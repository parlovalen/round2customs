/* =============================================================
   ROUND 2 CUSTOMS — Landing Game
   Vertical pixel-breakout gate screen. Clear the R2C logo before
   the clock runs out to enter the site. Esc/Q always skips.
   ============================================================= */

// ---------------------------------------------------------------
// CONFIG — point this at the real homepage before shipping.
// ---------------------------------------------------------------
const SITE_URL = 'index-site.html';

const CANVAS_W = 360;
const CANVAS_H = 440;

const TIME_LIMIT = 90;        // seconds
const READY_DURATION = 1.1;   // "GET READY" pause before clock starts
const BALL_LIVES = 3;         // game over when this many balls have dropped

const GRID_COLS = 64;
const GRID_ROWS = 20;
const GRID_TOP = 44;
// Each hit clears the 2x2-aligned block of pixels it lands in, not just
// the one pixel touched — keeps the finer grid clearable in reasonable time.

const BASE_BALL_SPEED = 350;  // px/s at t=0
const BALL_SPEED_MAX_MUL = 2.0; // multiplier reached at TIME_LIMIT
const BALL_SIZE = 8;          // pixel-block ball, not a circle

const PADDLE_W = 58;
const PADDLE_H = 9;
const PADDLE_Y = CANVAS_H - 40;
const PADDLE_SPEED = 420;

const LASER_SPEED = 480;
const LASER_COOLDOWN = 0.12;
const BOUNCE_JITTER = 0.3;    // rad — keeps the ball from looping the same corridor

// Dropped items ---------------------------------------------------
const ITEM_FALL_SPEED = 75;   // px/s — how fast pickups fall toward the paddle
const GUN_DROP_FRACTION = 0.20;  // gun drops once this fraction of the logo is cleared
const GUN_DURATION = 10;      // seconds the gun stays usable after pickup
const BOMB1_DROP_FRACTION = 0.45; // the bomb drops at this fraction cleared
const HAMMER_DROP_FRACTION = 0.80; // the disguised trap (a hammer) drops at this fraction cleared
const HAMMER_RESTORE_FRACTION = 0.30; // fraction of the grid the trap rebuilds if caught
const CLOCK_TIME_TRIGGER = 45; // only drop the +time clock inside the last N seconds
const CLOCK_BONUS = 30;       // seconds the clock pickup adds back to the timer
const BOMB_DURATION = 10;     // seconds the bomb's "double smash" red ball lasts

// ---------------------------------------------------------------
// AUDIO — synthesized 8-bit SFX, no external files.
// ---------------------------------------------------------------
let actx = null;
let muted = false;

function ensureAudio() {
  if (actx) return;
  const Ctx = window.AudioContext || window.webkitAudioContext;
  if (!Ctx) return;
  actx = new Ctx();
}

function resumeAudio() {
  if (actx && actx.state === 'suspended') actx.resume();
}

function beep({ freq = 440, duration = 0.08, type = 'square', vol = 0.15, slideTo = null, delay = 0 }) {
  if (muted || !actx) return;
  const t0 = actx.currentTime + delay;
  const osc = actx.createOscillator();
  const gain = actx.createGain();
  osc.type = type;
  osc.frequency.setValueAtTime(freq, t0);
  if (slideTo) osc.frequency.linearRampToValueAtTime(slideTo, t0 + duration);
  gain.gain.setValueAtTime(vol, t0);
  gain.gain.exponentialRampToValueAtTime(0.0008, t0 + duration);
  osc.connect(gain).connect(actx.destination);
  osc.start(t0);
  osc.stop(t0 + duration + 0.02);
}

// Filtered white-noise burst — the "boom" body of an explosion.
function noiseBurst({ duration = 0.3, vol = 0.25, startFreq = 1400, endFreq = 120 }) {
  if (muted || !actx) return;
  const t0 = actx.currentTime;
  const n = Math.floor(actx.sampleRate * duration);
  const buffer = actx.createBuffer(1, n, actx.sampleRate);
  const data = buffer.getChannelData(0);
  for (let i = 0; i < n; i++) data[i] = Math.random() * 2 - 1;
  const src = actx.createBufferSource();
  src.buffer = buffer;
  const filter = actx.createBiquadFilter();
  filter.type = 'lowpass';
  filter.frequency.setValueAtTime(startFreq, t0);
  filter.frequency.exponentialRampToValueAtTime(endFreq, t0 + duration);
  const gain = actx.createGain();
  gain.gain.setValueAtTime(vol, t0);
  gain.gain.exponentialRampToValueAtTime(0.001, t0 + duration);
  src.connect(filter).connect(gain).connect(actx.destination);
  src.start(t0);
  src.stop(t0 + duration + 0.02);
}

const sfxMenuMove = () => beep({ freq: 300, duration: 0.04, vol: 0.1 });
const sfxMenuSelect = () => { beep({ freq: 520, duration: 0.07, vol: 0.15 }); beep({ freq: 780, duration: 0.09, vol: 0.15, delay: 0.06 }); };
const sfxWall = () => beep({ freq: 220, duration: 0.05, vol: 0.08 });
const sfxPaddle = () => beep({ freq: 392, duration: 0.06, vol: 0.13 });
const sfxBrick = (row) => beep({ freq: 420 + row * 22, duration: 0.05, vol: 0.12 });
const sfxExplosion = () => {
  noiseBurst({ duration: 0.16, vol: 0.2, startFreq: 1400, endFreq: 90 });         // muffled transient
  beep({ freq: 70, duration: 0.5, type: 'sine', vol: 0.3, slideTo: 26 });         // deep boom body
  beep({ freq: 44, duration: 0.6, type: 'sine', vol: 0.22, slideTo: 20, delay: 0.02 }); // sub-bass
  beep({ freq: 120, duration: 0.14, type: 'triangle', vol: 0.12, slideTo: 45 });  // low punch
};
const sfxLaser = () => beep({ freq: 880, duration: 0.09, type: 'sawtooth', vol: 0.09, slideTo: 260 });
const sfxPowerupSpawn = () => beep({ freq: 500, duration: 0.16, type: 'triangle', vol: 0.12, slideTo: 900 });
const sfxPowerupCatch = () => { beep({ freq: 660, duration: 0.08, vol: 0.16 }); beep({ freq: 990, duration: 0.14, vol: 0.16, delay: 0.08 }); };
const sfxClockCatch = () => [784, 1046, 1318].forEach((f, i) => beep({ freq: f, duration: 0.1, vol: 0.15, delay: i * 0.07 }));
const sfxBombCatch = () => { beep({ freq: 180, duration: 0.2, type: 'square', vol: 0.16, slideTo: 70 }); beep({ freq: 90, duration: 0.22, type: 'sawtooth', vol: 0.12, delay: 0.05 }); };
const sfxTrap = () => { beep({ freq: 300, duration: 0.18, type: 'sawtooth', vol: 0.16, slideTo: 110 }); beep({ freq: 200, duration: 0.24, type: 'square', vol: 0.14, slideTo: 70, delay: 0.13 }); };
const sfxAssemble = () => [523, 659, 784, 1046].forEach((f, i) => beep({ freq: f, duration: 0.09, type: 'square', vol: 0.1, delay: i * 0.09 }));
const sfxKonami = () => [523, 659, 784, 1046, 1318].forEach((f, i) => beep({ freq: f, duration: 0.1, vol: 0.13, delay: i * 0.07 }));
const sfxWin = () => [523, 659, 784, 1046].forEach((f, i) => beep({ freq: f, duration: 0.16, vol: 0.16, delay: i * 0.12 }));
const sfxLose = () => [392, 330, 262, 196].forEach((f, i) => beep({ freq: f, duration: 0.2, type: 'sawtooth', vol: 0.13, delay: i * 0.15 }));

