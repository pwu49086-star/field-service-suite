# HVAC Installation Complete Flow Example

## Scenario

A technician receives an HVAC installation work order, goes on-site, installs the unit, and completes commissioning.

## Complete Code

```typescript
// 1. Create asset with HVAC extension
const asset = await assetService.create({
  name: '客厅空调',
  serialNumber: 'SN-2026-GRD-001',
  brandId: 'gree',
  modelId: 'kfr-35gw',
  customerId: 'customer-001',
  category: 'hvac',
  extension: {
    equipmentType: 'split',
    refrigerant: 'R410A',
    voltage: 220,
    horsepower: 1.5,
    coolingCapacity: 3500,
    installationLocation: '客厅',
  },
  installDate: '2026-07-06',
  warrantyExpiry: '2029-07-06',
});

// 2. Create installation work order
const workorder = await workOrderService.create({
  type: 'installation',
  status: 'pending',
  assetId: asset.id,
  customerId: 'customer-001',
  technicianId: 'tech-001',
  description: '安装格力 KFR-35GW 分体空调',
  scheduledDate: '2026-07-06',
  items: [],
  totalAmount: 0,
  paidAmount: 0,
  createdBy: 'tech-001',
});

// 3. Start work
await workOrderService.transitionStatus(workorder.id, 'in_progress');

// 4. Complete installation checklist (from hvac-workflows.md)
const checklist = [
  { item: '检查电源电压', result: 'pass' },
  { item: '确认安装位置', result: 'pass' },
  { item: '安装室内机', result: 'pass' },
  { item: '安装室外机', result: 'pass' },
  { item: '连接铜管', result: 'pass' },
  { item: '充注冷媒', result: 'pass' },
  { item: '制冷测试', result: 'pass' },
  { item: '客户验收签字', result: 'pass' },
];

// 5. Take photos
await attachmentService.captureAndAttach('image', workorder.id, 'workorder', 'photo_after');

// 6. Create timeline event
await timelineService.create({
  assetId: asset.id,
  customerId: 'customer-001',
  workorderId: workorder.id,
  type: 'installation',
  title: '安装格力 KFR-35GW 客厅空调',
  description: '安装完成，制冷测试正常',
  timestamp: new Date().toISOString(),
  technicianId: 'tech-001',
  status: 'completed',
  metadata: { commissioningChecklist: checklist },
  attachmentIds: [photo.id],
  partsUsed: [],
});

// 7. Complete work order
await workOrderService.transitionStatus(workorder.id, 'completed');
```

## Key Points

- Asset created with HVAC extension (refrigerant, voltage, horsepower)
- Work order references asset/customer/technician by ID (MDM)
- Checklist from hvac-workflows.md reference (not hardcoded)
- Photos attached via Attachment system
- Timeline event created automatically on status change
