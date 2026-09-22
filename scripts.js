/* ============================================================
   ROUND 2 CUSTOMS — scripts.js
   ============================================================ */

// ============================================================
// FOOTER YEAR
// ============================================================
const footerYearEl = document.getElementById('footer-year');
if (footerYearEl) footerYearEl.textContent = new Date().getFullYear();


// ============================================================
// IMAGE PARALLAX — hero + split-section photos drift vertically
// relative to the viewport as the page scrolls. The offset is written
// to a --parallax-y custom property consumed by each <img>'s own
// transform, so it layers on top of that image's existing crop/scale
// instead of overwriting it, and stays within the crop's overscan
// buffer so no edge is ever revealed.
// ============================================================
const parallaxImgs = document.querySelectorAll('.hero-image img, .split-image img');
const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
const PARALLAX_MAX = 36; // px, stays within each image's overscan buffer

if (parallaxImgs.length && !prefersReducedMotion) {
  let parallaxTicking = false;

  function applyParallax() {
    const vh = window.innerHeight;
    parallaxImgs.forEach(img => {
      const container = img.parentElement;
      const rect = container.getBoundingClientRect();
      const centerOffset = (rect.top + rect.height / 2) - vh / 2;
      const y = Math.max(-PARALLAX_MAX, Math.min(PARALLAX_MAX, -centerOffset * 0.08));
      img.style.setProperty('--parallax-y', `${y.toFixed(1)}px`);
    });
    parallaxTicking = false;
  }

  function requestParallax() {
    if (!parallaxTicking) {
      requestAnimationFrame(applyParallax);
      parallaxTicking = true;
    }
  }

  window.addEventListener('scroll', requestParallax, { passive: true });
  window.addEventListener('resize', requestParallax);
  applyParallax();
}


// ============================================================
// PROJECT HERO PARALLAX — the hero photo drifts upward faster than the
// page scrolls, so it slides over the giant background wordmark as soon
// as the user starts scrolling instead of moving in lockstep with it.
// Driven directly by scrollY (the hero sits at the top of the page) rather
// than the viewport-center-relative technique above, which needs a section
// to be mid-viewport to produce any offset.
// ============================================================
const phImage = document.querySelector('.ph-image img');
const PH_PARALLAX_MAX = 180; // px, stays within the image's 130%/-15% overscan buffer
const PH_PARALLAX_FACTOR = 0.4;

if (phImage && !prefersReducedMotion) {
  let phTicking = false;

  function applyPhParallax() {
    const y = -Math.min(PH_PARALLAX_MAX, window.scrollY * PH_PARALLAX_FACTOR);
    phImage.style.setProperty('--ph-parallax-y', `${y.toFixed(1)}px`);
    phTicking = false;
  }

  function requestPhParallax() {
    if (!phTicking) {
      requestAnimationFrame(applyPhParallax);
      phTicking = true;
    }
  }

  window.addEventListener('scroll', requestPhParallax, { passive: true });
  applyPhParallax();
}


// ============================================================
// WORD FILL REVEAL — the intro paragraph starts grey and fills in white
// one word at a time, driven by how far the paragraph has travelled
// through the viewport rather than by a timer, so the fill tracks the
// user's scroll position (and unfills when they scroll back up).
// ============================================================
// Runs on any .intro-copy element, so the intro statement and the
// testimonial share one implementation.
const wordFillEls = document.querySelectorAll('.intro-copy');

if (wordFillEls.length) {
  const wordFills = Array.from(wordFillEls).map(el => {
    // wrap each word in its own span so they can be lit individually
    const words = el.textContent.trim().split(/\s+/);
    el.textContent = '';
    const spans = words.map((word, i) => {
      const span = document.createElement('span');
      span.className = 'intro-word';
      span.textContent = word;
      el.appendChild(span);
      if (i < words.length - 1) el.appendChild(document.createTextNode(' '));
      return span;
    });
    return { el, spans };
  });

  let wordFillTicking = false;

  function applyWordFill() {
    const vh = window.innerHeight;

    wordFills.forEach(({ el, spans }) => {
      const rect = el.getBoundingClientRect();

      // fill runs from the paragraph's top hitting 80% of the viewport
      // through to its bottom clearing 45% — a comfortable read-along pace
      const start = vh * 0.8;
      const end = vh * 0.45;
      const progress = (start - rect.top) / (start - end + rect.height);
      const lit = Math.round(Math.max(0, Math.min(1, progress)) * spans.length);

      spans.forEach((span, i) => span.classList.toggle('is-lit', i < lit));
    });

    wordFillTicking = false;
  }

  function requestWordFill() {
    if (!wordFillTicking) {
      requestAnimationFrame(applyWordFill);
      wordFillTicking = true;
    }
  }

  window.addEventListener('scroll', requestWordFill, { passive: true });
  window.addEventListener('resize', requestWordFill);
  applyWordFill();
}


// ============================================================
// DESIGN SECTION PARALLAX — the CAD mockup travels up over the heading
// and copy as the section crosses the viewport, so the two overlap
// progressively rather than sitting in fixed positions.
// ============================================================
const dsImage = document.getElementById('ds-image');
const DS_PARALLAX_RANGE = 300; // px either side of centre across the section

if (dsImage && !prefersReducedMotion && !dsImage.closest('.ds--static')) {
  const dsSection = dsImage.closest('.ds');
  let dsTicking = false;

  function applyDsParallax() {
    const rect = dsSection.getBoundingClientRect();
    const vh = window.innerHeight;

    // 0 as the section's top reaches the bottom of the viewport,
    // 1 once its bottom has passed the top
    const progress = (vh - rect.top) / (vh + rect.height);
    const clamped = Math.max(0, Math.min(1, progress));
    const y = (0.5 - clamped) * 2 * DS_PARALLAX_RANGE;

    dsImage.style.setProperty('--ds-parallax-y', `${y.toFixed(1)}px`);
    dsTicking = false;
  }

  function requestDsParallax() {
    if (!dsTicking) {
      requestAnimationFrame(applyDsParallax);
      dsTicking = true;
    }
  }

  window.addEventListener('scroll', requestDsParallax, { passive: true });
  window.addEventListener('resize', requestDsParallax);
  applyDsParallax();
}


// ============================================================
// MATERIALS FAN — cards start fanned/overlapping at center and spread
// apart horizontally (and un-rotate) as the section scrolls through the
// viewport, driven by --fan-progress on the stage element.
// ============================================================
const materialsStage = document.getElementById('materials-fan-stage');