let musicTimer = null;
let musicStep = 0;
const BASS_PATTERN = [110, 110, 146.83, 110, 164.81, 146.83, 130.81, 98];
function startMusic() {
  if (musicTimer) return;
  musicTimer = setInterval(() => {
    if (!muted) beep({ freq: BASS_PATTERN[musicStep % BASS_PATTERN.length], duration: 0.12, type: 'triangle', vol: 0.045 });
    musicStep++;
  }, 230);
}
function stopMusic() {
  clearInterval(musicTimer);
  musicTimer = null;
  musicStep = 0;
}

// ---------------------------------------------------------------
// MENU MUSIC — a looping 8-bit tune for the start screen. Note names map
// to frequencies; the lead runs in 8th notes, bass roots hit each half-bar.
// ---------------------------------------------------------------
const NOTE = {
  R: 0,
  E2: 82.41, F2: 87.31, G2: 98.0, A2: 110.0,
  G3: 196.0, A3: 220.0,
  C4: 261.63, D4: 293.66, E4: 329.63, F4: 349.23, G4: 392.0, A4: 440.0, B4: 493.88,
  C5: 523.25, D5: 587.33, E5: 659.25, F5: 698.46, G5: 783.99, A5: 880.0,
};
const MENU_LEAD = [
  'A4', 'C5', 'E5', 'C5', 'D5', 'R', 'C5', 'R',
  'A4', 'C5', 'E5', 'A5', 'G5', 'R', 'E5', 'R',
  'F5', 'E5', 'D5', 'C5', 'D5', 'E5', 'C5', 'A4',
  'G4', 'A4', 'C5', 'E5', 'A4', 'R', 'R', 'R',
];
const MENU_BASS = ['A2', 'A2', 'A2', 'A2', 'F2', 'F2', 'G2', 'E2']; // one per 4 steps
let menuMusicTimer = null;
let menuMusicStep = 0;
function startMenuMusic() {
  if (menuMusicTimer || !actx) return;
  menuMusicStep = 0;
  menuMusicTimer = setInterval(() => {
    if (muted) { menuMusicStep++; return; }
    const s = menuMusicStep;
    const lead = NOTE[MENU_LEAD[s % MENU_LEAD.length]];
    if (lead) beep({ freq: lead, duration: 0.14, type: 'square', vol: 0.08 });
    if (s % 4 === 0) {
      const bass = NOTE[MENU_BASS[Math.floor(s / 4) % MENU_BASS.length]];
      if (bass) beep({ freq: bass, duration: 0.26, type: 'triangle', vol: 0.06 });
    }
    menuMusicStep++;
  }, 165);
}
function stopMenuMusic() {
  clearInterval(menuMusicTimer);
  menuMusicTimer = null;
  menuMusicStep = 0;
}
function toggleMute() {
  muted = !muted;
}

// ---------------------------------------------------------------
// CANVAS SETUP
// ---------------------------------------------------------------
const canvas = document.getElementById('game');
const ctx = canvas.getContext('2d');
const hintEl = document.getElementById('hint');
const hintShootEl = document.getElementById('hintShoot');
const skipBtn = document.getElementById('skipBtn');
const fallbackLink = document.getElementById('fallbackLink');

fallbackLink.href = SITE_URL;
skipBtn.addEventListener('click', goToSite);

function fitCanvas() {
  const dpr = window.devicePixelRatio || 1;
  canvas.width = CANVAS_W * dpr;
  canvas.height = CANVAS_H * dpr;
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  ctx.imageSmoothingEnabled = false;
}
fitCanvas();
window.addEventListener('resize', fitCanvas);

function goToSite() {
  stopMusic();
  stopMenuMusic();
  window.location.href = SITE_URL;
}

// ---------------------------------------------------------------
// LOGO
//   Menu: the real brand mark (r2c-logo.svg) drawn crisp.
//   Gameplay bricks: a hand-authored pixel bitmap of the wordmark.
//     The real "2" is a solid block with hair-thin (~8px) transparent
//     ribbon channels — those vanish under half a grid cell when the
//     SVG is downsampled, so the "2" turned into a solid blob. Authoring
//     the grid by hand keeps the serpentine's negative space intact at a
//     coarse, chunky resolution. Cream = R/C, orange = the "2".
// ---------------------------------------------------------------
const MENU_LOGO_W = CANVAS_W * 0.82;
const MENU_LOGO_TOP = 96;
const MENU_LOGO_FALLBACK_ASPECT = 192 / 780;
const logoImg = new Image();
let logoLoaded = false;

function getMenuLogoRect() {
  const aspect = logoImg.naturalWidth ? logoImg.naturalHeight / logoImg.naturalWidth : MENU_LOGO_FALLBACK_ASPECT;
  const w = MENU_LOGO_W;
  const h = w * aspect;
  return { x: (CANVAS_W - w) / 2, y: MENU_LOGO_TOP, w, h };
}

const LOGO_CREAM = '#E6E3D0';
const LOGO_ORANGE = '#D65E38';
// Pixel-exact transcription of the brand wordmark, extracted cell-by-cell
// from logo-reference.png. '#' = cream (R/C), 'O' = orange (the "2"),
// '.' = empty. 61 cols x 17 rows.
const LOGO_ART = [
  '################...OOOOOOOOOOOOOOOOOOOOOOO......#############',
  '#################..OOOOOOOOOOOOOOOOOOOOOOOO....##############',
  '##################.......................OO...###############',
  '#######...########.OOOOOOOOOOOOOOOOOOOO..OO..################',
  '######.....#######.OOOOOOOOOOOOOOOOOOOOO.OO.#######...#######',
  '#####.......######....................OO.OO.######.....######',
  '####.........#####..OOOOOOOOOOOOOOOOOOOO.OO.#####.......#####',
  '####.........#####.OOOOOOOOOOOOOOOOOOOO..OO.####.............',
  '####.........#####.OO....................OO.####.............',
  '#####.......#####..OO..OOOOOOOOOOOOOOOOOOOO.####.............',
  '######.....#####...OO.OOOOOOOOOOOOOOOOOOOO..#####.......#####',
  '#######...#####....OO.OO....................######.....######',
  '#######...######...OO.OOOOOOOOOOOOOOOOOOOOO.#######...#######',
  '#######...#######..OO..OOOOOOOOOOOOOOOOOOOO..################',
  '#######...########.OO.........................###############',
  '#######...########.OOOOOOOOOOOOOOOOOOOOOOOO....##############',
  '#######...########..OOOOOOOOOOOOOOOOOOOOOOO.....#############',
];

