# Worklog

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
