<template>
  <div class="caring-data-table">
    <div v-if="loading" class="caring-data-table__status" role="status">Loading...</div>
    <table v-else-if="data.length">
      <thead>
        <tr>
          <th
            v-for="(column, columnIndex) in columns"
            :key="column.key || column.prop || columnIndex"
            :style="{ textAlign: column.align || 'left', width: column.width }"
          >
            {{ column.label }}
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(row, rowIndex) in data" :key="getRowKey(row, rowIndex)">
          <td
            v-for="(column, columnIndex) in columns"
            :key="column.key || column.prop || columnIndex"
            :style="{ textAlign: column.align || 'left' }"
          >
            <slot
              :name="column.prop ? 'cell-' + column.prop : ''"
              :row="row"
              :column="column"
              :value="getCellValue(row, column)"
            >
              {{ formatCell(row, column) }}
            </slot>
          </td>
        </tr>
      </tbody>
    </table>
    <div v-else class="caring-data-table__status" role="status">{{ emptyText }}</div>
  </div>
</template>

<script>
export default {
  name: 'DataTable',
  props: {
    data: {
      type: Array,
      default: () => []
    },
    columns: {
      type: Array,
      default: () => []
    },
    loading: {
      type: Boolean,
      default: false
    },
    emptyText: {
      type: String,
      default: 'No data'
    },
    rowKey: {
      type: [String, Function],
      default: ''
    }
  },
  methods: {
    getCellValue(row, column) {
      return column.prop ? row[column.prop] : undefined
    },
    formatCell(row, column) {
      const value = this.getCellValue(row, column)
      return typeof column.formatter === 'function'
        ? column.formatter(row, column, value)
        : value
    },
    getRowKey(row, index) {
      if (typeof this.rowKey === 'function') return this.rowKey(row)
      if (this.rowKey) return row[this.rowKey]
      return row.id === undefined ? index : row.id
    }
  }
}
</script>

<style scoped>
.caring-data-table {
  overflow-x: auto;
  width: 100%;
}

.caring-data-table table {
  border-collapse: collapse;
  width: 100%;
}

.caring-data-table th,
.caring-data-table td {
  border-bottom: 1px solid #ebeef5;
  padding: 10px 12px;
}

.caring-data-table th {
  color: #606266;
  font-weight: 600;
}

.caring-data-table__status {
  color: #909399;
  padding: 24px 12px;
  text-align: center;
}
</style>
