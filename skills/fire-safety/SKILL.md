---
name: fire-safety
description: |
  Fire safety industry module for Field Service Suite.
  Use when:
  - Building fire safety equipment inspection and maintenance management
  - Creating fire safety work orders (extinguisher inspection, alarm testing, sprinkler maintenance)
  - Designing fire safety asset databases with expiry tracking, compliance management
  - Managing fire drill scheduling and records
  - Building fire safety brand/model databases
  Do NOT use for other industries or generic field service tasks.
---

# Fire Safety Module

## Overview

Fire safety module covers fire extinguishers, alarm systems, sprinkler systems, smoke detectors, and fire suppression systems. Key differentiator: **expiry tracking** and **compliance documentation** — fire equipment must meet strict regulatory deadlines.

## Asset Extension

```typescript
interface FireSafetyExtension {
  // Equipment type
  equipmentType:
    | 'extinguisher'         // 灭火器
    | 'alarm_panel'          // 火灾报警控制器
    | 'smoke_detector'       // 感烟探测器
    | 'heat_detector'        // 感温探测器
    | 'sprinkler'            // 喷淋头
    | 'fire_hydrant'         // 消火栓
    | 'fire_pump'            // 消防水泵
    | 'emergency_light'      // 应急照明
    | 'exit_sign'            // 疏散指示
    | 'fire_door'            // 防火门
    | 'gas_suppression'      // 气体灭火
    | 'kitchen_suppression'  // 厨房灭火
    | 'other';

  // Extinguisher specifics
  extinguisherType?: 'dry_powder' | 'co2' | 'foam' | 'water' | 'wet_chemical';
  extinguisherWeight?: number;   // 重量 (kg)
  extinguishClass?: string;      // 灭火级别 (A, B, C, D, E, K)

  // General specs
  coverageArea?: number;         // 覆盖面积 (m²)
  sensitivity?: string;          // 灵敏度等级

  // Compliance
  manufactureDate?: string;      // 生产日期
  expiryDate?: string;           // 有效期
  lastInspectionDate?: string;   // 上次检查日期
  nextInspectionDate?: string;   // 下次检查日期
  inspectionCycle?: number;      // 检查周期（月）
  certificationNo?: string;      // 认证编号
  certificationBody?: string;    // 认证机构

  // Location
  buildingName?: string;         // 建筑名称
  floorLevel?: string;           // 楼层
  zone?: string;                 // 区域
  locationDescription?: string;  // 具体位置描述

  // Pressure (extinguishers)
  pressureNormal?: boolean;      // 压力正常
  pressureValue?: number;        // 压力值 (MPa)
}
```

## Compliance Requirements

| Equipment | Inspection Frequency | Hydrostatic Test | Expiry |
|-----------|---------------------|------------------|--------|
| 灭火器 | 每月目视，每年全面 | 干粉 5 年，CO2 5 年 | 干粉 10 年，CO2 12 年 |
| 感烟探测器 | 每年清洗标定 | - | 10-15 年 |
| 喷淋头 | 每年检测 | - | 20 年 |
| 消火栓 | 每半年试水 | - | - |
| 应急照明 | 每月测试，每年全面 | - | 3-5 年（电池） |
| 防火门 | 每季度检查 | - | - |
| 气体灭火 | 每年检测 | - | - |

## Workflows

### Inspection (Primary)

```
接单 → 扫码签到 → 逐项检查 → 拍照记录 → 生成报告 → 完成
                                    ↓
                              [不合格项] → 生成整改工单
```

**Extinguisher Checklist**:
- [ ] 外观（无锈蚀、无损坏、标识清晰）
- [ ] 压力表（绿色区域）
- [ ] 保险销（完好）
- [ ] 喷管（无堵塞、无破损）
- [ ] 标签（生产日期、有效期清晰）
- [ ] 放置位置（固定、易取、标识清晰）
- [ ] 数量配置（符合规范）

### Repair/Replacement

```
接单 → 扫码识别 → 检查状态 → 报价确认 → 更换/维修 → 测试验收 → 更新记录 → 完成
```

### Fire Drill

```
计划制定 → 通知参与人员 → 实施演练 → 记录过程 → 总结评估 → 归档 → 完成
```

## Parts

| Category | Parts |
|----------|------|
| 灭火器 | 灭火药剂、压力表、阀门、喷管 |
| 报警 | 探测器、模块、按钮、声光 |
| 喷淋 | 喷淋头、管道、阀门、水泵 |
| 应急 | 电池、灯具、指示牌 |

## References

- Data model: `references/data-model.md`
- Workflows: `references/workflows.md`
