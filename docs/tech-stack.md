# Tech Stack

## Recommended Stack

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| Framework | Vue 3 | 3.4+ | UI framework |
| Language | TypeScript | 5.x | Type safety |
| Build | Vite | 5.x | Dev server & bundler |
| CSS | Tailwind CSS | 3.x | Utility-first styling |
| State | Pinia | 2.x | Reactive state management |
| Router | Vue Router | 4.x | Client-side routing |
| Local DB | Dexie.js | 4.x | IndexedDB wrapper |
| Scanning | html5-qrcode | 2.x | QR/barcode scanning |
| Image | browser-image-compression | 2.x | Client-side compression |
| Search | Fuse.js | 7.x | Fuzzy search |
| Icons | Lucide | 0.x | Icon library |
| PWA | Workbox | 7.x | Service Worker |
| Testing | Vitest | 1.x | Unit testing |
| E2E | Playwright | 1.x | End-to-end testing |

## Why This Stack

- **Vue 3 + TypeScript**: Composition API provides excellent DX for complex state management. TypeScript catches errors at compile time.
- **Dexie.js**: Best IndexedDB wrapper with TypeScript support. Essential for offline-first.
- **Tailwind CSS**: Rapid UI development, mobile-first responsive, small bundle with purging.
- **Pinia**: Official Vue state management, lightweight, TypeScript-friendly.
- **html5-qrcode**: Browser-native QR/barcode scanning, no native permissions needed.

## Alternative Stacks

| Concern | Alternative | When to Use |
|---------|------------|-------------|
| Framework | React + Next.js | If team prefers React |
| Framework | Nuxt 3 | If SSR is needed |
| Local DB | WatermelonDB | If React Native mobile app |
| CSS | UnoCSS | If prefer Windi CSS style |
| State | Zustand (React) | If using React |
