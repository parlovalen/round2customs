# Design system

Reference for the visual language used across the Round 2 Customs site. Values are pulled from `styles.css` custom properties and repeated patterns — keep this in sync when those change.

## Color

| Token | Value | Use |
|---|---|---|
| `--bg` | `#000000` | Page background |
| `--terracotta` | `#b84d1a` | Brand accent — hover states, active states, eyebrow labels, CTA fills |
| `--white` | `#ffffff` | Primary text |
| `--gray-inactive` | `#3d3d3d` | Inactive pagination dots |

Secondary tones are expressed as white at reduced opacity rather than separate hex values, e.g.:
- `rgba(255,255,255,0.6)` — muted body text (footer address)
- `rgba(255,255,255,0.4)` — deemphasized text (footer copyright, placeholder text)
- `rgba(255,255,255,0.07)` — hairline borders, gradient fills on buttons/fields

## Typography

Two typefaces:
- **`--font-display`** — Halyard Display (Adobe Fonts). Bold, uppercase, tight tracking. Used for all headings, nav links, buttons, labels.
- **`--font-body`** — Gabarito (Google Fonts). Used for paragraph copy and form inputs.

### Type scale (desktop → tablet ≤1024px → mobile ≤768px)

| Element | Desktop | Tablet | Mobile |
|---|---|---|---|
| Hero `h1` | 100px / 92px line-height | 72px | `clamp(32px, 11vw, 44px)` — fluid below 768px |
| Section `h2` | 80px / 77px | 56px | 40px / 38px |
| Nav overlay links | 64px | 44px | 38px |
| Body copy | 16px / 26px | — | 15px / 24px |
| Eyebrow label | 15px, terracotta, uppercase-style tracking | — | — |

Letter-spacing is consistently tight-to-wide depending on size — larger display type gets more negative/positive tracking per the individual rule; don't assume a single global tracking value.

## Spacing

| Token | Desktop | Tablet | Mobile |
|---|---|---|---|
| `--page-pad` (horizontal section padding) | 120px | 60px | 24px |
| `--section-py` (vertical section padding) | 80px | 60px | 48px |
| `--gap` (general-purpose gap) | 24px | — | 16px |

Breakpoints: **1024px** (tablet), **768px** (mobile), plus a legacy **400px** small-phone tier that now only holds a couple of leftover overrides (button padding, nav link size) — most components rely on `clamp()` or the 768px tier alone rather than a third breakpoint, since a stale 400px override previously caused silent bugs (see `WORKLOG.md`). Prefer fluid sizing (`clamp()`) over adding new fixed breakpoints where practical.

## Components

### Buttons (`.btn-primary`)
Pill shape (`border-radius: 60px`), 58px tall, `--font-display` 13px semibold, uppercase. Base state is a subtle translucent gradient fill (`--btn-gradient`) with a 1px hairline border. On hover, a canvas-driven pixel-grid particle animation fills the button with terracotta (see `ButtonPixelGridEffect` in `scripts.js`) — this replaces the plain color-swap the button would otherwise get from its `::before` wipe fallback. Every primary CTA across the site (hero, split sections, contact form) shares this exact class for consistency — don't create one-off button styles.

### Form fields
Translucent gradient background (`--field-gradient`) matching the button gradient, 1px hairline border (`--field-border`), 6px radius. Border brightens to terracotta on focus/error.

### Section text blocks
`.hero-text`, `.section-text`, `.contact-header` share a scroll-reveal treatment: start faded + shifted down 28px, animate to full opacity/position the first time the section enters the viewport (`IntersectionObserver`, one-shot, not re-triggered on scroll back up).

### Photography
Hero and split-section images sit in `overflow:hidden` containers and get a subtle scroll-linked vertical parallax (`--parallax-y` custom property layered onto each image's own crop transform — see `WORKLOG.md` for why it's applied to the `<img>` and not the container).

### Carousel (Studio section)
Center-weighted stack: the active slide is full scale/opacity, neighbors sit at 0.576 scale / reduced opacity offset ±72%, everything further out fades to 0. Driven by GSAP tweens in `scripts.js`, not CSS transitions.

## Motion

- Respect `prefers-reduced-motion: reduce` for continuous/looping effects (image parallax, grid-line drift). Skip these entirely for reduced-motion users.
- One-shot entrance animations (text reveal) are mild enough to keep running regardless of that preference.
- Hover transitions are generally `0.2s ease` for color/opacity, `0.3–0.45s` for larger movements (button fill wipe, pagination dot width).

## Disabled/experimental features

A few visual treatments were built and then turned off via `display:none` or reset margins rather than deleted, in case they're revisited:
- `.grid-line` (vertical guide lines) and the `::before` horizontal streak highlights on section boundaries — animated accent lines, currently hidden.
- The desktop-only 24px section gutter inset (`@media (min-width: 1025px)` margin rule) — currently reset to 0.

Check `styles.css` near the top (`/* Vertical guide lines... */` and `/* Horizontal rules... */` comments) before re-enabling — the JS in `scripts.js` (`GRID LINES` section) that generates the randomized streak gradients is still active and paired with these.
