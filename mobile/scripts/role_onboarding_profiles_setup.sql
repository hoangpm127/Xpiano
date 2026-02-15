-- Role and onboarding foundation for guest/learner/teacher.
-- Safe to run multiple times.

begin;

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'guest',
  profile_status text not null default 'basic',
  full_name text,
  avatar_url text,
  phone text,
  address_line text,
  city text,
  district text,
  updated_at timestamptz not null default now()
);

alter table if exists public.profiles
  add column if not exists role text not null default 'guest';

alter table if exists public.profiles
  add column if not exists profile_status text not null default 'basic';

alter table if exists public.profiles
  add column if not exists full_name text;

alter table if exists public.profiles
  add column if not exists avatar_url text;

alter table if exists public.profiles
  add column if not exists phone text;

alter table if exists public.profiles
  add column if not exists address_line text;

alter table if exists public.profiles
  add column if not exists city text;

alter table if exists public.profiles
  add column if not exists district text;

alter table if exists public.profiles
  add column if not exists updated_at timestamptz not null default now();

-- Compatibility for existing projects that already had a `profiles` table
-- with primary key `id` instead of `user_id`.
do $$
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'user_id'
  ) then
    alter table public.profiles
      add column user_id uuid;
  end if;

  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'id'
  ) then
    -- Best-effort backfill from legacy id column.
    execute $sql$
      update public.profiles
      set user_id = case
        when id is null then user_id
        when id::text ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
          then id::text::uuid
        else user_id
      end
      where user_id is null
    $sql$;
  end if;
end $$;

-- Ensure legacy non-null `id` column (if present) can auto-generate value
-- so inserts that only provide `user_id` do not fail.
do $$
declare
  v_id_type text;
  v_id_default text;
  v_has_id_fk boolean := false;
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'id'
  ) then
    select c.data_type, c.column_default
      into v_id_type, v_id_default
    from information_schema.columns c
    where c.table_schema = 'public'
      and c.table_name = 'profiles'
      and c.column_name = 'id';

    select exists (
      select 1
      from information_schema.table_constraints tc
      join information_schema.key_column_usage kcu
        on tc.constraint_name = kcu.constraint_name
       and tc.table_schema = kcu.table_schema
      where tc.table_schema = 'public'
        and tc.table_name = 'profiles'
        and tc.constraint_type = 'FOREIGN KEY'
        and kcu.column_name = 'id'
    ) into v_has_id_fk;

    if v_has_id_fk then
      -- FK-backed id must map to real user ids, never random.
      alter table public.profiles
        alter column id drop default;
    elsif v_id_default is null then
      if v_id_type = 'uuid' then
        alter table public.profiles
          alter column id set default gen_random_uuid();
      elsif v_id_type in ('text', 'character varying') then
        alter table public.profiles
          alter column id set default gen_random_uuid()::text;
      elsif v_id_type in ('integer', 'bigint') then
        create sequence if not exists public.profiles_id_seq;
        execute format(
          'select setval(''public.profiles_id_seq'', coalesce((select max(id)::bigint from public.profiles), 0))'
        );
        alter table public.profiles
          alter column id set default nextval('public.profiles_id_seq');
      end if;
    end if;

    -- Keep legacy id/user_id aligned.
    if v_id_type = 'uuid' then
      update public.profiles
      set user_id = coalesce(user_id, id)
      where user_id is null
        and id is not null;

      if v_has_id_fk then
        update public.profiles
        set id = user_id
        where user_id is not null
          and id is null;
      else
        -- Best-effort fill for nullable legacy rows.
        update public.profiles
        set id = coalesce(id, gen_random_uuid())
        where id is null;
      end if;
    elsif v_id_type in ('text', 'character varying') then
      update public.profiles
      set user_id = case
        when user_id is not null then user_id
        when id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
          then id::uuid
        else null
      end
      where user_id is null;

      if v_has_id_fk then
        update public.profiles
        set id = user_id::text
        where user_id is not null
          and (id is null or btrim(id) = '');
      else
        -- Best-effort fill for nullable legacy rows.
        update public.profiles
        set id = coalesce(id, gen_random_uuid()::text)
        where id is null;
      end if;
    elsif v_id_type in ('integer', 'bigint') then
      if not v_has_id_fk then
        create sequence if not exists public.profiles_id_seq;
        update public.profiles
        set id = coalesce(id, nextval('public.profiles_id_seq'))
        where id is null;
      end if;
    end if;

    -- For legacy schemas with FK on id, auto-copy user_id into id on insert.
    if v_has_id_fk and v_id_type in ('uuid', 'text', 'character varying') then
      create or replace function public.sync_profiles_legacy_id()
      returns trigger
      language plpgsql
      as $fn$
      begin
        if new.user_id is null then
          return new;
        end if;

        if tg_argv[0] = 'uuid' then
          new.id := new.user_id;
        elsif tg_argv[0] = 'text' or tg_argv[0] = 'character varying' then
          new.id := new.user_id::text;
        end if;
        return new;
      end;
      $fn$;

      drop trigger if exists trg_profiles_sync_legacy_id on public.profiles;
      execute format(
        'create trigger trg_profiles_sync_legacy_id
         before insert on public.profiles
         for each row
         execute function public.sync_profiles_legacy_id(%L)',
        v_id_type
      );
    end if;
  end if;
