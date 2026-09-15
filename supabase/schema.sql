-- ShareVault V0.1 Supabase/Postgres blueprint
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  role text not null default 'user' check (role in ('user','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.files (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  slug text not null unique,
  title text not null,
  description text,
  storage_path text not null,
  mime_type text,
  size_bytes bigint not null default 0,
  status text not null default 'active' check(status in ('active','blocked','deleted')),
  downloads bigint not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.traffic_events (
  id bigint generated always as identity primary key,
  file_id uuid not null references public.files(id) on delete cascade,
  occurred_at timestamptz not null default now(),
  event_type text not null check(event_type in ('view','download')),
  anonymous_session_hash text,
  referrer_host text,
  country_code text,
  device_type text,
  suspicious_score numeric(5,2) not null default 0,
  qualified boolean not null default false
);

create table if not exists public.wallet_ledger (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  amount numeric(14,6) not null,
  currency text not null default 'USD',
  kind text not null check(kind in ('estimated_earning','adjustment','payout')),
  status text not null default 'estimated' check(status in ('estimated','pending','available','paid','reversed')),
  reference text,
  created_at timestamptz not null default now()
);

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  file_id uuid references public.files(id) on delete set null,
  reporter_email text,
  reason text not null,
  details text,
  status text not null default 'open' check(status in ('open','reviewing','resolved','rejected')),
  created_at timestamptz not null default now()
);

create table if not exists public.withdrawal_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  amount numeric(14,2) not null check(amount>0),
  method text not null,
  status text not null default 'disabled' check(status in ('disabled','pending','approved','paid','rejected')),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.files enable row level security;
alter table public.traffic_events enable row level security;
alter table public.wallet_ledger enable row level security;
alter table public.reports enable row level security;
alter table public.withdrawal_requests enable row level security;

create policy "profile owner read" on public.profiles for select using(auth.uid()=id);
create policy "profile owner update" on public.profiles for update using(auth.uid()=id);
create policy "owner manages files" on public.files for all using(auth.uid()=owner_id) with check(auth.uid()=owner_id);
create policy "public active files readable" on public.files for select using(status='active');
create policy "owner reads traffic" on public.traffic_events for select using(exists(select 1 from public.files f where f.id=file_id and f.owner_id=auth.uid()));
create policy "owner reads ledger" on public.wallet_ledger for select using(auth.uid()=user_id);
create policy "anyone can report" on public.reports for insert with check(true);
create policy "owner reads withdrawals" on public.withdrawal_requests for select using(auth.uid()=user_id);

-- Important: traffic qualification and wallet credits must be performed server-side
-- with a service role / trusted function. Never let browser clients mark views qualified
-- or write monetary ledger entries.
