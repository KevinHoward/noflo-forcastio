noflo = require 'noflo'
request = require("request")
util = require("util")
_ = require("lodash")

class GetConditions extends noflo.AsyncComponent
  constructor: ->
    @apikey = null
    @latitude = null
    @longitude = null
    @options = null
    @timestamp = null

    @inPorts =
      apikey: new noflo.Port
      latitude: new noflo.Port
      longitude: new noflo.Port
      timestamp: new noflo.Port
      options: new noflo.Port

    @outPorts =
      out: new noflo.Port
      calls: new noflo.Port
      error: new noflo.Port

    @inPorts.apikey.on 'data', (data) =>
      @apikey = data
   
    @inPorts.latitude.on 'data', (data) =>
      @latitude = data
      
    @inPorts.longitude.on 'data', (data) =>
      @longitude = data

    @inPorts.timestamp.on 'data', (data) =>
      @timestamp = data

    @inPorts.options.on 'data', (data) =>
      @options = if (typeof data is "string") then JSON.parse(data) else data

    super()
    
  doAsync: (data, callback) ->
    # Validate required inputs
    unless @apikey
      return callback new Error "Missing Forecast.IO APIKey"

    unless @latitude
      return callback new Error "Missing Latitude"

    unless @longitude
      return callback new Error "Missing Longitude"

    # Declare URL
    url = "https://api.forecast.io/forecast/"
    url += @apikey + "/" + @latitude + "," + @longitude
    
    # Append Timestamp if provided
    url += "," + @timestamp if @timestamp
    
    # Request conditions from Forecast.IO
    request.get
      uri: url
      qs: @options
      timeout: @options.timeout ? 2500
      , (err, res, data) ->
        return callback err if err
        try
          # Return the number of daily calls made
          @outPorts.calls.send res.headers["X-Forecast-API-Calls"]
          @outPorts.calls.disconnect()

          # Return the data from request
          @outPorts.out.send data
          @outPorts.out.disconnect()
          callback()
        catch e
          return callback e
      
exports.getComponent = -> new GetConditions
