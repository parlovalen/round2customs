# Portfolio Case Study — Design Rules

Rules derived from `kch.html`. Apply these to all case study pages for consistency.

---

## Typography

| Role | Tag | Size | Weight | Letter-spacing | Line-height |
|---|---|---|---|---|---|
| Hero headline | `h1.hero-tagline` | 56px | 500 | −3px | 66px |
| Section heading (split) | `h3.split-heading` | 48px | 500 | −2px | 52px |
| Section intro (full-width) | `h3.t-intro` | 48px | 500 | −2px | 52px |
| Body copy | `.t-body` | 18px | 400 | — | 1.6 |
| Eyebrow label | `.eyebrow` | 12px | 600 | 0.08em | — |
| Nav / footer links | — | 16–20px | 300 | — | — |

- Font: **Inter** (Google Fonts, weights 300–700)
- Body default weight: **300**
- `t-body` max-width: **660px**, margin-top: 28px from heading
- Paragraph spacing inside `.t-body`: **18px** (via `p + p`)

---

## Color

| Token | Light | Dark |
|---|---|---|
| Background | `#fff` | `#111` |
| Text | `#000` | `#f0f0f0` |
| Body copy | `#111` | `rgba(255,255,255,0.6)` |
| Eyebrow | `#000` | `#FFC200` (KC brand amber) |
| Dividers / borders | `#ccc` | `#333` |
| Navbar border | `#e0e0e0` | `#222` |
| Image outline | `rgba(0,0,0,0.08)` | `rgba(255,255,255,0.08)` |
| CTA button | `#000 / #fff` | `#FFC200 / #000` |
| CTA hover | `#ff3700` | `#e6af00` |
| Carousel active dot | `#000` | `#fff` |
| Carousel inactive dot | `rgba(0,0,0,0.18)` | `rgba(255,255,255,0.2)` |

Brand accent: **`#ff3700`** (KC orange-red) — used for CTA hover and carousel cursor arrows.

---

## Spacing

| Context | Value |
|---|---|
| Default row gap (`.row`) | 120px bottom margin |
| Tight row gap (`.row.gap-sm`) | 60px |
| Extra-tight row gap (`.row.gap-xs`) | 24px |
| Page side padding (text) | 12% |
| Page side padding (images/carousel) | 60px |
| Hero top padding | 160px |
| Section heading → body copy | 24px (split) / 28px (t-body margin-top) |
| Eyebrow → heading | 20px |
| Divider margins | 80px top, 120px bottom |
| Split section column gap | 80px |
| Stacked images in split | 40px gap |

---

## Layout Patterns

### Full-width image
```html
<div class="img-full row">
  <img src="..." alt="...">
</div>
```
Padding: 0 60px. Border-radius: 20px. Outline: 1px rgba(0,0,0,0.08).

### 2-column image grid
```html
<div class="img-2col row">
  <img src="..."> <img src="...">
</div>
```
Default: `1fr 1fr`, gap 24px. For asymmetric splits use inline `grid-template-columns` (e.g. `7fr 3fr`).
When heights must match: add `align-items: stretch` to grid + `height:100%; object-fit:cover` on images.

### Split section (text left, images right)
```html
<div class="split-section">
  <div class="split-text">
    <span class="eyebrow">Label</span>
    <h3 class="split-heading">Heading</h3>
    <div class="t-body"><p>...</p></div>
  </div>
  <div class="split-images">
    <img src="..."> <img src="...">
  </div>
</div>
```
Grid: `5fr 7fr`. Use `padding-bottom` inline if the section sits directly before an image (skip `.row` on this element to avoid doubling the gap).

### Full-width text section
```html
<div class="tb row gap-sm">
  <span class="eyebrow">Label</span>
  <h3 class="t-intro">Heading</h3>
  <div class="t-body"><p>...</p></div>
</div>
```
Padding: 0 12%.

### Carousel (single visible slide)
- Container: `.carousel` (padding 0 60px)
- Inner: `.carousel-inner` (overflow hidden, border-radius 20px, `cursor:none`)
- Track: `.carousel-track` (flex, gap 24px, transition 0.55s cubic-bezier)
- Slides: width set in JS from `inner.clientWidth` to handle CSS gap correctly
- Pagination: dash-style `.dot` elements (32×2px), not circles
- Custom cursor: fixed-position SVG, arrow with tail, color `#ff3700`, 140×140px viewBox 0 0 96 96

---

## Images

- **All images**: `border-radius: 20px`
- **Standard outline**: `outline: 1px solid rgba(0,0,0,0.08)` (use `outline` not `border` to avoid layout impact)
- **No outline**: add `style="outline:none;"` inline — used when image has its own natural edge (mockups on transparent bg, mobile frames, etc.)
- **object-fit**: use `contain` for specs/diagrams; `cover` when heights must match in a grid
- **Video covers**: same border-radius and container treatment as images (`border-radius:20px`, `width:100%`)

---

## Dark Mode

- Toggled via `.dark` class on `<body>`
- Per-page persistence via `localStorage` key (e.g. `kch-theme`)
- Toggle UI: sun/moon pill in hero logo row, aligned right
- Transition: `0.8s ease` on `background-color`, `color`, `border-color`, `filter`, `box-shadow`
- Logo inversion: `filter: brightness(0) invert(1)` in dark mode
- The transition selector list must include every element that changes color — extend it when adding new components

---

## Section Structure Convention

Every content section follows this sequence:
1. **Eyebrow** — `.eyebrow` label (12px caps, describes what the section is)
2. **Heading** — `h3` with `.t-intro` or `.split-heading`
3. **Body copy** — `.t-body` with one or more `<p>` tags
4. **Visual** — image, carousel, or grid directly after

Eyebrow labels are always sentence-case descriptors: *Overview, Research & Planning, Information Architecture, Navigation Concepts, Design System, How it comes together.*

---

## Navigation / Chrome

- Fixed navbar: `padding: 24px 60px`, `border-bottom: 1px solid #e0e0e0`, `background: #fff`
- Brand name left, "Home" back-link right — both 16px weight 300
- Back link: `opacity: 0.45` default, `opacity: 1` on hover (no color change)
- Footer nav: space-between, `opacity: 0.45` → `1` on hover, `padding: 40px 60px 120px`

---

## Responsive Breakpoints

| Breakpoint | Key changes |
|---|---|
| ≤ 1100px | Hero tagline → 38px, t-intro → 32px, split-heading → 34px, split gap → 48px |
| ≤ 768px | Navbar padding → 24px, hero padding → 100px, hero tagline → 26px, 2-col grid → 1 col, split → 1 col |

---

## What Not To Do

- Don't use `border` on images — use `outline` to keep layout stable
- Don't mix `.row` margin with `split-section` padding-bottom (doubles the gap)
- Don't use `min-width: 100%` on carousel slides — use JS pixel widths from `inner.clientWidth`
- Don't use `border-radius` on `.carousel-slide img` when the inner container already clips (removes double-radius)
- Don't add new color elements without adding them to the dark mode transition selector list
