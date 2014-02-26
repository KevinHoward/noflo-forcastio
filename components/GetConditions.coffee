noflo = require 'noflo'
request = require 'request'

class GetConditions extends noflo.AsyncComponent
  constructor: ->
    @apikey = null
    @ins = null

    @inPorts =
      in: new noflo.Port
      apikey: new noflo.Port

    @outPorts =
      out: new noflo.Port
      calls: new noflo.Port
      error: new noflo.Port
  
    @inPorts.in.on 'data', (data) =>
      @ins = if (typeof data is 'string')
      then JSON.parse(data)
      else data

    @inPorts.apikey.on 'data', (data) =>
      @apikey = data

    super()
    
  doAsync: (data, callback) ->
    # Validate required inputs
    unless @apikey
      return callback new Error "Missing Forecast.IO APIKey"
    
    unless @ins.latitude
      return callback new Error "Missing Latitude"

    unless @ins.longitude
      return callback new Error "Missing Longitude"

    # Declare Forecast.IO web service URL
    url = "https://api.forecast.io/forecast/"
    url += @apikey + "/" + @ins.latitude + "," + @ins.longitude
    delete @ins['latitude']
    delete @ins['longitudeitude']


    # Append Timestamp to url if present
    if @ins.timestamp
      url += "," + @ins.timestamp
      delete @ins['timestamp']

    # Set the request timeout
    if @ins.timeout
      timeout = @ins.timeout
      delete @ins['timeout']
    else
      timeout = 2500
    
    # Request conditions from Forecast.IO
    request.get
      uri: url
      qs: @ins
      timeout: timeout
      , (err, response, data) ->
        return callback err if err
        try
          # Return the number of daily calls made
          @outPorts.calls.send response.headers['X-Forecast-API-Calls']

          # Return the data from request
          @outPorts.out.send data

          # Close out-ports
          @outPorts.calls.disconnect()
          @outPorts.out.disconnect()
          
          callback()
        catch e
          return callback e
      
exports.getComponent = -> new GetConditions
