# UI_MOCKUP_SPEC.md
# Money Tracker — UI Mockup & First Flutter iOS Milestone

Version: 1.1  
Status: Approved design direction; ready for prototype implementation  
Companion document: `APP_PLAN.md`

## Revisions — 2026-10-25

The owner asked the first version to follow CapMoney's App Store layout (structure and interactions), keeping this app's own name, colors, icons, wording and sample assets. Implemented changes:

- **Shell:** floating icon-only pill nav (Home, Reports, Transactions, Accounts, Profile) with the + button to its right, so it never covers content. Dark theme by default.
- **Home:** greeting + name + avatar, "spent today" pill, Day/Month toggle with counts, hide-amounts toggle, account filter chips, month bar with picker and back-to-today.
- **Calendar cells:** up to two items as a tilted stack (photos first, then category tiles) with a "+N" badge and the day number underneath. **Daily totals are no longer shown in cells** (owner's choice); the day's spending shows in the "spent today" pill and the day preview.
- **Day view:** three-column photo grid with amounts.
- **Reports:** Month / Year / All time tabs, account chips, income and expense cards, balance + savings rate, Category / Cluster / Map tabs (Cluster and Map are placeholders).
- **Add flow:** capture step (live camera, library, skip) then an entry step with a calculator keypad. See APP_PLAN.md revision R6.
- **Data:** saved to Supabase with sign-in (APP_PLAN.md revision R1).

## 1. Product direction
- Flutter + Dart; iOS first.
- Local-first direction; use mock data and in-memory state for this milestone.
- Vietnamese and English localization scaffolding.
- Light and Dark themes.
- Main differentiator: monthly calendar with small transaction photo thumbnails in each day cell and that day's expense total.
- Transaction photos are entirely optional.
- Create an original design. Do not copy another app's branding, exact layout, icons, or proprietary assets.

## 2. Approved decisions
| Area | Decision |
|---|---|
| Theme | Light and Dark; respect system theme by default; offer Light/Dark/System if feasible |
| Calendar | Seven columns; day number, up to 2–3 thumbnails, daily expense total |
| Photos | Optional; may skip, attach, replace, or remove |
| Visual style | Clean modern iOS UI, rounded cards, restrained green accent |
| Navigation | Home, Transactions, central Add action, Reports, Accounts |
| Sample currency | VND |
| First UI scope | Home calendar, selected-day detail, Add/Edit Transaction, basic Transactions list |
| Out of scope | OCR, budgets, widgets, cloud sync, banking integrations, production database, advanced analytics |

## 3. Theme tokens
Use centralized Flutter `ThemeData` / `ColorScheme`, not scattered hardcoded colors.

### Light
- Primary `#16A36A`; emphasis `#128354`
- Background `#F6F8F7`; surface `#FFFFFF`
- Main text `#17212B`; secondary text `#667085`
- Border `#E3E8E5`; income `#159957`; expense `#E5484D`; transfer `#3984D6`

### Dark
- Primary `#4ADE9A`
- Background `#101614`; surface `#19211E`; elevated surface `#202B26`
- Main text `#F3F7F4`; secondary text `#A8B5AE`
- Border `#303D36`; income `#4ADE9A`; expense `#FF7278`; transfer `#75B5FF`

### Spacing and accessibility
- Use a 4-point spacing scale; common values 8, 12, 16, 20, 24.
- Card radius about 16; input radius 12–16; thumbnail radius 6–8.
- Aim for tap targets at least 44 × 44 logical pixels.
- Respect iOS safe areas and keyboard insets.
- Keep contrast readable in both themes; avoid clipping Vietnamese labels.
- Do not communicate transaction type by color alone.

## 4. Screen A — Home / Monthly Photo Calendar
This is the primary screen and highest design priority.

### Layout
1. App bar: current month/year, month navigation or picker; optional search/settings.
2. Compact summary: balance, monthly income, monthly expenses. The calendar must remain the visual focus.
3. Seven-column calendar:
   - Monday-first week layout for Vietnamese locale.
   - Each cell shows the day number.
   - Show up to 2–3 compact transaction photo thumbnails where photos exist.
   - Show an overflow indicator/count if more transactions exist than fit.
   - Show daily expense total beneath thumbnails, clearly labelled as expenses.
   - Selected date has a clear primary-color outline or subtle fill.
   - Dates outside the month are subdued; today has a distinct but subtle marker.
   - Empty days remain quiet; do not show fake photo placeholders.
4. Selected-day preview below the calendar:
   - Selected date and daily expense total.
   - A few transaction rows with thumbnail or category icon, name/category, and amount.
   - “View all” opens the complete list for that day.
5. Bottom navigation: Home, Transactions, Add, Reports, Accounts. Add is prominent without obscuring content.

### Behavior
- Tapping a date updates selection and daily preview.
- Tapping a transaction opens its detail/edit state.
- Previous/next month navigation updates calendar and summary.
- Choose thumbnails deterministically (e.g. newest first) and show an overflow count.
- Income-only days must not be mislabeled as expense days.
- Keep day labels and amounts readable rather than squeezing in more photos.
- Empty months show the calendar plus a helpful empty-state prompt.

## 5. Screen B — Daily Transactions
- Back navigation and localized selected date.
- Daily expense total; optionally show income total when relevant.
- Optional filters: All / Expense / Income / Transfer.
- Rows show photo thumbnail if available, otherwise category icon; name/note; category; time; amount.
- Add action uses the selected date.
- Show an empty-day state with a direct Add Transaction action.
- Tapping a row opens Edit Transaction.

## 6. Screen C — Add/Edit Transaction
Optimize for quick one-handed use. Photo attachment is optional.

### Fields
1. Cancel / localized title / Save.
2. Type selector: Expense, Income, Transfer.
3. Prominent amount input with numeric keyboard and VND formatting; amount must be greater than zero.
4. Category selector for Expense and Income.
5. Account selector: one account for Expense/Income; source and destination for Transfer.
6. Date/time; default to now or selected calendar date.
7. Optional note.
8. Optional photo: camera or photo library, preview, replace/remove. Request OS permissions only when needed and handle denial gracefully.
9. One clear primary Save action.

### Behavior and validation
- Changing type updates relevant fields.
- Transfer does not require a category unless explicitly decided later.
- Prevent saving empty, invalid, or non-positive amounts.
- Keep Save reachable when keyboard is open.
- Confirm leaving only if there are unsaved changes.
- Saving without a photo must always work.
- If image picking is not implemented, do not pretend an image was saved; report the limitation.

## 7. Screen D — Transactions List
- Search affordance and All / Expense / Income / Transfer filters.
- Group transactions by date.
- Reuse the same transaction row component as the daily view.
- Use photo thumbnails when available, category icons otherwise.
- Include empty and no-results states.
- Mock data and in-memory state only.

## 8. Reusable components
Create widgets where they improve consistency:
- `MonthlySummaryCard`
- `PhotoCalendar`
- `PhotoCalendarDayCell`
- `TransactionThumbnail`
- `TransactionListItem`
- `TransactionTypeSelector`
- `AmountInput`
- `CategorySelector`
- `AccountSelector`
- `OptionalPhotoPicker`
- `EmptyStateView`
- Shared app navigation

Avoid overengineering. Keep components testable and easy to revise.

## 9. Localization
- Use Flutter localization infrastructure or a lightweight package compatible with the project's Flutter version.
- Include Vietnamese (`vi`) and English (`en`) from the beginning.
- Do not hardcode UI strings directly in widgets.
- Localize month/weekday names, dates, currency formatting, validation, empty states, and navigation.
- Vietnamese may be the initial default locale, but switching must be supported by the architecture.

## 10. Mock data
These are fictional visual fixtures only:
- Ví tiền mặt: 2.450.000 ₫
- Vietcombank: 8.000.000 ₫
- Cà phê — Ăn uống — 55.000 ₫ — photo
- Ăn trưa — Ăn uống — 85.000 ₫ — photo
- Grab — Di chuyển — 60.000 ₫ — photo
- Mua sắm — Mua sắm — 165.000 ₫ — no photo
- Lương — Thu nhập — 8.000.000 ₫ — no photo

## 11. First implementation milestone
Implement only:
1. Home with monthly photo calendar, summary, selected-day preview, bottom navigation.
2. Daily transaction list/detail.
3. Add/Edit Transaction with Expense / Income / Transfer states, validation, optional photo.
4. Basic Transactions screen with filters.
5. Light and Dark themes.
6. Vietnamese and English localization scaffolding.
7. In-memory sample state for navigation and interactions.

Do not implement a production database/repository, backend, sign-in, cloud sync, OCR, budgets, recurring transactions, widgets, banking integrations, or advanced analytics. Reports, Accounts, and Settings may be placeholders except for theme/language demo controls.

## 12. Acceptance criteria
- Runs in an iOS simulator with a coherent, polished layout.
- Calendar is the dominant element on Home.
- Days with transactions show small thumbnails and readable daily expense totals.
- Calendar remains usable on days with many transactions.
- Selecting a day updates the preview.
- User can navigate to daily transactions and Add Transaction.
- Expense / Income / Transfer states work in the form.
- Photo attachment is optional.
- Light and Dark themes can be previewed.
- Vietnamese and English localization scaffolding exists and visible strings are localized.
- Empty states are designed; only seeded demo data appears.
- Run formatter, `flutter analyze`, and available tests; report results.
- Stop after the UI prototype and request review before database/backend work.

## 13. Claude Code prompt
Paste from the project root:

> Read `APP_PLAN.md` and `UI_MOCKUP_SPEC.md` first. Inspect the repository, Flutter/Dart versions, project structure, dependencies, conventions, and available assets before editing. Implement only the first UI prototype milestone defined in `UI_MOCKUP_SPEC.md`.
>
> Prioritize the Home screen's monthly photo calendar: each day with transactions should show 2–3 small transaction thumbnails and a readable daily expense total. Include a selected-day preview, daily transaction list, Add/Edit Transaction form, and basic transaction filters. Support Light and Dark themes and Vietnamese/English localization scaffolding. Transaction photos must be optional.
>
> Use deterministic mock data and in-memory state only. Do not add a production database, backend, sign-in, cloud sync, OCR, budgets, or advanced analytics. Do not copy another app's branding or assets. Use packages compatible with the repository's Flutter version; avoid unnecessary dependencies.
>
> Run formatter, `flutter analyze`, and available tests. Report changed files, implemented interactions, commands/results, assumptions, known limitations, and blockers. Do not continue to database/domain implementation until the UI prototype is reviewed.

## 14. UI review checklist
- Can users understand monthly spending at a glance?
- Are thumbnails useful without overcrowding the calendar?
- Is the daily total readable on normal iPhone sizes?
- Is the selected-day state clear?
- Is Add Transaction quick and comfortable one-handedly?
- Can users save without a photo?
- Are both themes readable?
- Do Vietnamese labels fit without clipping?
- Are empty states clear?
- Are navigation and interactions coherent with mock data?
