-- Follow system for creator/teacher profiles.
-- Safe to run multiple times.

begin;

create table if not exists public.follows (
  follower_id uuid not null references auth.users(id) on delete cascade,
  followee_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, followee_id),
  constraint follows_no_self check (follower_id <> followee_id)
);

create index if not exists idx_follows_followee_created_desc
  on public.follows (followee_id, created_at desc);

create index if not exists idx_follows_follower_created_desc
  on public.follows (follower_id, created_at desc);

alter table public.follows enable row level security;

-- Required for client-side following feed query.
do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'follows'
      and policyname = 'follows_select_authenticated'
  ) then
    create policy follows_select_authenticated
      on public.follows
      for select
      to authenticated
      using (true);
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'follows'
      and policyname = 'follows_insert_own'
  ) then
    create policy follows_insert_own
      on public.follows
      for insert
      to authenticated
      with check (follower_id = auth.uid());
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'follows'
      and policyname = 'follows_delete_own'
  ) then
    create policy follows_delete_own
      on public.follows
      for delete
      to authenticated
      using (follower_id = auth.uid());
  end if;
end $$;

-- Ensure new posts can be tied to creator account for follow feed.
alter table if exists public.social_feed
  add column if not exists author_id uuid references auth.users(id) on delete set null;

create index if not exists idx_social_feed_author_created_desc
  on public.social_feed (author_id, created_at desc, id desc);

create or replace function public.toggle_follow(
  p_followee_id uuid
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_follower_id uuid := auth.uid();
  v_deleted_count int := 0;
begin
  if v_follower_id is null then
    raise exception 'auth required';
  end if;

  if p_followee_id is null then
    raise exception 'p_followee_id is required';
  end if;

  if v_follower_id = p_followee_id then
    raise exception 'cannot follow yourself';
  end if;

  delete from public.follows
  where follower_id = v_follower_id
    and followee_id = p_followee_id;

  get diagnostics v_deleted_count = row_count;

  if v_deleted_count > 0 then
    return false;
  end if;

  insert into public.follows (follower_id, followee_id)
  values (v_follower_id, p_followee_id)
  on conflict do nothing;

  return true;
end;
$$;

create or replace function public.get_profile_stats(
  p_user_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_followers_count bigint := 0;
  v_following_count bigint := 0;
  v_posts_count bigint := 0;
begin
  if p_user_id is null then
    return jsonb_build_object(
      'followers_count', 0,
      'following_count', 0,
      'posts_count', 0
    );
  end if;

  select count(*)
  into v_followers_count
  from public.follows
  where followee_id = p_user_id;

  select count(*)
  into v_following_count
  from public.follows
  where follower_id = p_user_id;

  select count(*)
  into v_posts_count
  from public.social_feed
  where author_id = p_user_id;

  return jsonb_build_object(
    'followers_count', coalesce(v_followers_count, 0),
    'following_count', coalesce(v_following_count, 0),
    'posts_count', coalesce(v_posts_count, 0)
  );
end;
$$;

revoke all on function public.toggle_follow(uuid) from public;
revoke all on function public.get_profile_stats(uuid) from public;
grant execute on function public.toggle_follow(uuid) to authenticated;
grant execute on function public.get_profile_stats(uuid) to anon, authenticated;

commit;
