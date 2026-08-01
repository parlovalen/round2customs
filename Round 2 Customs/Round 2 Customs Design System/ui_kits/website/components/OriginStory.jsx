/* @jsx React.createElement */
function OriginStory() {
  return (
    <section style={originStyles.wrap}>
      <div style={originStyles.text}>
        <div style={originStyles.eyebrow}>PRESS START</div>
        <h2 style={originStyles.title}>THE ORIGIN STORY</h2>
        <p style={originStyles.body}>
          Founder Alen Parlov spent his childhood in arcades and his career between a
          woodshop and an electrical bench. Round 2 Customs is what happens when those
          two obsessions meet — bespoke machines that look stunning, perform flawlessly,
          and stand the test of time.
        </p>
        <p style={originStyles.body}>
          We don't ship flat-pack. We don't cut corners. Every cabinet is built one at
          a time, by hand, in Lake Barrington, Illinois.
        </p>
        <a style={originStyles.link}>READ THE FULL STORY →</a>
      </div>
      <div style={originStyles.illoWrap}>
        <CabinetIllustration />
      </div>
    </section>
  );
}

function CabinetIllustration() {
  return (
    <svg viewBox="0 0 220 320" width="280" height="auto">
      <g fill="none" stroke="#D65E38" strokeWidth="1.5">
        <rect x="40" y="20" width="140" height="40" />
        <rect x="30" y="60" width="160" height="120" />
        <rect x="50" y="80" width="120" height="80" fill="#0a0a0b" stroke="#D65E38" />
        <rect x="30" y="180" width="160" height="40" />
        <circle cx="80" cy="200" r="6" />
        <circle cx="110" cy="200" r="4" />
        <circle cx="130" cy="200" r="4" />
        <circle cx="150" cy="200" r="4" />
        <rect x="40" y="220" width="140" height="80" />
        <line x1="40" y1="240" x2="180" y2="240" />
      </g>
    </svg>
  );
}

const originStyles = {
  wrap: { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 48, padding: '80px 80px', maxWidth: 1200, margin: '0 auto', alignItems: 'center' },
  text: { display: 'flex', flexDirection: 'column', gap: 14 },
  eyebrow: { fontFamily: "'Onest', sans-serif", fontSize: 11, letterSpacing: '.32em', color: '#D65E38', fontWeight: 500, textTransform: 'uppercase' },
  title: { fontFamily: "'Michroma', sans-serif", fontSize: 32, letterSpacing: '.14em', color: '#fff', margin: '4px 0 8px' },
  body: { color: '#C9C9CE', fontSize: 14, lineHeight: 1.7, fontFamily: "'Onest', sans-serif", margin: 0 },
  link: { color: '#D65E38', fontFamily: "'Onest', sans-serif", fontSize: 12, letterSpacing: '.18em', marginTop: 12, cursor: 'pointer', fontWeight: 500, textTransform: 'uppercase' },
  illoWrap: { display: 'flex', justifyContent: 'center' },
};

window.OriginStory = OriginStory;
