// ── COMPETITORS ──────────────────────────────────────────────────
const DEFAULT_COMPETITORS = [
  {
    id: 'rec-room-masters',
    name: 'Rec Room Masters',
    website: 'recroommasters.com',
    focus: 'High-end DIY kits & pro-grade PC cabinets',
    coreValueProp: 'Best-in-class DIY kit for arcade purists who want authentic parts and easy assembly.',
    keywords: ['Plug and Play', 'JAMMA-ready', 'RetroPie / Batocera / HyperSpin'],
    productTiers: [
      'Upright Xtension 2-Player DIY Cabinet Kit (flat-pack)',
      '32" Xtension Sit-Down Arcade Machine',
      'Full Emulator Edition with Cherry/ZF microswitches & IL joysticks'
    ],
    painPoints: [
      'Solo builds average 2–4 hours despite "easy assembly" marketing',
      'Flat-pack IKEA-style approach intimidates non-technical buyers',
      'Pricing not listed without navigating deep into the site'
    ],
    customersLove: [
      'Cherry/ZF microswitches and IL joysticks out of the box',
      'Swappable 2-player / 4-player controllers',
      'Compatibility with all major front-ends (HyperSpin, Launchbox, Batocera, Steam)',
      'Consistently praised customer service'
    ],
    gaps: [
      'No turn-key fully assembled option',
      'No vertical screen (SHMUP/Tate-mode) cabinets',
      'No apartment-slim form factor'
    ],
    priceRange: '$400–$1,800',
    marketPosition: 'Premium DIY',
    sentimentScore: 74
  },
  {
    id: 'gameroomsolutions',
    name: 'GameRoomSolutions',
    website: 'gameroomsolutions.com',
    focus: 'Full customization & tabletop units',
    coreValueProp: '"Build it your way" — maximum configurability from flat-pack to plug-and-play, made in the USA.',
    keywords: ['Fully Customizable', 'Built in USA', 'Free Shipping'],
    productTiers: [
      '32" Arcade Cabinet Kit (DIY, cam-lock)',
      '"Fatality" Full-Size 2-Player Kit',
      'Arcade Builder Series (choose DIY level)',
      'Ready-to-Play fully assembled units'
    ],
    painPoints: [
      'Inconsistent build quality on lower-end kits (slightly miscut pieces)',
      'Suboptimal default control layouts on entry kits',
      'No independent Trustpilot presence — all reviews on-site testimonials'
    ],
    customersLove: [
      '3D artwork preview before approval',
      'T-molding color choices',
      'Free shipping with liftgate service',
      '1-year electronics warranty',
      'Flexibility to choose assembly level'
    ],
    gaps: [
      'No compact/apartment form factor',
      'Software UI left entirely to buyer',
      'Limited third-party review social proof'
    ],
    priceRange: '$350–$1,500',
    marketPosition: 'Mid-Market DIY',
    sentimentScore: 68
  },
  {
    id: 'arcade1up',
    name: 'Arcade1Up',
    website: 'arcade1up.com',
    focus: 'Mass-market, licensed retail cabinets',
    coreValueProp: 'Officially licensed, recognizable game brands at a consumer retail price point.',
    keywords: ['Licensed Games', '¾-Size', 'Plug and Play'],
    productTiers: [
      'Budget Classics (e.g., Pac-Man Classic SE ~$334)',
      'Deluxe Edition 12-in-1 (~$500–$700)',
      'Premium/Kith Limited Editions (~$895+)'
    ],
    painPoints: [
      'Screens shaking/defective — multiple Trustpilot & BBB complaints',
      'MDF construction with screws falling out within 1–2 years',
      '$25 shipping charge for a bag of replacement screws',
      '3+ day email response times; Reddit sentiment has turned negative'
    ],
    customersLove: [
      'Brand recognition (Street Fighter, Mortal Kombat, Pac-Man)',
      'Approachable price point',
      'Available at Best Buy, Walmart, Amazon',
      'Compact ¾ size fits most spaces'
    ],
    gaps: [
      'No full-size or authentic-dimension option',
      'Poor long-term durability',
      'Software locked — cannot add games',
      'Customer service is market\'s biggest known liability'
    ],
    priceRange: '$334–$895',
    marketPosition: 'Budget / Mass Market',
    sentimentScore: 42
  },
  {
    id: 'dream-arcades',
    name: 'Dream Arcades',
    website: 'dreamarcades.com',
    focus: 'Premium multicades & cocktail table setups',
    coreValueProp: 'Commercial-grade construction with a lifetime controls warranty and the easiest MAME game-finding interface on the market.',
    keywords: ['Multicade', 'Cocktail Table', 'RetroReload MAME'],
    productTiers: [
      'Dreamcade 2.0 Cocktail Arcade (sit-around table)',
      'Upright Multicade cabinets (Windows 11 PC-based)',
      'Commercial-specification builds'
    ],
    painPoints: [
      'Most discoverable reviews from 2018–2022; 2025 sentiment is sparse',
      'Assembly-line production raises personalization concerns',
      'No vertical/SHMUP screen option'
    ],
    customersLove: [
      '¾" MDF laminated melamine construction (water-resistant)',
      'Lifetime warranty on controls',
      '1-year parts & labor warranty',
      'RetroReload software praised for easy game search',
      'Family-friendly cocktail format'
    ],
    gaps: [
      'Upright variety is limited vs. cocktail table lineup',
      'No modern streaming or online multiplayer integration',
      'Limited social media presence'
    ],
    priceRange: '$1,200–$3,500',
    marketPosition: 'Premium Multicade',
    sentimentScore: 72
  },
  {
    id: 'extreme-home-arcades',
    name: 'Extreme Home Arcades',
    website: 'extremehomearcades.com',
    focus: 'Ultra-premium, custom-built dream machines',
    coreValueProp: 'The most powerful, most personalized arcade cabinet money can buy — 23+ years in the industry, 37-point inspection, fully assembled delivery.',
    keywords: ['Custom Built', 'MegaCade', '73,000+ Games'],
    productTiers: [
      'Pre-Built Arcades (ships in 3–4 weeks)',
      'Fully Custom Builds (~3-month lead time)',
      'MegaCade / HQ MegaCade 4-Player flagships',
      '66TB drive system with 73,000+ games'
    ],
    painPoints: [
      '3-month lead time for custom builds is significant barrier',
      'Price points among highest with limited transparent pricing',
      'Thin review footprint outside their own YouTube channel'
    ],
    customersLove: [
      'Fully assembled delivery (no DIY)',
      'Animated HD active marquees that change per game',
      'RGB trim lighting',
      'Free lifetime software updates',
      '37-point inspection quality control',
      '73,000+ games "wow factor"'
    ],
    gaps: [
      'No entry-level product — extremely high floor price',
      'No apartment-friendly size',
      'Long custom lead times (3 months)',
      'Thin third-party review presence'
    ],
    priceRange: '$3,500–$12,000+',
    marketPosition: 'Ultra-Premium Custom',
    sentimentScore: 81
  },
  {
    id: 'polycade',
    name: 'Polycade',
    website: 'polycade.com',
    focus: 'Modern arcade gaming platform for home & commercial',
    coreValueProp: 'The only arcade cabinet designed to evolve — modular steel construction, swappable hardware, runs retro classics and modern titles side by side.',
    keywords: ['Modular', 'Gaming-Grade PC', 'Commercial & Home'],
    productTiers: [
      'Polycade Sente (flagship: AMD Ryzen 7 5800U, 16GB RAM, 1TB SSD)',
      'Robocade (commercial-focused)',
      'Commercial Financing available'
    ],
    painPoints: [
      'Significant price premium narrows consumer base',
      'Retro community distrusts modern aesthetic over authentic wood/arcade feel',
      'Kickstarter origins create early-backer expectation risk'
    ],
    customersLove: [
      'Powder-coated steel build (outlasts wood)',
      'AMD Ryzen PC inside for zero-lag modern gaming',
      'Modular swappable controllers and panels',
      'Design aesthetic fits design-forward spaces',
      'Dual home/commercial positioning',
      'Tyler Bushnell (son of Atari\'s Nolan Bushnell) brand credibility'
    ],
    gaps: [
      'No retro/wood aesthetic option — polarizing for traditionalists',
      'No budget tier',
      'Retro game library depth vs. competitors not clearly marketed'
    ],
    priceRange: '$2,500–$5,000',
    marketPosition: 'Modern/Design Premium',
    sentimentScore: 69
  },
  {
    id: 'retro-cade',
    name: 'Retro-Cade',
    website: 'retro-cade.com',
    focus: 'Handcrafted, heirloom-quality 2-player cabinets',
    coreValueProp: 'Handcrafted from 9-ply birch plywood (not particle board), with UV-printed artwork that won\'t peel — built to heirloom standards.',
    keywords: ['Handcrafted', 'Birch Plywood', 'UV-Printed Artwork'],
    productTiers: [
      '2-Player Classic Arcades (Ready to Go)',
      'Elite Line (fully customizable)',
      '4-Player configurations available'
    ],
    painPoints: [
      '16–18 week lead time (after artwork approval) — nearly 5 months',
      'Third-party reviews nearly absent',
      'Trust-building relies heavily on in-house claims'
    ],
    customersLove: [
      '9-ply ¾" laminated birch (not MDF/particle board)',
      'In-house 10-color UV printing (no vinyl peeling)',
      'Sanwa joysticks',
      '32" 1080p screen',
      'LED marquee, optional trackball'
    ],
    gaps: [
      'Longest lead time of any manufacturer (16–18 weeks)',
      'No ready-stock or shorter-lead pre-built option',
      'No apartment-compact form factor',
      'Minimal online review footprint'
    ],
    priceRange: '$2,000–$4,500',
    marketPosition: 'Heirloom / Artisan',
    sentimentScore: 76
  }
];