if (materialsStage) {
  if (prefersReducedMotion) {
    materialsStage.style.setProperty('--fan-progress', '1');
  } else {
    const materialsSection = materialsStage.closest('.materials-fan');
    let materialsTicking = false;

    function applyMaterialsFan() {
      const rect = materialsSection.getBoundingClientRect();
      const vh = window.innerHeight;

      // 0 as the section's top reaches the bottom of the viewport, 1 once
      // its center reaches the viewport center — fans open on the way in
      // and stays open on the way past. The extra vh * 0.15 delays the
      // start slightly, so cards stay fanned a beat before spreading.
      const progress = (vh - rect.top - vh * 0.15) / (vh * 0.7 + rect.height * 0.3);
      const clamped = Math.max(0, Math.min(1, progress));

      materialsStage.style.setProperty('--fan-progress', clamped.toFixed(3));
      materialsTicking = false;
    }

    function requestMaterialsFan() {
      if (!materialsTicking) {
        requestAnimationFrame(applyMaterialsFan);
        materialsTicking = true;
      }
    }

    window.addEventListener('scroll', requestMaterialsFan, { passive: true });
    window.addEventListener('resize', requestMaterialsFan);
    applyMaterialsFan();
  }
}


// ============================================================
// PRODUCT VIEWER — one pill expanded at a time, stepped by clicking a
// pill or with the up/down arrows, with the stage image crossfading to
// match. Panels animate via max-height, so the open one is measured on
// each change (and on resize, since the copy reflows).
// ============================================================
// Initialised per .pv section rather than by ID, so the component can
// appear more than once on a page with each instance tracking its own
// open pill.
document.querySelectorAll('.pv').forEach(pvSection => {
  const pvList  = pvSection.querySelector('.pv-list');
  const pvStage = pvSection.querySelector('.pv-stage');
  if (!pvList || !pvStage) return;

  const pvItems  = Array.from(pvList.querySelectorAll('.pv-item'));
  const pvCover  = pvStage.querySelector('.pv-cover');
  // the alt layout shows its copy in a box over the media instead of in
  // an accordion panel under each pill
  const pvCaptions = Array.from(pvSection.querySelectorAll('.pv-caption'));
  // a stage slide can be an <img> or a <video>, one per pill
  const pvImages = Array.from(pvStage.querySelectorAll('img:not(.pv-cover), video'));

  // -1 = nothing expanded, which is the state the section loads in
  let pvCurrent = pvItems.findIndex(item => item.classList.contains('is-active'));

  function setPvActive(index) {
    pvCurrent = index < 0 ? -1 : (index + pvItems.length) % pvItems.length;

    pvItems.forEach((item, i) => {
      const isActive = i === pvCurrent;
      const panel = item.querySelector('.pv-panel');
      item.classList.toggle('is-active', isActive);
      item.querySelector('.pv-pill').setAttribute('aria-expanded', String(isActive));
      // only the accordion layout has a panel to measure
      if (panel) panel.style.maxHeight = isActive ? `${panel.scrollHeight}px` : '';
    });

    pvCaptions.forEach((caption, i) => {
      caption.classList.toggle('is-active', i === pvCurrent);
    });

    // the cover holds the stage while nothing is expanded
    if (pvCover) pvCover.classList.toggle('is-active', pvCurrent < 0);

    pvImages.forEach((media, i) => {
      const isActive = i === pvCurrent;
      media.classList.toggle('is-active', isActive);

      // video slides only play while they're the one on stage
      if (media.tagName === 'VIDEO') {
        if (isActive) {
          media.currentTime = 0;
          media.play();
        } else {
          media.pause();
        }
      }
    });
  }

  pvItems.forEach((item, i) => {
    item.querySelector('.pv-pill').addEventListener('click', () => setPvActive(i));

    // collapse back to the all-closed state
    const close = item.querySelector('.pv-close');
    if (close) close.addEventListener('click', () => setPvActive(-1));
  });

  pvCaptions.forEach(caption => {
    const close = caption.querySelector('.pv-close');
    if (close) close.addEventListener('click', () => setPvActive(-1));
  });

  // stepping from the closed state enters the list at whichever end the
  // arrow points from
  function stepPv(dir) {
    setPvActive(pvCurrent < 0 ? (dir > 0 ? 0 : pvItems.length - 1) : pvCurrent + dir);
  }

  const pvPrev = pvSection.querySelector('.pv-arrow--prev');
  const pvNext = pvSection.querySelector('.pv-arrow--next');
  if (pvPrev) pvPrev.addEventListener('click', () => stepPv(-1));
  if (pvNext) pvNext.addEventListener('click', () => stepPv(1));

  window.addEventListener('resize', () => setPvActive(pvCurrent));
  setPvActive(pvCurrent);
});


// ============================================================
// PRODUCT STICKY BAR — appears once the hero has scrolled past, with the
// current in-page section highlighted in the tabs row (Apple product-page
// pattern).
// ============================================================
const productBar = document.getElementById('product-bar');
const phHeroEl   = document.getElementById('ph-hero');
const mainNavbar = document.getElementById('navbar');

if (productBar && phHeroEl) {
  function updateProductBarVisibility() {
    const heroBottom = phHeroEl.offsetTop + phHeroEl.offsetHeight;
    const navbarH = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--navbar-h')) || 76;
    productBar.classList.toggle('is-visible', window.scrollY > heroBottom - navbarH);
  }

  // Once the product bar is showing, the main navbar slides away on
  // scroll-down and slides back in (pushing the product bar back down
  // with it) on scroll-up — same collapse pattern as Apple product pages.
  let lastScrollY = window.scrollY;

  function updateNavCollapse() {
    const scrollY = window.scrollY;
    const delta = scrollY - lastScrollY;

    if (Math.abs(delta) > 4) {
      if (productBar.classList.contains('is-visible') && delta > 0) {
        document.body.classList.add('nav-collapsed');
      } else if (delta < 0) {
        document.body.classList.remove('nav-collapsed');
      }
      lastScrollY = scrollY;
    }
  }

  function onProductBarScroll() {
    updateProductBarVisibility();
    if (mainNavbar) updateNavCollapse();
  }

  window.addEventListener('scroll', onProductBarScroll, { passive: true });
  window.addEventListener('resize', updateProductBarVisibility);
  updateProductBarVisibility();

  const productBarLinks = productBar.querySelectorAll('a[data-cs-target]');
  const productBarSections = Array.from(productBarLinks)
    .map(link => document.getElementById(link.dataset.csTarget))
    .filter(Boolean);

  if (productBarSections.length && 'IntersectionObserver' in window) {
    const productBarObserver = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          productBarLinks.forEach(link => {
            link.classList.toggle('is-active', link.dataset.csTarget === entry.target.id);
          });
        }
      });
    }, { rootMargin: '-45% 0px -50% 0px', threshold: 0 });

    productBarSections.forEach(section => productBarObserver.observe(section));
  }
}


