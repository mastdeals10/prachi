# Prachiful App - ERP/CRM System

## Overview
A comprehensive Enterprise Resource Planning (ERP) and Customer Relationship Management (CRM) system focused on Astrology and Vastu products. Manages inventory, sales, finance, and customer interactions.

## Tech Stack
- **Frontend:** React 18 + TypeScript + Vite + Tailwind CSS
- **Backend/Database:** Supabase (PostgreSQL, Auth, Storage, Edge Functions)
- **Icons:** Lucide React

## Project Structure
- `src/components/` - Reusable UI components (modals, toasts, sidebar, header)
- `src/contexts/` - React Contexts (AuthContext, DateRangeContext)
- `src/lib/` - Utilities and Supabase client initialization
- `src/pages/` - Page components organized by module (sales, finance, etc.)
- `src/services/` - Business logic for Supabase API interactions
- `src/types/` - TypeScript interfaces
- `supabase/migrations/` - Database schema SQL scripts
- `supabase/functions/` - Edge Functions (Deno/TypeScript)
- `public/` - Static assets

## Environment Variables Required
- `VITE_SUPABASE_URL` - Supabase project URL
- `VITE_SUPABASE_ANON_KEY` - Supabase anonymous key

## Development
- Runs on port 5000 (`npm run dev`)
- Configured to allow all hosts for Replit proxy compatibility

## Key Modules
- **Inter-Godown Stock Transfer** (`src/pages/inventory/GodownTransfer.tsx`) — Transfer stock between godowns with full audit trail, stock movement logging, and document numbers (TRF-YYMM-####). Requires `godown_transfers` + `godown_transfer_items` tables (migration: `supabase/migrations/20260417000002_create_godown_transfers.sql`).
- **Enhanced Reports** (`src/pages/Reports.tsx`) — Six tabs: Sales Analysis, Profit & Loss, Stock Valuation, Buy vs Sell, Customer Aging, Outstanding Payables. All tabs have CSV export.
- **Invoice Edit Stock Rebalancing** — `handleEditSave` in `Invoices.tsx` now computes old-vs-new item quantity diffs and rebalances `godown_stock` + `products.stock_quantity` when an invoice is edited.

## Stock Architecture (Hybrid: Materialized Balance + Audit Ledger)
- **`godown_stock`** — current per-godown balance (materialized for O(1) reads).
- **`stock_movements`** — immutable audit ledger: every in/out logged with `reference_type` + `reference_id` (functions as the "stock_ledger" pattern).
- **`products.stock_quantity`** — cached total = SUM of `godown_stock` rows for the product.
- **Atomic posting via Postgres RPC `post_stock_movement`** (migration `20260417000004_post_stock_movement_rpc.sql`, TS wrapper `src/services/stockLedger.ts`): single transaction that (a) `FOR UPDATE` locks the godown_stock row to prevent races, (b) upserts the new clamped quantity, (c) inserts the stock_movements ledger row, (d) recomputes `products.stock_quantity` as SUM of all godown_stock rows. All-or-nothing — any failure rolls back all three writes.
- **Edit flow:** read old items → compute per-product/godown qty diff vs new items → apply delta to `godown_stock` → recompute totals (implemented in `Invoices.handleEditSave`).
- **Modules going through this pattern:** Purchase, Invoices (create + edit), Sales Returns, SO→Invoice conversion, Godown Transfer.
- **Integrity constraint:** `stock_movements` has a partial unique index on `(reference_type, reference_id, product_id, movement_type)` to prevent duplicate postings on retries (migration `20260417000003_stock_integrity_constraints.sql`).
- **`sales_order_items.godown_id`** column carries the per-line godown selection from SO into Invoice conversion (same migration).

## Deployment
- Static site deployment via `npm run build` → `dist/` directory
