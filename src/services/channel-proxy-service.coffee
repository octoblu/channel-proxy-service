_           = require 'lodash'
request     = require 'request'
OauthConfig = require '../models/oauth-config'
RequestFormatter = require '../models/request-formatter'

class ChannelProxyService
  constructor: ({@channelConfig, @users, @flows}) ->
    @requestFormatter = new RequestFormatter
    @oauthConfig = new OauthConfig {@channelConfig}

  makeRequest: ({flowUuid, config}, callback) =>
    @flows.getUserUuidForFlow flowUuid, (error, userUuid) => 
      return callback @_createError 500, error.message if error?
      @users.get userUuid, (error, userData) =>
        return callback @_createError 500, error.message if error?
        @channelConfig.fetch (error) =>
          return callback @_createError 500, error.message if error?

          oauthConfig = @oauthConfig.get userData, config
          config = _.defaultsDeep {}, config, oauthConfig
          requestOptions = @requestFormatter.format config
          request requestOptions, (error, response, body) =>
            return callback @_createError 500, error.message if error?
            callback null, statusCode: response.statusCode, body: body

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = ChannelProxyService
