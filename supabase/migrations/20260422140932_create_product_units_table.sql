/*
  # Create product_units table for gemstone piece tracking

  1. New Tables
    - `product_units`
      - `id` (uuid, primary key)
      - `product_id` (uuid, FK to products) — which gemstone product this piece belongs to
      - `weight` (numeric) — individual piece weight
      - `weight_unit` (text) — 'g', 'kg', or 'carat'
      - `status` (text) — 'in_stock' or 'sold'
      - `godown_id` (uuid, nullable FK to godowns) — where this piece is stored
      - `created_at` (timestamptz)
      - `sold_at` (timestamptz, nullable) — when the piece was sold
      - `sold_reference_type` (text, nullable) — e.g. 'sales_order', 'manual_stock_update'
      - `sold_reference_id` (text, nullable) — ID of the referencing document

  2. Security
    - Enable RLS
    - Authenticated users can read all product_units
    - Authenticated users can insert product_units
    - Authenticated users can update product_units (to mark sold/in_stock)

  3. Notes
    - Only products with is_gemstone = true should have rows here
    - Stock count for gemstones = COUNT(*) WHERE status = 'in_stock'
    - Non-gemstone products continue using godown_stock quantity-based tracking
*/

CREATE TABLE IF NOT EXISTS product_units (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  weight numeric NOT NULL CHECK (weight > 0),
  weight_unit text NOT NULL DEFAULT 'g' CHECK (weight_unit IN ('g', 'kg', 'carat')),
  status text NOT NULL DEFAULT 'in_stock' CHECK (status IN ('in_stock', 'sold')),
  godown_id uuid REFERENCES godowns(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now(),
  sold_at timestamptz,
  sold_reference_type text,
  sold_reference_id text
);

CREATE INDEX IF NOT EXISTS idx_product_units_product_id ON product_units(product_id);
CREATE INDEX IF NOT EXISTS idx_product_units_status ON product_units(status);
CREATE INDEX IF NOT EXISTS idx_product_units_godown_id ON product_units(godown_id);
CREATE INDEX IF NOT EXISTS idx_product_units_product_status ON product_units(product_id, status);

ALTER TABLE product_units ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read product_units"
  ON product_units FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert product_units"
  ON product_units FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update product_units"
  ON product_units FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete product_units"
  ON product_units FOR DELETE
  TO authenticated
  USING (true);
