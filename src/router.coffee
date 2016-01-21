ChannelProxyController = require './controllers/channel-proxy-controller'

class Router
  constructor: ({@channelProxyService}) ->
  route: (app) =>
    channelProxyController = new ChannelProxyController {@channelProxyService}

    app.post '/request', channelProxyController.makeRequest

module.exports = Router