function buildLogoBitmap() {
  const artH = LOGO_ART.length;
  const artW = LOGO_ART[0].length;
  const offX = Math.floor((GRID_COLS - artW) / 2);
  const offY = Math.floor((GRID_ROWS - artH) / 2);
  const grid = Array.from({ length: GRID_ROWS }, () => Array(GRID_COLS).fill(null));
  for (let r = 0; r < artH; r++) {
    for (let c = 0; c < artW; c++) {
      const ch = LOGO_ART[r][c];
      if (ch === '#') grid[offY + r][offX + c] = { alive: true, color: LOGO_CREAM };
      else if (ch === 'O') grid[offY + r][offX + c] = { alive: true, color: LOGO_ORANGE };
    }
  }
  return grid;
}

const GRID_CELL = CANVAS_W / GRID_COLS;
const GRID_LEFT = (CANVAS_W - GRID_COLS * GRID_CELL) / 2;
let LOGO_GRID = null; // built at boot — see logoImg.onload

// ---------------------------------------------------------------
// GAME STATE
// ---------------------------------------------------------------
let state = 'menu'; // menu | intro | ready | playing | win | lose
let paused = false; // P toggles; only meaningful while state === 'playing'
let clockSec = 0;
let elapsed = 0;
let timeLeft = TIME_LIMIT;
let readyTimer = 0;
let introTimer = 0;

// Start-of-round animation: the logo assembles from scattered pixels while
// the paddle slides in from the left.
const INTRO_DURATION = 1.25;   // total intro length (seconds)
const INTRO_TRAVEL = 0.8;      // how long each pixel takes to fly to its spot
const INTRO_MAX_DELAY = 0.35;  // per-pixel stagger so they gather, not snap
const PADDLE_HOME_X = (CANVAS_W - PADDLE_W) / 2;
function easeOutCubic(t) { return 1 - Math.pow(1 - t, 3); }

let bricks = [];
let totalBricks = 0;
let destroyedCount = 0;
let livesLeft = BALL_LIVES;
let loseReason = 'time'; // 'time' | 'balls'
let laserEnabled = false;
let laserPrearmed = false;
let laserCooldown = 0;
let gunTimer = 0; // seconds of gun use remaining (Infinity when cheat-armed)

// Dropped-item bookkeeping — each of these one-shot pickups drops once.
let gunDropped = false;
let clockDropped = false;
let bomb1Dropped = false;
let hammerDropped = false;
let bombActive = false;  // red "double smash" ball currently active
let bombTimer = 0;       // seconds of bomb effect remaining

let particles = [];
let lasers = [];
let items = []; // falling pickups: { type:'gun'|'clock'|'bomb', x, y, w, h }

let toastText = '';
let toastTimer = 0;
let toastColor = '#E7BE44';

let selIndex = 0;
const menuOptions = [
  { label: 'START GAME', action: startGame },
  { label: 'ENTER SITE', action: goToSite },
];
// Out-of-time keeps TRY AGAIN first; out-of-balls leads with ENTER SITE.
const loseOptionsTime = [
  { label: 'TRY AGAIN', action: restartGame },
  { label: 'ENTER SITE', action: goToSite },
];
const loseOptionsBalls = [
  { label: 'ENTER SITE', action: goToSite },
  { label: 'TRY AGAIN', action: restartGame },
];
let loseOptions = loseOptionsTime;

const paddle = { x: (CANVAS_W - PADDLE_W) / 2, y: PADDLE_Y, w: PADDLE_W, h: PADDLE_H };
const ball = { x: 0, y: 0, r: BALL_SIZE / 2, vx: 0, vy: 0, waiting: true, respawnTimer: 0 };
let ballTrail = []; // recent {x,y} positions, only recorded while the bomb is active

const keys = {};

// ---------------------------------------------------------------
// SETUP / RESET
// ---------------------------------------------------------------
function buildBricks() {
  bricks = [];
  totalBricks = 0;
  for (let r = 0; r < GRID_ROWS; r++) {
    const row = [];
    for (let c = 0; c < GRID_COLS; c++) {
      const cell = LOGO_GRID[r][c];
      if (cell) {
        row.push({ alive: true, color: cell.color });
        totalBricks++;
      } else {
        row.push(null);
      }
    }
    bricks.push(row);
  }
  destroyedCount = 0;
  gunDropped = laserPrearmed; // if pre-armed via cheat, skip the gun drop
}

function initGame() {
  buildBricks();
  paused = false;
  elapsed = 0;
  timeLeft = TIME_LIMIT;
  livesLeft = BALL_LIVES;
  particles = [];
  lasers = [];
  items = [];
  ballTrail = [];
  clockDropped = false;
  bomb1Dropped = false;
  hammerDropped = false;
  bombActive = false;
  bombTimer = 0;
  laserEnabled = laserPrearmed;
  gunTimer = laserPrearmed ? Infinity : 0; // cheat gun never expires
  laserCooldown = 0;
  paddle.x = (CANVAS_W - PADDLE_W) / 2;
  updateShootHint();
  ball.waiting = true;
  ball.respawnTimer = 0.01;
}

function launchBall() {
  ball.x = paddle.x + paddle.w / 2;
  ball.y = paddle.y - ball.r - 1;
  const angle = (Math.random() * 0.6 - 0.3); // slight randomness
  ball.vx = Math.sin(angle) * BASE_BALL_SPEED;
  ball.vy = -Math.abs(Math.cos(angle) * BASE_BALL_SPEED);
  ball.waiting = false;
}

// Give each logo pixel a scattered start point + small delay, then play the
// assemble animation before the round begins.
function setupIntro() {
  for (let r = 0; r < GRID_ROWS; r++) {
    for (let c = 0; c < GRID_COLS; c++) {
      const b = bricks[r][c];
      if (!b) continue;
      b.ix = Math.random() * CANVAS_W;
      b.iy = 20 + Math.random() * (CANVAS_H * 0.85);
      b.idelay = Math.random() * INTRO_MAX_DELAY;
    }
  }
  introTimer = 0;
  paddle.x = -PADDLE_W - 20; // start off the left edge
  sfxAssemble();
}

function beginRound() {
  initGame();
  setupIntro();
  state = 'intro';
  startMusic();
  updateHUDVisibility();
}

function startGame() {
  ensureAudio();
  resumeAudio();
  stopMenuMusic();
  beginRound();
}

function restartGame() {
  ensureAudio();
  resumeAudio();
  beginRound();
}

function triggerWin() {
  state = 'win';
  stopMusic();
  sfxWin();
  spawnBurst(CANVAS_W / 2, GRID_TOP + (GRID_ROWS * GRID_CELL) / 2, 40);
  updateHUDVisibility();
  setTimeout(() => { if (state === 'win') goToSite(); }, 3000);
}

function triggerLose() {
  state = 'lose';
  stopMusic();
  sfxLose();
  loseOptions = loseReason === 'balls' ? loseOptionsBalls : loseOptionsTime;
  selIndex = 0; // first item selected by default
  updateHUDVisibility();
}

