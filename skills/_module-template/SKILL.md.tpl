---
name: {{module-name}}
description: |
  {{Industry Name}} industry module for Field Service Suite.
  Use when:
  - Building {{industry}} asset management
  - Creating {{industry}} work orders (installation, repair, maintenance, inspection)
  - Designing {{industry}} equipment databases
  - Implementing {{industry}}-specific OCR or scanning
  Do NOT use for other industries or generic field service tasks.
---

# {{Industry Name}} Module

## Overview

{{Industry Name}} is an industry module for Field Service Suite. It extends the core Asset model with industry-specific fields, workflows, and checklists.

## Asset Extension

```typescript
interface {{Industry}}Extension {
  // Add your industry-specific fields here
  // Example:
  // field1: string;
  // field2: number;
  // field3: 'option_a' | 'option_b' | 'option_c';
}
```

## Workflows

### Installation

```
接单 → 上门勘测 → 报价确认 → 施工安装 → 调试验收 → 客户签字 → 完成
```

### Repair

```
接单 → 扫码识别 → 故障诊断 → 报价确认 → 维修处理 → 测试验收 → 收费 → 完成
```

### Maintenance

```
接单 → 扫码识别 → 按清单检查 → 清洗保养 → 更换配件 → 记录数据 → 完成
```

## OCR

If your industry has nameplate or label recognition needs, register a parser:

```typescript
ocrEngine.registerParser('nameplate', '{{module-name}}', {
  patterns: [
    { regex: /PATTERN/i, field: 'fieldName' },
  ],
});
```

## Parts

List common parts for your industry:

| Category | Parts |
|----------|-------|
| Category 1 | Part A, Part B |
| Category 2 | Part C, Part D |

## References

- Data model: `references/data-model.md`
- Workflows: `references/workflows.md`
