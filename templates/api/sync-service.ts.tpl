/**
 * API Sync Service Template
 * Syncs local IndexedDB with RESTful backend via SyncQueue.
 * Follows: offline-rules.md, database-rules.md
 */

import { db } from '../db/database';
import type { SyncItem } from '../types';

export interface APIConfig {
  baseUrl: string;
  authToken?: string;
  timeout?: number;
  maxRetries?: number;
}

export class SyncService {
  private config: APIConfig;
  private isSyncing = false;
  private syncInterval: ReturnType<typeof setInterval> | null = null;

  constructor(config: APIConfig) {
    this.config = { timeout: 10000, maxRetries: 10, ...config };
  }

  startAutoSync(intervalMs = 30000) {
    this.stopAutoSync();
    this.syncInterval = setInterval(() => {
      if (navigator.onLine && !this.isSyncing) this.processQueue();
    }, intervalMs);
  }

  stopAutoSync() {
    if (this.syncInterval) { clearInterval(this.syncInterval); this.syncInterval = null; }
  }

  async processQueue(): Promise<{ synced: number; failed: number }> {
    if (this.isSyncing) return { synced: 0, failed: 0 };
    this.isSyncing = true;
    const results = { synced: 0, failed: 0 };

    try {
      const pending = await db.syncQueue.where('status').equals('pending').sortBy('timestamp');
      for (const item of pending) {
        try {
          await db.syncQueue.update(item.id!, { status: 'syncing' });
          await this.syncItem(item);
          await db.syncQueue.update(item.id!, { status: 'synced' });
          results.synced++;
        } catch {
          const retryCount = (item.retryCount || 0) + 1;
          await db.syncQueue.update(item.id!, {
            status: retryCount >= this.config.maxRetries! ? 'failed' : 'pending',
            retryCount,
          });
          if (retryCount >= this.config.maxRetries!) results.failed++;
        }
      }
    } finally {
      this.isSyncing = false;
    }
    return results;
  }

  private async syncItem(item: SyncItem): Promise<void> {
    const url = `${this.config.baseUrl}/api/v1/${item.entityType}`;
    const headers = { 'Content-Type': 'application/json', ...(this.config.authToken ? { Authorization: `Bearer ${this.config.authToken}` } : {}) };
    const opts: RequestInit = { headers, signal: AbortSignal.timeout(this.config.timeout!) };

    if (item.action === 'create') await fetch(url, { ...opts, method: 'POST', body: JSON.stringify(item.data) });
    else if (item.action === 'update') await fetch(`${url}/${item.entityId}`, { ...opts, method: 'PUT', body: JSON.stringify(item.data) });
    else if (item.action === 'delete') await fetch(`${url}/${item.entityId}`, { ...opts, method: 'DELETE' });
  }

  async fullSync(): Promise<{ pushed: number; pulled: number }> {
    const pushResult = await this.processQueue();
    return { pushed: pushResult.synced, pulled: 0 }; // Pull implementation depends on backend
  }
}

export function createSyncService(config: APIConfig): SyncService {
  return new SyncService(config);
}
