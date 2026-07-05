# Offline-First Rules

## Principle

Field technicians work in basements, elevators, remote sites, and areas with zero cellular signal. The application MUST work fully offline and sync when connectivity returns.

## Architecture

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Vue UI      │ ←→  │  Pinia Store │ ←→  │  Service     │
│  Components  │     │  (reactive)  │     │  Layer       │
└──────────────┘     └──────────────┘     └──────┬───────┘
                                                  │
                                           ┌──────▼───────┐
                                           │  Dexie.js    │
                                           │  (IndexedDB) │
                                           └──────┬───────┘
                                                  │
                                           ┌──────▼───────┐
                                           │  SyncQueue   │
                                           └──────┬───────┘
                                                  │ (when online)
                                           ┌──────▼───────┐
                                           │  Server API  │
                                           └──────────────┘
```

## Offline Rules

1. **Every write goes to IndexedDB first** — no exceptions
2. **UI updates immediately** — optimistic updates, no waiting for server
3. **SyncQueue captures all mutations** — create, update, delete
4. **Network detection** — listen to `navigator.onLine` + periodic ping
5. **Background sync** — attempt sync when online, retry on failure
6. **Graceful degradation** — features that require server show clear offline indicators

## Sync Strategy

### Sync Queue Processing

```typescript
async function processSyncQueue(): Promise<void> {
  const pending = await db.syncQueue
    .where('status').equals('pending')
    .sortBy('timestamp');

  for (const item of pending) {
    try {
      item.status = 'syncing';
      await db.syncQueue.put(item);

      await api.sync(item.entityType, item.entityId, item.action, item.data);

      item.status = 'synced';
      await db.syncQueue.put(item);
    } catch (error) {
      item.retryCount++;
      item.status = item.retryCount >= MAX_RETRY ? 'failed' : 'pending';
      await db.syncQueue.put(item);
    }
  }
}
```

### Retry Policy

| Retry Count | Wait Time |
|-------------|-----------|
| 1 | 5 seconds |
| 2 | 15 seconds |
| 3 | 60 seconds |
| 4+ | 5 minutes |
| Max retries: 10 | Mark as failed |

## Conflict Resolution

### Strategy: Last Write Wins (default)

Most field service data is append-only (timeline events, photos). For these, Last Write Wins is safe.

### Manual Resolution (critical fields)

For critical conflicts (work order status, payment amount), prompt the user:

```
┌─────────────────────────────────────┐
│  数据冲突                            │
│                                      │
│  工单 WO-001 状态已被其他人修改       │
│                                      │
│  本地: 进行中                         │
│  服务器: 已完成                        │
│                                      │
│  [使用服务器版本]  [使用本地版本]      │
└─────────────────────────────────────┘
```

## Offline Indicators

- Global banner: "离线模式 — 数据将在联网后同步"
- Per-record badge: "待同步" for records not yet synced
- Sync status page: show pending/syncing/failed counts
- Photo upload queue: show pending upload count

## Storage Management

| Data | Storage | Max Size | Cleanup |
|------|---------|----------|---------|
| Structured data | IndexedDB | ~50MB | Archive old synced items |
| Photos (raw) | IndexedDB Blob | Compress to < 500KB each | Delete after cloud upload |
| Photos (thumbnail) | IndexedDB Blob | < 50KB each | Keep permanently |
| SyncQueue | IndexedDB | Keep last 1000 synced | Prune weekly |
| OCR cache | IndexedDB | Temporary | Delete after 7 days |