end $$;

-- Drop legacy role/profile_status check constraints so we can migrate values.
do $$
declare
  r record;
begin
  for r in
    select conname
    from pg_constraint
    where conrelid = 'public.profiles'::regclass
      and contype = 'c'
      and (
        conname ilike '%role%'
        or pg_get_constraintdef(oid) ilike '% role %'
        or pg_get_constraintdef(oid) ilike '%role in (%'
      )
  loop
    execute format(
      'alter table public.profiles drop constraint if exists %I',
      r.conname
    );
  end loop;

  for r in
    select conname
    from pg_constraint
    where conrelid = 'public.profiles'::regclass
      and contype = 'c'
      and (
        conname ilike '%profile_status%'
        or pg_get_constraintdef(oid) ilike '%profile_status%'
      )
  loop
    execute format(
      'alter table public.profiles drop constraint if exists %I',
      r.conname
    );
  end loop;
end $$;

-- Normalize legacy role/status values before adding new checks.
update public.profiles
set role = case lower(coalesce(role, ''))
  when 'student' then 'learner'
  when 'learner' then 'learner'
  when 'teacher' then 'teacher'
  when 'guest' then 'guest'
  else 'guest'
end;

update public.profiles
set profile_status = case lower(coalesce(profile_status, ''))
  when 'basic' then 'basic'
  when 'contact_ready' then 'contact_ready'
  when 'learner_ready' then 'learner_ready'
  when 'teacher_pending' then 'teacher_pending'
  when 'teacher_approved' then 'teacher_approved'
  when 'approved' then 'teacher_approved'
  when 'pending' then 'teacher_pending'
  else 'basic'
end;

do $$
begin
  alter table public.profiles
    add constraint profiles_role_check
    check (role in ('guest', 'learner', 'teacher'));
exception
  when duplicate_object then
    null;
end $$;

do $$
begin
  alter table public.profiles
    add constraint profiles_status_check
    check (
      profile_status in (
        'basic',
        'contact_ready',
        'learner_ready',
        'teacher_pending',
        'teacher_approved'
      )
    );
exception
  when duplicate_object then
    null;
end $$;

create or replace function public.set_profiles_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at
before update on public.profiles
for each row
execute function public.set_profiles_updated_at();

-- Backfill all users into profiles.
insert into public.profiles (
  user_id,
  role,
  profile_status,
  full_name,
  avatar_url
)
select
  u.id,
  case lower(coalesce(u.raw_user_meta_data ->> 'role', 'guest'))
    when 'teacher' then 'teacher'
    when 'learner' then 'learner'
    when 'student' then 'learner'
    else 'guest'
  end as role,
  case lower(coalesce(u.raw_user_meta_data ->> 'role', 'guest'))
    when 'teacher' then 'teacher_pending'
    when 'learner' then 'learner_ready'
    when 'student' then 'learner_ready'
    else 'basic'
  end as profile_status,
  nullif(trim(coalesce(u.raw_user_meta_data ->> 'full_name', '')), ''),
  nullif(trim(coalesce(u.raw_user_meta_data ->> 'avatar_url', '')), '')
