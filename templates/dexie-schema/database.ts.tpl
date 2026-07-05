/**
 * Dexie.js Database Schema Template
 * 
 * Follows: database-rules.md, mdm-rules.md, offline-rules.md
 * Types are in types/index.ts — this file only has the schema.
 */

import Dexie, { type Table } from 'dexie';
import type {
  Customer, Asset, Part, Brand, Model, Supplier, Technician,
  WorkOrder, Attachment, EntityAttachment, TimelineEvent,
  Payment, Quote, SyncItem,
} from '../types';

export class FieldServiceDB extends Dexie {
  // Master Data
  customers!: Table<Customer>;
  assets!: Table<Asset>;
  parts!: Table<Part>;
  brands!: Table<Brand>;
  models!: Table<Model>;
  suppliers!: Table<Supplier>;
  technicians!: Table<Technician>;

  // Business
  workorders!: Table<WorkOrder>;
  attachments!: Table<Attachment>;
  entityAttachments!: Table<EntityAttachment>;
  timelineEvents!: Table<TimelineEvent>;
  payments!: Table<Payment>;
  quotes!: Table<Quote>;

  // System
  syncQueue!: Table<SyncItem>;

  constructor() {
    super('FieldServiceDB');

    this.version(1).stores({
      // Master Data — indexes on foreign keys and frequently queried fields
      customers: '++id, name, phone, email, type, status, deletedAt',
      assets: '++id, serialNumber, brandId, modelId, customerId, addressId, category, status, deletedAt',
      parts: '++id, sku, barcode, name, brand, category, supplierId, status',
      brands: '++id, name, nameEn, status',
      models: '++id, brandId, name, category, status',
      suppliers: '++id, name, phone, status',
      technicians: '++id, name, phone, employeeId, status',

      // Business — indexes on foreign keys, status, and timestamps
      workorders: '++id, orderNo, type, status, assetId, customerId, technicianId, scheduledDate, createdAt',
      attachments: '++id, type, mimeType, storageType, createdAt',
      entityAttachments: '++id, attachmentId, entityType, entityId, purpose',
      timelineEvents: '++id, assetId, customerId, workorderId, type, timestamp, [assetId+type]',
      payments: '++id, workorderId, customerId, method, status, createdAt',
      quotes: '++id, workorderId, customerId, status, createdAt',

      // System
      syncQueue: '++id, entityType, entityId, action, status, timestamp',
    });
  }
}

export const db = new FieldServiceDB();
