path = require 'path'
fs = require 'fs'
#生产目录
ROOT = "#{__dirname}/static"
BUILD = "#{__dirname}/build"
module.exports = (grunt)->
    #项目配置
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'
        #压缩js
        uglify:
            app:
                files: [
                    expand: true
                    cwd: "#{ROOT}/js/app"
                    src: ['**/*.js','!**/*.min.js']
                    ext: '.min.js'
                    dest: "#{BUILD}/js/app"
                ]
            lib:
                files: [
                    expand: true
                    cwd: "#{ROOT}/js/lib"
                    src: ['**/*.js','!**/*.min.js']
                    ext: '.min.js'
                    dest: "#{BUILD}/js/lib"
                ]
        #检测js语法
        jshint: 
            options:
                ignores: ["#{ROOT}/js/app/**/*.min.js"]
            uses_defaults: ["#{ROOT}/js/app/**/*.js"]
            with_overrides: []
        requirejs:
            options:
                paths:
                    backbone: 'lib/backbone/1.1.2/backbone'
                    jquery: 'lib/jquery/1.7.2/jquery'
                    swiper: 'lib/swiper/3.0.4/swiper.jquery'
                    underscore: 'lib/underscore/1.8.2/underscore'
                shim:
                    backbone: 
                        deps: ['underscore', 'jquery']
                        exports: 'Backbone'
                    underscore: 
                        exports: '_'
            appIndex:
                options:
                    baseUrl: 'static/js'
                    out: "#{BUILD}/js/app-index.js"
                    name: 'app/view/index'
        #编译less成css
        less:
            options:
                paths: ["#{ROOT}/css"]
            app:
                #自动添加后缀
                options:
                    plugins: [
                        new (require('less-plugin-autoprefix')) {browsers: ["last 20 versions"]}
                    ]
                files: [
                    {
                        expand: true
                        cwd: "#{ROOT}/css/app"
                        src: '**/*.less'
                        ext: '.css'
                        dest: "#{BUILD}/css/app"
                    }
                ]
            lib:
                options:
                    compress: true
                files: [
                    {
                        expand: true
                        cwd: "#{ROOT}/css/lib"
                        src: ['**/*.css','!**/*.min.css']
                        ext: '.min.css'
                        dest: "#{BUILD}/css/lib"
                    }
                ]
        csslint:
            # options:
            #     csslintrc: '.csslintrc'
            app:
                src: ["#{BUILD}/css/app/**/*.css"]
        #自动根据指定排列css属性
        csscomb:
            options:
                config: '.csscomb.json'
            app:
                files: [
                    {
                        expand: true
                        cwd: "#{BUILD}/css/app"
                        src: ['**/*.css','!**/*.min.css']
                        ext: '.css'
                        dest: "#{BUILD}/css/app"
                    }
                ]
        #压缩css文件
        cssmin:
            app:
                files: [
                    {
                        expand: true
                        cwd: "#{BUILD}/css/app"
                        src: ['**/*.css','!**/*.min.css']
                        ext: '.min.css'
                        dest: "#{BUILD}/css/app"
                    }
                ]
        imagemin:
            common:
                files: [
                    {
                        expand: true
                        cwd: "#{ROOT}/img"
                        src: "**/*.{png,jpg,gif}"
                        dest: "#{ROOT}/img"
                    }
                ]
        watch:
            options:
                spawn: false
                interrupt: true
            app_js:
                files: ["static/js/app/**/*.js"]
                tasks: ['uglify:app','jshint','requirejs']  
            app_css:
                files: ["static/css/app/**/*.less"]
                tasks: ['less:app','csslint:app','csscomb:app','cssmin:app']
            image:
                files: ["static/img/**/*.{png,jpg,gif}"]
                tasks: ['imagemin']
        copy:
            app_css:
                files: [
                    {
                        expand: true
                        cwd: "#{ROOT}/css/app"
                        src: "!**/*.less"
                        dest: "#{BUILD}/css/app"
                    }
                ]
            lib_css:
                files: [
                    {
                        expand: true
                        cwd: "#{ROOT}/css/lib"
                        src: ['!**/*.css','!**/*.min.css']
                        dest: "#{BUILD}/css/lib"
                    }
                ]
            app_js:
                files: [
                    {
                        expand: true
                        cwd: "#{ROOT}/js/app"
                        src: ['!**/*.js','!**/*.min.js']
                        dest: "#{BUILD}/js/app"
                    }
                ]
            lib_js:
                files: [
                    {
                        expand: true
                        cwd: "#{ROOT}/js/lib"
                        src: ['!**/*.js','!**/*.min.js']
                        dest: "#{BUILD}/js/lib"
                    }
                ]
            image:
                files: [
                    {
                        expand: true
                        cwd: "#{ROOT}/img"
                        src: ["!**/*.{png,jpg,gif}"]
                        dest: "#{BUILD}/img"
                    }
                ]
    # Load the plugin that provides the "uglify" task.
    grunt.loadNpmTasks('grunt-contrib-uglify')
    grunt.loadNpmTasks('grunt-contrib-jshint')
    grunt.loadNpmTasks('grunt-contrib-requirejs')
    grunt.loadNpmTasks('grunt-contrib-less')
    grunt.loadNpmTasks('grunt-contrib-csslint')
    grunt.loadNpmTasks('grunt-csscomb')
    grunt.loadNpmTasks('grunt-contrib-cssmin')
    grunt.loadNpmTasks('grunt-contrib-imagemin')
    grunt.loadNpmTasks('grunt-contrib-watch')
    grunt.loadNpmTasks('grunt-contrib-copy')
    # Default task(s).
    grunt.registerTask('default', ['uglify', 'jshint', 'requirejs', 'less', 'csslint', 'csscomb', 'cssmin', 'imagemin', 'copy'])