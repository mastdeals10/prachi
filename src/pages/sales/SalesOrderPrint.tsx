import { formatCurrency, formatDate, numberToWords } from '../../lib/utils';
import { useCompanySettings } from '../../lib/useCompanySettings';
import type { SalesOrder, SalesOrderItem } from '../../types';
import type { Company } from '../../lib/companiesService';

function joinAddr(parts: (string | undefined | null)[]) { return parts.filter(Boolean).join(', '); }

interface SalesOrderPrintProps {
  order: SalesOrder;
  items: SalesOrderItem[];
  companyOverride?: Company;
}

export default function SalesOrderPrint({ order, items, companyOverride }: SalesOrderPrintProps) {
  const { company: defaultCompany } = useCompanySettings();

  const co = companyOverride ? {
    name: companyOverride.name, tagline: companyOverride.tagline || '',
    address1: companyOverride.address1 || '', address2: companyOverride.address2 || '',
    city: companyOverride.city || '', state: companyOverride.state || '',
    pincode: companyOverride.pincode || '', phone: companyOverride.phone || '',
    email: companyOverride.email || '', gstin: companyOverride.gstin || '',
    pan: companyOverride.pan || '', logo_url: companyOverride.logo_url || '',
    footer_note: companyOverride.footer_note || '',
  } : { ...defaultCompany, logo_url: '' };

  const companyAddr = joinAddr([co.address1, co.address2, co.city, co.state, co.pincode]);
  const customerAddr = joinAddr([
    order.customer_address, order.customer_address2,
    order.customer_city, order.customer_state, order.customer_pincode,
  ]);

  const subtotal = items.reduce((s, i) => s + i.total_price, 0);
  const total = order.total_amount;
  const hasDiscount = items.some(i => (i.discount_pct || 0) > 0);

  return (
    <div className="bg-white p-8 max-w-[800px] mx-auto text-neutral-900 font-sans print:p-6">
      {/* Header */}
      <div className="border-b-2 border-primary-600 pb-5 mb-5">
        <div className="flex items-start justify-between">
          <div className="flex items-start gap-3">
            {co.logo_url && <img src={co.logo_url} alt={co.name} className="h-14 w-auto object-contain" />}
            <div>
              <h1 className="text-2xl font-bold text-primary-700 tracking-wide">{co.name.toUpperCase()}</h1>
              {co.tagline && <p className="text-sm text-neutral-600 mt-0.5 font-medium">{co.tagline}</p>}
              {companyAddr && <p className="text-xs text-neutral-500 mt-1">{companyAddr}</p>}
              <div className="flex flex-wrap gap-3 mt-1">
                {co.phone && <p className="text-xs text-neutral-500">{co.phone}</p>}
                {co.email && <p className="text-xs text-neutral-500">{co.email}</p>}
                {co.gstin && <p className="text-xs text-neutral-500">GSTIN: {co.gstin}</p>}
              </div>
            </div>
          </div>
          <div className="text-right">
            <p className="text-2xl font-bold text-neutral-700 uppercase tracking-widest">PROFORMA</p>
            <p className="text-[11px] text-neutral-500 uppercase tracking-wider mt-0.5">Sales Order</p>
            <p className="text-sm font-semibold text-primary-600 mt-1">#{order.so_number}</p>
            <p className="text-xs text-neutral-500 mt-0.5">Date: {formatDate(order.so_date)}</p>
            {order.delivery_date && <p className="text-xs text-neutral-500">Expected: {formatDate(order.delivery_date)}</p>}
          </div>
        </div>
      </div>

      {/* From / To */}
      <div className="grid grid-cols-2 gap-6 mb-6">
        <div>
          <p className="text-[10px] font-bold text-neutral-400 uppercase tracking-widest mb-2">From</p>
          <div className="bg-neutral-50 rounded-lg p-3">
            <p className="font-semibold text-neutral-900">{co.name}</p>
            {co.tagline && <p className="text-xs text-neutral-600 mt-1">{co.tagline}</p>}
            {companyAddr && <p className="text-xs text-neutral-500 mt-0.5">{companyAddr}</p>}
            {co.phone && <p className="text-xs text-neutral-500">{co.phone}</p>}
          </div>
        </div>
        <div>
          <p className="text-[10px] font-bold text-neutral-400 uppercase tracking-widest mb-2">Bill To</p>
          <div className="bg-primary-50 rounded-lg p-3">
            <p className="font-semibold text-neutral-900">{order.customer_name}</p>
            {order.customer_phone && <p className="text-xs text-neutral-600 mt-1">{order.customer_phone}</p>}
            {customerAddr && <p className="text-xs text-neutral-500 mt-0.5">{customerAddr}</p>}
          </div>
        </div>
      </div>

      {/* Items table */}
      <div className="mb-5">
        <table className="w-full border-collapse">
          <thead>
            <tr className="bg-neutral-800 text-white">
              <th className="px-3 py-2 text-left text-xs font-semibold w-8">#</th>
              <th className="px-3 py-2 text-left text-xs font-semibold">Item</th>
              <th className="px-3 py-2 text-center text-xs font-semibold w-14">Unit</th>
              <th className="px-3 py-2 text-right text-xs font-semibold w-16">Qty</th>
              <th className="px-3 py-2 text-right text-xs font-semibold w-24">Rate</th>
              {hasDiscount && <th className="px-3 py-2 text-right text-xs font-semibold w-16">Disc%</th>}
              <th className="px-3 py-2 text-right text-xs font-semibold w-24">Amount</th>
            </tr>
          </thead>
          <tbody>
            {items.map((item, idx) => (
              <tr key={item.id || idx} className={idx % 2 === 0 ? 'bg-white' : 'bg-neutral-50'}>
                <td className="px-3 py-2.5 text-xs text-neutral-500 border-b border-neutral-100">{idx + 1}</td>
                <td className="px-3 py-2.5 border-b border-neutral-100">
                  <p className="text-sm font-medium text-neutral-900">{item.product_name}</p>
                </td>
                <td className="px-3 py-2.5 text-xs text-center text-neutral-600 border-b border-neutral-100">{item.unit}</td>
                <td className="px-3 py-2.5 text-xs text-right text-neutral-700 border-b border-neutral-100">{item.quantity}</td>
                <td className="px-3 py-2.5 text-xs text-right text-neutral-700 border-b border-neutral-100">{formatCurrency(item.unit_price)}</td>
                {hasDiscount && <td className="px-3 py-2.5 text-xs text-right text-neutral-500 border-b border-neutral-100">{(item.discount_pct || 0) > 0 ? `${item.discount_pct}%` : '—'}</td>}
                <td className="px-3 py-2.5 text-sm text-right font-medium text-neutral-900 border-b border-neutral-100">{formatCurrency(item.total_price)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Totals */}
      <div className="flex justify-end mb-5">
        <div className="w-60 space-y-1">
          <div className="flex justify-between text-sm text-neutral-600"><span>Subtotal</span><span>{formatCurrency(subtotal)}</span></div>
          {(order.courier_charges || 0) > 0 && <div className="flex justify-between text-sm text-neutral-600"><span>Courier</span><span>{formatCurrency(order.courier_charges || 0)}</span></div>}
          {(order.discount_amount || 0) > 0 && <div className="flex justify-between text-sm text-success-600"><span>Discount</span><span>−{formatCurrency(order.discount_amount || 0)}</span></div>}
          <div className="flex justify-between text-base font-bold bg-primary-600 text-white px-3 py-2 rounded-lg mt-1"><span>Total</span><span>{formatCurrency(total)}</span></div>
        </div>
      </div>

      {/* Amount in words */}
      <div className="bg-accent-50 border border-accent-200 rounded-lg px-4 py-2 mb-5">
        <p className="text-xs text-accent-700 font-medium">
          <span className="font-bold">Amount in Words: </span>{numberToWords(total)}
        </p>
      </div>

      {/* Signature blocks */}
      <div className="grid grid-cols-2 gap-5">
        <div className="border border-neutral-200 rounded-lg p-3">
          <p className="text-[10px] font-bold text-neutral-400 uppercase tracking-widest mb-6">Customer Acceptance</p>
          <div className="border-t border-neutral-300 pt-2">
            <p className="text-xs text-neutral-500">Signature, Name & Date</p>
          </div>
        </div>
        <div className="border border-neutral-200 rounded-lg p-3">
          <p className="text-[10px] font-bold text-neutral-400 uppercase tracking-widest mb-6">Authorized Signature</p>
          <div className="border-t border-neutral-300 pt-2">
            <p className="text-xs font-semibold text-neutral-700">{co.name}</p>
            {co.tagline && <p className="text-[10px] text-neutral-400">{co.tagline}</p>}
          </div>
        </div>
      </div>

      {order.notes && <div className="mt-4 text-xs text-neutral-500 border-t border-neutral-100 pt-3"><span className="font-medium text-neutral-700">Notes: </span>{order.notes}</div>}
      <div className="mt-4 text-center text-[10px] text-neutral-400 border-t border-neutral-100 pt-3 italic">
        This is a Proforma / Sales Order and not a final tax invoice.
        {co.footer_note && ' ' + co.footer_note}
      </div>
    </div>
  );
}
