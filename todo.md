# ✅ Store Billing / Calculator App (Flutter) – TODO + Full Specification

A fast, offline-first store billing app with a calculator-style UI for elder-friendly daily use.
Goal: Replace manual ledger entry using Qty × Rate style billing, generate invoices, view history, and export reports.

---

## 1) ✅ Project Goals

### MVP Goals
- Calculator-first billing entry (Qty * Rate)
- Add items to bill quickly
- Checkout / View bill screen
- Save invoice locally
- Invoice history list
- Export invoices (PDF + Excel)
- Settings: Theme, Text size, Language, Contrast option

### Phase-2 (Future - Optional)
- Product list / inventory module
- Customer credit / Udhari tracking
- Cloud backup sync (Supabase/Firebase)

---

## 2) ✅ Tech Stack & Packages

### Framework
- Flutter (Android + iOS) (Tablet friendly)

### State Management
- Riverpod (recommended)

### Database (Offline-First)
- Drift (SQLite)

### Export
- PDF: `pdf`
- Excel: `excel`
- File paths: `path_provider`
- Share: `share_plus` (optional)

### Localization / Translation
- `flutter_localizations`
- `intl`
- ARB translation files

### UI & Responsiveness
- `flutter_screenutil` OR built-in `LayoutBuilder`
- `responsive_framework` (optional)

---

## 3) ✅ App Structure (Clean Architecture - Feature Based)

lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   ├── app_sizes.dart
│   ├── theme/
│   │   ├── light_theme.dart
│   │   ├── dark_theme.dart
│   │   ├── contrast_theme.dart
│   ├── localization/
│   │   ├── l10n.dart
│   │   ├── app_en.arb
│   │   ├── app_ml.arb
│   │   ├── app_hi.arb
│   │   ├── app_ta.arb
│   ├── database/
│   │   ├── drift_db.dart
│   │   ├── tables/
│   │   │   ├── invoices.dart
│   │   │   ├── invoice_items.dart
│   ├── utils/
│   │   ├── serial_number.dart
│   │   ├── currency_format.dart
│   │   ├── date_helpers.dart
│   │   ├── export_pdf.dart
│   │   ├── export_excel.dart
│   ├── widgets/
│       ├── app_button.dart
│       ├── keypad_button.dart
│       ├── responsive_scaffold.dart
│       ├── section_header.dart
│
├── features/
│   ├── splash/
│   │   ├── presentation/splash_screen.dart
│   ├── calculator/
│   │   ├── domain/
│   │   │   ├── bill_item.dart
│   │   │   ├── calc_logic.dart
│   │   ├── presentation/
│   │   │   ├── calculator_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── bill_preview_list.dart
│   │   │   │   ├── calc_display.dart
│   │   │   │   ├── calc_keypad.dart
│   │   │   │   ├── qty_rate_input.dart
│   ├── checkout/
│   │   ├── presentation/checkout_screen.dart
│   ├── invoices/
│   │   ├── presentation/invoice_list_screen.dart
│   │   ├── presentation/invoice_detail_screen.dart
│   │   ├── presentation/widgets/filter_sheet.dart
│   ├── settings/
│       ├── presentation/settings_screen.dart
│       ├── domain/preferences_model.dart
│
└── main.dart

---

## 4) ✅ App Screens (Required)

### Screen 1: Splash Screen
✅ Requirements:
- App logo + name
- Smooth fade animation (1.5 sec)
- Load user settings from local storage:
  - theme mode
  - language
  - text size scaling
  - contrast mode on/off
- Navigate to Calculator screen

✅ TODO:
- [ ] Build splash UI
- [ ] Load saved settings
- [ ] Init Drift DB and check DB health
- [ ] Navigate to Calculator screen

---

### Screen 2: Main Screen (Calculator Billing UI)
This must match your provided UI layout and flow.
📌 Theme change: use GREEN instead of BLUE.

✅ Main Layout (Top → Bottom)
1. Header Area:
- Register label: "Register #1"
- Status: OPEN (green)
- Profile/settings icon

2. Current Bill List:
- Item name
- Qty × Rate (small subtext)
- Total amount aligned right
- Swipe actions:
  - Swipe left: delete item
  - Swipe right: edit item (optional)

