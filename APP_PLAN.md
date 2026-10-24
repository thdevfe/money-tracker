# APP_PLAN.md — Personal Finance Tracker (MVP)

> **Purpose:** Implementation-ready product and engineering specification for an AI coding agent.
>
> **Product:** A modern, minimal, visual-first personal finance app for tracking income and expenses with optional transaction photos, cash wallets and bank accounts, and simple category-based reports.
>
> **Status:** MVP specification. Treat explicit requirements as authoritative. Where this document marks a decision as an assumption, keep the implementation simple and document the assumption rather than inventing extra product scope.

---

## Revisions — 2026-10-25 (supersede the original text where they conflict)

The owner changed these decisions after reviewing the UI prototype. Sections below are marked **Revised** where they changed.

| # | Original | Revised decision |
|---|---|---|
| R1 | Local-only data, no sign-in, no backend (§1.5, §2.1, §2.2, §2.14, §2.15, §10) | Data is stored in **Supabase** (Postgres + Auth + Storage). Users sign in with email + password. Row-level security keeps each user's rows and photos private. The app needs an internet connection; offline support is post-MVP. |
| R2 | Mobile app only; no web client (§1.3) | Primary distribution is a **web app (PWA) on Netlify** for the owner and friends, added to the iPhone home screen. iOS builds still work for personal installs. No App Store release planned for now. |
| R3 | Local SQLite/Drift database with migrations (§6.7, §7.1, §11.2) | Postgres schema in `supabase/migrations/`, applied in the Supabase dashboard. A `LedgerRepository` interface hides the backend; an in-memory implementation powers demo mode (no backend configured) and tests. |
| R4 | Photos copied into app-private storage (FR-005A) | Photos upload to the private `transaction-photos` bucket under `<user_id>/`, shown via signed URLs. Old files are removed only after the row update succeeds. |
| R5 | Four tabs + floating add; original layout (§4, §4.1) | Layout follows CapMoney's **structure** (not its branding): five icon-only tabs (Home, Reports, Transactions, Accounts, Profile) in a floating pill with the + button beside it; Home greeting, Day/Month toggle, hide-amounts toggle, account chips and a stacked-photo calendar. Settings live in the Profile tab. See `UI_MOCKUP_SPEC.md`. |
| R6 | Single-form Add/Edit (§4 Screen C) | Two-step add: **capture** (live camera, library, or skip) then **entry** (photo/category hero, frosted amount, category/wallet chips, type switch, date chip, calculator keypad). Editing opens the entry step. |
| R7 | Dark/light follow system | Dark theme by default; Light/Dark/System in Profile. |

Copycat note: if the app is ever submitted to an app store, review the CapMoney-derived layout against App Store guideline 4.1 first.

---

## Reference Product and Design Direction

