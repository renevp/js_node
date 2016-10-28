_ = require 'lodash'
fe = require 'functional-extract'
Promise = require 'bluebird'
dates = require '../helpers/dates'

searchModel = (flightAPI) ->

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
        callback(null, JSON.parse(body))
    )

  getAirports = (query, callback) ->
    flightAPI.getAirports('/airports', query, (error, body) ->
      if error
        callback(error)
      else
        callback(null, JSON.parse(body))
    )

  getAirlineCodes = Promise.promisify(getAirlineCodes)
  searchFlights = Promise.promisify(searchFlights)

  #Method to use together functional-extract that allows to manage a schema
  _get = (path) ->
    return (obj) ->
      return _.get(obj, path)

  schema =
    key: _get('key')
    airlineName: _get('airline.name')
    duration: _get('durationMin')
    price: _get('price')
    # startDatetime: _get('start.dateTime')
    # startTimezone: _get('start.timeZone')
    # startAirportName: _get('start.airportName')
    # startCityName: _get('start.cityName')
    # startCountryName: _get('start.countryName')
    # finishDatetime: _get('finish.dateTime')
    # finishTimezone: _get('finish.timeZone')
    # finishAirportName: _get('finish.airportName')
    # finishCityName: _get('finish.cityName')
    # finishCountryName: _get('finish.countryName')

  getAllFlightsOneDate = (limit, codes, options, index) ->
    allFlights = []
    getFlights = (limit, codes, options, index) ->
      options.airlineCode = codes[index]
      console.log options
      return searchFlights(options)
        .then (flights) ->
          flights.forEach (flight) ->
            flightPicked = fe(schema, flight)
            allFlights.push flightPicked
          if index == limit - 1
            return allFlights
          else
            return getFlights(limit, codes, options, index + 1)
        .catch (e) ->
          console.log e.stack
    return getFlights(limit, codes, options, index)

  getAllAirlineFlightsOneDate = (options) ->
    return getAirlineCodes()
      .then (codes) ->
        return getAllFlightsOneDate(codes.length, codes, options, 0)
      .then (allFlights) ->
        return allFlights
      .catch (e) -> console.log("Catch handler " + e)

  getAllFlightsAllDates = (limit, range, options, index) ->
    allFlightsDates = []
    getFlightsByDate = (limit, range, options, index) ->
      options.date = range[index]
      return getAllAirlineFlightsOneDate(options)
        .then (allFlights) ->
          allFlights.forEach (flight) ->
            allFlightsDates.push flight
          if index == limit - 1
            return allFlightsDates
          else
            return getFlightsByDate(limit, range, options, index + 1)
        .catch (e) ->
          console.log e.stack
    return getFlightsByDate(limit, range, options, index)

  searchFlightsByDates = (options, range) ->
    allFlightsDates = []
    promise = Promise.resolve();
    range.forEach (date) ->
      console.log date
      options.date = date
      promise = promise.then () ->
        return getAllAirlineFlights(options)
          .then (allFlights) ->
            console.log "searchFlightsByDates..."
            allFlightsDates.push allFlights
            return allFlightsDates
          .catch (e) -> console.log("Catch handler " + e)

    return promise

  RANGE_TYPE = 'days'
  RANGE_NUMBER = 0
  DATE_FORMAT = 'Y-M-DD'

  searchAllFlights = (options) ->
    range = dates.getDates(RANGE_TYPE, RANGE_NUMBER, DATE_FORMAT, options.date)
    console.log range
    # Umm small issue with the dates
    # searchFlightsByDates(options, range)
    #   .then (allFlights) ->
    #     console.log "getAllFlightsByDateRange..."
    #     return allFlights
    #   .error (e)-> console.log("Error handler " + e)
    #   .catch (e) -> console.log("Catch handler " + e)
    

    getAllFlightsAllDates(range.length, range, options, 0)
      .then (allFlights) ->
        return allFlights
      .catch (e) -> console.log("Catch handler " + e)

    # This works
    # getAllAirlineFlights(options)
    #   .then (allFlights) ->
    #     console.log "getAllFlightsByDateRange..."
    #     return allFlights
    #   .error (e)-> console.log("Error handler " + e)
    #   .catch (e) -> console.log("Catch handler " + e)

  getAirlines: getAirlines
  getAirports: getAirports
  searchAllFlights: searchAllFlights

module.exports = searchModel