// ============================================================
// SCROLL REVEAL — section text slides + fades in on viewport entry
// ============================================================
const revealEls = document.querySelectorAll('.hero-text, .section-text, .contact-header, .ph-title, .ph-image, .ph-body .btn-primary');

if (revealEls.length) {
  if (!('IntersectionObserver' in window)) {
    revealEls.forEach(el => el.classList.add('is-visible'));
  } else {
    const revealObserver = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          revealObserver.unobserve(entry.target);
        }
      });
    }, { threshold: 0.2 });

    revealEls.forEach(el => revealObserver.observe(el));
  }
}


// ============================================================
// GRID LINES — one elongated highlight per line, drifting on scroll
// in opposing directions
// ============================================================
const gridLines = document.querySelectorAll('.grid-line');

function buildGridLineGradient() {
  const length = 18; // % of tile
  const half = length / 2;
  const opacity = (0.08 + Math.random() * 0.06).toFixed(2);
  return `linear-gradient(to bottom, transparent 0%, transparent ${(50 - half).toFixed(2)}%, rgba(255, 255, 255, ${opacity}) 50%, transparent ${(50 + half).toFixed(2)}%, transparent 100%)`;
}

const gridLineConfigs = Array.from(gridLines).map((line, i) => {
  const tileHeight = Math.round(1300 + Math.random() * 300);
  line.style.backgroundImage = buildGridLineGradient();
  line.style.backgroundSize = `100% ${tileHeight}px`;
  return { el: line, factor: i === 0 ? 0.25 : -0.25 };
});

function updateGridLineParallax() {
  const y = window.scrollY;
  gridLineConfigs.forEach(cfg => {
    cfg.el.style.backgroundPositionY = `${y * cfg.factor}px`;
  });
}

if (gridLineConfigs.length) {
  window.addEventListener('scroll', updateGridLineParallax, { passive: true });
  updateGridLineParallax();
}


// ============================================================
// HERO WORD CYCLE — scanline glitch transition
// ============================================================
const wordCycleEl = document.getElementById('word-cycle');
const wordCycleDisplay = document.getElementById('word-cycle-display');

if (wordCycleEl && wordCycleDisplay) {
  const words = ['ARCADES', 'SPACES', 'EXPERIENCES'];
  let wordIndex = 0;

  // reserve the width of the longest word so the layout never jumps
  // as the glitch transition swaps in shorter/longer words
  const sizer = document.createElement('span');
  const computed = getComputedStyle(wordCycleDisplay);
  sizer.style.cssText = `position:absolute; visibility:hidden; white-space:nowrap; font: ${computed.font}; letter-spacing: ${computed.letterSpacing};`;
  document.body.appendChild(sizer);
  let maxWidth = 0;
  words.forEach(word => {
    sizer.textContent = word;
    maxWidth = Math.max(maxWidth, sizer.offsetWidth);
  });
  sizer.remove();
  wordCycleEl.style.width = `${maxWidth}px`;

  setInterval(() => {
    wordIndex = (wordIndex + 1) % words.length;
    wordCycleEl.classList.add('is-glitching');

    // swap the text partway through the glitch so the distortion masks it
    setTimeout(() => {
      wordCycleDisplay.textContent = words[wordIndex];
      wordCycleDisplay.setAttribute('data-text', words[wordIndex]);
    }, 120);

    setTimeout(() => {
      wordCycleEl.classList.remove('is-glitching');
    }, 320);
  }, 2500);
}


// ============================================================
// NAV SCROLL COMPACT
// ============================================================
const navbar = document.getElementById('navbar');

function updateNavbarScroll() {
  navbar.classList.toggle('is-scrolled', window.scrollY > 0);
}

window.addEventListener('scroll', updateNavbarScroll, { passive: true });
updateNavbarScroll();


// ============================================================
// VENDOR LOGOS — subtle side scroll tied to page scroll
// ============================================================
const logoTrack = document.getElementById('logo-track');
const vendorsSection = document.querySelector('.trusted-vendors');

if (logoTrack && vendorsSection) {
  const maxShift = 100; // px, matches the extra width added to .logo-track

  function updateLogoScroll() {
    const rect = vendorsSection.getBoundingClientRect();
    const vh = window.innerHeight;
    const total = rect.height + vh;
    const progress = Math.min(Math.max((vh - rect.top) / total, 0), 1);
    logoTrack.style.transform = `translateX(-${progress * maxShift}px)`;
  }

  window.addEventListener('scroll', updateLogoScroll, { passive: true });
  updateLogoScroll();
}


// ============================================================
// GALLERY CARDS — tiles are wired to the lightbox below.
// ============================================================
const galleryCards = document.querySelectorAll('.gallery-card');


// ============================================================
// GALLERY MODAL — clicking a project gallery tile opens a lightbox on
// that tile's collection (category). Left/right arrows switch between
// collections, not individual photos; thumbnails switch photos within
// the current collection.
//
// Each tile only shows one cover photo, but its full collection can hold
// several — listed here by category. Placeholder sets reusing existing
// site photos until real per-collection photography is ready.
//
// Paths below are written relative to the site root, so pages nested in a
// subdirectory (projects/*.html) need a prefix. It's derived from how that
// page links styles.css — '' at the root, '../' one level down — rather
// than hardcoded, so the same list works from any depth.
// ============================================================
const ASSET_PREFIX = (document.querySelector('link[rel="stylesheet"][href$="styles.css"]')
  ?.getAttribute('href') || '').replace('styles.css', '');

const GALLERY_COLLECTIONS = {
  'Pinball Gallery': [
    { src: ASSET_PREFIX + 'assets/images/hero-pinball.png', alt: 'Custom pinball machine build' },
    { src: ASSET_PREFIX + 'assets/images/classic-vpin.png', alt: 'VPIN Classic custom pinball build' },
    { src: ASSET_PREFIX + 'assets/images/vpin-noire.jpg', alt: 'VPIN Noire custom pinball build' },
  ],
  'Retro Gallery': [
    { src: ASSET_PREFIX + 'assets/images/theStudio.png', alt: 'R2C studio build' },
    { src: ASSET_PREFIX + 'assets/images/retro-studio.jpg', alt: 'Retro Studio custom arcade build' },
    { src: ASSET_PREFIX + 'assets/images/retro-3rd-strike.jpg', alt: 'Retro 3rd Strike custom arcade build' },
  ],
  'Custom Builds': [
    { src: ASSET_PREFIX + 'assets/images/fully-custom-2player.png', alt: 'Custom 2-player arcade cabinet' },
    { src: ASSET_PREFIX + 'assets/images/apex-cosmic.jpg', alt: 'Apex Cosmic custom arcade build' },
    { src: ASSET_PREFIX + 'assets/images/the-apex.png', alt: 'The Apex custom cabinet' },
  ],
  'Cocktail Cabinets': [
    { src: ASSET_PREFIX + 'assets/images/the-loft.png', alt: 'The Loft custom cabinet' },
    { src: ASSET_PREFIX + 'assets/images/fully-custom-2player.png', alt: 'Custom 2-player arcade cabinet' },
    { src: ASSET_PREFIX + 'assets/images/steam-pedestal.jpg', alt: 'Steam Pedestal custom arcade build' },
  ],
  'Restorations': [
    { src: ASSET_PREFIX + 'assets/images/the-apex.png', alt: 'The Apex custom cabinet' },
    { src: ASSET_PREFIX + 'assets/images/retro-3rd-strike.jpg', alt: 'Retro 3rd Strike custom arcade build' },
    { src: ASSET_PREFIX + 'assets/images/theStudio.png', alt: 'R2C studio build' },
  ],
  'Prop Builds': [
    { src: ASSET_PREFIX + 'assets/images/mario-bros-isolated.png', alt: 'Mario Bros arcade prop build' },
    { src: ASSET_PREFIX + 'assets/images/mario-bros.jpg', alt: 'Mario Bros custom arcade build' },
    { src: ASSET_PREFIX + 'assets/images/steam-pedestal.jpg', alt: 'Steam Pedestal custom arcade build' },
  ],
};

