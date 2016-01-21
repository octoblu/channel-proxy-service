_  = require 'lodash'

class Flows
  constructor: ({@flows}) ->
  getUserUuidForFlow: (uuid, callback) =>
    return callback new Error('Missing Flow Uuid') unless uuid?
    @flows.findOne 'resource.owner.uuid': uuid, (error, flow) =>
      return callback error if error?
      callback null, _.get flow, 'resource.owner.uuid'

module.exports = Flows
