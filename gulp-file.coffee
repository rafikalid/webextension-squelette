gulp			= require 'gulp'
gutil			= require 'gulp-util'
# minify		= require 'gulp-minify'
include			= require "gulp-include"
sass 			= require 'gulp-sass'
rename			= require "gulp-rename"
coffeescript	= require 'gulp-coffeescript'
PluginError		= gulp.PluginError
cliTable		= require 'cli-table'
template		= require 'gulp-template'
pug				= require 'gulp-pug'
through 		= require 'through2'
path			= require 'path'

# check arguments
SUPPORTED_NAVS = ['chrome', 'firefox', 'opera', 'edge']
settings = gutil.env
throw new Error '"--nav=**" argument is required' unless settings.nav
throw new Error "Unsupported navigator: #{settings.nav}, supported are #{SUPPORTED_NAVS.join ','}." unless settings.nav in SUPPORTED_NAVS

# compile js (background, popup, ...)
compileJSGen = (folder)->
	->
		gulp.src "assets/#{folder}/**/[!_]*.coffee", nodir: true
			.pipe include hardFail: true
			.pipe template settings
			.pipe coffeescript(bare: true).on 'error', errorHandler
			.pipe gulp.dest "build/#{folder}/"
			.on 'error', errorHandler

compileJS = -> do compileJSGen 'js'
compileBackground = -> do compileJSGen 'background'
compilePopup = -> do compileJSGen 'popup'

# compile sass
compileSass = ->
	gulp.src "assets/css/**/[!_]*.sass", nodir: true
		# .pipe template settings
		.pipe include({hardFail: true}) 
		.pipe sass({outputStyle: 'compressed'}) 
		.pipe sass().on 'error', sass.logError
		.pipe gulp.dest "build/css/"
		.on 'error', errorHandler

# compile manifest
compileManifest = ->
	gulp.src 'assets/manifest/manifest.coffee' #, nodir: true
		.pipe include hardFail: true
		.pipe template settings
		.pipe coffeescript(bare: true).on 'error', errorHandler
		.pipe through.obj (file, enc, cb)->
			# ignore null file and stream
			return cb null, file if file.isNull() or file.isStream()
			# process
			err = null
			try
				data = file.contents.toString 'utf8'
				data = eval data
				file.contents = new Buffer JSON.stringify data
			catch e
				err = new gutil.PluginError 'toJSON', e
			cb err, file
		.pipe rename 'manifest.json'
		.pipe gulp.dest 'build'
		.on 'error', errorHandler

# compile locals
compileLocals = ->
	gulp.src 'assets/_locales/index.coffee' #, nodir: true
		.pipe include hardFail: true
		.pipe template settings
		.pipe coffeescript(bare: true).on 'error', errorHandler
		.pipe through.obj (file, enc, cb)->
			# ignore null file and stream
			return cb null, file if file.isNull() or file.isStream()
			# process
			err = null
			try
				data = file.contents.toString 'utf8'
				data = eval data
				# reorganize code
				# @return
				# {
				# 	fr: {
				# 		key: {message: ''}
				# 	}
				# }
				data = _i18nNormalize data
				# split into files
				for k,v of data
					fle = new gutil.File
						base: k
						cwd : __dirname
						path: path.join __dirname, '_locales', k, 'messages.json'
					fle.contents = new Buffer JSON.stringify v
					@push fle
			catch e
				err = new gutil.PluginError 'i18n spliter', e
			cb err
		.pipe gulp.dest 'build/_locales/'
		.on 'error', errorHandler

# compile pug files
compilePug = ->
	gulp.src 'assets/**/[!_]*.pug', nodir: true
		.pipe template settings
		.pipe pug data:{}
		.pipe gulp.dest 'build/'
		.on 'error', errorHandler

# copy lib files
copyLibs = ->
	gulp.src 'assets/lib/**/*'
		.pipe gulp.dest 'build/lib/'

# copy images
copyImages = ->
	gulp.src "assets/images/**/*"
		.pipe gulp.dest('build/images/')