// Case-study pages carry their own photo list (#project-photos, JSON array
// of {src, alt} relative to the site root). The first five feed the bento
// tiles; the lightbox opens on the clicked photo and arrows/thumbs move
// through the whole list. Pages without it keep the showroom's
// category-collection behaviour.
const projectPhotosEl = document.getElementById('project-photos');
const PROJECT_PHOTOS = projectPhotosEl
  ? JSON.parse(projectPhotosEl.textContent).map(p => ({ ...p, src: ASSET_PREFIX + p.src }))
  : null;

const galleryModal = document.getElementById('gallery-modal');

if (galleryCards.length && galleryModal) {
  const modalImg    = document.getElementById('gallery-modal-img');
  const modalTitle  = document.getElementById('gallery-modal-title');
  const modalThumbs = document.getElementById('gallery-modal-thumbs');
  const modalPrev   = document.getElementById('gallery-modal-prev');
  const modalNext   = document.getElementById('gallery-modal-next');
  const modalClose  = document.getElementById('gallery-modal-close');

  const collections = PROJECT_PHOTOS
    ? { [projectPhotosEl.dataset.title || '']: PROJECT_PHOTOS }
    : GALLERY_COLLECTIONS;
  const collectionNames = Object.keys(collections);
  let collectionIndex = 0;
  let imageIndex = 0;

  function showImage(i) {
    const images = collections[collectionNames[collectionIndex]];
    imageIndex = (i + images.length) % images.length;
    const item = images[imageIndex];
    modalImg.src = item.src;
    modalImg.alt = item.alt;
    modalThumbs.querySelectorAll('.gallery-modal-thumb').forEach((thumb, ti) => {
      thumb.classList.toggle('is-active', ti === imageIndex);
    });
  }

  function renderThumbs(images) {
    modalThumbs.innerHTML = '';
    images.forEach((item, i) => {
      const thumb = document.createElement('button');
      thumb.type = 'button';
      thumb.className = 'gallery-modal-thumb';
      thumb.innerHTML = `<img src="${item.src}" alt="${item.alt}">`;
      thumb.addEventListener('click', () => showImage(i));
      modalThumbs.appendChild(thumb);
    });
  }

  // direction: 0 = no animation (opening the modal), 1 = next (slide from
  // the right), -1 = prev (slide from the left)
  function showCollection(ci, direction = 0, startIndex = 0) {
    collectionIndex = (ci + collectionNames.length) % collectionNames.length;
    const category = collectionNames[collectionIndex];
    const images = collections[category];

    modalTitle.textContent = category;
    renderThumbs(images);

    if (!direction) {
      showImage(startIndex);
      return;
    }

    const exitX  = direction > 0 ? -32 : 32;
    const enterX = -exitX;
    const slideDuration = 250;

    modalImg.style.transition = `transform ${slideDuration}ms ease, opacity ${slideDuration}ms ease`;
    modalImg.style.transform = `translateX(${exitX}px)`;
    modalImg.style.opacity = '0';

    window.setTimeout(() => {
      showImage(0);
      modalImg.style.transition = 'none';
      modalImg.style.transform = `translateX(${enterX}px)`;
      void modalImg.offsetWidth; // force reflow so the enter position applies before animating
      modalImg.style.transition = `transform ${slideDuration}ms ease, opacity ${slideDuration}ms ease`;
      modalImg.style.transform = 'translateX(0)';
      modalImg.style.opacity = '1';
    }, slideDuration);
  }

  function openGalleryModal(category, startIndex = 0) {
    showCollection(collectionNames.indexOf(category), 0, startIndex);
    galleryModal.classList.add('is-open');
    galleryModal.setAttribute('aria-hidden', 'false');
    galleryModal.removeAttribute('inert');
    document.body.style.overflow = 'hidden';
  }

  function closeGalleryModal() {
    galleryModal.classList.remove('is-open');
    galleryModal.setAttribute('aria-hidden', 'true');
    // keeps its links/buttons out of the tab order while hidden, so
    // aria-hidden doesn't hide focusable content from assistive tech
    // while a keyboard user can still tab into it
    galleryModal.setAttribute('inert', '');
    document.body.style.overflow = '';
  }

  galleryCards.forEach(card => {
    card.addEventListener('click', e => {
      e.preventDefault();
      if (PROJECT_PHOTOS) {
        openGalleryModal(collectionNames[0], Number(card.dataset.photo) || 0);
      } else {
        openGalleryModal(card.dataset.category);
      }
    });
  });

  // Project mode: arrows step through photos; showroom: through collections.
  const step = dir => PROJECT_PHOTOS
    ? showImage(imageIndex + dir)
    : showCollection(collectionIndex + dir, dir);

  modalPrev.addEventListener('click', () => step(-1));
  modalNext.addEventListener('click', () => step(1));
  modalClose.addEventListener('click', closeGalleryModal);

  galleryModal.addEventListener('click', e => {
    if (e.target === galleryModal) closeGalleryModal();
  });

  document.addEventListener('keydown', e => {
    if (!galleryModal.classList.contains('is-open')) return;
    if (e.key === 'Escape') closeGalleryModal();
    if (e.key === 'ArrowLeft') step(-1);
    if (e.key === 'ArrowRight') step(1);
  });
}


// ============================================================
// NAV TOGGLE
// ============================================================
const navToggle = document.getElementById('nav-toggle');
const navMenu   = document.getElementById('nav-menu');