from auth.users u
where not exists (
  select 1
  from public.profiles p
  where p.user_id = u.id
);

-- Merge metadata for existing rows mapped by user_id.
update public.profiles p
set full_name = coalesce(p.full_name, nullif(trim(coalesce(u.raw_user_meta_data ->> 'full_name', '')), '')),
    avatar_url = coalesce(p.avatar_url, nullif(trim(coalesce(u.raw_user_meta_data ->> 'avatar_url', '')), '')),
    updated_at = now()
from auth.users u
where p.user_id = u.id;

-- If teacher_profiles has approval state, sync teacher profile_status.
do $$
begin
  if exists (
    select 1
    from information_schema.tables
    where table_schema = 'public'
      and table_name = 'teacher_profiles'
  ) and exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'teacher_profiles'
      and column_name = 'verification_status'
  ) then
    update public.profiles p
    set profile_status = case
      when lower(coalesce(tp.verification_status, '')) = 'approved'
        then 'teacher_approved'
      else 'teacher_pending'
    end
    from public.teacher_profiles tp
    where p.user_id = tp.user_id
      and p.role = 'teacher';
  end if;
end $$;

-- Optional learner profile table for future extension.
create table if not exists public.learner_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists trg_learner_profiles_updated_at on public.learner_profiles;
create trigger trg_learner_profiles_updated_at
before update on public.learner_profiles
for each row
execute function public.set_profiles_updated_at();

alter table public.profiles enable row level security;
alter table public.learner_profiles enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'profiles'
      and policyname = 'profiles_select_own'
  ) then
    create policy profiles_select_own
      on public.profiles
      for select
      to authenticated
      using (user_id = auth.uid());
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'profiles'
      and policyname = 'profiles_insert_own'
  ) then
    create policy profiles_insert_own
      on public.profiles
      for insert
      to authenticated
      with check (user_id = auth.uid());
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'profiles'
      and policyname = 'profiles_update_own'
  ) then
    create policy profiles_update_own
      on public.profiles
      for update
      to authenticated
      using (user_id = auth.uid())
      with check (user_id = auth.uid());
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'learner_profiles'
      and policyname = 'learner_profiles_select_own'
  ) then
    create policy learner_profiles_select_own
      on public.learner_profiles
      for select
      to authenticated
      using (user_id = auth.uid());
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'learner_profiles'
      and policyname = 'learner_profiles_insert_learner'
  ) then
    create policy learner_profiles_insert_learner
      on public.learner_profiles
      for insert
      to authenticated
      with check (
        user_id = auth.uid()
        and exists (
          select 1
          from public.profiles p
          where p.user_id = auth.uid()
            and p.role = 'learner'
        )
      );
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'learner_profiles'
      and policyname = 'learner_profiles_update_own'
  ) then
    create policy learner_profiles_update_own
      on public.learner_profiles
      for update
      to authenticated
      using (user_id = auth.uid())
      with check (user_id = auth.uid());
  end if;
end $$;

-- Lock teacher_profiles to owner-only (if table exists).
do $$
declare
  v_policy text;
