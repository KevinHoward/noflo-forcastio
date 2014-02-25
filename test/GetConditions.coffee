comp = require "../components/GetConditions"
socket = require('noflo').internalSocket

apikey = "[enter your apikey here]"

setupComponent = ->
  c = comp.getComponent()
  options = socket.createSocket()
  latitude = socket.createSocket()
  longitude = socket.createSocket()
  out = socket.createSocket()
  calls = socket.createSocket()
  err = socket.createSocket()
  c.inPorts.options.attach options
  c.inPorts.latitude.attach latitude
  c.inPorts.longitude.attach longitude
  c.outPorts.out.attach out
  c.outPorts.calls.attach calls
  c.outPorts.error.attach err
  [c, options, latitude, longitude, timestamp, out, calls, err]

exports['test API key check'] = (test) ->
  [c, options, latitude, longitude, timestamp, out, calls, err] = setupComponent()
  err.once 'data', (data) ->
    test.ok data
    test.ok data.message
    test.equals data.message, 'APIKey must be set on Forecast options'

  err.once 'disconnect', ->
    test.done()

  c.send
    latitude: 28.3825201
    longitude: -81.5602336