if (navToggle && navMenu) {
  navToggle.addEventListener('click', () => {
    const isOpen = navToggle.classList.toggle('is-open');
    navMenu.classList.toggle('is-open', isOpen);
    navToggle.setAttribute('aria-expanded', String(isOpen));
    navMenu.setAttribute('aria-hidden', String(!isOpen));
    // keeps the menu's links out of the tab order while closed, so
    // aria-hidden doesn't hide focusable content from assistive tech
    // while a keyboard user can still tab into it
    navMenu.toggleAttribute('inert', !isOpen);
    document.body.style.overflow = isOpen ? 'hidden' : '';
  });

  // Custom Builder is a placeholder — it toggles its own "Coming Soon"
  // pill instead of navigating, so it's excluded from the auto-close below
  navMenu.querySelectorAll('a').forEach(link => {
    if (link.id === 'nav-link-custom-builder') return;
    link.addEventListener('click', closeMenu);
  });
}



function closeMenu() {
  navToggle.classList.remove('is-open');
  navMenu.classList.remove('is-open');
  navToggle.setAttribute('aria-expanded', 'false');
  navMenu.setAttribute('aria-hidden', 'true');
  navMenu.setAttribute('inert', '');
  document.body.style.overflow = '';
}


// ============================================================
// CUSTOM BUILDER NAV ITEM — reveals its "Coming Soon" pill on click/tap
// instead of linking anywhere (hover still reveals it for mouse users)
// ============================================================
const navCustomBuilder = document.getElementById('nav-link-custom-builder');

if (navCustomBuilder) {
  const toggleBadge = e => {
    e.preventDefault();
    navCustomBuilder.classList.toggle('is-revealed');
  };

  navCustomBuilder.addEventListener('click', toggleBadge);
  navCustomBuilder.addEventListener('keydown', e => {
    if (e.key === 'Enter' || e.key === ' ') toggleBadge(e);
  });
}


// ============================================================
// STUDIO CAROUSEL
// Update this array with your actual image filenames.
// Drop photos into assets/images/studio/ and list them here.
// ============================================================
// Add more images here as you build out the studio gallery.
// Drop files into assets/images/ and add entries to this array.
// Index 2 (the 3rd slide) is the studio shot — it's also where `current`
// starts, so the carousel opens centered on it.
const carouselTrack = document.getElementById('carousel-track');
const paginationEl  = document.getElementById('carousel-pagination');
const carouselEl    = document.getElementById('carousel');

if (carouselTrack && paginationEl && carouselEl) {
  const slides = [
    { src: 'assets/images/hero-pinball.png', alt: 'VPIN Modern custom pinball build', name: 'VPIN<br>MODERN', link: 'projects/vpin-modern.html' },
    { src: 'assets/images/classic-vpin.png', alt: 'VPIN Classic custom pinball build', name: 'VPIN<br>CLASSIC', link: 'projects/vpin-classic.html' },
    { src: 'assets/images/theStudio.png', alt: 'R2C studio build', name: 'THE<br>STUDIO' },
    { src: 'assets/images/the-apex.png', alt: 'The Apex custom cabinet', name: 'THE<br>APEX' },
    { src: 'assets/images/the-loft.png', alt: 'The Loft custom cabinet', name: 'THE<br>LOFT' },
  ];

  let current = 2; // start on the 3rd slide
  const total  = slides.length;

  // build one <li><img><label></li> per slide and stack them all at dead
  // center; renderCarousel() below positions each one by its distance from
  // `current`. The name label travels with its slide but only shows when
  // that slide is centered.
  const slideEls = slides.map(({ src, alt, name }) => {
    const li = document.createElement('li');
    li.className = 'carousel-slide';

    const img = document.createElement('img');
    img.src = src;
    img.alt = alt;
    li.appendChild(img);

    const label = document.createElement('div');
    label.className = 'studio-label';
    label.innerHTML = `<h2>${name}</h2>`;
    li.appendChild(label);
    li._label = label;

    carouselTrack.appendChild(li);
    return li;
  });

  const idx = n => ((n % total) + total) % total;

  // signed distance from `current`, wrapped into range e.g. -2..2 for 5 slides
  function distanceFrom(i) {
    let d = (i - current + total) % total;
    if (d > total / 2) d -= total;
    return d;
  }

  function renderCarousel(animate = true) {
    slideEls.forEach((el, i) => {
      const d = distanceFrom(i);
      let xPercent, scale, opacity, zIndex;

      if (d === 0) {
        xPercent = 0; scale = 1; opacity = 1; zIndex = 30;
        el.dataset.role = 'center';
      } else if (Math.abs(d) === 1) {
        xPercent = d * 72; scale = 0.576; opacity = 0.5; zIndex = 20;
        el.dataset.role = d === -1 ? 'prev' : 'next';
      } else {
        xPercent = d * 144; scale = 0.5; opacity = 0; zIndex = 10;
        el.dataset.role = 'far';
      }

      gsap.to(el, { xPercent, scale, opacity, zIndex, duration: animate ? 0.6 : 0, ease: 'power2.out' });
      gsap.to(el._label, { opacity: d === 0 ? 1 : 0, duration: animate ? 0.3 : 0, ease: 'power1.out' });
    });

    paginationEl.querySelectorAll('.pagination-dot').forEach((dot, i) => {
      dot.classList.toggle('is-active', i === current);
      dot.setAttribute('aria-selected', String(i === current));
    });
  }

  function goTo(n) {
    current = idx(n);
    renderCarousel();
  }

  function initCarousel() {
    slides.forEach((_, i) => {
      const dot = document.createElement('button');
      dot.className = 'pagination-dot' + (i === 0 ? ' is-active' : '');
      dot.setAttribute('role', 'tab');
      dot.setAttribute('aria-label', `Slide ${i + 1}`);
      dot.setAttribute('aria-selected', String(i === 0));
      dot.addEventListener('click', () => goTo(i));
      paginationEl.appendChild(dot);
    });

    // clicking a side slide brings it to center; clicking the already-
    // centered slide navigates to its case study, if it has one
    slideEls.forEach((el, i) => el.addEventListener('click', () => {
      if (distanceFrom(i) === 0 && slides[i].link) {
        window.location.href = ASSET_PREFIX + slides[i].link;
      } else {
        goTo(i);
      }
    }));

    renderCarousel(false); // set initial positions instantly, no animation
  }

  // Drag/swipe support — a proxy just measures the gesture; the slides
  // themselves are driven entirely by renderCarousel(), not by drag position.
  const carouselDragProxy = document.createElement('div');
  carouselDragProxy.style.visibility = 'hidden';
  carouselDragProxy.style.position = 'absolute';
  carouselEl.appendChild(carouselDragProxy);

  Draggable.create(carouselDragProxy, {
    type: 'x',
    trigger: carouselEl,
    onDragEnd() {
      if (this.x < -50) goTo(current + 1);
      else if (this.x > 50) goTo(current - 1);
      this.x = 0;
      gsap.set(carouselDragProxy, { x: 0 });
    }
  });

  initCarousel();
}

