# Round 2 Customs — Website

Marketing site for Round 2 Customs, a custom arcade machine builder. Static HTML/CSS/JS, no build step or framework.

## Stack

- Plain HTML, CSS, and vanilla JS (no bundler, no framework)
- [GSAP](https://gsap.com/) + Draggable — studio carousel and the (currently unused) card gallery
- [Lottie](https://airbnb.io/lottie/) — was used for a nav hover effect, since removed
- [EmailJS](https://www.emailjs.com/) — contact form delivery, no backend required
- Fonts: Halyard Display (Adobe Fonts / Typekit) + Gabarito (Google Fonts)

## Project structure

```
index.html          Homepage — nav, hero, sections, contact form, footer
showroom.html        Showroom page — recent project stories grid (6 build cards), contact form
projects/             One page per recent project story (linked from the showroom cards):
                      vpin-classic, apex-cosmic, vpin-noire, retro-studio, steam-pedestal,
                      retro-3rd-strike. Placeholder body copy — swap in real project stories.
                      Each also has its own contact form.
styles.css           All styles, including responsive breakpoints (see comments)
scripts.js           All page behavior (nav, carousel, form, animations) — shared across pages,
                      each section guards for the elements it needs so pages without a
                      carousel/contact form don't error
gallery.js            GSAP card-gallery demo, currently unused (display:none in CSS)
assets/
  brand/              Logo
  images/              Photography used across sections
  logos/               Vendor/partner logos
  animation/           Lottie/video assets for nav + hero
```

## Running locally

No build step. Serve the directory with any static file server, e.g.:

```bash
python3 -m http.server 8000
```

Then open `http://localhost:8000`.

## Contact form (EmailJS)

The contact form (`#contact`) is a global element — it's duplicated on every page (homepage, showroom, and each project detail page), each with its own EmailJS SDK `<script>` tag and `id="contact-form"`. `scripts.js` is shared across all pages and wires up whichever form it finds. Nav "Custom Builder"/"Contact" links point to `#contact` on the current page rather than back to the homepage.

The form is wired to EmailJS — see the `CONTACT FORM — EmailJS` section near the bottom of `scripts.js` for the three credentials (`EMAILJS_PUBLIC_KEY`, `EMAILJS_SERVICE_ID`, `EMAILJS_TEMPLATE_ID`).

**Important:** `emailjs.sendForm()` reads each field's `name=` attribute directly. The EmailJS template variables must match the form's field names exactly:

```
{{name}}, {{email}}, {{phone}}, {{message}}
```

### Spam protection

- **Honeypot** — a visually-hidden field (`name="hp_website"`) that real users never see or fill. If a submission arrives with it populated, the JS silently shows the success state without actually sending, so bots don't know to retry.
- **reCAPTCHA v3** — not yet implemented. It requires server-side verification of the secret key, which this static site doesn't have a backend for. If the site moves to Vercel with a serverless function, that's the natural place to add it (verify the token in an API route, then trigger the send).

## Deployment

Built to deploy as a static site (e.g. Vercel) — no server-side code currently required.

## Browser support

Modern evergreen browsers. Uses `IntersectionObserver`, CSS custom properties, and `backdrop-filter`; no polyfills included.
