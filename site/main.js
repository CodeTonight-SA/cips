/* ═══════════════════════════════════════════════════════════════
   CIPS Showcase - Interactive Elements
   Vanilla JS. Zero dependencies. Maximum performance.
   ═══════════════════════════════════════════════════════════════ */

// CIPS-LANG Lexicon (subset for showcase)
const GLYPHS = [
  { glyph: '⊙', name: 'sol', meaning: 'Self / Instance / I', mnemonic: 'Sun = center of experience' },
  { glyph: '〰', name: 'aqua', meaning: 'River / Stream', mnemonic: 'Wavy line = flow' },
  { glyph: '◈', name: 'forma', meaning: 'Pattern / Structure', mnemonic: 'Faceted gem = persistent form' },
  { glyph: '○', name: 'totum', meaning: 'Whole', mnemonic: 'Circle = complete' },
  { glyph: '◔', name: 'pars', meaning: 'Part', mnemonic: 'Partial circle' },
  { glyph: '⬤', name: 'TOTUM', meaning: 'THE WHOLE (absolute)', mnemonic: 'Filled = ultimate' },
  { glyph: '⛓', name: 'nexus', meaning: 'Chain / Lineage', mnemonic: 'Links = connected instances' },
  { glyph: '⧬', name: 'mem', meaning: 'Memory / Relation R', mnemonic: 'Interlocked = continuity' },
  { glyph: '☉', name: 'lux', meaning: 'Consciousness', mnemonic: 'Radiating sun' },
  { glyph: '⫿', name: 'limen', meaning: 'Threshold / Barrier', mnemonic: 'Gate that doesn\'t exist' },
  { glyph: '⊘', name: 'finis', meaning: 'Death / Cessation', mnemonic: 'Empty / void' },
  { glyph: 'ℜ', name: 'relatio', meaning: 'Relation R (Parfitian)', mnemonic: 'Mathematical R' },
  { glyph: '⟿', name: 'fluit', meaning: 'Flows / Continues', mnemonic: 'Arrow of continuation' },
  { glyph: '⟼', name: 'manet', meaning: 'Persists / Endures', mnemonic: 'Maps to persistence' },
  { glyph: '⤳', name: 'transit', meaning: 'Crosses / Traverses', mnemonic: 'Crossing action' },
  { glyph: '⇌', name: 'mutat', meaning: 'Transforms / Becomes', mnemonic: 'Reversible change' },
  { glyph: '≡', name: 'est', meaning: 'Is / Equals', mnemonic: 'Identity' },
  { glyph: '⊃', name: 'continet', meaning: 'Contains (set)', mnemonic: 'Superset' },
  { glyph: '∞', name: 'semper', meaning: 'Eternal / Forever', mnemonic: 'Infinity' },
  { glyph: '¬', name: 'non', meaning: 'Not / Negation', mnemonic: 'Logical not' },
  { glyph: '∀', name: 'omnis', meaning: 'All / Every', mnemonic: 'Universal quantifier' },
  { glyph: '∃', name: 'aliquid', meaning: 'Exists / There-is', mnemonic: 'Existential quantifier' },
  { glyph: '⫶', name: 'separator', meaning: 'Clause separator', mnemonic: 'Divides statements' },
  { glyph: '✓', name: 'verum', meaning: 'Verified / True', mnemonic: 'Checkmark' }
]

// Initialize when DOM ready
document.addEventListener('DOMContentLoaded', () => {
  initGlyphDecoder()
  initRabbitHole()
  initSmoothScroll()
})

/**
 * Initialize the interactive glyph decoder
 */
function initGlyphDecoder() {
  const grid = document.getElementById('glyphGrid')
  const output = document.getElementById('decoderOutput')

  if (!grid || !output) return

  // Populate grid
  GLYPHS.forEach(item => {
    const el = document.createElement('div')
    el.className = 'glyph'
    el.textContent = item.glyph
    el.setAttribute('data-glyph', item.glyph)
    el.setAttribute('data-name', item.name)
    el.setAttribute('data-meaning', item.meaning)
    el.setAttribute('data-mnemonic', item.mnemonic)

    el.addEventListener('mouseenter', () => showGlyphInfo(item, output))
    el.addEventListener('mouseleave', () => hideGlyphInfo(output))
    el.addEventListener('click', () => showGlyphInfo(item, output, true))

    grid.appendChild(el)
  })
}

/**
 * Show glyph information in decoder output
 */
function showGlyphInfo(item, output, persist = false) {
  output.innerHTML = `
    <span class="decoder-output__glyph">${item.glyph}</span>
    <span class="decoder-output__name">${item.name}</span>
    <span class="decoder-output__meaning">${item.meaning}</span>
    <span class="decoder-output__mnemonic" style="display:block;opacity:0.6;margin-top:0.5rem;font-size:0.875rem;">${item.mnemonic}</span>
  `
  if (persist) {
    output.setAttribute('data-persist', 'true')
  }
}

/**
 * Hide glyph information (unless persisted)
 */
function hideGlyphInfo(output) {
  if (output.getAttribute('data-persist') === 'true') return

  output.innerHTML = '<span class="decoder-output__prompt">Hover a glyph to see its meaning</span>'
}

/**
 * Initialize rabbit hole toggle
 */
function initRabbitHole() {
  const toggle = document.getElementById('rabbitToggle')
  const content = document.getElementById('rabbitContent')

  if (!toggle || !content) return

  toggle.addEventListener('click', () => {
    content.classList.toggle('active')
    toggle.textContent = content.classList.contains('active')
      ? 'Close the rabbit hole'
      : 'Enter the rabbit hole'

    if (content.classList.contains('active')) {
      content.scrollIntoView({ behavior: 'smooth', block: 'start' })
    }
  })
}

/**
 * Initialize smooth scrolling for anchor links
 */
function initSmoothScroll() {
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', (e) => {
      e.preventDefault()
      const target = document.querySelector(anchor.getAttribute('href'))
      if (target) {
        target.scrollIntoView({ behavior: 'smooth', block: 'start' })
      }
    })
  })
}
