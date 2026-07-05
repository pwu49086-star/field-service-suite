# API / Service Layer Patterns

## Service Architecture

```
UI Component → Pinia Store → Service Layer → Dexie.js → SyncQueue
```

## Service Interface

Every entity service provides:

```typescript
interface EntityService<T> {
  getById(id: string): Promise<T | undefined>;
  list(options?: ListOptions): Promise<T[]>;
  create(data: CreateDTO): Promise<T>;
  update(id: string, data: UpdateDTO): Promise<T>;
  delete(id: string): Promise<void>;
  search(query: string, fields: string[]): Promise<T[]>;
}
```

## Work Order Service (extended)

```typescript
interface WorkOrderService extends EntityService<WorkOrder> {
  transitionStatus(id: string, newStatus: WorkOrderStatus): Promise<WorkOrder>;
  assignTechnician(id: string, technicianId: string): Promise<WorkOrder>;
  addItems(id: string, items: WorkItem[]): Promise<WorkOrder>;
  getByAssetId(assetId: string): Promise<WorkOrder[]>;
  getByStatus(status: WorkOrderStatus): Promise<WorkOrder[]>;
}
```

## Timeline Service (extended)

```typescript
interface TimelineService {
  create(data: CreateTimelineDTO): Promise<TimelineEvent>;
  getByAssetId(assetId: string, options?: QueryOptions): Promise<TimelineEvent[]>;
  getByWorkOrderId(workorderId: string): Promise<TimelineEvent[]>;
  getRecent(limit: number): Promise<TimelineEvent[]>;
  countByType(assetId: string): Promise<Record<string, number>>;
  getTotalSpending(assetId: string): Promise<number>;
}
```

## Sync Queue Integration

Every write operation automatically adds to SyncQueue:

```typescript
async addToSyncQueue(entityId: string, action: 'create' | 'update' | 'delete', data: unknown) {
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
```

## Error Handling

```typescript
class FieldServiceError extends Error {
  constructor(
    public code: string,
    message: string,
    public details?: unknown
  ) {
    super(message);
  }
}

// Error codes
// INVALID_TRANSITION — State machine rejected transition
// ASSET_NOT_FOUND — Asset lookup failed
// DUPLICATE_SERIAL — Serial number already exists
// OFFLINE — Operation requires network
// SYNC_CONFLICT — Server rejected due to conflict
```
