require! fs
require! async
option 'testFile' 'File in (/lib or /test) to run test on' 'FILE'
option 'currentfile' 'Latest file that triggered the save' 'FILE'

externalScripts =
    \http://service.ihned.cz/js/d3/v3.3.2.min.js
    \http://service.ihned.cz/js/tooltip/v1.1.4.d3.min.js
    ...

externalStyles =
    \http://service.ihned.cz/js/tooltip/v1.1.4.css
    ...

externalData =
    style: "#__dirname/www/screen.css"

preferScripts = <[ postInit.js _loadData.js ../data.js init.js _loadExternal.js]>
deferScripts = <[ base.js ]>
develOnlyScripts = <[ _loadData.js _loadExternal.js]>
gzippable = <[ ]>
build-styles = (options = {}, cb) ->
    (err, [external, local]) <~ async.parallel do
        *   (cb) -> fs.readFile "#__dirname/www/external.css", cb
            (cb) -> prepare-stylus \screen, options, cb
    <~ fs.writeFile "#__dirname/www/screen.css", external + "\n\n\n" + local
    cb?!

prepare-stylus = (file, options, cb) ->
    console.log "Building Stylus"
    require! stylus
    (err, data) <~ fs.readFile "#__dirname/www/styl/#file.styl"
    data .= toString!
    stylusCompiler = stylus data
        ..include "#__dirname/www/styl/"
        ..define \iurl stylus.url paths: ["#__dirname/www/img/"]
    if options.compression
        stylusCompiler.set \compress true
    (err, css) <~ stylusCompiler.render
    throw err if err
    console.log "Stylus built"
    cb null css

build-script = (file, cb) ->
    require! child_process.exec
    (err, result) <~ exec "lsc -o #__dirname/www/js -c #__dirname/#file"
    throw err if err
    cb?!

build-all-scripts = (cb) ->
    console.log "Building scripts..."
    require! child_process.exec
    (err, result) <~ exec "lsc -o #__dirname/www/js -c #__dirname/www/ls"
    throw err if err
    console.log "Scripts built"
    cb?!

download-external-scripts = (cb) ->
    console.log "Dowloading scripts..."
    require! request
    (err, responses) <~ async.map externalScripts, request~get
    bodies = responses.map (.body)
    <~ fs.writeFile "#__dirname/www/external.js" bodies.join "\n;\n"
    console.log "Scripts loaded"
    cb?!

download-external-data = (cb) ->
    console.log "Combining data..."
    files = for key, datafile of externalData => {key, datafile}
    return cb! unless files.length
    out = {}
    (err) <~ async.each files, ({key, datafile}:file, cb) ->
        (err, data) <~ fs.readFile datafile
        return cb that if err
        data .= toString!
        if \json is datafile.substr -4, 4
            data = JSON.parse data
        out[key] = data
        cb!
    <~ fs.writeFile "#__dirname/www/data.js", "window.ig.data = #{JSON.stringify out};"
    console.log "Data combined"
    cb?!

download-external-styles = (cb) ->
    console.log "Downloading styles..."
    require! request
    (err, responses) <~ async.map externalStyles, request~get
    contents = responses.map (.body)
    <~ fs.writeFile "#__dirname/www/external.css" contents.join "\n\n"
    console.log "Styles loaded"
    cb!

combine-scripts = (options = {}, cb) ->
    console.log "Combining scripts..."
    require! uglify: "uglify-js"
    (err, files) <~ fs.readdir "#__dirname/www/js"
    files .= filter -> it isnt 'script.js.map'
    if options.compression
        files .= filter -> it not in develOnlyScripts
        files.push "../data.js"
    files .= sort (a, b) ->
        indexA = deferScripts.indexOf a
        indexB = deferScripts.indexOf b
        if indexA == -1 and -1 != preferScripts.indexOf a
            indexA = -2 + -1 * preferScripts.indexOf a
        if indexB == -1 and -1 != preferScripts.indexOf b
            indexB = -2 + -1 * preferScripts.indexOf b

        indexA - indexB
    files .= map -> "./www/js/#it"
    minifyOptions = {}
    if not options.compression
        minifyOptions
            ..compress     = no
            ..mangle       = no
            ..outSourceMap = "../js/script.js.map"
            ..sourceRoot   = "../../"
    result = uglify.minify files, minifyOptions

    {map, code} = result
    if not options.compression
        code += "\n//@ sourceMappingURL=./js/script.js.map"
        fs.writeFile "#__dirname/www/js/script.js.map", map
    else
        external = fs.readFileSync "#__dirname/www/external.js"
        code = external + code

    fs.writeFileSync "#__dirname/www/script.js", code
    console.log "Scripts combined"
    cb? err

