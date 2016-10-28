class Airline
  constructor: (@name) ->

class Schedule
  constructor: (options) ->
    {@datetime,
      @timezone,
      @airportName,
      @cityName,
      @countryName} = options

class Flight
  constructor: (@key) ->
