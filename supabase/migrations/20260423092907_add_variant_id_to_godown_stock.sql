/*
  # Add variant_id to godown_stock

  ## Purpose
  Enables per-godown, per-variant stock tracking for "variant" type products.

  ## Changes
  1. Modified Tables
    - `godown_stock`
      - Add `variant_id uuid` (nullable FK → product_variants.id, ON DELETE CASCADE)
      - Add unique constraint: (godown_id, product_id, variant_id) — variant_id may be NULL
        (use a partial unique index for NULL-safe uniqueness)

  ## Notes
  - Existing rows (non-variant products) are unaffected; variant_id stays NULL for them.
  - A new unique index handles both NULL (simple products) and non-NULL (variant products)
    since standard UNIQUE constraints treat NULLs as distinct.
  - The existing (godown_id, product_id) unique index must be replaced by the new partial
    index to avoid conflicts.
*/

-- Add variant_id column (nullable, FK to product_variants)
ALTER TABLE godown_stock
  ADD COLUMN IF NOT EXISTS variant_id uuid REFERENCES product_variants(id) ON DELETE CASCADE;

-- Partial unique index: for non-variant rows (variant_id IS NULL)
-- Standard unique constraint already covers (godown_id, product_id) for non-variant rows
-- but we need to relax it. Drop the old constraint if it exists and recreate as partial.

DO $$
BEGIN
  -- Try to drop the old unique constraint on (godown_id, product_id) if it exists
  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'godown_stock'
      AND constraint_type = 'UNIQUE'
      AND constraint_name = 'godown_stock_godown_id_product_id_key'
  ) THEN
    ALTER TABLE godown_stock DROP CONSTRAINT godown_stock_godown_id_product_id_key;
  END IF;
END $$;

-- Partial unique index for simple products (variant_id IS NULL)
CREATE UNIQUE INDEX IF NOT EXISTS godown_stock_product_godown_no_variant_idx
  ON godown_stock (godown_id, product_id)
  WHERE variant_id IS NULL;

-- Partial unique index for variant products (variant_id IS NOT NULL)
CREATE UNIQUE INDEX IF NOT EXISTS godown_stock_product_godown_variant_idx
  ON godown_stock (godown_id, product_id, variant_id)
  WHERE variant_id IS NOT NULL;
