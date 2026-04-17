import { supabase } from '../lib/supabase';

export interface PostStockMovementArgs {
  productId: string;
  godownId: string;
  qtyChange: number;
  movementType: string;
  referenceType: string;
  referenceId: string;
  referenceNumber?: string | null;
  notes?: string | null;
}

export async function postStockMovement(args: PostStockMovementArgs): Promise<void> {
  const { error } = await supabase.rpc('post_stock_movement', {
    p_product_id: args.productId,
    p_godown_id: args.godownId,
    p_qty_change: args.qtyChange,
    p_movement_type: args.movementType,
    p_reference_type: args.referenceType,
    p_reference_id: args.referenceId,
    p_reference_number: args.referenceNumber ?? null,
    p_notes: args.notes ?? null,
  });
  if (error) {
    throw new Error(`Stock posting failed: ${error.message}`);
  }
}
