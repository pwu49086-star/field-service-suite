# Appliance Repair Data Model

## Asset Extension Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| applianceType | enum | Yes | washing_machine/dryer/refrigerator/microwave/oven/dishwasher/range_hood/gas_stove/water_heater/other |
| capacity | number | No | 容量 (L for fridge, kg for washer) |
| capacityUnit | enum | No | kg/L/place_settings |
| powerRating | number | No | 额定功率 (W) |
| voltage | enum | No | 220/380 |
| energyRating | enum | No | 1级-5级 |
| isSmart | boolean | No | 智能家电 |
| connectivity | enum | No | wifi/bluetooth/none |
| features | string[] | No | ['变频', '烘干', '蒸汽', '除菌'] |
| installationType | enum | No | built_in/freestanding/wall_mounted/countertop |
| installationLocation | enum | No | 厨房/卫生间/阳台/客厅/other |
| nameplateImageUrl | string | No | 铭牌照片 URL |
| purchaseDate | date | No | 购买日期 |
| purchaseChannel | string | No | 购买渠道 |

## Appliance Types

| Type | Chinese | Capacity Unit | Common Capacity Range |
|------|---------|--------------|----------------------|
| washing_machine | 洗衣机 | kg | 6-12 kg |
| dryer | 烘干机 | kg | 7-10 kg |
| refrigerator | 冰箱 | L | 150-600 L |
| freezer | 冷柜 | L | 100-500 L |
| microwave | 微波炉 | L | 20-30 L |
| oven | 烤箱 | L | 30-70 L |
| dishwasher | 洗碗机 | place_settings | 6-16 套 |
| range_hood | 油烟机 | - | - |
| gas_stove | 燃气灶 | - | - |
| water_heater | 热水器 | L | 40-100 L |
| air_purifier | 空气净化器 | - | - |
| dehumidifier | 除湿机 | L/day | 10-50 L/day |

## Warranty Rules

| Appliance | Typical Warranty |
|-----------|-----------------|
| 洗衣机 | 整机 3 年，电机 10 年 |
| 冰箱 | 整机 1 年，压缩机 3-10 年 |
| 微波炉 | 整机 1 年，磁控管 3 年 |
| 洗碗机 | 整机 2 年 |
| 油烟机 | 整机 3 年，电机 5 年 |
| 燃气灶 | 整机 3 年 |
| 热水器 | 整机 3 年，内胆 5-8 年 |

## Indexes

```typescript
assets: '++id, serialNumber, brandId, modelId, customerId, category, status, extension.applianceType'
```