// ============================================================
// CONTACT FORM — EmailJS
//
// Setup (one-time):
//   1. Create a free account at https://www.emailjs.com
//   2. Add an Email Service (Gmail, Outlook, etc.) → copy the Service ID
//   3. Create an Email Template → copy the Template ID
//      sendForm() reads each field's `name` attribute directly, so the
//      template variables must match the <input>/<textarea> name= values
//      in the form: {{name}}, {{email}}, {{phone}}, {{message}}
//   4. Go to Account → Public Key → copy it
//   5. Replace the three placeholder strings below
// ============================================================
const form = document.getElementById('contact-form');

if (form) {
  const EMAILJS_PUBLIC_KEY  = 'ZMJXhKl-QLGxzYyUC';
  const EMAILJS_SERVICE_ID  = 'service_efzlosd';
  const EMAILJS_TEMPLATE_ID = 'template_wyxcbdb';

  emailjs.init({ publicKey: EMAILJS_PUBLIC_KEY });

  const submitBtn = form.querySelector('.submit-btn');

  function validateForm() {
    let valid = true;
    form.querySelectorAll('[required]').forEach(field => {
      const empty = !field.value.trim();
      field.style.borderColor = empty ? 'var(--terracotta)' : '';
      if (empty) valid = false;
    });
    return valid;
  }

  form.querySelectorAll('[required]').forEach(field => {
    field.addEventListener('input', () => {
      if (field.value.trim()) field.style.borderColor = '';
    });
  });

  form.addEventListener('submit', e => {
    e.preventDefault();

    // Honeypot — real users never fill this (it's visually hidden); if it
    // has a value, silently pretend to succeed so the bot doesn't retry
    const honeypot = form.querySelector('[name="hp_website"]');
    if (honeypot && honeypot.value.trim()) {
      form.innerHTML = `
        <div class="form-success">
          <p>Message received. We'll be in touch shortly.</p>
        </div>
      `;
      return;
    }

    if (!validateForm()) return;

    const originalHTML = submitBtn.innerHTML;
    submitBtn.textContent = 'SENDING…';
    submitBtn.disabled = true;

    emailjs.sendForm(EMAILJS_SERVICE_ID, EMAILJS_TEMPLATE_ID, form)
      .then(() => {
        form.innerHTML = `
          <div class="form-success">
            <p>Message received. We'll be in touch shortly.</p>
          </div>
        `;
      })
      .catch(() => {
        submitBtn.innerHTML = originalHTML;
        submitBtn.disabled = false;
        alert('Something went wrong — please try again or email us directly.');
      });
  });
}

// ============================================================

// ============================================================
// CASE STUDY — VPIN Noire project page
// ============================================================

// ------------------------------------------------------------
// Before / after slider (Custom Artwork section)
// ------------------------------------------------------------
const csBaSlider = document.getElementById('cs-ba-slider');
const csBaHandle  = document.getElementById('cs-ba-handle');

if (csBaSlider && csBaHandle) {
  const frame    = csBaSlider.querySelector('.cs-ba-frame');
  const afterWrap = csBaSlider.querySelector('.cs-ba-after-wrap');

  function setSlider(percent) {
    const clamped = Math.max(0, Math.min(100, percent));
    afterWrap.style.width = `${clamped}%`;
    csBaHandle.style.left = `${clamped}%`;
    csBaHandle.setAttribute('aria-valuenow', String(Math.round(clamped)));
  }

  function percentFromClientX(clientX) {
    const rect = frame.getBoundingClientRect();
    return ((clientX - rect.left) / rect.width) * 100;
  }

  let dragging = false;

  function onPointerMove(e) {
    if (!dragging) return;
    const clientX = e.touches ? e.touches[0].clientX : e.clientX;
    setSlider(percentFromClientX(clientX));
  }

  function stopDragging() {
    dragging = false;
  }

  csBaHandle.addEventListener('pointerdown', () => { dragging = true; });
  frame.addEventListener('pointerdown', e => {
    dragging = true;
    setSlider(percentFromClientX(e.clientX));
  });
  window.addEventListener('pointermove', onPointerMove);
  window.addEventListener('pointerup', stopDragging);

  csBaHandle.addEventListener('keydown', e => {
    const current = parseFloat(csBaHandle.style.left) || 50;
    if (e.key === 'ArrowLeft')  { setSlider(current - 5); e.preventDefault(); }
    if (e.key === 'ArrowRight') { setSlider(current + 5); e.preventDefault(); }
  });

  setSlider(50);
}


// ------------------------------------------------------------
// Stat counters (CNC callout + Build Statistics) — count up once
// when the tile scrolls into view
// ------------------------------------------------------------
const csStatEls = document.querySelectorAll('[data-count-to]');

if (csStatEls.length) {
  function animateStat(el) {
    const target = parseInt(el.dataset.countTo, 10);
    const suffix = el.dataset.suffix || '';

    if (prefersReducedMotion || !('IntersectionObserver' in window)) {
      el.textContent = target.toLocaleString() + suffix;
      return;
    }

    const duration = 1200;
    const start = performance.now();

    function tick(now) {
      const progress = Math.min(1, (now - start) / duration);
      const eased = 1 - Math.pow(1 - progress, 3);
      el.textContent = Math.round(target * eased).toLocaleString() + suffix;
      if (progress < 1) requestAnimationFrame(tick);
    }

    requestAnimationFrame(tick);
  }

  if (!('IntersectionObserver' in window)) {
    csStatEls.forEach(animateStat);
  } else {
    const statObserver = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          animateStat(entry.target);
          statObserver.unobserve(entry.target);
        }
      });
    }, { threshold: 0.4 });

    csStatEls.forEach(el => statObserver.observe(el));
  }
}


// ------------------------------------------------------------
// FAQ accordion
// ------------------------------------------------------------
const csFaqItems = document.querySelectorAll('.cs-faq-item');

if (csFaqItems.length) {
  csFaqItems.forEach(item => {
    const question = item.querySelector('.cs-faq-question');
    const answer   = item.querySelector('.cs-faq-answer');

    question.addEventListener('click', () => {
      const isOpen = item.classList.toggle('is-open');
      question.setAttribute('aria-expanded', String(isOpen));
      answer.style.maxHeight = isOpen ? `${answer.scrollHeight}px` : '';
    });
  });
}


// ------------------------------------------------------------
// Build gallery masonry lightbox — flat click-to-enlarge, reuses the
// .gallery-modal component styling from the showroom's project gallery
// ------------------------------------------------------------
const csMasonry = document.getElementById('cs-masonry');
const csGalleryModal = document.getElementById('cs-gallery-modal');

