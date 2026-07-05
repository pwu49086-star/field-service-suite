# Work Order Flow Example

## Scenario

A technician receives a repair work order, goes on-site, diagnoses the issue, gets approval, completes the repair, and collects payment.

## State Machine Trace

```
draft → pending → in_progress → pending_quote → in_progress → pending_payment → completed
```

## Complete Flow

### Step 1: Create Work Order (draft)

```typescript
const workorder = await workOrderService.create({
  type: 'repair',
  assetId: 'asset-001',       // Reference — don't copy asset data
  customerId: 'customer-001', // Reference — don't copy customer data
  description: '空调不制冷',
  scheduledDate: '2026-07-06',
});
// Status: draft
```

### Step 2: Assign Technician (draft → pending)

```typescript
await workOrderService.assignTechnician(workorder.id, 'tech-001');
// Status: pending
// Timeline Event: work order assigned
```

### Step 3: Technician Starts Work (pending → in_progress)

```typescript
await workOrderService.transitionStatus(workorder.id, 'in_progress');
// Status: in_progress
// Timeline Event: work started
```

### Step 4: On-Site Diagnosis

Technician scans the asset QR code:

```typescript
const scanResult = await scannerService.startScan('scanner-container');
// → 'SN-2026-GRD-001'

const asset = await assetService.getBySerialNumber('SN-2026-GRD-001');
// → Full asset details + timeline history
```

Technician views the asset timeline to understand history:

```typescript
const history = await timelineService.getByAssetId(asset.id);
// → Shows: installation (2026-07), maintenance (2026-12), repair (2027-06)
```

### Step 5: Create Quote (in_progress → pending_quote)

```typescript
await quoteService.create({
  workorderId: workorder.id,
  items: [
    { description: '更换启动电容', amount: 25 },
    { description: '加注 R410A 冷媒', amount: 80 },
    { description: '工时费', amount: 100 },
  ],
  totalAmount: 205,
});
await workOrderService.transitionStatus(workorder.id, 'pending_quote');
```

### Step 6: Customer Approves (pending_quote → in_progress)

```typescript
await quoteService.approve(quote.id);
await workOrderService.transitionStatus(workorder.id, 'in_progress');
```

### Step 7: Complete Repair

```typescript
// Take before/after photos
await attachmentService.captureAndAttach('image', workorder.id, 'workorder', 'photo_before');
// ... perform repair ...
await attachmentService.captureAndAttach('image', workorder.id, 'workorder', 'photo_after');

// Record parts used
await workOrderService.addParts(workorder.id, [
  { partId: 'cap-35uf', quantity: 1 },
  { partId: 'r410a-200g', quantity: 1 },
]);
```

### Step 8: Collect Payment (in_progress → pending_payment → completed)

```typescript
await paymentService.create({
  workorderId: workorder.id,
  amount: 205,
  method: 'wechat_pay',
  items: [
    { description: '启动电容', amount: 25 },
    { description: 'R410A 冷媒', amount: 80 },
    { description: '工时费', amount: 100 },
  ],
});

await workOrderService.transitionStatus(workorder.id, 'pending_payment');
await paymentService.confirm(payment.id);
await workOrderService.transitionStatus(workorder.id, 'completed');
```

### Step 9: Timeline Events Created

All steps above automatically generate Timeline Events on the asset:

```
14:00  repair    工单开始：空调不制冷
14:10  note      诊断：启动电容损坏
14:15  quote     报价：¥205（电容+冷媒+工时）
14:20  note      客户确认报价
14:25  note      更换启动电容，加注冷媒
14:45  payment   收款：¥205（微信支付）
14:50  repair    工单完成：空调恢复正常制冷
```

## Key Takeaways

1. **Scan first** — technician scans asset to pull up its history before starting
2. **Timeline awareness** — view past repairs to inform current diagnosis
3. **Quote before work** — get approval before spending money
4. **Photos at every stage** — before, during, after
5. **Parts tracked** — every part used is recorded with quantity
6. **Auto timeline** — every state change creates a timeline event
7. **MDM in action** — work order references asset/customer/technician by ID, never copies
