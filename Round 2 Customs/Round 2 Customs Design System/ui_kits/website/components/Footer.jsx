/* @jsx React.createElement */
function Footer() {
  return (
    <footer style={footStyles.wrap}>
      <div style={footStyles.top}>
        <img src="../../assets/r2c-logo.svg" style={{ height: 28 }} alt="R2C" />
        <div style={footStyles.cols}>
          <Col title="STUDIO">
            <div>Lake Barrington, IL</div>
            <div style={{ color: '#D65E38' }}>round2customs.com</div>
          </Col>
          <Col title="CONTACT">
            <div>alen@round2customs.com</div>
            <div>224.522.0875</div>
          </Col>
          <Col title="FOLLOW">
            <div style={{ color: '#59A9CC' }}>@round2customs</div>
          </Col>
        </div>
        <div style={footStyles.socials}>
          <span style={{ ...footStyles.socIcon, color: '#59A9CC' }}>◉</span>
          <span style={{ ...footStyles.socIcon, color: '#E7BE44' }}>☞</span>
          <span style={{ ...footStyles.socIcon, color: '#D65E38' }}>✉</span>
        </div>
      </div>
      <div style={footStyles.fine}>
        © 2026 ROUND 2 CUSTOMS · HANDCRAFTED IN ILLINOIS
      </div>
    </footer>
  );
}

function Col({ title, children }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      <div style={{ fontFamily: "'Onest', sans-serif", fontSize: 11, letterSpacing: '.18em', color: '#8A8A92', fontWeight: 500, textTransform: 'uppercase' }}>{title}</div>
      <div style={{ color: '#C9C9CE', fontSize: 13, fontFamily: "'Onest', sans-serif", display: 'flex', flexDirection: 'column', gap: 2 }}>{children}</div>
    </div>
  );
}

const footStyles = {
  wrap: { background: '#0A0A0B', borderTop: '1px solid #1A1A1D', padding: '40px 80px 32px' },
  top: { display: 'grid', gridTemplateColumns: 'auto 1fr auto', gap: 48, alignItems: 'flex-start' },
  cols: { display: 'flex', gap: 56 },
  socials: { display: 'flex', gap: 16, alignItems: 'center' },
  socIcon: { fontSize: 22, fontFamily: "'Press Start 2P', monospace", cursor: 'pointer' },
  fine: { marginTop: 32, color: '#5A5A62', fontSize: 11, letterSpacing: '.18em', fontFamily: "'Onest', sans-serif", textTransform: 'uppercase', fontWeight: 500 },
};

window.Footer = Footer;
