/**
 * Dexie.js Database Schema Template
 * 
 * Follows: database-rules.md, mdm-rules.md, offline-rules.md
 * Replace {{Entity}} placeholders with actual entity names.
 */

import Dexie, { type Table } from 'dexie';

// ─── Master Data Interfaces ───────────────────────────────────────

export interface Customer {
  id: string;
  name: string;
  phone: string;
  email?: string;
  type: 'individual' | 'company';
  addresses: Address[];
  tags: string[];
  notes?: string;
  status: 'active' | 'inactive';
  createdAt: string;
  updatedAt: string;
  deletedAt?: string | null;
}

export interface Address {
  id: string;
  label: string;
  province?: string;
  city: string;
  district?: string;
  street?: string;
  detail: string;
  latitude?: number;
  longitude?: number;
  isDefault: boolean;
}

export interface Asset {
  id: string;
  name: string;
  serialNumber: string;
  brandId: string;
  modelId: string;
  customerId: string;
  addressId?: string;
  category: AssetCategory;
  status: AssetStatus;
  installDate?: string;
  warrantyExpiry?: string;
  extension: Record<string, unknown>;
  lastServiceDate?: string;
  nextMaintenanceDate?: string;
  tags: string[];
  notes?: string;
  createdAt: string;
  updatedAt: string;
  deletedAt?: string | null;
}

export type AssetCategory = 'hvac' | 'appliance' | 'elevator' | 'water-purifier' | 'solar' | 'fire-safety' | 'security' | 'other';
export type AssetStatus = 'registered' | 'active' | 'maintenance' | 'inactive' | 'scrapped' | 'transferred';

export interface Part {
  id: string;
  name: string;
  sku: string;
  barcode?: string;
  brand?: string;
  category?: string;
  unit: 'piece' | 'meter' | 'kilogram' | 'liter' | 'set' | 'roll';
  stock: number;
  minStock: number;
  unitPrice: number;
  costPrice?: number;
  supplierId?: string;
  compatibleAssets: string[];
  imageUrl?: string;
  status: 'active' | 'discontinued';
  createdAt: string;
  updatedAt: string;
}

export interface Brand {
  id: string;
  name: string;
  nameEn?: string;
  logo?: string;
  categories: string[];
  website?: string;
  status: 'active' | 'inactive';
  createdAt: string;
}

export interface Model {
  id: string;
  brandId: string;
  name: string;
  category: AssetCategory;
  specs: Record<string, unknown>;
  imageUrl?: string;
  status: 'active' | 'discontinued';
  createdAt: string;
}

export interface Supplier {
  id: string;
  name: string;
  contact?: string;
  phone: string;
  email?: string;
  address?: string;
  paymentTerms?: string;
  leadTimeDays?: number;
  rating?: number;
  notes?: string;
  status: 'active' | 'inactive';
  createdAt: string;
  updatedAt: string;
}

export interface Technician {
  id: string;
  name: string;
  phone: string;
  email?: string;
  employeeId?: string;
  skills: string[];
  certifications: Certification[];
  maxDailyOrders?: number;
  serviceArea?: string;
  status: 'active' | 'on_leave' | 'inactive';
  createdAt: string;
  updatedAt: string;
}

export interface Certification {
  name: string;
  issuedBy?: string;
  issuedAt?: string;
  expiresAt?: string;
}

// ─── Business Interfaces ──────────────────────────────────────────

export interface WorkOrder {
  id: string;
  orderNo: string;
  type: 'installation' | 'repair' | 'maintenance' | 'inspection' | 'quote_only' | 'other';
  status: WorkOrderStatus;
  priority: 'low' | 'normal' | 'high' | 'urgent';
  assetId: string;
  customerId: string;
  technicianId?: string;
  addressId?: string;
  description?: string;
  faultCategory?: string;
  scheduledDate?: string;
  scheduledTimeSlot?: string;
  startedAt?: string;
  completedAt?: string;
  duration?: number;
  items: WorkItem[];
  totalAmount: number;
  paidAmount: number;
  signatureAttachmentId?: string;
  notes?: string;
  createdAt: string;
  updatedAt: string;
  createdBy: string;
}

export type WorkOrderStatus = 'draft' | 'pending' | 'in_progress' | 'paused' | 'pending_parts' | 'pending_quote' | 'pending_payment' | 'completed' | 'cancelled';

export interface WorkItem {
  id: string;
  type: 'labor' | 'part' | 'material' | 'other';
  description: string;
  partId?: string;
  quantity: number;
  unitPrice: number;
  amount: number;
}

export interface Attachment {
  id: string;
  type: 'image' | 'video' | 'pdf' | 'audio' | 'document';
  mimeType: string;
  fileName: string;
  fileSize: number;
  url: string;
  thumbnailUrl?: string;
  storageType: 'local' | 'indexeddb' | 'cloud';
  width?: number;
  height?: number;
  duration?: number;
  exif?: {
    latitude?: number;
    longitude?: number;
    takenAt?: string;
    orientation?: number;
  };
  ocrResultId?: string;
  createdAt: string;
  createdBy: string;
}

export interface EntityAttachment {
  id: string;
  attachmentId: string;
  entityType: 'asset' | 'workorder' | 'customer' | 'timeline_event' | 'part';
  entityId: string;
  purpose: string;
  sortOrder: number;
  createdAt: string;
}

export interface TimelineEvent {
  id: string;
  assetId: string;
  customerId: string;
  workorderId?: string;
  type: string;
  title: string;
  description?: string;
  timestamp: string;
  technicianId?: string;
  status: 'pending' | 'in_progress' | 'completed' | 'cancelled';
  metadata?: Record<string, unknown>;
  attachmentIds: string[];
  partsUsed: PartsUsage[];
  totalAmount?: number;
  createdAt: string;
  createdBy: string;
}

export interface PartsUsage {
  partId: string;
  quantity: number;
  unitPrice: number;
}

export interface Payment {
  id: string;
  workorderId: string;
  customerId: string;
  amount: number;
  method: string;
  status: 'pending' | 'completed' | 'refunded' | 'failed';
  items: { description: string; amount: number }[];
  invoiceNo?: string;
  paidAt?: string;
  notes?: string;
  createdAt: string;
  createdBy: string;
}

export interface Quote {
  id: string;
  workorderId: string;
  customerId: string;
  items: { description: string; type: string; quantity: number; unitPrice: number; amount: number }[];
  totalAmount: number;
  discountAmount: number;
  finalAmount: number;
  status: 'draft' | 'pending_approval' | 'approved' | 'rejected' | 'expired';
  approvedAt?: string;
  rejectedAt?: string;
  rejectionReason?: string;
  validUntil?: string;
  notes?: string;
  createdAt: string;
  createdBy: string;
}

// ─── Sync Queue ───────────────────────────────────────────────────

export interface SyncItem {
  id?: number;
  entityType: string;
  entityId: string;
  action: 'create' | 'update' | 'delete';
  data: unknown;
  timestamp: number;
  retryCount: number;
  status: 'pending' | 'syncing' | 'failed' | 'synced';
}

// ─── Database Definition ──────────────────────────────────────────

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
