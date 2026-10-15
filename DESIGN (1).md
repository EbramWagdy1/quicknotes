---
name: Paper Slate
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#464555'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#777587'
  outline-variant: '#c7c4d8'
  surface-tint: '#4d44e3'
  primary: '#3525cd'
  on-primary: '#ffffff'
  primary-container: '#4f46e5'
  on-primary-container: '#dad7ff'
  inverse-primary: '#c3c0ff'
  secondary: '#4648d4'
  on-secondary: '#ffffff'
  secondary-container: '#6063ee'
  on-secondary-container: '#fffbff'
  tertiary: '#004d70'
  on-tertiary: '#ffffff'
  tertiary-container: '#006693'
  on-tertiary-container: '#b8e0ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e2dfff'
  primary-fixed-dim: '#c3c0ff'
  on-primary-fixed: '#0f0069'
  on-primary-fixed-variant: '#3323cc'
  secondary-fixed: '#e1e0ff'
  secondary-fixed-dim: '#c0c1ff'
  on-secondary-fixed: '#07006c'
  on-secondary-fixed-variant: '#2f2ebe'
  tertiary-fixed: '#c9e6ff'
  tertiary-fixed-dim: '#89ceff'
  on-tertiary-fixed: '#001e2f'
  on-tertiary-fixed-variant: '#004c6e'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display-lg:
    fontFamily: Hanken Grotesk
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.015em
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.005em
  headline-sm:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 22px
  body-sm:
    fontFamily: Hanken Grotesk
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  label-md:
    fontFamily: Hanken Grotesk
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Hanken Grotesk
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-tablet: 1.25rem
  gutter-desktop: 1.5rem
  margin: 1rem
  margin-tablet: 1.5rem
  margin-desktop: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system embodies a serene, hyper-focused digital workspace tailored for capturing thoughts, organizing structured notes, and archiving spontaneous ideas without cognitive friction. Merging the deliberate typographic discipline of modern iOS human interfaces with the functional material architecture and expressive tactile transitions of Flutter and Material 3, the design communicates intentional clarity, responsiveness, and quiet utility.

The aesthetic rests on high-legibility minimalism elevated by warm, tactile surfaces that mirror fine paper stationery. Interfaces avoid loud visual ornamentation, relying instead on disciplined spacing, crisp grotesk typography, soft boundary outlines, and subtle elevation changes. Visual momentum is reserved for user actions: crisp floating controls, effortless modal slide transitions, and deliberate metadata chips. The emotional tone is grounded, calm, and dependable—evoking the focus of a blank desk prepared for deep thought.

## Colors

The palette establishes an uncluttered, distraction-free environment centered around deep indigo accents paired with clean, warm-slate paper neutrals. 

- **Primary (`#4F46E5`) & Secondary (`#6366F1`):** Indigo serves as the focal driver for actionable interface elements, high-priority icons, focus rings, and selection indicators. Its muted variant drives soft tint surfaces such as active chip backgrounds and highlighted text.
- **Tertiary (`#0EA5E9`):** A soft, crisp sky blue reserved specifically for semantic ambient data: geolocation markers, synchronization indicators, and linked reference pills.
- **Neutrals & Surfaces:**
  - Canvas / Background: `#F8FAFC` provides an off-white, paper-like warmth that softens screen glare compared to pure white.
  - Surface Elevated / Card Fill: `#FFFFFF` ensures crisp contrast against the canvas.
  - Borders & Dividers: `#E2E8F0` for subtle low-contrast boundaries; `#CBD5E1` for hover and active container states.
  - Typography: `#0F172A` (Slate 900) for primary headlines and long-form note content, `#475569` (Slate 600) for subheadings and body descriptions, and `#94A3B8` (Slate 400) for tertiary timestamps and empty-state hints.
- **Functional Semantics:** Soft coral red (`#EF4444`) for destructive confirmations (note deletion, purge history) and soft emerald (`#10B981`) for saved status cues.

