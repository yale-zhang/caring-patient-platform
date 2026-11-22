const fs = require('fs')
const path = require('path')
const { createRequire } = require('module')

module.exports = function createLegacyVueConfig(appDir, mode) {
  const appRequire = createRequire(path.join(appDir, 'package.json'))
  const appConfig = appRequire(path.join(appDir, 'config', 'index.js'))
  const production = mode === 'prod'
  const paths = production ? appConfig.build : appConfig.dev
  const env = appRequire(path.join(appDir, 'config', `${mode}.env.js`))
  const resolve = name => appRequire.resolve(name)
  const webpack = appRequire('webpack')
  const vueStyleLoader = resolve('vue-style-loader')
  const cssLoader = resolve('css-loader')
  const lessLoader = resolve('less-loader')
  const styleLoaders = [vueStyleLoader, cssLoader].join('!')
  const babelInclude = [path.join(appDir, 'src')]

  try {
    babelInclude.push(path.dirname(resolve('vux/package.json')))
  } catch (error) {
    if (error.code !== 'MODULE_NOT_FOUND') throw error
  }

  const babelOptions = {
    babelrc: false,
    presets: [
      [resolve('babel-preset-env'), { modules: false }],
      resolve('babel-preset-stage-2')
    ],
    plugins: [resolve('babel-plugin-syntax-dynamic-import')]
  }

  const config = {
    context: appDir,
    entry: {
      app: path.join(appDir, 'src', 'main.js')
    },
    output: {
      path: appConfig.build.assetsRoot,
      publicPath: paths.assetsPublicPath,
      filename: production
        ? path.posix.join(paths.assetsSubDirectory, 'js/[name].[chunkhash].js')
        : path.posix.join(paths.assetsSubDirectory, 'js/[name].js'),
      chunkFilename: production
        ? path.posix.join(paths.assetsSubDirectory, 'js/[id].[chunkhash].js')
        : path.posix.join(paths.assetsSubDirectory, 'js/[id].js')
    },
    resolve: {
      extensions: ['.js', '.vue', '.json'],
      alias: {
        '@': path.join(appDir, 'src'),
        'vue$': resolve('vue/dist/vue.esm.js')
      }
    },
    module: {
      rules: [
        {
          test: /\.vue$/,
          loader: resolve('vue-loader'),
          options: {
            loaders: {
              js: {
                loader: resolve('babel-loader'),
                options: babelOptions
              },
              css: styleLoaders,
              less: styleLoaders
            },
            preLoaders: {
              less: lessLoader
            }
          }
        },
        {
          test: /\.js$/,
          loader: resolve('babel-loader'),
          include: babelInclude,
          options: babelOptions
        },
        {
          test: /\.css$/,
          use: [vueStyleLoader, cssLoader]
        },
        {
          test: /\.less$/,
          use: [vueStyleLoader, cssLoader, lessLoader]
        },
        {
          test: /\.(png|jpe?g|gif|svg|woff2?|eot|ttf|otf)(\?.*)?$/,
          loader: resolve('url-loader'),
          options: {
            limit: 10000,
            name: path.posix.join(paths.assetsSubDirectory, '[name].[hash:7].[ext]')
          }
        },
        {
          test: /\.(mp4|webm|ogg|mp3|wav|flac|aac)(\?.*)?$/,
          loader: resolve('file-loader'),
          options: {
            name: path.posix.join(paths.assetsSubDirectory, 'media/[name].[hash:7].[ext]')
          }
        }
      ]
    },
    plugins: [
      new webpack.DefinePlugin({ 'process.env': env }),
      new (appRequire('html-webpack-plugin'))({
        filename: path.basename(appConfig.build.index),
        template: path.join(appDir, 'index.html'),
        inject: true,
        chunksSortMode: 'dependency'
      })
    ],
    devtool: production
      ? (appConfig.build.productionSourceMap ? appConfig.build.devtool : false)
      : paths.devtool
  }

  const staticDir = path.join(appDir, 'static')
  if (fs.existsSync(staticDir)) {
    const CopyWebpackPlugin = appRequire('copy-webpack-plugin')
    config.plugins.push(new CopyWebpackPlugin([{
      from: staticDir,
      to: paths.assetsSubDirectory,
      ignore: ['.*']
    }]))
  }

  if (!production) {
    config.plugins.push(new webpack.HotModuleReplacementPlugin())
  }

  return config
}
