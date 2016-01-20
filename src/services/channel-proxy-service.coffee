class ChannelProxyService
  makeRequest: ({}, callback) =>
    callback()

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = ChannelProxyService
