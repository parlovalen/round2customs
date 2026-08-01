/* @jsx React.createElement */
function NavV2() {
  return (
    <nav style={navV2.bar}>
      <img src="../../assets/r2c-logo.svg" style={{ height: 24 }} alt="R2C" />
      <div style={navV2.links}>
        <a style={navV2.link}>WORK</a>
        <a style={navV2.link}>PROCESS</a>
        <a style={navV2.link}>STUDIO</a>
        <a style={navV2.link}>JOURNAL</a>
      </div>
      <button style={navV2.cta}>START YOUR QUEST</button>
    </nav>
  );
}
const navV2 = {
  bar: { position:'sticky', top:0, zIndex:30, display:'grid', gridTemplateColumns:'auto 1fr auto', alignItems:'center', gap:48, padding:'20px 56px', background:'rgba(0,0,0,.8)', backdropFilter:'blur(12px)', borderBottom:'1px solid #1A1A1D' },
  links: { display:'flex', gap:36, justifyContent:'center' },
  link: { color:'#fff', fontFamily:"'Onest',sans-serif", textTransform:'uppercase', letterSpacing:'.16em', fontSize:12, fontWeight:500, cursor:'pointer' },
  cta: { background:'#D65E38', color:'#fff', border:0, borderRadius:0, padding:'14px 22px', fontFamily:"'Onest',sans-serif", fontWeight:500, letterSpacing:'.18em', fontSize:11, textTransform:'uppercase', cursor:'pointer' },
};

function HeroV2() {
  return (
    <section style={heroV2.wrap}>
      <div style={heroV2.left}>
        <div style={heroV2.eyebrow}>EST. 2019 · LAKE BARRINGTON, IL</div>
        <h1 style={heroV2.h1}>BUILT BY HAND.<br/><span style={{color:'#D65E38'}}>PLAYED FOR LIFE.</span></h1>
        <p style={heroV2.lede}>Round 2 Customs designs and handcrafts premium arcade machines — bespoke builds for collectors, game rooms, and the kinds of places where a flat-pack cabinet just won't do.</p>
        <div style={heroV2.row}>
          <button style={heroV2.cta}>START YOUR QUEST →</button>
          <a style={heroV2.ghost}>SEE THE BUILDS</a>
        </div>
      </div>
      <div style={heroV2.right}>
        <div style={heroV2.smokeP} />
        <div style={heroV2.smokeC} />
        <div style={heroV2.cabinet}>
          <div style={heroV2.marquee}>ROUND 2 CUSTOMS</div>
          <div style={heroV2.screen}>
            <div style={heroV2.screenInner}>
              <div style={heroV2.flicker}>READY<br/>PLAYER 1</div>
            </div>
          </div>
          <div style={heroV2.controls}>
            <div style={heroV2.stick} />
            <div style={{display:'flex',gap:8}}>
              <div style={heroV2.btn} /><div style={heroV2.btn} /><div style={heroV2.btn} />
            </div>
            <div style={heroV2.stick} />
          </div>
          <div style={heroV2.base} />
        </div>
      </div>
    </section>
  );
}
const heroV2 = {
  wrap: { display:'grid', gridTemplateColumns:'1.05fr 1fr', gap:64, padding:'80px 80px 100px', alignItems:'center', position:'relative', overflow:'hidden' },
  left: { display:'flex', flexDirection:'column', gap:24 },
  eyebrow: { fontFamily:"'Onest',sans-serif", letterSpacing:'.32em', fontSize:11, color:'#D65E38', fontWeight:500, textTransform:'uppercase' },
  h1: { fontFamily:"'Michroma',sans-serif", fontSize:64, lineHeight:1.05, letterSpacing:'.04em', margin:0, color:'#fff' },
  lede: { color:'#C9C9CE', fontSize:17, lineHeight:1.6, fontFamily:"'Onest',sans-serif", maxWidth:520, margin:0 },
  row: { display:'flex', gap:18, alignItems:'center', marginTop:8 },
  cta: { background:'#D65E38', color:'#fff', border:0, borderRadius:0, padding:'20px 28px', fontFamily:"'Onest',sans-serif", fontWeight:500, letterSpacing:'.18em', fontSize:12, textTransform:'uppercase', cursor:'pointer', boxShadow:'0 0 24px rgba(214,94,56,.45)' },
  ghost: { color:'#fff', fontFamily:"'Onest',sans-serif", fontSize:12, fontWeight:500, letterSpacing:'.18em', textTransform:'uppercase', cursor:'pointer', borderBottom:'1px solid #2A2A2E', paddingBottom:6 },
  right: { position:'relative', display:'flex', justifyContent:'center', alignItems:'center', minHeight:480 },
  smokeP: { position:'absolute', left:-40, top:40, width:380, height:380, background:'radial-gradient(circle, rgba(214,51,132,.5), transparent 65%)', filter:'blur(60px)' },
  smokeC: { position:'absolute', right:-40, top:40, width:380, height:380, background:'radial-gradient(circle, rgba(89,169,204,.5), transparent 65%)', filter:'blur(60px)' },
  cabinet: { position:'relative', width:300, display:'flex', flexDirection:'column', alignItems:'center' },
  marquee: { width:300, height:46, background:'#0A0A0B', border:'4px solid #fff', borderBottom:0, display:'flex', alignItems:'center', justifyContent:'center', fontFamily:"'Michroma',sans-serif", fontSize:10, letterSpacing:'.2em' },
  screen: { width:300, height:200, background:'#000', border:'5px solid #fff', display:'flex', alignItems:'center', justifyContent:'center', boxShadow:'inset 0 0 50px rgba(214,94,56,.25)' },
  screenInner: { textAlign:'center' },
  flicker: { fontFamily:"'Press Start 2P',monospace", color:'#E7BE44', fontSize:18, lineHeight:1.4, textShadow:'0 0 18px #D65E38' },
  controls: { width:300, height:54, background:'#1c1c1e', borderLeft:'5px solid #fff', borderRight:'5px solid #fff', display:'flex', alignItems:'center', justifyContent:'space-around' },
  stick: { width:20, height:30, borderRadius:20, background:'#D65E38', boxShadow:'0 0 0 2px #000, 0 4px 0 #7a2d18' },
  btn: { width:14, height:14, borderRadius:'50%', background:'#fff' },
  base: { width:300, height:160, background:'linear-gradient(180deg,#5a3d28,#3a2618)', border:'5px solid #fff', borderTop:0 },
};

