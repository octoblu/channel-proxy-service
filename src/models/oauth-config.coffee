_  = require 'lodash'
textCrypt = require './text-crypt'

class OauthConfig
  constructor: ({@channelConfig}) ->

  get: (userData, template) =>
    userApiMatch = _.findWhere(userData.api, type: template.type)
    return {} unless userApiMatch?

    channelApiMatch = @channelConfig.get template.type
    return {} unless channelApiMatch?

    channelConfig = _.pick channelApiMatch,
      'bodyFormat'
      'followAllRedirects'
      'skipVerifySSL'
      'hiddenParams'
      'auth_header_key'
      'bodyParams'

    config = _.defaults {}, template, channelConfig

    if userApiMatch.token_crypt
      userApiMatch.token  = textCrypt.decrypt userApiMatch.token_crypt
    if userApiMatch.secret_crypt
      userApiMatch.secret = textCrypt.decrypt userApiMatch.secret_crypt
    if userApiMatch.refreshToken_crypt
      userApiMatch.refreshToken = textCrypt.decrypt userApiMatch.refreshToken_crypt

    config.apikey = userApiMatch.apikey

    userToken = userApiMatch.token ? userApiMatch.key

    userOAuth =
      access_token: userToken
      access_token_secret: userApiMatch.secret
      refreshToken: userApiMatch.refreshToken
      expiresOn: userApiMatch.expiresOn
      defaultParams: userApiMatch.defaultParams

    config.defaultParams = userApiMatch.defaultParams

    channelOauth =  channelApiMatch.oauth?[process.env.NODE_ENV]
    channelOauth ?= channelApiMatch.oauth
    channelOauth ?= {tokenMethod: channelApiMatch.auth_strategy}

    config.oauth = _.defaults {}, userOAuth, template.oauth, channelOauth

    if channelApiMatch.overrides
      config.headerParams = _.extend {}, template.headerParams, channelApiMatch.overrides.headerParams

    config.oauth.key ?= config.oauth.clientID
    config.oauth.key ?= config.oauth.consumerKey

    config.oauth.secret ?= config.oauth.clientSecret
    config.oauth.secret ?= config.oauth.consumerSecret

    return JSON.parse JSON.stringify config # removes things that are undefined

module.exports = OauthConfig
