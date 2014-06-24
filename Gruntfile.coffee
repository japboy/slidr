'use strict'

# Load required Node.js modules
fs = require 'fs'
path = require 'path'


#
# Grunt main configuration
# ------------------------
module.exports = (grunt) ->

  #
  # Initial configuration object for Grunt
  # passed to `grunt.initConfig()`
  #
  conf =

    # Setup basic paths and read them by `<%= path.PROP %>`
    path:
      source: 'src'
      publish: 'dist'
      document: 'docs'

    #
    # Task to browserify JavaScript codes
    #
    # * [grunt-browserify](https://github.com/jmreidy/grunt-browserify)
    #
    browserify:
      options:
        transform: [
          'coffeeify'
          'debowerify'
        ]
      source:
        src: '<%= path.source %>/js/main.js'
        dest: '<%= path.publish %>/js/app.js'

    #
    # Task to remove files & directories
    #
    # * [grunt-contrib-clean](https://github.com/gruntjs/grunt-contrib-clean)
    #
    clean:
      options:
        force: true
      publish:
        src: '<%= path.publish %>'

    #
    # Task to lint CoffeeScript
    #
    # * [grunt-coffeelint](https://github.com/vojtajina/grunt-coffeelint)
    # * [CoffeeLint options](http://www.coffeelint.org/#options)
    #
    coffeelint:
      options: JSON.parse fs.readFileSync('.coffeelintrc')
      source:
        expand: true
        cwd: '<%= path.source %>'
        src: [
          '**/*.coffee'
          '**/*.litcoffee'
          '!**/vendor/**/*'
        ]
        filter: 'isFile'

    #
    # Task to concatenate files into one
    #
    # * [grunt-contrib-concat](https://github.com/gruntjs/grunt-contrib-concat)
    #
    concat:
      style:
        options:
          separator: grunt.util.linefeed
        src: [
          './bower_components/normalize-css/normalize.css'
        ]
        dest: '<%= path.publish %>/css/preset.css'
      script:
        options:
          separator: ';'
        src: [
          './bower_components/modernizr/modernizr.js'
        ]
        dest: '<%= path.publish %>/js/preset.js'

    #
    # Task to launch Connect static web server
    #
    # * [grunt-contrib-connect](https://github.com/gruntjs/grunt-contrib-connect)
    #
    connect:
      publish:
        options:
          port: 9000
          protocol: 'http'
          hostname: '*'
          base: '<%= path.publish %>'
          livereload: true

    #
    # Task to copy files
    #
    # * [grunt-contrib-copy](https://github.com/gruntjs/grunt-contrib-copy)
    #
    copy:
      source:
        expand: true
        cwd: '<%= path.source %>'
        src: [
          '**/*'
          '!**/*.coffee'
          '!**/*.hbp'
          '!**/*.hbs'
          '!**/*.hbt'
          '!**/*.jade'
          '!**/*.js'
          '!**/*.jst'
          '!**/*.less'
          '!**/*.litcoffee'
          '!**/*.sass'
          '!**/*.scss'
          '!**/*.styl'
          '!meta.json'
          '!img/sprites/**/*'
        ]
        dest: '<%= path.publish %>'

    #
    # Task to optimise CSS by CSSO
    #
    # * [grunt-csso](https://github.com/t32k/grunt-csso)
    #
    csso:
      options:
        restructure: true
      publish:
        expand: true
        cwd: '<%= path.publish %>'
        src: [
           '**/*.css'
           '!**/*.min.css'
           '!**/*-min.css'
        ]
        filter: 'isFile'
        dest: '<%= path.publish %>'
        ext: '.min.css'

    #
    # Task to generate JavaScript/CoffeeScript documentation by Docco
    #
    # * [grunt-docco](https://github.com/DavidSouther/grunt-docco)
    #
    docco:
      options:
        output: '<%= path.document %>/docco/'
      source:
        expand: true
        cwd: '<%= path.source %>'
        src: [
          '**/*.coffee'
          '**/*.licoffee'
          '**/*.js'
        ]
        filter: 'isFile'
      gruntfile:
        src: 'Gruntfile.coffee'

    #
    # Task to compile Jade
    #
    # * [grunt-contrib-jade](https://github.com/gruntjs/grunt-contrib-jade)
    #
    jade:
      options:
        pretty: true
        data: ->
          json = path.join '.', 'src', 'meta.json'
          return grunt.file.readJSON json
      source:
        expand: true
        cwd: '<%= path.source %>'
        src: '**/!(_)*.jade'
        filter: 'isFile'
        dest: '<%= path.publish %>'
        ext: '.html'

    #
    # Task to lint JavaScript by JSHint
    #
    # * [grunt-contrib-jshint](https://github.com/gruntjs/grunt-contrib-jshint)
    #
    jshint:
      options:
        jshintrc: '.jshintrc'
      source:
        expand: true
        cwd: '<%= path.source %>'
        src: [
          '**/*.js'
        ]
        filter: 'isFile'

    #
    # Task to lint JSON
    #
    # * [grunt-jsonlint](https://github.com/brandonramirez/grunt-jsonlint)
    #
    jsonlint:
      source:
        src: [
          '<%= path.source %>/**/*.json'
          'package.json'
        ]

    #
    # Task to compile Markdown
    #
    # * [grunt-markdown](https://github.com/treasonx/grunt-markdown)
    #
    markdown:
      options:
        gfm: true
        highlight: 'auto'
        codeLines:
          before: '<code>'
          after: '</code>'
      source:
        expand: true
        cwd: '<%= path.source %>'
        src: '**/*.md'
        filter: 'isFile'
        dest: '<%= path.publish %>'
        ext: '.html'

    #
    # Task to notify messages
    #
    # * [grunt-notify](https://github.com/dylang/grunt-notify)
    #
    notify:
      build:
        options:
          title: 'Build completed'
          message: 'Successfully finished.'
      watch:
        options:
          title: 'Watch started'
          message: 'Local server launched: http://localhost:8080/'

    #
    # Task to generate sprite image & sheet
    #
    # * [grunt-spritesmith](https://github.com/Ensighten/grunt-spritesmith)
    #
    sprite:
      source:
        src: [
          './src/img/sprites/**/*.png'
        ]
        destImg: './dist/img/sprite.png'
        destCSS: './dist/css/sprite.css'
        algorithm: 'binary-tree'
        padding: 1

    #
    # Task to compile Stylus
    #
    # * [grunt-contrib-stylus](https://github.com/gruntjs/grunt-contrib-stylus)
    #
    stylus:
      options:
        compress: false
        'include css': true
        'resolve url': false
      source:
        expand: true
        cwd: '<%= path.source %>'
        src: '**/!(_)*.styl'
        filter: 'isFile'
        dest: '<%= path.publish %>'
        ext: '.css'

    #
    # Task to optimise JavaScript through UglifyJS
    #
    # * [grunt-contrib-uglify](https://github.com/gruntjs/grunt-contrib-uglify)
    #
    uglify:
      options:
        sourceMap: true
        preserveComments: false
       publish:
         expand: true
         cwd: '<%= path.publish %>'
         src: [
           '**/*.js'
           '!**/*.min.js'
           '!**/*-min.js'
         ]
         filter: 'isFile'
         dest: '<%= path.publish %>'
         ext: '.min.js'

    #
    # Task to observe file changes & fire up related tasks
    #
    # * [grunt-contrib-watch](https://github.com/gruntjs/grunt-contrib-watch)
    #
    watch:
      options:
        livereload: true
      css:
        files: [
          '<%= path.source %>/**/*.styl'
        ]
        tasks: [
          'stylus'
          'concat:style'
          'csso'
        ]
      html:
        files: [
          '<%= path.source %>/**/*.jade'
        ]
        tasks: [
          'jade'
        ]
      image:
        files: '<%= path.source %>/**/img/**/*'
        tasks: [
          'copy'
          'sprite'
          'csso'
        ]
      js:
        files: [
          '<%= path.source %>/**/*.coffee'
          '<%= path.source %>/**/*.js'
          '<%= path.source %>/**/*.json'
          '<%= path.source %>/**/*.litcoffee'
        ]
        tasks: [
          'jsonlint'
          'jshint'
          'coffeelint'
          'concat:script'
          'browserify'
          'uglify'
        ]


  #
  # List of sequential tasks
  # passed to `grunt.registerTask tasks.TASK`
  #
  tasks =
    listen: [
      'notify:watch'
      'connect'
      'watch'
    ]
    default: [
      'clean'
      'jsonlint'      # Validate JavaScript & JSON files
      'jshint'
      'coffeelint'
      'stylus'        # Preprocess CSS files
      'jade'          # Preprocess HTML files
      'concat'        # Concatenate files
      'browserify'
      'sprite'        # Generate CSS sprite images & CSS files
      'copy'          # Copy other files
      'csso'          # Minify files
      'uglify'
      'notify:build'
    ]


  # Load Grunt plugins
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-jshint'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-csso'
  grunt.loadNpmTasks 'grunt-jsonlint'
  grunt.loadNpmTasks 'grunt-notify'
  grunt.loadNpmTasks 'grunt-spritesmith'

  # Load initial configuration being set up above
  grunt.initConfig conf

  # Regist sequential tasks being listed above
  grunt.registerTask 'listen', tasks.listen
  grunt.registerTask 'default', tasks.default
