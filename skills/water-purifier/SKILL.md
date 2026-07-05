---
name: water-purifier
description: |
  Water purifier industry module for Field Service Suite.
  Use when:
  - Building water purifier installation and maintenance service management
  - Creating water purifier work orders (installation, filter replacement, repair)
  - Designing water purifier asset databases with TDS monitoring, filter tracking
  - Managing filter lifecycle and replacement scheduling
  - Building water quality testing records
  - Managing water purifier brand/model databases (Midea, Angel, Qinyuan, 3M, AO Smith)
  Do NOT use for:
  - HVAC systems (use hvac module)
  - General plumbing (not a field service asset)
  - Generic field service without water purifier characteristics
---

# Water Purifier Module

## Overview

Water purifier module covers RO (Reverse Osmosis), UF (Ultrafiltration), UV, and water softener service management. Key differentiator: **filter lifecycle tracking** with TDS monitoring over time.

## Asset Extension

```typescript
interface WaterPurifierExtension {
  // Purifier type
  purifierType:
    | 'ro'            // 反渗透 (Reverse Osmosis)
    | 'uf'            // 超滤 (Ultrafiltration)
    | 'uv'            // 紫外线杀菌
    | 'nanofiltration' // 纳滤
    | 'water_softener' // 软水机
    | 'commercial'     // 商用净水器
    | 'other';

  // Water source
  waterSource: 'tap' | 'well' | 'other';  // 自来水/井水/其他

  // Capacity
  flowRate?: number;              // 流量 (L/h or GPD)
  flowRateUnit?: 'LPH' | 'GPD';  // 升/小时 或 加仑/天
  tankCapacity?: number;          // 压力桶容量 (L)

  // Water quality monitoring
  inletTDS?: number;              // 进水 TDS (ppm)
  outletTDS?: number;             // 出水 TDS (ppm)
  targetTDS?: number;             // 目标 TDS (ppm)

  // Filters
  filters: FilterInfo[];          // 滤芯配置

  // Smart features
  hasTDSMonitor?: boolean;        // 有 TDS 监测
  hasFilterReminder?: boolean;    // 有滤芯更换提醒
  hasLeakDetection?: boolean;     // 有漏水检测
  connectivity?: 'wifi' | 'none';

  // Installation
  installationLocation?: '厨房' | '卫生间' | '阳台' | 'other';
  installationType?: 'under_sink' | 'countertop' | 'whole_house' | 'commercial';

  // Purchase
  purchaseDate?: string;
  purchaseChannel?: string;
}

interface FilterInfo {
  position: number;               // 滤芯位置 (1, 2, 3, ...)
  type: 'pp' | 'cto' | 'ro_membrane' | 'uf_membrane' | 'uv_lamp' | 't33' | 'mineral' | 'other';
  typeName: string;               // 中文名称 (PP棉, 活性炭, RO膜, ...)
  model?: string;                 // 滤芯型号
  installedDate?: string;         // 安装日期
  expectedLifespan?: number;      // 预期寿命 (月)
  replacementDate?: string;       // 实际更换日期
  status: 'active' | 'due_soon' | 'expired' | 'replaced';
}
```

## Filter Types

| Type | Chinese | Function | Typical Lifespan |
|------|---------|----------|-----------------|
| pp | PP棉 | 去除泥沙、铁锈、大颗粒 | 3-6 个月 |
| cto | 活性炭 | 去除余氯、异味、有机物 | 6-12 个月 |
| ro_membrane | RO膜 | 去除重金属、细菌、病毒 | 2-3 年 |
| uf_membrane | 超滤膜 | 去除细菌、胶体 | 1-2 年 |
| uv_lamp | UV灯管 | 杀菌消毒 | 1 年 (8000 小时) |
| t33 | 后置活性炭 | 改善口感 | 6-12 个月 |
| mineral | 矿化滤芯 | 添加矿物质 | 6-12 个月 |

## Water Quality Standards

