-- Money Tracker: custom categories (Phase 2).
-- Run after 0001_init.sql (SQL Editor › New query › paste › Run).
-- Built-in categories stay as codes in the app (transactions.category_code);
-- user-created ones live here and are referenced by custom_category_id.

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  type text not null check (type in ('expense', 'income')),
  name text not null check (char_length(trim(name)) between 1 and 40),
  icon_key text not null,
  color_key text not null,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- One name per type per user, ignoring case and surrounding spaces.
create unique index categories_unique_name
  on public.categories (user_id, type, lower(trim(name)));

create trigger categories_touch before update on public.categories
  for each row execute function public.touch_updated_at();

alter table public.categories enable row level security;

create policy "own categories" on public.categories
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Transactions can point at a custom category instead of a built-in code.
-- "restrict" blocks deleting a category that transactions still use; the app
-- offers archiving instead.
alter table public.transactions
  add column custom_category_id uuid
    references public.categories (id) on delete restrict;

create index transactions_custom_category_idx
  on public.transactions (custom_category_id);

alter table public.transactions drop constraint transaction_shape;
alter table public.transactions add constraint transaction_shape check (
  (type in ('expense', 'income')
    and account_id is not null
    -- Exactly one of: built-in code, custom category.
    and ((category_code is not null) <> (custom_category_id is not null))
    and source_account_id is null and destination_account_id is null)
  or
  (type = 'transfer'
    and account_id is null
    and category_code is null and custom_category_id is null
    and source_account_id is not null and destination_account_id is not null
    and source_account_id <> destination_account_id
    and photo_path is null)
);

-- A custom category must belong to the user and match the transaction type.
drop policy "own transactions" on public.transactions;
create policy "own transactions" on public.transactions
  for all to authenticated
  using (user_id = auth.uid())
  with check (
    user_id = auth.uid()
    and (account_id is null or exists (
      select 1 from public.accounts a
      where a.id = account_id and a.user_id = auth.uid()))
    and (source_account_id is null or exists (
      select 1 from public.accounts a
      where a.id = source_account_id and a.user_id = auth.uid()))
    and (destination_account_id is null or exists (
      select 1 from public.accounts a
      where a.id = destination_account_id and a.user_id = auth.uid()))
    and (custom_category_id is null or exists (
      select 1 from public.categories c
      where c.id = custom_category_id
        and c.user_id = auth.uid()
        and c.type = transactions.type))
  );
