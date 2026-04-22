/*
  # Add product_unit_ids column to sales_order_items

  1. Modified Tables
    - `sales_order_items`
      - Add `product_unit_ids` (uuid[], default empty array) — stores the IDs of specific
        product_units selected for gemstone line items

  2. Notes
    - For non-gemstone items this will remain an empty array
    - For gemstone items this contains the UUIDs of the pieces sold on this line
    - Quantity for gemstone items = array_length(product_unit_ids, 1)
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'sales_order_items' AND column_name = 'product_unit_ids'
  ) THEN
    ALTER TABLE sales_order_items ADD COLUMN product_unit_ids uuid[] DEFAULT '{}';
  END IF;
END $$;