// ── MARKET INTELLIGENCE ───────────────────────────────────────────
const TRENDS_DATA = {
  reportDate: 'May 2, 2026',
  nextRefresh: 'May 16, 2026',
  marketHealth: 'GROWING FAST',
  marketSize: '$4.8B',
  marketSizeYear: '2025',
  projectedSize: '$8.6B',
  projectedYear: '2034',
  cagr: '6.7%',
  usFecSize: '$6.0B',
  barcadeCount: '2,200+',

  platforms: [
    {
      id: 'youtube',
      name: 'YouTube',
      icon: 'youtube',
      competition: 'Medium',
      opportunity: 'High',
      topFormat: 'Claw machine wins, arcade challenges, game hacks',
      keyGap: 'No major arcade venue brand owns a YouTube presence — huge first-mover opportunity',
      topVoice: 'ClawCrazy (1.3M), Arcade Warrior (2.1M), Plush Time Wins (1.9M)',
      score: 8
    },
    {
      id: 'tiktok',
      name: 'TikTok',
      icon: 'smartphone',
      competition: 'High',
      opportunity: 'Very High',
      topFormat: 'Short win reveals, claw machine grabs, prize unboxing, POV',
      keyGap: 'ClawCrazy = 750M views across platforms; venue brands absent from this format',
      topVoice: 'ClawCrazy (750M views total)',
      score: 10
    },
    {
      id: 'instagram',
      name: 'Instagram',
      icon: 'instagram',
      competition: 'Medium',
      opportunity: 'High',
      topFormat: 'Reels > Carousels > Static. BTS machine setup, staff content, UGC wins',
      keyGap: 'Carousel "5 games to try" — high save rate; tag-to-win contests = UGC engine',
      topVoice: 'Individual creators, no venue brands',
      score: 8
    },
    {
      id: 'facebook',
      name: 'Facebook',
      icon: 'facebook',
      competition: 'Low',
      opportunity: 'Medium',
      topFormat: 'Event announcements, birthday packages, tournament brackets, family moments',
      keyGap: 'Facebook Events underutilized by most venues — huge organic local reach tool',
      topVoice: 'Parents 30–50, local community groups',
      score: 6
    },
    {
      id: 'google',
      name: 'Google Trends',
      icon: 'trending-up',
      competition: 'High',
      opportunity: 'High',
      topFormat: '"arcade near me", "barcade", "family entertainment center", "VR arcade"',
      keyGap: 'Rising queries with high commercial intent — people searching to spend money',
      topVoice: 'Peak seasons: Summer (Jun–Aug), Holiday (Nov–Jan)',
      score: 9
    },
    {
      id: 'reddit',
      name: 'Reddit / Community',
      icon: 'message-circle',
      competition: 'Low',
      opportunity: 'Medium',
      topFormat: 'Nostalgia, socializing, novel experiences — top 3 visit motivators',
      keyGap: '67% of millennials respond to nostalgic marketing; Gen Z 74% positive on Y2K',
      topVoice: 'Adults 25–45 nostalgia-driven; machine quality pain points prominent',
      score: 6
    }
  ],

  trends: [
    { name: 'Retro / nostalgia arcade culture', status: 'rising', action: 'NOW', window: 'Peak millennial/Gen Z crossover' },
    { name: 'Claw machine + prize reveal content', status: 'viral', action: 'NOW', window: 'ClawCrazy proved demand at 750M views' },
    { name: 'VR / immersive arcade experiences', status: 'rising-steady', action: '3–6 months', window: 'Invest now, peak in 12 months' },
    { name: 'Family Entertainment Centers', status: 'surging', action: 'NOW', window: 'Post-COVID experience economy in full swing' },
    { name: 'Licensed IP machines (Cyberpunk, Top Gun)', status: 'rising', action: 'NOW', window: 'New releases are content hooks' },
    { name: 'Competitive socializing / tournaments', status: 'rising', action: 'NOW', window: 'Gen Z drives this category' },
    { name: '"Arcade hack" tips content', status: 'emerging', action: 'NOW', window: 'Early mover advantage available' }
  ],

  gaps: [
    { rank: 1, angle: 'Claw machine win reveals (POV)', demand: 9, supply: 4, velocity: 10, score: 15, why: '750M views proves demand; no venue brand owns this format' },
    { rank: 2, angle: '"How to beat" game tips from the venue', demand: 8, supply: 2, velocity: 9, score: 15, why: 'Individual creators do this; venue doing it = trust + authority' },
    { rank: 3, angle: 'Nostalgia triggers — then vs. now', demand: 9, supply: 3, velocity: 9, score: 15, why: '67–74% of millennials/Gen Z respond; almost no venues do this' },
    { rank: 4, angle: 'New game arrival / unboxing reveal', demand: 8, supply: 2, velocity: 8, score: 14, why: 'New releases (Cyberpunk, Top Gun) = built-in hype; nobody filming setups' },
    { rank: 5, angle: 'Staff personality / "day in the life"', demand: 7, supply: 1, velocity: 8, score: 14, why: 'Zero venue brands have staff-driven content — massive differentiation' },
    { rank: 6, angle: 'Tournament / competition recap', demand: 8, supply: 3, velocity: 8, score: 13, why: 'Competitive socializing is surging; events → content → more events' },
    { rank: 7, angle: 'Prize redemption haul / showcase', demand: 8, supply: 4, velocity: 8, score: 12, why: 'Venue perspective = unique twist on proven viral format' },
    { rank: 8, angle: '"Date night at the arcade" storyline', demand: 8, supply: 3, velocity: 7, score: 12, why: 'Adults are the growth audience; date night content is evergreen' },
    { rank: 9, angle: 'Behind-the-scenes machine maintenance', demand: 6, supply: 1, velocity: 7, score: 12, why: 'Pure curiosity content; nobody shows this; ASMR/process appeal' },
    { rank: 10, angle: 'Family moments / kids winning big', demand: 9, supply: 5, velocity: 7, score: 11, why: 'Emotional content, high shares; needs authentic execution' }
  ]
};

