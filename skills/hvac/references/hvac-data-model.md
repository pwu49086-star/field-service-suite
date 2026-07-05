# HVAC Data Model

## Asset Extension Fields

HVAC assets extend the base Asset with these fields stored in `asset.extension`:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| equipmentType | enum | Yes | split/window/central/ducted/vrf/heat_pump/chiller |
| refrigerant | enum | Yes | R22/R410A/R32/R290/R134a/R407C |
| voltage | number | Yes | 220 or 380 (V) |
| horsepower | number | Yes | 匹数 (0.75, 1, 1.5, 2, 3, 5, 10...) |
| coolingCapacity | number | Yes | 制冷量 (W) |
| heatingCapacity | number | No | 制热量 (W) |
| energyRating | enum | No | 1级-5级 |
| outdoorUnitSerial | string | No | 外机序列号 (split/VRF) |
| outdoorUnitModel | string | No | 外机型号 |
| installationLocation | enum | Yes | 客厅/卧室/书房/办公室/会议室/机房/厂房/商铺/other |
| pipeLength | number | No | 连管长度 (m) |
| indoorUnitCount | number | No | 内机数量 (VRF) |
| nameplateImageUrl | string | No | 铭牌照片 URL |

## Equipment Types

| Type | Chinese | Description |
|------|---------|-------------|
| split | 分体机 | 壁挂式/立柜式，一拖一 |
| window | 窗机 | 窗式一体机 |
| central | 中央空调 | 风冷/水冷中央空调 |
| ducted | 风管机 | 天花板内嵌，风管送风 |
| vrf | 多联机 | 一拖多系统 |
| heat_pump | 热泵 | 空气源/地源热泵 |
| chiller | 冷水机 | 工业冷水机组 |

## Refrigerant Types

| Code | Name | Status | Notes |
|------|------|--------|-------|
| R22 | 氟利昂 | 逐步淘汰 | ODP > 0，正在淘汰 |
| R410A | 环保冷媒 | 主流 | ODP = 0，GWP 高 |
| R32 | 新冷媒 | 增长中 | ODP = 0，GWP 较低 |
| R290 | 丙烷 | 新兴 | 天然冷媒，GWP 极低 |
| R134a | 环保冷媒 | 特定用途 | 主要用于汽车空调 |
| R407C | 混合冷媒 | 替代 R22 | 直接替换方案 |

## Warranty Rules

| Component | Typical Warranty |
|-----------|-----------------|
| 整机 | 3 年 |
| 压缩机 | 5-6 年 |
| 上门服务 | 1 年 |

Warranty calculation: `warrantyStart` + warranty years = `warrantyExpiry`

## Indexes

```typescript
// Dexie.js indexes for HVAC queries
assets: '++id, serialNumber, brandId, modelId, customerId, category, status, extension.equipmentType'
```

Note: Dexie.js supports indexing nested JSON fields with dot notation.