if (csMasonry && csGalleryModal) {
  const csItems = Array.from(csMasonry.querySelectorAll('.cs-masonry-item'));
  const csModalImg   = document.getElementById('cs-gallery-modal-img');
  const csModalPrev  = document.getElementById('cs-gallery-modal-prev');
  const csModalNext  = document.getElementById('cs-gallery-modal-next');
  const csModalClose = document.getElementById('cs-gallery-modal-close');

  let csIndex = 0;

  function showCsImage(i) {
    csIndex = (i + csItems.length) % csItems.length;
    const img = csItems[csIndex].querySelector('img');
    csModalImg.src = img.src;
    csModalImg.alt = img.alt;
  }

  function openCsModal(i) {
    showCsImage(i);
    csGalleryModal.classList.add('is-open');
    csGalleryModal.setAttribute('aria-hidden', 'false');
    csGalleryModal.removeAttribute('inert');
    document.body.style.overflow = 'hidden';
  }

  function closeCsModal() {
    csGalleryModal.classList.remove('is-open');
    csGalleryModal.setAttribute('aria-hidden', 'true');
    // keeps its buttons out of the tab order while hidden, so aria-hidden
    // doesn't hide focusable content from assistive tech while a keyboard
    // user can still tab into it
    csGalleryModal.setAttribute('inert', '');
    document.body.style.overflow = '';
  }

  csItems.forEach((item, i) => {
    item.addEventListener('click', () => openCsModal(i));
  });

  csModalPrev.addEventListener('click', () => showCsImage(csIndex - 1));
  csModalNext.addEventListener('click', () => showCsImage(csIndex + 1));
  csModalClose.addEventListener('click', closeCsModal);

  csGalleryModal.addEventListener('click', e => {
    if (e.target === csGalleryModal) closeCsModal();
  });

  document.addEventListener('keydown', e => {
    if (!csGalleryModal.classList.contains('is-open')) return;
    if (e.key === 'Escape') closeCsModal();
    if (e.key === 'ArrowLeft') showCsImage(csIndex - 1);
    if (e.key === 'ArrowRight') showCsImage(csIndex + 1);
  });
}


// ============================================================
// RELATED PROJECTS CAROUSEL — bottom of every case study.
// Looping carousel of the showroom's project tiles (minus the page you're on).
// Slots 0-3 are visible: 1 and 2 fully opaque, 0 and 3 faded. Clicking a
// faded tile steps the carousel that way; pagination dots jump straight to
// a project. `current` is the tile sitting in slot 1.
// ============================================================
const rpTrack = document.getElementById('rp-track');
const rpPagination = document.getElementById('rp-pagination');

if (rpTrack && rpPagination) {
  const RP_PROJECTS = [
    { slug: 'vpin-classic',     img: 'classic-vpin.png',       alt: 'VPIN Classic custom pinball build',     name: 'VPIN<br>CLASSIC' },
    { slug: 'apex-cosmic',      img: 'apex-cosmic.jpg',        alt: 'Cosmic Apex custom arcade build',       name: 'COSMIC<br>APEX' },
    { slug: 'vpin-modern',      img: 'vpin-noire.jpg',         alt: 'VPIN Modern custom pinball build',      name: 'VPIN<br>MODERN' },
    { slug: 'retro-studio',     img: 'retro-studio.jpg',       alt: 'Retro Studio custom arcade build',      name: 'RETRO<br>STUDIO' },
    { slug: 'steam-pedestal',   img: 'steam-pedestal.jpg',     alt: 'Steam Deck Pedestal custom arcade build', name: 'STEAM DECK<br>PEDESTAL' },
    { slug: 'retro-3rd-strike', img: 'retro-3rd-strike.jpg',   alt: 'Retro 3rd Strike custom arcade build',  name: 'RETRO<br>3RD STRIKE' },
  ];

  const pageSlug = location.pathname.split('/').pop().replace(/\.html$/, '');
  const rpItems = RP_PROJECTS.filter(p => p.slug !== pageSlug);
  const rpCount = rpItems.length;

  // The visible window is 4 slots wide, so a loop of just `rpCount` tiles has
  // no spare tile to wait off-canvas — the one leaving the left edge would
  // have to fly across the screen to re-enter on the right. The ring is
  // therefore doubled (each project appears twice) so the tile that wraps
  // around always does so far outside the visible slots.
  const rpTotal = rpCount * 2;
  const rpHalf = rpTotal / 2;
  let rpCurrent = 0; // unbounded step counter; the ring position is rpCurrent mod rpTotal

  const rpTiles = Array.from({ length: rpTotal }, (_, n) => {
    const p = rpItems[n % rpCount];
    const li = document.createElement('li');
    li.className = 'rp-tile';
    li.innerHTML = `
      <a class="project-card" href="${ASSET_PREFIX}projects/${p.slug}.html">
        <img src="${ASSET_PREFIX}assets/images/${p.img}" alt="${p.alt}" loading="lazy">
        <div class="project-card-fade"></div>
        <span class="project-card-name">${p.name}</span>
      </a>`;
    rpTrack.appendChild(li);
    return li;
  });

  function renderRp(instant) {
    rpTiles.forEach((li, i) => {
      // signed distance from `current`, wrapped into -half..half; slot 1 = current
      const r = (((i - rpCurrent + rpHalf) % rpTotal) + rpTotal) % rpTotal - rpHalf;
      const slot = r + 1;
      if (instant) li.style.transition = 'none';
      li.dataset.slot = String(slot);
      li.style.setProperty('--d', String(Math.max(-1, Math.min(4, slot))));
      li.dataset.role = slot === 0 ? 'prev' : slot === 3 ? 'next' : 'center';
      const visible = slot >= 0 && slot <= 3;
      li.setAttribute('aria-hidden', String(!visible));
      li.querySelector('a').tabIndex = visible ? 0 : -1;
    });
    if (instant) {
      void rpTrack.offsetWidth; // apply the positions before transitions come back
      rpTiles.forEach(li => { li.style.transition = ''; });
    }
    rpPagination.querySelectorAll('.pagination-dot').forEach((dot, i) => {
      const active = i === (((rpCurrent % rpCount) + rpCount) % rpCount);
      dot.classList.toggle('is-active', active);
      dot.setAttribute('aria-selected', String(active));
    });
  }

  const rpGoTo = n => { rpCurrent = n; renderRp(false); };

  rpItems.forEach((p, i) => {
    const dot = document.createElement('button');
    dot.className = 'pagination-dot';
    dot.setAttribute('role', 'tab');
    dot.setAttribute('aria-label', `Show ${p.slug.replace(/-/g, ' ')}`);
    // step the short way round to the chosen project
    dot.addEventListener('click', () => {
      let delta = (((i - rpCurrent) % rpCount) + rpCount) % rpCount;
      if (delta > rpCount / 2) delta -= rpCount;
      rpGoTo(rpCurrent + delta);
    });
    rpPagination.appendChild(dot);
  });

  // faded outer tiles step the carousel instead of following the link
  rpTiles.forEach(li => {
    li.querySelector('a').addEventListener('click', e => {
      // on phones only slot 1 is a live link; both neighbours (0 and 2) step the carousel
      const phone = window.matchMedia('(max-width: 768px)').matches;
      const slot = li.dataset.slot;
      if (li.dataset.role === 'prev') { e.preventDefault(); rpGoTo(rpCurrent - 1); }
      else if (li.dataset.role === 'next' || (phone && slot === '2')) { e.preventDefault(); rpGoTo(rpCurrent + 1); }
    });
  });

  // swipe on touch screens
  let rpTouchX = null;
  rpTrack.addEventListener('touchstart', e => { rpTouchX = e.touches[0].clientX; }, { passive: true });
  rpTrack.addEventListener('touchend', e => {
    if (rpTouchX === null) return;
    const dx = e.changedTouches[0].clientX - rpTouchX;
    if (Math.abs(dx) > 50) rpGoTo(rpCurrent + (dx < 0 ? 1 : -1));
    rpTouchX = null;
  });

  renderRp(true);
}


