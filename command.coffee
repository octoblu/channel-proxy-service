_             = require 'lodash'
MeshbluConfig = require 'meshblu-config'
Server        = require './src/server'
ChannelConfig = require './src/models/channel-config'

class Command
  constructor: ->
    @serverOptions =
      port:           process.env.PORT || 80
      disableLogging: process.env.DISABLE_LOGGING == "true"

    @mongoDbUri = process.env.MONGODB_URI
    @accessKeyId  = process.env.AWS_ACCESS_KEY_ID
    @secretAccessKey  = process.env.AWS_SECRET_ACCESS_KEY

  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    # Use this to require env
    @panic new Error('Missing required environment variable: MONGODB_URI') if _.isEmpty @mongoDbUri
    @panic new Error('Missing required environment variable: AWS_ACCESS_KEY_ID') if _.isEmpty @accessKeyId
    @panic new Error('Missing required environment variable: AWS_SECRET_ACCESS_KEY') if _.isEmpty @secretAccessKey

    meshbluConfig = new MeshbluConfig().toJSON()
    channelConfig = new ChannelConfig {@accessKeyId, @secretAccessKey}
    server = new Server @serverOptions, {meshbluConfig, @mongoDbUri, channelConfig}

    server.run (error) =>
      return @panic error if error?

      {address,port} = server.address()
      console.log "Server listening on #{address}:#{port}"

    process.on 'SIGTERM', =>
      console.log 'SIGTERM caught, exiting'
      server.stop =>
        process.exit 0

command = new Command()
command.run()