| Parameter | Excellent | Good | Acceptable | Poor |
|-----------|-----------|------|------------|------|
| TDS (ppm) | 0-50 | 50-100 | 100-300 | > 300 |
| pH | 6.5-7.5 | 7.5-8.0 | 8.0-8.5 | > 8.5 |
| 余氯 (mg/L) | 0 | < 0.05 | < 0.3 | > 0.3 |

## Workflows

### Installation

```
接单 → 上门勘测 → 确认水源 → 安装设备 → 冲洗管路 → 水质测试 → 客户验收 → 完成
```

**Installation Checklist**:
- [ ] 确认水源类型（自来水/井水）
- [ ] 测量进水 TDS
- [ ] 确认水压（0.1-0.4 MPa）
- [ ] 确认安装位置和空间
- [ ] 安装主机
- [ ] 安装压力桶（RO 机型）
- [ ] 安装水龙头
- [ ] 连接水管
- [ ] 冲洗管路 15 分钟
- [ ] 测量出水 TDS
- [ ] 检查漏水
- [ ] 客户验收签字

### Filter Replacement

```
接单 → 扫码识别 → 查看滤芯状态 → 更换滤芯 → 冲洗 → 水质测试 → 重置计时 → 完成
```

**Filter Replacement Checklist**:
- [ ] 扫码识别设备，查看各滤芯状态
- [ ] 关闭进水阀
- [ ] 排空管路余水
- [ ] 更换到期滤芯
- [ ] 打开进水阀
- [ ] 冲洗新滤芯 15-30 分钟
- [ ] 测量出水 TDS
- [ ] 检查漏水
- [ ] 重置滤芯计时器
- [ ] 记录更换信息

### Repair

```
接单 → 扫码识别 → 故障诊断 → 报价确认 → 维修处理 → 水质测试 → 收费 → 完成
```

**Common Faults**:

| 故障现象 | 可能原因 | 处理方式 |
|---------|---------|---------|
| 出水 TDS 高 | RO 膜失效、滤芯到期 | 更换 RO 膜/滤芯 |
| 不出水 | 水压不足、管路堵塞、水泵故障 | 检查水压、清理管路、更换水泵 |
| 漏水 | 接头松动、管路老化、密封圈损坏 | 紧固接头、更换管路 |
| 噪音大 | 水泵异常、管路共振 | 更换水泵、固定管路 |
| 出水量小 | 滤芯堵塞、压力桶气压不足 | 更换滤芯、充气 |
| 异味 | 滤芯失效、管路污染 | 更换滤芯、冲洗管路 |

### Water Quality Test

```
接单 → 扫码签到 → 采样 → 测试 TDS/pH/余氯 → 记录数据 → 生成报告 → 完成
```

## TDS Monitoring

TDS (Total Dissolved Solids) is the primary water quality indicator for purifiers.

### Monitoring Pattern

```typescript
interface TDSReading {
  id: string;
  assetId: string;
  timestamp: string;
  inletTDS: number;      // 进水 TDS
  outletTDS: number;     // 出水 TDS
  reductionRate: number; // 去除率 = (inlet - outlet) / inlet * 100%
  technicianId: string;
  notes?: string;
}
```

### Trend Analysis

- **Stable** (去除率 > 90%): 滤芯正常
- **Declining** (去除率 70-90%): 滤芯即将到期
- **Failed** (去除率 < 70%): 需要更换滤芯
- **Sudden spike**: 可能是 RO 膜破损

## Parts

| Category | Parts |
|----------|------|
| 滤芯 | PP棉、活性炭、RO膜、超滤膜、UV灯管、后置活性炭 |
| 水路 | 进水电磁阀、高压开关、低压开关、冲洗电磁阀 |
| 机械 | 水泵、压力桶、鹅颈龙头 |
| 电气 | 控制板、TDS探头、漏水传感器 |
| 耗材 | 接头、管路、密封圈 |

## References

- Data model: `references/data-model.md`
- Workflows: `references/workflows.md`
- Brands: `references/water-purifier-brands.md`