// ============================================================
// BUTTON PIXEL GRID EFFECT (EASED + REVERSE)
// ============================================================
class ButtonPixelGridEffect {
  constructor(button) {
    this.button = button;
    this.canvas = button.querySelector('.btn-particle-canvas');
    this.ctx = this.canvas.getContext('2d');
    this.isHovering = false;
    this.isReversing = false;
    this.animationId = null;
    
    this.pixelSize = 8;
    this.gridCols = 0;
    this.gridRows = 0;
    this.filledPixels = new Set();
    this.pixelsToFill = [];
    this.fillIndex = 0;
    this.startTime = 0;
    this.fillDuration = 800; // milliseconds
    
    this.setupCanvas();
    this.attachListeners();
  }

  setupCanvas() {
    this.canvas.width = this.button.offsetWidth;
    this.canvas.height = this.button.offsetHeight;
    
    this.gridCols = Math.ceil(this.canvas.width / this.pixelSize);
    this.gridRows = Math.ceil(this.canvas.height / this.pixelSize);
    
    // Create randomized fill order with left-to-right bias
    this.pixelsToFill = [];
    
    for (let col = 0; col < this.gridCols; col++) {
      for (let row = 0; row < this.gridRows; row++) {
        const bias = col + (Math.random() * 2 - 1) * 3;
        this.pixelsToFill.push({ col, row, bias });
      }
    }
    
    this.pixelsToFill.sort((a, b) => a.bias - b.bias);
  }

  attachListeners() {
    this.button.addEventListener('mouseenter', () => this.startAnimation());
    this.button.addEventListener('mouseleave', () => this.reverseAnimation());
  }

  startAnimation() {
    if (this.isHovering) return;
    this.isHovering = true;
    this.isReversing = false;
    this.canvas.classList.add('active');
    this.fillIndex = 0;
    this.startTime = Date.now();
    this.animate();
  }

  reverseAnimation() {
    this.isHovering = false;
    this.isReversing = true;
    this.startTime = Date.now();
    this.animate();
  }

  easeOutQuart(t) {
    return 1 - Math.pow(1 - t, 4);
  }

  fillPixels() {
    if (this.isReversing) {
      const elapsed = Date.now() - this.startTime;
      const progress = Math.min(elapsed / this.fillDuration, 1);
      const eased = this.easeOutQuart(progress);
      const targetIndex = this.pixelsToFill.length * (1 - eased);
      
      while (this.fillIndex > targetIndex) {
        this.fillIndex--;
        const pixel = this.pixelsToFill[this.fillIndex];
        const key = `${pixel.col},${pixel.row}`;
        this.filledPixels.delete(key);
      }
    } else {
      const elapsed = Date.now() - this.startTime;
      const progress = Math.min(elapsed / this.fillDuration, 1);
      const eased = this.easeOutQuart(progress);
      const targetIndex = Math.floor(this.pixelsToFill.length * eased);
      
      while (this.fillIndex < targetIndex) {
        const pixel = this.pixelsToFill[this.fillIndex];
        const key = `${pixel.col},${pixel.row}`;
        this.filledPixels.add(key);
        this.fillIndex++;
      }
    }
  }

  drawPixels() {
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    this.ctx.fillStyle = 'rgb(220, 120, 80)';
    
    this.filledPixels.forEach(key => {
      const [col, row] = key.split(',').map(Number);
      const x = col * this.pixelSize;
      const y = row * this.pixelSize;
      this.ctx.fillRect(x, y, this.pixelSize, this.pixelSize);
    });
  }

  animate() {
    this.fillPixels();
    this.drawPixels();
    
    const elapsed = Date.now() - this.startTime;
    
    if (this.isReversing) {
      if (elapsed < this.fillDuration && this.fillIndex > 0) {
        this.animationId = requestAnimationFrame(() => this.animate());
      } else {
        this.filledPixels.clear();
        this.canvas.classList.remove('active');
      }
    } else {
      if (elapsed < this.fillDuration && this.fillIndex < this.pixelsToFill.length) {
        this.animationId = requestAnimationFrame(() => this.animate());
      }
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const pixelEffects = [];
  document.querySelectorAll('.btn-primary').forEach(button => {
    pixelEffects.push(new ButtonPixelGridEffect(button));
  });

  let resizeTimer;
  window.addEventListener('resize', () => {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(() => {
      pixelEffects.forEach(effect => effect.setupCanvas());
    }, 200);
  });
});


// ============================================================
// FOOTER PHONE REVEAL
// The number never sits in the HTML source — it's built here and only
// swapped in once the visitor clicks the button, so simple scrapers that
// don't execute JS only ever see "Reveal Phone Number".
// ============================================================
document.querySelectorAll('[data-footer-phone]').forEach(btn => {
  // digits, reversed, so a raw-text search of this file doesn't turn up
  // the number either
  const reversed = '0065743748';

  btn.addEventListener('click', () => {
    const digits = reversed.split('').reverse().join('');
    const formatted = `(${digits.slice(0, 3)}) ${digits.slice(3, 6)}-${digits.slice(6)}`;

    const link = document.createElement('a');
    link.className = 'footer-phone-link';
    link.href = `tel:+1${digits}`;
    link.textContent = formatted;

    btn.replaceWith(link);
  }, { once: true });
});
