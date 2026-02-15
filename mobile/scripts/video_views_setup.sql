-- Minimal TikTok-like view tracking (safe to re-run)
-- Records 1 view per feed per user/session per day.

begin;

alter table if exists public.social_feed
  add column if not exists view_count bigint not null default 0;

create table if not exists public.video_views (
  id bigserial primary key,
  feed_id text not null,
  user_id uuid references auth.users(id) on delete set null,
  session_id uuid not null,
  view_date date not null default current_date,
  created_at timestamptz not null default now()
);

-- Add FK only when social_feed.id is text-compatible.
do $$
declare
  v_data_type text;
begin
  select data_type
  into v_data_type
  from information_schema.columns
  where table_schema = 'public'
    and table_name = 'social_feed'
    and column_name = 'id';

  if v_data_type in ('text', 'character varying') then
    if not exists (
      select 1
      from information_schema.table_constraints
      where table_schema = 'public'
        and table_name = 'video_views'
        and constraint_name = 'video_views_feed_id_fkey'
    ) then
      alter table public.video_views
        add constraint video_views_feed_id_fkey
        foreign key (feed_id) references public.social_feed(id) on delete cascade;
    end if;
  end if;
end $$;

create index if not exists idx_video_views_feed_created_desc
  on public.video_views (feed_id, created_at desc);

create unique index if not exists ux_video_views_feed_user_day
  on public.video_views (feed_id, user_id, view_date)
  where user_id is not null;

create unique index if not exists ux_video_views_feed_session_day
  on public.video_views (feed_id, session_id, view_date)
  where user_id is null;

alter table public.video_views enable row level security;

-- Optional read policy for authenticated users (own events only).
do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'video_views'
      and policyname = 'video_views_select_own'
  ) then
    create policy video_views_select_own
      on public.video_views
      for select
      to authenticated
      using (user_id = auth.uid());
  end if;
end $$;

create or replace function public.record_view(
  p_feed_id text,
  p_session_id uuid
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_inserted_count int := 0;
  v_feed_id text := nullif(trim(p_feed_id), '');
begin
  if v_feed_id is null then
    raise exception 'p_feed_id is required';
  end if;

  if p_session_id is null then
    raise exception 'p_session_id is required';
  end if;

  if not exists (
    select 1 from public.social_feed where id::text = v_feed_id
  ) then
    return false;
  end if;

  if v_user_id is null then
    insert into public.video_views (feed_id, user_id, session_id, view_date)
    values (v_feed_id, null, p_session_id, current_date)
    on conflict do nothing;
  else
    insert into public.video_views (feed_id, user_id, session_id, view_date)
    values (v_feed_id, v_user_id, p_session_id, current_date)
    on conflict do nothing;
  end if;

  get diagnostics v_inserted_count = row_count;

  if v_inserted_count > 0 then
    update public.social_feed
    set view_count = coalesce(view_count, 0) + 1
    where id::text = v_feed_id;
    return true;
  end if;

  return false;
end;
$$;

revoke all on function public.record_view(text, uuid) from public;
grant execute on function public.record_view(text, uuid) to anon, authenticated;

commit;
