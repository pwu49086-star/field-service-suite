/**
 * Timeline Service Template
 * 
 * Follows: timeline-rules.md
 * Unified event timeline for all asset activities.
 */

import { db } from '@/db/database';
import type { TimelineEvent, PartsUsage } from '@/db/database';

export class TimelineService {
  /**
   * Create a new timeline event
   */
  async create(data: Omit<TimelineEvent, 'id' | 'createdAt'>): Promise<TimelineEvent> {
    const event: TimelineEvent = {
      ...data,
      id: crypto.randomUUID(),
      createdAt: new Date().toISOString(),
    };

    await db.timelineEvents.add(event);
    await db.syncQueue.add({
      entityType: 'timeline_event',
      entityId: event.id,
      action: 'create',
      data: event,
      timestamp: Date.now(),
      retryCount: 0,
      status: 'pending',
    });

    // Update asset's lastServiceDate if it's a service event
    const serviceTypes = ['installation', 'repair', 'maintenance', 'inspection'];
    if (serviceTypes.includes(event.type)) {
      await db.assets.update(event.assetId, {
        lastServiceDate: event.timestamp,
        updatedAt: new Date().toISOString(),
      });
    }

    return event;
  }

  /**
   * Get full timeline for an asset, newest first
   */
  async getByAssetId(assetId: string, options?: {
    type?: string;
    limit?: number;
    offset?: number;
  }): Promise<TimelineEvent[]> {
    let collection = db.timelineEvents
      .where('assetId')
      .equals(assetId);

    if (options?.type) {
      collection = collection.and(e => e.type === options.type);
    }

    let results = await collection.reverse().sortBy('timestamp');

    if (options?.offset) {
      results = results.slice(options.offset);
    }
    if (options?.limit) {
      results = results.slice(0, options.limit);
    }

    return results;
  }

  /**
   * Get timeline for a specific work order
   */
  async getByWorkOrderId(workorderId: string): Promise<TimelineEvent[]> {
    return db.timelineEvents
      .where('workorderId')
      .equals(workorderId)
      .reverse()
      .sortBy('timestamp');
  }

  /**
   * Get recent events across all assets (dashboard view)
   */
  async getRecent(limit: number = 20): Promise<TimelineEvent[]> {
    return db.timelineEvents
      .orderBy('timestamp')
      .reverse()
      .limit(limit)
      .toArray();
  }

  /**
   * Get events for a customer across all their assets
   */
  async getByCustomerId(customerId: string): Promise<TimelineEvent[]> {
    return db.timelineEvents
      .where('customerId')
      .equals(customerId)
      .reverse()
      .sortBy('timestamp');
  }

  /**
   * Count events by type for an asset (analytics)
   */
  async countByType(assetId: string): Promise<Record<string, number>> {
    const events = await db.timelineEvents
      .where('assetId')
      .equals(assetId)
      .toArray();

    const counts: Record<string, number> = {};
    events.forEach(e => {
      counts[e.type] = (counts[e.type] || 0) + 1;
    });
    return counts;
  }

  /**
   * Calculate total spending for an asset
   */
  async getTotalSpending(assetId: string): Promise<number> {
    const events = await db.timelineEvents
      .where('assetId')
      .equals(assetId)
      .and(e => e.totalAmount != null)
      .toArray();

    return events.reduce((sum, e) => sum + (e.totalAmount || 0), 0);
  }
}

export const timelineService = new TimelineService();
