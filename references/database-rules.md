# Database Design Rules

## Technology

Use **Dexie.js** (IndexedDB wrapper) for all local data storage. IndexedDB is the only reliable persistent storage available to web applications in field environments.

## Schema Design

### Table Naming

- Use camelCase plural: `customers`, `assets`, `workorders`, `parts`
- Join tables: `partsUsage`, `assetAttachments`
- System tables: `syncQueue`, `settings`

### Index Strategy

- Index all foreign keys: `customerId`, `assetId`, `technicianId`, `workorderId`
- Index frequently queried fields: `status`, `serialNumber`, `sku`, `phone`
- Index timestamp fields used for sorting: `createdAt`, `updatedAt`, `scheduledDate`
- Compound indexes for common queries: `[assetId+type]`, `[customerId+status]`

### Version Migration

```typescript
// Always use additive migrations
db.version(2).stores({
  customers: '++id, name, phone, email', // added email index
  assets: '++id, serialNumber, brandId, modelId, customerId, category, status',
});
```

- Never remove columns in migrations — add new ones
- Use `upgrade()` callback for data transformations
- Test migrations with real data volumes

## Data Access Pattern

```
UI Component
    ↓ (reads/writes)
Pinia Store (reactive state)
    ↓ (calls)
Service Layer (business logic)
    ↓ (operates on)
Dexie.js (IndexedDB)
    ↓ (queues)
SyncQueue (for server sync)
```

**Rules:**
1. UI components NEVER access Dexie directly
2. All business logic lives in the Service layer
3. Pinia stores are the reactive bridge between UI and Services
4. SyncQueue captures all mutations for offline sync

## Sync Queue Schema

```typescript
interface SyncItem {
  id?: number;          // Auto-increment
  entityType: string;   // 'customer' | 'asset' | 'workorder' | ...
  entityId: string;     // UUID of the affected entity
  action: 'create' | 'update' | 'delete';
  data: unknown;        // The payload
  timestamp: number;    // When the change happened
  retryCount: number;   // How many times we've tried to sync
  status: 'pending' | 'syncing' | 'failed' | 'synced';
}
```

## Performance Rules

1. Use `offset`/`limit` for list queries — never load all records
2. Use Dexie's `where()` for indexed queries, not `filter()`
3. Use `bulkAdd()` / `bulkPut()` for batch operations
4. Use Web Workers for image compression and OCR processing
5. Implement virtual scrolling for lists > 50 items

## Data Size Limits

| Data Type | Max Size | Strategy |
|-----------|---------|----------|
| Text fields | No limit | IndexedDB handles well |
| Images (single) | Compress to < 500KB | client-side compression |
| Total IndexedDB | ~50MB (browser dependent) | Implement cleanup strategy |
| SyncQueue | Prune after successful sync | Keep last 1000 synced items |
