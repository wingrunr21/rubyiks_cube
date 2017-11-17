// @flow
require('dotenv').config()
const {
  createConfig,
  match,

  babel,
  devServer,
  postcss,
  sass,

  addPlugins,
  entryPoint,
  env,
  extractText,
  setOutput,
  sourceMaps
} = require('webpack-blocks')
const { html, resolveModules } = require('webpack-blocks-utils')
const webpack = require('webpack')
const path = require('path')

function roofpigLoader() {
  return (context, { merge }) => merge({
    module: {
      rules: [
        Object.assign(
          {
            test: require.resolve('roofpig'),
            use: ['imports-loader?$=jquery', 'exports-loader?CubeAnimation']
          },
          context.match
        )
      ]
    }
  })
}

module.exports = createConfig([
  // Entry points (order is important)
  entryPoint('babel-polyfill'),
  env('development', [entryPoint('react-hot-loader/patch')]),
  entryPoint('./src/index.js'),

  // Allow centralized imports
  resolveModules([path.resolve('./src'), path.resolve('./node_modules')]),

  // Configure the babel loader
  babel(),

  // Configure HTML output
  html({
    title: "Rubyik's Cube",
    template: 'assets/index.html'
  }),

  // Configure the roofpig loader
  roofpigLoader(),

  // Configure css and scss
  match(/\.s?css$/, {}, [
    sass({ includePaths: [path.resolve('node_modules')] }),
    postcss(),
    env('production', [extractText('[name].[contenthash:8].css')])
  ]),

  // Save output to 'public' with a short hash in the filename
  setOutput({
    path: path.resolve(__dirname, 'public'),
    filename: '[name].[hash:8].js',
    publicPath: '/'
  }),

  // Development
  env('development', [
    addPlugins([new webpack.NamedModulesPlugin()]),
    devServer(),
    sourceMaps()
  ]),

  // Production
  env('production', [
    sourceMaps('hidden-source-map'),
    addPlugins([
      new webpack.LoaderOptionsPlugin({
        minimize: true,
        debug: false
      }),
      new webpack.optimize.UglifyJsPlugin({
        parallel: true,
        sourceMap: true
      }),
      new webpack.optimize.ModuleConcatenationPlugin()
    ])
  ])
])