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

- **Home**: month navigation (arrows or horizontal swipe), compact summary
  (total tracked balance, month income, month expenses), seven-column photo
  calendar (up to 3 thumbnails + `+N` overflow, daily expense total, income-only
  days marked `+`), and a selected-day preview with "View all".
- **Daily transactions**: totals, All/Expense/Income/Transfer filter, rows that
  open the edit form, and an empty state with an Add action.
- **Add/Edit transaction**: Expense / Income / Transfer, amount with live digit
  grouping and a numeric keyboard, category chips, account picker(s), date/time,
  optional note, and an optional photo (camera/library, preview, replace, remove).
  Validation covers the amount (> 0), the category, and transfers between two
  different accounts. Delete needs confirmation, and leaving with unsaved changes asks first.
- **Transactions**: grouped by day, newest first, type filters and text search.
- **Reports**: placeholder. **Accounts**: read-only list with derived balances.
- **Settings** (gear on Home): Light/Dark/System theme and Vietnamese/English/System
  language, both in memory only.

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
