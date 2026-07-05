---
name: solar
description: |
  Solar energy industry module for Field Service Suite.
  Use when:
  - Building solar panel installation and maintenance service management
  - Creating solar work orders (installation, repair, cleaning, inspection)
  - Designing solar asset databases with panel specs, inverter tracking, generation monitoring
  - Managing solar panel cleaning schedules and performance degradation analysis
  - Building solar brand/model databases (LONGi, JA Solar, Trina, JinkoSolar, Huawei, Sungrow)
  Do NOT use for other industries or generic field service tasks.
---

# Solar Module

## Overview

Solar module covers photovoltaic (PV) panel systems, inverters, batteries, and grid connection equipment. Key differentiator: **generation monitoring** and **performance degradation tracking**.

## Asset Extension

```typescript
interface SolarExtension {
  // System type
  systemType: 'residential' | 'commercial' | 'industrial' | 'utility';
  gridType: 'on_grid' | 'off_grid' | 'hybrid';  // 并网/离网/混合

  // Panel specs
  panelBrand?: string;
  panelModel?: string;
  panelCount?: number;           // 组件数量
  panelWattage?: number;         // 单块功率 (W)
  totalCapacity?: number;        // 总装机容量 (kWp)

  // Inverter
  inverterBrand?: string;
  inverterModel?: string;
  inverterCapacity?: number;     // 逆变器容量 (kW)
  inverterCount?: number;

  // Battery (optional)
  hasBattery?: boolean;
  batteryBrand?: string;
  batteryCapacity?: number;      // 电池容量 (kWh)
  batteryType?: 'lithium' | 'lead_acid' | 'flow';

  // Grid connection
  gridVoltage?: 220 | 380;
  meterNo?: string;              // 电表号

  // Installation
  installationAngle?: number;    // 安装角度 (度)
  installationDirection?: string; // 朝向 (南/东南/西南)
  roofType?: 'flat' | 'tilted' | 'ground';

  // Performance
  estimatedAnnualYield?: number; // 预计年发电量 (kWh)
  actualAnnualYield?: number;    // 实际年发电量 (kWh)
  performanceRatio?: number;     // 性能比 (%)
  degradationRate?: number;      // 年衰减率 (%)

  // Monitoring
  monitoringPlatform?: string;   // 监控平台
  monitoringUrl?: string;        // 监控地址

  // Grid
  gridConnectionDate?: string;   // 并网日期
  contractNo?: string;           // 合同编号
  feedInTariff?: number;         // 上网电价 (元/kWh)
}
```

## Workflows

### Installation

```
接单 → 现场勘测 → 方案设计 → 报价确认 → 施工安装 → 并网验收 → 完成
```

### Cleaning

```
接单 → 扫码签到 → 安全检查 → 清洗组件 → 检查连接 → 记录数据 → 完成
```

**Cleaning Checklist**:
- [ ] 安全防护（安全带、绝缘手套）
- [ ] 检查组件外观（破损、热斑、蜗牛纹）
- [ ] 清洗组件表面（清水冲洗，禁用高压水枪）
- [ ] 检查支架固定
- [ ] 检查线缆连接
- [ ] 检查接地
- [ ] 记录清洗前后发电数据

### Inspection

```
接单 → 扫码签到 → 外观检查 → 电气测试 → 红外热成像 → 生成报告 → 完成
```

### Repair

```
接单 → 扫码识别 → 故障诊断 → 报价确认 → 维修/更换 → 测试验收 → 完成
```

**Common Faults**:

| 故障 | 原因 | 处理 |
|------|------|------|
| 发电量下降 | 灰尘遮挡、组件衰减 | 清洗、更换组件 |
| 逆变器报警 | 电网异常、组件故障 | 检查电网、更换组件 |
| 热斑 | 组件缺陷、遮挡 | 更换组件 |
| 绝缘故障 | 线缆老化、接头进水 | 更换线缆 |
| 通信故障 | 监控模块故障 | 更换监控模块 |

## Parts

| Category | Parts |
|----------|------|
| 组件 | 光伏组件、接线盒、MC4接头 |
| 电气 | 逆变器、汇流箱、配电箱、断路器 |
| 支架 | 铝合金支架、不锈钢螺栓 |
| 线缆 | 光伏线缆、接地线 |
| 监控 | 采集器、通信模块 |
| 电池 | 锂电池、铅酸电池 |

## References

- Data model: `references/data-model.md`
- Workflows: `references/workflows.md`
