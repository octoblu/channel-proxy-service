OauthConfig = require '../models/oauth-config'

class ChannelProxyService
  constructor: ({@channelConfig, @usersModel}) ->

  makeRequest: ({userUuid, config}, callback) =>
    @usersModel.get userUuid, (error, userData) =>
      return callback @_createError 500, error.message if error?
      @channelConfig.fetch (error) =>
        return callback @_createError 500, error.message if error?
        oauthConfig = new OauthConfig {@channelConfig}
        oauth = oauthConfig.get userData, config
        callback()

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = ChannelProxyService
