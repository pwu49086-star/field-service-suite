# Architecture Deep Dive

## System Layers

```
┌─────────────────────────────────────────────────┐
│  Codex Skill Layer                               │
│  SKILL.md → Router → Sub-skills                  │
├─────────────────────────────────────────────────┤
│  Knowledge Layer                                 │
│  references/ → Rules, patterns, examples         │
│  schemas/ → JSON Schema definitions              │
│  templates/ → Code generation templates          │
├─────────────────────────────────────────────────┤
│  Application Layer                               │
│  Vue 3 + TypeScript + Tailwind CSS               │
├─────────────────────────────────────────────────┤
│  State Layer                                     │
│  Pinia stores (reactive state)                   │
├─────────────────────────────────────────────────┤
│  Service Layer                                   │
│  Business logic, state machine, validation       │
├─────────────────────────────────────────────────┤
│  Data Layer                                      │
│  Dexie.js (IndexedDB) + SyncQueue                │
├─────────────────────────────────────────────────┤
│  Sync Layer                                      │
│  SyncQueue → API Server (when online)            │
└─────────────────────────────────────────────────┘
```

## Data Flow

### Read Path
```
UI Component → computed() → Pinia store → Service.getById() → Dexie.js
```

### Write Path
```
UI Component → Pinia action → Service.create/update() → Dexie.js → SyncQueue
```

### Sync Path
```
Network online → SyncQueue.process() → API Server → Mark synced
```

## Entity Relationship Diagram

```
Customer ──1:N──→ Address ──1:N──→ Asset
                                      │
                                      ├──1:N──→ WorkOrder ──1:N──→ WorkItem
                                      │              │
                                      │              ├──1:1──→ Payment
                                      │              ├──1:1──→ Quote
                                      │              └──1:N──→ Attachment (via EntityAttachment)
                                      │
                                      └──1:N──→ TimelineEvent ──N:N──→ Attachment

Brand ──1:N──→ Model ←──ref── Asset

Supplier ──1:N──→ Part ←──ref── WorkItem / PartsUsage

Technician ──1:N──→ WorkOrder
```

## Module Architecture

```
Root Plugin
├── SKILL.md (router)
├── references/ (shared rules)
├── schemas/ (shared data models)
├── templates/ (code templates)
└── skills/
    ├── field-service-core (foundational patterns)
    ├── hvac (extends core for HVAC)
    ├── appliance-repair (extends core for appliances)
    └── ... (more industries)
```

**Key principle**: Core has zero knowledge of any industry. Industry modules extend via JSON `extension` field.
