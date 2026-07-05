# Workflow Rules

## State Machine Pattern

All business entities with lifecycle states use a **finite state machine**. Never use string comparisons or magic values for state transitions.

## Work Order State Machine

### States

```typescript
const WorkOrderStatus = {
  DRAFT: 'draft',
  PENDING: 'pending',
  IN_PROGRESS: 'in_progress',
  PAUSED: 'paused',
  PENDING_PARTS: 'pending_parts',
  PENDING_QUOTE: 'pending_quote',
  PENDING_PAYMENT: 'pending_payment',
  COMPLETED: 'completed',
  CANCELLED: 'cancelled',
} as const;
```

### Transitions

```typescript
const transitions: Record<string, string[]> = {
  draft:           ['pending', 'cancelled'],
  pending:         ['in_progress', 'cancelled'],
  in_progress:     ['paused', 'pending_parts', 'pending_quote', 'pending_payment', 'completed'],
  paused:          ['in_progress', 'cancelled'],
  pending_parts:   ['in_progress'],
  pending_quote:   ['in_progress', 'cancelled'],
  pending_payment: ['completed'],
  completed:       [],
  cancelled:       [],
};
```

### Transition Rules

1. Validate transitions: `canTransition(from, to)` must return true
2. Every transition creates a Timeline Event with `from` and `to` status
3. Transitions can require data: `pending_parts` requires parts list
4. Transitions can trigger side effects: `completed` triggers payment collection
5. Invalid transitions throw an error — never silently fail

## Asset State Machine

```typescript
const AssetStatus = {
  REGISTERED: 'registered',
  ACTIVE: 'active',
  MAINTENANCE: 'maintenance',
  INACTIVE: 'inactive',
  SCRAPPED: 'scrapped',
  TRANSFERRED: 'transferred',
} as const;

const assetTransitions: Record<string, string[]> = {
  registered:  ['active'],
  active:      ['maintenance', 'inactive', 'transferred', 'scrapped'],
  maintenance: ['active', 'inactive'],
  inactive:    ['active', 'scrapped'],
  transferred: ['active'],
  scrapped:    [],
};
```

## Event-Driven Side Effects

State transitions can trigger events:

```
WorkOrder.completed
  → Create Timeline Event (work order completed)
  → Update Asset.lastServiceDate
  → Trigger payment collection flow
  → Generate service report

WorkOrder.pending_parts
  → Create Timeline Event (parts requested)
  → Check parts inventory
  → Create parts reservation

Asset.scrapped
  → Create Timeline Event (asset scrapped)
  → Cancel all pending work orders for this asset
  → Archive asset data
```

## Offline Workflow

1. All state transitions write to IndexedDB first
2. Transition is immediately reflected in UI (optimistic update)
3. SyncQueue captures the transition event
4. When online, transitions sync to server in chronological order
5. If server rejects a transition (e.g., already completed by another tech), handle conflict

## Conflict Resolution

| Conflict Type | Strategy |
|--------------|----------|
| Same field, different values | Last Write Wins |
| Status transition conflict | Server wins, client re-syncs |
| Photo/attachment conflict | Always keep local version |
| Parts quantity conflict | Manual resolution prompt |