function StripeBar() {
  return (
    <div style={{ display:'flex', flexDirection:'column', gap:3, padding:'4px 0' }}>
      <div style={{ height:3, background:'#D65E38' }} />
      <div style={{ height:3, background:'#E7BE44' }} />
      <div style={{ height:3, background:'#59A9CC' }} />
    </div>
  );
}

function StatStrip() {
  const stats = [
    ['07+', 'YEARS BUILDING'],
    ['1 OF 1', 'EVERY CABINET'],
    ['100%', 'HAND-FINISHED'],
    ['IL · USA', 'ASSEMBLED'],
  ];
  return (
    <section style={statStyle.wrap}>
      {stats.map(([n,l]) => (
        <div key={l} style={statStyle.cell}>
          <div style={statStyle.n}>{n}</div>
          <div style={statStyle.l}>{l}</div>
        </div>
      ))}
    </section>
  );
}
const statStyle = {
  wrap: { display:'grid', gridTemplateColumns:'repeat(4,1fr)', borderTop:'1px solid #1F1F22', borderBottom:'1px solid #1F1F22' },
  cell: { padding:'32px 24px', borderRight:'1px solid #1F1F22', display:'flex', flexDirection:'column', gap:8 },
  n: { fontFamily:"'Michroma',sans-serif", fontSize:28, color:'#fff', letterSpacing:'.04em' },
  l: { fontFamily:"'Onest',sans-serif", fontSize:11, letterSpacing:'.22em', color:'#8A8A92', fontWeight:500, textTransform:'uppercase' },
};

function Manifesto() {
  return (
    <section style={manStyle.wrap}>
      <div style={manStyle.eyebrow}>WHAT WE BELIEVE</div>
      <p style={manStyle.body}>
        Most arcade cabinets are <span style={{color:'#fff'}}>flimsy, mass-produced, disposable</span>. Ours aren't. Every Round 2 cabinet is engineered from the bench up — the same hands wire the boards and shape the cabinet. No flat packs. No shortcuts. Built to look stunning, perform flawlessly, and outlive the trend cycle.
      </p>
      <div style={manStyle.sig}>— ALEN PARLOV, FOUNDER</div>
    </section>
  );
}
const manStyle = {
  wrap: { padding:'100px 80px', maxWidth:980, margin:'0 auto', textAlign:'center', display:'flex', flexDirection:'column', gap:24, alignItems:'center' },
  eyebrow: { fontFamily:"'Onest',sans-serif", letterSpacing:'.32em', fontSize:11, color:'#D65E38', fontWeight:500, textTransform:'uppercase' },
  body: { fontFamily:"'Onest',sans-serif", fontSize:24, lineHeight:1.5, color:'#8A8A92', margin:0, maxWidth:820 },
  sig: { fontFamily:"'Onest',sans-serif", letterSpacing:'.22em', fontSize:11, color:'#fff', fontWeight:500, marginTop:8 },
};

