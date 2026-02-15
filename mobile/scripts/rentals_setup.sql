-- Rentals MVP setup: deposit + atomic anti-overlap + owner-only access.
-- Safe to run multiple times.

begin;

create extension if not exists pgcrypto;

-- 1) Ensure pianos has minimum rental pricing fields.
alter table if exists public.pianos
  add column if not exists deposit_amount numeric not null default 0;

alter table if exists public.pianos
  add column if not exists daily_price numeric not null default 0;

alter table if exists public.pianos
  add column if not exists status text not null default 'available';

do $$
begin
  alter table public.pianos
    add constraint pianos_status_check
    check (status in ('available', 'rented', 'maintenance'));
exception
  when duplicate_object then
    null;
end $$;

-- Backfill daily_price from price_per_hour if daily_price is still 0.
update public.pianos
set daily_price = coalesce(nullif(daily_price, 0), price_per_hour, 0)
where coalesce(daily_price, 0) <= 0;

create table if not exists public.rentals (
  id uuid primary key default gen_random_uuid(),
  piano_id integer not null references public.pianos(id) on delete restrict,
  renter_id uuid not null references auth.users(id) on delete cascade,
  start_date date not null,
  end_date date not null,
  total_price numeric not null,
  deposit_amount numeric not null,
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

do $$
begin
  alter table public.rentals
    add constraint rentals_status_check
    check (status in ('pending', 'active', 'returned', 'cancelled'));
exception
  when duplicate_object then
    null;
end $$;

do $$
begin
  alter table public.rentals
    add constraint rentals_date_range_check
    check (start_date <= end_date);
exception
  when duplicate_object then
    null;
end $$;

create index if not exists idx_rentals_piano_dates_active
  on public.rentals (piano_id, start_date, end_date)
  where status in ('pending', 'active');

create index if not exists idx_rentals_renter_created_desc
  on public.rentals (renter_id, created_at desc);

alter table public.rentals enable row level security;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'rentals'
      and policyname = 'rentals_select_own'
  ) then
    create policy rentals_select_own
      on public.rentals
      for select
      to authenticated
      using (renter_id = auth.uid());
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'rentals'
      and policyname = 'rentals_insert_own'
  ) then
    create policy rentals_insert_own
      on public.rentals
      for insert
      to authenticated
      with check (renter_id = auth.uid());
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'rentals'
      and policyname = 'rentals_update_own'
  ) then
    create policy rentals_update_own
      on public.rentals
      for update
      to authenticated
      using (renter_id = auth.uid())
      with check (renter_id = auth.uid());
  end if;
end $$;

create or replace function public.create_rental_atomic(
  p_piano_id integer,
  p_start_date date,
  p_end_date date,
  p_total_price numeric,
  p_deposit_amount numeric,
  p_status text default 'pending'
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id uuid := auth.uid();
  v_conflict_id uuid;
  v_rental_id uuid;
  v_status text := lower(coalesce(nullif(trim(p_status), ''), 'pending'));
begin
  if v_user_id is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  if p_piano_id is null then
    raise exception 'PIANO_REQUIRED';
  end if;

  if p_start_date is null or p_end_date is null then
    raise exception 'DATE_REQUIRED';
  end if;

  if p_start_date > p_end_date then
    raise exception 'INVALID_DATE_RANGE';
  end if;

  if p_total_price is null or p_total_price < 0 then
    raise exception 'INVALID_TOTAL_PRICE';
  end if;

  if p_deposit_amount is null or p_deposit_amount < 0 then
    raise exception 'INVALID_DEPOSIT';
  end if;

  if v_status not in ('pending', 'active', 'returned', 'cancelled') then
    v_status := 'pending';
  end if;

  -- Serialize writes per piano to prevent race condition.
  perform pg_advisory_xact_lock(41001, p_piano_id);

  -- Overlap check with active rental statuses.
  select r.id
    into v_conflict_id
  from public.rentals r
  where r.piano_id = p_piano_id
    and r.status in ('pending', 'active')
    and r.start_date <= p_end_date
    and r.end_date >= p_start_date
  limit 1
  for update;

  if v_conflict_id is not null then
    raise exception 'RENTAL_CONFLICT:Timeslot already rented';
  end if;

  insert into public.rentals (
    piano_id,
    renter_id,
    start_date,
    end_date,
    total_price,
    deposit_amount,
    status
  )
  values (
    p_piano_id,
    v_user_id,
    p_start_date,
    p_end_date,
    p_total_price,
    p_deposit_amount,
    v_status
  )
  returning id into v_rental_id;

  return v_rental_id;
end;
$$;

revoke all on function public.create_rental_atomic(integer, date, date, numeric, numeric, text) from public;
grant execute on function public.create_rental_atomic(integer, date, date, numeric, numeric, text) to authenticated;

commit;
