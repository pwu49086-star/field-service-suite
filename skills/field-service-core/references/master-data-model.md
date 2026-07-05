# Master Data Model

## Overview

Master Data Management (MDM) is the foundation of the system. All foundational entities are globally unique records that are referenced by business entities, never copied.

## Entity Definitions

### Customer

```typescript
interface Customer {
  id: string;                    // UUID
  name: string;                  // Person or organization name
  phone: string;                 // Primary phone (used for search)
  email?: string;
  type: 'individual' | 'company';
  addresses: Address[];          // Multiple addresses (home, office, site)
  tags: string[];                // Custom categorization
  notes?: string;
  status: 'active' | 'inactive';
  createdAt: string;             // ISO datetime
  updatedAt: string;
  deletedAt?: string | null;     // Soft delete
}
```

**Search fields**: name, phone, email
**Indexes**: phone (unique lookup), name (search), status

### Asset

```typescript
interface Asset {
  id: string;
  name: string;                  // Human-readable name ('客厅空调')
  serialNumber: string;          // Manufacturer serial (globally unique)
  brandId: string;               // → Brand (reference)
  modelId: string;               // → Model (reference)
  customerId: string;            // → Customer (reference)
  addressId?: string;            // → Address (reference)
  category: AssetCategory;       // Determines industry module
  status: AssetStatus;           // Lifecycle state
  installDate?: string;          // Date installed
  warrantyExpiry?: string;       // Warranty end date
  extension: Record<string, unknown>; // Industry-specific JSON
  lastServiceDate?: string;      // Denormalized from Timeline
  nextMaintenanceDate?: string;  // Scheduled maintenance
  tags: string[];
  notes?: string;
  createdAt: string;
  updatedAt: string;
  deletedAt?: string | null;
}
```

**Search fields**: name, serialNumber
**Indexes**: serialNumber (unique), brandId, modelId, customerId, category, status

### Work Order

```typescript
interface WorkOrder {
  id: string;
  orderNo: string;               // Human-readable (WO-20260706-001)
  type: 'installation' | 'repair' | 'maintenance' | 'inspection' | 'quote_only' | 'other';
  status: WorkOrderStatus;       // State machine
  priority: 'low' | 'normal' | 'high' | 'urgent';
  assetId: string;               // → Asset (reference, NEVER copy asset data)
  customerId: string;            // → Customer (reference, NEVER copy)
  technicianId?: string;         // → Technician (reference)
  addressId?: string;            // → Address (reference)
  description?: string;
  scheduledDate?: string;
  items: WorkItem[];             // Service line items
  totalAmount: number;
  // ... timestamps and metadata
}
```

**Critical rule**: WorkOrder NEVER contains asset serialNumber, customer name, or technician name. It only holds IDs.

## Reference vs Copy — Decision Matrix

| Field | On WorkOrder | Rule |
|-------|-------------|------|
| Customer name | ❌ Not stored | Use `customerId` → lookup |
| Customer phone | ❌ Not stored | Use `customerId` → lookup |
| Asset serial | ❌ Not stored | Use `assetId` → lookup |
| Asset brand | ❌ Not stored | Use `assetId` → brandId → lookup |
| Technician name | ❌ Not stored | Use `technicianId` → lookup |
| Part name | ❌ Not stored | Use `partId` → lookup |
| Part price at time of use | ✅ Stored | Denormalized for historical accuracy |
| Customer name (cached) | ⚠️ Optional | Only for display, marked as `cached`, auto-updated |
