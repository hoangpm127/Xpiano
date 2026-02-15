-- Hotfix: fix "infinite recursion detected in policy for relation profiles"
-- Safe to run multiple times.
--
-- Why this happens:
-- - Legacy DB may have a profiles policy that queries public.profiles again
--   (directly/indirectly), causing recursive policy evaluation.
--
-- What this script does:
-- 1) Ensure profiles.user_id exists and backfill from legacy id where possible.
-- 2) Drop ALL existing policies on public.profiles.
-- 3) Recreate minimal owner-only policies (no self-referencing subqueries).

begin;

alter table if exists public.profiles
  add column if not exists user_id uuid;

-- Backfill user_id from legacy id column when possible.
do $$
declare
  v_id_type text;
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'id'
  ) then
    select data_type
      into v_id_type
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'id';

    if v_id_type = 'uuid' then
      update public.profiles p
      set user_id = p.id
      where p.user_id is null
        and p.id is not null
        and exists (select 1 from auth.users u where u.id = p.id);
    elsif v_id_type in ('text', 'character varying') then
      update public.profiles p
      set user_id = p.id::uuid
      where p.user_id is null
        and p.id is not null
        and p.id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
        and exists (select 1 from auth.users u where u.id = p.id::uuid);
    end if;
  end if;
end $$;

-- Drop every existing policy on public.profiles (including unknown legacy ones).
do $$
declare
  r record;
begin
  for r in
    select policyname
    from pg_policies
    where schemaname = 'public'
      and tablename = 'profiles'
  loop
    execute format('drop policy if exists %I on public.profiles', r.policyname);
  end loop;
end $$;

alter table public.profiles enable row level security;

-- Recreate minimal non-recursive policies.
create policy profiles_select_own
  on public.profiles
  for select
  to authenticated
  using (user_id = auth.uid());

create policy profiles_insert_own
  on public.profiles
  for insert
  to authenticated
  with check (user_id = auth.uid());

create policy profiles_update_own
  on public.profiles
  for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

commit;

-- Optional verification:
-- select policyname, cmd, qual, with_check
-- from pg_policies
-- where schemaname='public' and tablename='profiles'
-- order by policyname;