## Typography

The design system standardizes on `Hanken Grotesk`, a modern grotesque typeface featuring crisp letterforms, generous counters, and balanced vertical metrics. It delivers readability across dense note bodies while projecting a sharp, engineered aesthetic in headlines and operational labels.

- **Headlines & Titles:** Note titles and screen headers employ medium-to-bold weights with negative tracking (`-0.01em` to `-0.02em`), keeping titles visually tight and authoritative without feeling bulky.
- **Reading Body:** Paragraphs maintain a relaxed line-height ratio (`1.6x` on desktop and mobile) to preserve optical tracking over multi-line reading, note drafting, and checklist parsing.
- **Metadata & Labels:** Metadata tags, creation dates, character counters, and semantic pills utilize medium and semibold weights at `11px–13px`, using slight positive tracking to ensure instant scannability on small form factors.

## Layout & Spacing

The system implements a mobile-first fluid layout based on an 8-point base grid system (with 4-point micro-increments for internal chip spacing and icon alignments).

- **Mobile (<640px):** Content adheres to a 4-column fluid layout with an outer canvas edge margin of `1rem` (`16px`) and gutters of `1rem`. Full-bleed presentation is favored for active note-writing canvases, maximizing edge-to-edge drafting width while preserving a `16px` safe horizontal text gutter.
- **Tablet (640px–1024px):** Reflows to an 8-column layout with `1.5rem` margins. The interface transitions to a dual-pane master-detail pattern (note list on the left 3 columns, active editor on the right 5 columns).
- **Desktop (>=1024px):** A 12-column grid constrained to a maximum width of `1280px`. Left navigation rail occupies 2 columns, note archive/filter list occupies 4 columns, and the primary reading/editing surface takes 6 columns.

Vertical rhythm adheres strictly to tokens: micro-elements (chips, metadata items) use `space-xs` and `space-sm`, card internal spacing uses `space-md`, and structural layout sections use `space-lg` to `space-xl`.

## Elevation & Depth

Depth is established through a hybrid model combining Material 3 surface tonal tiers with iOS-inspired low-contrast ghost outlines and soft ambient shadows.

1. **Base Tier (Ground / Canvas):** Hex `#F8FAFC`. Zero elevation, zero shadow.
2. **Surface Tier 1 (Resting Cards, Chips, List Rows):** Pure white `#FFFFFF` paired with a low-contrast 1px border (`#E2E8F0`) and an ambient tinted drop shadow: `0px 1px 3px rgba(15, 23, 42, 0.04), 0px 1px 2px rgba(15, 23, 42, 0.02)`.
3. **Surface Tier 2 (Hovered Cards, Sticky Navigation, Segmented Controls):** `#FFFFFF` with a 1px border (`#CBD5E1`) and a softened elevation lift: `0px 4px 6px -1px rgba(15, 23, 42, 0.06), 0px 2px 4px -2px rgba(15, 23, 42, 0.04)`.
4. **Surface Tier 3 (Floating Action Button & Dropdowns):** Primary or neutral container elevated via `0px 10px 15px -3px rgba(79, 70, 229, 0.18), 0px 4px 6px -4px rgba(79, 70, 229, 0.1)`.
5. **Surface Tier 4 (Modal Sheets, Alert Dialogs, Undo Toast Overlays):** `#FFFFFF` paired with an ambient backdrop overlay (`rgba(15, 23, 42, 0.35)` with an 8px blur filter). Bottom sheets drop shadow: `0px -8px 24px -4px rgba(15, 23, 42, 0.12)`.

## Shapes

The design system utilizes roundedness level `2` (`0.5rem` / `8px` standard radius). This bridges the structured efficiency of productivity tooling with the approachability of modern consumer mobile platforms.

