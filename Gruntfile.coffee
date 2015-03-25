path = require 'path'
fs = require 'fs'
#生产目录
SOURCE = "#{__dirname}/src"
BUILD = "#{__dirname}/build"
module.exports = (grunt)->
    #项目配置
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'
        clean:
            build: BUILD
        #复制不用构建的文件
        copy:
            app_css:
                files: [
                    {
                        expand: true
                        cwd: "#{SOURCE}/css/app"
                        src: "!**/*.less"
                        dest: "#{BUILD}/css/app"
                    }
                ]
            lib_css:
                files: [
                    {
                        expand: true
                        cwd: "#{SOURCE}/css/lib"
                        src: ['!**/*.css','!**/*.min.css']
                        dest: "#{BUILD}/css/lib"
                    }
                ]
            app_js:
                files: [
                    {
                        expand: true
                        cwd: "#{SOURCE}/js/app"
                        src: ['!**/*.js','!**/*.min.js']
                        dest: "#{BUILD}/js/app"
                    }
                ]
            lib_js:
                files: [
                    {
                        expand: true
                        cwd: "#{SOURCE}/js/lib"
                        src: ['!**/*.js','!**/*.min.js']
                        dest: "#{BUILD}/js/lib"
                    }
                ]
            image:
                files: [
                    {
                        expand: true
                        cwd: "#{SOURCE}/img"
                        src: ["!**/*.{png,jpg,gif}"]
                        dest: "#{BUILD}/img"
                    }
                ]
        #检测js语法
        jshint: 
            options:
                ignores: ["#{SOURCE}/js/app/**/*.min.js"]
            uses_defaults: ["#{SOURCE}/js/app/**/*.js"]
            with_overrides: []
        #压缩js
        uglify:
            app:
                files: [
                    expand: true
                    cwd: "#{SOURCE}/js/app"
                    src: ['**/*.js','!**/*.min.js']
                    ext: '.min.js'
                    dest: "#{BUILD}/js/app"
                ]
            lib:
                files: [
                    expand: true
                    cwd: "#{SOURCE}/js/lib"
                    src: ['**/*.js','!**/*.min.js']
                    ext: '.min.js'
                    dest: "#{BUILD}/js/lib"
                ]
        #requirejs模块化并合并压缩js
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
            #合并首页js
            appIndex:
                options:
                    baseUrl: 'src/js'
                    out: "#{BUILD}/js/app-index.js"
                    name: 'app/view/index'
        #编译less成css
        less:
            options:
                paths: ["#{SOURCE}/css"]
            app:
                #自动添加后缀
                options:
                    plugins: [
                        new (require('less-plugin-autoprefix')) {browsers: ["last 20 versions"]}
                    ]
                files: [
                    {
                        expand: true
                        cwd: "#{SOURCE}/css/app"
                        src: '**/*.less'
                        ext: '.css'
                        dest: "#{SOURCE}/css/app"
                    }
                ]
            lib:
                options:
                    compress: true
                files: [
                    {
                        expand: true
                        cwd: "#{SOURCE}/css/lib"
                        src: ['**/*.css','!**/*.min.css']
                        ext: '.min.css'
                        dest: "#{BUILD}/css/lib"
                    }
                ]
        #检测编译好的css语法
        csslint:
            options:
                csslintrc: '.csslintrc.json'
            app:
                src: ["#{SOURCE}/css/app/**/*.css","!#{SOURCE}/css/app/**/*.min.css"]
        #自动根据指定排列css属性
        csscomb:
            options:
                config: '.csscomb.json'
            app:
                files: [
                    {
                        expand: true
                        cwd: "#{SOURCE}/css/app"
                        src: ['**/*.css','!**/*.min.css']
                        ext: '.css'
                        dest: "#{SOURCE}/css/app"
                    }
                ]
        #压缩css文件
        cssmin:
            app:
                files: [
                    {
                        expand: true
                        cwd: "#{SOURCE}/css/app"
                        src: ['**/*.css','!**/*.min.css']
                        ext: '.min.css'
                        dest: "#{BUILD}/css/app"
                    }
                ]
        #合并文件
        concat:
            #合并首页css
            appIndexCss:
                src: ["#{BUILD}/css/lib/normalize/3.0.2/normalize.min.css", "#{BUILD}/css/app/common.min.css"]
                dest: "#{BUILD}/css/app-index.css"
        #压缩图片素材
        imagemin:
            common:
                files: [
                    {
                        expand: true
                        cwd: "#{SOURCE}/img"
                        src: "**/*.{png,jpg,gif}"
                        dest: "#{BUILD}/img"
                    }
                ]
        #监控文件变化，实时进行编译
        watch:
            options:
                spawn: false
                interrupt: true
            app_js:
                files: ["src/js/app/**/*.js"]
                tasks: ['uglify:app','jshint','requirejs']  
            app_css:
                files: ["src/css/app/**/*.less"]
                tasks: ['less:app','csslint:app','csscomb:app','cssmin:app','concat:appIndexCss']
            image:
                files: ["src/img/**/*.{png,jpg,gif}"]
                tasks: ['imagemin']
    # Load the plugin that provides the "uglify" task.
    grunt.loadNpmTasks('grunt-contrib-clean')
    grunt.loadNpmTasks('grunt-contrib-copy')
    grunt.loadNpmTasks('grunt-contrib-concat')
    grunt.loadNpmTasks('grunt-contrib-uglify')
    grunt.loadNpmTasks('grunt-contrib-jshint')
    grunt.loadNpmTasks('grunt-contrib-requirejs')
    grunt.loadNpmTasks('grunt-contrib-less')
    grunt.loadNpmTasks('grunt-contrib-csslint')
    grunt.loadNpmTasks('grunt-csscomb')
    grunt.loadNpmTasks('grunt-contrib-cssmin')
    grunt.loadNpmTasks('grunt-contrib-imagemin')
    grunt.loadNpmTasks('grunt-contrib-watch')
    
    # Default task(s).
    grunt.registerTask('default', ['clean', 'copy', 'uglify', 'jshint', 'requirejs', 'less', 'csslint', 'csscomb', 'cssmin','concat', 'imagemin'])