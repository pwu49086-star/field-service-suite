# Water Purifier Filter Replacement Flow Example

## Scenario

A technician receives a filter replacement work order, scans the purifier, checks filter status, and replaces expired filters.

## Complete Code

```typescript
// 1. Scan asset QR code
const scanResult = await scannerService.startScan('scanner-container');
const asset = await assetLookupService.lookupByScanValue(scanResult.value);

// 2. Check filter status (from water-purifier data model)
const extension = asset.extension as WaterPurifierExtension;
const filterStatuses = extension.filters.map(filter => {
  if (!filter.installedDate || !filter.expectedLifespan) return { ...filter, status: 'active' };
  const installed = new Date(filter.installedDate);
  const expiry = new Date(installed.setMonth(installed.getMonth() + filter.expectedLifespan));
  const daysLeft = Math.ceil((expiry.getTime() - Date.now()) / 86400000);
  return {
    ...filter,
    status: daysLeft <= 0 ? 'expired' : daysLeft <= 30 ? 'due_soon' : 'active',
    daysLeft,
  };
});

// 3. Show filter status to technician
// Filter 1 (PP棉): expired, 0 days left
// Filter 2 (活性炭): due_soon, 15 days left
// Filter 3 (RO膜): active, 180 days left

// 4. Replace expired filters
const replacedFilters = filterStatuses.filter(f => f.status === 'expired');

// 5. Update asset extension
const newFilters = extension.filters.map(f => {
  const replaced = replacedFilters.find(r => r.position === f.position);
  if (replaced) {
    return { ...f, installedDate: new Date().toISOString().slice(0, 10), status: 'active' };
  }
  return f;
});
await assetService.update(asset.id, { extension: { ...extension, filters: newFilters } });

// 6. Test water quality
const tdsTest = {
  inletTDS: 250,
  outletTDS: 15,
  reductionRate: 94, // (250-15)/250 * 100
};

// 7. Create timeline event
await timelineService.create({
  assetId: asset.id,
  customerId: asset.customerId,
  type: 'maintenance',
  title: '更换滤芯',
  description: `更换 ${replacedFilters.length} 个滤芯，出水 TDS: ${tdsTest.outletTDS}`,
  timestamp: new Date().toISOString(),
  technicianId: 'tech-001',
  status: 'completed',
  metadata: {
    maintenanceType: 'filter_replacement',
    filtersReplaced: replacedFilters.map(f => ({
      position: f.position,
      newType: f.type,
      installedDate: new Date().toISOString().slice(0, 10),
    })),
    waterQualityTest: tdsTest,
  },
  attachmentIds: [],
  partsUsed: replacedFilters.map(f => ({ partId: f.type, quantity: 1, unitPrice: 0 })),
});
```

## Key Points

- Scanner → asset lookup → filter status check
- Filter lifespan calculated from installedDate + expectedLifespan
- TDS test measures water quality (inlet vs outlet)
- Timeline event records filter replacement and TDS results
