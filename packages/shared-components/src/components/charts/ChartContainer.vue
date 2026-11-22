<template>
  <div ref="chart" class="caring-chart-container" :style="containerStyle" />
</template>

<script>
import * as echarts from 'echarts'

export default {
  name: 'ChartContainer',
  props: {
    options: {
      type: Object,
      default: () => ({})
    },
    height: {
      type: [Number, String],
      default: 300
    },
    width: {
      type: String,
      default: '100%'
    },
    loading: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    containerStyle() {
      return {
        height: typeof this.height === 'number' ? `${this.height}px` : this.height,
        width: this.width
      }
    }
  },
  watch: {
    options: {
      deep: true,
      handler(options) {
        if (this._chart) this._chart.setOption(options, true)
      }
    },
    loading(value) {
      if (!this._chart) return
      if (value) this._chart.showLoading()
      else this._chart.hideLoading()
    }
  },
  mounted() {
    this._chart = echarts.init(this.$refs.chart)
    this._chart.setOption(this.options, true)
    if (this.loading) this._chart.showLoading()
    this._resize = () => this._chart && this._chart.resize()

    if (typeof ResizeObserver !== 'undefined') {
      this._resizeObserver = new ResizeObserver(this._resize)
      this._resizeObserver.observe(this.$refs.chart)
    } else if (typeof window !== 'undefined') {
      window.addEventListener('resize', this._resize)
    }

    this.$emit('ready', this._chart)
  },
  beforeDestroy() {
    this.disposeChart()
  },
  beforeUnmount() {
    this.disposeChart()
  },
  methods: {
    disposeChart() {
      if (this._resizeObserver) this._resizeObserver.disconnect()
      if (typeof window !== 'undefined' && this._resize) {
        window.removeEventListener('resize', this._resize)
      }
      if (this._chart) this._chart.dispose()
      this._resizeObserver = null
      this._chart = null
    }
  }
}
</script>
