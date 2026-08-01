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
// SCROLL REVEAL — section text slides + fades in on viewport entry
// ============================================================
const revealEls = document.querySelectorAll('.hero-text, .section-text, .contact-header');

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
// GALLERY CARD CURSOR — a category pill follows the pointer in place of
// the native cursor while hovering a project gallery tile. One shared
// element fixed to the viewport (appended to <body>) so it renders above
// everything instead of being clipped by a card's own overflow:hidden.
// ============================================================
const galleryCards = document.querySelectorAll('.gallery-card');

if (galleryCards.length) {
  const galleryCursor = document.createElement('span');
  galleryCursor.className = 'gallery-cursor';
  document.body.appendChild(galleryCursor);

  galleryCards.forEach(card => {
    card.addEventListener('mouseenter', () => {
      galleryCursor.textContent = card.dataset.category || '';
      galleryCursor.classList.add('is-active');
    });

    card.addEventListener('mousemove', e => {
      galleryCursor.style.left = `${e.clientX}px`;
      galleryCursor.style.top = `${e.clientY}px`;
    });

    card.addEventListener('mouseleave', () => {
      galleryCursor.classList.remove('is-active');
    });
  });
}


// ============================================================
// GALLERY MODAL — clicking a project gallery tile opens a lightbox on
// that tile's collection (category). Left/right arrows switch between
// collections, not individual photos; thumbnails switch photos within
// the current collection.
//
// Each tile only shows one cover photo, but its full collection can hold
// several — listed here by category. Placeholder sets reusing existing
// site photos until real per-collection photography is ready.
// ============================================================
const GALLERY_COLLECTIONS = {
  'Pinball Gallery': [
    { src: 'assets/images/hero-pinball.png', alt: 'Custom pinball machine build' },
    { src: 'assets/images/classic-vpin.png', alt: 'VPIN Classic custom pinball build' },
    { src: 'assets/images/vpin-noire.jpg', alt: 'VPIN Noire custom pinball build' },
  ],
  'Retro Gallery': [
    { src: 'assets/images/theStudio.png', alt: 'R2C studio build' },
    { src: 'assets/images/retro-studio.jpg', alt: 'Retro Studio custom arcade build' },
    { src: 'assets/images/retro-3rd-strike.jpg', alt: 'Retro 3rd Strike custom arcade build' },
  ],
  'Custom Builds': [
    { src: 'assets/images/fully-custom-2player.png', alt: 'Custom 2-player arcade cabinet' },
    { src: 'assets/images/apex-cosmic.jpg', alt: 'Apex Cosmic custom arcade build' },
    { src: 'assets/images/the-apex.png', alt: 'The Apex custom cabinet' },
  ],
  'Cocktail Cabinets': [
    { src: 'assets/images/the-loft.png', alt: 'The Loft custom cabinet' },
    { src: 'assets/images/fully-custom-2player.png', alt: 'Custom 2-player arcade cabinet' },
    { src: 'assets/images/steam-pedestal.jpg', alt: 'Steam Pedestal custom arcade build' },
  ],
  'Restorations': [
    { src: 'assets/images/the-apex.png', alt: 'The Apex custom cabinet' },
    { src: 'assets/images/retro-3rd-strike.jpg', alt: 'Retro 3rd Strike custom arcade build' },
    { src: 'assets/images/theStudio.png', alt: 'R2C studio build' },
  ],
  'Prop Builds': [
    { src: 'assets/images/mario-bros-isolated.png', alt: 'Mario Bros arcade prop build' },
    { src: 'assets/images/mario-bros.jpg', alt: 'Mario Bros custom arcade build' },
    { src: 'assets/images/steam-pedestal.jpg', alt: 'Steam Pedestal custom arcade build' },
  ],
};

const galleryModal = document.getElementById('gallery-modal');

