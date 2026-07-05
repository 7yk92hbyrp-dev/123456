-- Workout app cloud backup — run this once in Supabase (SQL Editor → Run).
-- One table: one row per account, holding that account's whole workout data.

create table public.backups (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  data       jsonb not null,
  updated_at timestamptz not null default now()
);

-- Row-level security: without a policy that matches, a request sees NOTHING.
alter table public.backups enable row level security;

-- The only policy: you can read/write a row only if it is YOUR row.
-- auth.uid() is the signed-in user's id, taken from their login token —
-- it cannot be faked from the app side.
create policy "Own row only"
  on public.backups
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
