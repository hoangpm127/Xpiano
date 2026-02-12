-- Prepare social feed + storage for real MP4 upload flow.
-- Safe to run multiple times.

begin;

alter table if exists public.social_feed
  add column if not exists media_type text not null default 'image';

do $$
begin
  alter table public.social_feed
    add constraint social_feed_media_type_check
    check (media_type in ('image', 'video'));
exception
  when duplicate_object then
    null;
end $$;

update public.social_feed
set media_type = 'video'
where media_type = 'image'
  and (
    lower(coalesce(media_url, '')) like '%.mp4'
    or lower(coalesce(media_url, '')) like '%.mp4?%'
    or lower(coalesce(media_url, '')) like '%/mp4%'
  );

create index if not exists idx_social_feed_created_at_id_desc
  on public.social_feed (created_at desc, id desc);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'videos-feed',
  'videos-feed',
  true,
  104857600,
  array['video/mp4']
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'videos_feed_public_read'
  ) then
    create policy videos_feed_public_read
      on storage.objects
      for select
      using (bucket_id = 'videos-feed');
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'videos_feed_authenticated_insert'
  ) then
    create policy videos_feed_authenticated_insert
      on storage.objects
      for insert
      to authenticated
      with check (bucket_id = 'videos-feed');
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'videos_feed_owner_update'
  ) then
    create policy videos_feed_owner_update
      on storage.objects
      for update
      to authenticated
      using (bucket_id = 'videos-feed' and owner = auth.uid())
      with check (bucket_id = 'videos-feed' and owner = auth.uid());
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'videos_feed_owner_delete'
  ) then
    create policy videos_feed_owner_delete
      on storage.objects
      for delete
      to authenticated
      using (bucket_id = 'videos-feed' and owner = auth.uid());
  end if;
end $$;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'social_feed'
      and policyname = 'social_feed_public_read'
  ) then
    create policy social_feed_public_read
      on public.social_feed
      for select
      using (true);
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'social_feed'
      and policyname = 'social_feed_authenticated_insert'
  ) then
    create policy social_feed_authenticated_insert
      on public.social_feed
      for insert
      to authenticated
      with check (auth.uid() is not null);
  end if;
end $$;

commit;
