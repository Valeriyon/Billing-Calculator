# Billing Calculator

Billing Calculator is an offline-first Flutter POS application built for fast day-to-day billing at small stores and counters. The app focuses on a calculator-style entry flow, local invoice storage, inventory management, and accessibility-friendly controls for operators who need a simple and reliable billing experience.

## Project Overview

The app runs fully on-device using Flutter, Riverpod, and Drift. It stores invoices and inventory data in a local SQLite database, persists user preferences with SharedPreferences, and uses GoRouter for navigation between the main billing flow and supporting screens.

## Flow

1. The app starts in a splash screen and then opens the main billing calculator.
2. The cashier enters quantity and rate, then adds line items to the bill.
3. The bill summary shows the current items, subtotal, and quick access to checkout.
4. In checkout, the user reviews items, applies a discount, and saves the invoice.
5. The invoice is written to the local database together with its invoice items.
6. Invoice history can be viewed later, filtered by date or payment mode, and opened in detail.
7. Inventory items can be added, edited, searched, filtered, and linked to a barcode or image.
8. Settings let the user adjust theme, language, text size, contrast mode, and haptic feedback.

## Features

- Calculator-style billing screen for quick quantity and rate entry.
- Bill item list with swipe-to-delete and a compact checkout action.
- Invoice checkout with subtotal, discount, and total calculation.
- Local invoice persistence with automatic invoice number generation.
- Invoice history with detailed and consolidated views.
- Invoice filtering by date range and payment mode.
- Inventory management with add, edit, delete, search, sort, and filter support.
- Barcode capture, item images, category, brand, unit of measure, and unit value support in inventory forms.
- Multi-language support for English, Malayalam, Hindi, and Tamil.
- Light, dark, and high-contrast themes with adjustable text scaling.
- Haptic feedback preference for better accessibility.

## Dependencies

### Core App Packages

- `flutter`: UI framework.
- `flutter_riverpod` and `riverpod_annotation`: state management.
- `go_router`: declarative routing.
- `drift` and `sqlite3_flutter_libs`: local SQLite database layer.
- `shared_preferences`: persists user settings.
- `flutter_localizations` and `intl`: localization and date/number formatting.

### Supporting Packages

- `path_provider` and `path`: file and storage path handling.
- `image_picker`: selects item images from camera or gallery.
- `mobile_scanner`: barcode scanning in inventory forms.
- `audioplayers`: used for item form feedback and audio interactions.
- `pdf`, `printing`, `excel`, and `share_plus`: included for document export and sharing workflows.

## Database Schema

The app uses Drift with a single local SQLite database. Current schema version is `5`.

### `invoices`

Stores one row per invoice.

| Column | Type | Notes |
| --- | --- | --- |
| `id` | integer | Primary key, auto-increment |
| `invoiceNo` | text | Unique invoice number, for example `INV-20260405-001` |
| `subtotalAmount` | real | Total before discount |
| `discountAmount` | real | Applied discount |
| `totalAmount` | real | Final invoice total |
| `paymentMode` | enum/int | `cash`, `upi`, or `credit` |
| `paymentStatus` | enum/int | `pending`, `partial`, or `fulfilled` |
| `notes` | text nullable | Optional note field |
| `createdAt` | datetime | Creation timestamp |
| `updatedAt` | datetime | Last update timestamp |

### `invoice_items`

Stores line items for each invoice.

| Column | Type | Notes |
| --- | --- | --- |
| `id` | integer | Primary key, auto-increment |
| `invoiceId` | integer | Foreign key to `invoices.id` |
| `itemName` | text | Display name of the billed item |
| `quantity` | real | Quantity billed |
| `rate` | real | Unit rate |
| `total` | real | Line total |
| `discountAmount` | real | Item-level discount |
| `serialNo` | integer | Ordering within the invoice |
| `createdAt` | datetime | Creation timestamp |

### `inventory_items`

Stores the master product catalog used during billing.

| Column | Type | Notes |
| --- | --- | --- |
| `id` | integer | Primary key, auto-increment |
| `code` | text | Unique internal item code |
| `barcode` | text nullable | Optional scanned barcode |
| `name` | text | Item name |
| `category` | text | Category label |
| `brand` | text | Brand label |
| `price` | real | Selling price |
| `uom` | text | Unit of measurement, default `pcs` |
| `unitValue` | real | Quantity represented by the price unit |
| `imagePath` | text nullable | Local image path |
| `status` | enum/int | `available`, `outOfStock`, or `archived` |
| `createdAt` | datetime | Creation timestamp |

### `document_series_numbers`

Stores configurable number series used for generated document codes.

| Column | Type | Notes |
| --- | --- | --- |
| `id` | integer | Primary key, auto-increment |
| `module` | text | Unique module key such as `item` |
| `startingNumber` | integer | First number in the sequence |
| `currentNumber` | integer | Current sequence value |
| `prefix` | text nullable | Optional prefix |
| `suffix` | text nullable | Optional suffix |
| `pattern` | text | Format template, default `{prefix}-{current_number}` |
| `status` | integer | `1` active, `0` inactive |
| `createdAt` | datetime | Creation timestamp |
| `updatedAt` | datetime | Last update timestamp |

### Relationships

- `invoice_items.invoiceId` references `invoices.id`.
- `invoice_items` belongs to a single invoice.
- `inventory_items.code` is unique and used as the internal item identifier.
- `document_series_numbers` currently seeds the `item` series for inventory code generation.

## Notes

- Invoice numbers are generated in the format `INV-YYYYMMDD-###`.
- The current codebase includes placeholders for print and share actions in the UI.
- The app is designed to work offline and keeps data stored locally on the device.
