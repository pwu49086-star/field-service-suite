# Field Service Suite

> Asset Lifecycle Management — Codex Skill for Field Service Industry Software Development

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## What Is This?

Field Service Suite is a [Codex Skill](https://openai.com/codex) that transforms Codex into a field service domain expert. It provides structured knowledge, data models, UI patterns, and workflow rules for building mobile-first, offline-first field service applications.

**This is not a prompt.** It is a modular, extensible knowledge framework that makes AI understand the nuances of field service software — from asset lifecycle management to OCR nameplate recognition.

## Core Philosophy

```
Asset-centric    → Every piece of equipment is an Asset with a lifecycle
Timeline-driven  → All events flow into a unified timeline per asset
Master Data      → Foundational entities are globally unique, referenced never copied
Mobile-first     → Technicians work on phones with gloves in the sun
Offline-first    → Signal is unreliable in the field — everything works offline
```

## Five Core Capabilities

| Capability | Description |
|-----------|-------------|
| **Master Data** | Customer, Asset, Part, Brand, Model, Supplier, Technician — all globally unique |
| **Asset Model** | Unified asset model with industry-specific JSON extensions |
| **OCR Engine** | Shared across all industries — nameplate, barcode, QR, invoice, receipt |
| **Attachment System** | Images, video, PDF, audio, document — any entity can reference |
| **Event Timeline** | Unified event stream per asset — the single source of truth for history |

## Industry Modules

| Module | Status | Description |
|--------|--------|-------------|
| **HVAC** | ✅ v0.1 | Air conditioning, heating, ventilation |
| Appliance Repair | 🔲 Phase 2 | Washing machine, refrigerator, microwave |
| Water Purifier | 🔲 Phase 2 | RO filters, TDS monitoring |
| Elevator | 🔲 Phase 3 | Lift maintenance, annual inspection |
| Fire Safety | 🔲 Phase 3 | Extinguishers, alarms, sprinklers |
| Solar | 🔲 Phase 3 | Panels, inverters, generation monitoring |
| Security | 🔲 Phase 3 | Cameras, access control, alarms |

## Tech Stack (Recommended)

| Layer | Technology |
|-------|-----------|
| Framework | Vue 3 + TypeScript |
| Build | Vite |
| Styling | Tailwind CSS |
| State | Pinia |
| Local DB | Dexie.js (IndexedDB) |
| Scanning | html5-qrcode |
| Image | browser-image-compression |
| Search | Fuse.js |
| PWA | Workbox |
| Testing | Vitest + Playwright |

## Project Structure

```
field-service-suite/
├── SKILL.md              # Entry point (router)
├── plugin.json           # Codex plugin metadata
├── references/           # Shared rules (loaded on demand)
├── schemas/              # JSON Schemas (master + business + extensions)
├── templates/            # Code generation templates
├── skills/               # Sub-skills (industry modules)
│   ├── field-service-core/
│   ├── hvac/
│   └── _module-template/
├── scripts/              # Validation & scaffolding tools
└── docs/                 # Extended documentation
```

## Quick Start

1. Install this skill in your Codex skills directory
2. Ask Codex: "Help me build a field service app with work order management"
3. Codex will load the appropriate rules and generate code following field service patterns

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on adding new industry modules.

## License

[MIT](LICENSE)
