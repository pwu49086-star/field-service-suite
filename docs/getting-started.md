# Getting Started

## Installation

1. Clone this repository into your Codex skills directory:

```bash
git clone https://github.com/your-org/field-service-suite.git ~/.codex/skills/field-service-suite
```

2. Restart Codex to detect the new skill.

## Quick Start

### Ask Codex to build a field service app:

```
Help me build a field service application with work order management and asset tracking.
Use Vue 3, TypeScript, Dexie.js, and Tailwind CSS.
```

### Ask for a specific feature:

```
Create a Dexie.js database schema for HVAC equipment management with offline support.
```

```
Build a mobile work order detail page with photo capture and status transitions.
```

```
Implement a unified timeline view that shows all events for an asset.
```

### Use an industry module:

```
Build an HVAC asset management system with nameplate OCR recognition.
```

## Project Structure

See the [Architecture Document](../outputs/field-service-suite-architecture.md) for the complete design.

## Tech Stack

- **Vue 3** + TypeScript — Composition API with `<script setup>`
- **Vite** — Fast HMR build tool
- **Tailwind CSS** — Utility-first CSS
- **Pinia** — State management
- **Dexie.js** — IndexedDB wrapper for offline-first storage
- **html5-qrcode** — QR/barcode scanning
- **browser-image-compression** — Client-side image compression
- **Fuse.js** — Fuzzy search
- **Workbox** — Service Worker for PWA

## Creating a New Industry Module

```bash
python scripts/generate_module.py elevator 电梯
```

Then customize the generated files in `skills/elevator/`.

See [Contributing Modules](contributing-modules.md) for details.
