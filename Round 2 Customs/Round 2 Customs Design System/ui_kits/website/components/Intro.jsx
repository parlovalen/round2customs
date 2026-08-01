/* @jsx React.createElement */
function RainbowDivider() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 4, padding: '60px 0' }}>
      <div style={{ height: 4, background: '#D65E38', boxShadow: '0 0 12px rgba(214,94,56,.55)' }} />
      <div style={{ height: 4, background: '#E7BE44', boxShadow: '0 0 12px rgba(231,190,68,.5)' }} />
      <div style={{ height: 4, background: '#59A9CC', boxShadow: '0 0 12px rgba(89,169,204,.5)' }} />
    </div>
  );
}

function IntroBlock() {
  return (
    <section style={introStyles.wrap}>
      <div style={introStyles.eyebrow}>MISSION</div>
      <p style={introStyles.body}>
        At Round 2 Customs, we fuse timeless nostalgia with modern performance to deliver
        handcrafted, premium arcade machines tailored to your style.
      </p>
    </section>
  );
}

const introStyles = {
  wrap: { textAlign: 'center', padding: '60px 24px 0', maxWidth: 760, margin: '0 auto' },
  eyebrow: { fontFamily: "'Onest', sans-serif", fontSize: 11, letterSpacing: '.32em', color: '#D65E38', marginBottom: 16, fontWeight: 500, textTransform: 'uppercase' },
  body: { color: '#C9C9CE', fontSize: 17, lineHeight: 1.6, fontFamily: "'Onest', sans-serif" },
};

window.RainbowDivider = RainbowDivider;
window.IntroBlock = IntroBlock;
