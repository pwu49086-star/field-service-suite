# Fire Safety Data Model

## Asset Extension Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| equipmentType | enum | Yes | extinguisher/alarm_panel/smoke_detector/heat_detector/sprinkler/fire_hydrant/fire_pump/emergency_light/exit_sign/fire_door/gas_suppression/kitchen_suppression/other |
| extinguisherType | enum | No | dry_powder/co2/foam/water/wet_chemical |
| extinguisherWeight | number | No | 重量 (kg) |
| extinguishClass | string | No | 灭火级别 (A, B, C, D, E, K) |
| coverageArea | number | No | 覆盖面积 (m²) |
| sensitivity | string | No | 灵敏度等级 |
| manufactureDate | date | No | 生产日期 |
| expiryDate | date | No | 有效期 |
| lastInspectionDate | date | No | 上次检查日期 |
| nextInspectionDate | date | No | 下次检查日期 |
| inspectionCycle | number | No | 检查周期（月） |
| certificationNo | string | No | 认证编号 |
| certificationBody | string | No | 认证机构 |
| buildingName | string | No | 建筑名称 |
| floorLevel | string | No | 楼层 |
| zone | string | No | 区域 |
| locationDescription | string | No | 具体位置 |
| pressureNormal | boolean | No | 压力正常 |
| pressureValue | number | No | 压力值 (MPa) |

## Extinguisher Types

| Type | Chinese | Use For | Lifespan |
|------|---------|---------|----------|
| dry_powder | 干粉 | A, B, C 类火灾 | 10 年 |
| co2 | 二氧化碳 | B, C 类、电气火灾 | 12 年 |
| foam | 泡沫 | A, B 类火灾 | 10 年 |
| water | 水基 | A 类火灾 | 10 年 |
| wet_chemical | 湿化学 | K 类（厨房） | 10 年 |

## Inspection Frequency

| Equipment | Visual Check | Full Inspection | Special |
|-----------|-------------|-----------------|---------|
| 灭火器 | 每月 | 每年 | 水压测试 5 年 |
| 探测器 | - | 每年 | 清洗标定每年 |
| 喷淋 | - | 每年 | - |
| 消火栓 | - | 每半年 | 试水测试 |
| 应急照明 | 每月 | 每年 | 电池 3-5 年 |
| 防火门 | - | 每季度 | - |
