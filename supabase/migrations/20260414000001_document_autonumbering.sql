-- Document number sequences (atomic, collision-free)
CREATE TABLE IF NOT EXISTS document_sequences (
  prefix text NOT NULL, year_month text NOT NULL, last_seq int NOT NULL DEFAULT 0,
  PRIMARY KEY (prefix, year_month)
);
ALTER TABLE document_sequences ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated use sequences" ON document_sequences FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
CREATE OR REPLACE FUNCTION next_document_number(p_prefix text) RETURNS text
LANGUAGE plpgsql SECURITY DEFINER SET search_path = 'public' AS $$
DECLARE v_ym text := to_char(now() AT TIME ZONE 'Asia/Kolkata', 'YYMM'); v_seq int;
BEGIN
  INSERT INTO document_sequences (prefix, year_month, last_seq) VALUES (p_prefix, v_ym, 1)
  ON CONFLICT (prefix, year_month) DO UPDATE SET last_seq = document_sequences.last_seq + 1
  RETURNING last_seq INTO v_seq;
  RETURN p_prefix || '-' || v_ym || '-' || lpad(v_seq::text, 4, '0');
END; $$;
