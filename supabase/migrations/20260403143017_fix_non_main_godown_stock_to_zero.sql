
/*
  # Fix godown stock duplication

  ## Problem
  When syncing stock from products, the stock was copied to ALL godowns equally,
  causing each warehouse to show the same quantity as Main Warehouse.

  ## Fix
  - Zero out godown_stock for the two non-main warehouses (GOKUL NAGRI KOPARGAON and AURANGABAD HIGHWAY)
  - Main Warehouse stock remains correct (matches products.stock_quantity)

  ## Affected Godowns
  - GOKUL NAGRI KOPARGAON (id: 98b38ebe-020f-4af2-bbb4-b6f5e560567a) → set to 0
  - AURANGABAD HIGHWAY (id: 016b122d-14ca-4801-9cc5-fb98dd75bc3f) → set to 0
  - Main Warehouse (id: b719b338-75f2-4065-b225-e7b5d593e926) → unchanged
*/

UPDATE godown_stock
SET quantity = 0, updated_at = now()
WHERE godown_id IN (
  '98b38ebe-020f-4af2-bbb4-b6f5e560567a',
  '016b122d-14ca-4801-9cc5-fb98dd75bc3f'
);