// ── CONTENT SCHEDULE ─────────────────────────────────────────────
const CONTENT_IDEAS = [
  {
    id: 1,
    title: 'POV: You Finally Win the Giant Prize',
    score: 15,
    platforms: ['TikTok', 'Instagram'],
    angle: 'First-person POV of the claw grabbing the biggest prize, slow-mo drop, reaction cut',
    hook: 'Fear → Relief → Joy',
    format: '15–30 sec Reel, trending audio',
    week: 1, day: 1,
    status: 'scheduled'
  },
  {
    id: 2,
    title: 'Staff Reveals How to Actually Win [Machine]',
    score: 15,
    platforms: ['TikTok', 'Instagram'],
    angle: 'Staff member giving genuine strategy tips for a specific machine',
    hook: '"We\'re not supposed to tell you this but…"',
    format: '30–60 sec talking head + machine demo',
    week: 1, day: 2,
    status: 'scheduled'
  },
  {
    id: 3,
    title: 'New Machine Setup — First Look 🔧',
    score: 14,
    platforms: ['TikTok', 'Instagram', 'Facebook'],
    angle: 'Time-lapse or POV of unboxing and setting up a brand new arcade machine',
    hook: '"First look before anyone plays it"',
    format: '30–60 sec behind-the-scenes',
    week: 1, day: 4,
    status: 'idea'
  },
  {
    id: 4,
    title: '1990 vs. 2026: The Arcade Glow-Up',
    score: 15,
    platforms: ['Instagram', 'TikTok'],
    angle: 'Side-by-side comparison of classic arcade machines vs. modern VR/immersive games',
    hook: '"It\'s not your dad\'s arcade anymore"',
    format: 'Instagram carousel + TikTok split-screen',
    week: 1, day: 6,
    status: 'idea'
  },
  {
    id: 5,
    title: 'How Many Tickets in 10 Minutes?',
    score: 14,
    platforms: ['TikTok', 'Instagram'],
    angle: 'Staff challenge — race the clock to win as many redemption tickets as possible',
    hook: 'Competition + Aspiration',
    format: '60 sec, fast-cut, ticket count reveal',
    week: 2, day: 1,
    status: 'idea'
  },
  {
    id: 6,
    title: 'What $50 Gets You at Our Arcade',
    score: 13,
    platforms: ['TikTok', 'Instagram', 'Facebook'],
    angle: 'Walk through what $50 of play looks like — games, tickets, prizes',
    hook: '"More than you think"',
    format: '45–60 sec Reel, journey from card swipe to prize',
    week: 2, day: 2,
    status: 'idea'
  },
  {
    id: 7,
    title: 'This Machine is UNDEFEATED — Watch Us Try',
    score: 14,
    platforms: ['TikTok', 'Instagram'],
    angle: 'Pick the hardest machine. Staff and customers attempt to win. Document the journey.',
    hook: '"No one has beaten this yet"',
    format: '30–60 sec, ongoing weekly series potential',
    week: 2, day: 4,
    status: 'idea'
  },
  {
    id: 8,
    title: 'Perfect Date Night — Arcade Edition',
    score: 12,
    platforms: ['Instagram', 'TikTok', 'Facebook'],
    angle: 'Two people on a date night itinerary through the arcade',
    hook: '"Steal this date idea"',
    format: '60 sec story-arc Reel with trending romantic audio',
    week: 2, day: 6,
    status: 'idea'
  },
  {
    id: 9,
    title: 'Prize Store Showcase — What Can You Actually Win?',
    score: 12,
    platforms: ['Instagram', 'TikTok'],
    angle: 'Full walkthrough of the prize redemption counter',
    hook: '"Target acquired 👀"',
    format: 'Instagram carousel + TikTok walk-and-talk',
    week: 1, day: 7,
    status: 'idea'
  },
  {
    id: 10,
    title: 'Behind the Scenes: How We Fix an Arcade Machine',
    score: 12,
    platforms: ['TikTok', 'Instagram'],
    angle: 'Quick maintenance/repair clip — adjusting claw tension, resetting tickets',
    hook: '"Ever wondered what\'s inside?"',
    format: '30–45 sec, close-up shots, satisfying sounds',
    week: 2, day: 7,
    status: 'idea'
  }
];

// ── REPORT PERIODS ────────────────────────────────────────────────
const REPORT_PERIODS = [
  { id: '2026-05', label: 'May 2026', hasData: true },
  { id: '2026-04', label: 'Apr 2026', hasData: false },
  { id: '2026-03', label: 'Mar 2026', hasData: false }
];

// ── WORKSPACES ────────────────────────────────────────────────────
const WORKSPACES = [
  { id: 'r2c', name: 'Round 2 Customs', active: true },
  { id: 'new', name: '+ Add Workspace', isAction: true }
];
