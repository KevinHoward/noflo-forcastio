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

    @url = "https://api.forecast.io/forecast/"

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
      @options = data

    super()
    
  checkRequired: (data, callback) ->
    unless @apikey
      return callback new Error "Missing Forecast.IO APIKey"
    unless @latitude
      return callback new Error "Missing Latitude"
    unless @longitude
      return callback new Error "Missing Longitude"
    do callback

  doAsync: (data, callback) ->
    # Validate inputs
    @checkRequired data, (err) =>
      return callback err if err
      
    # Set timeout
    requestTimeout = @options.timeout or 2500
      
    # Declare URL
    url = @url + @options.APIKey + "/" + @latitude + "," + @longitude
    
    url = url + "," + @timestamp if @timestamp
    
    # Request conditions from Forecast.IO
    request.get
        uri: url
        qs: @options
        timeout: requestTimeout
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
