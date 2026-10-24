# Money Tracker (UI prototype)

Personal income/expense tracker built with Flutter, iOS first. Its main
feature is a **monthly photo calendar**: each day shows small thumbnails of
that day's transaction photos and the day's spending total.

> **Status: UI prototype milestone.** All data is deterministic mock data held
> in memory and resets on restart. There is no database, backend, sign-in or
> sync yet. See `APP_PLAN.md` / `UI_MOCKUP_SPEC.md` for the full plan.

## Run

```bash
flutter pub get
flutter run            # pick an iOS simulator
flutter run -d chrome  # quick web preview (camera/library picking differs)
```

iOS builds need the Xcode license accepted once: `sudo xcodebuild -license`.

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
- **Add/Edit transaction**: Expense / Income / Transfer, grouped amount input,
  category chips, account picker(s), date/time, optional note and optional photo.
  Validation, delete confirmation and an unsaved-changes prompt.
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

## Known limitations (prototype)

- No persistence. Picked photos point to the picker's temp file and are not copied
  into app storage.
- No overdraft or balance checks, and the transaction type can't be changed while editing.
- Accounts and categories can't be created or edited, and Reports is a placeholder.
- Theme and language choices are not saved between launches.