function updateShootHint() {
  hintShootEl.classList.toggle('active', laserEnabled);
  hintShootEl.classList.toggle('inactive', !laserEnabled);
}

function updateHUDVisibility() {
  const showHint = state === 'playing' || state === 'ready';
  hintEl.classList.toggle('visible', showHint);
  // Out-of-balls already leads its menu with ENTER SITE, so drop the
  // redundant bottom button there; keep it for win + out-of-time.
  const showSkip = state === 'win' || (state === 'lose' && loseReason !== 'balls');
  skipBtn.classList.toggle('visible', showSkip);
}

function showToast(text, color = '#E7BE44') {
  toastText = text;
  toastColor = color;
  toastTimer = 1.8;
}

// ---------------------------------------------------------------
// PARTICLES
// ---------------------------------------------------------------
function spawnParticles(x, y, color, count = 6) {
  for (let i = 0; i < count; i++) {
    const a = Math.random() * Math.PI * 2;
    const s = 40 + Math.random() * 90;
    particles.push({
      x, y, vx: Math.cos(a) * s, vy: Math.sin(a) * s,
      life: 0.35 + Math.random() * 0.25, maxLife: 0.6, color, size: 2 + Math.random() * 2,
    });
  }
}

const WIN_BURST_COLORS = ['#D65E38', '#D52B1E', '#E7BE44', '#59A9CC', '#E6E3D0'];
function spawnBurst(x, y, count) {
  for (let i = 0; i < count; i++) {
    spawnParticles(
      x + (Math.random() - 0.5) * 120,
      y + (Math.random() - 0.5) * 80,
      WIN_BURST_COLORS[Math.floor(Math.random() * WIN_BURST_COLORS.length)],
      1
    );
  }
}

function updateParticles(dt) {
  for (let i = particles.length - 1; i >= 0; i--) {
    const p = particles[i];
    p.x += p.vx * dt;
    p.y += p.vy * dt;
    p.vy += 140 * dt;
    p.life -= dt;
    if (p.life <= 0) particles.splice(i, 1);
  }
}

