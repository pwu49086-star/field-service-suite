# Water Purifier Data Model

## Asset Extension Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| purifierType | enum | Yes | ro/uf/uv/nanofiltration/water_softener/commercial/other |
| waterSource | enum | Yes | tap/well/other |
| flowRate | number | No | 流量 (L/h or GPD) |
| flowRateUnit | enum | No | LPH/GPD |
| tankCapacity | number | No | 压力桶容量 (L) |
| inletTDS | number | No | 进水 TDS (ppm) |
| outletTDS | number | No | 出水 TDS (ppm) |
| targetTDS | number | No | 目标 TDS (ppm) |
| filters | FilterInfo[] | Yes | 滤芯配置 |
| hasTDSMonitor | boolean | No | 有 TDS 监测 |
| hasFilterReminder | boolean | No | 有滤芯更换提醒 |
| hasLeakDetection | boolean | No | 有漏水检测 |
| connectivity | enum | No | wifi/none |
| installationLocation | enum | No | 厨房/卫生间/阳台/other |
| installationType | enum | No | under_sink/countertop/whole_house/commercial |
| purchaseDate | date | No | 购买日期 |
| purchaseChannel | string | No | 购买渠道 |

## Filter Info Structure

```typescript
interface FilterInfo {
  position: number;           // 滤芯位置 (1, 2, 3, ...)
  type: FilterType;           // 滤芯类型
  typeName: string;           // 中文名称
  model?: string;             // 滤芯型号
  installedDate?: string;     // 安装日期
  expectedLifespan?: number;  // 预期寿命 (月)
  replacementDate?: string;   // 实际更换日期
  status: 'active' | 'due_soon' | 'expired' | 'replaced';
}
```

## Purifier Types

| Type | Chinese | Description | Key Feature |
|------|---------|-------------|------------|
| ro | 反渗透 | Reverse Osmosis | 去除率最高，需要水泵 |
| uf | 超滤 | Ultrafiltration | 保留矿物质，不需要水泵 |
| uv | 紫外线 | UV Sterilization | 杀菌，不改变 TDS |
| nanofiltration | 纳滤 | Nanofiltration | 介于 RO 和 UF 之间 |
| water_softener | 软水机 | Water Softener | 去除钙镁离子 |
| commercial | 商用 | Commercial | 大流量商用设备 |

## Typical Filter Configuration

### RO System (4-5 stage)

| Stage | Type | Chinese | Lifespan |
|-------|------|---------|----------|
| 1 | pp | PP棉 | 3-6 月 |
| 2 | cto | 前置活性炭 | 6-12 月 |
| 3 | pp | PP棉 (可选) | 3-6 月 |
| 4 | ro_membrane | RO膜 | 2-3 年 |
| 5 | t33 | 后置活性炭 | 6-12 月 |

### UF System (3-4 stage)

| Stage | Type | Chinese | Lifespan |
|-------|------|---------|----------|
| 1 | pp | PP棉 | 3-6 月 |
| 2 | cto | 活性炭 | 6-12 月 |
| 3 | uf_membrane | 超滤膜 | 1-2 年 |
| 4 | t33 | 后置活性炭 (可选) | 6-12 月 |

## TDS Standards

| Category | TDS Range (ppm) | Meaning |
|----------|----------------|---------|
| Excellent | 0-50 | 纯净水标准 |
| Good | 50-100 | 优质饮用水 |
| Acceptable | 100-300 | 可接受 |
| Poor | > 300 | 需要处理 |

## Warranty Rules

| Component | Typical Warranty |
|-----------|-----------------|
| 整机 | 1-2 年 |
| RO膜 | 2-3 年 |
| 水泵 | 2-3 年 |
| 压力桶 | 3 年 |
| 滤芯 | 耗材，不在保修范围 |

## Indexes

```typescript
assets: '++id, serialNumber, brandId, modelId, customerId, category, status, extension.purifierType'
```
