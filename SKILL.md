---
name: field-service-suite
description: |
  Asset Lifecycle Management framework for Field Service industry software development.
  Use when building mobile-first, offline-first field service applications including:
  work order management, asset tracking, customer management, OCR/scanning,
  photo/attachment management, timeline history, and industry-specific modules
  (HVAC, appliance repair, elevator, water purifier, solar, fire safety, security).
  Covers database design, UI patterns, workflow engines, and master data management.
  Do NOT use for generic CRUD applications without field service characteristics.
---

# Field Service Suite

## Overview

Asset Lifecycle Management framework. Every piece of equipment in the real world is an **Asset** with a lifecycle: installation → active use → maintenance → repair → inspection → transfer → scrap. This skill ensures Codex understands field service domain patterns — not generic CRUD.

Core philosophy: **Asset-centric, timeline-driven, master-data-governed, mobile-first, offline-first.**

## When to Route

| User Intent | Route To | Load Rules |
|-------------|----------|------------|
| "Build a field service app" | `field-service-core` | architecture, ui, database |
| "Generate work order page" | `field-service-core` | ui, database, workflow |
| "HVAC equipment management" | `hvac` | mdm, asset-lifecycle, hvac-data-model |
| "HVAC work order" | `hvac` | ui, workflow, hvac-workflows |
| "HVAC nameplate OCR" | `hvac` | ocr, hvac-nameplate-ocr |
| "Design a new industry module" | `_module-template` | module-development-guide |
| "Scan QR code" | `field-service-core` | scanner, offline |
| "Photo/attachment management" | `field-service-core` | attachment, image |
| "Asset timeline/history" | `field-service-core` | timeline |
| "Offline sync" | `field-service-core` | offline, database |

## Do Not Route Here When

- The request is about a non-field-service domain
- The user explicitly asks for a backend-only service with no mobile UI
- The task is purely cosmetic (CSS-only changes unrelated to field service patterns)

## Routing Rules

1. Classify the request by industry:
   - `HVAC`: air conditioning, heating, ventilation, refrigerant, compressor, nameplate
   - `Appliance Repair`: washing machine, refrigerator, microwave, dishwasher
   - `Water Purifier`: filter, TDS, RO membrane
   - `Elevator`: lift, floors, inspection, annual check
   - `Fire Safety`: extinguisher, alarm, sprinkler, fire drill
   - `Solar`: panel, inverter, grid, generation
   - `Security`: camera, alarm, access control
   - `Generic`: no specific industry — use core patterns
2. Route to the most specific sub-skill.
3. Always load the master data rules and asset lifecycle rules from `../../references/`.
4. Load only the rules needed for the current task — do not load everything.

## Core Concepts

### Master Data (MDM)

All foundational entities are master data — globally unique, referenced never copied:

- **Customer**: person or organization that owns assets and receives service
- **Asset**: any piece of equipment, device, or installation (replaces "Equipment")
- **Part**: spare parts and consumables with SKU, stock, pricing
- **Brand**: manufacturer brand name
- **Model**: specific product model linked to a brand
- **Supplier**: parts supplier
- **Technician**: field service worker with skills and certifications

### Asset Lifecycle

Every asset flows through: `registered → active → maintenance → inactive → scrapped → transferred`. All service events (installation, repair, maintenance, inspection, quote, payment, callback) are recorded as **Timeline Events** on the asset.

### Event Timeline

The single source of truth for asset history. All work orders, photos, payments, and notes flow into a unified timeline per asset. Never maintain separate history tables for installation/repair/maintenance.

### Five Core Capabilities

1. **Master Data**: Global entity registry with strict reference rules
2. **Asset Model**: Unified asset with industry-specific extensions via JSON
3. **OCR Engine**: Shared across all industries — nameplate, barcode, QR, invoice, receipt
4. **Attachment System**: Images, video, PDF, audio, document — any entity can reference
5. **Event Timeline**: Unified event stream per asset — the most important data structure

## Templates

When generating code, use these templates:

| Template | Purpose | File |
|----------|---------|------|
| Vue page | Page components | `templates/vue-page/*.tpl` |
| Database | Dexie.js schema | `templates/dexie-schema/database.ts.tpl` |
| Service | Business logic layer | `templates/service/*.tpl` |
| Store | Pinia state management | `templates/store/pinia-store.ts.tpl` |
| Workflow | State machine | `templates/workflow/state-machine.ts.tpl` |
| Constants | Shared status labels & colors | `templates/constants/status.ts.tpl` |
| Utils | Date formatting, warranty check | `templates/utils/date.ts.tpl` |
| Composables | useScanner, useNetworkStatus | `templates/composables/*.tpl` |
| Router | Vue Router config | `templates/router/index.ts.tpl` |