begin
  if exists (
    select 1
    from information_schema.tables
    where table_schema = 'public'
      and table_name = 'teacher_profiles'
  ) then
    alter table public.teacher_profiles enable row level security;
    create index if not exists idx_teacher_profiles_user_id
      on public.teacher_profiles (user_id);

    -- Drop known broad/public policies created earlier.
    foreach v_policy in array array[
      'Allow public read access',
      'Public profiles are viewable by everyone',
      'Users can view all teacher profiles'
    ]
    loop
      execute format(
        'drop policy if exists %I on public.teacher_profiles',
        v_policy
      );
    end loop;

    if not exists (
      select 1 from pg_policies
      where schemaname = 'public' and tablename = 'teacher_profiles'
        and policyname = 'teacher_profiles_select_own'
    ) then
      create policy teacher_profiles_select_own
        on public.teacher_profiles
        for select
        to authenticated
        using (user_id = auth.uid());
    end if;

    if not exists (
      select 1 from pg_policies
      where schemaname = 'public' and tablename = 'teacher_profiles'
        and policyname = 'teacher_profiles_insert_teacher'
    ) then
      create policy teacher_profiles_insert_teacher
        on public.teacher_profiles
        for insert
        to authenticated
        with check (
          user_id = auth.uid()
          and exists (
            select 1
            from public.profiles p
            where p.user_id = auth.uid()
              and p.role = 'teacher'
          )
        );
    end if;

    if not exists (
      select 1 from pg_policies
      where schemaname = 'public' and tablename = 'teacher_profiles'
        and policyname = 'teacher_profiles_update_own'
    ) then
      create policy teacher_profiles_update_own
        on public.teacher_profiles
        for update
        to authenticated
        using (user_id = auth.uid())
        with check (user_id = auth.uid());
    end if;
  end if;
end $$;

-- One-time backfill for legacy rows: map user_id from id when possible.
do $$
declare
  v_has_id_uuid boolean := false;
  v_has_id_text boolean := false;
begin
  select exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'id'
      and udt_name = 'uuid'
  ) into v_has_id_uuid;

  select exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'id'
      and udt_name in ('text', 'varchar')
  ) into v_has_id_text;

  if v_has_id_uuid then
    update public.profiles p
    set user_id = p.id
    where p.user_id is null
      and p.id is not null
      and exists (
        select 1
        from auth.users u
        where u.id = p.id
      );
  elsif v_has_id_text then
    update public.profiles p
    set user_id = p.id::uuid
    where p.user_id is null
      and p.id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
      and exists (
        select 1
        from auth.users u
        where u.id = p.id::uuid
      );
  end if;
end $$;

