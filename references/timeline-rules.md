# Event Timeline Rules

## Principle

The Event Timeline is the **single source of truth** for what happened to an Asset. All service activities, status changes, and significant observations are recorded as Timeline Events.

## Timeline Event Schema

```typescript
interface TimelineEvent {
  id: string;                    // UUID
  assetId: string;               // Primary entity 鈥?which asset
  customerId: string;            // Which customer
  workorderId?: string;          // Related work order (if any)
  type: TimelineEventType;       // Event category
  title: string;                 // Short description
  description?: string;          // Detailed description
  timestamp: string;             // ISO datetime 鈥?when it happened
  technicianId?: string;         // Who did it
  status: 'pending' | 'in_progress' | 'completed' | 'cancelled';
  metadata?: Record<string, unknown>;  // Type-specific data
  attachmentIds?: string[];      // Related attachments
  partsUsed?: PartsUsage[];      // Parts consumed (repair/maintenance)
  createdAt: string;
  createdBy: string;             // Technician ID who created the event
}

type TimelineEventType =
  | 'installation'   // 璁惧瀹夎
  | 'repair'         // 缁翠慨
  | 'maintenance'    // 淇濆吇
  | 'inspection'     // 宸℃
  | 'quote'          // 鎶ヤ环
  | 'payment'        // 鏀舵
  | 'callback'       // 鍥炶
  | 'transfer'       // 璁惧杞Щ
  | 'scrap'          // 璁惧鎶ュ簾
  | 'note';          // 澶囨敞
```

## Event Type Metadata

Each event type has its own metadata schema. Industry modules define the specific metadata structure. See `schemas/business/timeline-event.json` for the base structure.

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
6. Date grouping: "浠婂ぉ", "鏄ㄥぉ", "鏈懆", "鏈湀", "鏇存棭"

## Rules

1. Every work order completion creates a Timeline Event
2. Every asset status change creates a Timeline Event
3. Timeline Events are immutable once created 鈥?corrections are new events
4. Timeline Events can exist without a work order (e.g., standalone notes)
5. Deleting a work order does NOT delete its Timeline Events

