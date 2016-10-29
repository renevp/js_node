moment = require 'moment'
require 'moment-range'
c = require './constants'

exports.getDates = (date) ->
  start = moment(date).subtract(c.RANGE_NUMBER, c.RANGE_TYPE)
  end = moment(date).add(c.RANGE_NUMBER, c.RANGE_TYPE)
  range = moment.range(start, end)
  dates = []

  range.by(c.RANGE_TYPE, (moment) ->
    dates.push moment.format(c.DATE_FORMAT)
  )
  dates
