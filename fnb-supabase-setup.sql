-- F&B Standards · Supabase multi-user setup
-- Run this whole file in Supabase SQL Editor for project: gufnisizabudxeqqviet
-- This uses Supabase Auth anonymous sign-in so many browsers can share one database.
-- The frontend uses ONLY the publishable/anon key, never a service-role key.

create extension if not exists pgcrypto;

create table if not exists public.fnb_cloud (
  bucket text not null,
  item_id text not null,
  payload jsonb not null,
  updated_at timestamptz not null default now(),
  updated_by uuid null default auth.uid(),
  primary key (bucket, item_id)
);

alter table public.fnb_cloud enable row level security;

grant select, insert, update, delete on public.fnb_cloud to authenticated;

 drop policy if exists "fnb_cloud_select_authenticated" on public.fnb_cloud;
 drop policy if exists "fnb_cloud_insert_authenticated" on public.fnb_cloud;
 drop policy if exists "fnb_cloud_update_authenticated" on public.fnb_cloud;
 drop policy if exists "fnb_cloud_delete_authenticated" on public.fnb_cloud;

create policy "fnb_cloud_select_authenticated"
on public.fnb_cloud for select to authenticated using (true);

create policy "fnb_cloud_insert_authenticated"
on public.fnb_cloud for insert to authenticated with check (true);

create policy "fnb_cloud_update_authenticated"
on public.fnb_cloud for update to authenticated using (true) with check (true);

create policy "fnb_cloud_delete_authenticated"
on public.fnb_cloud for delete to authenticated using (true);

-- Realtime: add the shared table to the publication.
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'fnb_cloud'
  ) then
    execute 'alter publication supabase_realtime add table public.fnb_cloud';
  end if;
end $$;

-- Storage bucket for inspection evidence photos.
insert into storage.buckets (id, name, public)
values ('fnb-photos', 'fnb-photos', true)
on conflict (id) do update set public = true;

drop policy if exists "fnb_photos_insert_authenticated" on storage.objects;
drop policy if exists "fnb_photos_update_authenticated" on storage.objects;
drop policy if exists "fnb_photos_delete_authenticated" on storage.objects;

create policy "fnb_photos_insert_authenticated"
on storage.objects for insert to authenticated
with check (bucket_id = 'fnb-photos');

create policy "fnb_photos_update_authenticated"
on storage.objects for update to authenticated
using (bucket_id = 'fnb-photos')
with check (bucket_id = 'fnb-photos');

create policy "fnb_photos_delete_authenticated"
on storage.objects for delete to authenticated
using (bucket_id = 'fnb-photos');

-- IMPORTANT: in Supabase Dashboard, enable:
-- Authentication → Sign In / Providers → Anonymous Sign-Ins
-- The frontend calls signInAnonymously() and then uses the authenticated Postgres role.
