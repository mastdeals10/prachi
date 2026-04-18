/*
  # PO Delivery Tracking & B2B Drop Shipment

  ## Feature 1: Purchase Order Delivery Tracking
  Extends the existing purchase_entries table with delivery tracking fields.

  ## Feature 2: B2B Drop Shipment Tables
  Creates drop_shipments and drop_shipment_items tables if not exist,
  with RLS and indexes.
*/

-- ============================================================
-- FEATURE 1: Delivery Tracking on purchase_entries
-- ============================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'purchase_entries' AND column_name = 'expected_delivery_date'
  ) THEN
    ALTER TABLE purchase_entries ADD COLUMN expected_delivery_date date;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'purchase_entries' AND column_name = 'delivery_status'
  ) THEN
    ALTER TABLE purchase_entries
      ADD COLUMN delivery_status text NOT NULL DEFAULT 'Pending'
        CHECK (delivery_status IN ('Pending', 'In Transit', 'Delivered', 'Delayed'));
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'purchase_entries' AND column_name = 'received_qty'
  ) THEN
    ALTER TABLE purchase_entries ADD COLUMN received_qty numeric(12,3) NOT NULL DEFAULT 0;
  END IF;
END $$;

-- ============================================================
-- FEATURE 2: B2B Drop Shipments
-- ============================================================

CREATE TABLE IF NOT EXISTS drop_shipments (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ds_number             text UNIQUE NOT NULL,
  supplier_id           uuid REFERENCES suppliers(id),
  supplier_name         text NOT NULL DEFAULT '',
  customer_id           uuid REFERENCES customers(id),
  customer_name         text NOT NULL DEFAULT '',
  customer_phone        text DEFAULT '',
  customer_address      text DEFAULT '',
  customer_city         text DEFAULT '',
  customer_state        text DEFAULT '',
  customer_pincode      text DEFAULT '',
  ds_date               date NOT NULL DEFAULT CURRENT_DATE,
  expected_delivery_date date,
  status                text NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft', 'confirmed', 'supplier_dispatched', 'delivered', 'invoiced', 'cancelled')),
  supplier_invoice_number text DEFAULT '',
  tracking_number       text DEFAULT '',
  courier_company       text DEFAULT '',
  subtotal              numeric(12,2) NOT NULL DEFAULT 0,
  tax_amount            numeric(12,2) NOT NULL DEFAULT 0,
  total_amount          numeric(12,2) NOT NULL DEFAULT 0,
  notes                 text DEFAULT '',
  company_id            uuid REFERENCES companies(id),
  created_at            timestamptz DEFAULT now(),
  updated_at            timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS drop_shipment_items (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  drop_shipment_id  uuid NOT NULL REFERENCES drop_shipments(id) ON DELETE CASCADE,
  product_id        uuid REFERENCES products(id),
  product_name      text NOT NULL,
  unit              text DEFAULT 'pcs',
  quantity          numeric(12,3) NOT NULL DEFAULT 0,
  unit_price        numeric(12,2) NOT NULL DEFAULT 0,
  total_price       numeric(12,2) NOT NULL DEFAULT 0,
  created_at        timestamptz DEFAULT now()
);

ALTER TABLE drop_shipments ENABLE ROW LEVEL SECURITY;
ALTER TABLE drop_shipment_items ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'drop_shipments' AND policyname = 'Authenticated users can view drop shipments'
  ) THEN
    CREATE POLICY "Authenticated users can view drop shipments"
      ON drop_shipments FOR SELECT TO authenticated
      USING (auth.uid() IS NOT NULL);
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'drop_shipments' AND policyname = 'Authenticated users can insert drop shipments'
  ) THEN
    CREATE POLICY "Authenticated users can insert drop shipments"
      ON drop_shipments FOR INSERT TO authenticated
      WITH CHECK (auth.uid() IS NOT NULL);
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'drop_shipments' AND policyname = 'Authenticated users can update drop shipments'
  ) THEN
    CREATE POLICY "Authenticated users can update drop shipments"
      ON drop_shipments FOR UPDATE TO authenticated
      USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'drop_shipments' AND policyname = 'Authenticated users can delete drop shipments'
  ) THEN
    CREATE POLICY "Authenticated users can delete drop shipments"
      ON drop_shipments FOR DELETE TO authenticated
      USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'drop_shipment_items' AND policyname = 'Authenticated users can view drop shipment items'
  ) THEN
    CREATE POLICY "Authenticated users can view drop shipment items"
      ON drop_shipment_items FOR SELECT TO authenticated
      USING (auth.uid() IS NOT NULL);
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'drop_shipment_items' AND policyname = 'Authenticated users can insert drop shipment items'
  ) THEN
    CREATE POLICY "Authenticated users can insert drop shipment items"
      ON drop_shipment_items FOR INSERT TO authenticated
      WITH CHECK (auth.uid() IS NOT NULL);
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'drop_shipment_items' AND policyname = 'Authenticated users can update drop shipment items'
  ) THEN
    CREATE POLICY "Authenticated users can update drop shipment items"
      ON drop_shipment_items FOR UPDATE TO authenticated
      USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'drop_shipment_items' AND policyname = 'Authenticated users can delete drop shipment items'
  ) THEN
    CREATE POLICY "Authenticated users can delete drop shipment items"
      ON drop_shipment_items FOR DELETE TO authenticated
      USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_drop_shipments_supplier ON drop_shipments(supplier_id);
CREATE INDEX IF NOT EXISTS idx_drop_shipments_customer ON drop_shipments(customer_id);
CREATE INDEX IF NOT EXISTS idx_drop_shipments_status ON drop_shipments(status);
CREATE INDEX IF NOT EXISTS idx_drop_shipment_items_ds ON drop_shipment_items(drop_shipment_id);
CREATE INDEX IF NOT EXISTS idx_purchase_entries_delivery_status ON purchase_entries(delivery_status);
CREATE INDEX IF NOT EXISTS idx_purchase_entries_expected_delivery ON purchase_entries(expected_delivery_date);
