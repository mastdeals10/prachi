
/*
  # Fix PO Cancel + Renumber All Documents to Correct Sequence

  ## Changes
  1. Add 'cancelled' to purchase_entries status constraint
  2. Renumber old PE-YYMM-NNNN purchase entries to PO/2604/001..007
  3. Shift existing PO/2604/001 and PO/2604/002 to 008 and 009
  4. Fix bad SO number SO-2604-1907 -> SO/2604/013
  5. Fix bad DC/2603/001 -> DC/2604/015
  6. Reset document_sequences to match actual max
*/

-- 1. Fix purchase_entries status constraint
ALTER TABLE purchase_entries DROP CONSTRAINT IF EXISTS purchase_entries_status_check;
ALTER TABLE purchase_entries ADD CONSTRAINT purchase_entries_status_check
  CHECK (status = ANY (ARRAY['unpaid','partial','paid','cancelled']));

-- 2. Drop unique constraint temporarily
ALTER TABLE purchase_entries DROP CONSTRAINT IF EXISTS purchase_entries_entry_number_key;

-- 3. Move existing PO/2604/001 and PO/2604/002 out of the way first
UPDATE purchase_entries SET entry_number = '__PO_008__' WHERE entry_number = 'PO/2604/001';
UPDATE purchase_entries SET entry_number = '__PO_009__' WHERE entry_number = 'PO/2604/002';

-- 4. Renumber old PE-* entries to PO/2604/001..007
DO $$
DECLARE
  rec RECORD;
  seq INT := 1;
BEGIN
  FOR rec IN 
    SELECT id FROM purchase_entries 
    WHERE entry_number LIKE 'PE-%'
    ORDER BY created_at
  LOOP
    UPDATE purchase_entries 
    SET entry_number = 'PO/2604/' || lpad(seq::text, 3, '0')
    WHERE id = rec.id;
    seq := seq + 1;
  END LOOP;
END $$;

-- 5. Rename placeholder entries to final numbers
UPDATE purchase_entries SET entry_number = 'PO/2604/008' WHERE entry_number = '__PO_008__';
UPDATE purchase_entries SET entry_number = 'PO/2604/009' WHERE entry_number = '__PO_009__';

-- 6. Restore unique constraint
ALTER TABLE purchase_entries ADD CONSTRAINT purchase_entries_entry_number_key UNIQUE (entry_number);

-- 7. Fix bad SO number
UPDATE sales_orders SET so_number = 'SO/2604/013' WHERE so_number = 'SO-2604-1907';

-- 8. Fix DC/2603/001 wrong period
UPDATE delivery_challans SET challan_number = 'DC/2604/015' WHERE challan_number = 'DC/2603/001';

-- 9. Reset document_sequences to match actual maximums
DELETE FROM document_sequences WHERE prefix IN ('SO','DC','INV','PO');
INSERT INTO document_sequences (prefix, year_month, last_seq) VALUES
  ('SO',  '2603', 1),
  ('SO',  '2604', 15),
  ('DC',  '2604', 15),
  ('INV', '2603', 1),
  ('INV', '2604', 10),
  ('PO',  '2604', 9);
