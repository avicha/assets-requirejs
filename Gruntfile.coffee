path = require 'path'
fs = require 'fs'
#生产目录
ROOT = "#{__dirname}/static"
module.exports = (grunt)->
    # Project configuration.
    grunt.initConfig
        uglify:
            app:
                files: [
                    expand: true
                    cwd: "#{ROOT}/js/app"
                    src: ["**/*.js"]
                    ext: '.min.js'
                    dest: "#{ROOT}/js/app"
                    extDot: 'last'
                    filter: (src)->
                        ext = path.extname src
                        ('.js' is ext) and (!~src.indexOf '.min.js')
                ]
            lib:
                files: [
                    expand: true
                    cwd: "#{ROOT}/js/lib"
                    src: ["**/*.js"]
                    ext: '.min.js'
                    dest: "#{ROOT}/js/lib"
                    extDot: 'last'
                    filter: (src)->
                        ext = path.extname src
                        dir = path.dirname src
                        name = path.basename src,ext
                        ('.js' is ext) and (!~src.indexOf '.min.js') and !fs.existsSync(path.join dir,"#{name}.min.js")
                ]
    #编译less成css
        less:
        #压缩
            options:
                paths: ["#{ROOT}/css"]
                compress: true
            app:
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
                        dest: "#{ROOT}/css/app"
                    }
                ]
            lib:
                files: [
                    {
                        expand: true
                        cwd: "#{ROOT}/css/lib"
                        src: '**/*.css'
                        ext: '.min.css'
                        dest: "#{ROOT}/css/lib"
                        filter: (src)->
                            ext = path.extname src
                            dir = path.dirname src
                            name = path.basename src,ext
                            ('.css' is ext) and (!~src.indexOf '.min.css') and !fs.existsSync(path.join dir,"#{name}.min.css")
                    }
                ]
        jshint: 
            options:
                ignores: ["#{ROOT}/js/app/**/*.min.js"]
            uses_defaults: ["#{ROOT}/js/app/**/*.js"]
            with_overrides: []
        watch:
            app_js:
                files: ["static/js/app/**/*.js"]
                tasks: ['uglify:app','jshint']
                options:
                    spawn: false
                    interrupt: true
            app_css:
                files: ["static/css/app/**/*.less"]
                tasks: ['less:app']
                options:
                    spawn: false
                    interrupt: true
    # Load the plugin that provides the "uglify" task.
    grunt.loadNpmTasks('grunt-contrib-uglify')
    grunt.loadNpmTasks('grunt-contrib-less')
    grunt.loadNpmTasks('grunt-contrib-watch')
    grunt.loadNpmTasks('grunt-contrib-jshint')
    # Default task(s).
    grunt.registerTask('default', ['uglify', 'less', 'jshint'])