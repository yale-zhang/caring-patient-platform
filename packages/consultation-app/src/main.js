import './vue-shim'
// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'

import FastClick from 'fastclick'
import VueRouter from 'vue-router'
import App from './App'
import store from "./webIM/store";
import router from './router/index'
import Antd from 'ant-design-vue'
// import './assets/css/font-awesonmme/css/font-awesome.min.css'
import './assets/css/weui/weui.css'
// import vant from 'vant'
import echarts from 'echarts';


import BaseService from './service/common/baseService'
import sassWxJs from './components/utils/wxConfigUrl'
import Tools from './service/common/tools'
import { Constants } from '@/api/constants';
import 'vant/lib/index.css';
import 'vant/lib/icon/local.css';
import { Checkbox, CheckboxGroup, Icon, Uploader, Image as VanImage, Col, Row, ImagePreview, PullRefresh, Toast, Switch, Search, Overlay, Loading} from 'vant';
import { LoadingPlugin, ToastPlugin, AlertPlugin,GroupTitle,Cell, Grid,GridItem,XHeader,Popup,TransferDom,XSwitch, Tabbar, TabbarItem,Flexbox, FlexboxItem,XDialog } from 'vux'
// Vue.use(vant)
Vue.use(Checkbox)
Vue.use(CheckboxGroup)
Vue.use(Icon)
Vue.use(PullRefresh)
Vue.use(VanImage)
Vue.use(Uploader)
Vue.use(Col)
Vue.use(Toast)
Vue.use(Row)
Vue.use(LoadingPlugin)
Vue.use(AlertPlugin)
Vue.use(ToastPlugin)
Vue.use(Antd)
Vue.use(ImagePreview)
Vue.use(Loading)
Vue.use(Switch)
Vue.use(Search)
Vue.use(Overlay)
Vue.prototype.$getWxConfigSignatureUrl = sassWxJs.getWxConfigSignatureUrl

Vue.component('x-header', XHeader)
Vue.component('grid', Grid)
Vue.component('grid-item', GridItem)
Vue.component('group-title', GroupTitle)
Vue.component('cell', Cell)
Vue.directive('transfer-dom', TransferDom)
Vue.component('x-switch', XSwitch)
Vue.component('tabbar', Tabbar)
Vue.component('tabbar-item', TabbarItem)

Vue.component('popup', Popup)
Vue.component('x-dialog', XDialog)

Vue.component('flexbox', Flexbox)
Vue.component('flexbox-item', FlexboxItem)
import wx from 'weixin-js-sdk'


//Vue.use(Vuex)
Vue.use(VueRouter)

// util 和baseService 直接注入到Vue上
Vue.use(Tools)
Vue.use(BaseService)
// seesion 过期弹框登录
import login from '@/components/user/loginDialog.vue'
Vue.use(login)
Vue.use(wx)
Vue.use(echarts)
//注册AbScroller
import AbScroller from '@/components/form/abScroller.vue';
Vue.component('abScroller', AbScroller);
//注册AbCustDialog
import AbCustDialog from '@/components/form/abCustDialog.vue';
Vue.component('abCustDialog', AbCustDialog);

FastClick.attach(document.body)

Vue.config.productionTip = false
Vue.prototype.Constants = Constants;
// Vue.prototype.$axios = axios
/* eslint-disable no-new */

const Base64 = require('js-base64').Base64

// 防抖处理 -- 最后执行
const on = Vue.prototype.$on
Vue.prototype.$on = function (event, func) {
  let timer
  let newFunc = func
  if (event === 'click') {
    newFunc = function () {
      clearTimeout(timer)
      timer = setTimeout(function () {
        func.apply(this, arguments)
      }, 500)
    }
  }
  // console.log('防抖')
  on.call(this, event, newFunc)
}

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

window.Vue = new Vue({
  router,
  store,
  Base64,
  render: h => h(App)
}).$mount('#app-box')