3. Calculator Area:
- Manual price display input
- Qty input
- Keypad buttons: 0–9, 00, ., backspace, clear
- Operator: ×
- Plus button to add item (+)

4. Bottom bar:
- Big "Checkout" button
- Total amount

✅ TODO:
- [ ] Implement calculator UI (pixel close to your image)
- [ ] Use large readable font sizes (elder-friendly)
- [ ] Button size should be large (min 56px height)
- [ ] Add haptic feedback toggle (optional)
- [ ] Ensure all buttons work even on tablets
- [ ] Add "Clear All" option for current bill

✅ Calculator Logic Rules:
- Quantity can be decimal (ex: 1.5)
- Rate can be decimal (ex: 12.50)
- Total = qty * rate
- Add to bill button only enabled if both qty and rate valid
- Prevent invalid input like ".." or multiple decimals

✅ UX improvements for elders:
- Big digits and high spacing
- Large touch targets
- No hidden small icons
- Avoid complex gestures as main action (swipe is optional)

---

### Screen 3: Checkout / View Bill Page
✅ Purpose:
Before saving invoice, user reviews everything.

✅ Components:
- Bill items list
- Subtotal
- Discount (optional):
  - global discount amount or %
- Grand Total
- Payment mode:
  - Cash
  - GPay/UPI
  - Credit
- Optional: Notes field
- Confirm & Save button
- Cancel / back button

✅ TODO:
- [ ] Build checkout screen UI
- [ ] Allow edit quantities and remove items
- [ ] Confirm & Save -> store invoice + items in DB
- [ ] After save:
  - reset temp bill state
  - show success toast/snackbar
  - optionally open invoice preview page

---

### Screen 4: Invoice List Page (History)
✅ Must include:
- Filters:
  - Date range
  - Payment mode
  - Amount range (optional)
  - Search by Invoice No (optional)
- Toggle view modes:
  ✅ Consolidated View
  ✅ Detailed View

✅ Consolidated View (Daily summary)
- Date
- No. of invoices
- Total amount
- Total cash / total UPI / total credit (optional)

✅ Detailed View
- Invoice number
- Date and time
- Total amount
- Payment mode
- Tap = view invoice detail

✅ Export Options
- Export to PDF (daily range / filtered list)
- Export to Excel (daily range / filtered list)

✅ TODO:
- [ ] Build invoice list page
- [ ] Implement filter bottom sheet
- [ ] Implement consolidated/detailed view switch
- [ ] Export button in top-right
- [ ] Export respects filters applied

---

### Screen 5: Invoice Detail Page
✅ Shows:
- Invoice No
- Date + time
- Item table
- Subtotal / discount / grand total
- Payment mode
- Print/share/export this invoice (PDF)

✅ TODO:
- [ ] Build detail view UI
- [ ] Generate invoice PDF
- [ ] Share invoice PDF

---

### Screen 6: Settings Page
✅ Must include:
1. Theme:
   - Light Mode
   - Dark Mode
2. Contrast Mode (Optional Toggle)
   - OFF by default
   - When ON: higher contrast colors, thicker borders

3. Text Size Adjustment
- Slider: Small → Large
- Must affect entire app text size

4. Language Selection:
- English
- Malayalam
- Hindi
- Tamil

✅ TODO:
- [ ] Build settings page
- [ ] Persist all preferences locally
- [ ] App should rebuild instantly on changes

---

## 5) ✅ Green Theme UI Specs

