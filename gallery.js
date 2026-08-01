/* ============================================================
   CARD CAROUSEL — 1 center card, 1 faded card on each side,
   cycling through a 5-image loop. Rebuilt from scratch (not the
   original pen's continuous scrub-timeline, which assumed a much
   larger card set and broke down with only 5 items).
   Navigate via Prev/Next buttons or by swiping/dragging.

   All top-level names are prefixed "gallery" — this file and
   scripts.js are both loaded as plain <script> tags sharing one
   global scope, and identically-named top-level `let`/`const`
   declarations across scripts throw a SyntaxError that silently
   kills whichever script runs second.
   ============================================================ */
gsap.registerPlugin(Draggable);

const galleryCardEls = gsap.utils.toArray('.gsap-showcase .cards li');
const galleryTotal = galleryCardEls.length;
let galleryCurrent = 0;

// signed distance from `galleryCurrent`, wrapped into range e.g. -2..2 for 5 items
function galleryDistanceFrom(i) {
  let d = (i - galleryCurrent + galleryTotal) % galleryTotal;
  if (d > galleryTotal / 2) d -= galleryTotal;
  return d;
}

function renderGallery(animate = true) {
  galleryCardEls.forEach((el, i) => {
    const d = galleryDistanceFrom(i);
    let xPercent, scale, opacity, zIndex;

    if (d === 0) {
      xPercent = 0; scale = 1; opacity = 1; zIndex = 30;
    } else if (Math.abs(d) === 1) {
      xPercent = d * 100; scale = 0.75; opacity = 0.35; zIndex = 20;
    } else {
      xPercent = d * 200; scale = 0.55; opacity = 0; zIndex = 10;
    }

    gsap.to(el, { xPercent, scale, opacity, zIndex, duration: animate ? 0.5 : 0, ease: 'power2.out' });
  });
}

function galleryGoTo(n) {
  galleryCurrent = ((n % galleryTotal) + galleryTotal) % galleryTotal;
  renderGallery();
}

renderGallery(false); // set initial positions instantly, no animation

document.querySelector('.gsap-showcase .next').addEventListener('click', () => galleryGoTo(galleryCurrent + 1));
document.querySelector('.gsap-showcase .prev').addEventListener('click', () => galleryGoTo(galleryCurrent - 1));

// swipe/drag support — a proxy just measures the gesture; the cards
// themselves are driven entirely by renderGallery(), not by drag position.
Draggable.create('.gsap-showcase .drag-proxy', {
  type: 'x',
  trigger: '.gsap-showcase .cards',
  onDragEnd() {
    if (this.x < -50) galleryGoTo(galleryCurrent + 1);
    else if (this.x > 50) galleryGoTo(galleryCurrent - 1);
    this.x = 0;
    gsap.set('.gsap-showcase .drag-proxy', { x: 0 });
  }
});
