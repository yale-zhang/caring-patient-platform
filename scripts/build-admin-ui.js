const path = require('path')
const { spawnSync } = require('child_process')
const { createRequire, Module } = require('module')

const appDir = path.resolve(__dirname, '..', 'packages', 'admin-ui')
const appRequire = createRequire(path.join(appDir, 'package.json'))
const cli = appRequire.resolve('@vue/cli-service/bin/vue-cli-service.js')

process.env.NODE_PATH = [
  path.join(appDir, 'node_modules'),
  process.env.NODE_PATH
].filter(Boolean).join(path.delimiter)
Module._initPaths()

const result = spawnSync(process.execPath, [cli, ...process.argv.slice(2)], {
  cwd: appDir,
  env: process.env,
  stdio: 'inherit'
})

if (result.error) {
  console.error(result.error)
  process.exitCode = 1
} else {
  process.exitCode = result.status === null ? 1 : result.status
}
