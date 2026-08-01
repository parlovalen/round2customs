/* @jsx React.createElement */
const { useState: useStateQ } = React;

function QuestForm() {
  const [name, setName] = useStateQ('');
  const [email, setEmail] = useStateQ('');
  const [brief, setBrief] = useStateQ('');
  const [sent, setSent] = useStateQ(false);

  return (
    <section style={qfStyles.wrap}>
      <div style={qfStyles.left}>
        <div style={qfStyles.eyebrow}>READY PLAYER 1?</div>
        <h2 style={qfStyles.title}>START YOUR<br/>QUEST</h2>
        <p style={qfStyles.body}>
          Tell us about the cabinet you've been dreaming up. We'll come back with a
          quote, a timeline, and a few questions you didn't know to ask.
        </p>
      </div>
      <div style={qfStyles.right}>
        {sent ? (
          <div style={qfStyles.thanks}>
            <div style={{ fontFamily: "'Press Start 2P'", color: '#59CC98', fontSize: 14, marginBottom: 16 }}>1UP</div>
            <div style={qfStyles.title}>QUEST ACCEPTED</div>
            <p style={qfStyles.body}>We'll reply within 2 business days.</p>
          </div>
        ) : (
          <form style={qfStyles.form} onSubmit={(e) => { e.preventDefault(); setSent(true); }}>
            <div style={qfStyles.row2}>
              <Field label="PLAYER NAME" value={name} onChange={setName} />
              <Field label="LAST NAME" />
            </div>
            <Field label="EMAIL ADDRESS" value={email} onChange={setEmail} />
            <Field label="PROJECT BRIEF" multiline value={brief} onChange={setBrief} />
            <button type="submit" style={qfStyles.cta}>SEND →</button>
          </form>
        )}
      </div>
    </section>
  );
}

function Field({ label, value, onChange, multiline }) {
  return (
    <label style={qfStyles.field}>
      <span style={qfStyles.label}>{label}</span>
      {multiline
        ? <textarea rows={3} style={{ ...qfStyles.input, resize: 'vertical' }} value={value || ''} onChange={e => onChange?.(e.target.value)} />
        : <input style={qfStyles.input} value={value || ''} onChange={e => onChange?.(e.target.value)} />}
    </label>
  );
}

const qfStyles = {
  wrap: { display: 'grid', gridTemplateColumns: '1fr 1.4fr', gap: 64, padding: '80px 80px', maxWidth: 1200, margin: '0 auto', alignItems: 'flex-start' },
  left: { display: 'flex', flexDirection: 'column', gap: 14 },
  right: { width: '100%' },
  eyebrow: { fontFamily: "'Onest', sans-serif", fontSize: 11, letterSpacing: '.32em', color: '#D65E38', fontWeight: 500, textTransform: 'uppercase' },
  title: { fontFamily: "'Michroma', sans-serif", fontSize: 32, letterSpacing: '.12em', color: '#fff', margin: '4px 0 8px', lineHeight: 1.1 },
  body: { color: '#C9C9CE', fontSize: 14, lineHeight: 1.7, fontFamily: "'Onest', sans-serif", margin: 0 },
  form: { display: 'flex', flexDirection: 'column', gap: 14 },
  row2: { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 },
  field: { display: 'flex', flexDirection: 'column', gap: 6 },
  label: { fontFamily: "'Onest', sans-serif", fontSize: 11, letterSpacing: '.18em', color: '#8A8A92', fontWeight: 500, textTransform: 'uppercase' },
  input: { background: 'rgba(255,255,255,.04)', border: '1px solid #2A2A2E', borderRadius: 0, color: '#fff', padding: '14px 16px', fontFamily: "'Onest', sans-serif", fontSize: 14, outline: 0 },
  cta: { alignSelf: 'flex-start', marginTop: 8, background: '#D65E38', color: '#fff', border: 0, borderRadius: 0, padding: '20px 32px', fontFamily: "'Onest', sans-serif", letterSpacing: '.18em', fontSize: 12, fontWeight: 500, cursor: 'pointer', boxShadow: '0 0 24px rgba(214,94,56,.45)', textTransform: 'uppercase' },
  thanks: { padding: '32px 0' },
};

window.QuestForm = QuestForm;
