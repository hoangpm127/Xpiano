-- Atomic like increment for social_feed.
-- Run this once in Supabase SQL Editor.

create or replace function public.increment_social_feed_likes(p_feed_id integer)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.social_feed
  set likes_count = coalesce(likes_count, 0) + 1
  where id = p_feed_id;
end;
$$;

grant execute on function public.increment_social_feed_likes(integer)
to anon, authenticated;
