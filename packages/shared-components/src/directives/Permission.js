import { hasPermission } from '../utils/auth'

const originalDisplays = new WeakMap()

function updatePermission(element, binding) {
  if (!originalDisplays.has(element)) {
    originalDisplays.set(element, element.style.display)
  }

  element.style.display = hasPermission(binding.value)
    ? originalDisplays.get(element)
    : 'none'
}

export default {
  bind: updatePermission,
  inserted: updatePermission,
  update: updatePermission,
  componentUpdated: updatePermission,
  mounted: updatePermission,
  updated: updatePermission
}