### Primary Color Palette (Green)
- Primary: Green (example: #1B8F3A)
- Secondary: Light green accents
- Background: Clean white / soft gray
- Dark mode: Deep gray/black with green accents

✅ TODO:
- [ ] Replace all blue buttons with green theme
- [ ] Checkout button: solid green background
- [ ] Add-to-bill (+) button: green
- [ ] OPEN status chip: green

---

## 6) ✅ Responsiveness Rules (Phones + Tablets)

✅ Requirements:
- Must support:
  - Android phones
  - 7" tablets
  - 10" tablets
- Must support:
  - Portrait layout
  - Landscape layout

✅ Layout Adaptation Strategy:
- Phone Portrait:
  - Current Bill on top
  - Keypad below
- Tablet Landscape:
  - Left: Current Bill List + total
  - Right: Calculator keypad
- Checkout page should use 2-column layout on tablets

✅ TODO:
- [ ] Use LayoutBuilder and breakpoints:
  - <600 width = phone layout
  - >=600 width = tablet layout
- [ ] Ensure buttons are not small in tablet mode
- [ ] Ensure typography scales smoothly

---

## 7) ✅ Accessibility + Elder-Friendly Requirements

✅ Must Have:
- Large buttons
- Clear labels
- Adjustable text size
- Contrast mode optional
- Avoid always-on high contrast
- Dark mode for night usage
- Simple navigation

✅ Optional Nice-to-have:
- Voice feedback toggle
- Large number keypad mode
- Bigger spacing mode

✅ TODO:
- [ ] Add "Text size slider"
- [ ] Add "Contrast toggle"
- [ ] Support screen readers (Semantics labels)

---

## 8) ✅ Database Design (Drift SQLite)

### Table: invoices
- invoice_id (PK auto int)
- invoice_no (string unique)  e.g. INV-20260125-001
- total_amount (double)
- discount_total (double)
- payment_mode (enum: CASH, UPI, CREDIT)
- payment_status (enum: PENDING, PARTIAL, FULFILLED)
- created_at (datetime)

### Table: invoice_items
- invoice_item_id (PK auto int)
- invoice_id (FK)
- item_name (string)
- quantity (double)
- rate (double)
- total (double)
- discount_amount (double)

✅ TODO:
- [ ] Setup drift_db.dart
- [ ] Implement migrations
- [ ] Create repository layer for invoice save/load

---

## 9) ✅ Serial Number Rules

Invoice number format:
- INV-YYYYMMDD-### 
Example: INV-20260126-001

Line item serial:
- ITEM-YYYYMMDD-### (optional)

✅ TODO:
- [ ] Create serial_number.dart helper
- [ ] Ensure invoice_no unique per day
- [ ] Handle reset counter each day

---

## 10) ✅ Business Logic Rules

### Calculator Entry
- Item total = qty × rate
- User presses + to add line item
- Item name can be:
  - "Item 1", "Item 2" (default)
  - Optional manual naming in checkout screen

### Checkout
- Final total = subtotal - discount
- Save invoice + invoice_items in DB
- Clear current bill after save

✅ TODO:
- [ ] Implement validation
- [ ] Prevent saving empty invoice

---

## 11) ✅ Export Specifications

### Export Excel
- File name: report_YYYYMMDD.xlsx
- Sheet columns:
  - Invoice No
  - Date
  - Payment Mode
  - Total
  - Discount
  - Item Count

### Export PDF
- Daily summary PDF:
  - Totals
  - List of invoices
- Invoice PDF:
  - Item list
  - total + payment info

✅ TODO:
- [ ] export_excel.dart
- [ ] export_pdf.dart
- [ ] Add export menu on Invoice List page
- [ ] Save files to Downloads folder (Android)

---

## 12) ✅ Navigation Flow

Splash -> Calculator Screen
Calculator:
- Checkout button -> Checkout Screen
Checkout:
- Confirm -> Save -> Return to Calculator
Invoice List:
- Tap invoice -> Invoice Detail
Settings accessible from header icon

✅ TODO:
- [ ] Setup go_router or Navigator 2.0
- [ ] Add bottom navigation OR drawer:
  - Calculator
  - Invoice List
  - Settings

---

## 13) ✅ Testing Checklist

✅ Manual Testing
- [ ] Calculator input works for decimals
- [ ] Add items quickly
- [ ] Checkout totals correct
- [ ] Save invoice and reopen app (data persists)
- [ ] Tablet landscape layout works properly
- [ ] Export PDF and Excel works
- [ ] Theme switching works instantly
- [ ] Text size slider updates app UI
- [ ] Language switching updates full UI
- [ ] Contrast toggle works, but not default

✅ Performance
- [ ] Opening Calculator should be instant
- [ ] Invoice list loads quickly even with 5000+ invoices

---

## 14) ✅ UI Design Rules Summary

- Use GREEN theme instead of blue
- Elder-friendly:
  - big font
  - big buttons
  - clean UI
- Not always high contrast
- Light mode + dark mode
- Responsive for tablet portrait + landscape
- Multi-language support with instant switching

---

✅ End of TODO
