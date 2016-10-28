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

  getAirlines = Promise.promisify(getAirlines)
  getAirlineCodes = Promise.promisify(getAirlineCodes)
  searchFlights = Promise.promisify(searchFlights)

  searchAll = (options) ->
    getAirlineCodes().then (codes) ->
      return codes
    .then (codes) ->
      codes.forEach (code) ->
        options.airlineCode = code
        searchFlights(options).then (results) ->
          console.log  results

  getCodes = () ->
    return getAirlineCodes()
      .then (codes) ->
        return codes

  router.use '/search/:airline_code', (req, res, next) ->
    options =
      airlineCode: req.params.airline_code
      date: req.query.date
      fromCode: req.query.from
      toCode: req.query.to

    getCodes()
      .then (codes) ->
        console.log typeof codes
        console.log("Final result " + codes)
        return codes
      .each (code) ->
        console.log code
        return options.airlineCode = code
      .then (options) ->
        console.log 'Bla'
        console.log options
      .error (e)-> console.log("Error handler " + e)
      .catch (e) -> console.log("Catch handler " + e)

    # getCodes()
    #   .then (finalResult) ->
    #     console.log typeof finalResult
    #     console.log("Final result " + finalResult)
    #     res.send(finalResult)
    #   .error (e)-> console.log("Error handler " + e)
    #   .catch (e) -> console.log("Catch handler " + e)

    # getAirlines((error, body) ->
    #   if error
    #     res.status(500).sendStatus(error)
    #   else
    #     console.log typeof body
    #     codes = _.map(body, 'code')
    #     console.log codes
    #
    #
    #     searchFlights(options, (error, body) ->
    #       if error
    #         res.status(500).send(error)
    #       else if body
    #         res.type('json')
    #         res.send(JSON.parse(body))
    #       else
    #         res.status(404).send('No flights availables')
    #     )
    #)

  router

module.exports = routes
