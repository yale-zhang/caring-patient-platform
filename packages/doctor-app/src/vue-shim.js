import Vue from 'vue'

// 兼容两种场景：
// 1) 项目没装 i18n：给个透传的 $t，避免 "TypeError: _vm.$t is not a function"
// 2) 装了 vue-i18n，但部分组件在 i18n 初始化前就渲染（this._i18n 为 undefined）：
//    包一层，取不到 _i18n 时直接返回 key，避免 "Cannot read properties of undefined (reading '_t')"
if (typeof Vue.prototype.$t !== 'function') {
  Vue.prototype.$t = function (key) { return key }
  Vue.prototype.$te = Vue.prototype.$te || function () { return false }
  Vue.prototype.$tc = Vue.prototype.$tc || function (key) { return key }
} else {
  const rawT = Vue.prototype.$t
  Vue.prototype.$t = function () {
    if (!this || !this._i18n) return arguments[0]
    return rawT.apply(this, arguments)
  }
  if (typeof Vue.prototype.$tc === 'function') {
    const rawTC = Vue.prototype.$tc
    Vue.prototype.$tc = function () {
      if (!this || !this._i18n) return arguments[0]
      return rawTC.apply(this, arguments)
    }
  }
}

export default Vue