create or replace function public.upsert_contact_info(
  p_phone text,
  p_address_line text,
  p_city text default null,
  p_district text default null
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_phone text := nullif(trim(coalesce(p_phone, '')), '');
  v_address text := nullif(trim(coalesce(p_address_line, '')), '');
  v_city text := nullif(trim(coalesce(p_city, '')), '');
  v_district text := nullif(trim(coalesce(p_district, '')), '');
  v_has_id_uuid boolean := false;
  v_has_id_text boolean := false;
begin
  if v_uid is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  if v_phone is null or v_address is null then
    raise exception 'PHONE_AND_ADDRESS_REQUIRED';
  end if;

  select exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'id'
      and udt_name = 'uuid'
  ) into v_has_id_uuid;

  select exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'id'
      and udt_name in ('text', 'varchar')
  ) into v_has_id_text;

  update public.profiles
  set phone = v_phone,
      address_line = v_address,
      city = v_city,
      district = v_district,
      profile_status = case
        when public.profiles.profile_status in (
          'learner_ready',
          'teacher_pending',
          'teacher_approved'
        )
          then public.profiles.profile_status
        else 'contact_ready'
      end,
      updated_at = now()
  where user_id = v_uid;

  if found then
    return;
  end if;

  -- Legacy fallback: row may exist by id while user_id is null.
  if v_has_id_uuid then
    execute
      'update public.profiles
       set user_id = $1,
           phone = $2,
           address_line = $3,
           city = $4,
           district = $5,
           profile_status = case
             when profile_status in (''learner_ready'', ''teacher_pending'', ''teacher_approved'')
               then profile_status
             else ''contact_ready''
           end,
           updated_at = now()
       where id = $1'
      using v_uid, v_phone, v_address, v_city, v_district;
  elsif v_has_id_text then
    execute
      'update public.profiles
       set user_id = $1,
           phone = $2,
           address_line = $3,
           city = $4,
           district = $5,
           profile_status = case
             when profile_status in (''learner_ready'', ''teacher_pending'', ''teacher_approved'')
               then profile_status
             else ''contact_ready''
           end,
           updated_at = now()
       where id = $6'
      using v_uid, v_phone, v_address, v_city, v_district, v_uid::text;
  end if;

  if found then
    return;
  end if;

  if v_has_id_uuid then
    execute
      'insert into public.profiles (
         id, user_id, role, profile_status, phone, address_line, city, district, updated_at
       )
       values ($1, $1, ''guest'', ''contact_ready'', $2, $3, $4, $5, now())
       on conflict (id) do update
       set user_id = excluded.user_id,
           phone = excluded.phone,
           address_line = excluded.address_line,
           city = excluded.city,
           district = excluded.district,
           profile_status = case
             when public.profiles.profile_status in (''learner_ready'', ''teacher_pending'', ''teacher_approved'')
               then public.profiles.profile_status
             else ''contact_ready''
           end,
           updated_at = now()'
      using v_uid, v_phone, v_address, v_city, v_district;
  elsif v_has_id_text then
    execute
      'insert into public.profiles (
         id, user_id, role, profile_status, phone, address_line, city, district, updated_at
       )
       values ($1, $2, ''guest'', ''contact_ready'', $3, $4, $5, $6, now())
       on conflict (id) do update
       set user_id = excluded.user_id,
           phone = excluded.phone,
           address_line = excluded.address_line,
           city = excluded.city,
           district = excluded.district,
           profile_status = case
             when public.profiles.profile_status in (''learner_ready'', ''teacher_pending'', ''teacher_approved'')
               then public.profiles.profile_status
             else ''contact_ready''
           end,
           updated_at = now()'
      using v_uid::text, v_uid, v_phone, v_address, v_city, v_district;
  else
    insert into public.profiles (
      user_id,
      role,
      profile_status,
      phone,
      address_line,
      city,
      district,
      updated_at
    )
    values (
      v_uid,
      'guest',
      'contact_ready',
      v_phone,
      v_address,
      v_city,
      v_district,
      now()
    )
    on conflict (user_id) do update
    set phone = excluded.phone,
        address_line = excluded.address_line,
        city = excluded.city,
        district = excluded.district,
        profile_status = case
          when public.profiles.profile_status in ('learner_ready', 'teacher_pending', 'teacher_approved')
            then public.profiles.profile_status
          else 'contact_ready'
        end,
        updated_at = now();
  end if;
end;
$$;

create or replace function public.upgrade_role(
  p_role text
)
returns text
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_target_role text := lower(coalesce(trim(p_role), ''));
  v_current_role text;
  v_has_id_uuid boolean := false;
  v_has_id_text boolean := false;
  v_updated_rows integer := 0;
