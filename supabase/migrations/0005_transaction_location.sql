-- Money Tracker: where a transaction was added (Reports › Map).
-- Run after 0004_budgets.sql (SQL Editor › New query › paste › Run).
-- Only filled when the user turns on location saving in the app.

alter table public.transactions
  add column latitude double precision
    check (latitude between -90 and 90),
  add column longitude double precision
    check (longitude between -180 and 180),
  add constraint transaction_location_pair
    check ((latitude is null) = (longitude is null));
