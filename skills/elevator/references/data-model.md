# Elevator Data Model

## Asset Extension Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| elevatorType | enum | Yes | passenger/freight/residential/escalator/moving_walk/hospital/observation/other |
| loadCapacity | number | Yes | 载重 (kg) |
| speed | number | Yes | 速度 (m/s) |
| floors | number | Yes | 服务楼层数 |
| floorRange | string | Yes | 楼层范围 (e.g., 'B2-F30') |
| travelHeight | number | No | 提升高度 (m) |
| machineRoomType | enum | Yes | machine_room/machine_room_less |
| machineRoomLocation | string | No | 机房位置 |
| driveType | enum | Yes | traction/hydraulic/screw/belt |
| controlType | string | No | 控制方式 (VVVF, AC-2) |
| doorType | string | No | 门类型 |
| registrationNo | string | No | 注册代码 |
| registrationDate | date | No | 注册日期 |
| useCertificateNo | string | No | 使用证书编号 |
| useCertificateExpiry | date | No | 使用证书有效期 |
| lastInspectionDate | date | No | 上次检验日期 |
| nextInspectionDate | date | No | 下次检验日期 |
| inspectionResult | enum | No | pass/fail/conditional |
| inspectionAgency | string | No | 检验机构 |
| emergencyPhone | boolean | No | 紧急电话 |
| fireServiceMode | boolean | No | 消防功能 |
| earthquakeDevice | boolean | No | 地震感知装置 |

## Elevator Types

| Type | Chinese | Typical Speed | Typical Load |
|------|---------|--------------|-------------|
| passenger | 乘客电梯 | 1.0-10.0 m/s | 630-2500 kg |
| freight | 货梯 | 0.25-1.0 m/s | 1000-5000 kg |
| residential | 住宅电梯 | 1.0-1.75 m/s | 400-1000 kg |
| escalator | 自动扶梯 | 0.5-0.65 m/s | - |
| moving_walk | 自动人行道 | 0.5-0.75 m/s | - |
| hospital | 医用电梯 | 1.0-2.5 m/s | 1600-2500 kg |
| observation | 观光电梯 | 1.0-3.0 m/s | 1000-2000 kg |

## Drive Types

| Type | Chinese | Description |
|------|---------|-------------|
| traction | 曳引 | 钢丝绳+曳引轮，最常见 |
| hydraulic | 液压 | 液压缸驱动，低层建筑 |
| screw | 螺杆 | 螺杆螺母驱动，家用 |
| belt | 皮带 | 皮带驱动，家用 |

## Warranty Rules

| Component | Typical Warranty |
|-----------|-----------------|
| 整机 | 1-2 年 |
| 主机 | 3-5 年 |
| 控制柜 | 2-3 年 |
| 门机 | 2-3 年 |
| 钢丝绳 | 5 年 |

## Maintenance Frequency

| Building Type | Frequency |
|--------------|-----------|
| 商业/办公 | 每月 2 次 |
| 住宅 | 每月 1-2 次 |
| 医院 | 每月 2-3 次 |
| 地铁/机场 | 每月 3-4 次 |
