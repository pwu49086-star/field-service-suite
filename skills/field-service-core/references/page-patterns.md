# Page Patterns

## Standard Page Structure

```
┌─────────────────────────┐
│  Header (fixed)          │  ← Back + Title + Action
├─────────────────────────┤
│  Content (scrollable)    │
├─────────────────────────┤
│  ActionBar (fixed)       │  ← Primary actions
└─────────────────────────┘
```

## Common Page Types

### List Page
- Sticky search bar
- Filter chips
- Card-based items
- Pull-to-refresh
- Infinite scroll
- FAB for create

### Detail Page
- Summary card at top
- Tab bar (Timeline, Details, Attachments)
- Sticky action bar

### Form Page
- Grouped sections
- Inline validation
- Auto-save draft
- Camera/scan inline

### Scanner Page
- Full-screen camera
- Scan overlay frame
- Result area at bottom
- Manual entry fallback

## Touch Targets

Minimum 44px, prefer 48px. Primary buttons 56px height.

## Status Display

Use colored badges: pending=amber, in_progress=blue, completed=green, cancelled=red.
