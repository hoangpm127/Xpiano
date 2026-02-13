-- Admin teacher review RPCs (dev-friendly).
-- Purpose:
-- 1) Allow admin screen in app to list all teacher profiles despite owner-only RLS.
-- 2) Approve pending teacher profiles from app.
-- Safe to run multiple times.

begin;

create or replace function public.admin_list_teacher_profiles()
returns setof public.teacher_profiles
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if auth.uid() is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  return query
  select *
  from public.teacher_profiles
  order by created_at desc nulls last;
end;
$$;

create or replace function public.admin_approve_all_pending_teachers()
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_pending_count integer := 0;
begin
  if auth.uid() is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  select count(*)
  into v_pending_count
  from public.teacher_profiles
  where verification_status = 'pending';

  if v_pending_count = 0 then
    return jsonb_build_object(
      'success', true,
      'count', 0,
      'message', 'Không có giáo viên nào đang chờ duyệt'
    );
  end if;

  update public.teacher_profiles
  set verification_status = 'approved',
      approved_at = now()
  where verification_status = 'pending';

  return jsonb_build_object(
    'success', true,
    'count', v_pending_count,
    'message', format('Đã duyệt %s giáo viên thành công', v_pending_count)
  );
end;
$$;

revoke all on function public.admin_list_teacher_profiles() from public;
revoke all on function public.admin_approve_all_pending_teachers() from public;
grant execute on function public.admin_list_teacher_profiles() to authenticated;
grant execute on function public.admin_approve_all_pending_teachers() to authenticated;

commit;
