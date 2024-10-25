const path = require('path');

module.exports = {
  entry: path.resolve(__dirname, 'src/js/app.js'), // Use absolute path for better resolution
  output: {
    filename: 'app.js',
    path: path.resolve(__dirname, '../priv/static/js'),  // Output directory
    publicPath: '/js/'
  },
  mode: 'production',
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env']
          }
        }
      }
    ]
  },
  resolve: {
    extensions: ['.js']
  }
};

