/**
 * 慢病管理平台 - 共享组件库入口文件
 */

import MobileHeader from './components/mobile/MobileHeader.vue'
import DataTable from './components/desktop/DataTable.vue'
import ChartContainer from './components/charts/ChartContainer.vue'
import request from './utils/request'
import { formatDate, formatPhone } from './utils/format'
import { getToken, setToken, hasPermission, hasRole, isLoggedIn, logout } from './utils/auth'
import AuthMixin from './mixins/AuthMixin'
import TableMixin from './mixins/TableMixin'
import Permission from './directives/Permission'
import Loading from './directives/Loading'
import { dateFilter, phoneFilter } from './filters/index'

// 工具函数导出
export { MobileHeader, DataTable, ChartContainer }
export { request, formatDate, formatPhone, getToken, setToken, hasPermission, hasRole, isLoggedIn, logout }

// 混入导出
export { AuthMixin, TableMixin }

// 指令导出
export { Permission, Loading }

// 过滤器导出
export { dateFilter, phoneFilter }

// Vue插件安装方法
const components = [
  MobileHeader,
  DataTable,
  ChartContainer
]

const install = function(app) {
  components.forEach(component => app.component(component.name, component))
  app.directive('permission', Permission)
  app.directive('loading', Loading)

  if (typeof app.filter === 'function') {
    app.filter('date', dateFilter)
    app.filter('phone', phoneFilter)
  }

  const globalProperties = app.config && app.config.globalProperties
    ? app.config.globalProperties
    : app.prototype
  globalProperties.$request = request
  globalProperties.$formatDate = formatDate
}

// 自动安装
if (typeof window !== 'undefined' && window.Vue) {
  install(window.Vue)
}

export default {
  version: '1.0.0',
  install,
  MobileHeader,
  DataTable,
  ChartContainer
}