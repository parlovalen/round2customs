# Round 2 Customs — Design System

> _"Timeless nostalgia, modern performance."_

Round 2 Customs (R2C) is a small, premium custom arcade cabinet builder based in **Lake Barrington, Illinois**. Their machines are handcrafted, bespoke builds aimed at retro-gaming enthusiasts, collectors, and businesses outfitting game rooms or commercial entertainment spaces. The brand positions itself as the **artisan alternative** to flimsy mass-market cabinets — gamers who also happen to be serious makers (the founder's background combines electrical engineering and woodworking).

This design system codifies their visual language: **dark cabinet-black canvases**, **neon arcade accents** (orange first, with blue / yellow / red support), wide-tracked uppercase display type, and a playful tone built on gaming tropes ("INSERT COIN", "PRESS START", "READY PLAYER 1?") that's always backed up with talk of craftsmanship.

---

## Source Materials

This system was built from the following uploaded references (also stored in `/uploads`):

| File | What it shows |
|---|---|
| `R2C-logo-blackRed.png` | Primary wordmark — "R2C" in white + signature orange `2` |
| `business-card.png` | Color palette, neon underline motif, pixel cursor/icon usage |
| `r2c-freestanding-banner-33x79.5_FINAL.jpg` | Hero photography style, smoke + neon backdrop, rainbow stripe motif |
| `website.jpg` | Full website screenshot — confirms layout, sections, and copy patterns |

We were **not** given a Figma file, codebase, or a slide template, so:
- The website UI kit is reconstructed from the website screenshot — pixel-for-pixel where readable, otherwise inferred from the rest of the brand collateral.
- Fonts are sourced from **Google Fonts** (Michroma / Onest / Press Start 2P) — flagged below.

---

## Index

```
.
├── README.md                ← you are here
├── SKILL.md                 ← agent skill manifest
├── colors_and_type.css      ← all design tokens (CSS vars) — colors, type, spacing, shadows
├── assets/
│   ├── r2c-logo.png         ← primary wordmark
│   ├── business-card.png    ← color/typography reference
│   ├── banner.jpg           ← hero photography reference
│   └── website-reference.jpg
├── preview/                 ← design system cards (registered in the DS tab)
│   └── *.html
└── ui_kits/
    └── website/             ← marketing-site UI kit (recreation)
        ├── index.html
        └── components/*.jsx
```

---

## Content Fundamentals

**Voice:** _Playful but credible._ R2C uses gaming language to create immersion — every section header is a gaming trope — but always grounds it in craft language ("handcrafted", "engineered", "stand the test of time").

**Casing:** Section headers are **ALL CAPS, wide-tracked** (`letter-spacing: 0.18em`+). Body copy is sentence-case, conversational. Labels and eyebrows above headers are also caps (smaller, even wider tracking).

**Pronouns:** "We" (R2C) talking to "you" (the buyer). Direct and warm. Not corporate.

**Header library** — pull from these gaming tropes when naming sections:

| Trope | Use for |
|---|---|
| `INSERT COIN` | top-of-page eyebrow, attention call |
| `PRESS START` / `READY PLAYER 1?` | hero CTA, onboarding |
| `START YOUR QUEST` | primary CTA button (project inquiry) |
| `SELECT YOUR CHARACTER` | configurator / product selection |
| `THE ORIGIN STORY` | about / founder section |
| `EXAMPLE PROJECTS` / `HALL OF FAME` | portfolio grid |
| `1UP` / `LEVEL UP` | upgrades, premium tier |
| `GAME OVER` | error states, sold out |
| `HIGH SCORE` | testimonials |

**Body copy formula:** Open with the gaming/nostalgia hook, then deliver a craftsmanship payoff in the same paragraph. Example pattern from the banner: _"At Round 2 Customs, we fuse timeless nostalgia with modern performance to deliver handcrafted, premium arcade machines tailored to your style."_ — one sentence, two halves, nostalgia → craft.

**Things to avoid:**
- Emoji (the brand uses pixel-art icons instead)
- Specs-heavy marketing ("16ms response time, 4K HDR…") — they sell craft and feeling, not numbers
- Casual / meme voice — playful, not goofy
- Apologies, hedging, or corporate-speak ("solutions", "leveraging", "ecosystem")

**Punctuation:** En-dash for asides — like this. Periods at the end of headers are rare; treat headers as titles, not sentences.

---

## Visual Foundations

### Color
- **Canvas is black.** True `#000` for the page background; `#141416` for cards; `#1F1F22` for elevated panels. The brand never lives on white — even printed materials (business card) are black-first.
- **One primary accent: orange `#E15A2B`** — pulled directly from the logo's `2`. This is the "press start" color. Use for primary CTAs, key icons, the active state, and the brand wordmark.
- **Three support neons:** cyan `#2EB6E0`, yellow `#F5C518`, red `#D52B1E`. Used for the underline-rainbow motif, secondary icons (Instagram = cyan, cursor = yellow, mail = orange/red), and small accents. Use **sparingly** — one or two per surface — never all four at once except in the explicit rainbow stripe.
- **Magenta `#D63384` and green `#3DDC84`** are tertiary, mostly reserved for atmospheric photography (the magenta/cyan smoke in hero imagery) and "1UP" success states.

### Type
- **Display: Michroma** — wide, technical, all-caps. Used for every header and the wordmark itself. Tracked at `0.08em–0.18em`. Never lowercase.
- **Body: Onest** — humanist sans, comfortable at small sizes. 400/500/600/700.
- **Accent: Press Start 2P** — pixel font, used **rarely** and only for direct gaming references (the email-as-CRT-text on the business card, error/Easter-egg states). Never for body copy.

### Backgrounds
- **Primary: flat black.** No gradients on body backgrounds.
- **Atmosphere via photography**, not CSS gradients. Hero shots use **smoky magenta + cyan haze** behind a centered cabinet — that's the signature "atmosphere" effect.
- **Rainbow horizontal stripe** (orange → yellow → cyan → magenta, four parallel lines) is a recurring divider motif — see banner footer and website mid-section. Use it sparingly as a section break.
- **No noise / grain textures** in the digital UI. The photography brings the warmth.

### Layout
- Generous whitespace despite the busy aesthetic — sections breathe, content is centered with max-widths.
- Single-column hero, then 4-up project grid, then split form/footer.
- Fixed top nav, fully transparent over the hero, opaque dark on scroll.

### Borders, radii, shadows
- **Radii are subtly squared**: default `4px`. Buttons and cards keep arcade-cabinet rectangularity. Pill shapes only for the rare chip/badge.
- **Borders: 1px hairlines** (`#2A2A2E`) on dark — barely visible, used to separate panels.
- **Shadows on dark are mostly _glows_**, not drop shadows. The signature elevation is `0 0 24px rgba(225,90,43,.45)` (orange neon halo). Drop shadows exist (`--shadow-md`) but are rarely seen because the canvas is already black.

### Animation & states
- **Hover:** orange CTA brightens to `--r2c-orange-hot`; outlined buttons gain the orange glow + filled background.
- **Press:** scale `0.98`, deeper orange (`--r2c-orange-deep`).
- **Focus:** 2px orange outline + glow.
- **Page anims:** subtle fade-up on scroll (200–400ms, ease-out). Avoid bouncy / playful easings — the brand is precise, not cartoony.
- **CRT flicker** as a special effect — reserved for hero text or the 404 page. Don't use globally.

### Imagery
- **Photographs of finished cabinets** are the primary visual content. Centered, often with the **magenta-cyan smoke backdrop** (a studio lighting setup, not a Photoshop filter).
- **Wireframe 3D icons** (coins, hearts, ghosts, joysticks) appear as small decorative accents — usually orange or cyan, line-only, isometric.
- **Color vibe:** warm-leaning (orange dominates), but with cool atmospheric lights. Never washed-out or pastel.

### Transparency & blur
- Top nav uses **backdrop-blur** when scrolled (`backdrop-filter: blur(12px)` over `rgba(0,0,0,.6)`).
- Modals and overlays: `rgba(0,0,0,.75)` scrim, no blur on the scrim.
- Inputs on forms: subtle 4% white fill, no blur.

---

## Iconography

**The R2C iconography mixes three styles**, each with its own role:

1. **Pixel/8-bit cursor icons** (the yellow pointing hand on the business card, pixel mail/instagram glyphs). Hand-built bitmap aesthetic — sharp, tiny, full-color. Used for **wayfinding and small UI accents** (website link, social links). Source: custom bitmap art. We don't have these as files yet — the UI kit reproduces them with a CSS `image-rendering: pixelated` PNG sprite where needed, otherwise falls back to the closest Lucide equivalent and **flags the substitution**.

2. **Wireframe 3D / line illustrations** (cabinets, joysticks, hearts). Single-stroke line art, often orange. Used as **section markers and decorative anchors** — never as functional UI controls.

3. **Functional UI icons** (close, menu, chevron, form glyphs). For these we use **Lucide** (CDN: `https://unpkg.com/lucide@latest`) — a thin-stroke (1.5px) line icon set whose weight matches the wireframe-illustration vibe. **This is a substitution flagged for review** — we don't have access to R2C's own UI icon set yet.

**Emoji:** Not used. The pixel-cursor and line icons replace anywhere a brand might reach for emoji.

**Unicode glyphs:** Sparingly — the rainbow underline motif on the business card is graphical, not unicode. `→` for inline arrows is fine.

---

## Font Substitutions — please review

We did **not** receive font files for Michroma or Onest, so this system loads them from **Google Fonts**. Both are open-source and freely available there, but if you have an alternate licensed cut (e.g. an OTF you'd like to ship), drop it into `fonts/` and we'll update `colors_and_type.css` to `@font-face` it.

The pixel font (Press Start 2P) is an aesthetic match for the email line on the business card — confirm with the client whether they consider that an official brand face or just a one-off treatment.

---

## What's Missing / TODO

- [ ] Original pixel-art icon sprites (cursor, mail, Instagram, controller). Currently substituted with Lucide.
- [ ] High-resolution photography library (we only have one banner photo).
- [ ] Confirmation on the rainbow-stripe gradient color order — banner shows orange / yellow / cyan / magenta but the website may differ.
- [ ] An icon-only / square logo lockup for favicons and small placements.
- [ ] Any product configurator UI (if one exists).
