/**
 * Master Data Service Template
 * 
 * Follows: mdm-rules.md, database-rules.md, offline-rules.md
 * Base service for all master data entities. Extend for specific entities.
 */

import { db, type SyncItem } from '@/db/database';
import type { Table } from 'dexie';

export abstract class MasterDataService<T extends { id: string; createdAt: string; updatedAt: string }> {
  protected abstract table: Table<T>;
  protected abstract entityType: string;

  async getById(id: string): Promise<T | undefined> {
    return this.table.get(id);
  }

  async list(options?: {
    filter?: Partial<T>;
    limit?: number;
    offset?: number;
    orderBy?: string;
  }): Promise<T[]> {
    let collection = this.table.toCollection();

    if (options?.filter) {
      const entries = Object.entries(options.filter).filter(([_, v]) => v !== undefined);
      for (const [key, value] of entries) {
        collection = collection.and((item: any) => item[key] === value);
      }
    }

    let results = await collection.toArray();

    if (options?.orderBy) {
      const desc = options.orderBy.startsWith('-');
      const field = desc ? options.orderBy.slice(1) : options.orderBy;
      results.sort((a: any, b: any) => {
        if (desc) return b[field] > a[field] ? 1 : -1;
        return a[field] > b[field] ? 1 : -1;
      });
    }

    if (options?.offset) {
      results = results.slice(options.offset);
    }
    if (options?.limit) {
      results = results.slice(0, options.limit);
    }

    return results;
  }

  async create(data: Omit<T, 'id' | 'createdAt' | 'updatedAt'>): Promise<T> {
    const now = new Date().toISOString();
    const entity = {
      ...data,
      id: crypto.randomUUID(),
      createdAt: now,
      updatedAt: now,
    } as T;

    await this.table.add(entity);
    await this.addToSyncQueue(entity.id, 'create', entity);

    return entity;
  }

  async update(id: string, data: Partial<T>): Promise<T> {
    const existing = await this.table.get(id);
    if (!existing) {
      throw new Error(`${this.entityType} ${id} not found`);
    }

    const updated = {
      ...existing,
      ...data,
      id, // Ensure ID cannot be changed
      updatedAt: new Date().toISOString(),
    } as T;

    await this.table.put(updated);
    await this.addToSyncQueue(id, 'update', updated);

    return updated;
  }

  async softDelete(id: string): Promise<void> {
    const existing = await this.table.get(id);
    if (!existing) {
      throw new Error(`${this.entityType} ${id} not found`);
    }

    const now = new Date().toISOString();
    await this.table.update(id, {
      deletedAt: now,
      updatedAt: now,
    } as any);

    await this.addToSyncQueue(id, 'update', { id, deletedAt: now });
  }

  async search(query: string, fields: (keyof T)[]): Promise<T[]> {
    const lowerQuery = query.toLowerCase();
    return this.table
      .filter((item: any) =>
        fields.some(field => {
          const value = item[field];
          return typeof value === 'string' && value.toLowerCase().includes(lowerQuery);
        })
      )
      .toArray();
  }

  async count(): Promise<number> {
    return this.table.count();
  }

  protected async addToSyncQueue(entityId: string, action: SyncItem['action'], data: unknown): Promise<void> {
    await db.syncQueue.add({
      entityType: this.entityType,
      entityId,
      action,
      data,
      timestamp: Date.now(),
      retryCount: 0,
      status: 'pending',
    });
  }
}