# compile
watch = ->
	gulp.watch 'assets/manifest/*.coffee', compileManifest
	gulp.watch 'assets/_locales/*.coffee', compileLocals
	gulp.watch 'assets/**/*.pug', compilePug
	gulp.watch 'assets/lib/**/*', copyLibs
	gulp.watch 'assets/css/**/*.sass', compileSass
	gulp.watch 'assets/images/**/*', copyImages

	gulp.watch 'assets/js/**/*.coffee', compileJS
	gulp.watch 'assets/background/**/*.coffee', compileBackground
	gulp.watch 'assets/popup/**/*.coffee', compilePopup
	return

# default task
parallelTasks = [
	compileManifest
	compileLocals
	compilePug
	copyLibs
	compileSass
	copyImages
	
	compileJS
	compileBackground
	compilePopup
]

# create default task
gulp.task 'default', gulp.series (gulp.parallel parallelTasks), watch

# compile final values (consts to be remplaced at compile time)
# handlers
# compileCoffee = ->
# 	gulp.src 'assets/**/[!_]*.coffee', nodir: true
# 	# include related files
# 	.pipe include hardFail: true
# 	# convert to js
# 	.pipe coffeescript(bare: true).on 'error', errorHandler
# 	# save 
# 	.pipe gulp.dest 'build'
# 	.on 'error', errorHandler
# # watch files
# watch = ->
# 	gulp.watch ['assets/**/*.coffee'], compileCoffee
# 	return

# error handler
errorHandler= (err)->
	# get error line
	expr = /:(\d+):(\d+):/.exec err.stack
	if expr
		line = parseInt expr[1]
		col = parseInt expr[2]
		code = err.code?.split("\n")[line-3 ... line + 3].join("\n")
	else
		code = line = col = '??'
	# Render
	table = new cliTable()
	table.push {Name: err.name},
		{Filename: err.filename},
		{Message: err.message},
		{Line: line},
		{Col: col}
	console.error table.toString()
	console.log '\x1b[31mStack:'
	console.error '\x1b[0m┌─────────────────────────────────────────────────────────────────────────────────────────┐'
	console.error '\x1b[34m', err.stack
	console.log '\x1b[0m└─────────────────────────────────────────────────────────────────────────────────────────┘'
	console.log '\x1b[31mCode:'
	console.error '\x1b[0m┌─────────────────────────────────────────────────────────────────────────────────────────┐'
	console.error '\x1b[34m', code
	console.log '\x1b[0m└─────────────────────────────────────────────────────────────────────────────────────────┘'
	return

# process arguments
# console.log '---process.args: ', process.argv
# for arg in process.args
# 	console.log('---- arg: ', arg)


###*
 * Normalize i18n
 * {
 * 	key:
 * 		lang: value
 * }
###
_i18nNormalize = (data)->
	# check for used locals
	locals = null
	firstKey = null
	for k, v of data
		if v and typeof v is 'object'
			# check local name
			for k2,v2 of v
				unless /^[a-z]{2}(?:_[A-Z]{2})?$/.test k2
					throw new Error "Illegal local #{k2}, supported format are: [a-z]{2} or [a-z]{2}_[A-Z]{2}, Example: en, en_US"
			# if not first
			if locals
				# check all locals are there
				locals2 = Object.keys v
				unless locals2.length is locals.length
					for l in locals2
						throw new Error "local #{l} required at #{firstKey}" unless l in locals
					for l in locals
						throw new Error "local #{l} required at #{k}" unless l in locals2
			else
				firstKey = k
				locals = Object.keys v
	# Normalize
	result = Object.create null
	# create each lang obj
	for k in locals
		result[k] = Object.create null
	# split
	for k,v of data
		# static name
		if typeof v is 'string'
			result[k2][k] = message: v for k2 in locals
		else
			for k2 in locals
				v2 = v[k2]
				if typeof v2 is 'string'
					result[k2][k] = message: v2
				else
					result[k2][k] = v2
	# result
	result