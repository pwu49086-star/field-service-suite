---
name: appliance-repair
description: |
  Appliance repair industry module for Field Service Suite.
  Use when:
  - Building home appliance repair service management (washing machines, refrigerators, microwaves, dishwashers, dryers, ovens, range hoods)
  - Creating appliance repair work orders with fault diagnosis
  - Designing appliance asset databases with type, capacity, features
  - Managing appliance parts inventory (motors, pumps, heating elements, control boards)
  - Building appliance brand/model databases (Haier, Midea, Siemens, Bosch, Panasonic, LG, Samsung)
  Do NOT use for:
  - HVAC systems (use hvac module)
  - Elevator, fire safety, solar, or other industries
  - Generic field service without appliance characteristics
---

# Appliance Repair Module

## Overview

Appliance repair module covers home appliance service management. It extends the core Asset model with appliance-specific fields, common fault databases, and repair workflows.

## Asset Extension

```typescript
interface ApplianceExtension {
  // Appliance type
  applianceType:
    | 'washing_machine'      // 洗衣机
    | 'dryer'                // 烘干机
    | 'refrigerator'         // 冰箱
    | 'freezer'              // 冷柜
    | 'microwave'            // 微波炉
    | 'oven'                 // 烤箱
    | 'dishwasher'           // 洗碗机
    | 'range_hood'           // 油烟机
    | 'gas_stove'            // 燃气灶
    | 'water_heater'         // 热水器
    | 'air_purifier'         // 空气净化器
    | 'dehumidifier'         // 除湿机
    | 'other';

  // Core specs
  capacity?: number;              // 容量 (L for washer/fridge, kg for dryer)
  capacityUnit?: 'kg' | 'L' | 'place_settings';
  powerRating?: number;           // 额定功率 (W)
  voltage?: 220 | 380;
  energyRating?: '1级' | '2级' | '3级' | '4级' | '5级';

  // Features
  isSmart?: boolean;              // 智能家电
  connectivity?: 'wifi' | 'bluetooth' | 'none';
  features?: string[];            // ['变频', '烘干', '蒸汽', '除菌']

  // Installation
  installationType?: 'built_in' | 'freestanding' | 'wall_mounted' | 'countertop';
  installationLocation?: '厨房' | '卫生间' | '阳台' | '客厅' | 'other';

  // Nameplate
  nameplateImageUrl?: string;

  // Purchase info
  purchaseDate?: string;          // 购买日期
  purchaseChannel?: string;       // 购买渠道 (京东/天猫/线下)
}
```

## Common Appliance Types

| Type | Chinese | Common Capacity | Typical Brands |
|------|---------|----------------|----------------|
| washing_machine | 洗衣机 | 8-12 kg | 海尔、美的、西门子、博世、LG |
| dryer | 烘干机 | 8-10 kg | 西门子、博世、LG、松下 |
| refrigerator | 冰箱 | 200-600 L | 海尔、美的、西门子、博世、三星 |
| microwave | 微波炉 | 20-30 L | 格兰仕、美的、松下 |
| dishwasher | 洗碗机 | 6-14 套 | 西门子、博世、美的、方太 |
| range_hood | 油烟机 | - | 方太、老板、美的 |
| gas_stove | 燃气灶 | - | 方太、老板、华帝、美的 |
| water_heater | 热水器 | 50-80 L | 海尔、美的、A.O.史密斯 |

## Workflows

### Repair (Primary Workflow)

```
接单 → 扫码识别 → 故障诊断 → 报价确认 → 维修处理 → 测试验收 → 收费 → 完成
                                      ↓
                                [需要配件] → 暂停 → 领料 → 继续维修
```

### Common Faults by Appliance Type

**洗衣机**:
- 不启动 — 电源板、门锁、电机
- 不脱水 — 排水泵、皮带、电机
- 漏水 — 进水管、排水管、密封圈
- 噪音大 — 轴承、减震器、配重块
- 不进水 — 进水阀、水位传感器

**冰箱**:
- 不制冷 — 压缩机、冷媒泄漏、毛细管堵塞
- 不启动 — 启动器、保护器、温控器
- 漏水 — 排水孔堵塞、接水盘
- 噪音大 — 压缩机、风扇
- 结冰严重 — 化霜定时器、化霜加热器

**微波炉**:
- 不加热 — 磁控管、高压二极管、高压电容
- 不转盘 — 转盘电机
- 不启动 — 门开关、保险丝、电源板

**洗碗机**:
- 不进水 — 进水阀、水压不足
- 不排水 — 排水泵、排水管堵塞
- 洗不干净 — 喷臂堵塞、洗涤剂问题
- 漏水 — 门密封圈、水管接头

### Installation

```
接单 → 上门勘测 → 确认条件 → 安装调试 → 客户验收 → 完成
```

### Maintenance (for applicable types)

```
接单 → 扫码识别 → 按清单检查 → 清洗保养 → 记录数据 → 完成
```

## Parts

| Category | Parts |
|----------|------|
| 电气 | 电源板、控制板、电机、门开关、温控器 |
| 机械 | 排水泵、进水阀、皮带、轴承、密封圈 |
| 加热 | 加热管、磁控管、高压电容、高压二极管 |
| 结构 | 门铰链、门封条、转盘、喷臂、滤网 |
| 耗材 | 洗涤剂、漂洗剂、专用清洗剂 |

## OCR

Appliance nameplate OCR patterns:

```typescript
ocrEngine.registerParser('nameplate', 'appliance-repair', {
  patterns: [
    { regex: /(?:品牌|BRAND)[:\s]*(.+)/i, field: 'brand' },
    { regex: /(?:型号|MODEL)[:\s]*([A-Z0-9\-\/]+)/i, field: 'model' },
    { regex: /(?:S\/?N|序列号)[:\s]*([A-Z0-9\-]+)/i, field: 'serialNumber' },
    { regex: /(?:额定功率|POWER)[:\s]*(\d+)\s*W/i, field: 'powerRating' },
    { regex: /(?:额定电压|VOLTAGE)[:\s]*(\d{3})\s*V/i, field: 'voltage' },
    { regex: /(?:容量|CAPACITY)[:\s]*(\d+)\s*(?:L|kg|KG)/i, field: 'capacity' },
  ],
});
```

## References

- Data model: `references/data-model.md`
- Workflows: `references/workflows.md`
- Brands: `references/appliance-brands.md`
