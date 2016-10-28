express = require 'express'
util = require 'util'
bodyParser = require 'body-parser'
expressValidator = require 'express-validator'

app = express()
app.use(bodyParser.json());
app.use(expressValidator())

app.use(express.static(__dirname + '/public'))

url = process.env.URL || 'http://node.locomote.com/code-task'
flightAPI = require('./flightAPI/wrapper')(url)

searchModel = require('./models/searchModel')(flightAPI)

router = require('./controllers/searchController')(searchModel)
app.use(router);

port = process.env.PORT || 3000
app.listen(port, () ->
  console.log 'Running my app on port ' + port
)
