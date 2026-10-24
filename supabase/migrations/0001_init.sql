-- Money Tracker: initial schema.
-- Run once in the Supabase dashboard (SQL Editor › New query › paste › Run).
-- Every row belongs to one signed-in user; row-level security keeps users'
-- data private from each other. Amounts are integer minor units (đồng).

-- Accounts (wallets) -------------------------------------------------------

create table public.accounts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  name text not null check (char_length(trim(name)) between 1 and 50),
  type text not null check (type in ('cash', 'bank')),
  opening_balance_minor bigint not null default 0
    check (opening_balance_minor >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index accounts_user_idx on public.accounts (user_id);

-- Transactions ---------------------------------------------------------------

create table public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  type text not null check (type in ('expense', 'income', 'transfer')),
  amount_minor bigint not null check (amount_minor > 0),
  occurred_at timestamptz not null,
  -- Income/expense only.
  account_id uuid references public.accounts (id) on delete restrict,
  category_code text,
  -- Transfer only.
  source_account_id uuid references public.accounts (id) on delete restrict,
  destination_account_id uuid references public.accounts (id) on delete restrict,
  note text check (note is null or char_length(note) <= 300),
  -- Path inside the transaction-photos bucket: "<user_id>/<file>".
  photo_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint transaction_shape check (
    (type in ('expense', 'income')
      and account_id is not null and category_code is not null
      and source_account_id is null and destination_account_id is null)
    or
    (type = 'transfer'
      and account_id is null and category_code is null
      and source_account_id is not null and destination_account_id is not null
      and source_account_id <> destination_account_id
      and photo_path is null)
  )
);

create index transactions_user_time_idx
  on public.transactions (user_id, occurred_at desc);
create index transactions_account_idx on public.transactions (account_id);
create index transactions_source_idx on public.transactions (source_account_id);
create index transactions_destination_idx
  on public.transactions (destination_account_id);

-- updated_at --------------------------------------------------------------------

create function public.touch_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger accounts_touch before update on public.accounts
  for each row execute function public.touch_updated_at();
create trigger transactions_touch before update on public.transactions
  for each row execute function public.touch_updated_at();

-- Row-level security: each user sees and changes only their own rows ---------

alter table public.accounts enable row level security;
alter table public.transactions enable row level security;

create policy "own accounts" on public.accounts
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "own transactions" on public.transactions
  for all to authenticated
  using (user_id = auth.uid())
  with check (
    user_id = auth.uid()
    -- Referenced accounts must also be the user's own.
    and (account_id is null or exists (
      select 1 from public.accounts a
      where a.id = account_id and a.user_id = auth.uid()))
    and (source_account_id is null or exists (
      select 1 from public.accounts a
      where a.id = source_account_id and a.user_id = auth.uid()))
    and (destination_account_id is null or exists (
      select 1 from public.accounts a
      where a.id = destination_account_id and a.user_id = auth.uid()))
  );

-- New users start with one cash wallet ---------------------------------------

create function public.create_default_account() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.accounts (user_id, name, type)
  values (new.id, 'Tiền mặt', 'cash');
  return new;
end;
$$;

create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.create_default_account();

-- Private photo storage: files live under "<user_id>/" ------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'transaction-photos',
  'transaction-photos',
  false,
  5242880, -- 5 MB
  array['image/jpeg', 'image/png', 'image/heic', 'image/webp']
);

create policy "own photos: read" on storage.objects
  for select to authenticated
  using (bucket_id = 'transaction-photos'
    and (storage.foldername(name))[1] = auth.uid()::text);

create policy "own photos: upload" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'transaction-photos'
    and (storage.foldername(name))[1] = auth.uid()::text);

create policy "own photos: delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'transaction-photos'
    and (storage.foldername(name))[1] = auth.uid()::text);
