-- Add delivery_challan_id to courier_entries (shipments linked to DC)
ALTER TABLE courier_entries ADD COLUMN IF NOT EXISTS delivery_challan_id uuid REFERENCES delivery_challans(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_courier_entries_dc ON courier_entries(delivery_challan_id);
-- Add godown_id per line item to sales_order_items, invoice_items, delivery_challan_items
ALTER TABLE sales_order_items ADD COLUMN IF NOT EXISTS godown_id uuid REFERENCES godowns(id) ON DELETE SET NULL;
ALTER TABLE invoice_items ADD COLUMN IF NOT EXISTS godown_id uuid REFERENCES godowns(id) ON DELETE SET NULL;
ALTER TABLE delivery_challan_items ADD COLUMN IF NOT EXISTS godown_id uuid REFERENCES godowns(id) ON DELETE SET NULL;
