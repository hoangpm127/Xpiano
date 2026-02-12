-- Atomic booking setup: prevent double booking on overlapping timeslots.
-- Safe to run multiple times.

begin;

do $$
begin
  alter table public.bookings
    add constraint bookings_start_before_end
    check (start_time < end_time);
exception
  when duplicate_object then
    null;
end $$;

create index if not exists idx_bookings_piano_time_active
  on public.bookings (piano_id, start_time, end_time)
  where status in ('pending', 'confirmed');

create unique index if not exists ux_bookings_piano_start_active
  on public.bookings (piano_id, start_time)
  where status in ('pending', 'confirmed');

create or replace function public.create_booking_atomic(
  p_piano_id integer,
  p_start timestamptz,
  p_end timestamptz,
  p_total_price numeric,
  p_status text default 'confirmed'
)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_conflict_id bigint;
  v_booking_id bigint;
  v_status text := lower(coalesce(nullif(trim(p_status), ''), 'confirmed'));
begin
  if v_user_id is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  if p_piano_id is null then
    raise exception 'PIANO_REQUIRED';
  end if;

  if p_start is null or p_end is null then
    raise exception 'TIME_REQUIRED';
  end if;

  if p_start >= p_end then
    raise exception 'INVALID_TIME_RANGE';
  end if;

  if p_total_price is null or p_total_price <= 0 then
    raise exception 'INVALID_TOTAL_PRICE';
  end if;

  if v_status not in ('pending', 'confirmed') then
    v_status := 'confirmed';
  end if;

  -- Serialize booking writes for the same piano inside this transaction.
  perform pg_advisory_xact_lock(31001, p_piano_id);

  -- Lock any conflicting rows (if present) and reject overlap.
  select b.id
    into v_conflict_id
  from public.bookings b
  where b.piano_id = p_piano_id
    and b.status in ('pending', 'confirmed')
    and b.start_time < p_end
    and b.end_time > p_start
  limit 1
  for update;

  if v_conflict_id is not null then
    raise exception 'BOOKING_CONFLICT:Timeslot already booked';
  end if;

  insert into public.bookings (
    user_id,
    piano_id,
    start_time,
    end_time,
    total_price,
    status
  )
  values (
    v_user_id,
    p_piano_id,
    p_start,
    p_end,
    p_total_price,
    v_status
  )
  returning id into v_booking_id;

  return v_booking_id;
end;
$$;

revoke all on function public.create_booking_atomic(integer, timestamptz, timestamptz, numeric, text) from public;
grant execute on function public.create_booking_atomic(integer, timestamptz, timestamptz, numeric, text) to authenticated;

commit;
