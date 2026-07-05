# Asset Lifecycle Flow Example

## Scenario

A customer buys a new HVAC unit. Over the next 5 years, it goes through installation, multiple repairs, regular maintenance, an inspection, and eventually gets replaced.

## Timeline

```
2026-07-01  Installation     安装格力 KFR-35GW 客厅空调
2026-07-01  Note             安装完成，制冷正常，客户确认签字
2026-12-15  Maintenance      首次保养：清洗滤网、检查冷媒
2027-06-20  Repair           维修：更换电容，加注 R410A 冷媒
2027-12-10  Maintenance      年度保养：清洗内外机、检查电路
2028-06-15  Inspection       年度巡检：运行正常，能效达标
2028-12-08  Maintenance      年度保养：更换滤网
2029-07-22  Repair           维修：压缩机故障，更换压缩机
2029-08-01  Quote            更换新机报价：¥8,500
2029-08-05  Payment          收款：¥8,500（新机 + 安装）
2029-08-05  Transfer         旧机转移至仓库待报废
2029-08-05  Scrap            旧机报废，原因：压缩机损坏，维修不经济
2029-08-05  Installation     安装新机格力 KFR-35GW
2030-06-10  Callback         回访：新机运行正常，客户满意
```

## Data Flow

```typescript
// 1. Installation — create asset + first timeline event
const asset = await assetService.create({
  name: '客厅空调',
  serialNumber: 'SN-2026-GRD-001',
  brandId: 'gree',           // Reference to Brand master data
  modelId: 'kfr-35gw',       // Reference to Model master data
  customerId: 'customer-001',
  addressId: 'addr-001',
  category: 'hvac',
  extension: {
    refrigerant: 'R410A',
    voltage: 220,
    horsepower: 1.5,
    coolingCapacity: 3500,
    installationLocation: '客厅',
  },
  installDate: '2026-07-01',
  warrantyExpiry: '2029-07-01',
});

await timelineService.create({
  assetId: asset.id,
  customerId: 'customer-001',
  type: 'installation',
  title: '安装格力 KFR-35GW 客厅空调',
  description: '新机安装，制冷测试正常',
  technicianId: 'tech-001',
  status: 'completed',
  metadata: {
    installationType: 'new',
    commissioningChecklist: [
      { item: '制冷测试', result: 'pass' },
      { item: '制热测试', result: 'pass' },
      { item: '排水测试', result: 'pass' },
      { item: '噪音测试', result: 'pass' },
    ],
  },
  attachmentIds: ['photo-install-001', 'signature-001'],
});

// 2. Repair — reference asset, don't copy its data
await timelineService.create({
  assetId: asset.id,
  customerId: 'customer-001',
  workorderId: 'wo-2027-001',
  type: 'repair',
  title: '维修：更换电容',
  description: '空调不启动，检查发现启动电容损坏',
  technicianId: 'tech-002',
  status: 'completed',
  metadata: {
    faultDescription: '空调不启动',
    faultCategory: 'electrical',
    rootCause: '启动电容老化',
    repairActions: ['更换启动电容 35μF', '加注 R410A 冷媒 200g'],
    duration: 45,
  },
  partsUsed: [
    { partId: 'cap-35uf', quantity: 1, unitPrice: 25 },
    { partId: 'r410a-200g', quantity: 1, unitPrice: 80 },
  ],
  attachmentIds: ['photo-before-001', 'photo-after-001', 'photo-old-capacitor'],
});

// 3. Scrap — end of life
await timelineService.create({
  assetId: 'old-asset-id',
  customerId: 'customer-001',
  type: 'scrap',
  title: '旧机报废',
  description: '压缩机损坏，维修成本超过新机价格',
  technicianId: 'tech-001',
  status: 'completed',
  metadata: {
    reason: '压缩机损坏，维修不经济',
    disposalMethod: '回收处理',
  },
});

// Update asset status
await assetService.updateStatus('old-asset-id', 'scrapped');
```

## Key Takeaways

1. **Asset is the anchor** — all events reference `assetId`
2. **Master data is referenced** — `brandId`, `modelId`, `customerId` are never copied
3. **Timeline is unified** — installation, repair, maintenance, scrap all in one stream
4. **Parts are tracked** — `partsUsed` references Part master data by ID
5. **Attachments are linked** — photos, signatures linked to specific events
6. **Metadata is typed** — each event type has its own metadata structure
