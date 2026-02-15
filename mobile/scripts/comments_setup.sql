-- Setup DB objects for feed comments.
-- Safe to run multiple times.

begin;

create table if not exists public.comments (
  id bigserial primary key,
  feed_id bigint not null references public.social_feed(id) on delete cascade,
  user_id uuid not null default auth.uid(),
  content text not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_comments_feed_created_desc
  on public.comments (feed_id, created_at desc);

alter table public.comments enable row level security;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'comments'
      and policyname = 'comments_public_read'
  ) then
    create policy comments_public_read
      on public.comments
      for select
      using (true);
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'comments'
      and policyname = 'comments_authenticated_insert'
  ) then
    create policy comments_authenticated_insert
      on public.comments
      for insert
      to authenticated
      with check (user_id = auth.uid());
  end if;
end $$;

commit;