// ---------------------------------------------------------------
// INPUT
// ---------------------------------------------------------------
const HANDLED_KEYS = new Set(['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'Space', 'Enter', 'KeyW', 'KeyS', 'KeyA', 'KeyD', 'Escape', 'KeyQ', 'KeyM', 'KeyP']);

const KONAMI = ['ArrowUp', 'ArrowUp', 'ArrowDown', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'ArrowLeft', 'ArrowRight', 'KeyB', 'KeyA'];
let konamiBuf = [];
function trackKonami(code) {
  if (state !== 'menu') return;
  konamiBuf.push(code);
  if (konamiBuf.length > KONAMI.length) konamiBuf.shift();
  if (konamiBuf.length === KONAMI.length && konamiBuf.every((k, i) => k === KONAMI[i])) {
    laserPrearmed = true;
    konamiBuf = [];
    sfxKonami();
    showToast('CHEAT ACTIVATED — LASER READY');
  }
}

function navMenu(options, dir) {
  selIndex = (selIndex + dir + options.length) % options.length;
  sfxMenuMove();
}
function confirmMenu(options) {
  sfxMenuSelect();
  options[selIndex].action();
}

function tryShoot() {
  if (!laserEnabled || laserCooldown > 0 || state !== 'playing' || paused) return;
  lasers.push({ x: paddle.x + paddle.w / 2, y: paddle.y - 4 });
  laserCooldown = LASER_COOLDOWN;
  sfxLaser();
}

function togglePause() {
  if (state !== 'playing') return;
  paused = !paused;
  if (paused) {
    stopMusic();
    sfxMenuSelect();
  } else {
    startMusic();
    // avoid a large catch-up dt on the first frame after resuming
    lastT = performance.now();
  }
}

window.addEventListener('keydown', (e) => {
  if (HANDLED_KEYS.has(e.code)) e.preventDefault();
  ensureAudio();
  resumeAudio();
  keys[e.code] = true;

  if (e.code === 'KeyM') { toggleMute(); return; }

  trackKonami(e.code);

  if (state === 'menu') {
    if (e.code === 'ArrowUp' || e.code === 'KeyW') navMenu(menuOptions, -1);
    else if (e.code === 'ArrowDown' || e.code === 'KeyS') navMenu(menuOptions, 1);
    else if (e.code === 'Enter' || e.code === 'Space') confirmMenu(menuOptions);
    else if (e.code === 'Escape' || e.code === 'KeyQ') goToSite();
  } else if (state === 'lose') {
    if (e.code === 'ArrowUp' || e.code === 'KeyW') navMenu(loseOptions, -1);
    else if (e.code === 'ArrowDown' || e.code === 'KeyS') navMenu(loseOptions, 1);
    else if (e.code === 'Enter' || e.code === 'Space') confirmMenu(loseOptions);
    else if (e.code === 'Escape' || e.code === 'KeyQ') goToSite();
  } else if (state === 'intro' || state === 'ready' || state === 'playing') {
    if (e.code === 'Escape' || e.code === 'KeyQ') goToSite();
    else if (e.code === 'KeyP') togglePause();
    else if (e.code === 'Space') tryShoot();
  } else if (state === 'win') {
    if (e.code === 'Enter' || e.code === 'Space' || e.code === 'Escape') goToSite();
  }
});

window.addEventListener('keyup', (e) => { keys[e.code] = false; });

canvas.addEventListener('click', () => {
  if (state === 'win') goToSite();
});

// ---------------------------------------------------------------
// UPDATE
// ---------------------------------------------------------------
function clamp(v, lo, hi) { return Math.max(lo, Math.min(hi, v)); }

function speedMul(t) {
  return 1 + Math.min(t / TIME_LIMIT, 1) * (BALL_SPEED_MAX_MUL - 1);
}

function updatePaddle(dt) {
  let dir = 0;
  if (keys.ArrowLeft || keys.KeyA) dir -= 1;
  if (keys.ArrowRight || keys.KeyD) dir += 1;
  paddle.x = clamp(paddle.x + dir * PADDLE_SPEED * dt, 4, CANVAS_W - 4 - paddle.w);
}

function checkPaddleCollision(prevY) {
  if (ball.vy <= 0) return;
  // Swept check against the paddle's y-band (not just the current frame's
  // position) — at top speed the ball can move further in one frame than
  // the paddle is tall, which would otherwise let it tunnel straight through.
  const prevBottom = prevY + ball.r;
  const currBottom = ball.y + ball.r;
  if (currBottom < paddle.y || prevBottom > paddle.y + paddle.h) return;
  if (ball.x < paddle.x - ball.r || ball.x > paddle.x + paddle.w + ball.r) return;
  const rel = clamp((ball.x - (paddle.x + paddle.w / 2)) / (paddle.w / 2), -1, 1);
  const maxAngle = Math.PI / 3;
  const angle = rel * maxAngle + (Math.random() - 0.5) * BOUNCE_JITTER;
  const speed = Math.hypot(ball.vx, ball.vy);
  ball.vx = Math.sin(angle) * speed;
  ball.vy = -Math.abs(Math.cos(angle) * speed);
  ball.y = paddle.y - ball.r - 1;
  sfxPaddle();
}

// Clears an aligned `size`x`size` block around the hit cell. One impact =
// one sound (played here, not per-cell, so a big block isn't a beep storm).
function explodeAt(r, c, size, explosive) {
  const blockR = Math.floor(r / size) * size;
  const blockC = Math.floor(c / size) * size;
  let any = false;
  for (let rr = blockR; rr < blockR + size; rr++) {
    for (let cc = blockC; cc < blockC + size; cc++) {
      if (rr < 0 || rr >= GRID_ROWS || cc < 0 || cc >= GRID_COLS) continue;
      const b = bricks[rr][cc];
      if (b && b.alive) { destroyBrick(rr, cc, b); any = true; }
    }
  }
  if (any) { if (explosive) sfxExplosion(); else sfxBrick(r); }
}

function destroyBrick(r, c, brick) {
  brick.alive = false;
  destroyedCount++;
  const x = GRID_LEFT + c * GRID_CELL + GRID_CELL / 2;
  const y = GRID_TOP + r * GRID_CELL + GRID_CELL / 2;
  spawnParticles(x, y, brick.color, 3);
  // Pickups drop as cl-progress crosses each threshold, from the cleared cell.
  if (!gunDropped && destroyedCount >= Math.ceil(totalBricks * GUN_DROP_FRACTION)) {
    gunDropped = true;
    spawnItem('gun', x, y);
  }
  if (!bomb1Dropped && destroyedCount >= Math.ceil(totalBricks * BOMB1_DROP_FRACTION)) {
    bomb1Dropped = true;
    spawnItem('bomb', x, y);
  }
  if (!hammerDropped && destroyedCount >= Math.ceil(totalBricks * HAMMER_DROP_FRACTION)) {
    hammerDropped = true;
    spawnItem('hammer', x, y); // disguised trap — looks helpful, rebuilds the logo
  }
  if (destroyedCount >= totalBricks) triggerWin();
}

function ballHitsRect(rx, ry, rw, rh) {
  const bx = ball.x - ball.r, by = ball.y - ball.r, bw = ball.r * 2, bh = ball.r * 2;
  return bx < rx + rw && bx + bw > rx && by < ry + rh && by + bh > ry;
}

function resolveBallBounce(rx, ry, rw, rh) {
  const bx = ball.x - ball.r, by = ball.y - ball.r, bw = ball.r * 2, bh = ball.r * 2;
  const overlapLeft = bx + bw - rx;
  const overlapRight = rx + rw - bx;
  const overlapTop = by + bh - ry;
  const overlapBottom = ry + rh - by;
  const minX = Math.min(overlapLeft, overlapRight);
  const minY = Math.min(overlapTop, overlapBottom);
  if (minX < minY) ball.vx = overlapLeft < overlapRight ? -Math.abs(ball.vx) : Math.abs(ball.vx);
  else ball.vy = overlapTop < overlapBottom ? -Math.abs(ball.vy) : Math.abs(ball.vy);
}

function checkBrickCollision() {
  const relY = ball.y - GRID_TOP;
  if (relY < -20 || relY > GRID_ROWS * GRID_CELL + 20) return;
  const c0 = Math.max(0, Math.floor((ball.x - ball.r - GRID_LEFT) / GRID_CELL) - 2);
  const c1 = Math.min(GRID_COLS - 1, Math.floor((ball.x + ball.r - GRID_LEFT) / GRID_CELL) + 2);
  const r0 = Math.max(0, Math.floor((relY - ball.r) / GRID_CELL) - 2);
  const r1 = Math.min(GRID_ROWS - 1, Math.floor((relY + ball.r) / GRID_CELL) + 2);
  for (let r = r0; r <= r1; r++) {
    for (let c = c0; c <= c1; c++) {
      const b = bricks[r][c];
      if (!b || !b.alive) continue;
      const rx = GRID_LEFT + c * GRID_CELL, ry = GRID_TOP + r * GRID_CELL;
      if (ballHitsRect(rx, ry, GRID_CELL, GRID_CELL)) {
        resolveBallBounce(rx, ry, GRID_CELL, GRID_CELL);
        // Ball clears a 4x4 block, or 8x8 (with an explosive sound) under the bomb.
        explodeAt(r, c, bombActive ? 8 : 4, bombActive);
        return; // one impact resolved per frame
      }
    }
  }
}

const ITEM_SCALE = 0.75; // shrinks both sprite render + hitbox (25% smaller)
const ITEM_SIZES = {
  gun:   { w: 20, h: 24 },
  clock: { w: 22, h: 24 },
  bomb:  { w: 22, h: 24 },
  hammer: { w: 22, h: 24 },
};
function spawnItem(type, x, y) {
  const size = ITEM_SIZES[type];
  items.push({ type, x, y, w: size.w * ITEM_SCALE, h: size.h * ITEM_SCALE });
  sfxPowerupSpawn();
}

// Pick a falling-item origin: a random surviving logo pixel, or a random
// column near the top of the play area if the logo is nearly gone.
function randomDropOrigin() {
  const alive = [];
  for (let r = 0; r < GRID_ROWS; r++) {
    for (let c = 0; c < GRID_COLS; c++) {
      if (bricks[r][c] && bricks[r][c].alive) alive.push([r, c]);
    }
  }
  if (alive.length) {
    const [r, c] = alive[Math.floor(Math.random() * alive.length)];
    return { x: GRID_LEFT + c * GRID_CELL + GRID_CELL / 2, y: GRID_TOP + r * GRID_CELL + GRID_CELL / 2 };
  }
  return { x: 40 + Math.random() * (CANVAS_W - 80), y: GRID_TOP + 12 };
}

function applyItem(type) {
  if (type === 'gun') {
    laserEnabled = true;
    gunTimer = GUN_DURATION;
    updateShootHint();
    sfxPowerupCatch();
    showToast(`LASER — ${GUN_DURATION}s TO SHOOT`);
  } else if (type === 'clock') {
    elapsed = Math.max(0, elapsed - CLOCK_BONUS);
    timeLeft = Math.max(0, TIME_LIMIT - elapsed);
    sfxClockCatch();
    showToast(`+${CLOCK_BONUS} SECONDS`);
  } else if (type === 'bomb') {
    bombActive = true;
    bombTimer = BOMB_DURATION;
    sfxBombCatch();
    showToast('BOMB BALL — DOUBLE SMASH');
  } else if (type === 'hammer') {
    // Disguised trap: rebuilds part of the logo, undoing progress.
    restoreGrid(HAMMER_RESTORE_FRACTION);
    sfxTrap();
    showToast(`LOGO REBUILT +${Math.round(HAMMER_RESTORE_FRACTION * 100)}%`, '#D52B1E');
  }
}

// Revives a random set of already-destroyed logo cells, rolling back the
// clear-progress. Used by the hammer trap.
function restoreGrid(fraction) {
  const dead = [];
  for (let r = 0; r < GRID_ROWS; r++) {
    for (let c = 0; c < GRID_COLS; c++) {
      const b = bricks[r][c];
      if (b && !b.alive) dead.push([r, c]);
    }
  }
  for (let i = dead.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [dead[i], dead[j]] = [dead[j], dead[i]];
  }
  const n = Math.min(dead.length, Math.round(totalBricks * fraction));
  for (let i = 0; i < n; i++) {
    const [r, c] = dead[i];
    bricks[r][c].alive = true;
    destroyedCount--;
    // small revive spark so the rebuild reads visually
    if (i % 6 === 0) {
      spawnParticles(GRID_LEFT + c * GRID_CELL + GRID_CELL / 2, GRID_TOP + r * GRID_CELL + GRID_CELL / 2, bricks[r][c].color, 1);
    }
  }
}

function updateItems(dt) {
  for (let i = items.length - 1; i >= 0; i--) {
    const p = items[i];
    p.y += ITEM_FALL_SPEED * dt;
    const hitsPaddle = p.x + p.w / 2 > paddle.x && p.x - p.w / 2 < paddle.x + paddle.w &&
      p.y + p.h / 2 > paddle.y && p.y - p.h / 2 < paddle.y + paddle.h;
    if (hitsPaddle) {
      applyItem(p.type);
      items.splice(i, 1);
    } else if (p.y - p.h / 2 > CANVAS_H) {
      items.splice(i, 1);
    }
  }
}

function updateLasers(dt) {
  for (let i = lasers.length - 1; i >= 0; i--) {
    const l = lasers[i];
    l.y -= LASER_SPEED * dt;
    if (l.y < GRID_TOP - 10) { lasers.splice(i, 1); continue; }
    const relY = l.y - GRID_TOP;
    if (relY < -10 || relY > GRID_ROWS * GRID_CELL) continue;
    const c = Math.floor((l.x - GRID_LEFT) / GRID_CELL);
    const r = Math.floor(relY / GRID_CELL);
    if (r >= 0 && r < GRID_ROWS && c >= 0 && c < GRID_COLS) {
      const b = bricks[r][c];
      if (b && b.alive) {
        explodeAt(r, c, 2, false); // gun bolts always clear a 2x2 block
        lasers.splice(i, 1);
      }
    }
  }
}

function updateBall(dt) {
  if (ball.waiting) {
    ball.x = paddle.x + paddle.w / 2;
    ball.y = paddle.y - ball.r - 1;
    ball.respawnTimer -= dt;
    if (ball.respawnTimer <= 0) launchBall();
    return;
  }

  const speed = BASE_BALL_SPEED * speedMul(elapsed);
  const mag = Math.hypot(ball.vx, ball.vy) || 1;
  ball.vx = (ball.vx / mag) * speed;
  ball.vy = (ball.vy / mag) * speed;

  const prevY = ball.y;
  ball.x += ball.vx * dt;
  ball.y += ball.vy * dt;

  if (ball.x - ball.r < 4) { ball.x = 4 + ball.r; ball.vx = Math.abs(ball.vx); sfxWall(); }
  if (ball.x + ball.r > CANVAS_W - 4) { ball.x = CANVAS_W - 4 - ball.r; ball.vx = -Math.abs(ball.vx); sfxWall(); }
  if (ball.y - ball.r < 4) { ball.y = 4 + ball.r; ball.vy = Math.abs(ball.vy); sfxWall(); }

  checkPaddleCollision(prevY);
  checkBrickCollision();

  if (bombActive) {
    ballTrail.push({ x: ball.x, y: ball.y });
    if (ballTrail.length > 10) ballTrail.shift();
  } else if (ballTrail.length) {
    ballTrail.length = 0;
  }

  if (ball.y - ball.r > CANVAS_H) {
    ball.waiting = true;
    ball.respawnTimer = 0.55;
    livesLeft--;
    if (livesLeft <= 0 && state === 'playing') {
      loseReason = 'balls';
      triggerLose();
    }
  }
}

function update(dt) {
  clockSec += dt; // keeps blink animations running even while paused
  if (state === 'playing' && paused) return; // freeze all gameplay + timer

  updateParticles(dt);
  if (toastTimer > 0) toastTimer -= dt;

  if (state === 'intro') {
    introTimer += dt;
    // slide the paddle in from off the left edge
    const p = easeOutCubic(Math.min(1, introTimer / INTRO_DURATION));
    paddle.x = -PADDLE_W - 20 + (PADDLE_HOME_X - (-PADDLE_W - 20)) * p;
    if (introTimer >= INTRO_DURATION) {
      paddle.x = PADDLE_HOME_X;
      state = 'ready';
      readyTimer = 0;
      updateHUDVisibility();
    }
    return;
  }

  if (state === 'ready') {
    readyTimer += dt;
    if (readyTimer >= READY_DURATION) {
      state = 'playing';
      updateHUDVisibility();
      launchBall();
    }
    return;
  }

  if (state !== 'playing') return;

  elapsed += dt;
  timeLeft = Math.max(0, TIME_LIMIT - elapsed);
  laserCooldown = Math.max(0, laserCooldown - dt);

  if (bombActive) {
    bombTimer -= dt;
    if (bombTimer <= 0) { bombActive = false; bombTimer = 0; }
  }

  if (laserEnabled && Number.isFinite(gunTimer)) {
    gunTimer -= dt;
    if (gunTimer <= 0) {
      gunTimer = 0;
      laserEnabled = false;
      updateShootHint();
      showToast('LASER OFFLINE');
    }
  }

  // Clock: one drop once we're inside the final stretch.
  if (!clockDropped && timeLeft <= CLOCK_TIME_TRIGGER) {
    clockDropped = true;
    const o = randomDropOrigin();
    spawnItem('clock', o.x, o.y);
  }

  updatePaddle(dt);
  updateBall(dt);
  updateLasers(dt);
  updateItems(dt);

  if (timeLeft <= 0 && state === 'playing') {
    loseReason = 'time';
    triggerLose();
  }
}

// ---------------------------------------------------------------
// RENDER
// ---------------------------------------------------------------
function drawPixelText(text, x, y, size, color, align = 'center') {
  ctx.font = `${size}px 'Press Start 2P'`;
  ctx.fillStyle = color;
  ctx.textAlign = align;
  ctx.textBaseline = 'alphabetic';
  ctx.fillText(text, x, y);
}

function drawBricks() {
  for (let r = 0; r < GRID_ROWS; r++) {
    for (let c = 0; c < GRID_COLS; c++) {
      const b = bricks[r][c];
      if (!b || !b.alive) continue;
      ctx.fillStyle = b.color;
      ctx.fillRect(GRID_LEFT + c * GRID_CELL, GRID_TOP + r * GRID_CELL, GRID_CELL - 1, GRID_CELL - 1);
    }
  }
}

function drawMenuLogo() {
  if (!logoLoaded) return;
  const { x, y, w, h } = getMenuLogoRect();
  ctx.drawImage(logoImg, x, y, w, h);
}

// Pixel-art bullet: tapered nose, flat tail. (x, yBack) is the bullet's
// trailing edge (where it "fires from"), unit is the size of one pixel block.
const BULLET_PATTERN = [
  [0, 1, 0],
  [1, 1, 1],
  [1, 1, 1],
  [1, 1, 1],
  [1, 1, 1],
  [0, 1, 0],
];
function drawBulletIcon(x, yBack, unit) {
  const rows = BULLET_PATTERN.length, cols = BULLET_PATTERN[0].length;
  const left = x - (cols * unit) / 2;
  const top = yBack - rows * unit;
  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      if (BULLET_PATTERN[r][c]) ctx.fillRect(left + c * unit, top + r * unit, unit, unit);
    }
  }
}

