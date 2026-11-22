// 必须作为 main.js 的第一个 import：apiAxios.js 等模块在 import 阶段就会
// new Vue({router}) 并触发组件渲染，此时 main.js 函数体还没执行，
// 所以 $t 兜底必须放在最前面的模块里生效。
import Vue from 'vue'

if (!Vue.prototype.$t) {
  Vue.prototype.$t = function (key) { return key }
}

export default Vue
