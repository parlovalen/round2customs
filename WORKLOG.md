# Worklog

## 2026-08-01 — Project Gallery bento section + lightbox modal

- Added a "Project Gallery" section to `showroom.html`, below Recent Project Stories: a bento-style mosaic (one large tile + an uneven-then-equal 2-row column, matching a Figma layout) built with fluid flexbox ratios instead of the design's fixed pixel widths so it holds up at any viewport. Tiles show a category (e.g. "Pinball Gallery") via a pointer-following pill — a single shared `position: fixed` element (not per-tile) so it renders above everything instead of being clipped by a tile's own `overflow: hidden`.
- Clicking a tile opens a lightbox: dark blurred backdrop, large image with a title (the collection name) top-left, thumbnail strip, and left/right pixel-arrow controls recreated from the Figma "8bit-arrow"/"close" cursor components (node 56:78) used on the studio carousel — bare icons, no button chrome, terracotta by default, white on hover.
- Collections vs. photos, an important distinction: each tile represents a whole category, not a single photo. Arrows/keyboard cycle between *collections* (title + thumbnail strip both change, with a slide transition), while clicking a thumbnail only swaps the photo within the current collection (no slide, no title change). `GALLERY_COLLECTIONS` in `scripts.js` currently seeds each of the 6 categories with 3 placeholder photos reused from existing site assets — swap in real per-category photography when it's ready.
- Iterated on styling per feedback: section background/tile colors flip-flopped between light and dark a few times before landing on light grey section + dark tiles; gaps standardized to 16px throughout both this section and Recent Project Stories; image hover gets a 1.12x zoom-in.

## 2026-08-01 — Contact form made global

- The contact form previously only existed on the homepage; every other page's "Custom Builder"/"Contact" links and CTAs routed back to `index.html#contact`. Made it a true global element instead: duplicated the full `#contact` section (form, honeypot, EmailJS SDK script tag) onto `showroom.html` and all 6 `projects/*.html` pages, and repointed their nav links and "Start Your Build" CTAs to the local `#contact` on the same page.
- `scripts.js` already guarded the form-handling block on `document.getElementById('contact-form')`, so no JS changes were needed — it just now finds and wires up a form on every page.

## 2026-08-01 — Recent project stories section + detail pages

