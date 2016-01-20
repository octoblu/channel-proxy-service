class ChannelProxyController
  constructor: ({@channelProxyService}) ->

  makeRequest: (request, response) =>
    {hasError} = request.query
    @channelProxyService.makeRequest {}, (error) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.sendStatus(200)

module.exports = ChannelProxyController