begin
  if v_uid is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  if v_target_role not in ('learner', 'teacher') then
    raise exception 'INVALID_TARGET_ROLE';
  end if;

  select exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'id'
      and udt_name = 'uuid'
  ) into v_has_id_uuid;

  select exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'id'
      and udt_name in ('text', 'varchar')
  ) into v_has_id_text;

  select role
    into v_current_role
  from public.profiles
  where user_id = v_uid
  for update;

  if v_current_role is null then
    if v_has_id_uuid then
      execute
        'select role
         from public.profiles
         where id = $1
         for update'
      into v_current_role
      using v_uid;

      if v_current_role is not null then
        execute
          'update public.profiles
           set user_id = $1,
               updated_at = now()
           where id = $1
             and (user_id is null or user_id <> $1)'
        using v_uid;
      end if;
    elsif v_has_id_text then
      execute
        'select role
         from public.profiles
         where id = $1
         for update'
      into v_current_role
      using v_uid::text;

      if v_current_role is not null then
        execute
          'update public.profiles
           set user_id = $1,
               updated_at = now()
           where id = $2
             and (user_id is null or user_id <> $1)'
        using v_uid, v_uid::text;
      end if;
    end if;
  end if;

  if v_current_role is null then
    if v_has_id_uuid then
      execute
        'insert into public.profiles (id, user_id, role, profile_status, updated_at)
         values ($1, $1, ''guest'', ''basic'', now())
         on conflict (id) do update
         set user_id = excluded.user_id,
             updated_at = now()'
      using v_uid;
    elsif v_has_id_text then
      execute
        'insert into public.profiles (id, user_id, role, profile_status, updated_at)
         values ($1, $2, ''guest'', ''basic'', now())
         on conflict (id) do update
         set user_id = excluded.user_id,
             updated_at = now()'
      using v_uid::text, v_uid;
    else
      insert into public.profiles (user_id, role, profile_status, updated_at)
      values (v_uid, 'guest', 'basic', now())
      on conflict (user_id) do nothing;
    end if;

    select role
      into v_current_role
    from public.profiles
    where user_id = v_uid
    for update;

    if v_current_role is null and v_has_id_uuid then
      execute
        'select role
         from public.profiles
         where id = $1
         for update'
      into v_current_role
      using v_uid;
    elsif v_current_role is null and v_has_id_text then
      execute
        'select role
         from public.profiles
         where id = $1
         for update'
      into v_current_role
      using v_uid::text;
    end if;
  end if;

  if v_current_role is null then
    raise exception 'PROFILE_ROW_NOT_FOUND';
  end if;

  v_current_role := lower(v_current_role);

  -- Idempotent behavior: if user already chose this role before,
  -- return success so app can continue teacher/learner flow.
  if v_current_role = v_target_role then
    if v_has_id_uuid then
      execute
        'update public.profiles
         set profile_status = case
           when $1 = ''learner'' then ''learner_ready''
           else ''teacher_pending''
         end,
         updated_at = now()
         where user_id = $2 or id = $2'
      using v_target_role, v_uid;
    elsif v_has_id_text then
      execute
        'update public.profiles
         set profile_status = case
           when $1 = ''learner'' then ''learner_ready''
           else ''teacher_pending''
         end,
         updated_at = now()
         where user_id = $2 or id = $3'
      using v_target_role, v_uid, v_uid::text;
    else
      update public.profiles
      set profile_status = case
            when v_target_role = 'learner' then 'learner_ready'
            else 'teacher_pending'
          end,
          updated_at = now()
      where user_id = v_uid;
    end if;

    update auth.users
    set raw_user_meta_data = coalesce(raw_user_meta_data, '{}'::jsonb)
        || jsonb_build_object('role', v_target_role)
    where id = v_uid;

    return v_target_role;
  end if;

  if v_current_role <> 'guest' then
    raise exception 'ROLE_ALREADY_FINAL:%', v_current_role;
  end if;

  if v_has_id_uuid then
    execute
      'update public.profiles
       set role = $1,
           profile_status = case
             when $1 = ''learner'' then ''learner_ready''
             else ''teacher_pending''
           end,
           updated_at = now()
       where user_id = $2 or id = $2'
    using v_target_role, v_uid;
  elsif v_has_id_text then
    execute
      'update public.profiles
       set role = $1,
           profile_status = case
             when $1 = ''learner'' then ''learner_ready''
             else ''teacher_pending''
           end,
           updated_at = now()
       where user_id = $2 or id = $3'
    using v_target_role, v_uid, v_uid::text;
  else
    update public.profiles
    set role = v_target_role,
        profile_status = case
          when v_target_role = 'learner' then 'learner_ready'
          else 'teacher_pending'
        end,
        updated_at = now()
    where user_id = v_uid;
  end if;

  get diagnostics v_updated_rows = row_count;
  if v_updated_rows = 0 then
    raise exception 'PROFILE_UPDATE_FAILED';
  end if;

  -- Keep legacy metadata in sync for old UI paths.
  update auth.users
  set raw_user_meta_data = coalesce(raw_user_meta_data, '{}'::jsonb)
      || jsonb_build_object('role', v_target_role)
  where id = v_uid;

  return v_target_role;
end;
$$;

revoke all on function public.upsert_contact_info(text, text, text, text) from public;
revoke all on function public.upgrade_role(text) from public;
grant execute on function public.upsert_contact_info(text, text, text, text) to authenticated;
grant execute on function public.upgrade_role(text) to authenticated;

commit;
