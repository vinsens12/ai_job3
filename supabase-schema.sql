-- WorkMatch AI Job Finder: Supabase schema
-- Run this script once in Supabase SQL Editor. Review existing tables before running.

create extension if not exists pgcrypto;

create table if not exists public.jobs (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  company_name text not null,
  province text,
  description text,
  requirements text,
  keywords text[] not null default '{}',
  salary_min integer,
  salary_max integer,
  job_type text check (job_type in ('Full-Time','Part-Time','Freelance','Internship','Contract')),
  experience_level text,
  min_age integer,
  source_url text,
  apply_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.saved_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  job_id uuid not null references public.jobs(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(user_id, job_id)
);

create table if not exists public.applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  job_id uuid references public.jobs(id) on delete set null,
  job_title text not null,
  company_name text,
  apply_url text,
  status text not null default 'สนใจ'
    check (status in ('สนใจ','สมัครแล้ว','รอติดต่อ','สัมภาษณ์','ได้รับข้อเสนอ','ไม่ผ่าน')),
  notes text,
  applied_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists jobs_active_province_idx on public.jobs(is_active, province);
create index if not exists jobs_type_idx on public.jobs(job_type);
create index if not exists saved_jobs_user_idx on public.saved_jobs(user_id);
create index if not exists applications_user_idx on public.applications(user_id);

alter table public.jobs enable row level security;
alter table public.saved_jobs enable row level security;
alter table public.applications enable row level security;

-- Public can read active job listings. Only trusted admins/service role should insert/update jobs.
drop policy if exists "Anyone can view active jobs" on public.jobs;
create policy "Anyone can view active jobs" on public.jobs
  for select using (is_active = true);

drop policy if exists "Users can view own saved jobs" on public.saved_jobs;
create policy "Users can view own saved jobs" on public.saved_jobs
  for select to authenticated using (auth.uid() = user_id);
drop policy if exists "Users can save own jobs" on public.saved_jobs;
create policy "Users can save own jobs" on public.saved_jobs
  for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "Users can unsave own jobs" on public.saved_jobs;
create policy "Users can unsave own jobs" on public.saved_jobs
  for delete to authenticated using (auth.uid() = user_id);

drop policy if exists "Users can view own applications" on public.applications;
create policy "Users can view own applications" on public.applications
  for select to authenticated using (auth.uid() = user_id);
drop policy if exists "Users can insert own applications" on public.applications;
create policy "Users can insert own applications" on public.applications
  for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "Users can update own applications" on public.applications;
create policy "Users can update own applications" on public.applications
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "Users can delete own applications" on public.applications;
create policy "Users can delete own applications" on public.applications
  for delete to authenticated using (auth.uid() = user_id);

-- Optional: add a profile table if you want server-side profile storage.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  age integer check (age is null or age between 15 and 100),
  skills text[] not null default '{}',
  province text,
  updated_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
drop policy if exists "Users manage own profile" on public.profiles;
create policy "Users manage own profile" on public.profiles
  for all to authenticated using (auth.uid() = id) with check (auth.uid() = id);

-- Do not create an INSERT policy for jobs for anonymous/authenticated users.
-- Import verified job listings from a trusted admin process.
