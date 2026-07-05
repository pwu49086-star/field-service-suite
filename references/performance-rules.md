# Performance Rules

## Image Performance

1. **Compress before storing** — max 800px width, 80% quality
2. **Generate thumbnails** — 200px width for list views
3. **Lazy load images** — use `loading="lazy"` or Intersection Observer
4. **Use Web Workers** for compression — never block the main thread

## List Performance

1. **Virtual scrolling** for lists > 50 items — use `@tanstack/vue-virtual`
2. **Paginate IndexedDB queries** — use `.offset()` and `.limit()`
3. **Debounce search input** — 300ms delay
4. **Debounce scroll handlers** — 16ms (60fps)
5. **Memoize expensive computations** — use `computed()` with stable deps

## Bundle Performance

1. **Route-based code splitting** — `() => import('./pages/WorkOrder.vue')`
2. **Lazy load heavy libraries** — OCR, QR scanner, image compression
3. **Tree-shake icon libraries** — import individual icons, not entire sets
4. **Analyze bundle** — `vite-bundle-visualizer` to find bloat

## IndexedDB Performance

1. **Index all query fields** — never use `.filter()` on unindexed fields
2. **Use `bulkAdd()` / `bulkPut()`** for batch operations
3. **Use `Collection.toArray()`** only for small result sets
4. **Use `cursor()` iteration** for large result sets
5. **Close database connections** when not in use

## Network Performance

1. **Compress photos before upload** — max 500KB
2. **Upload photos in background** — don't block UI
3. **Retry with exponential backoff** — 5s, 15s, 60s, 5min
4. **Batch sync operations** — send multiple changes in one request
5. **Use ETags/If-None-Match** for conditional requests

## Rendering Performance

1. **Avoid v-if/v-for on same element**
2. **Use `v-memo` for expensive list items**
3. **Key v-for with unique IDs**, not array index
4. **Avoid deep watchers** — watch specific properties
5. **Use `shallowRef()`** for large objects that don't need deep reactivity
