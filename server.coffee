require('coffee-script').register()
path        = require("path")
url         = require("url")
express     = require("express")
exphbs = require('express-handlebars')
browserify  = require("connect-browserify")
ReactAsync  = require("react-async")
nodejsx     = require("node-cjsx").transform()
App         = require("./client")
stylus = require("stylus")
nib = require("nib")

console.log process.env.NODE_ENV
development = process.env.NODE_ENV isnt "production"



renderApp = (req, res, next) =>
  path = url.parse(req.url).pathname
  app = App(path: path)
  ReactAsync.renderComponentToStringWithAsyncState app, (err, markup) =>
    return next(err) if err
    res.header('Content-Type', 'text/html')
    res.render 'home', {markup: markup}
      



app = express()

app.engine('handlebars', exphbs({ defaultLayout: 'main'}))
app.set('view engine', 'handlebars')


app.use stylus.middleware(
  src: __dirname + "/stylesheets"
  dest: __dirname + "/assets"
  debug: true
  force: true
  compile: (str, path) ->
    stylus(str)
      .set('filename', path)
      .set('compress', true)
      .use(nib())
      .import('nib')
)

if development
  app.get "/assets/bundle.js", browserify("./client.coffee",
    debug: true
    watch: true
    extensions: [".cjsx", ".coffee", ".js", ".json"]
  )


app
  .use("/assets", express.static(path.join(__dirname, "assets")))
  .use(renderApp)
  .listen process.env.PORT || 3000, ->
    console.log "Point your browser at http://localhost:#{process.env.PORT || 3000}"
