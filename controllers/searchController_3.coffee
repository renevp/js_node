express = require 'express'
_ = require 'lodash'
Promise = require 'bluebird'

routes = (flightAPI) ->
  router = express.Router()

  getAirlines = (callback) ->
    flightAPI.getAirlines('/airlines', (error, body) ->
      if error
        callback(error)
      else
        callback(null, JSON.parse(body))
    )

  getAirlineCodes = (callback) ->
    flightAPI.getAirlines('/airlines', (error, body) ->
      if error
        callback(error)
      else
        codes = _.map(JSON.parse(body), 'code')
        callback(null, codes)
    )

  searchFlights = (options, callback) ->
    flightAPI.searchFlights('/flight_search', options, (error, body) ->
      if error
        callback(error)
      else
        callback(null, body)
    )

  router.use '/airlines', (req, res, next) ->
    getAirlines((error, body) ->
      if error
        res.status(500).send(error)
      else if body
        res.type('json')
        res.send(body)
      else
        res.status(404).send('No airlines found')
    )

  router.use '/airports', (req, res, next) ->
    query = req.query.q
    flightAPI.getAirports('/airports', query, (error, body) ->
      if error
        res.status(500).send(err)
      else if body
        res.type('json')
        res.send(JSON.parse(body))
      else
        res.status(404).send('No airports found')
    )

  getAirlineCodes = Promise.promisify(getAirlineCodes)
  searchFlights = Promise.promisify(searchFlights)

  getAllFlights = (limit, codes, options, index) ->
    allFlights = []
    getFlights = (limit, codes, options, index) ->
      options.airlineCode = codes[index]
      console.log "getFlights"
      console.log options
      return searchFlights(options)
        .then (flights) ->
          allFlights.push JSON.parse(flights)
          if allFlights.length == limit
            return allFlights
          else
            return getFlights(limit, codes, options, index + 1)
        .catch (e) ->
          console.log e.stack
    return getFlights(limit, codes, options, index)

  getCodes = () ->
    return getAirlineCodes()
      .then (codes) ->
        return codes

  router.use '/search', (req, res, next) ->
    options =
      airlineCode: null
      date: req.query.date
      fromCode: req.query.from
      toCode: req.query.to
    getCodes()
      .then (codes) ->
        console.log("Codes: " + codes)
        return getAllFlights(codes.length, codes, options, 0)
      .then (allFlights) ->
        console.log "Finishing..."
        res.type('json')
        res.send(allFlights)
      .error (e)-> console.log("Error handler " + e)
      .catch (e) -> console.log("Catch handler " + e)

  router

module.exports = routes