function ProcessV2() {
  const steps = [
    ['01', 'BRIEF', 'You tell us about the build — theme, players, footprint, the games that matter.'],
    ['02', 'DESIGN', 'Renders, finishes, hardware specs. We iterate until you can already see it in the room.'],
    ['03', 'BUILD', 'Cabinet milled and finished in the woodshop. Boards wired and tuned at the bench.'],
    ['04', 'DELIVER', 'White-glove install. Tutorial included. Then you press start.'],
  ];
  return (
    <section style={pv2.wrap}>
      <div style={pv2.head}>
        <div style={pv2.eyebrow}>SELECT YOUR CHARACTER</div>
        <h2 style={pv2.title}>HOW A QUEST GETS BUILT</h2>
      </div>
      <div style={pv2.grid}>
        {steps.map(([n,t,b]) => (
          <div key={n} style={pv2.card}>
            <div style={pv2.num}>{n}</div>
            <div style={pv2.t}>{t}</div>
            <div style={pv2.b}>{b}</div>
          </div>
        ))}
      </div>
    </section>
  );
}
const pv2 = {
  wrap: { padding:'80px 80px', maxWidth:1280, margin:'0 auto' },
  head: { display:'flex', flexDirection:'column', gap:12, marginBottom:40 },
  eyebrow: { fontFamily:"'Onest',sans-serif", letterSpacing:'.32em', fontSize:11, color:'#D65E38', fontWeight:500, textTransform:'uppercase' },
  title: { fontFamily:"'Michroma',sans-serif", fontSize:32, letterSpacing:'.12em', color:'#fff', margin:0 },
  grid: { display:'grid', gridTemplateColumns:'repeat(4,1fr)', gap:0, borderTop:'1px solid #1F1F22' },
  card: { padding:'32px 28px 36px', borderRight:'1px solid #1F1F22', borderBottom:'1px solid #1F1F22', display:'flex', flexDirection:'column', gap:14 },
  num: { fontFamily:"'Michroma',sans-serif", color:'#D65E38', fontSize:14, letterSpacing:'.2em' },
  t: { fontFamily:"'Michroma',sans-serif", color:'#fff', fontSize:18, letterSpacing:'.16em' },
  b: { fontFamily:"'Onest',sans-serif", color:'#C9C9CE', fontSize:14, lineHeight:1.6 },
};

