class ChannelProxyController
  constructor: ({@channelProxyService}) ->

  makeRequest: (request, response) =>
    {userUuid, config} = request.body
    @channelProxyService.makeRequest {userUuid, config}, (error) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.sendStatus(200)

module.exports = ChannelProxyController