function drawPaddle() {
  ctx.save();
  ctx.shadowColor = '#D65E38';
  ctx.shadowBlur = 10;
  ctx.fillStyle = '#F07248';
  ctx.fillRect(paddle.x, paddle.y, paddle.w, paddle.h);
  ctx.restore();
  if (laserEnabled) {
    ctx.fillStyle = '#E7BE44';
    drawBulletIcon(paddle.x + 8, paddle.y - 1, 1.5);
    drawBulletIcon(paddle.x + paddle.w - 8, paddle.y - 1, 1.5);
  }
}

function drawBall() {
  // Bomb-ball comet trail: older positions are smaller + fainter, drawn behind.
  if (bombActive && ballTrail.length) {
    for (let i = 0; i < ballTrail.length; i++) {
      const t = ballTrail[i];
      const f = (i + 1) / ballTrail.length; // 0..1, newer = larger/brighter
      ctx.globalAlpha = f * 0.55;
      ctx.fillStyle = i % 2 ? '#F07248' : '#E7BE44';
      const s = ball.r * f;
      ctx.fillRect(t.x - s, t.y - s, s * 2, s * 2);
    }
    ctx.globalAlpha = 1;
  }

  const color = bombActive ? '#D52B1E' : '#FFFFFF';
  ctx.save();
  ctx.shadowColor = color;
  ctx.shadowBlur = bombActive ? 10 : 6;
  ctx.fillStyle = color;
  ctx.fillRect(ball.x - ball.r, ball.y - ball.r, ball.r * 2, ball.r * 2);
  ctx.restore();
}

