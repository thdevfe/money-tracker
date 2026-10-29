-- Money Tracker: bank term deposits (Accounts page).
-- Run after 0002_custom_categories.sql (SQL Editor › New query › paste › Run).
-- Deposits are tracked on their own and do not change account balances.

create table public.term_deposits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  bank_name text not null check (char_length(trim(bank_name)) between 1 and 60),
  principal_minor bigint not null check (principal_minor > 0),
  -- Yearly rate in basis points: 550 = 5.5%.
  rate_bp integer not null check (rate_bp between 0 and 10000),
  start_date date not null,
  term_months integer not null check (term_months between 1 and 120),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index term_deposits_user_idx on public.term_deposits (user_id);

create trigger term_deposits_touch before update on public.term_deposits
  for each row execute function public.touch_updated_at();

alter table public.term_deposits enable row level security;

create policy "own term deposits" on public.term_deposits
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
