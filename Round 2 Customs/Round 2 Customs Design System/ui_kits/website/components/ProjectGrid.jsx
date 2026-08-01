/* @jsx React.createElement */
function ProjectGrid() {
  const projects = [
    { name: 'NEON HEIST', tag: 'Spider-Man · 2P', g1: '#D63384', g2: '#D65E38' },
    { name: 'COIN HOARD', tag: 'Pac-Man · 1P', g1: '#E7BE44', g2: '#000' },
    { name: 'TILT ROYALE', tag: 'Pinball · BAR EDITION', g1: '#59A9CC', g2: '#D63384' },
    { name: 'BAT SIGNAL', tag: 'Batman · 2P', g1: '#D65E38', g2: '#59A9CC' },
  ];
  return (
    <section style={pgStyles.wrap}>
      <div style={pgStyles.head}>
        <div style={pgStyles.eyebrow}>HALL OF FAME</div>
        <h2 style={pgStyles.title}>EXAMPLE PROJECTS</h2>
      </div>
      <div style={pgStyles.grid}>
        {projects.map(p => (
          <div key={p.name} style={pgStyles.card}>
            <div style={{ ...pgStyles.thumb, background: `linear-gradient(160deg, ${p.g1}, ${p.g2})` }}>
              <div style={pgStyles.thumbInner} />
            </div>
            <div style={pgStyles.cardBody}>
              <div style={pgStyles.cardName}>{p.name}</div>
              <div style={pgStyles.cardTag}>{p.tag}</div>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}

const pgStyles = {
  wrap: { padding: '40px 80px 80px', maxWidth: 1280, margin: '0 auto' },
  head: { textAlign: 'center', marginBottom: 36 },
  eyebrow: { fontFamily: "'Onest', sans-serif", fontSize: 11, letterSpacing: '.32em', color: '#D65E38', marginBottom: 12, fontWeight: 500, textTransform: 'uppercase' },
  title: { fontFamily: "'Michroma', sans-serif", fontSize: 28, letterSpacing: '.16em', color: '#fff', margin: 0 },
  grid: { display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 16 },
  card: { background: 'transparent', border: '1px solid #2A2A2E', borderRadius: 0, overflow: 'hidden', cursor: 'pointer', transition: 'all .2s' },
  thumb: { aspectRatio: '4/5', position: 'relative' },
  thumbInner: { position: 'absolute', inset: '20% 15%', background: 'rgba(0,0,0,.45)', border: '2px solid rgba(255,255,255,.08)' },
  cardBody: { padding: '16px 18px', display: 'flex', flexDirection: 'column', gap: 6 },
  cardName: { fontFamily: "'Michroma', sans-serif", fontSize: 11, letterSpacing: '.18em', color: '#fff' },
  cardTag: { fontSize: 11, color: '#8A8A92', fontFamily: "'Onest', sans-serif" },
};

window.ProjectGrid = ProjectGrid;
