# 共享组件库 (@caring/shared-components)

慢病管理平台的共享组件库，提供通用的UI组件和工具函数。

## 功能特性

- 🎨 统一的UI组件设计
- 🔧 通用工具函数
- 📱 移动端适配组件
- 🌐 支持 Vue 2.x
- 📊 图表组件封装
- 🌍 国际化支持

## 技术栈

- **框架**: Vue 2.6+
- **UI组件**: Vant 2.11.0 / 3.4.5 + Element UI 2.12.0
- **构建工具**: Rollup 2.0.0
- **HTTP客户端**: Axios 0.26.0 / 0.27.2
- **时间处理**: Moment.js 2.29.4
- **图表库**: ECharts 4.2.1 / 5.3.2

## 项目结构

```
src/
├── components/          # 通用组件
│   ├── mobile/         # 移动端组件
│   ├── desktop/        # 桌面端组件
│   └── charts/         # 图表组件
├── utils/               # 工具函数
│   ├── request.js      # HTTP请求封装
│   ├── auth.js         # 认证相关
│   └── format.js       # 数据格式化
├── mixins/              # Vue混入
├── directives/          # 自定义指令
├── filters/             # 过滤器
└── index.js             # 入口文件
```

## 使用方法

### 安装

```bash
npm install @caring/shared-components
```

### 引入组件

```javascript
// 全局引入
import CaringComponents from '@caring/shared-components'
import Vue from 'vue'

Vue.use(CaringComponents)

// 按需引入
import { MobileHeader, DataTable } from '@caring/shared-components'
```

### 使用组件

```vue
<template>
  <div>
    <mobile-header title="患者管理" />
    <data-table :data="tableData" :columns="columns" />
  </div>
</template>

<script>
import { MobileHeader, DataTable } from '@caring/shared-components'

export default {
  components: {
    MobileHeader,
    DataTable
  },
  data() {
    return {
      tableData: [],
      columns: [
        { prop: 'name', label: '姓名' },
        { prop: 'age', label: '年龄' }
      ]
    }
  }
}
</script>
```

### 使用工具函数

```javascript
import { request, formatDate } from '@caring/shared-components'

// HTTP请求
request.get('/api/patients').then(data => {
  console.log(data)
})

// 格式化日期
const formatted = formatDate(new Date(), 'YYYY-MM-DD')
```

## 开发指南

### 添加新组件

1. 在 `src/components/` 对应目录下创建组件
2. 编写组件文档和示例
3. 在 `src/index.js` 中导出组件
4. 添加单元测试

### 组件规范

```vue
<template>
  <div class="caring-component">
    <!-- 组件内容 -->
  </div>
</template>

<script>
export default {
  name: 'CaringComponent',
  props: {
    // 属性定义
  },
  data() {
    return {
      // 数据定义
    }
  },
  methods: {
    // 方法定义
  }
}
</script>

<style scoped>
.caring-component {
  /* 组件样式 */
}
</style>
```

### 工具函数规范

```javascript
/**
 * 格式化日期
 * @param {Date} date 日期对象
 * @param {string} format 格式字符串
 * @returns {string} 格式化后的日期
 */
export function formatDate(date, format) {
  // 实现逻辑
}
```

## 构建和发布

### 开发环境

```bash
npm run dev
```

### 构建

```bash
npm run build
```

### 测试

```bash
npm run test
```

## 注意事项

- 组件库支持 Vue 2.x
- 移动端组件基于Vant，桌面端组件基于Element UI
- 图表组件基于ECharts封装
- 工具函数保持纯函数特性
- 所有组件都需要添加完整的类型定义

## 贡献指南

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](../../../LICENSE) 文件了解详情。