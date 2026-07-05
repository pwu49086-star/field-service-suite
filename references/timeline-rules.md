# Event Timeline Rules

## Principle

The Event Timeline is the **single source of truth** for what happened to an Asset. All service activities, status changes, and significant observations are recorded as Timeline Events.

## Timeline Event Schema

```typescript
interface TimelineEvent {
  id: string;                    // UUID
  assetId: string;               // Primary entity — which asset
  customerId: string;            // Which customer
  workorderId?: string;          // Related work order (if any)
  type: TimelineEventType;       // Event category
  title: string;                 // Short description
  description?: string;          // Detailed description
  timestamp: string;             // ISO datetime — when it happened
  technicianId?: string;         // Who did it
  status: 'pending' | 'in_progress' | 'completed' | 'cancelled';
  metadata?: Record<string, unknown>;  // Type-specific data
  attachmentIds?: string[];      // Related attachments
  partsUsed?: PartsUsage[];      // Parts consumed (repair/maintenance)
  createdAt: string;
  createdBy: string;             // Technician ID who created the event
}

type TimelineEventType =
  | 'installation'   // 设备安装
  | 'repair'         // 维修
  | 'maintenance'    // 保养
  | 'inspection'     // 巡检
  | 'quote'          // 报价
  | 'payment'        // 收款
  | 'callback'       // 回访
  | 'transfer'       // 设备转移
  | 'scrap'          // 设备报废
  | 'note';          // 备注
```

## Event Type Metadata

### Installation

```typescript
interface InstallationMetadata {
  installationType: 'new' | 'replacement' | 'relocation';
  commissioningChecklist: ChecklistItem[];
  testResults: Record<string, string>;
}
```

### Repair

```typescript
interface RepairMetadata {
  faultDescription: string;
  faultCategory: string;        // 'electrical' | 'mechanical' | 'refrigerant' | 'other'
  rootCause?: string;
  repairActions: string[];
  duration: number;             // minutes
}
```

### Maintenance

```typescript
interface MaintenanceMetadata {
  maintenanceType: 'scheduled' | 'preventive' | 'emergency';
  checklist: ChecklistItem[];
  nextMaintenanceDate?: string;
}
```

### Inspection

```typescript
interface InspectionMetadata {
  inspectionType: 'routine' | 'compliance' | 'safety';
  checklist: ChecklistItem[];
  overallResult: 'pass' | 'fail' | 'conditional';
  correctiveActions?: string[];
}
```

## Query Patterns

```typescript
// Get full timeline for an asset
const events = await db.timelineEvents
  .where('assetId').equals(assetId)
  .reverse()
  .sortBy('timestamp');

// Get timeline filtered by type
const repairs = await db.timelineEvents
  .where('[assetId+type]').equals([assetId, 'repair'])
  .reverse()
  .sortBy('timestamp');

// Get recent events across all assets (dashboard)
const recent = await db.timelineEvents
  .orderBy('timestamp')
  .reverse()
  .limit(20);

// Count repairs per asset (for analytics)
const repairCounts = await db.timelineEvents
  .where('type').equals('repair')
  .toArray()
  .then(events => {
    const counts: Record<string, number> = {};
    events.forEach(e => { counts[e.assetId] = (counts[e.assetId] || 0) + 1; });
    return counts;
  });
```

## Display Rules

1. Timeline displays in reverse chronological order (newest first)
2. Each event shows: icon + type label + title + timestamp + technician
3. Events with attachments show thumbnail previews
4. Tap an event to expand full details
5. Filter by event type (tabs or chips)
6. Date grouping: "今天", "昨天", "本周", "本月", "更早"

## Rules

1. Every work order completion creates a Timeline Event
2. Every asset status change creates a Timeline Event
3. Timeline Events are immutable once created — corrections are new events
4. Timeline Events can exist without a work order (e.g., standalone notes)
5. Deleting a work order does NOT delete its Timeline Events