- **Small Components (Chips, Badges, Metadata Tags, Checkboxes):** `0.375rem` (`6px`) to `0.5rem` (`8px`) curvature, ensuring crisp perimeter clarity in dense visual streams.
- **Medium Components (List Cards, Text Input Fields, Buttons):** Standard radius of `0.75rem` (`12px`) for comfortable thumb-targeting and clear boundary containment.
- **Large Containers (Modal Bottom Sheets, Editor Panels):** `1rem` (`16px`) to `1.5rem` (`24px`) top-corner radius, delivering smooth, organic sheet pull-ups.
- **Floating Controls (FABs, Avatar Pills, Floating Bar Containers):** Full pill (`9999px`) styling for primary contextual actions to distinguish dynamic interactions from structured content cards.

## Components

### Buttons & Floating Action Buttons (FAB)
- **Primary Action Button:** Solid `#4F46E5` background, `#FFFFFF` text, `0.75rem` radius, `44px` minimum touch height. Active state applies `#4338CA` with a subtle `scale(0.98)` spring animation.
- **Secondary Button:** Surface `#FFFFFF` with a 1px `#E2E8F0` border, `#0F172A` text, and `#F1F5F9` hover/pressed tint.
- **Floating Action Button (New Note):** Extended pill or 56px rounded circle floating `16px` above the bottom safe area. High-contrast `#4F46E5` fill with `#FFFFFF` glyph, elevated by Indigo ambient drop-shadow. Shrinks smoothly to an icon-only pill upon downward list scroll.

### Chips & Metadata Tags
- **Timestamp & Location Chips:** Inline tags styled with `0.375rem` radius, `space-xs` vertical padding, and `space-sm` horizontal padding. Geolocation tags render a `#0EA5E9` dot indicator with `#E0F2FE` background; timestamps use Slate `#F1F5F9` background and `#475569` text.
- **Filter Chips:** Tonal chips that toggle to solid `#4F46E5` with `#FFFFFF` text when selected.

### Note List Cards
- **Card Container:** `#FFFFFF` background, 1px `#E2E8F0` border, `12px` border radius, `space-md` internal padding.
- **Structure:** Title (`headline-sm`, 1-line clamp), body snippet (`body-sm`, 2-line clamp, `#475569`), bottom footer row housing timestamp, tag pills, and attachment icons. Hover or press elevates to Tier 2 with smooth transition.

### Input Fields & Search Bars
- **Search Header:** Pill-shaped (`9999px`) `#F1F5F9` input container with search icon prefix, clear button suffix, and inset focus border in `#6366F1`.
- **Note Content Editor:** Borderless canvas. Note title field uses `display-lg-mobile` (`28px`), auto-resizing vertically. Note body field renders unbordered Markdown-supported canvas utilizing `body-lg` (`16px`), `26px` line-height.

### Checkboxes & Todo Rows
- **Checkbox:** `20px × 20px` container with `6px` radius. Unchecked shows `#CBD5E1` 1.5px border. Checked renders `#4F46E5` with `#FFFFFF` checkmark icon. Checking triggers a strikethrough transition on the sibling text with a subtle opacity drop to `0.45`.

### Modal Sheets & Undo Feedback Overlays
- **Modal Bottom Sheet (Confirm Delete / Note Settings):** Slips up from the bottom with a 16px top corner radius, drag handle pill (`36px × 4px`, `#CBD5E1`) centered at the top. Destructive actions highlighted in solid `#EF4444`.
- **Shake Gesture Feedback (Undo Bar):** Floating pill snackbar positioned above bottom navigation with spring damping. Includes a shake-to-undo prompt with an explicit "Undo" primary text button and 5-second countdown progress line.

### Empty & Archival States
- **Zero-State Display:** Clean graphic layout featuring an airy 48px minimalist vector line icon in `#94A3B8`, a bold `headline-md` ("No notes yet"), a supportive 2-line explanation in `body-sm`, followed by a primary "Create First Note" action button.