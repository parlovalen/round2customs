/* @jsx React.createElement */
function Nav() {
  return (
    <nav style={navStyles.bar}>
      <div style={navStyles.group}>
        <a style={navStyles.link}>HOME</a>
        <a style={navStyles.link}>BUILDS</a>
        <a style={navStyles.link}>ABOUT</a>
      </div>
      <img src="../../assets/r2c-logo.svg" style={{ height: 26 }} alt="R2C" />
      <div style={navStyles.group}>
        <a style={navStyles.link}>PROCESS</a>
        <a style={navStyles.link}>CONTACT</a>
        <a style={{ ...navStyles.link, color: '#D65E38' }}>QUOTE</a>
      </div>
    </nav>
  );
}

const navStyles = {
  bar: {
    position: 'sticky', top: 0, zIndex: 30,
    display: 'flex', alignItems: 'center', justifyContent: 'space-between',
    padding: '18px 48px',
    background: 'rgba(0,0,0,.75)', backdropFilter: 'blur(12px)',
    borderBottom: '1px solid #1A1A1D',
  },
  group: { display: 'flex', gap: 28, alignItems: 'center' },
  link: {
    color: '#fff', fontFamily: "'Onest', sans-serif",
    textTransform: 'uppercase', letterSpacing: '.16em', fontSize: 12, fontWeight: 500,
    cursor: 'pointer',
  },
};

window.Nav = Nav;
