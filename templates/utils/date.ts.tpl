/**
 * Date/Time Formatting Utilities Template
 * 
 * Shared formatting functions. Import these instead of defining them in every page.
 */

/**
 * Format a timestamp for display in timeline/list views.
 * Shows "今天 HH:MM", "昨天 HH:MM", or "M月D日 HH:MM".
 */
export function formatTime(timestamp: string): string {
  const d = new Date(timestamp);
  const now = new Date();
  const isToday = d.toDateString() === now.toDateString();
  const isYesterday = d.toDateString() === new Date(now.getTime() - 86400000).toDateString();
  const time = d.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });

  if (isToday) return `今天 ${time}`;
  if (isYesterday) return `昨天 ${time}`;
  return d.toLocaleDateString('zh-CN', { month: 'short', day: 'numeric' }) + ' ' + time;
}

/**
 * Format a date string (YYYY-MM-DD) for display.
 */
export function formatDate(dateStr: string | undefined | null): string {
  if (!dateStr) return '-';
  return new Date(dateStr).toLocaleDateString('zh-CN');
}

/**
 * Format duration in minutes to human-readable string.
 */
export function formatDuration(minutes: number | undefined | null): string {
  if (!minutes) return '-';
  if (minutes < 60) return `${minutes} 分钟`;
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;
  return mins > 0 ? `${hours} 小时 ${mins} 分钟` : `${hours} 小时`;
}

/**
 * Get relative time description (e.g., "3天前", "刚刚").
 */
export function getRelativeTime(timestamp: string): string {
  const now = Date.now();
  const then = new Date(timestamp).getTime();
  const diff = now - then;

  if (diff < 60000) return '刚刚';
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`;
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`;
  if (diff < 604800000) return `${Math.floor(diff / 86400000)}天前`;
  return formatDate(timestamp);
}

/**
 * Check if a warranty has expired.
 */
export function getWarrantyStatus(expiryDate: string | undefined | null): {
  label: string;
  color: string;
  expired: boolean;
} | null {
  if (!expiryDate) return null;
  const expiry = new Date(expiryDate);
  const now = new Date();
  const daysLeft = Math.ceil((expiry.getTime() - now.getTime()) / 86400000);

  if (daysLeft < 0) return { label: '已过期', color: 'text-red-600', expired: true };
  if (daysLeft < 30) return { label: `${daysLeft}天后到期`, color: 'text-amber-600', expired: false };
  return { label: `${daysLeft}天后到期`, color: 'text-green-600', expired: false };
}
