import './vue-shim'
// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'

import App from './App'
import router from './router'
import 'default-passive-events'
import { Constants } from '@/api/constants'
import 'vant/lib/index.css'
import constantItem from './api/constantItem.js' // error log
import { compressionImg } from '@/components/utils/compressImg.js'
import { h5Close, previewWeiXinCms, jumpPatientChat, backPatientManage, reservationApproval } from '@/components/utils/h5Router.js'
import headNavigation from '@/components/headNavigation/headNavigation'
import { cleanFieldRepeat } from './components/utils/formResultField'
import 'vant/lib/icon/local.css'

Vue.config.productionTip = false
Vue.prototype.Constants = Constants
Vue.prototype.$initDict = constantItem.initDict
Vue.prototype.$getDictItem = constantItem.getDictItem
Vue.prototype.$showHist = constantItem.showHist
Vue.prototype.$getShowHist = constantItem.getShowHist
Vue.prototype.$getDoctorDefaultAvatar = constantItem.getDoctorDefaultAvatar
Vue.prototype.$formatPatientName = constantItem.formatPatientName
Vue.prototype.$compressionImg = compressionImg
Vue.prototype.$cleanFieldRepeat = cleanFieldRepeat
Vue.prototype.$h5Close = h5Close
Vue.prototype.$backPatientManage = backPatientManage
Vue.prototype.$previewWeiXinCms = previewWeiXinCms
Vue.prototype.$jumpPatientChat = jumpPatientChat
Vue.prototype.$reservationApproval = reservationApproval
Vue.config.ignoredElements.push('uni')
Vue.component('headNavigation', headNavigation)

/* eslint-disable no-new */
// vue-i18n 的 $i18n 是 getter，返回 this._i18n；给没有 i18n 的实例兜底一个空实现，
// 这样 vue-i18n 自己的 $t 也不会因为 this._i18n 为空而崩
Vue.mixin({
  beforeCreate: function () {
    if (!this._i18n) {
      this._i18n = {
        locale: 'zh',
        _t: function (key) { return key },
        _tc: function (key) { return key },
        _te: function () { return false },
        _getMessages: function () { return {} }
      }
    }
  }
})

// vue-i18n 的 $t 依赖 this._i18n，某些组件在 i18n 初始化前渲染会抛 "reading '_t'"；
// 这里在创建根实例前再包一层（Vue.use(VueI18n) 会覆盖 prototype，必须放在它之后）
if (typeof Vue.prototype.$t === 'function') {
  var __raw$t = Vue.prototype.$t
  Vue.prototype.$t = function () {
    if (!this || !this.$i18n || typeof this.$i18n._t !== 'function') return arguments[0]
    return __raw$t.apply(this, arguments)
  }
  if (typeof Vue.prototype.$tc === 'function') {
    var __raw$tc = Vue.prototype.$tc
    Vue.prototype.$tc = function () {
      if (!this || !this.$i18n || typeof this.$i18n._t !== 'function') return arguments[0]
      return __raw$tc.apply(this, arguments)
    }
  }
}

new Vue({
  el: '#app',
  router,
  components: { App },
  template: '<App/>'
})
