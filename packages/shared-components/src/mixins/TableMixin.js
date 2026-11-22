export default {
  data() {
    return {
      tableData: [],
      tableLoading: false,
      tablePagination: {
        current: 1,
        pageSize: 10,
        total: 0
      }
    }
  },
  methods: {
    handleTablePageChange(current) {
      this.tablePagination.current = current
    },
    handleTablePageSizeChange(pageSize) {
      this.tablePagination.current = 1
      this.tablePagination.pageSize = pageSize
    }
  }
}
