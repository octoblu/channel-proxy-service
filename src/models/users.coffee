class Users
  constructor: ({@users}) ->
  get: (uuid, callback) =>
    return callback new Error('Missing User Uuid') unless uuid?
    @users.findOne 'skynet.uuid': uuid, callback

module.exports = Users
