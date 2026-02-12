-- Booking RLS setup (owner-first policy model)
-- Safe to run multiple times.

begin;

alter table if exists public.bookings
  enable row level security;

-- 1) Owner can read only own bookings.
do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'bookings'
      and policyname = 'bookings_select_own'
  ) then
    create policy bookings_select_own
      on public.bookings
      for select
      to authenticated
      using (user_id = auth.uid());
  end if;
end $$;

-- 2) Owner can insert only rows bound to self.
--    Note: app should still prefer RPC create_booking_atomic.
do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'bookings'
      and policyname = 'bookings_insert_own'
  ) then
    create policy bookings_insert_own
      on public.bookings
      for insert
      to authenticated
      with check (user_id = auth.uid());
  end if;
end $$;

-- 3) Owner can update only own bookings (for cancel/status changes).
do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'bookings'
      and policyname = 'bookings_update_own'
  ) then
    create policy bookings_update_own
      on public.bookings
      for update
      to authenticated
      using (user_id = auth.uid())
      with check (user_id = auth.uid());
  end if;
end $$;

-- 4) Optional delete: allow only owner and only when pending.
--    If you want to block delete entirely, drop this policy.
do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'bookings'
      and policyname = 'bookings_delete_own_pending'
  ) then
    create policy bookings_delete_own_pending
      on public.bookings
      for delete
      to authenticated
      using (user_id = auth.uid() and status = 'pending');
  end if;
end $$;

commit;
