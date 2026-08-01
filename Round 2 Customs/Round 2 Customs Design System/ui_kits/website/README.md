# Round 2 Customs — Website UI Kit

A pixel-fidelity recreation of the Round 2 Customs marketing site, reconstructed from the website screenshot and brand collateral. Open `index.html` to see the full page; individual components live in `components/`.

## Components
- `Nav.jsx` — sticky top nav with centered logo
- `Hero.jsx` — smoke + neon backdrop, illustrated cabinet
- `Intro.jsx` — mission paragraph + `RainbowDivider`
- `OriginStory.jsx` — split copy/illustration block
- `ProjectGrid.jsx` — 4-up portfolio grid ("EXAMPLE PROJECTS")
- `QuestForm.jsx` — "START YOUR QUEST" contact form
- `Footer.jsx` — three-column footer with pixel social icons

## Notes / Substitutions
- Cabinet illustration is an SVG approximation — replace with high-res photo when available.
- Pixel social icons (◉ / ☞ / ✉) are unicode placeholders for the bitmap art on the business card. Swap for real PNG sprites once provided.
- Project thumbnails use color-only placeholders. Drop real photos into `assets/` and reference them in `ProjectGrid.jsx`.
