-- Money Tracker: monthly budgets.
-- Run after 0003_term_deposits.sql (SQL Editor › New query › paste › Run).
-- category_ids holds the app's category ids (built-in codes such as 'food'
-- or custom category uuids); empty means all spending.

create table public.budgets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  name text not null check (char_length(trim(name)) between 1 and 40),
  limit_minor bigint not null check (limit_minor > 0),
  category_ids text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index budgets_user_idx on public.budgets (user_id);

create trigger budgets_touch before update on public.budgets
  for each row execute function public.touch_updated_at();

alter table public.budgets enable row level security;

create policy "own budgets" on public.budgets
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
