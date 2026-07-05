/**
 * Timeline Utilities Template
 * 
 * Date grouping, stats computation, event subtitle generation.
 * Import these instead of implementing them in every timeline page.
 */

import type { TimelineEvent, TimelineEventType } from '../types';

// ─── Date Grouping ───────────────────────────────────────────────

export interface EventGroup {
  label: string;
  date: string;
  events: TimelineEvent[];
}

/**
 * Group timeline events by date for display.
 * Returns groups with labels like "今天", "昨天", "周一", "6月15日", "2025年12月1日".
 */
export function groupEventsByDate(events: TimelineEvent[]): EventGroup[] {
  const groups = new Map<string, TimelineEvent[]>();
  const now = new Date();
  const today = now.toDateString();
  const yesterday = new Date(now.getTime() - 86400000).toDateString();
  const weekAgo = new Date(now.getTime() - 7 * 86400000);

  for (const event of events) {
    const d = new Date(event.timestamp);
    const dateKey = d.toDateString();
    let label: string;

    if (dateKey === today) {
      label = '今天';
    } else if (dateKey === yesterday) {
      label = '昨天';
    } else if (d > weekAgo) {
      label = d.toLocaleDateString('zh-CN', { weekday: 'long' });
    } else if (d.getFullYear() === now.getFullYear()) {
      label = d.toLocaleDateString('zh-CN', { month: 'long', day: 'numeric' });
    } else {
      label = d.toLocaleDateString('zh-CN', { year: 'numeric', month: 'long', day: 'numeric' });
    }

    if (!groups.has(label)) {
      groups.set(label, []);
    }
    groups.get(label)!.push(event);
  }

  return Array.from(groups.entries()).map(([label, evts]) => ({
    label,
    date: evts[0].timestamp,
    events: evts,
  }));
}

// ─── Stats ───────────────────────────────────────────────────────

export interface TimelineStats {
  byType: Record<string, number>;
  totalCount: number;
  totalSpending: number;
  firstEventDate: string | null;
  lastEventDate: string | null;
}

/**
 * Compute statistics from a list of timeline events.
 */
export function computeTimelineStats(events: TimelineEvent[]): TimelineStats {
  const byType: Record<string, number> = {};
  let totalSpending = 0;

  for (const event of events) {
    byType[event.type] = (byType[event.type] || 0) + 1;
    if (event.totalAmount) totalSpending += event.totalAmount;
  }

  const sorted = [...events].sort((a, b) =>
    new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime()
  );

  return {
    byType,
    totalCount: events.length,
    totalSpending,
    firstEventDate: sorted[0]?.timestamp ?? null,
    lastEventDate: sorted[sorted.length - 1]?.timestamp ?? null,
  };
}

// ─── Event Subtitle ──────────────────────────────────────────────

/**
 * Generate a subtitle string for a timeline event card.
 * Shows relevant metadata like technician, parts count, amount.
 */
export function getEventSubtitle(event: TimelineEvent, options?: {
  technicianNames?: Map<string, string>;
}): string {
  const parts: string[] = [];

  if (event.technicianId) {
    const name = options?.technicianNames?.get(event.technicianId);
    parts.push(name ? `技师: ${name}` : `技师: ${event.technicianId}`);
  }

  if (event.partsUsed?.length) {
    parts.push(`${event.partsUsed.length} 个配件`);
  }

  if (event.totalAmount) {
    parts.push(`¥${event.totalAmount}`);
  }

  if (event.attachmentIds?.length) {
    parts.push(`${event.attachmentIds.length} 张照片`);
  }

  return parts.join(' · ');
}

// ─── Filtering ───────────────────────────────────────────────────

/**
 * Filter events by type.
 */
export function filterEventsByType(
  events: TimelineEvent[],
  type: TimelineEventType | 'all'
): TimelineEvent[] {
  if (type === 'all') return events;
  return events.filter(e => e.type === type);
}

/**
 * Filter events by date range.
 */
export function filterEventsByDateRange(
  events: TimelineEvent[],
  startDate: Date,
  endDate: Date
): TimelineEvent[] {
  return events.filter(e => {
    const d = new Date(e.timestamp);
    return d >= startDate && d <= endDate;
  });
}