if (galleryCards.length && galleryModal) {
  const modalImg    = document.getElementById('gallery-modal-img');
  const modalTitle  = document.getElementById('gallery-modal-title');
  const modalThumbs = document.getElementById('gallery-modal-thumbs');
  const modalPrev   = document.getElementById('gallery-modal-prev');
  const modalNext   = document.getElementById('gallery-modal-next');
  const modalClose  = document.getElementById('gallery-modal-close');

  const collectionNames = Object.keys(GALLERY_COLLECTIONS);
  let collectionIndex = 0;
  let imageIndex = 0;

  function showImage(i) {
    const images = GALLERY_COLLECTIONS[collectionNames[collectionIndex]];
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
  function showCollection(ci, direction = 0) {
    collectionIndex = (ci + collectionNames.length) % collectionNames.length;
    const category = collectionNames[collectionIndex];
    const images = GALLERY_COLLECTIONS[category];

    modalTitle.textContent = category;
    renderThumbs(images);

    if (!direction) {
      showImage(0);
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

  function openGalleryModal(category) {
    showCollection(collectionNames.indexOf(category), 0);
    galleryModal.classList.add('is-open');
    galleryModal.setAttribute('aria-hidden', 'false');
    document.body.style.overflow = 'hidden';
  }

  function closeGalleryModal() {
    galleryModal.classList.remove('is-open');
    galleryModal.setAttribute('aria-hidden', 'true');
    document.body.style.overflow = '';
  }

  galleryCards.forEach(card => {
    card.addEventListener('click', e => {
      e.preventDefault();
      openGalleryModal(card.dataset.category);
    });
  });

  modalPrev.addEventListener('click', () => showCollection(collectionIndex - 1, -1));
  modalNext.addEventListener('click', () => showCollection(collectionIndex + 1, 1));
  modalClose.addEventListener('click', closeGalleryModal);

  galleryModal.addEventListener('click', e => {
    if (e.target === galleryModal) closeGalleryModal();
  });

  document.addEventListener('keydown', e => {
    if (!galleryModal.classList.contains('is-open')) return;
    if (e.key === 'Escape') closeGalleryModal();
    if (e.key === 'ArrowLeft') showCollection(collectionIndex - 1, -1);
    if (e.key === 'ArrowRight') showCollection(collectionIndex + 1, 1);
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
    document.body.style.overflow = isOpen ? 'hidden' : '';
  });

  navMenu.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', closeMenu);
  });
}




// ============================================================
// NAV MEDIA — Custom Builder CNC video
// ============================================================
const cncMediaEl = document.getElementById('nav-media-cnc');
const customBuilderLink = document.getElementById('nav-link-custom-builder');

if (cncMediaEl && customBuilderLink) {
  const cncVideo = cncMediaEl.querySelector('video');

  customBuilderLink.addEventListener('mouseenter', () => {
    cncMediaEl.classList.add('is-active');
    cncVideo.currentTime = 0;
    cncVideo.play();
  });

  customBuilderLink.addEventListener('mouseleave', () => {
    cncMediaEl.classList.remove('is-active');
    cncVideo.pause();
  });
}

function closeMenu() {
  navToggle.classList.remove('is-open');
  navMenu.classList.remove('is-open');
  navToggle.setAttribute('aria-expanded', 'false');
  navMenu.setAttribute('aria-hidden', 'true');
  document.body.style.overflow = '';
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
    { src: 'assets/images/hero-pinball.png', alt: 'Custom pinball machine', name: 'ARCADE<br>PINBALL' },
    { src: 'assets/images/classic-vpin.png', alt: 'Classic Virtual Pin build', name: 'CLASSIC<br>V-PIN' },
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

    // clicking any visible side slide brings it to center
    slideEls.forEach((el, i) => el.addEventListener('click', () => goTo(i)));

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

// ============================================================

// ============================================================

// ============================================================

// ============================================================

// ============================================================

// ============================================================

// ============================================================

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
