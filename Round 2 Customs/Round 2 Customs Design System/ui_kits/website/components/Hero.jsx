/* @jsx React.createElement */
function Hero() {
  return (
    <section style={heroStyles.wrap}>
      <div style={heroStyles.smokeL} />
      <div style={heroStyles.smokeR} />
      <div style={heroStyles.center}>
        <div style={heroStyles.eyebrow}>INSERT COIN</div>
        <h1 style={heroStyles.title}>PRESS <span style={{color:'#D65E38'}}>START</span></h1>
        <p style={heroStyles.sub}>Handcrafted, premium arcade machines tailored to your style.</p>
        <button style={heroStyles.cta}>START YOUR QUEST →</button>
      </div>
    </section>
  );
}

const heroStyles = {
  wrap: { position: 'relative', overflow: 'hidden', padding: '120px 24px 140px', background: '#000' },
  smokeL: { position: 'absolute', left: -120, top: 60, width: 600, height: 520, background: 'radial-gradient(circle, rgba(214,51,132,.4), transparent 65%)', filter: 'blur(70px)', pointerEvents: 'none' },
  smokeR: { position: 'absolute', right: -120, top: 60, width: 600, height: 520, background: 'radial-gradient(circle, rgba(89,169,204,.45), transparent 65%)', filter: 'blur(70px)', pointerEvents: 'none' },
  center: { position: 'relative', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 18, textAlign: 'center' },
  eyebrow: { fontFamily: "'Onest', sans-serif", fontSize: 11, letterSpacing: '.32em', color: '#D65E38', fontWeight: 500, textTransform: 'uppercase' },
  title: { fontFamily: "'Michroma', sans-serif", fontSize: 80, letterSpacing: '.06em', margin: 0, color: '#fff', lineHeight: 1 },
  sub: { color: '#C9C9CE', fontSize: 16, maxWidth: 520, lineHeight: 1.6, margin: 0, fontFamily: "'Onest', sans-serif" },
  cta: { marginTop: 12, background: '#D65E38', color: '#fff', border: 0, borderRadius: 0, padding: '20px 32px', fontFamily: "'Onest', sans-serif", textTransform: 'uppercase', letterSpacing: '.18em', fontSize: 12, fontWeight: 500, cursor: 'pointer', boxShadow: '0 0 24px rgba(214,94,56,.45)' },
};

window.Hero = Hero;