### Critical Pattern: Component Splitting

When a page exceeds **200 lines**, split into child components:

```
Page (shell: header + router-view + action bar)
├── components/StepAssetSelect.vue      ← Step 1: asset search/scan
├── components/StepCustomerSelect.vue   ← Step 2: customer search
├── components/StepDetailsForm.vue      ← Step 3: form fields
└── components/StepConfirm.vue          ← Step 4: review & submit
```

Rules:
- Each component owns its own state and validation
- Page component manages step navigation via `useFormWizard`
- Child components emit events up, never navigate directly
- Shared UI patterns (search input, card list, step indicator) become reusable components

### Critical Pattern: Checklist Loading

Industry checklists (HVAC installation, maintenance, inspection) are defined in the industry module's `references/hvac-workflows.md`. When generating checklist UI:

1. Load the checklist definition from the workflow reference
2. Generate a composable or constant array
3. Render as a checkbox list with `v-model`
4. Store checked state in the work order's metadata

Do NOT hardcode checklists in page components.

### Critical Pattern: Shared Constants

**Always** generate `constants/status.ts` and `utils/date.ts` first. Every page imports from these instead of defining its own labels/colors/formatting functions.

### Critical Pattern: Store Enrichment

The WorkOrder store MUST include an `enrichOrder()` function that joins master data names (asset name, customer name, technician name) for display. WorkOrder only stores IDs.

### Critical Pattern: Type-Safe Extension Access

When accessing industry-specific extension fields, generate a type guard or computed property:

```typescript
import type { HVACExtension } from '@/types';

function isHVACExtension(ext: Record<string, unknown>): ext is HVACExtension {
  return 'equipmentType' in ext && 'refrigerant' in ext;
}

const hvac = computed(() => {
  const ext = asset.value?.extension;
  return ext && isHVACExtension(ext) ? ext : null;
});
```

## References

- Architecture & principles: `../../references/architecture.md`
- Mobile UI: `../../references/ui-rules.md`
- Workflow: `../../references/workflow-rules.md`
- Database: `../../references/database-rules.md`
- Naming: `../../references/naming-rules.md`
- Timeline: `../../references/timeline-rules.md`
- Attachment: `../../references/attachment-rules.md`
- Offline: `../../references/offline-rules.md`
- Scanner: `../../references/scanner-rules.md`
- OCR: `../../references/ocr-rules.md`
- Performance: `../../references/performance-rules.md`
- MDM: `../../references/mdm-rules.md`
- Asset Lifecycle: `../../references/asset-lifecycle-rules.md`
- Coding: `../../references/coding-rules.md`
- Module Dev: `../../references/module-development-guide.md`
- Master Data rules: `../../references/mdm-rules.md`
- Asset lifecycle: `../../references/asset-lifecycle-rules.md`
- Database design: `../../references/database-rules.md`
- Mobile UI: `../../references/ui-rules.md`
- Workflow state machine: `../../references/workflow-rules.md`
- Naming conventions: `../../references/naming-rules.md`
- Offline-first: `../../references/offline-rules.md`
- Coding standards: `../../references/coding-rules.md`
- Performance: `../../references/performance-rules.md`
- Attachment system: `../../references/attachment-rules.md`
- OCR engine: `../../references/ocr-rules.md`
- Scanner: `../../references/scanner-rules.md`
- Timeline: `../../references/timeline-rules.md`
- Module development: `../../references/module-development-guide.md`

## Sub-Skills

- `../field-service-core/SKILL.md` — Core patterns, master data, timeline, attachments, OCR
- `../hvac/SKILL.md` — HVAC industry module
- `../_module-template/SKILL.md` — Template for creating new industry modules

## Examples

- Asset lifecycle flow: `../../references/examples/asset-lifecycle-flow.md`
- Work order flow: `../../references/examples/workorder-flow.md`
- Offline sync pattern: `../../references/examples/offline-sync-pattern.md`

## Example Prompts

- "Build a field service app with work order management and asset tracking"
- "Design an IndexedDB schema for HVAC equipment with Dexie.js"
- "Generate a mobile work order detail page with photo capture"
- "Implement a unified timeline view for asset history"
- "Create an OCR pipeline for reading HVAC nameplate photos"
- "Design an offline-first sync strategy for field technicians"