function GalleryStrip() {
  const tiles = [
    { name:'NEON HEIST', tag:'Spider-Man · 2P', g1:'#D63384', g2:'#D65E38' },
    { name:'COIN HOARD', tag:'Pac-Man · 1P', g1:'#E7BE44', g2:'#0A0A0B' },
    { name:'TILT ROYALE', tag:'Pinball · BAR EDITION', g1:'#59A9CC', g2:'#D63384' },
    { name:'BAT SIGNAL', tag:'Batman · 2P', g1:'#D65E38', g2:'#59A9CC' },
  ];
  return (
    <section style={gs.wrap}>
      <div style={gs.head}>
        <div>
          <div style={gs.eyebrow}>HALL OF FAME</div>
          <h2 style={gs.title}>RECENT BUILDS</h2>
        </div>
        <a style={gs.link}>SEE ALL 24 →</a>
      </div>
      <div style={gs.grid}>
        {tiles.map(t => (
          <article key={t.name} style={gs.card}>
            <div style={{ ...gs.thumb, background:`linear-gradient(160deg, ${t.g1}, ${t.g2})` }}>
              <div style={gs.thumbInner} />
            </div>
            <div style={gs.body}>
              <div style={gs.name}>{t.name}</div>
              <div style={gs.tag}>{t.tag}</div>
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}
const gs = {
  wrap: { padding:'40px 80px 100px', maxWidth:1280, margin:'0 auto' },
  head: { display:'flex', justifyContent:'space-between', alignItems:'flex-end', marginBottom:32 },
  eyebrow: { fontFamily:"'Onest',sans-serif", letterSpacing:'.32em', fontSize:11, color:'#D65E38', fontWeight:500, textTransform:'uppercase', marginBottom:10 },
  title: { fontFamily:"'Michroma',sans-serif", fontSize:32, letterSpacing:'.12em', color:'#fff', margin:0 },
  link: { color:'#fff', fontFamily:"'Onest',sans-serif", fontWeight:500, fontSize:12, letterSpacing:'.18em', textTransform:'uppercase', cursor:'pointer', borderBottom:'1px solid #2A2A2E', paddingBottom:6 },
  grid: { display:'grid', gridTemplateColumns:'repeat(4,1fr)', gap:16 },
  card: { display:'flex', flexDirection:'column', cursor:'pointer' },
  thumb: { aspectRatio:'4/5', position:'relative', border:'1px solid #2A2A2E' },
  thumbInner: { position:'absolute', inset:'18% 14%', background:'rgba(0,0,0,.45)', border:'2px solid rgba(255,255,255,.08)' },
  body: { padding:'14px 0 0', display:'flex', flexDirection:'column', gap:6 },
  name: { fontFamily:"'Michroma',sans-serif", fontSize:12, letterSpacing:'.18em', color:'#fff' },
  tag: { fontSize:12, color:'#8A8A92', fontFamily:"'Onest',sans-serif" },
};

function CTABanner() {
  return (
    <section style={cb.wrap}>
      <div style={cb.eyebrow}>READY PLAYER 1?</div>
      <h2 style={cb.h}>YOUR CABINET DOESN'T <span style={{color:'#D65E38'}}>EXIST YET.</span><br/>LET'S FIX THAT.</h2>
      <button style={cb.cta}>START YOUR QUEST →</button>
    </section>
  );
}
const cb = {
  wrap: { padding:'120px 80px', textAlign:'center', display:'flex', flexDirection:'column', alignItems:'center', gap:24, borderTop:'1px solid #1F1F22', borderBottom:'1px solid #1F1F22' },
  eyebrow: { fontFamily:"'Onest',sans-serif", letterSpacing:'.32em', fontSize:11, color:'#D65E38', fontWeight:500, textTransform:'uppercase' },
  h: { fontFamily:"'Michroma',sans-serif", fontSize:48, letterSpacing:'.06em', color:'#fff', lineHeight:1.15, margin:0 },
  cta: { background:'#D65E38', color:'#fff', border:0, borderRadius:0, padding:'22px 36px', fontFamily:"'Onest',sans-serif", fontWeight:500, letterSpacing:'.18em', fontSize:13, textTransform:'uppercase', cursor:'pointer', marginTop:8, boxShadow:'0 0 30px rgba(214,94,56,.45)' },
};

function FooterV2() {
  return (
    <footer style={fv2.wrap}>
      <div style={fv2.top}>
        <div style={{display:'flex',flexDirection:'column',gap:18,maxWidth:340}}>
          <img src="../../assets/r2c-logo.svg" style={{ height:30 }} alt="R2C" />
          <div style={fv2.muted}>Custom arcade cabinets, handcrafted in Lake Barrington, IL.</div>
        </div>
        <div style={fv2.cols}>
          <div>
            <div style={fv2.colTitle}>STUDIO</div>
            <div style={fv2.li}>Lake Barrington, IL</div>
            <div style={fv2.li}>By appointment only</div>
          </div>
          <div>
            <div style={fv2.colTitle}>CONTACT</div>
            <div style={fv2.li}>alen@round2customs.com</div>
            <div style={fv2.li}>224.522.0875</div>
          </div>
          <div>
            <div style={fv2.colTitle}>FOLLOW</div>
            <div style={{...fv2.li, color:'#59A9CC'}}>@round2customs</div>
          </div>
        </div>
      </div>
      <div style={fv2.bot}>© 2026 ROUND 2 CUSTOMS · ALL CABINETS HANDBUILT · NO FLAT PACKS</div>
    </footer>
  );
}
const fv2 = {
  wrap: { padding:'48px 80px 32px', borderTop:'1px solid #1A1A1D', background:'#000' },
  top: { display:'grid', gridTemplateColumns:'1fr 1fr', gap:48, alignItems:'flex-start' },
  cols: { display:'grid', gridTemplateColumns:'repeat(3,1fr)', gap:36 },
  colTitle: { fontFamily:"'Onest',sans-serif", letterSpacing:'.22em', fontSize:11, color:'#8A8A92', fontWeight:500, textTransform:'uppercase', marginBottom:12 },
  li: { fontFamily:"'Onest',sans-serif", fontSize:13, color:'#C9C9CE', marginBottom:4 },
  muted: { fontFamily:"'Onest',sans-serif", fontSize:13, color:'#8A8A92', lineHeight:1.6 },
  bot: { marginTop:48, paddingTop:24, borderTop:'1px solid #1A1A1D', fontFamily:"'Onest',sans-serif", fontSize:11, letterSpacing:'.18em', color:'#5A5A62', fontWeight:500, textTransform:'uppercase' },
};

Object.assign(window, { NavV2, HeroV2, StripeBar, StatStrip, Manifesto, ProcessV2, GalleryStrip, CTABanner, FooterV2 });
