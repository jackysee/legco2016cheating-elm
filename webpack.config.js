var path = require('path');
var copy = require('copy-webpack-plugin');

module.exports = {
    entry: {
        app: [
            './src/index.js'
        ]
    },
    output: {
        path: path.resolve(__dirname + "/docs"),
        filename: '[name].js'
    },
    module:{
        loaders: [
            {
                test: /\.elm$/,
                exclude: [/node_modules/, /elm-stuff/],
                loader: 'elm-webpack'
            },
            {
                test: /\.html$/,
                exclude: /node_modules/,
                loader: 'file?name=[name].[ext]'
            }
        ],

        noParse: /\.elm$/
    },

    devServer: {
        inline: true,
        stats: { colors: true }
    },

    plugins: [
        new copy([
            {from: 'src/data', to:'data'}
        ])
    ]
};