- Built the "Recent Project Stories" section from a Figma design (2-column card grid, 6 cards, dark-photo cards with the build name pinned bottom-left, terracotta border on hover). Initially placed it on the homepage; moved it to `showroom.html` instead (replacing its "coming soon" placeholder) since that's the page it's actually gallery content for — the homepage now just has a compact "Explore More Builds" teaser button linking to the showroom.
- Each card links to a dedicated page under `projects/` — one per real project name supplied (VPIN Classic, Apex Cosmic, VPIN Noire, Retro Studio, Steam Pedestal, Retro 3rd Strike), using the matching photos dropped into `assets/images/`. Each detail page reuses the shared nav/footer, a new full-width `.project-hero` photo band, and a `.project-content` block with title, placeholder story copy (matches the site's existing lorem-ipsum convention elsewhere), a back-to-showroom link, and a "Start Your Build" CTA into the homepage contact section.
- New CSS: `.showroom-teaser` for the homepage CTA, `.project-stories-label`/`.project-grid`/`.project-card` for the card grid (now on the showroom page), `.project-hero`/`.project-content`/`.project-back` for the detail-page template — all responsive at the existing 1024/768 breakpoints. Removed the now-unused `.showroom-grid`/`.showroom-empty` placeholder CSS.

## 2026-08-01 — Showroom page

- Site is now multi-page: added `showroom.html` (nav "Showroom" link now points here instead of the homepage carousel anchor). Page shell only — page header + an empty `.showroom-grid` with a placeholder message and "Get in touch" CTA, ready for real build entries later.
- `scripts.js` is shared across pages, but several sections (studio carousel, contact form/EmailJS) assumed their elements always existed and would throw on a page that doesn't have them. Wrapped those sections in existence checks so the same script file works on pages with a subset of the homepage's sections. Nav toggle, footer year, button hover effect, parallax, and scroll-reveal were already guarded or safe to run without their target elements.

## 2026-08-01 — Mobile responsive pass, footer, contact form hardening

Starting point: desktop-only design (zero media queries), pixel-grid button hover effect already in place.

### Mobile responsive design
- Added tablet (≤1024px) and mobile (≤768px) breakpoints across nav, hero, split sections (Fully Custom / Customer Build), trusted vendors, studio carousel, and contact form.
- Hero image moved above the text on mobile (was side-by-side on desktop); buttons go full-width.
- Fixed a layout bug where a leftover small-phone (≤400px) breakpoint was silently overriding `h1`/`h2`/nav font sizes and vendor logo sizing set at the 768px breakpoint — removed the stale rules.
- Fixed a bug where `.services-list` (two-column desktop layout) stayed two-column and `nowrap` through the 1024–768px tablet range after its parent had already narrowed, causing horizontal overflow. Now stacks to one column at the same 1024px breakpoint as everything else, and wraps instead of forcing overflow on narrow phones.
- Removed the coin-flip nav hover effect (Lottie animation on the first "O" in each nav link) — it split link text into multiple DOM nodes for a flex-laid-out link, which broke on mobile when "Custom Builder" needed to wrap (fragments wrapped and centered independently instead of flowing as one line). Removed the effect, its Lottie script include, and related CSS/JS entirely rather than patching around it.
- Multiple rounds of visual polish: vendor logos (grid → single column, sizing, spacing), carousel side-slide peek/opacity/pagination sizing, mobile nav menu alignment/backdrop opacity/spacing, hero `h1`/`h2` sizing (moved to a `clamp()` for fluid scaling below 390px instead of a hard breakpoint jump).

### Footer
- Added a footer section: company name + copyright (auto-updating year via JS) + address, and social links (TikTok, Instagram, Facebook — address/Instagram/Facebook pulled from the live round2customs.com; TikTok added once the client provided the handle).
- Iterated on layout per feedback: removed logo, restructured text order, alignment, sizing, and copyright symbol spacing.

### Contact form
- Converted the "Submit Inquiry" text-link into a proper pill button matching the site's other CTAs (including the pixel-grid fill hover effect), retitled "Send Message".
- Wired up EmailJS with real credentials (public key, service ID, template ID). Fixed a documentation bug in `scripts.js` where the noted template variables (`from_name`/`from_email`) didn't match what `sendForm()` actually sends (`name`/`email`, taken from each field's `name=` attribute).
- Added honeypot spam protection: a visually-hidden field that silently no-ops the submission (fake success) if bots fill it in.
- Considered reCAPTCHA v3; deferred since it requires server-side secret-key verification and the site has no backend yet. Documented as a follow-up for whenever a Vercel serverless function is added.

### Visual experiments
- Added, then tuned, then hidden (per request) a set of grid-line accents: faint vertical guide lines tracking the content column edges, and horizontal rules at section boundaries, each with an animated highlight streak (randomized position/length, scroll-driven parallax on the vertical lines, opposing directions). Also added and then reverted a desktop-only 24px section gutter inset. Left in the codebase but disabled via `display:none` / margin reset, not deleted, in case it's revisited.
- Added image parallax (hero + split-section photos) and scroll-reveal slide+fade-in for section text (`IntersectionObserver`-driven, respects `prefers-reduced-motion` for the parallax but not the one-time text reveal, since that's mild enough to keep for all users).
- Fixed a real bug in the first parallax implementation: the transform was applied to the image's container, which was exactly the same size as its own `overflow:hidden` parent — clipping the effect down to nothing. Fixed by applying the offset to each `<img>` via a `--parallax-y` CSS custom property layered on top of its existing crop transform, with a clamped range and matching overscan buffer so no edge is ever revealed.

### Housekeeping
- Restructured the local repo so the website files live nested inside `Round 2 Customs/Website/` (matching the user's folder organization) while the git root stays at that folder, so pushes to GitHub still contain only the site's files with no wrapper directory.
- Ran a full smoke test: JS syntax, CSS brace balance, HTML tag balance, all local asset references resolve, all nav anchors match real section IDs, all `getElementById`/`querySelector` targets in JS match real elements, all external CDN dependencies reachable, dev server serving correctly.