**Product inspiration:** [CapMoney: Money Tracker on the App Store](https://apps.apple.com/vn/app/capmoney-money-tracker/id6757230737?l=vi) and its public guide at https://capmoney.app/en/guide/.

Use this reference for high-level product principles only:
- Fast, low-friction daily money entry.
- Visual transaction records using optional photos or category icons.
- A clear, scannable chronological history.
- Simple monthly summaries and category reports.
- A lightweight, personal, offline-friendly experience.

Do **not** copy CapMoney's name, logo, exact screen layouts, illustrations, icons, proprietary assets, wording, or distinctive branding. Create an original visual identity and layout guided by the same general problem and interaction principles.

For this MVP, optional local photo attachments are included, but OCR/photo recognition is not. Users manually enter and verify transaction details. OCR, automatic image recognition, widgets, budgets, trip tracking, sharing, and cloud sync are deferred.

## 0. Instructions for the AI Coding Agent

Build the application described in this document in small, verifiable phases.

### Required working rules

1. Inspect the repository before making changes. If it is empty, initialize the Flutter project using the project name `money_tracker` (or use an existing project name if already configured).
2. Follow the existing project conventions when they do not conflict with this document.
3. Use stable Flutter/Dart APIs and compatible package versions. Do not guess package APIs; check the package version actually installed.
4. Implement only the MVP scope in this document. Do not add ads, social features, bank integrations, AI financial advice, subscriptions, receipt OCR, or other unrequested features.
5. Keep business logic out of widgets. Use repositories and domain/application services so the app can later add cloud synchronization without rewriting screens.
6. Use typed models and explicit enums. Avoid `dynamic` except at serialization boundaries where unavoidable.
7. Store money as integer minor units (for VND, integer đồng; for currencies with fractional units, minor units) rather than `double`. Never use floating-point arithmetic for balances.
8. Store timestamps consistently in UTC; display dates/times in the device’s local timezone.
9. Persist data before showing a transaction as successfully saved. Handle persistence failures visibly and do not silently discard input.
10. Use database transactions for operations that update multiple records or affect balances.
11. Support Vietnamese and English using Flutter localization, with English and Vietnamese locale resources. Do not hardcode user-facing strings in widgets.
12. Add automated tests for calculations, validation, repository behavior, and critical user flows.
13. Do not claim a task is complete unless the code is implemented and relevant tests/analyzers have been run. Report any commands that could not be run.
14. Keep `README.md` updated with setup, run, test, and architecture instructions.
15. Before adding a dependency, confirm that it is needed, maintained enough for the MVP, and compatible with the current Flutter SDK. Avoid unnecessary dependencies.

### Definition of done for each phase

- Code compiles.
- `dart format` has been run on changed Dart files.
- `flutter analyze` reports no new errors; resolve warnings introduced by the implementation where practical.
- Relevant automated tests pass.
- No user-facing strings are left unlocalized.
- Loading, empty, validation-error, and persistence-error states are handled where applicable.
- The phase summary lists files changed, commands run, test results, and remaining issues.

---

## 1. Product Overview

### 1.1 Problem

People need a quick, understandable way to record money coming in and going out across different places where they keep money, such as cash and bank accounts, and to understand where their money goes.

### 1.2 Product goal

Provide a lightweight, visual-first personal finance tracker that lets a user:

- Create and manage cash wallets and bank accounts.
- Record income, expenses, and transfers in a few steps.
- Optionally attach a photo from the camera or photo library to an income/expense entry.
- Scan the transaction history visually using a photo thumbnail or category icon.
- Browse and filter transaction history.
- View tracked-account balances and simple income/expense summaries.
- Understand expenses by category and time period.
- Use the app in Vietnamese or English.
- Use core features offline, with financial data and photos stored locally.

### 1.3 Target platform

- Flutter mobile app.
- Android and iOS are the intended platforms.
- The initial implementation should prioritize a working, testable MVP on the platform available in the development environment, while keeping code platform-neutral.
- Do not implement a web or desktop client as part of this MVP.

### 1.4 Product principles

- Fast transaction entry with as few required fields as practical.
- Visual transaction records: use a photo when attached, otherwise show a category icon/sticker-style placeholder.
- Clear balances and trustworthy calculations.
- Simple navigation and low visual clutter.
- Offline-first operation; photos remain on-device.
- No mandatory account registration for the MVP.
- Architecture that can later support remote synchronization.

### 1.5 Explicit non-goals

Do **not** implement the following in the MVP:

- Connecting to real bank accounts or importing bank statements.
- Cloud synchronization, user accounts, authentication, or a backend.
- Shared wallets or multi-user collaboration.
- Investment, portfolio, debt, loan, or net-worth management beyond balances in tracked accounts.
- AI-generated advice or chat.
- Recurring transactions or scheduled payments.
- Budget limits, budget alerts, or notifications.
- Automatic receipt OCR, image recognition, and automatic transaction extraction. Photo attachment itself is in MVP; recognition is deferred.
- Cloud photo storage or remote file uploads.
- Currency conversion or foreign-exchange rates.
- Multi-currency totals or automatic exchange-rate conversion.
- CSV/Excel export or import.
- Widgets, wearable apps, or web app.
- Ads, subscriptions, or payment processing.
- Biometric app lock, PIN lock, or encrypted cloud backup.
- Complex accounting features such as split transactions, reconciliation, or double-entry ledgers.

These can be considered after the MVP is validated. OCR/recognition, monthly budgets, widgets, travel/trip grouping, and cloud sync are explicitly deferred roadmap candidates.

---

## 2. Assumptions and Product Decisions

The following are intentional MVP decisions, not open implementation choices:

1. **Revised (R1):** ~~Single local user profile, no sign-in.~~ Each user signs in (email + password) and sees only their own data.
2. **Revised (R1):** ~~Local-first.~~ Data lives in Supabase; the app needs internet. Offline support is post-MVP.
3. **One reporting currency per installation:** default to VND for a Vietnamese device/locale; otherwise default to the device locale’s common currency only if it can be determined reliably. If not reliable, default to VND and allow the user to change the currency in Settings. No currency conversion.
4. **Currency configuration:** store the selected currency code at the app/settings level. Existing transactions use the installation’s configured currency. Changing the currency does not convert historical amounts; show a confirmation warning before changing it. If this behavior adds too much complexity, disable currency changing in MVP and use VND as the only supported currency. Do not mix currencies in a total.
5. **Account types:** Cash and Bank Account. “Wallet” is the user-facing general term for an account that stores money.
6. **Opening balance:** users may enter an opening balance when creating an account. It is the initial balance, not income, and is excluded from income/expense reports.
7. **No negative balances by default:** an expense or transfer-out cannot exceed the available balance. Prevent saving and explain the reason. Do not allow overdrafts in the MVP.
8. **Transfer semantics:** a transfer has one source account, one destination account, and one amount. It decreases the source balance and increases the destination balance by the same amount. It is excluded from income and expense analytics.
9. **Deleted records:** transactions are hard-deleted in the MVP after a confirmation prompt. Account deletion is allowed only when the account has no transactions; otherwise instruct the user to remove or reassign transactions first. Never silently cascade-delete transaction history.
10. **Date range:** default dashboard/reporting period is the current calendar month in the device’s local timezone.
11. **Time:** store transaction timestamps as UTC and display in local time. A date-only filter uses local calendar-day boundaries.
12. **Categories:** ship with a small set of default income and expense categories. Users can create, edit, and delete their own categories, subject to constraints below.
13. **No multi-currency:** all accounts and transactions use the same configured currency.
14. **Privacy (revised, R1):** financial data and photos are sent only to the project's own Supabase backend, protected per user by row-level security. Do not add analytics or crash-reporting SDKs that transmit user data without explicit product approval.
15. **Backend (revised, R1/R3):** Supabase is the backend. Keep stable IDs and the repository boundary so the backend can change without UI rewrites. No multi-device conflict resolution beyond last write wins.

If a repository constraint makes one of these decisions impossible, explain the constraint and propose the smallest change instead of silently changing behavior.

---

## 3. MVP Functional Requirements

### P0 — Must have for first release

#### FR-001: First launch and empty state

- App opens directly to the main app; no sign-up is required.
- If no accounts exist, show a friendly empty state and a primary action to create the first account.
- If accounts exist but there are no transactions, show zero income/expense for the selected period and guide the user to add a transaction.
- The app must remain usable offline.

#### FR-002: Account management

Users can create, view, edit, and delete accounts.

Account fields:

- `id`: stable unique ID.
- `name`: required, trimmed, 1–50 characters.
- `type`: `cash` or `bank`.
- `openingBalanceMinor`: integer, defaults to 0, must be non-negative.
- `createdAtUtc`.
- `updatedAtUtc`.
- `isArchived`: boolean, default false; optional implementation detail if archive is used instead of deletion.

Behavior:

- List accounts with name, type, and current balance.
- Create account with name, type, and opening balance.
- Edit name and type. Changing type must not alter the balance.
- Do not allow editing the opening balance after the account has transactions unless the implementation introduces a clearly modeled balance adjustment. For MVP, make the opening balance read-only after the first transaction.
- Delete only an account with no transactions. Confirm before deletion.
- If an account has transactions, prevent deletion and explain why.
- Archived accounts, if implemented, cannot be selected for new transactions but remain visible in historical transactions and balances. If archive behavior is not implemented, omit `isArchived` rather than adding a partial feature.

#### FR-003: Transaction types

Support exactly these transaction types:

- `income`
- `expense`
- `transfer`

Each transaction has a stable ID and timestamps. Use a transaction model that can represent all three types without ambiguous fields.

Common fields:

- `id`
- `type`
- `amountMinor` — positive integer greater than zero.
- `transactionAtUtc`
- `note` — optional, trimmed, maximum 300 characters.
- `attachmentPath` — optional relative path to an app-managed local image; null when no photo is attached.
- `createdAtUtc`
- `updatedAtUtc`
- `accountId` — for income and expense.
- `categoryId` — required for income and expense; not used for transfer.
- `destinationAccountId` — required for transfer.
- `sourceAccountId` — required for transfer.

Validation:
- Amount must be greater than zero.
- Income/expense account must exist and be selectable.
- Income/expense category must exist, be active, and match the transaction type.
- Transfer source and destination must both exist, must be different accounts, and must be selectable.
- Transfer amount must not exceed the source account’s available balance.
- Expense amount must not exceed the account’s available balance.
- A note is optional.
- Date/time defaults to now, but the user can change it.
- All invalid input must show a localized field-level or form-level message.

#### FR-004: Add transaction

Provide a fast, focused form for recording a transaction.

Form behavior:
- User chooses Income, Expense, or Transfer.
- For Income: amount, account, category, date/time, note.
- For Expense: amount, account, category, date/time, note.
- For Transfer: amount, source account, destination account, date/time, note.
- Optional for income/expense: attach one photo from the camera or photo library. Do not require an image to save a transaction.
- Use a numeric keypad for amount entry.
- Format the displayed amount using the configured currency and locale; do not use formatted text as the stored value.
- The Save button is disabled while required fields are invalid or a save is in progress.
- Prevent duplicate taps while saving.
- After successful save, persist the record and show a success response; return to the previous screen or clear the form according to the existing navigation pattern.
- On failure, preserve the entered values and show an error.
- Newest transactions should appear first in history.

#### FR-005: Edit and delete transaction

- User can open a transaction detail/edit screen from history.
- User can edit amount, account(s), category, date/time, and note, subject to validation.
- Recalculate account balances and reports from persisted transaction data after an edit.
- Editing a transaction must be atomic: if validation or persistence fails, the previous valid state remains unchanged.
- User can delete a transaction after confirmation.
- Deleting a transaction reverses its balance effect.
- Deleting a transfer reverses both sides.
- After edit/delete, refresh affected account balances, dashboard summaries, and reports.
- Do not allow changing transaction type during edit in the MVP. If the user needs a different type, delete and recreate it.

#### FR-005A: Local transaction photo attachment

- Users can optionally take a photo or choose an existing image when creating or editing an income/expense transaction.
- Show a preview before saving, with clear replace and remove actions.
- Copy the selected image to persistent app-managed storage. Do not rely on a temporary picker/cache path.
- Store a relative file path in the database; do not store raw image bytes in the transaction table.
- Keep images on the device. Do not upload photos or transaction data.
- If camera/photo permission is denied, explain that the user can continue without a photo or choose an available alternative.
- If an image is missing or unreadable, show a neutral placeholder and allow the transaction to load and be edited.
- On transaction deletion, remove the associated app-managed image only if it is no longer referenced by another record.
- When replacing/removing a photo, clean up the old file only after the database update succeeds.
- Resize/compress images to a documented mobile-friendly limit while retaining enough detail for receipts.
- OCR, automatic amount/category extraction, background recognition, and remote image processing are explicitly out of scope.

#### FR-006: Balance calculation

Account current balance must be derived from the opening balance and persisted transactions:

`balance = openingBalance + income - expense + transferIn - transferOut`

Where:
- Income increases the selected account.
- Expense decreases the selected account.
- Transfer-in increases the destination account.
- Transfer-out decreases the source account.
- Opening balance is not counted as income.

Important:
- Use integer minor units for every operation.
- A transfer must never appear in income or expense totals.
- Avoid storing a separately editable balance that can drift from transaction history.
- If performance later requires cached balances, treat them as derived cache values and test them against the authoritative calculation. For the MVP, calculate via repository queries or a tested aggregation method.

#### FR-007: Transaction history

- Display a chronological list, newest first.
- Each row displays type, amount, account or transfer route, category when applicable, date, and note preview when present.
- Income and transfer-in amounts are visually distinct from expenses, but meaning must not rely on color alone.
- Support filters:
  - Date period: current month, previous month, and custom date range.
  - Type: all, income, expense, transfer.
  - Account: all or one account.
  - Category: all or one applicable category.
- Filters can be combined.
- Provide a clear/reset filters action.
- Provide empty states for no transactions and no filter matches.
- Pagination is not required for the MVP, but avoid loading all records into the UI if the database/repository can efficiently query by date range.

#### FR-008: Dashboard

Dashboard displays:

- Total current balance across all non-archived accounts.
- Income total for the selected reporting period.
- Expense total for the selected reporting period.
- Net cash flow for the period: `income - expense`.
- Recent transactions (up to 5).
- Breakdown of expenses by category for the selected period.
- A month selector or previous/next month navigation.
- A clear state if no transactions exist.

Definitions:
- Current total balance is the sum of current balances across tracked accounts, not the sum of income minus expense in the selected month.
- Period income includes only income transactions in the selected period.
- Period expense includes only expense transactions in the selected period.
- Net cash flow excludes transfers and opening balances.
- Expense-by-category includes only expense transactions.
- Do not infer that total balance is the user’s full net worth; label it as the total balance of tracked accounts.

#### FR-009: Reports and analytics

Provide a simple report screen with:

- Monthly income vs. expense totals.
- Expense breakdown by category.
- Optional previous-period comparison if it can be implemented without expanding scope; if not, leave it out.
- Date range selection: current month, previous month, custom range.
- Tap a category in the expense breakdown to view matching transactions, if practical within the existing navigation.

Analytics requirements:
- Only expense transactions contribute to expense-category breakdown.
- Category percentages use the sum of expenses in the selected period as denominator.
- If the denominator is zero, show an empty state rather than dividing by zero.
- Use accessible labels and text values alongside charts.
- Do not rely solely on chart colors to communicate category meaning.

#### FR-010: Category management

Ship with default categories in both localized names and stable IDs/codes.

Default expense categories (suggested MVP seed data):
- Food & Drinks
- Transport
- Shopping
- Bills & Utilities
- Housing
- Health
- Entertainment
- Education
- Travel
- Personal Care
- Other Expense

Default income categories:
- Salary
- Freelance
- Business
- Investment Income
- Gift
- Other Income

Requirements:
- Categories have `id`, `type` (`income` or `expense`), `name`, `iconKey` (optional), `colorKey` (optional), `isSystem`, `isArchived`, `createdAtUtc`, `updatedAtUtc`.
- Localize system category labels in the UI using stable category codes; do not store translated display labels as the only identity.
- Users can add custom categories with a required name (1–40 characters) and type.
- Prevent duplicate category names within the same type, case-insensitively after trimming.
- Users may edit custom category names.
- System categories cannot be renamed or deleted in the MVP.
- A category used by existing transactions cannot be hard-deleted. Allow archive/deactivation so it cannot be selected for new transactions while historical reports remain accurate. If archive UI is too much for the first iteration, disable deletion of used categories and explain why.
- Transfers do not use categories.

#### FR-011: Settings

MVP settings:
- Choose app language: System default, Vietnamese, English.
- Show current app currency configuration.
- About/version information.
- Do not add unrelated settings.
- Persist the selected language locally.
- Language change should take effect immediately or after a clearly communicated app refresh.

Currency:
- Default to VND for Vietnamese locale.
- For the first MVP, it is acceptable to support VND only to keep amounts and formatting simple.
- If currency selection is implemented, ensure every account and transaction uses the same currency and show a warning before changing it. Never perform silent currency conversion.

#### FR-012: Data persistence and startup

- Data persists across app restarts.
- Database schema versioning/migrations are supported.
- First-run category seed is idempotent: reopening the app must not duplicate categories.
- Database errors are surfaced with a useful message and must not silently clear data.
- No network access is required for core flows.
- Repository interfaces must not depend on widgets or navigation.

---

## 4. Navigation and Screen Specifications

Use a simple bottom navigation with four primary destinations:

1. **Home** — balance summary and recent visual activity.
2. **History** — transaction timeline and filters.
3. **Reports** — monthly summaries and category breakdown.
4. **Accounts** — cash wallets and bank accounts.

A prominent floating Add (`+`) action should open quick transaction entry from the main app. Settings and Categories are secondary destinations reachable from a clear settings/menu action. Keep the navigation shallow; do not add extra tabs for features excluded from the MVP.

### Screen A — Home / Dashboard

Components:
- App bar with app name or compact greeting and settings action.
- Compact current-month activity strip/bar chart, with a clear label for the date range.
- Period selector defaulting to current month.
- Total tracked account balance card.
- Income and expense summary cards.
- Net cash flow.
- Expense-by-category chart/list.
- Recent transactions list (maximum 5).
- Add transaction action.

States:
- Loading during initial database read.
- Empty state when there are no accounts.
- No-transactions state when accounts exist but the selected period has no activity.
- Error state with retry for data load failures.

Actions:
- Add transaction.
- Navigate to transaction detail.
- Change reporting month.
- Navigate to all transactions/reports.
- Navigate to accounts/settings.

### Screen B — Transactions

Components:
- Title and search/filter action.
- Show a small rounded photo thumbnail when a transaction has an attachment; otherwise show a category icon/sticker placeholder.
- Combined filter controls for date range, type, account, category.
- Chronological grouped list (grouping by date is optional).
- Add transaction action.

States:
- No transactions at all.
- No matching filters.
- Loading.
- Read/database error.

Actions:
- Open transaction.
- Edit/delete transaction.
- Apply/reset filters.
- Add transaction.

Text search is optional for MVP. Do not build a complicated full-text search system; if implemented, search note and account/category display names only.

### Screen C — Add/Edit Transaction

Components:
- Transaction type selector.
- Amount input with numeric keyboard.
- Account selector, or source/destination selectors for transfers.
- Category selector for income/expense.
- Date/time selector.
- Optional note field.
- Optional photo attachment control with camera/gallery actions, preview, replace, and remove.
- Save button.

Validation and interaction:
- Changing transaction type clears fields that are not applicable and initializes sensible defaults.
- For a transfer, destination must differ from source.
- Do not allow save while persistence is in progress.
- Preserve values on failed save.
- Show validation close to the field that needs attention.

### Screen D — Accounts

Components:
- List of accounts with account type and current balance.
- Add account action.
- Empty state with create-account CTA.

Account form:
- Name.
- Type: Cash or Bank.
- Opening balance (only editable at account creation under MVP rules).
- Save/cancel.

Account detail (may be a simple page or bottom sheet):
- Account name/type/current balance.
- Recent transactions for that account.
- Edit account.
- Delete only when there are no transactions.

### Screen E — Reports

Components:
- Reporting period selector.
- Income vs. expense summary.
- Expense category breakdown chart and/or list with amounts and percentages.
- Accessible text alternatives for chart values.

States:
- Empty period.
- Loading.
- Error with retry.

### Screen F — Categories

Accessible from Settings or transaction category selection.
- List income/expense categories.
- Add custom category.
- Rename custom category.
- Archive or prevent deletion if used by transactions.
- System categories are read-only.

### Screen G — Settings

Components:
- Language selection: System, Vietnamese, English.
- Currency information (VND-only is acceptable for MVP).
- App version/about.
- No login, cloud sync, or backup controls in this release.


### 4.1 UI Wireframes — MVP Layout Contract

These are structural wireframes, not final pixel-perfect designs. Implement the hierarchy and behavior first, then tune spacing consistently with Material 3. Example amounts are illustrative. Create an original identity rather than reproducing CapMoney's exact visuals.

#### Global navigation

```text
┌────────────────────────────────┐
│              AppBar            │
│        screen title / action   │
├────────────────────────────────┤
│                                │
│        Current screen          │
│                                │
├────────────────────────────────┤
│ Home  History  Reports Accounts│
└────────────────────────────────┘
                           (+)
```

- Four primary destinations: Home, History, Reports, Accounts.
- A prominent floating `+` action opens quick transaction entry and is reachable from main screens.
- Settings and Categories are secondary destinations accessible from a clear menu/settings action.
- Respect safe areas, back navigation, keyboard insets, dynamic text scaling, and small-screen scrolling.

#### Screen A — Home / Visual Dashboard

```text
┌────────────────────────────────┐
│ Money Log                 [⚙]  │
│ October 2026              [⌄]  │
│                                │
│ TOTAL BALANCE                  │
│ 12,500,000 ₫                   │
│ Cash 2,500,000 · Bank 10,000K  │
│                                │
│ ┌────────────────┐ ┌──────────┐│
│ │ Income         │ │ Expense  ││
│ │ +8,000,000 ₫   │ │ -3,200K ₫││
│ └────────────────┘ └──────────┘│
│                                │
│ THIS MONTH                     │
│ [Mon][Tue][Wed][Thu][Fri][Sat] │
│  ▂    ▅    ▃    ▇    ▂    ▄    │
│                                │
│ RECENT ACTIVITY        See all │
│ [🍜] Lunch             -80,000 │
│      Food · Cash · Today       │
│ [📷] Grocery          -240,000 │
│      Shopping · Yesterday     │
│ [💰] Salary          +8,000,000│
│      Income · Oct 01           │
│                                │
│ Home History Reports Accounts  │
└────────────────────────────────┘
```

Behavior:
- Balance is the sum of current balances in tracked accounts, not just this month's net cash flow.
- Income/expense cards use the selected month.
- Activity chart shows daily activity in a selected, clearly labeled range. Choose one definition (selected month or rolling 7 days) and use it consistently.
- Recent activity uses the transaction photo if present; otherwise show the category icon.
- Tap a row to open the transaction; See all opens History.
- If no accounts exist, show a create-account empty state. If accounts exist but the month has no activity, keep the balance visible and offer Add transaction.

#### Screen B — History / Visual Transaction Feed

```text
┌────────────────────────────────┐
│ History                   [⌕]  │
│ [This month⌄] [All types⌄]     │
│ [All accounts⌄] [Category⌄]    │
│                                │
│ TODAY                -320,000 ₫│
│ ┌────────────────────────────┐ │
│ │ [photo/icon] Lunch         │ │
│ │ Food · Cash · 12:30         │ │
│ │                     -80,000 │ │
│ └────────────────────────────┘ │
│ ┌────────────────────────────┐ │
│ │ [photo/icon] Taxi           │ │
│ │ Transport · Bank · 09:15    │ │
│ │                    -240,000 │ │
│ └────────────────────────────┘ │
│                                │
│ YESTERDAY            +500,000 ₫│
│ ┌────────────────────────────┐ │
│ │ [photo/icon] Sold item      │ │
│ │ Other Income · Cash         │ │
│ │                    +500,000 │ │
│ └────────────────────────────┘ │
│                                │
│ Home History Reports Accounts  │
└────────────────────────────────┘
```

Behavior:
- Group rows by local calendar date. Daily summary totals are optional; if shown, define whether they represent net, income, or expense.
- Keep filters compact. On narrow devices use a filter sheet instead of compressing many controls.
- Photo is a thumbnail, not a full-row background; text stays readable.
- Tap a row to view/edit. Provide reset filters and a clear no-results state.

#### Screen C — Quick Add / Edit Transaction

```text
┌────────────────────────────────┐
│ [×]          Add record     [✓] │
│                                │
│ [ Expense ] [ Income ] [Transfer]│
│                                │
│          Amount (VND)           │
│          120,000 ₫              │
│                                │
│ Category                       │
│ [Food] [Transport] [Shopping]  │
│ [Bills] [Health] [Other]       │
│                                │
│ Account                        │
│ [Cash wallet                ⌄] │
│                                │
│ Date                           │
│ [Oct 23, 2026              ⌄]  │
│                                │
│ Note                           │
│ [Lunch with colleagues       ] │
│                                │
│ Add photo (optional)           │
│ [ Camera ] [ Gallery ]         │
│ [    photo preview / remove ]  │
│                                │
│           [ Save record ]      │
└────────────────────────────────┘
```

Behavior:
- Income and Expense share one form structure. Transfer shows Source account and Destination account and hides Category.
- Amount input is prominent, uses a numeric keyboard, and is converted to integer minor units; never persist the formatted display string.
- Category choices may be icon chips or a selector depending on device width.
- Photo is optional and supports preview, replace, and remove before save.
- Keep entered values after validation or persistence errors.
- The top checkmark and bottom Save button above are alternatives in the sketch; implement only one primary save action to prevent duplicate submissions.

#### Screen D — Accounts

```text
┌────────────────────────────────┐
│ Accounts                  [＋]  │
│                                │
│ TOTAL BALANCE                  │
│ 12,500,000 ₫                   │
│                                │
│ CASH                           │
│ ┌────────────────────────────┐ │
│ │ [wallet icon] Cash wallet  │ │
│ │                     2,500K │ │
│ └────────────────────────────┘ │
│ BANK ACCOUNTS                  │
│ ┌────────────────────────────┐ │
│ │ [bank icon] Main bank      │ │
│ │                    10,000K │ │
│ └────────────────────────────┘ │
│                                │
│ [ + Add account ]              │
│                                │
│ Home History Reports Accounts  │
└────────────────────────────────┘
```

Behavior:
- Show account type and repository-derived current balance.
- Create form: name, Cash/Bank type, opening balance.
- Account detail may show recent transactions. Deletion is blocked while referenced by any transaction.
- Never display a stale balance stored only in widget state.

#### Screen E — Reports

```text
┌────────────────────────────────┐
│ Reports                  [⌄]   │
│ October 2026                   │
│                                │
│ INCOME          EXPENSE        │
│ 8,000,000 ₫    3,200,000 ₫     │
│                                │
│ Net cash flow                  │
│ +4,800,000 ₫                   │
│                                │
│ EXPENSE BY CATEGORY            │
│ [simple donut/bar chart]        │
│                                │
│ Food & Drinks       1,200,000  │
│ Transport             600,000  │
│ Shopping              400,000  │
│ Bills                 300,000  │
│ Other                 700,000  │
│                                │
│ Tap category to inspect records│
│ Home History Reports Accounts  │
└────────────────────────────────┘
```

Behavior:
- Keep the selected reporting period visible.
- Income and expenses exclude transfers and opening balances.
- Show accessible category names, amounts, and percentages alongside the chart.
- Handle zero-activity periods without misleading charts. Tapping a category may open filtered History.

#### Screen F — Category Management

```text
┌────────────────────────────────┐
│ [←] Categories                 │
│ [ Expense ] [ Income ]         │
│                                │
│ [🍜] Food & Drinks          [⋮]│
│ [🚗] Transport               [⋮]│
│ [🛍] Shopping                [⋮]│
│ [🏠] Housing                 [⋮]│
│ [⋯]  Other                   [⋮]│
│                                │
│ [ + Add custom category ]      │
└────────────────────────────────┘
```

Behavior:
- Clearly distinguish built-in and custom categories.
- System categories are read-only. Categories referenced by historical transactions cannot be hard-deleted; archive or prevent deletion.

#### Screen G — Settings

```text
┌────────────────────────────────┐
│ [←] Settings                   │
│                                │
│ Preferences                    │
│ Language           Vietnamese⌄ │
│ Currency                     VND│
│                                │
│ Data                           │
│ Stored on this device          │
│ Cloud sync is not available    │
│ in this version.               │
│                                │
│ About                          │
│ App version                    │
└────────────────────────────────┘
```

Behavior:
- Language: System default, Vietnamese, English.
- VND-only is acceptable for MVP.
- Make clear that cloud sync and backup are not included. Do not show fake sync controls.

#### Shared screen states

- Loading: small progress indicator/skeleton without unnecessary flashes.
- Empty: explain what is missing and provide the most relevant next action.
- Error: localized, readable message and retry action when appropriate.
- Validation: show feedback near the relevant field.
- Destructive action: confirmation dialog with a clear cancel action.
- Keyboard: inputs and save action remain usable above the keyboard.
- Accessibility: semantic labels for icon-only actions; values are not communicated by color alone.

---

## 5. Business Rules and Edge Cases

### 5.1 Money representation

- Store amounts as positive integer minor units.
- VND is displayed with no fractional digits.
- Never parse a localized formatted currency string as the source of truth.
- Parsing should accept digits and a clearly defined decimal separator only if fractional currencies are supported.
- Reject empty, zero, negative, malformed, and overflow values.
- Formatting must use locale-aware number/currency formatting.

### 5.2 Account balance

For each account:

`currentBalance = openingBalance + sum(income) - sum(expense) + sum(transferIn) - sum(transferOut)`

- Opening balance must be non-negative.
- No overdraft: reject an expense or transfer-out that would make the account balance negative.
- Income and transfer-in can increase balances.
- The account’s balance must be recalculated after transaction create, edit, or delete.
- A transaction dated in the past still affects the current balance.
- Editing a past transaction must not change the calculation rules.

### 5.3 Atomic transaction operations

Create/edit/delete operations must be atomic:
- Validate all referenced records and balance constraints.
- Apply the transaction mutation.
- Ensure the database transaction succeeds before reporting success.
- On edit, calculate balance constraints as if the old transaction were removed before applying the new version. This avoids falsely rejecting a valid edit because the old transaction is counted twice.
- If any part fails, roll back the whole operation.

### 5.4 Transfer rules

- Source and destination account IDs must differ.
- Amount must be positive.
- Source account must have enough available balance.
- Transfer decreases source and increases destination by equal amounts.
- Transfers do not affect income, expense, net cash flow, or expense-category totals.
- A transfer has one logical transaction ID and must not be represented as two independent user-visible transactions.
- Editing/deleting a transfer must update both accounts atomically.

### 5.5 Date and reporting boundaries

- Use the device’s local timezone for calendar periods.
- Convert local start/end-of-day boundaries to UTC before querying the database.
- Use a half-open interval: `startUtc <= transactionAtUtc < endUtcExclusive`.
- Current month begins at local midnight on the first day of the month and ends at local midnight on the first day of the next month.
- Be careful with daylight-saving changes on devices that observe them.
- Sorting order: transaction timestamp descending, then stable ID as a deterministic tie-breaker.

### 5.6 Category rules

- Income categories can only be assigned to income.
- Expense categories can only be assigned to expense.
- Transfers cannot have a category.
- Historical transactions must remain reportable if their category is archived.
- Do not delete a category referenced by transactions.

### 5.7 Account deletion and history

- Never cascade-delete transactions when deleting an account.
- Block account deletion if any transaction references it as the account, transfer source, or transfer destination.
- A future archive feature may replace deletion, but do not silently introduce it if it is not implemented end-to-end.

### 5.8 Duplicate taps and errors

- Disable submit while saving.
- Do not create duplicate transactions from repeated rapid taps.
- Display a clear localized error if a save fails.
- Preserve form input on save failure.
- Do not swallow exceptions without logging useful diagnostic context in development.

---

## 6. Data Model

Use stable string IDs (UUIDs or another well-supported unique-ID strategy) for all entities. IDs must be created in the application layer and remain stable for future synchronization.

### 6.1 Account

Suggested fields:

```dart
class Account {
  final String id;
  final String name;
  final AccountType type; // cash | bank
  final int openingBalanceMinor;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}
```

Do not persist `currentBalance` as an authoritative mutable field in the MVP; derive it from the opening balance and transactions.

### 6.2 Transaction

Suggested model:

```dart
enum TransactionType { income, expense, transfer }

class MoneyTransaction {
  final String id;
  final TransactionType type;
  final int amountMinor;
  final String? accountId; // income/expense
  final String? categoryId; // income/expense
  final String? sourceAccountId; // transfer
  final String? destinationAccountId; // transfer
  final DateTime transactionAtUtc;
  final String? note;
  final String? attachmentPath; // relative app-managed local image path
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}
```

Validation must enforce the field combinations:
- `income`: `accountId` and `categoryId` required; source/destination null.
- `expense`: `accountId` and `categoryId` required; source/destination null.
- `transfer`: source/destination required and different; account/category null.

Database alternative: use explicit nullable columns plus constraints and repository validation. If the chosen database does not support constraints conveniently, enforce all invariants in the domain layer and test them.

### 6.3 Category

```dart
class Category {
  final String id;
  final String code; // stable code for system categories; nullable for custom if desired
  final TransactionType type; // only income or expense
  final String name; // custom display name; system category display is localized by code
  final String? iconKey;
  final String? colorKey;
  final bool isSystem;
  final bool isArchived;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}
```

For custom categories, persist the user-entered name. For system categories, prefer a stable code plus localized labels in app localization resources. Do not use translated names as primary identifiers.

### 6.4 App settings

Store local settings separately from financial entities:
- `languageCode`: `system`, `vi`, or `en`.
- `currencyCode`: `VND` for the initial MVP.
- Optional schema/version metadata should be managed by the database migration mechanism.

### 6.5 Relationships

- One account has many income/expense transactions.
- A transfer references two accounts: source and destination.
- One category can be referenced by many income or expense transactions.
- Category type must match transaction type.
- Account deletion is blocked while referenced by any transaction.
- Category hard deletion is blocked while referenced by any transaction.

### 6.6 Database indexes

Create indexes where supported and useful:
- Transaction timestamp.
- Transaction type + timestamp.
- Account ID + timestamp.
- Category ID + timestamp.
- Transfer source account ID.
- Transfer destination account ID.

Avoid premature optimization, but use indexed date queries for history and reports.

### 6.7 Schema and migration requirements

- Include a schema version.
- Implement migration infrastructure from the first schema version.
- Seed system categories transactionally and idempotently.
- Do not delete or reset user data during a schema migration.
- Add a migration test when schema changes are introduced.

---

## 7. Technical Architecture

### 7.1 Stack

- Flutter + Dart.
- Material 3 as the base design system.
- **Revised (R3):** Supabase (`supabase_flutter`) for auth, Postgres and photo storage; SQL migrations in `supabase/migrations/`. ~~Local SQLite/Drift.~~
- State management: choose one maintained solution and use it consistently. Recommended default: Riverpod if compatible with the project’s Flutter version; otherwise use a simple, well-structured alternative rather than mixing patterns.
- Routing: use a maintained declarative router if the app has multiple screens; keep navigation definitions centralized.
- Localization: Flutter `flutter_localizations` + generated ARB resources; support `en` and `vi`.
- Charts: use a maintained chart package only if necessary. Keep chart widgets replaceable and show textual data alongside charts.
- Images: `camera` for the live capture screen and `image_picker` for the library; uploads go to Supabase Storage (R4).
- IDs: UUID package or a small tested ID abstraction.
- Dates/numbers: Dart `intl` for locale-aware formatting.
- **Revised (R1):** the only remote service is the project's Supabase backend. Hosting: Netlify (static web build).

The coding agent must verify package compatibility before adding dependencies and record selected versions in `pubspec.yaml`.

### 7.2 Layering

Recommended layers:

1. **Presentation**
   - Screens, reusable widgets, form state, navigation.
   - No direct SQL or business calculations.
2. **Application**
   - Use cases/services: create transaction, edit transaction, delete transaction, create account, load dashboard, query history, generate report.
   - Coordinates validation and repositories.
3. **Domain**
   - Entities, enums, validation rules, balance/report calculation policies.
   - Prefer pure Dart where practical.
4. **Data**
   - Database tables/DAOs, DTO/model mapping, repository implementations, migrations, seed data.
5. **Core**
   - Localization helpers, currency/date formatting, error types, shared utilities.

### 7.3 Repository interfaces

Create interfaces at the domain/application boundary, for example:

- `AccountRepository`
  - `watchAccounts()`
  - `getAccountById(id)`
  - `createAccount(...)`
  - `updateAccount(...)`
  - `deleteAccountIfUnused(id)`
  - `getAccountBalance(id)`
  - `getAllAccountBalances()`
- `TransactionRepository`
  - `watchTransactions(query)`
  - `getTransactionById(id)`
  - `createTransaction(...)`
  - `updateTransaction(...)`
  - `deleteTransaction(id)`
  - `getPeriodSummary(startUtc, endUtcExclusive)`
  - `getExpenseBreakdown(startUtc, endUtcExclusive)`
  - `getRecentTransactions(limit)`
- `CategoryRepository`
  - `getCategories(type, includeArchived)`
  - `createCustomCategory(...)`
  - `updateCustomCategory(...)`
  - `archiveCategory(id)`
- `SettingsRepository`
  - `getSettings()`
  - `updateLanguage(code)`

Adapt method signatures to the chosen state/database packages. Do not create empty abstractions that have no real use; these interfaces are required because a future sync implementation must not require UI rewrites.

### 7.4 State and reactivity

- Use a consistent state-management pattern.
- UI should react to database changes after create/edit/delete.
- Avoid manually updating multiple independent UI copies of the same balance.
- Use repository streams/watchers or explicit invalidation/refetch patterns consistently.
- Keep form state separate from persisted entity state.

### 7.5 Error handling

Define typed errors for expected cases, such as:
- Invalid amount.
- Insufficient balance.
- Account not found or unavailable.
- Category not found, archived, or mismatched type.
- Account in use.
- Category in use.
- Persistence failure.

Map domain errors to localized, understandable UI messages. Do not show raw SQL errors to users.

### 7.6 Cloud-sync readiness (not implemented)

Prepare for future sync by:
- Using stable IDs.
- Keeping `createdAtUtc` and `updatedAtUtc`.
- Separating repository interfaces from local database implementations.
- Avoiding widget code that assumes SQLite directly.
- Keeping mutations centralized in use cases/repositories.

Do not add `syncStatus`, conflict resolution, server IDs, authentication, retry queues, or a backend until cloud sync is approved. If a future sync feature is implemented, the data model will need a deliberate migration and conflict strategy.

---

## 8. Suggested Project Structure

Adjust to the existing repository if one exists. A feature-first structure is recommended:

```text
lib/
  main.dart
  app/
    app.dart
    router.dart
    theme/
      app_theme.dart
    localization/
  core/
    errors/
    formatting/
    dates/
    database/
      app_database.dart
      migrations/
      seed/
    widgets/
  features/
    dashboard/
      data/
      domain/
      application/
      presentation/
    transactions/
      data/
      domain/
      application/
      presentation/
    accounts/
      data/
      domain/
      application/
      presentation/
    categories/
      data/
      domain/
      application/
      presentation/
    reports/
      domain/
      application/
      presentation/
    settings/
      data/
      domain/
      application/
      presentation/
test/
  core/
  features/
```

Do not create a folder or layer merely to satisfy the diagram if it would be empty. Keep the structure understandable and consistent.

---

## 9. UI/UX and Design System

### 9.1 Visual direction

- Modern, minimal, calm, practical, and visual-first.
- Draw inspiration from image-backed transaction records, compact summaries, and fast entry, but create an original layout and branding rather than a CapMoney copy.
- Material 3 components with a small custom theme.
- Clear spacing and readable typography.
- Prefer cards and simple lists over dense dashboards.
- Keep the primary action easy to reach.
- Use consistent icons and component sizes.
- Avoid excessive gradients, shadows, animations, and decorative elements.
- Use responsive layouts for small and large phone screens.
- Respect system text scaling and accessibility settings.

### 9.2 Semantic color

Use semantic theme colors for:
- Income/positive amount.
- Expense/negative amount.
- Neutral balance.
- Warning/error.
- Category visualization.

Color values must come from the theme, not be scattered across widgets. Do not rely on color alone: show labels, signs, and icons/text.

### 9.3 Transaction image/sticker presentation

- If a transaction has a local photo, show a cropped rounded thumbnail in history and recent-activity rows.
- If no photo is attached, show a category icon/sticker inside a consistent neutral surface.
- Keep amount, category/name, account, and date more prominent than the thumbnail.
- Reuse thumbnail size and crop behavior consistently across screens.
- Image failure must never hide or block access to a transaction.
- Do not reproduce CapMoney-specific sticker designs or screenshots.

### 9.4 Amount display

- Use locale-aware currency formatting.
- VND examples should be readable in Vietnamese locale.
- Amounts in forms should be easy to enter and edit.
- Display negative effects with a minus sign where appropriate; stored amounts remain positive and transaction type determines direction.
- Use a consistent display convention throughout dashboard, history, account list, and reports.

### 9.5 Forms

- Label every field.
- Show required/optional state clearly.
- Use numeric input for amount.
- Avoid clearing valid fields after an error.
- Show clear confirmation dialogs for destructive actions.
- Ensure controls are accessible to screen readers.

### 9.6 Accessibility

- Maintain adequate contrast.
- Use semantic labels for icon-only buttons.
- Support dynamic text sizing.
- Ensure tap targets are comfortably usable.
- Charts must have an accessible textual summary or equivalent category list.

### 9.7 Localization

- English (`en`) and Vietnamese (`vi`) must be supported from the beginning.
- User-facing text must come from localization resources.
- Format dates, numbers, and currency according to the active locale.
- System category labels are localized.
- Custom category names and account names remain exactly as entered by the user.
- Do not use translated UI strings as persisted business identifiers.

---

## 10. Security, Privacy, and Data Safety

- All financial records stay on the device in the MVP.
- Do not transmit transaction or account data to external services.
- Do not log amounts, notes, or other financial details in production logs.
- Do not add third-party analytics or advertising SDKs.
- Use the database package’s safe parameterized query mechanisms.
- Do not store secrets because the MVP has no API keys or authentication.
- Confirm destructive actions.
- Do not implement an unverified “backup” feature.
- Document that uninstalling the app or losing the device may cause loss of local-only data; the MVP has no cloud backup.
- Handle database initialization and migrations safely. Never respond to a database error by automatically deleting and recreating the database.

---

## 11. Testing Strategy

### 11.1 Unit tests — required

Money and balance rules:
- Opening balance is included in current balance but excluded from income/expense totals.
- Income increases the correct account.
- Expense decreases the correct account.
- Transfer decreases source and increases destination.
- Transfer does not count as income or expense.
- Expense and transfer-out that exceed available balance are rejected.
- Editing a transaction does not double-count the old version.
- Deleting an income, expense, or transfer reverses its balance effects.
- Zero, negative, malformed, and overflowing amounts are rejected.

Validation:
- Empty account name is rejected.
- Account name length limits are enforced.
- Category type mismatch is rejected.
- Transfer to the same account is rejected.
- Duplicate category names are rejected case-insensitively.
- Used account/category deletion is blocked.

Date/report calculations:
- Current-month boundaries are correct.
- Transactions at the start boundary are included.
- Transactions at the end-exclusive boundary are excluded.
- Reports exclude transfers and opening balances.
- Expense category percentages handle zero expense safely.
- Sorting is deterministic for equal timestamps.

### 11.2 Repository/database tests — required

- Account and transaction data persist after reopening the database.
- Transaction create/edit/delete are atomic.
- Failed edits leave old data intact.
- Account deletion is blocked when referenced.
- Category deletion/archive constraints work.
- Default categories seed exactly once.
- Transaction photo metadata persists across database/app restart.
- Replacing/removing/deleting a photo follows safe file-cleanup rules.
- A missing image does not make a transaction unreadable.
- Migration infrastructure initializes a fresh database.
- Date-range and summary queries return correct results.

### 11.3 Widget tests — required

- First-run empty state and create-account action.
- Add-income form validation and success.
- Add-expense form validation and insufficient-balance message.
- Transfer form rejects same source/destination.
- Transaction list empty and filtered-empty states.
- Dashboard displays correct summary labels.
- Language selection changes visible strings.
- Destructive action requires confirmation.

### 11.4 Integration/smoke test

At minimum, test this flow:

1. Launch app with an empty database.
2. Create a cash account with opening balance 1,000,000 VND.
3. Add income of 500,000 VND.
4. Add expense of 200,000 VND.
5. Transfer 300,000 VND to a bank account.
6. Verify cash balance is 1,000,000 VND and bank balance is 300,000 VND, assuming the income was 500,000 and expense 200,000 and the transfer is 300,000: cash starts at 1,000,000, rises to 1,500,000, falls to 1,300,000, then falls to 1,000,000; bank rises to 300,000.
7. Verify income report is 500,000 VND, expense report is 200,000 VND, and transfer is excluded from both.
8. Edit the expense and verify balances and reports update.
9. Delete the transfer and verify both account balances update correctly.
10. Restart the app and verify data persists.

---

## 12. Acceptance Criteria

The MVP is ready for release when all of the following are true:

- [ ] App launches without requiring an account or internet.
- [ ] User can create cash and bank accounts.
- [ ] User can record income, expenses, and transfers.
- [ ] Transfers update both accounts and never count as income/expense.
- [ ] Opening balances affect current balances but not income/expense analytics.
- [ ] Negative balances are prevented.
- [ ] User can edit/delete transactions with correct recalculation.
- [ ] Transaction history supports date, type, account, and category filters.
- [ ] Dashboard shows total tracked-account balance, period income, period expense, net cash flow, and recent transactions.
- [ ] Expense breakdown by category is correct.
- [ ] Default categories are localized and seeded only once.
- [ ] User can create custom categories and invalid category operations are blocked.
- [ ] Vietnamese and English UI work.
- [ ] Data survives app restarts.
- [ ] Optional transaction photos persist across app restarts and remain local; no image or ledger data is uploaded.
- [ ] Database schema/migration support exists.
- [ ] Important business rules are covered by automated tests.
- [ ] `flutter analyze` has no new errors.
- [ ] README includes setup, run, test, and architecture instructions.
- [ ] No out-of-scope feature has been added.

---

## 13. Implementation Roadmap for the AI Agent

Implement phases in order. Do not attempt to generate the whole app in one large unverified change.

### Phase 0 — Repository inspection and project bootstrap

**Status: done** (UI prototype milestone, commits `8d087e4`…`a762108`).

Tasks:
- Inspect repository and Flutter/Dart versions.
- Confirm target platforms.
- Initialize or normalize Flutter project if needed.
- Add only the agreed core dependencies.
- Configure linting, localization generation, formatting, and test setup.
- Create the base theme, app entry point, and README.

Exit criteria:
- App starts on target platform.
- `flutter analyze` and initial tests run.
- Dependencies and architecture decisions are documented.

### Phase 1 — Domain model and persistence

**Status: done, pending backend hookup.** Supabase schema (`0001_init.sql`), `LedgerRepository` with Supabase and in-memory implementations, sign-in, save-before-show with error handling, no-overdraft validation. Categories remain built-in codes until Phase 2. Remaining: apply the schema to the owner's Supabase project and verify end to end.

Tasks:
- Define Account, MoneyTransaction, Category, settings models, and enums.
- Implement database schema, migrations, and idempotent system-category seeding.
- Implement repositories and typed errors.
- Implement and test balance calculation and transaction validation.

Exit criteria:
- Repository/database tests pass.
- Balance and transfer rules are covered by unit tests.
- No UI is required beyond a temporary development shell if useful.

### Phase 2 — Accounts and categories

**Status: done.** Account create/edit/delete with in-use and opening-balance rules, account detail, custom categories (create, rename, recolor, archive/restore, delete when unused) with `0002_custom_categories.sql`. Built-in categories stay app-defined codes. Pending: apply both migrations to the owner's Supabase project.

Tasks:
- Build account list, create/edit account form, and account detail.
- Enforce account deletion constraints.
- Build category list and custom category creation/edit/archive behavior.
- Add localized empty/loading/error states.

Exit criteria:
- Accounts and categories persist.
- Opening balance works.
- Account/category constraints are tested.

### Phase 3 — Transaction entry and history

**Status: done.** Two-step add flow, edit/delete, and history filters for type, time (any, this month, last month, custom range), account (including transfer sides) and category, combinable with search, plus reset and no-results states. Rows show the account. Pending: verify against the owner's Supabase project.

Tasks:
- Build add/edit transaction forms for income, expense, and transfer.
- Add optional local photo attachment via camera/gallery, persistent app-managed storage, preview, replacement/removal, and missing-file handling. Do not implement OCR.
- Implement atomic create/edit/delete.
- Build transaction history and filters.
- Add confirmation and validation states.

Exit criteria:
- All transaction types work.
- Insufficient balance is blocked.
- Transfer operations update both accounts correctly.
- Edit/delete behavior is tested.

### Phase 4 — Dashboard and reports

**Status: partly done** (Reports with month/year/all-time, income/expense, savings rate, category breakdown). Remaining: custom date range, tap category to filtered history.

Tasks:
- Implement period-based summary queries.
- Build dashboard cards and an image-aware transaction feed using photos or category-icon placeholders.
- Build expense-by-category report and accessible chart/list.
- Add month/date-range navigation and empty states.

Exit criteria:
- Summary values match repository calculations.
- Transfers and opening balances are excluded from income/expense analytics.
- Reports work for empty periods and custom date ranges.

### Phase 5 — Localization, polish, and QA

Tasks:
- Complete English and Vietnamese translations.
- Check date and currency formatting.
- Add widget and smoke/integration tests, including photo permission denial, photo preview/removal, missing-file placeholder, and persistence.
- Review accessibility, loading states, errors, and destructive confirmations.
- Run format, analyze, and tests.
- Update README.

Exit criteria:
- Acceptance criteria are met.
- No known critical balance-calculation bugs.
- All required commands and results are reported.

### Phase 6 — Release preparation

Tasks:
- Configure app name and icons if assets are available.
- Verify Android/iOS build configuration.
- Test a release build on available target platforms.
- Document limitations and known issues.
- Do not submit to app stores or create developer accounts without explicit approval.

Exit criteria:
- A buildable MVP and reproducible local setup are documented.

---

## 14. Required AI Agent Workflow

For each phase:

1. **Plan:** list the files/components to add or change and explain the approach briefly.
2. **Implement:** make the smallest coherent set of changes for the phase.
3. **Verify:** run formatter, analyzer, and relevant tests.
4. **Inspect:** review for duplicate logic, unsafe money calculations, unlocalized strings, and violations of this plan.
5. **Report:** summarize implementation, changed files, commands/results, and unresolved items.
6. **Pause at phase boundaries:** do not start the next phase until the current phase meets its exit criteria, unless the user explicitly asks to continue automatically.

If a requirement is ambiguous:
- Prefer the simplest behavior consistent with this document.
- State the assumption in the phase report.
- Do not invent new features.
- Ask the user only when the ambiguity materially affects data integrity, architecture, privacy, or user-visible behavior.

### Final delivery report

When all phases are complete, provide:
- What was implemented.
- Architecture and dependency choices.
- How to run the app.
- How to run tests and static analysis.
- Test/build results.
- Known limitations.
- Confirmation that cloud sync is not implemented.
- Any remaining release steps requiring the user’s approval.


## 14A. Post-MVP Evolution (Not Part of Initial Build)

Do not implement these during MVP unless explicitly requested later. This list prevents future ideas from leaking into the first release.

1. **Photo OCR suggestions:** infer likely amount/date/vendor/category from a receipt. Results must be suggestions that the user reviews and edits; never save recognition results automatically. Decide privacy/network behavior before implementation.
2. **Monthly budget:** a simple monthly expense limit with progress, not a complex budget planner.
3. **Better history/report filters:** text search, richer date ranges, category drill-down, and period comparisons.
4. **Backup and restore:** local export/import with explicit safety warnings and validation.
5. **Cloud sync:** authentication, remote storage, conflict resolution, and photo synchronization planned as a separate project.
6. **Quick capture/widgets:** home-screen or lock-screen shortcuts after core entry and persistence are stable.
7. **Travel/group tracking:** only if validated by user demand.

Do not include subscriptions, ads, or paywalls until the app's core value proposition and privacy model have been validated.

---

## 15. Initial Prompt to Start Implementation

Use this prompt with the coding agent after placing this file at the repository root:

> Read `APP_PLAN.md` completely before changing code. Inspect the existing repository and report the current Flutter/Dart setup, existing conventions, and any conflicts with the plan. Then implement **Phase 0 only** from the Implementation Roadmap. Do not implement later phases yet. Follow the Required AI Agent Workflow, run formatting, `flutter analyze`, and available tests, update README, and report changed files, commands, results, assumptions, and blockers. Do not add any feature outside the MVP scope.


---

## Appendix A — Public Reference Links

These links were consulted for broad product positioning only; they are not pixel-perfect implementation specifications:

- CapMoney App Store listing: https://apps.apple.com/vn/app/capmoney-money-tracker/id6757230737?l=vi
- CapMoney Google Play listing: https://play.google.com/store/apps/details?hl=vi&id=com.capmoney.app
- CapMoney public guide to photo/sticker entry and reports: https://capmoney.app/en/guide/

Public descriptions emphasize image-backed tracking, quick entry, searchable transaction history, and category/month reports. This project's implementation must retain its own branding, visual design, copy, and assets.
