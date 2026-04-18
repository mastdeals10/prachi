/*
  # Add Ship-To Address Fields to sales_orders

  ## Summary
  Extends the existing B2B ship-to block with explicit address fields so that
  ship-to details can be entered manually (without requiring an existing customer
  in the CRM) or auto-filled from a selected customer.

  ## New Columns on `sales_orders`
  - `ship_to_name`     — Recipient / company name at the delivery address
  - `ship_to_address1` — Street / house / plot number
  - `ship_to_address2` — Area / landmark / colony (optional)
  - `ship_to_city`     — City
  - `ship_to_state`    — State
  - `ship_to_pin`      — PIN / postal code
  - `ship_to_phone`    — Contact number at the delivery address

  ## Changed Constraints
  - The existing `chk_b2b_ship_to_customer` constraint required `ship_to_customer_id`
    to be non-null whenever `is_b2b = true`. We DROP that constraint because manual-
    address B2B orders have no customer FK. The application layer enforces that at
    least one of (ship_to_customer_id OR ship_to_name) is present for B2B orders.

  ## Security
  - No RLS changes; existing policies already cover sales_orders.

  ## Notes
  - All new columns are nullable — existing rows are unaffected.
  - The old `ship_to_customer_id` FK column is kept as-is.
*/

/* Drop old constraint that forced ship_to_customer_id on every B2B order */
ALTER TABLE sales_orders DROP CONSTRAINT IF EXISTS chk_b2b_ship_to_customer;

/* Add explicit ship-to address columns */
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'sales_orders' AND column_name = 'ship_to_name'
  ) THEN
    ALTER TABLE sales_orders ADD COLUMN ship_to_name text;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'sales_orders' AND column_name = 'ship_to_address1'
  ) THEN
    ALTER TABLE sales_orders ADD COLUMN ship_to_address1 text;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'sales_orders' AND column_name = 'ship_to_address2'
  ) THEN
    ALTER TABLE sales_orders ADD COLUMN ship_to_address2 text;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'sales_orders' AND column_name = 'ship_to_city'
  ) THEN
    ALTER TABLE sales_orders ADD COLUMN ship_to_city text;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'sales_orders' AND column_name = 'ship_to_state'
  ) THEN
    ALTER TABLE sales_orders ADD COLUMN ship_to_state text;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'sales_orders' AND column_name = 'ship_to_pin'
  ) THEN
    ALTER TABLE sales_orders ADD COLUMN ship_to_pin text;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'sales_orders' AND column_name = 'ship_to_phone'
  ) THEN
    ALTER TABLE sales_orders ADD COLUMN ship_to_phone text;
  END IF;
END $$;
