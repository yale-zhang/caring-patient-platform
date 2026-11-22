const loadingStates = new WeakMap()
let stylesAdded = false

function addStyles() {
  if (stylesAdded || typeof document === 'undefined') return

  const style = document.createElement('style')
  style.textContent = [
    '@keyframes caring-loading-spin{to{transform:rotate(360deg)}}',
    '.caring-loading-overlay{align-items:center;background:rgba(255,255,255,.72);',
    'display:flex;inset:0;justify-content:center;position:absolute;z-index:10}',
    '.caring-loading-spinner{animation:caring-loading-spin .8s linear infinite;',
    'border:2px solid #dcdfe6;border-radius:50%;border-top-color:#409eff;',
    'height:24px;width:24px}'
  ].join('')
  document.head.appendChild(style)
  stylesAdded = true
}

function updateLoading(element, binding) {
  const active = Boolean(binding.value)
  let state = loadingStates.get(element)

  if (active && typeof document === 'undefined') return

  if (!active) {
    if (!state) return
    if (state.overlay.parentNode) state.overlay.parentNode.removeChild(state.overlay)
    element.style.position = state.position
    if (state.ariaBusy === null) element.removeAttribute('aria-busy')
    else element.setAttribute('aria-busy', state.ariaBusy)
    loadingStates.delete(element)
    return
  }

  if (!state) {
    state = {
      position: element.style.position,
      ariaBusy: element.getAttribute('aria-busy'),
      overlay: document.createElement('div')
    }
    state.overlay.className = 'caring-loading-overlay'
    state.overlay.setAttribute('role', 'status')
    const spinner = document.createElement('span')
    spinner.className = 'caring-loading-spinner'
    spinner.setAttribute('aria-label', 'Loading')
    state.overlay.appendChild(spinner)

    if (typeof window !== 'undefined' && window.getComputedStyle(element).position === 'static') {
      element.style.position = 'relative'
    }
    element.appendChild(state.overlay)
    loadingStates.set(element, state)
  }

  if (!state.overlay.parentNode) element.appendChild(state.overlay)
  state.overlay.setAttribute('aria-label', typeof binding.value === 'string' ? binding.value : 'Loading')
  element.setAttribute('aria-busy', 'true')
  addStyles()
}

function removeLoading(element) {
  updateLoading(element, { value: false })
}

export default {
  bind: updateLoading,
  inserted: updateLoading,
  update: updateLoading,
  componentUpdated: updateLoading,
  mounted: updateLoading,
  updated: updateLoading,
  unbind: removeLoading,
  unmounted: removeLoading
}
