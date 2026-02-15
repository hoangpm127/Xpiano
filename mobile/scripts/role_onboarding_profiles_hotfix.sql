-- Hotfix for legacy profiles schemas where primary key is `id`
-- and `user_id` may be null, causing upgrade_role to fail with duplicate key.
-- Safe to run multiple times.

begin;

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
         where user_id = $2'
      using v_target_role, v_uid;
      get diagnostics v_updated_rows = row_count;
      if v_updated_rows = 0 then
        execute
          'update public.profiles
           set user_id = $2,
               profile_status = case
                 when $1 = ''learner'' then ''learner_ready''
                 else ''teacher_pending''
               end,
               updated_at = now()
           where id = $2'
        using v_target_role, v_uid;
      end if;
    elsif v_has_id_text then
      execute
        'update public.profiles
         set profile_status = case
           when $1 = ''learner'' then ''learner_ready''
           else ''teacher_pending''
         end,
         updated_at = now()
         where user_id = $2'
      using v_target_role, v_uid;
      get diagnostics v_updated_rows = row_count;
      if v_updated_rows = 0 then
        execute
          'update public.profiles
           set user_id = $2,
               profile_status = case
                 when $1 = ''learner'' then ''learner_ready''
                 else ''teacher_pending''
               end,
               updated_at = now()
           where id = $3'
        using v_target_role, v_uid, v_uid::text;
      end if;
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
       where user_id = $2'
    using v_target_role, v_uid;
    get diagnostics v_updated_rows = row_count;
    if v_updated_rows = 0 then
      execute
        'update public.profiles
         set user_id = $2,
             role = $1,
             profile_status = case
               when $1 = ''learner'' then ''learner_ready''
               else ''teacher_pending''
             end,
             updated_at = now()
         where id = $2'
      using v_target_role, v_uid;
      get diagnostics v_updated_rows = row_count;
    end if;
  elsif v_has_id_text then
    execute
      'update public.profiles
       set role = $1,
           profile_status = case
             when $1 = ''learner'' then ''learner_ready''
             else ''teacher_pending''
           end,
           updated_at = now()
       where user_id = $2'
    using v_target_role, v_uid;
    get diagnostics v_updated_rows = row_count;
    if v_updated_rows = 0 then
      execute
        'update public.profiles
         set user_id = $2,
             role = $1,
             profile_status = case
               when $1 = ''learner'' then ''learner_ready''
               else ''teacher_pending''
             end,
             updated_at = now()
         where id = $3'
      using v_target_role, v_uid, v_uid::text;
      get diagnostics v_updated_rows = row_count;
    end if;
  else
    update public.profiles
    set role = v_target_role,
        profile_status = case
          when v_target_role = 'learner' then 'learner_ready'
          else 'teacher_pending'
        end,
        updated_at = now()
    where user_id = v_uid;
    get diagnostics v_updated_rows = row_count;
  end if;

  if v_updated_rows = 0 then
    raise exception 'PROFILE_UPDATE_FAILED';
  elsif v_updated_rows > 1 then
    raise exception 'DUPLICATE_PROFILE_ROWS_DETECTED';
  end if;

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
