request = require 'request'

flightAPI = (url) ->
  getAirlines = (callback) ->
    request(url + '/airlines', (error, response, body) ->
      if !error and response.statusCode == 200
        callback(null, body)
      else
        callback(error)
    )

  getAirports = (query, callback) ->
    request(url + "/airports?q=" + query, (error, response, body) ->
        if !error and response.statusCode == 200
          callback(null, body)
        else
          callback(error)
    )

  searchFlights = (options, callback) ->
    request(url + "/flight_search/" + options.airlineCode +
      "?date=" + options.date +
      "&from=" + options.fromCode +
      "&to=" + options.toCode, (error, response, body) ->
        if !error and response.statusCode == 200
          callback(null, JSON.parse(body))
        else 
          callback(error)
    )

  getAirlines: getAirlines
  getAirports: getAirports
  searchFlights: searchFlights

module.exports = flightAPI
