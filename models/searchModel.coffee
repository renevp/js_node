_ = require 'lodash'
Promise = require 'bluebird'

searchModel = (flightAPI) ->

  getAirlines = Promise.promisify(flightAPI.getAirlines)
  getAirports = Promise.promisify(flightAPI.getAirports)
  search = Promise.promisify(flightAPI.searchFlights)

  getFlightsOneDate = (limit, codes, options, index) ->
    allFlights = []
    getFlights = (limit, codes, options, index) ->
      options.airlineCode = codes[index]
      console.log options
      return search(options)
        .then (flights) ->
          flights.forEach (flight) ->
            allFlights.push flight
          if index == limit - 1
            return allFlights
          else
            return getFlights(limit, codes, options, index + 1)
        .catch (e) ->
          console.log e
          throw new Error("The request can't be processed")
    return getFlights(limit, codes, options, index)

  searchFlights = (options) ->
    return getAirlines()
      .then (airlines) ->
        codes = _.map(JSON.parse(airlines), 'code')
        return getFlightsOneDate(codes.length, codes, options, 0)
      .then (allFlights) ->
        return allFlights
      .catch (e) ->
        console.log e
        throw e

  getAirlines: getAirlines
  getAirports: getAirports
  searchFlights: searchFlights

module.exports = searchModel
