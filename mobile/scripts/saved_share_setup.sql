-- Setup DB tables for Save + Share tracking.
-- NOTE: This project currently uses social_feed.id as bigint.
-- Safe to run multiple times.

begin;

create table if not exists public.saved_posts (
  user_id uuid not null references auth.users(id) on delete cascade,
  feed_id bigint not null references public.social_feed(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, feed_id)
);

create table if not exists public.share_events (
  id bigserial primary key,
  feed_id bigint not null references public.social_feed(id) on delete cascade,
  user_id uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create index if not exists idx_saved_posts_user_created_desc
  on public.saved_posts (user_id, created_at desc);

create index if not exists idx_share_events_feed_created_desc
  on public.share_events (feed_id, created_at desc);

alter table public.saved_posts enable row level security;
alter table public.share_events enable row level security;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'saved_posts'
      and policyname = 'saved_posts_select_own'
  ) then
    create policy saved_posts_select_own
      on public.saved_posts
      for select
      to authenticated
      using (user_id = auth.uid());
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'saved_posts'
      and policyname = 'saved_posts_insert_own'
  ) then
    create policy saved_posts_insert_own
      on public.saved_posts
      for insert
      to authenticated
      with check (user_id = auth.uid());
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'saved_posts'
      and policyname = 'saved_posts_delete_own'
  ) then
    create policy saved_posts_delete_own
      on public.saved_posts
      for delete
      to authenticated
      using (user_id = auth.uid());
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'share_events'
      and policyname = 'share_events_insert_own'
  ) then
    create policy share_events_insert_own
      on public.share_events
      for insert
      to authenticated
      with check (user_id = auth.uid());
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'share_events'
      and policyname = 'share_events_select_own'
  ) then
    create policy share_events_select_own
      on public.share_events
      for select
      to authenticated
      using (user_id = auth.uid());
  end if;
end $$;

commit;
