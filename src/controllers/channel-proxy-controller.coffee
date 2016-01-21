class ChannelProxyController
  constructor: ({@channelProxyService}) ->

  makeRequest: (request, response) =>
    config = request.body
    flowUuid = request.meshbluAuth.uuid
    @channelProxyService.makeRequest {flowUuid, config}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.statusCode).send result.body

module.exports = ChannelProxyController
