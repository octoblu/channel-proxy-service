class OctobluChannelProxyController
  constructor: ({@octobluChannelProxyService}) ->

  hello: (request, response) =>
    {hasError} = request.query
    @octobluChannelProxyService.doHello {hasError}, (error) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.sendStatus(200)

module.exports = OctobluChannelProxyController
