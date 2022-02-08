module.exports = function (config) {
    config.set({
        basePath: 'TechKiteOFFICEappstore/core/static/',
        frameworks: ['jasmine'],
        mime: { 'text/x-typescript': ['ts','tsx'] },
        files: [
            {pattern: 'assets/app/**/*Spec.ts', watched: false}
        ],
        exclude: [],
        preprocessors: {
            'assets/app/**/*.ts': ['webpack']
        },
        webpackMiddleware: {
            noInfo: true,
            stats: {
                chunks: false,
                colors: true
            }
        },
        webpack: {
            resolve: {
                extensions: ['.js', '.ts', '.tsx']
            },
            module: {
                rules: [
                    {
                        test: /\.tsx?$/,
                        loader: 'ts-loader'
                    }
                ]
            },
            stats: {
                colors: true,
                modules: true,
                reasons: true,
                errorDetails: true
            },
            devtool: 'inline-source-map',
            mode: 'production'
        },
        reporters: ['progress'],
        port: 9876,
        colors: true,
        logLevel: config.LOG_INFO,
        autoWatch: true,
        browsers: ['Firefox'],
        singleRun: false,
        concurrency: Infinity,
    })
};