function drawParticles() {
  particles.forEach((p) => {
    ctx.globalAlpha = Math.max(0, p.life / p.maxLife);
    ctx.fillStyle = p.color;
    ctx.fillRect(p.x - p.size / 2, p.y - p.size / 2, p.size, p.size);
  });
  ctx.globalAlpha = 1;
}

function drawLasers() {
  lasers.forEach((l) => {
    ctx.save();
    ctx.shadowColor = '#E7BE44';
    ctx.shadowBlur = 6;
    ctx.fillStyle = '#E7BE44';
    drawBulletIcon(l.x, l.y, 2);
    ctx.restore();
  });
}

// Chunky 8-bit pixel-art sprites for the falling pickups. Each is a small
// matrix of color keys ('.' = transparent) rendered as fat pixels.
const ITEM_SPRITES = {
  // ammo/bullet — "the gun". Y=yellow nose, o=orange casing, W=shine, k=shadow.
  gun: {
    px: 2,
    colors: { Y: '#E7BE44', o: '#D65E38', W: '#FFFFFF', k: '#A8442A' },
    art: [
      '....YY....',
      '...YYYY...',
      '..YYYYYY..',
      '.YYYYYYYY.',
      '.YWYYYYYY.',
      '.YYYYYYYY.',
      '.oooooooo.',
      '.oooooooo.',
      '.okkkkkko.',
      '.oooooooo.',
      '.oooooooo.',
      '..oooooo..',
    ],
  },
  // hourglass — "the +time clock". R=frame(blue), s=sand(yellow), W=shine.
  clock: {
    px: 2,
    colors: { R: '#59A9CC', s: '#E7BE44', W: '#FFFFFF' },
    art: [
      'RRRRRRRRRRR',
      '.sssssssss.',
      '..sssssss..',
      '...sssss...',
      '....sss....',
      '.....s.....',
      '.....s.....',
      '....R.R....',
      '...R...R...',
      '..sssssss..',
      '.sssssssss.',
      'RRRRRRRRRRR',
    ],
  },
  // bomb — matches the reference bomb. K=body, W=shine, F=fuse, S/Y=spark.
  bomb: {
    px: 2,
    colors: { K: '#565660', W: '#FFFFFF', F: '#8A8A92', S: '#F07248', Y: '#E7BE44' },
    art: [
      '.........S.',
      '........SYS',
      '.......SF..',
      '......F....',
      '....KKKK...',
      '...KKKKKK..',
      '..KKKKKKKK.',
      '..KWWKKKKK.',
      '..KWKKKKKK.',
      '..KKKKKKKK.',
      '...KKKKKK..',
      '....KKKK...',
    ],
  },
  // hammer — a disguised trap; looks like a helpful "smash" tool.
  // M=metal head, L=metal shine, H=wood handle, h=wood highlight.
  hammer: {
    px: 2,
    colors: { M: '#8A8A92', L: '#E6E3D0', H: '#A8442A', h: '#D65E38' },
    art: [
      '.MMMMMMMMM.',
      'MLLMMMMMMMM',
      'MMMMMMMMMMM',
      'MMMMMMMMMMM',
      '....Hh.....',
      '....Hh.....',
      '....Hh.....',
      '....Hh.....',
      '....Hh.....',
      '....Hh.....',
      '...HHHH....',
      '...HHHH....',
    ],
  },
};

function drawSprite(sprite, cx, cy) {
  const { art, colors } = sprite;
  const ps = sprite.px * ITEM_SCALE;
  const rows = art.length, cols = art[0].length;
  const left = cx - (cols * ps) / 2;
  const top = cy - (rows * ps) / 2;
  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      const ch = art[r][c];
      if (ch === '.') continue;
      ctx.fillStyle = colors[ch];
      ctx.fillRect(left + c * ps, top + r * ps, ps, ps);
    }
  }
}

function drawItems() {
  items.forEach((p) => {
    const sprite = ITEM_SPRITES[p.type];
    if (!sprite) return;
    ctx.save();
    ctx.shadowColor = p.type === 'bomb' ? '#D52B1E' : p.type === 'clock' ? '#59A9CC' : p.type === 'hammer' ? '#C9C9CE' : '#E7BE44';
    ctx.shadowBlur = 6;
    drawSprite(sprite, p.x, p.y);
    ctx.restore();
  });
}

function drawHUD() {
  const blink = timeLeft < 10 ? (Math.floor(clockSec * 4) % 2 === 0) : true;
  const timeColor = timeLeft <= 20 ? '#D52B1E' : timeLeft <= 60 ? '#E7BE44' : '#FFFFFF';
  drawPixelText(`TIME ${Math.ceil(timeLeft)}`, 12, 26, 9, blink ? timeColor : 'transparent', 'left');
  drawPixelText(`BALLS ${livesLeft}`, 12, 40, 6, '#8A8A92', 'left');
  const pct = totalBricks ? Math.round((destroyedCount / totalBricks) * 100) : 0;
  drawPixelText(`${pct}%`, CANVAS_W - 12, 26, 9, '#8A8A92', 'right');
  let statusY = 40;
  if (laserEnabled && Number.isFinite(gunTimer)) {
    drawPixelText(`GUN ${Math.ceil(gunTimer)}`, CANVAS_W - 12, statusY, 6, '#E7BE44', 'right');
    statusY += 12;
  }
  if (bombActive) {
    drawPixelText(`BOMB ${Math.ceil(bombTimer)}`, CANVAS_W - 12, statusY, 6, '#D52B1E', 'right');
  }
}

