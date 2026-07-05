# Timeline Model

## Overview

The Event Timeline is the **single source of truth** for what happened to an Asset. It replaces separate history tables for installation, repair, maintenance, inspection, etc.

## Why Unified Timeline

**Before** (anti-pattern):
```
installation_history table → only installation events
repair_history table → only repair events
maintenance_history table → only maintenance events
→ "What happened to this asset?" requires joining 5+ tables
```

**After** (this pattern):
```
timeline_events table → ALL events for ALL types
→ "What happened to this asset?" = single query by assetId
```

## Event Schema

```typescript
interface TimelineEvent {
  id: string;
  assetId: string;               // Which asset
  customerId: string;            // Which customer
  workorderId?: string;          // Related work order (optional)
  type: TimelineEventType;       // Event category
  title: string;                 // Short description
  description?: string;          // Detailed description
  timestamp: string;             // When it happened
  technicianId?: string;         // Who did it
  status: 'pending' | 'in_progress' | 'completed' | 'cancelled';
  metadata?: Record<string, unknown>; // Type-specific data
  attachmentIds: string[];       // Related photos/videos
  partsUsed: PartsUsage[];       // Parts consumed
  totalAmount?: number;          // Cost (for payment events)
  createdAt: string;
  createdBy: string;
}
```

## Event Types

| Type | When Created | Metadata |
|------|-------------|----------|
| installation | Asset installed | commissioningChecklist, testResults |
| repair | Repair completed | faultDescription, rootCause, repairActions |
| maintenance | Maintenance completed | checklist, nextMaintenanceDate |
| inspection | Inspection completed | checklist, overallResult |
| quote | Quote created | items, totalAmount, approvalStatus |
| payment | Payment collected | amount, method, invoiceNo |
| callback | Follow-up completed | satisfaction, feedback |
| transfer | Asset moved | fromAddress, toAddress |
| scrap | Asset decommissioned | reason, disposalMethod |
| note | General observation | free text |

## Query Patterns

```typescript
// Full timeline for an asset
const events = await timelineService.getByAssetId(assetId);

// Filter by type
const repairs = await timelineService.getByAssetId(assetId, { type: 'repair' });

// Recent activity (dashboard)
const recent = await timelineService.getRecent(20);

// Total spending on an asset
const totalCost = await timelineService.getTotalSpending(assetId);

// Repair frequency
const counts = await timelineService.countByType(assetId);
// → { installation: 1, repair: 3, maintenance: 5, inspection: 2 }
```

## Display Rules

1. Reverse chronological order (newest first)
2. Date grouping: "今天", "昨天", "本周", "本月", "更早"
3. Each event shows: icon + type + title + timestamp + technician
4. Tap to expand full details
5. Filter by event type (chips or tabs)
6. Attachment thumbnails inline

## Immutability

Timeline Events are **immutable** once created. To correct an error:
- Create a new event with the correction
- Reference the original event in metadata
- Never modify or delete existing events
