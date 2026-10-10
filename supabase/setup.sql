-- 屁屁×屁眼 港澳之旅：Supabase 資料庫設定
-- 用法：Supabase 專案 → SQL Editor → New query → 貼上整份 → 把最下面兩個 Email 換成你們的 → Run

-- 1. 允許登入的名單
create table if not exists public.members (email text primary key);
alter table public.members enable row level security;  -- 名單本身不開放讀取

create or replace function public.is_member() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.members where lower(email) = lower(auth.jwt() ->> 'email'));
$$;
grant execute on function public.is_member() to authenticated;

-- 2. 資料表
create table if not exists public.expenses (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  amount numeric not null check (amount > 0),
  currency text not null check (currency in ('TWD','HKD','MOP')),
  payer text not null check (payer in ('pp','py','half')),
  split text not null check (split in ('both','pp','py')),
  category text,
  day text,
  created_at timestamptz not null default now()
);
create table if not exists public.photos (
  id uuid primary key default gen_random_uuid(),
  path text not null,
  day text,
  created_at timestamptz not null default now()
);
create table if not exists public.todos (id text primary key, done boolean not null default false);
create table if not exists public.kv (key text primary key, value jsonb);

-- 3. 只有名單內的人能讀寫
do $$ declare t text; begin
  foreach t in array array['expenses','photos','todos','kv'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists "members only" on public.%I', t);
    execute format('create policy "members only" on public.%I for all to authenticated using (public.is_member()) with check (public.is_member())', t);
  end loop;
end $$;

-- 4. 照片儲存空間（私人）
insert into storage.buckets (id, name, public) values ('photos', 'photos', false) on conflict (id) do nothing;
drop policy if exists "members read photos" on storage.objects;
drop policy if exists "members add photos" on storage.objects;
drop policy if exists "members remove photos" on storage.objects;
create policy "members read photos" on storage.objects for select to authenticated using (bucket_id = 'photos' and public.is_member());
create policy "members add photos" on storage.objects for insert to authenticated with check (bucket_id = 'photos' and public.is_member());
create policy "members remove photos" on storage.objects for delete to authenticated using (bucket_id = 'photos' and public.is_member());

-- 5. 即時同步
alter publication supabase_realtime add table public.expenses, public.photos, public.todos;

-- 7. 允許登入的 Email（換成你們的）
insert into public.members (email) values
  ('第一個 Email'),
  ('第二個 Email')
on conflict do nothing;
