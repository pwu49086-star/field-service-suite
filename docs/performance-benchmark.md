# Performance Benchmark Guide

## Page Load Targets

| Metric | Target | Good | Acceptable |
|--------|--------|------|------------|
| First Contentful Paint | < 1.0s | < 1.5s | < 2.5s |
| Largest Contentful Paint | < 2.0s | < 2.5s | < 4.0s |
| Time to Interactive | < 3.0s | < 4.0s | < 6.0s |
| Total Bundle Size | < 200KB | < 300KB | < 500KB |

## IndexedDB Targets

| Operation | Target | Good |
|-----------|--------|------|
| Single read | < 5ms | < 10ms |
| Single write | < 10ms | < 20ms |
| Bulk read (100) | < 50ms | < 100ms |
| Indexed query | < 10ms | < 20ms |

## Offline Sync

| Metric | Target | Good |
|--------|--------|------|
| Queue write | < 20ms | < 50ms |
| Single sync | < 500ms | < 1000ms |
| Batch sync (10) | < 3s | < 5s |

## Optimization Checklist

- Route-based code splitting
- Tree-shaking for icon libraries
- Lazy load OCR/QR libraries
- Compress photos before storage
- Index all IndexedDB query fields
- Virtual scrolling for long lists
- Debounce search input (300ms)
- Background photo upload
