# Mobile UI Rules

## Design Principles

Technicians work on phones with gloves, in the sun, on ladders, in cramped spaces. Every pixel must earn its place.

## Layout Structure

```
┌─────────────────────────┐
│  Header (fixed)          │  ← Back + Title + Action
├─────────────────────────┤
│                          │
│  Content (scrollable)    │  ← Main content area
│                          │
├─────────────────────────┤
│  ActionBar (fixed)       │  ← Primary actions (large, prominent)
└─────────────────────────┘
```

## Size Rules

| Element | Minimum Size | Recommended |
|---------|-------------|-------------|
| Touch target | 44px × 44px | 48px × 48px |
| Primary button height | 48px | 56px |
| Font size (body) | 14px | 16px |
| Font size (heading) | 18px | 20px |
| Font size (caption) | 12px | 12px |
| Spacing (section) | 16px | 24px |
| Spacing (element) | 8px | 12px |
| Border radius | 8px | 12px |

## Interaction Rules

1. **Prefer selection over typing** — use dropdowns, chips, tags
2. **Prefer scanning over selection** — scan QR/barcode first
3. **Prefer OCR over scanning** — photo recognition for text
4. **Bottom Sheet over Modal** — easier to dismiss on mobile
5. **Toast over Alert** — non-blocking feedback
6. **Pull-to-refresh** — for list pages
7. **Swipe actions** — for common operations (complete, delete)
8. **Haptic feedback** — on critical actions (complete work order)

## Color & Contrast

- Background: `#FFFFFF` (light) or `#1A1A2E` (dark)
- Text primary: `#1A1A1A` (light) / `#F5F5F5` (dark)
- Text secondary: `#6B7280` (light) / `#9CA3AF` (dark)
- Accent/Primary: `#2563EB` (blue — professional, trustworthy)
- Success: `#10B981` (green)
- Warning: `#F59E0B` (amber)
- Error: `#EF4444` (red)
- Minimum contrast ratio: 4.5:1 (WCAG AA)

## Status Colors

| Status | Color | Background |
|--------|-------|------------|
| Draft | Gray | `bg-gray-100 text-gray-700` |
| Pending | Amber | `bg-amber-50 text-amber-700` |
| In Progress | Blue | `bg-blue-50 text-blue-700` |
| Paused | Orange | `bg-orange-50 text-orange-700` |
| Completed | Green | `bg-green-50 text-green-700` |
| Cancelled | Red | `bg-red-50 text-red-700` |

## Page Patterns

### List Page

- Search bar at top (sticky)
- Filter chips below search
- Card-based list items
- Pull-to-refresh
- Infinite scroll
- Empty state with illustration + CTA

### Detail Page

- Summary card at top
- Tab bar for sections (Timeline, Details, Attachments)
- Sticky action bar at bottom
- Swipe between tabs

### Form Page

- Grouped sections with headers
- Inline validation (on blur)
- Auto-save draft to IndexedDB
- Smart defaults (today's date, current technician)
- Camera/scan buttons inline with form fields

## Typography

```css
/* Use system font stack */
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;

/* Chinese: add PingFang SC for iOS, Noto Sans SC for Android */
font-family: -apple-system, BlinkMacSystemFont, 'PingFang SC', 'Noto Sans SC', 'Segoe UI', Roboto, sans-serif;
```
