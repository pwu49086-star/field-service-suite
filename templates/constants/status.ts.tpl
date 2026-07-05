/**
 * Shared Constants Template
 * 
 * Centralized status labels, colors, and display constants.
 * Import these instead of defining them in every page component.
 * 
 * Follows: naming-rules.md, ui-rules.md
 */

// ─── Work Order Status ────────────────────────────────────────────

export const WORK_ORDER_STATUS_LABELS: Record<string, string> = {
  draft: '草稿',
  pending: '待处理',
  in_progress: '进行中',
  paused: '已暂停',
  pending_parts: '等配件',
  pending_quote: '等报价',
  pending_payment: '等收款',
  completed: '已完成',
  cancelled: '已取消',
};

export const WORK_ORDER_STATUS_COLORS: Record<string, string> = {
  draft: 'bg-gray-100 text-gray-700',
  pending: 'bg-amber-50 text-amber-700',
  in_progress: 'bg-blue-50 text-blue-700',
  paused: 'bg-orange-50 text-orange-700',
  pending_parts: 'bg-purple-50 text-purple-700',
  pending_quote: 'bg-yellow-50 text-yellow-700',
  pending_payment: 'bg-pink-50 text-pink-700',
  completed: 'bg-green-50 text-green-700',
  cancelled: 'bg-red-50 text-red-700',
};

// ─── Asset Status ─────────────────────────────────────────────────

export const ASSET_STATUS_LABELS: Record<string, string> = {
  registered: '待安装',
  active: '运行中',
  maintenance: '维护中',
  inactive: '已停用',
  scrapped: '已报废',
  transferred: '已转移',
};

export const ASSET_STATUS_COLORS: Record<string, string> = {
  registered: 'bg-gray-100 text-gray-700',
  active: 'bg-green-50 text-green-700',
  maintenance: 'bg-amber-50 text-amber-700',
  inactive: 'bg-gray-100 text-gray-600',
  scrapped: 'bg-red-50 text-red-700',
  transferred: 'bg-blue-50 text-blue-700',
};

// ─── Work Order Types ─────────────────────────────────────────────

export const WORK_ORDER_TYPE_LABELS: Record<string, string> = {
  installation: '安装',
  repair: '维修',
  maintenance: '保养',
  inspection: '巡检',
  quote_only: '报价',
  other: '其他',
};

// ─── Timeline Event Icons ─────────────────────────────────────────

export const TIMELINE_EVENT_ICONS: Record<string, string> = {
  installation: '🔧',
  repair: '🔩',
  maintenance: '🧹',
  inspection: '🔍',
  quote: '💰',
  payment: '✅',
  callback: '📞',
  transfer: '📦',
  scrap: '🗑️',
  note: '📝',
};

// ─── HVAC Specific ────────────────────────────────────────────────

export const HVAC_EQUIPMENT_TYPE_LABELS: Record<string, string> = {
  split: '分体机',
  window: '窗机',
  central: '中央空调',
  ducted: '风管机',
  vrf: '多联机',
  heat_pump: '热泵',
  chiller: '冷水机',
};

export const HVAC_INSTALLATION_LOCATION_LABELS: Record<string, string> = {
  '客厅': '客厅',
  '卧室': '卧室',
  '书房': '书房',
  '办公室': '办公室',
  '会议室': '会议室',
  '机房': '机房',
  '厂房': '厂房',
  '商铺': '商铺',
  'other': '其他',
};
