// ── SHARED APP UTILITIES ──────────────────────────────────────────

// Load competitors from localStorage or defaults
function loadCompetitors() {
  try {
    const saved = localStorage.getItem('r2c_competitors');
    if (saved) return JSON.parse(saved);
  } catch (e) {}
  return DEFAULT_COMPETITORS;
}

function saveCompetitors(list) {
  localStorage.setItem('r2c_competitors', JSON.stringify(list));
}

// ── SIDE RAIL ─────────────────────────────────────────────────────
function buildRail(activePage, subItems) {
  const pages = [
    { id: 'index',       label: 'Hub',                  icon: 'layout-grid', href: 'index.html' },
    { id: 'trends',      label: 'Market Intelligence',   icon: 'trending-up', href: 'trends.html' },
    { id: 'competitive', label: 'Competitor Analysis',   icon: 'crosshair',   href: 'competitive.html' },
    { id: 'content',     label: 'Content Schedule',      icon: 'calendar',    href: 'content.html' }
  ];

  const activeDash = pages.find(p => p.id === activePage) || pages[0];

  const dashMenuHTML = pages.map(p => `
    <a href="${p.href}" class="workspace-option${p.id === activePage ? ' active' : ''}">
      <i data-lucide="${p.icon}" style="font-size:12px;flex-shrink:0;"></i>
      ${p.label}
    </a>
  `).join('');

  const sectionLabel = { trends: 'Sections', competitive: 'Companies', content: 'Reports' }[activePage];

  const subNavHTML = subItems?.length ? `
    <div class="nav-section-label">${sectionLabel || ''}</div>
    ${subItems.map(s => `
      <div class="nav-item${s.active ? ' active' : ''}${s.isAction ? ' nav-item-action' : ''}" onclick="${s.onclick}">
        <span>${s.label}</span>
      </div>
    `).join('')}
  ` : '';

  const rail = document.getElementById('rail');
  if (!rail) return;

  rail.innerHTML = `
    <div class="rail-logo">
      <img src="../Round%202%20Customs%20Design%20System/assets/r2c-logo.svg" alt="Round 2 Customs"
        onerror="this.style.display='none'; this.nextElementSibling.style.display='block'">
      <div style="display:none">
        <div class="rail-logo-text">ROUND 2</div>
        <div class="rail-logo-sub">Customs</div>
      </div>
    </div>

    <div class="workspace-switcher" id="workspaceSwitcher">
      <div class="ws-row">
        <button class="dash-btn" onclick="toggleDashMenu(event)">
          <i data-lucide="${activeDash.icon}"></i>
          <span class="dash-label">${activeDash.label}</span>
          <span class="workspace-chevron">▾</span>
        </button>
        <div class="workspace-menu" id="dashMenu">
          ${dashMenuHTML}
        </div>
      </div>
    </div>

    <nav class="rail-nav">
      ${subNavHTML}
    </nav>

    <div class="rail-footer">
      <div class="rail-footer-meta">
        <strong>Last synced</strong><br>
        May 2, 2026 — 2 reports
      </div>
    </div>
  `;

  if (window.lucide) lucide.createIcons();
}

function toggleDashMenu(e) {
  e.stopPropagation();
  document.getElementById('dashMenu').classList.toggle('open');
}

document.addEventListener('click', () => {
  document.getElementById('dashMenu')?.classList.remove('open');
});

// ── LUCIDE ICON INIT ──────────────────────────────────────────────
function initIcons() {
  if (window.lucide) lucide.createIcons();
}

// ── MODAL HELPERS ─────────────────────────────────────────────────
function openModal(id) {
  document.getElementById(id)?.classList.add('open');
}

function closeModal(id) {
  document.getElementById(id)?.classList.remove('open');
}

function platformBadge(platform) {
  const colors = {
    'TikTok': 'chip-red',
    'Instagram': 'chip-orange',
    'Facebook': 'chip-blue',
    'YouTube': 'chip-red'
  };
  return `<span class="chip ${colors[platform] || ''}">${platform}</span>`;
}

function scoreColor(score) {
  if (score >= 14) return 'var(--green)';
  if (score >= 12) return 'var(--yellow)';
  return 'var(--text-2)';
}
