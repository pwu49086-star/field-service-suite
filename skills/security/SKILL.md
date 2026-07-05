---
name: security
description: |
  Security industry module for Field Service Suite.
  Use when:
  - Building security equipment installation and maintenance management
  - Creating security work orders (camera installation, access control setup, alarm maintenance)
  - Designing security asset databases with camera specs, storage, network config
  - Managing security system maintenance schedules and firmware updates
  - Building security brand/model databases (Hikvision, Dahua, Uniview, Axis, Honeywell)
  Do NOT use for other industries or generic field service tasks.
---

# Security Module

## Overview

Security module covers CCTV cameras, access control systems, alarm systems, intercoms, and related networking equipment. Key differentiator: **network configuration tracking** and **firmware management**.

## Asset Extension

```typescript
interface SecurityExtension {
  // Device type
  deviceType:
    | 'camera'            // 摄像头
    | 'nvr'               // 网络录像机
    | 'dvr'               // 数字录像机
    | 'access_control'    // 门禁控制器
    | 'card_reader'       // 读卡器
    | 'electric_lock'     // 电锁
    | 'alarm_panel'       // 报警主机
    | 'pir_sensor'        // 红外探测器
    | 'door_sensor'       // 门磁
    | 'siren'             // 警号
    | 'intercom'          // 对讲设备
    | 'monitor'           // 监视器
    | 'switch'            // 网络交换机
    | 'other';

  // Camera specs
  resolution?: string;         // 分辨率 (e.g., '4MP', '8MP', '4K')
  lensType?: string;           // 镜头类型 (e.g., '2.8mm', '3.6-12mm')
  nightVision?: boolean;       // 红外夜视
  nightVisionRange?: number;   // 夜视距离 (m)
  ptzCapable?: boolean;        // 云台功能
  waterproof?: boolean;        // 防水
  ipRating?: string;           // IP等级 (e.g., 'IP67')
  audioEnabled?: boolean;      // 有音频

  // Network
  ipAddress?: string;
  macAddress?: string;
  protocol?: string;           // 协议 (ONVIF, RTSP, Hikvision, Dahua)

  // Storage
  storageType?: 'nvr' | 'sd_card' | 'cloud' | 'nas';
  storageCapacity?: number;    // 存储容量 (TB)
  recordingDays?: number;      // 录像保存天数

  // Access control
  doorCount?: number;          // 门数量
  cardCapacity?: number;       // 卡容量
  accessMethod?: string[];     // ['刷卡', '密码', '指纹', '人脸']

  // Firmware
  firmwareVersion?: string;
  firmwareLastUpdate?: string;

  // Installation
  installationHeight?: number;  // 安装高度 (m)
  installationLocation?: 'indoor' | 'outdoor' | 'both';
  coverageAngle?: number;       // 覆盖角度
}
```

## Workflows

### Installation

```
接单 → 现场勘测 → 方案设计 → 报价确认 → 施工安装 → 调试验收 → 培训交付 → 完成
```

### Maintenance

```
接单 → 扫码签到 → 按清单检查 → 清洁保养 → 固件更新 → 记录数据 → 完成
```

**Camera Maintenance Checklist**:
- [ ] 镜头清洁
- [ ] 遮挡检查
- [ ] 红外灯正常
- [ ] 图像质量检查
- [ ] 录像回放测试
- [ ] 网络连接正常
- [ ] 存储状态检查
- [ ] 固件版本检查
- [ ] 防水密封检查

**Access Control Checklist**:
- [ ] 读卡器功能正常
- [ ] 电锁动作正常
- [ ] 出门按钮正常
- [ ] 门磁状态正确
- [ ] 联动报警测试
- [ ] 电池备用电源

### Repair

**Common Faults**:

| 故障 | 原因 | 处理 |
|------|------|------|
| 图像模糊 | 镜头脏、失焦 | 清洁、调焦 |
| 夜视效果差 | IR灯衰减、遮挡 | 更换IR灯 |
| 离线 | 网络故障、电源故障 | 检查网络和电源 |
| 录像丢失 | 硬盘故障、配置错误 | 更换硬盘 |
| 门禁不开 | 读卡器故障、电锁故障 | 更换设备 |
| 误报警 | 探测器灵敏度、环境干扰 | 调整灵敏度 |

## Parts

| Category | Parts |
|----------|------|
| 视频 | 摄像头、镜头、防护罩、支架 |
| 存储 | 硬盘、SD卡、NVR |
| 门禁 | 读卡器、电锁、出门按钮、门磁 |
| 报警 | 探测器、警号、按钮 |
| 网络 | 交换机、光纤收发器、网线 |
| 电源 | 电源适配器、UPS、POE交换机 |

## References

- Data model: `references/data-model.md`
- Workflows: `references/workflows.md`
