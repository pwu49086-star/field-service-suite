/**
 * API Sync Service Template
 * 
 * Syncs local IndexedDB data with a RESTful backend.
 * Works with the existing SyncQueue pattern.
 * 
 * Follows: offline-rules.md, database-rules.md
 */

import { db } from '../db/database';
import type { SyncItem } from '../types';

// ─── Configuration ───────────────────────────────────────────────

export interface APIConfig {
  baseUrl: string;
  authToken?: string;
  timeout?: number;       // ms, default 10000
  maxRetries?: number;    // default 10
}

// ─── API Client ──────────────────────────────────────────────────

class APIClient {
  private config: APIConfig;

  constructor(config: APIConfig) {
    this.config = {
      timeout: 10000,
      maxRetries: 10,
      ...config,
    };
  }

  private async request<T>(
    method: string,
    path: string,
    body?: unknown
  ): Promise<T> {
    const url = `${this.config.baseUrl}${path}`;
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    if (this.config.authToken) {
      headers['Authorization'] = `Bearer ${this.config.authToken}`;
    }

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.config.timeout);

    try {
      const response = await fetch(url, {
        method,
        headers,
        body: body ? JSON.stringify(body) : undefined,
        signal: controller.signal,
      });

      if (!response.ok) {
        throw new Error(`API error: ${response.status} ${response.statusText}`);
      }

      return response.json();
    } finally {
      clearTimeout(timeoutId);
    }
  }

  async get<T>(path: string): Promise<T> {
    return this.request<T>('GET', path);
  }

  async post<T>(path: string, body: unknown): Promise<T> {
    return this.request<T>('POST', path, body);
  }

  async put<T>(path: string, body: unknown): Promise<T> {
    return this.request<T>('PUT', path, body);
  }

  async delete(path: string): Promise<void> {
    return this.request<void>('DELETE', path);
  }
}

// ─── Sync Service ────────────────────────────────────────────────

export class SyncService {
  private api: APIClient;
  private isSyncing = false;
  private syncInterval: ReturnType<typeof setInterval> | null = null;

  constructor(config: APIConfig) {
    this.api = new APIClient(config);
  }

  /**
   * Start automatic sync on interval
   */
  startAutoSync(intervalMs: number = 30000) {
    this.stopAutoSync();
    this.syncInterval = setInterval(() => {
      if (navigator.onLine && !this.isSyncing) {
        this.processQueue();
      }
    }, intervalMs);
  }

  stopAutoSync() {
    if (this.syncInterval) {
      clearInterval(this.syncInterval);
      this.syncInterval = null;
    }
  }

  /**
   * Process the sync queue
   */
  async processQueue(): Promise<{ synced: number; failed: number; skipped: number }> {
    if (this.isSyncing) return { synced: 0, failed: 0, skipped: 0 };
    this.isSyncing = true;

    const results = { synced: 0, failed: 0, skipped: 0 };

    try {
      const pending = await db.syncQueue
        .where('status').equals('pending')
        .sortBy('timestamp');

      for (const item of pending) {
        try {
          // Mark as syncing
          await db.syncQueue.update(item.id!, { status: 'syncing' });

          // Send to server
          await this.syncItem(item);

          // Mark as synced
          await db.syncQueue.update(item.id!, { status: 'synced' });
          results.synced++;
        } catch (error: any) {
          const retryCount = (item.retryCount || 0) + 1;
          const maxRetries = this.api['config'].maxRetries || 10;

          if (retryCount >= maxRetries) {
            await db.syncQueue.update(item.id!, {
              status: 'failed',
              retryCount,
            });
            results.failed++;
          } else {
            await db.syncQueue.update(item.id!, {
              status: 'pending',
              retryCount,
            });
            results.skipped++;
          }
        }
      }
    } finally {
      this.isSyncing = false;
    }

    return results;
  }

  /**
   * Sync a single item to the server
   */
  private async syncItem(item: SyncItem): Promise<void> {
    const endpoint = `/api/v1/${item.entityType}`;

    switch (item.action) {
      case 'create':
        await this.api.post(endpoint, item.data);
        break;
      case 'update':
        await this.api.put(`${endpoint}/${item.entityId}`, item.data);
        break;
      case 'delete':
        await this.api.delete(`${endpoint}/${item.entityId}`);
        break;
    }
  }

  /**
   * Pull latest data from server
   */
  async pullFromServer(entityType: string, since?: string): Promise<unknown[]> {
    const params = since ? `?since=${encodeURIComponent(since)}` : '';
    return this.api.get<unknown[]>(`/api/v1/${entityType}${params}`);
  }

  /**
   * Full sync: push local changes, then pull server changes
   */
  async fullSync(): Promise<{ pushed: number; pulled: number }> {
    const pushResult = await this.processQueue();

    // Pull latest from server for each entity type
    const entityTypes = ['customers', 'assets', 'workorders', 'technicians'];
    let pulled = 0;

    for (const type of entityTypes) {
      try {
        const lastSync = await this.getLastSyncTime(type);
        const data = await this.pullFromServer(type, lastSync);
        if (data.length > 0) {
          await this.mergeServerData(type, data);
          pulled += data.length;
        }
      } catch (error) {
        console.error(`Failed to pull ${type}:`, error);
      }
    }

    return { pushed: pushResult.synced, pulled };
  }

  // ─── Private Helpers ──────────────────────────────────────────

  private async getLastSyncTime(entityType: string): Promise<string | undefined> {
    const setting = await db.syncQueue
      .where('entityType').equals(entityType)
      .and(item => item.status === 'synced')
      .reverse()
      .sortBy('timestamp');

    if (setting.length > 0) {
      return new Date(setting[0].timestamp).toISOString();
    }
    return undefined;
  }

  private async mergeServerData(entityType: string, data: unknown[]): Promise<void> {
    // Merge server data into local IndexedDB
    // This is a simplified version — real implementation should handle conflicts
    const table = (db as any)[entityType];
    if (table) {
      await table.bulkPut(data);
    }
  }
}

// ─── Factory ─────────────────────────────────────────────────────

export function createSyncService(config: APIConfig): SyncService {
  return new SyncService(config);
}
