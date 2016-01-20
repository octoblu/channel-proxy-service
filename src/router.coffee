ChannelProxyController = require './controllers/channel-proxy-controller'

class Router
  constructor: ({@channelProxyService}) ->
  route: (app) =>
    channelProxyController = new ChannelProxyController {@channelProxyService}

    app.get '/request', channelProxyController.makeRequest
    # e.g. app.put '/resource/:id', someController.update

module.exports = Router
