const path = require('path')
const { createRequire } = require('module')
const createLegacyVueConfig = require('./legacy-vue-config')

const appDir = process.cwd()
const appRequire = createRequire(path.join(appDir, 'package.json'))
const appConfig = appRequire(path.join(appDir, 'config', 'index.js'))
const webpack = appRequire('webpack')
const WebpackDevServer = appRequire('webpack-dev-server')
const compiler = webpack(createLegacyVueConfig(appDir, 'dev'))
const host = process.env.HOST || appConfig.dev.host || 'localhost'
const port = Number(process.env.PORT || appConfig.dev.port)
const server = new WebpackDevServer(compiler, {
  host,
  port,
  hot: true,
  inline: true,
  historyApiFallback: true,
  publicPath: appConfig.dev.assetsPublicPath,
  stats: 'errors-only'
})

server.listen(port, host, error => {
  if (error) {
    console.error(error)
    process.exitCode = 1
    return
  }

  console.log(`Development server running at http://${host}:${port}/`)
})

function closeServer() {
  server.close(() => process.exit())
}

process.once('SIGINT', closeServer)
process.once('SIGTERM', closeServer)
