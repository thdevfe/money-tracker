# Money Tracker (UI prototype)

Personal income/expense tracker built with Flutter, iOS first. Its main
feature is a **monthly photo calendar**: each day shows small thumbnails of
that day's transaction photos and the day's spending total.

> **Status:** saves data to **Supabase** (sign-in, database, private photo
> storage) and is hosted as a web app on **Netlify**. Without Supabase
> settings it runs in **demo mode** with sample data in memory.

## Backend setup (once)

1. Create a free project at supabase.com (region: Southeast Asia).
2. In the dashboard, open **SQL Editor › New query**, paste
   `supabase/migrations/0001_init.sql` and click **Run**. This creates the
   tables, row-level security (each user sees only their own data), a default
   cash wallet for new users, and the private `transaction-photos` bucket.
3. Copy `config/supabase.example.json` to `config/supabase.json` and fill in
   the **Project URL** and the **publishable** key from
   *Project Settings › API Keys*. Never use the secret/service_role key in the
   app. `config/supabase.json` is git-ignored.
4. *Authentication › URL Configuration*: set **Site URL** to the Netlify URL so
   sign-up confirmation emails link back to the app.

## Run

```bash
flutter pub get
flutter run --dart-define-from-file=config/supabase.json   # with Supabase
flutter run                                                # demo mode
```

## Deploy the web app (Netlify)

Netlify builds from GitHub on every push (`netlify.toml` →
`scripts/netlify_build.sh`, which installs Flutter and runs
`flutter build web`).

1. Netlify › **Add new site › Import an existing project › GitHub**, pick
   this repo. Build settings come from `netlify.toml`.
2. **Site configuration › Environment variables**: add `SUPABASE_URL` and
   `SUPABASE_PUBLISHABLE_KEY`, then redeploy.
3. In Supabase, **Authentication › URL Configuration**: set **Site URL** to the
   Netlify URL and add it under **Redirect URLs**.

Users open the link in Safari and choose **Share › Add to Home Screen**.

## Test and analyze

```bash
dart format lib test
flutter analyze
flutter test
```

## What's in the prototype

The layout follows CapMoney's App Store screenshots (structure and interactions
only). The name, green accent, icons, wording and sample photos are this
project's own.

- **Shell**: floating icon-only pill nav bar (Home, Reports, Transactions,
  Accounts, Profile) and a floating + button on Home and Transactions. Dark
  theme by default.
- **Home**: time-of-day greeting with name and avatar, "Spent X today" pill,
  Day/Month toggle with counts, hide-amounts (eye) button, account filter chips,
  and a month bar (‹ month ⌄ ↺ ›) with a month picker.
  - **Month view**: seven-column calendar where each day shows up to two items
    as a tilted stack (photos first, then category tiles) with a "+N" badge and
    the day number underneath. Selected-day preview with "View all" below it.
  - **Day view**: three-column photo grid of the selected day with amounts on
    each tile.
- **Reports**: Month / Year / All time tabs, account chips, income and expense
  cards, balance and savings rate, and a spending-by-category list. Cluster and
  Map are placeholders.
- **Daily transactions**: totals, All/Expense/Income/Transfer filter, rows that
  open the edit form.
- **Add transaction (two steps)**:
  1. Capture: live camera preview (flash, flip, 1x/2x) with a shutter,
     "Choose from library", or "Skip photo". Falls back to a message where
     no camera is available (simulator, web).
  2. Entry: the photo (or the category on a tinted card) with the amount on a
     frosted panel, "Add details" for note and time, category and wallet
     chips, an expense/income/transfer switch, a date chip, and a calculator
     keypad (+ − × ÷, 000) with a Done key. The first category is
     preselected. Editing opens the entry screen directly.
- **Transactions**: grouped by day, type filters and text search.
- **Accounts**: read-only list with derived balances.
- **Profile**: name, theme and language (all in memory only).

## Architecture

```text
lib/
  app/            MaterialApp, bottom-nav shell, navigation helpers
  core/           theme tokens (ThemeData + AppColors extension), formatters,
                  shared widgets (EmptyStateView)
  l10n/           ARB files (en template, vi) + generated AppLocalizations
  features/
    transactions/ domain (models, pure ledger calculations), data (mock data),
                  providers (in-memory Riverpod state), presentation (screens
                  and widgets)
    accounts/ reports/ settings/
assets/mock_photos/  original sample images made for this project
```

- State: `flutter_riverpod` 2.x (`StateNotifier` / `StateProvider`), the same
  style the earlier version of this repo used.
- Money is stored as integer đồng (`amountMinor`); transfers never count as
  income or expense.
- Localization: `flutter_localizations` + `gen-l10n` (`l10n.yaml`). Vietnamese is
  the default, and its calendar weeks start on Monday.
- `clockProvider` can be overridden in tests so the mock data is deterministic.

## Known limitations

- Needs an internet connection (no offline mode yet).
- The transaction type can't be changed while editing.
- Accounts and categories can't be created or edited yet (new users get one
  cash wallet). Report clusters and map are placeholders.
- Theme and language choices are not saved between launches.
