---
name: elevator
description: |
  Elevator industry module for Field Service Suite.
  Use when:
  - Building elevator/escalator maintenance and inspection service management
  - Creating elevator work orders (installation, repair, maintenance, annual inspection)
  - Designing elevator asset databases with load capacity, speed, floors, machine room type
  - Managing elevator compliance tracking (annual inspection, safety certificates)
  - Building elevator brand/model databases (Otis, Schindler, ThyssenKrupp, KONE, Mitsubishi)
  Do NOT use for other industries or generic field service tasks.
---

# Elevator Module

## Overview

Elevator module covers passenger elevators, freight elevators, escalators, and moving walks. Key differentiator: **compliance tracking** — mandatory annual inspections, safety certificates, and regulatory documentation.

## Asset Extension

```typescript
interface ElevatorExtension {
  // Elevator type
  elevatorType:
    | 'passenger'       // 乘客电梯
    | 'freight'         // 货梯
    | 'residential'     // 住宅电梯
    | 'escalator'       // 自动扶梯
    | 'moving_walk'     // 自动人行道
    | 'hospital'        // 医用电梯
    | 'observation'     // 观光电梯
    | 'other';

  // Core specs
  loadCapacity: number;          // 载重 (kg)
  speed: number;                 // 速度 (m/s)
  floors: number;                // 服务楼层数
  floorRange: string;            // 楼层范围 (e.g., 'B2-F30')
  travelHeight?: number;         // 提升高度 (m)

  // Machine room
  machineRoomType: 'machine_room' | 'machine_room_less';  // 有机房/无机房
  machineRoomLocation?: string;  // 机房位置

  // Drive type
  driveType: 'traction' | 'hydraulic' | 'screw' | 'belt';  // 曳引/液压/螺杆/皮带

  // Control
  controlType?: string;          // 控制方式 (e.g., 'VVVF', 'AC-2')
  doorType?: string;             // 门类型 (e.g., '中分门', '旁开门')

  // Registration
  registrationNo?: string;       // 注册代码
  registrationDate?: string;     // 注册日期
  useCertificateNo?: string;     // 使用证书编号
  useCertificateExpiry?: string; // 使用证书有效期

  // Inspection
  lastInspectionDate?: string;   // 上次检验日期
  nextInspectionDate?: string;   // 下次检验日期
  inspectionResult?: 'pass' | 'fail' | 'conditional';
  inspectionAgency?: string;     // 检验机构

  // Safety
  emergencyPhone?: boolean;      // 有无紧急电话
  fireServiceMode?: boolean;     // 有无消防功能
  earthquakeDevice?: boolean;    // 有无地震感知装置
}
```

## Compliance Requirements

| Requirement | Frequency | Authority |
|------------|-----------|-----------|
| 年度检验 | 每年 1 次 | 特种设备检验机构 |
| 使用证书更新 | 每 1-4 年 | 市场监督管理局 |
| 维保记录 | 每月 2 次 | 维保单位 |
| 安全评估 | 每 15 年 | 检验机构 |

## Workflows

### Maintenance (Primary — Bi-monthly)

```
接单 → 扫码签到 → 按清单检查 → 润滑保养 → 记录数据 → 客户签字 → 完成
```

**Maintenance Checklist**:
- [ ] 机房环境（温度、湿度、照明、通风）
- [ ] 曳引机（油位、油质、振动、噪音）
- [ ] 控制柜（指示灯、接触器、继电器）
- [ ] 限速器（动作灵活、钢丝绳状态）
- [ ] 轿厢内（照明、通风、按钮、显示）
- [ ] 轿门（开关顺畅、间隙、安全触板）
- [ ] 层门（开关顺畅、间隙、锁紧）
- [ ] 导靴/导靴磨损
- [ ] 钢丝绳（磨损、断丝、张力）
- [ ] 缓冲器（状态）
- [ ] 平层精度
- [ ] 运行噪音/振动
- [ ] 紧急通讯装置
- [ ] 消防功能测试

### Annual Inspection

```
接单 → 准备资料 → 现场检验 → 整改项处理 → 取得报告 → 更新证书 → 完成
```

### Repair

```
接单 → 扫码识别 → 故障诊断 → 报价确认 → 维修处理 → 测试验收 → 收费 → 完成
```

**Common Faults**:

| 故障现象 | 可能原因 | 处理方式 |
|---------|---------|---------|
| 不运行 | 控制柜故障、安全回路断开 | 检查安全回路、更换部件 |
| 平层不准 | 编码器故障、导靴磨损 | 更换编码器、调整导靴 |
| 门故障 | 门机故障、门锁触点 | 更换门机、调整门锁 |
| 异常振动 | 导靴磨损、钢丝绳张力不均 | 更换导靴、调整绳张力 |
| 困人 | 安全回路动作、停电 | 盘车救援、检查原因 |

## Parts

| Category | Parts |
|----------|------|
| 电气 | 控制板、变频器、接触器、继电器、编码器 |
| 机械 | 曳引轮、钢丝绳、导靴、门机、门滑块 |
| 安全 | 限速器、安全钳、缓冲器、限位开关 |
| 耗材 | 润滑油、齿轮油、清洁剂 |

## References

- Data model: `references/data-model.md`
- Workflows: `references/workflows.md`
