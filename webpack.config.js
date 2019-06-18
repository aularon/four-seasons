const path = require('path');

const isProd = process.env.NODE_ENV === 'production';

module.exports = {
  // If your entry-point is at "src/index.js" and
  // your output is in "/dist", you can ommit
  // these parts of the config
  module: {
    rules: [{
        test: /\.html$/,
        exclude: /node_modules/,
        loader: 'file-loader?name=[name].[ext]'
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        // This is what you need in your own work
        loader: "elm-webpack-loader",
        // loader: '../index.js',
        options: {
          debug: !isProd,
          optimize: isProd
          // warn: true
        }
      },
      {
        test: /\.less$/,
        use: [{
          loader: 'style-loader' // creates style nodes from JS strings
        }, {
          loader: 'css-loader' // translates CSS into CommonJS
        }, {
          loader: 'less-loader' // compiles Less to CSS
        }]
      }
    ]
  },

  devServer: {
    inline: true,
    stats: 'errors-only',
    contentBase: path.resolve('src'),
    historyApiFallback: {
      index: 'index.html'
    }
  }
};
