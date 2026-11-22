const path = require('path')
const { createRequire } = require('module')
const createLegacyVueConfig = require('./legacy-vue-config')

const appDir = process.cwd()
const appRequire = createRequire(path.join(appDir, 'package.json'))
const webpack = appRequire('webpack')
const webpackConfig = createLegacyVueConfig(appDir, 'prod')

webpack(webpackConfig, (error, stats) => {
  if (error) {
    console.error(error.stack || error)
    if (error.details) console.error(error.details)
    process.exitCode = 1
    return
  }

  const output = stats.toString({
    colors: Boolean(process.stdout.isTTY),
    modules: false,
    chunks: false,
    children: false
  })
  console.log(output)
  if (stats.hasErrors()) process.exitCode = 1
})
