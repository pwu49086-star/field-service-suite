---
name: hvac
description: |
  HVAC (Heating, Ventilation, Air Conditioning) industry module for Field Service Suite.
  Use when:
  - Building HVAC asset management (air conditioners, heat pumps, ventilation systems)
  - Creating HVAC work orders (installation, repair, maintenance, inspection)
  - Designing HVAC equipment databases with refrigerant, voltage, horsepower fields
  - Implementing HVAC nameplate OCR (reading brand, model, serial, specs from photos)
  - Building HVAC maintenance checklists (filter cleaning, refrigerant check, coil cleaning)
  - Managing HVAC parts inventory (filters, capacitors, refrigerant, copper tubing)
  - Designing HVAC warranty tracking
  - Creating HVAC brand/model databases (Gree, Midea, Daikin, Haier, etc.)
  Do NOT use for:
  - Non-HVAC field service (use field-service-core)
  - Elevator, fire safety, solar, or other industries
  - Generic CRUD without field service characteristics
---

# HVAC Module

## Overview

HVAC is the first industry module for Field Service Suite. It extends the core Asset model with HVAC-specific fields, workflows, checklists, and OCR rules.

**HVAC is an industry module, not the system core.** The core framework has zero knowledge of HVAC. All HVAC-specific logic lives in this module.

## Asset Extension

HVAC assets extend the base Asset with industry-specific fields via the `extension` JSON field:

```typescript
interface HVACExtension {
  // Equipment type
  equipmentType: 'split' | 'window' | 'central' | 'ducted' | 'vrf' | 'heat_pump' | 'chiller';

  // Core specs
  refrigerant: 'R22' | 'R410A' | 'R32' | 'R290' | 'R134a' | 'R407C';
  voltage: 220 | 380;
  horsepower: number;           // 匹数: 0.75, 1, 1.5, 2, 3, 5, 10...
  coolingCapacity: number;      // 制冷量 (W)
  heatingCapacity?: number;     // 制热量 (W)
  energyRating?: '1级' | '2级' | '3级' | '4级' | '5级';

  // Outdoor unit (for split/VRF systems)
  outdoorUnitSerial?: string;
  outdoorUnitModel?: string;

  // Installation details
  installationLocation: '客厅' | '卧室' | '书房' | '办公室' | '会议室' | '机房' | '厂房' | '商铺' | 'other';
  pipeLength?: number;          // 连管长度 (m)
  indoorUnitCount?: number;     // 内机数量 (VRF/多联机)

  // Nameplate
  nameplateImageUrl?: string;   // 铭牌照片 URL
}
```

## Workflows

### Installation

```
接单 → 上门勘测 → 报价确认 → 施工安装 → 调试验收 → 客户签字 → 完成
```

**Installation checklist**:
- [ ] 检查电源电压
- [ ] 确认安装位置
- [ ] 安装室内机（水平、固定）
- [ ] 安装室外机（通风、固定）
- [ ] 连接铜管（抽真空、保压）
- [ ] 连接排水管
- [ ] 连接电源线
- [ ] 充注冷媒
- [ ] 制冷测试
- [ ] 制热测试
- [ ] 排水测试
- [ ] 噪音测试
- [ ] 客户验收签字

### Repair

```
接单 → 扫码识别 → 故障诊断 → 报价确认 → 维修处理 → 测试验收 → 收费 → 完成
```

**Common faults**: 不制冷、不制热、不启动、漏水、噪音大、异味、遥控器失灵、压缩机故障

### Maintenance

```
接单 → 扫码识别 → 按清单检查 → 清洗保养 → 更换配件 → 记录数据 → 完成
```

**Maintenance checklist**:
- **室内机**: 过滤网（清洗/更换）、蒸发器（清洗）、排水管（疏通）、风机、出风温度
- **室外机**: 冷凝器（清洗）、风机、运行电流、制冷剂压力、电气连接、支架
- **系统**: 制冷/制热效果、噪音、漏水、运行参数

### Inspection

```
接单 → 扫码签到 → 逐项检查 → 拍照记录 → 生成报告 → 完成
```

## OCR: Nameplate Recognition

HVAC registers a nameplate parser with the Core OCR engine:

```typescript
ocrEngine.registerParser('nameplate', 'hvac', {
  patterns: [
    { regex: /(?:品牌|BRAND)[:\s]*(.+)/i, field: 'brand' },
    { regex: /(?:型号|MODEL)[:\s]*([A-Z0-9-]+)/i, field: 'model' },
    { regex: /S\/?N[:\s]*([A-Z0-9-]+)/i, field: 'serialNumber' },
    { regex: /(?:制冷剂|REF|R)[:\s]*(R\d+[A-Z]*)/i, field: 'refrigerant' },
    { regex: /(\d{3})\s*V/i, field: 'voltage' },
    { regex: /(\d+\.?\d*)\s*(?:匹|HP|hp)/i, field: 'horsepower' },
    { regex: /(\d+)\s*(?:W|瓦|Watt)/i, field: 'coolingCapacity' },
  ],
  postProcess: (fields) => {
    if (fields.horsepower && !fields.coolingCapacity) {
      fields.coolingCapacity = parseFloat(fields.horsepower) * 2500;
    }
    return fields;
  },
});
```

## Parts

Common HVAC parts:

| Category | Parts |
|----------|-------|
| 电气 | 启动电容、运行电容、电路板、温控器、传感器 |
| 冷媒 | R410A、R32、R22、R407C |
| 机械 | 压缩机、风机电机、膨胀阀、四通阀 |
| 耗材 | 过滤网、干燥过滤器、铜管、保温棉 |
| 其他 | 遥控器、支架、排水泵 |

## References

- HVAC data model: `references/hvac-data-model.md`
- HVAC workflows: `references/hvac-workflows.md`
- HVAC brands: `references/hvac-brands.md`
- HVAC nameplate OCR: `references/hvac-nameplate-ocr.md`
