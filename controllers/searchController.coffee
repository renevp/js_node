express = require 'express'
_ = require 'lodash'
moment = require 'moment'

routes = (searchModel) ->
  router = express.Router()

  isInvalid = (req) ->
    req.checkQuery('q', 'Invalid query').notEmpty()
    errors = req.validationErrors()
    return errors

  router.get('/', (req, res) ->
    res.render('index')
  )

  router.get('/airlines', (req, res) ->
    searchModel.getAirlines()
      .then (airlines) ->
        res.type('json')
        res.send(airlines)
      .catch (e) ->
        res.status(500).send(e)
    )

  router.get('/airports', (req, res) ->
    if isInvalid(req)
      res.status(400)
      res.send('Invalid query')
    query = req.query.q
    searchModel.getAirports(query)
      .then (airports) ->
        res.type('json')
        res.send(airports)
      .catch (e) ->
        res.status(500).send(e)
  )

  # Method used for the client autocomplete
  router.get('/locations', (req, res) ->
    if isInvalid(req)
      res.status(400)
      res.send('Invalid query')
    query = req.query.q
    searchModel.getAirports(query)
      .then (airports) ->
        airportsJoined = []
        airportsObj = JSON.parse(airports)
        airportsObj.forEach (airport) ->
          airportsJoined.push airport.cityName + ", " +
            airport.countryName + " - " +
            airport.airportName + " (" +
            airport.airportCode + ")"
        res.type('json')
        res.send(airportsJoined)
      .catch (e) ->
        console.log e
        res.status(500).send(e)
  )

  router.get('/search', (req, res) ->
    req.checkQuery('date', 'Invalid query').notEmpty()
    req.checkQuery('from', 'Invalid query').notEmpty()
    req.checkQuery('to', 'Invalid query').notEmpty()
    errors = req.validationErrors();
    if errors
      res.status(400)
      res.send('Invalid query')
      return

    if moment(req.query.date).isBefore(moment().subtract(1, 'days'))
      res.status(400)
      res.send("Date can't be past")
      return

    options =
      airlineCode: null
      date: req.query.date
      fromCode: req.query.from
      toCode: req.query.to
    searchModel.searchFlights(options)
      .then (allFlights) ->
        console.log "Finishing..."
        res.type('json')
        res.send(JSON.stringify(allFlights, null, 2))
      .catch (e) ->
        res.status(500).send(e)
  )

  router

module.exports = routes
