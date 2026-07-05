# Solar Data Model

## Asset Extension Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| systemType | enum | Yes | residential/commercial/industrial/utility |
| gridType | enum | Yes | on_grid/off_grid/hybrid |
| panelBrand | string | No | 组件品牌 |
| panelModel | string | No | 组件型号 |
| panelCount | integer | No | 组件数量 |
| panelWattage | number | No | 单块功率 (W) |
| totalCapacity | number | No | 总装机容量 (kWp) |
| inverterBrand | string | No | 逆变器品牌 |
| inverterModel | string | No | 逆变器型号 |
| inverterCapacity | number | No | 逆变器容量 (kW) |
| inverterCount | integer | No | 逆变器数量 |
| hasBattery | boolean | No | 有无储能 |
| batteryBrand | string | No | 电池品牌 |
| batteryCapacity | number | No | 电池容量 (kWh) |
| batteryType | enum | No | lithium/lead_acid/flow |
| gridVoltage | enum | No | 220/380 |
| meterNo | string | No | 电表号 |
| installationAngle | number | No | 安装角度 (度) |
| installationDirection | string | No | 朝向 |
| roofType | enum | No | flat/tilted/ground |
| estimatedAnnualYield | number | No | 预计年发电量 (kWh) |
| actualAnnualYield | number | No | 实际年发电量 (kWh) |
| performanceRatio | number | No | 性能比 (%) |
| degradationRate | number | No | 年衰减率 (%) |
| monitoringPlatform | string | No | 监控平台 |
| monitoringUrl | string | No | 监控地址 |
| gridConnectionDate | date | No | 并网日期 |
| contractNo | string | No | 合同编号 |
| feedInTariff | number | No | 上网电价 (元/kWh) |

## System Types

| Type | Chinese | Typical Size |
|------|---------|-------------|
| residential | 户用 | 5-30 kWp |
| commercial | 工商业 | 30-500 kWp |
| industrial | 工业 | 500-5000 kWp |
| utility | 集中式 | 5000+ kWp |

## Performance Benchmarks

| Metric | Excellent | Good | Average | Poor |
|--------|-----------|------|---------|------|
| Performance Ratio | > 85% | 80-85% | 75-80% | < 75% |
| Annual Degradation | < 0.5% | 0.5-0.7% | 0.7-1.0% | > 1.0% |
| Availability | > 99% | 98-99% | 95-98% | < 95% |

## Warranty Rules

| Component | Typical Warranty |
|-----------|-----------------|
| 光伏组件 | 12 年产品质保，25 年线性功率质保 |
| 逆变器 | 5-10 年 |
| 支架 | 10 年 |
| 电池 | 5-10 年 |
