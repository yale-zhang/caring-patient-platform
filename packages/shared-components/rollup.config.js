const path = require('path')
const vue = require('rollup-plugin-vue')

const external = id => /^(vue|axios|moment|echarts)(\/.*)?$/.test(id)

module.exports = {
  input: path.resolve(__dirname, 'src/index.js'),
  external,
  plugins: [
    vue({
      css: true,
      compileTemplate: true
    })
  ],
  output: [
    {
      file: path.resolve(__dirname, 'dist/index.esm.js'),
      format: 'es',
      exports: 'named'
    },
    {
      file: path.resolve(__dirname, 'dist/index.cjs.js'),
      format: 'cjs',
      exports: 'named'
    }
  ]
}
