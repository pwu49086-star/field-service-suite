# Coding Standards

## TypeScript

- `strict: true` in tsconfig — no `any` types
- Use `interface` for data shapes, `type` for unions/intersections
- Use `readonly` for immutable data
- Use `enum` or `as const` for fixed sets of values
- Prefer `unknown` over `any` for untyped data
- Use `satisfies` operator for type narrowing

## Vue 3

- Use Composition API with `<script setup lang="ts">`
- One component per file
- Props defined with `defineProps<Props>()` — always with type
- Events defined with `defineEmits<Emits>()`
- Use `computed()` for derived state, `watch()` sparingly
- Prefer `ref()` over `reactive()` for primitives
- Use `provide()`/`inject()` for deeply shared state

## Service Layer

```typescript
// Every entity has a service
class WorkOrderService {
  // CRUD
  async getById(id: string): Promise<WorkOrder | undefined>
  async list(filter: WorkOrderFilter): Promise<WorkOrder[]>
  async create(data: CreateWorkOrderDTO): Promise<WorkOrder>
  async update(id: string, data: UpdateWorkOrderDTO): Promise<WorkOrder>
  async delete(id: string): Promise<void>

  // Business logic
  async transitionStatus(id: string, newStatus: WorkOrderStatus): Promise<void>
  async assignTechnician(id: string, technicianId: string): Promise<void>
  async addParts(id: string, parts: PartsUsage[]): Promise<void>
}
```

## Error Handling

```typescript
// Define domain errors
class FieldServiceError extends Error {
  constructor(
    public code: string,
    message: string,
    public details?: unknown
  ) {
    super(message);
  }
}

// Usage
throw new FieldServiceError('INVALID_TRANSITION', `Cannot transition from ${from} to ${to}`);
throw new FieldServiceError('ASSET_NOT_FOUND', `Asset ${id} not found`);
```

## Logging

```typescript
// Use structured logging
logger.info('workorder.created', { id, type, customerId, assetId });
logger.error('sync.failed', { entityType, entityId, error: error.message });
logger.warn('offline.storage.quota', { usedMB, maxMB });
```

## Testing

- Unit tests for all Service methods
- Integration tests for state machine transitions
- E2E tests for critical flows (create work order, complete work order)
- Use `vitest` for unit tests, `playwright` for E2E