run-script = (file) ->
    require! child_process.exec
    (err, stdout, stderr) <~ exec "lsc #__dirname/#file"
    throw err if err
    console.error stderr if stderr
    console.log stdout

test-script = (file) ->
    require! child_process.exec
    [srcOrTest, ...fileAddress] = file.split /[\\\/]/
    fileAddress .= join '/'
    <~ build-all-server-scripts
    cmd = "mocha --compilers ls:livescript -R tap --bail #__dirname/test/#fileAddress"
    (err, stdout, stderr) <~ exec cmd
    niceTestOutput stdout, stderr, cmd

build-all-server-scripts = (cb) ->
    require! child_process.exec
    (err, stdout, stderr) <~ exec "lsc -o #__dirname/lib -c #__dirname/src"
    throw stderr if stderr
    cb? err

relativizeFilename = (file) ->
    file .= replace __dirname, ''
    file .= replace do
        new RegExp \\\\, \g
        '/'
    file .= substr 1

gzip-files = (cb) ->
    (err) <~ async.map gzippable, gzip-file
    cb err

gzip-file = (file, cb) ->
    require! zlib
    gzip = zlib.createGzip!
    address        = "#__dirname/www/#file"
    gzippedAddress = "#__dirname/www/#file.gz"
    input  = fs.createReadStream address
    output = fs.createWriteStream gzippedAddress
    input.pipe gzip .pipe output
    cb!

refresh-manifest = (cb) ->
    (err, file) <~ fs.readFile "#__dirname/www/manifest.template.appcache"
    return if err
    file .= toString!
    file += '\n# ' + new Date!toUTCString!
    <~ fs.writeFile "#__dirname/www/manifest.appcache", file
    cb?!

task \build ->
    download-external-scripts!
    <~ download-external-styles
    # build-styles compression: no
    <~ build-all-scripts
    combine-scripts compression: no

task \deploy ->
    <~ async.parallel do
        *   download-external-scripts
            download-external-data
            download-external-styles
            # build-all-server-scripts!
            # refresh-manifest!
    build-styles compression: yes
    <~ build-all-scripts
    <~ combine-scripts compression: yes
    <~ gzip-files!

task \build-styles ->
    t0 = Date.now!
    <~ build-styles compression: no
    <~ download-external-data!

task \build-script ({currentfile}) ->
    file = relativizeFilename currentfile
    isServer = \src/ == file.substr 0, 4
    isScript = \srv/ == file.substr 0, 4
    isTest = \test/ == file.substr 0, 5
    if isServer or isTest
        test-script file
    else if isScript
        run-script file
    else
        <~ build-script file
        combine-scripts compression: no

niceTestOutput = (test, stderr, cmd) ->
    lines         = test.split "\n"
    oks           = 0
    fails         = 0
    out           = []
    shortOut      = []
    disabledTests = []
    for line in lines
        if 'ok' == line.substr 0, 2
            ++oks
        else if 'not' == line.substr 0,3
            ++fails
            out.push line
            shortOut.push line.match(/not ok [0-9]+ (.*)$/)[1]
        else if 'Disabled' == line.substr 0 8
            disabledTests.push line
        else if line and ('#' != line.substr 0, 1) and ('1..' != line.substr 0, 3)
            console.log line# if ('   ' != line.substr 0, 3)
    if oks && !fails
        console.log "Tests OK (#{oks})"
        disabledTests.forEach -> console.log it
    else
        #console.log "!!!!!!!!!!!!!!!!!!!!!!!    #{fails}    !!!!!!!!!!!!!!!!!!!!!!!"
        if out.length
            console.log shortOut.join ", "#line for line in shortOut
        else
            console.log "Tests did not run (error in testfile?)"
            console.log test
            console.log stderr
            console.log cmd
