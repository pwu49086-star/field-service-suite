# Architecture Principles

## Core Identity

This is an **Asset Lifecycle Management** framework, not a generic CRUD generator. Every design decision serves the reality that field technicians work with physical assets in unpredictable environments.

## Design Principles

### 1. Asset-Centric

- Asset is the central entity — not work order, not customer
- All operations revolve around assets: who owns it, what happened to it, what needs to happen
- An Asset can be an HVAC unit, elevator, solar panel, fire extinguisher, water purifier, or any physical device

### 2. Timeline-Driven History

- All events (installation, repair, maintenance, inspection, quote, payment, callback) flow into a **unified Event Timeline** per asset
- Never maintain separate history tables per event type
- Timeline is the single source of truth for "what happened to this asset"

### 3. Master Data Governance

- Foundational entities (Customer, Asset, Part, Brand, Model, Supplier, Technician) are master data
- Master data is globally unique — each entity has exactly one record
- Business entities (WorkOrder, Payment, Quote) **reference** master data, never copy it
- Changes to master data propagate everywhere through references

### 4. Mobile-First

- Design for a 375px viewport first, enhance for larger screens
- One-hand operation — critical actions in the bottom 1/3 of the screen
- Minimum 44px touch targets, prefer 48px
- Prefer selection over typing, scanning over selection, OCR over scanning
- Bottom Sheet over Modal dialogs
- One screen = one complete work order view

### 5. Offline-First

- All data operations write to IndexedDB first (local)
- Sync queue captures changes for later server sync
- Optimistic UI — update immediately, sync in background
- Conflict resolution: Last Write Wins for most fields, manual resolution for critical conflicts
- Photos stored as IndexedDB Blobs, uploaded when online

### 6. Modular & Extensible

- Industry modules are independent sub-skills
- Core framework has zero knowledge of any specific industry
- New industry = new sub-skill + JSON schema extension
- No if/else chains for industry-specific logic

### 7. High Cohesion, Low Coupling

- Related functionality lives in the same module
- Modules communicate through well-defined interfaces (schemas)
- No circular dependencies between modules
- Shared concerns (OCR, attachments, timeline) live in Core

## Anti-Patterns (Forbidden)

- ❌ Direct localStorage access in UI layer — always go through Service layer
- ❌ Hardcoded industry fields in generic models — use JSON extension
- ❌ Multi-function pages — each page has a single responsibility
- ❌ Nested modals — use navigation instead
- ❌ Main-thread image processing — use Web Worker
- ❌ Loading all module rules — load on demand only
- ❌ Copy-pasting code — extract to template or utility
- ❌ Duplicating master data in work orders — always reference
- ❌ Separate history tables per event type — use unified Timeline
