http = require 'http'
express = require 'express'
assets = require 'connect-assets'

app = express()
app.use express.static __dirname + '/public'
app.use assets()
app.set "views", __dirname + "/views"
app.set "view engine", "jade"

app.get '/', (req, res) ->
  res.render 'index'

app.listen(3000)

console.log 'Server running at http://127.0.0.1:3000/'
