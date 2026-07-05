# Water Purifier Workflows

## Filter Replacement (Primary Workflow)

Filter replacement is the most frequent service for water purifiers — far more common than repair.

### State Flow
```
接单 → 扫码识别 → 查看滤芯状态 → 更换滤芯 → 冲洗 → 水质测试 → 重置计时 → 完成
```

### Process Details

1. **扫码识别** — 扫描设备二维码，调取滤芯配置和安装日期
2. **查看滤芯状态** — 系统自动计算各滤芯剩余寿命
   - 绿色 (> 30% 剩余): 正常
   - 黄色 (10-30% 剩余): 即将到期
   - 红色 (< 10% 或已过期): 需要更换
3. **更换到期滤芯** — 按照滤芯位置逐个更换
4. **冲洗** — 打开进水阀，冲洗新滤芯 15-30 分钟
5. **水质测试** — 测量出水 TDS，确认达标
6. **重置计时** — 在系统中重置已更换滤芯的计时器
7. **记录** — 记录更换的滤芯型号、日期、技师

### Filter Lifespan Calculation

```typescript
function getFilterStatus(filter: FilterInfo): 'active' | 'due_soon' | 'expired' {
  if (!filter.installedDate || !filter.expectedLifespan) return 'active';

  const installed = new Date(filter.installedDate);
  const expiryDate = new Date(installed);
  expiryDate.setMonth(expiryDate.getMonth() + filter.expectedLifespan);

  const now = new Date();
  const daysRemaining = Math.ceil((expiryDate.getTime() - now.getTime()) / 86400000);
  const totalDays = filter.expectedLifespan * 30;
  const percentRemaining = (daysRemaining / totalDays) * 100;

  if (percentRemaining <= 0) return 'expired';
  if (percentRemaining <= 30) return 'due_soon';
  return 'active';
}
```

## Installation

### State Flow
```
接单 → 上门勘测 → 确认水源 → 安装设备 → 冲洗管路 → 水质测试 → 客户验收 → 完成
```

### Installation Checklist

- [ ] 确认水源类型（自来水/井水）
- [ ] 测量进水 TDS（基线值）
- [ ] 确认水压（0.1-0.4 MPa）
- [ ] 确认安装位置和空间
- [ ] 关闭进水阀
- [ ] 安装进水三通
- [ ] 安装主机（RO 机型需要电源）
- [ ] 安装压力桶（RO 机型）
- [ ] 安装鹅颈龙头
- [ ] 连接各段水管
- [ ] 打开进水阀
- [ ] 冲洗管路 15-30 分钟
- [ ] 测量出水 TDS（确认达标）
- [ ] 检查所有接头漏水
- [ ] 记录滤芯安装日期
- [ ] 客户验收签字

### Post-Installation

- 记录进水 TDS 基线值
- 记录出水 TDS
- 设置滤芯更换提醒（根据滤芯类型设置不同周期）
- 登记设备到客户名下

## Repair

### State Flow
```
接单 → 扫码识别 → 故障诊断 → 报价确认 → 维修处理 → 水质测试 → 收费 → 完成
```

### Common Faults

| 故障现象 | 可能原因 | 处理方式 | 配件 |
|---------|---------|---------|------|
| 出水 TDS 高 | RO 膜失效 | 更换 RO 膜 | RO膜 |
| 不出水 | 水压不足、管路堵塞 | 检查水压、清理管路 | - |
| 不出水 | 水泵故障 | 更换水泵 | 水泵 |
| 漏水 | 接头松动 | 紧固接头 | - |
| 漏水 | 管路老化、密封圈损坏 | 更换管路/密封圈 | 管路、密封圈 |
| 噪音大 | 水泵异常 | 更换水泵 | 水泵 |
| 出水量小 | 滤芯堵塞 | 更换滤芯 | 滤芯 |
| 出水量小 | 压力桶气压不足 | 充气或更换压力桶 | 压力桶 |
| 异味 | 滤芯失效 | 更换滤芯 | 滤芯 |
| 不制水（RO） | 进水电磁阀故障 | 更换电磁阀 | 电磁阀 |
| 一直冲洗 | 冲洗电磁阀故障 | 更换电磁阀 | 电磁阀 |

## Water Quality Test

### State Flow
```
接单 → 扫码签到 → 采样 → 测试 TDS/pH/余氯 → 记录数据 → 生成报告 → 完成
```

### Test Parameters

| Parameter | Method | Target |
|-----------|--------|--------|
| TDS | TDS 笔 | < 100 ppm (RO), < 300 ppm (UF) |
| pH | pH 试纸/仪 | 6.5-8.5 |
| 余氯 | 余氯测试剂 | < 0.05 mg/L (RO), < 0.3 mg/L (UF) |

### TDS Trend Analysis

```
正常: 出水 TDS 稳定在 10-50 ppm，去除率 > 90%
警告: 出水 TDS 上升到 50-100 ppm，去除率 70-90%
异常: 出水 TDS > 100 ppm，去除率 < 70% → 需要更换 RO 膜
```
