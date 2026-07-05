# Scanner → Asset Lookup → Work Order Flow Example

## Scenario

Technician scans an asset barcode, system looks up the asset, shows history, and creates a new work order.

## Complete Code

```typescript
// 1. Scan asset
const scanResult = await scannerService.startScan('scanner-container');

// 2. Lookup asset (from asset-lookup-service template)
const lookup = await assetLookupService.lookupByScanValue(scanResult.value);

if (lookup.asset) {
  // 3a. Asset found — show details and timeline
  const asset = await assetLookupService.enrich(lookup.asset);
  const timeline = await timelineService.getByAssetId(asset.id);
  const repairCount = timeline.filter(e => e.type === 'repair').length;
  
  // Display: "格力 KFR-35GW | SN: ABC123 | 3 次维修记录"
  console.log(`${asset.brandName} ${asset.modelName} | SN: ${asset.serialNumber} | ${repairCount} 次维修记录`);

  // 4. Create work order
  const workorder = await workOrderService.create({
    type: 'repair',
    status: 'pending',
    assetId: asset.id,
    customerId: asset.customerId,
    description: '客户报告不制冷',
    scheduledDate: new Date().toISOString().slice(0, 10),
    items: [],
    totalAmount: 0,
    paidAmount: 0,
    createdBy: 'tech-001',
  });

  // 5. Start work
  await workOrderService.transitionStatus(workorder.id, 'in_progress');

  // 6. Diagnose and repair
  await workOrderService.addItems(workorder.id, [
    { id: crypto.randomUUID(), type: 'part', description: '启动电容 35μF', quantity: 1, unitPrice: 25, amount: 25 },
    { id: crypto.randomUUID(), type: 'labor', description: '工时费', quantity: 1, unitPrice: 100, amount: 100 },
  ]);

  // 7. Take before/after photos
  await attachmentService.captureAndAttach('image', workorder.id, 'workorder', 'photo_before');
  // ... perform repair ...
  await attachmentService.captureAndAttach('image', workorder.id, 'workorder', 'photo_after');

  // 8. Complete
  await workOrderService.transitionStatus(workorder.id, 'completed');

} else {
  // 3b. Asset not found — offer to create
  console.log('设备未找到，是否新建？');
  // Navigate to asset creation page with serial number pre-filled
}
```

## Key Points

- Scanner → lookup → enrich (join brand/model/customer names)
- Timeline history informs diagnosis (3 previous repairs)
- Work order items track parts and labor separately
- Before/after photos document the repair
- Fallback: asset not found → offer to create
