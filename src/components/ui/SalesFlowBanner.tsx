import { FileText, Receipt, Truck, Package, IndianRupee, ArrowRight } from 'lucide-react';
import type { ActivePage } from '../../types';

interface SalesFlowBannerProps {
  onNavigate?: (page: ActivePage) => void;
  counts?: {
    salesOrders?: number;
    challans?: number;
    invoices?: number;
    dispatches?: number;
    pendingPayment?: number;
  };
}

interface StepProps {
  icon: React.ComponentType<{ className?: string }>;
  label: string;
  count?: number;
  page?: ActivePage;
  onNavigate?: (page: ActivePage) => void;
  color: string;
  bgColor: string;
  isLast?: boolean;
}

function FlowStep({ icon: Icon, label, count, page, onNavigate, color, bgColor, isLast }: StepProps) {
  const content = (
    <div className={`flex items-center gap-2 px-3 py-2 rounded-lg border transition-all ${bgColor} ${page && onNavigate ? 'cursor-pointer hover:shadow-sm hover:scale-105' : ''}`}>
      <div className={`w-6 h-6 rounded-md flex items-center justify-center shrink-0 ${color}`}>
        <Icon className="w-3.5 h-3.5" />
      </div>
      <div>
        <p className="text-[10px] font-semibold text-neutral-500 leading-none">{label}</p>
        {count !== undefined && (
          <p className="text-sm font-bold text-neutral-800 leading-tight">{count}</p>
        )}
      </div>
    </div>
  );

  return (
    <div className="flex items-center gap-1">
      {page && onNavigate ? (
        <button onClick={() => onNavigate(page)} className="outline-none">{content}</button>
      ) : content}
      {!isLast && <ArrowRight className="w-3.5 h-3.5 text-neutral-300 shrink-0" />}
    </div>
  );
}

export default function SalesFlowBanner({ onNavigate, counts }: SalesFlowBannerProps) {
  const steps: StepProps[] = [
    {
      icon: FileText,
      label: 'Sales Orders',
      count: counts?.salesOrders,
      page: 'sales-orders',
      onNavigate,
      color: 'bg-blue-100 text-blue-700',
      bgColor: 'bg-blue-50 border-blue-100',
    },
    {
      icon: Truck,
      label: 'Delivery Challans',
      count: counts?.challans,
      page: 'challans',
      onNavigate,
      color: 'bg-orange-100 text-orange-700',
      bgColor: 'bg-orange-50 border-orange-100',
    },
    {
      icon: Receipt,
      label: 'Invoices',
      count: counts?.invoices,
      page: 'invoices',
      onNavigate,
      color: 'bg-green-100 text-green-700',
      bgColor: 'bg-green-50 border-green-100',
    },
    {
      icon: Package,
      label: 'Dispatched',
      count: counts?.dispatches,
      page: 'courier',
      onNavigate,
      color: 'bg-teal-100 text-teal-700',
      bgColor: 'bg-teal-50 border-teal-100',
    },
    {
      icon: IndianRupee,
      label: 'Pending Payment',
      count: counts?.pendingPayment,
      page: 'invoices',
      onNavigate,
      color: 'bg-error-50 text-error-700',
      bgColor: 'bg-error-50 border-error-100',
      isLast: true,
    },
  ];

  return (
    <div className="bg-white border border-neutral-100 rounded-xl px-4 py-3">
      <p className="text-[9px] font-bold text-neutral-400 uppercase tracking-widest mb-2">Sales Flow</p>
      <div className="flex items-center gap-1 flex-wrap">
        {steps.map((step, i) => (
          <FlowStep key={i} {...step} isLast={i === steps.length - 1} />
        ))}
      </div>
    </div>
  );
}
