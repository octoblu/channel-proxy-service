OctobluChannelProxyController = require './controllers/octoblu-channel-proxy-controller'

class Router
  constructor: ({@octobluChannelProxyService}) ->
  route: (app) =>
    octobluChannelProxyController = new OctobluChannelProxyController {@octobluChannelProxyService}

    app.get '/hello', octobluChannelProxyController.hello
    # e.g. app.put '/resource/:id', someController.update

module.exports = Router