function drawToast() {
  if (toastTimer <= 0) return;
  const alpha = Math.min(1, toastTimer / 0.35);
  ctx.globalAlpha = alpha;
  drawPixelText(toastText, CANVAS_W / 2, 44, 7, toastColor, 'center');
  ctx.globalAlpha = 1;
}

function renderMenu() {
  drawPixelText('ROUND 2 CUSTOMS', CANVAS_W / 2, 34, 10, '#FFFFFF');
  drawMenuLogo();
  const logoBottom = MENU_LOGO_TOP + getMenuLogoRect().h;
  drawPixelText('CLEAR THE LOGO. BEAT THE CLOCK.', CANVAS_W / 2, logoBottom + 24, 6, '#8A8A92');

  menuOptions.forEach((opt, i) => {
    const y = logoBottom + 62 + i * 26;
    const active = i === selIndex;
    drawPixelText(`${active ? '► ' : '   '}${opt.label}`, CANVAS_W / 2, y, 10, active ? '#F07248' : '#C9C9CE');
  });

  if (Math.floor(clockSec * 2) % 2 === 0) {
    drawPixelText('▲▼ SELECT   ENTER CONFIRM', CANVAS_W / 2, CANVAS_H - 20, 6, '#5A5A62');
  }
  drawToast();
}

function renderPlayfield() {
  drawBricks();
  drawParticles();
  drawItems();
  drawLasers();
  drawPaddle();
  drawBall();
  drawHUD();
  drawToast();

  if (state === 'ready') {
    ctx.fillStyle = 'rgba(0,0,0,0.35)';
    ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);
    drawPixelText('GET READY', CANVAS_W / 2, CANVAS_H / 2, 12, '#F07248');
  }

  if (state === 'playing' && paused) {
    ctx.fillStyle = 'rgba(0,0,0,0.6)';
    ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);
    drawPixelText('PAUSED', CANVAS_W / 2, CANVAS_H / 2 - 6, 14, '#E7BE44');
    if (Math.floor(clockSec * 2) % 2 === 0) {
      drawPixelText('PRESS P TO RESUME', CANVAS_W / 2, CANVAS_H / 2 + 22, 6, '#8A8A92');
    }
  }
}

function renderIntro() {
  // Each pixel flies from its scattered start to its grid home, staggered.
  for (let r = 0; r < GRID_ROWS; r++) {
    for (let c = 0; c < GRID_COLS; c++) {
      const b = bricks[r][c];
      if (!b || !b.alive) continue;
      const tx = GRID_LEFT + c * GRID_CELL, ty = GRID_TOP + r * GRID_CELL;
      const local = (introTimer - (b.idelay || 0)) / INTRO_TRAVEL;
      const p = Math.max(0, Math.min(1, local));
      const e = easeOutCubic(p);
      const x = (b.ix !== undefined ? b.ix : tx) + (tx - (b.ix !== undefined ? b.ix : tx)) * e;
      const y = (b.iy !== undefined ? b.iy : ty) + (ty - (b.iy !== undefined ? b.iy : ty)) * e;
      ctx.globalAlpha = p;
      ctx.fillStyle = b.color;
      ctx.fillRect(x, y, GRID_CELL - 1, GRID_CELL - 1);
    }
  }
  ctx.globalAlpha = 1;
  drawParticles();
  drawPaddle();
}

function renderWin() {
  drawParticles();
  drawPixelText('LEVEL CLEAR!', CANVAS_W / 2, CANVAS_H / 2 - 30, 13, '#59CC98');
  drawPixelText('THE SHOP IS OPEN', CANVAS_W / 2, CANVAS_H / 2 + 2, 8, '#FFFFFF');
  if (Math.floor(clockSec * 2) % 2 === 0) {
    drawPixelText('ENTERING SITE...', CANVAS_W / 2, CANVAS_H / 2 + 30, 7, '#8A8A92');
  }
  drawPixelText('PRESS ANY KEY TO SKIP', CANVAS_W / 2, CANVAS_H - 20, 6, '#5A5A62');
}

function renderLose() {
  const title = loseReason === 'balls' ? 'OUT OF BALLS' : "TIME'S UP";
  drawPixelText(title, CANVAS_W / 2, CANVAS_H / 2 - 60, 13, '#D52B1E');
  const pct = totalBricks ? Math.round((destroyedCount / totalBricks) * 100) : 0;
  drawPixelText(`LOGO ${pct}% CLEARED`, CANVAS_W / 2, CANVAS_H / 2 - 30, 7, '#8A8A92');

  loseOptions.forEach((opt, i) => {
    const y = CANVAS_H / 2 + 10 + i * 26;
    const active = i === selIndex;
    drawPixelText(`${active ? '► ' : '   '}${opt.label}`, CANVAS_W / 2, y, 10, active ? '#F07248' : '#C9C9CE');
  });
}

function render() {
  ctx.clearRect(0, 0, CANVAS_W, CANVAS_H);
  ctx.fillStyle = '#000000';
  ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);

  if (state === 'menu') renderMenu();
  else if (state === 'intro') renderIntro();
  else if (state === 'ready' || state === 'playing') renderPlayfield();
  else if (state === 'win') renderWin();
  else if (state === 'lose') renderLose();
}

// ---------------------------------------------------------------
// MAIN LOOP
// ---------------------------------------------------------------
let lastT = performance.now();
function frame(t) {
  let dt = (t - lastT) / 1000;
  lastT = t;
  dt = Math.min(dt, 0.05);
  update(dt);
  render();
  requestAnimationFrame(frame);
}

// The gameplay grid is hand-authored (no image needed), so build it and
// start the loop right away. The menu's crisp SVG logo fades in whenever
// it finishes loading (drawMenuLogo guards on logoLoaded).
LOGO_GRID = buildLogoBitmap();
logoImg.onload = () => { logoLoaded = true; };
logoImg.src = 'r2c-logo.svg';
updateHUDVisibility();
lastT = performance.now();
requestAnimationFrame(frame);

// Start the menu tune as early as the browser allows. We try immediately
// (works where autoplay is permitted), and otherwise unlock on the very
// first interaction of ANY kind — click, tap, or key — not just an arrow.
function unlockMenuMusic() {
  ensureAudio();
  if (!actx) return;
  const begin = () => { if (state === 'menu') startMenuMusic(); };
  if (actx.state === 'suspended') actx.resume().then(begin).catch(() => {});
  else begin();
}
['pointerdown', 'mousedown', 'touchstart', 'keydown'].forEach((ev) =>
  window.addEventListener(ev, unlockMenuMusic, { passive: true })
);
unlockMenuMusic();
