# Naming Conventions

## Files

| Type | Convention | Example |
|------|-----------|---------|
| Vue component | PascalCase.vue | `WorkOrderDetail.vue` |
| TypeScript file | camelCase.ts | `workOrderService.ts` |
| JSON schema | kebab-case.json | `workorder.json` |
| CSS/Tailwind | kebab-case | `work-order-card` |
| Test file | *.spec.ts | `workOrderService.spec.ts` |
| Skill directory | kebab-case | `field-service-core` |
| Reference doc | kebab-case.md | `database-rules.md` |

## Variables & Functions

| Type | Convention | Example |
|------|-----------|---------|
| Variable | camelCase | `workOrderId`, `customerName` |
| Function | camelCase | `getWorkOrder()`, `createAsset()` |
| Boolean | has/is/can prefix | `hasPermission`, `isOffline`, `canEdit` |
| Constant | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `DEFAULT_PAGE_SIZE` |
| Enum | PascalCase type, UPPER_SNAKE values | `WorkOrderStatus.IN_PROGRESS` |

## Database

| Type | Convention | Example |
|------|-----------|---------|
| Table name | camelCase plural | `customers`, `workorders` |
| Column name | camelCase | `customerId`, `createdAt` |
| Foreign key | entityId | `assetId`, `technicianId` |
| Index name | idx_table_column | `idx_workorders_status` |
| Join table | camelCase | `partsUsage`, `assetAttachments` |

## API / Service Layer

| Type | Convention | Example |
|------|-----------|---------|
| Service class | PascalCase + Service | `WorkOrderService` |
| Method | verb + noun | `getById()`, `create()`, `updateStatus()` |
| Query method | getBy + Filter | `getByCustomerId()`, `getByStatus()` |
| Async method | Same as sync | All service methods are async |

## Routes

| Type | Convention | Example |
|------|-----------|---------|
| Route path | kebab-case | `/work-orders/:id` |
| Route name | PascalCase | `WorkOrderDetail` |
| Nested route | parent/child | `/assets/:id/timeline` |

## Vue Components

| Type | Convention | Example |
|------|-----------|---------|
| Page component | PascalCase + Page | `WorkOrderListPage.vue` |
| UI component | PascalCase | `StatusBadge.vue`, `PhotoGrid.vue` |
| Composable | use + Name | `useWorkOrder()`, `useScanner()` |
| Store | use + Name + Store | `useWorkOrderStore()` |
| Props | camelCase | `workOrderId`, `showActions` |
| Events | kebab-case | `status-changed`, `photo-captured` |

## JSON Schema

| Type | Convention | Example |
|------|-----------|---------|
| Schema ID | kebab-case URI | `field-service://schemas/workorder` |
| Property name | camelCase | `customerId`, `serialNumber` |
| Enum values | snake_case | `in_progress`, `pending_parts` |
