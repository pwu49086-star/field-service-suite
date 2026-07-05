---
name: field-service-core
description: |
  Core module for Field Service Suite — Asset Lifecycle Management framework.
  Use when:
  - Creating field service application databases (Dexie.js/IndexedDB)
  - Building work order management (create, assign, track, complete)
  - Implementing asset tracking with master data management (MDM)
  - Designing unified event timeline for asset history
  - Building attachment systems (photos, videos, PDFs, audio)
  - Implementing QR/barcode scanning for assets and parts
  - Creating mobile-first field service UI (Vue 3 + Tailwind)
  - Implementing offline-first sync with conflict resolution
  - Designing workflow state machines for work orders
  - Building customer management with address handling
  - Implementing parts inventory management
  Do NOT use for:
  - Industry-specific asset extensions (use hvac, elevator, etc.)
  - Non-field-service applications
  - Backend-only services without mobile UI
---

# Field Service Core

## Overview

This is the core module of Field Service Suite. It provides the foundational patterns for building field service applications: master data management, unified timeline, attachment system, OCR engine, scanning, offline-first architecture, and workflow state machines.

All industry modules (HVAC, elevator, etc.) depend on this core module.

## Core Data Model

### Master Data Entities

All foundational entities follow MDM principles — globally unique, referenced never copied:

| Entity | Key | References |
|--------|-----|-----------|
| Customer | id, name, phone | addresses[] |
| Asset | id, serialNumber, category | brandId, modelId, customerId, addressId |
| Part | id, sku, name | supplierId |
| Brand | id, name | — |
| Model | id, name | brandId |
| Supplier | id, name | — |
| Technician | id, name, phone | skills[], certifications[] |

### Business Entities

| Entity | Key | References (never copies) |
|--------|-----|--------------------------|
| WorkOrder | id, orderNo, type, status | assetId, customerId, technicianId |
| TimelineEvent | id, type, timestamp | assetId, customerId, workorderId? |
| Attachment | id, type, url | — (linked via EntityAttachment) |
| Payment | id, amount, method | workorderId, customerId |
| Quote | id, items[], totalAmount | workorderId, customerId |

### Entity Relationship

```
Customer ─1:N→ Address ─1:N→ Asset ─1:N→ WorkOrder ─1:N→ WorkItem
                                    │           │
                                    │           ├→ Payment
                                    │           └→ Quote
                                    │
                                    └→ TimelineEvent ─N:N→ Attachment
```

## Key Patterns

### 1. Asset-Centric Architecture

Every operation revolves around Assets. The Asset is the anchor entity:

```typescript
// Create asset with industry extension
const asset = await assetService.create({
  name: '客厅空调',
  serialNumber: 'SN-2026-001',
  brandId: brand.id,          // Reference, not copy
  modelId: model.id,          // Reference, not copy
  customerId: customer.id,    // Reference, not copy
  category: 'hvac',
  extension: {                // Industry-specific JSON
    refrigerant: 'R410A',
    horsepower: 1.5,
  },
});
```

### 2. Unified Timeline

All events flow into a single Timeline per asset:

```typescript
// Every service activity creates a timeline event
await timelineService.create({
  assetId: asset.id,
  customerId: customer.id,
  workorderId: workorder.id,
  type: 'repair',
  title: '维修：更换电容',
  timestamp: new Date().toISOString(),
  technicianId: technician.id,
  partsUsed: [{ partId: 'cap-35uf', quantity: 1, unitPrice: 25 }],
  attachmentIds: [photoBefore.id, photoAfter.id],
});
```

### 3. Workflow State Machine

Work orders use a finite state machine:

```
draft → pending → in_progress → paused/pending_parts/pending_quote/pending_payment → completed
```

Every transition is validated and creates a Timeline Event.

### 4. Offline-First

All operations write to IndexedDB first. SyncQueue captures mutations for server sync.

## Loading Rules

When this skill is triggered, load only the rules needed for the current task:

| Task | Load These Rules |
|------|-----------------|
| Generate database schema | database-rules, mdm-rules, naming-rules |
| Generate UI page | ui-rules, performance-rules, naming-rules |
| Implement work order flow | workflow-rules, timeline-rules |
| Implement scanning | scanner-rules, offline-rules |
| Implement photo/attachment | attachment-rules, performance-rules |
| Implement OCR | ocr-rules |
| Design data model | mdm-rules, asset-lifecycle-rules, database-rules |
| Implement offline sync | offline-rules, database-rules |

## References

- Master data model: `references/master-data-model.md`
- Timeline model: `references/timeline-model.md`
- Attachment model: `references/attachment-model.md`
- OCR engine: `references/ocr-engine.md`
- Page patterns: `references/page-patterns.md`
- API patterns: `references/api-patterns.md`

## Example Prompts

- "Create a Dexie.js database schema for a field service app"
- "Build a work order list page with status filtering"
- "Implement offline-first sync with conflict resolution"
- "Design a unified timeline view for asset history"
- "Build an attachment service with photo compression"
- "Create a QR scanner page that looks up assets"
