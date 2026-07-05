# Offline Sync Pattern Example

## Scenario

A technician goes to a basement equipment room with no cellular signal. They complete a full maintenance job offline, then sync when they return to the surface.

## Architecture

```
Offline Mode:
  UI → Pinia Store → Service Layer → IndexedDB → SyncQueue

Online Mode:
  SyncQueue → API Server → Mark as synced
```

## Step-by-Step

### 1. Detect Offline

```typescript
// composable: useNetworkStatus.ts
export function useNetworkStatus() {
  const isOnline = ref(navigator.onLine);

  window.addEventListener('online', () => {
    isOnline.value = true;
    syncService.processQueue(); // Auto-sync when back online
  });

  window.addEventListener('offline', () => {
    isOnline.value = false;
  });

  return { isOnline };
}
```

### 2. Work Offline

All operations write to IndexedDB:

```typescript
// Service layer automatically handles offline
const workorder = await workOrderService.create({
  type: 'maintenance',
  assetId: 'asset-001',
  customerId: 'customer-001',
  description: '季度保养',
});

// This writes to:
// 1. db.workorders — the work order record
// 2. db.syncQueue — a sync item with action: 'create'
```

### 3. SyncQueue Entry

```typescript
// Automatically created by the service layer
{
  id: 1,
  entityType: 'workorder',
  entityId: 'wo-2026-001',
  action: 'create',
  data: { type: 'maintenance', assetId: 'asset-001', ... },
  timestamp: 1688640000000,
  retryCount: 0,
  status: 'pending'
}
```

### 4. Multiple Operations Offline

Technician completes the full job:

```typescript
// All of these queue sync items
await workOrderService.transitionStatus(woId, 'in_progress');
await timelineService.create({ type: 'maintenance', assetId, ... });
await attachmentService.capturePhoto(workId, 'workorder', 'photo_before');
await attachmentService.capturePhoto(workId, 'workorder', 'photo_after');
await workOrderService.addParts(woId, [{ partId: 'filter-001', quantity: 1 }]);
await workOrderService.transitionStatus(woId, 'completed');

// SyncQueue now has 6 pending items
```

### 5. Return Online — Auto Sync

```typescript
// When network returns, syncService.processQueue() runs automatically
async function processQueue(): Promise<SyncResult> {
  const pending = await db.syncQueue
    .where('status').equals('pending')
    .sortBy('timestamp');

  const results = { synced: 0, failed: 0 };

  for (const item of pending) {
    try {
      item.status = 'syncing';
      await db.syncQueue.put(item);

      await apiClient.post('/sync', {
        entityType: item.entityType,
        entityId: item.entityId,
        action: item.action,
        data: item.data,
        timestamp: item.timestamp,
      });

      item.status = 'synced';
      await db.syncQueue.put(item);
      results.synced++;
    } catch (error) {
      item.retryCount++;
      item.status = item.retryCount >= 10 ? 'failed' : 'pending';
      await db.syncQueue.put(item);
      results.failed++;
    }
  }

  return results;
}
```

### 6. UI Indicators

```vue
<template>
  <div v-if="!isOnline" class="offline-banner">
    📡 离线模式 — 数据将在联网后自动同步
  </div>

  <div v-if="pendingSyncCount > 0" class="sync-badge">
    {{ pendingSyncCount }} 条待同步
  </div>
</template>
```

### 7. Conflict Handling

```typescript
// Server detects a conflict
async function handleConflict(clientData: any, serverData: any): Promise<Resolution> {
  // Status conflict — server wins for terminal states
  if (serverData.status === 'completed' && clientData.status !== 'completed') {
    return { strategy: 'server-wins', message: '工单已在其他设备完成' };
  }

  // Photo conflict — always keep local
  if (clientData.type === 'attachment') {
    return { strategy: 'client-wins' };
  }

  // Other — last write wins
  return {
    strategy: 'last-write-wins',
    winner: clientData.timestamp > serverData.timestamp ? 'client' : 'server',
  };
}
```

## Key Takeaways

1. **Every write queues a sync item** — service layer handles this transparently
2. **UI updates immediately** — optimistic updates, no loading spinners for local ops
3. **Auto-sync on reconnect** — no manual action needed
4. **Exponential backoff** — retries get slower to avoid hammering the server
5. **Clear UI indicators** — technician always knows sync status
6. **Conflict resolution is built in** — most conflicts resolve automatically
7. **Photos upload in background** — don't block the technician from moving on
