http          = require 'http'
request       = require 'request'
mongojs       = require 'mongojs'
{ObjectId}    = require 'mongojs'
shmock        = require '@octoblu/shmock'
Server        = require '../../src/server'
ChannelConfig = require '../../src/models/channel-config'

describe 'Make Request', ->
  beforeEach (done) ->
    database = mongojs 'octoblu-test-database', ['users']
    @users = database.users
    @users.remove => done()

  beforeEach (done) ->
    @meshblu = shmock 0xd00d

    serverOptions =
      port: undefined,
      disableLogging: true

    meshbluConfig =
      server: 'localhost'
      port: 0xd00d

    channelConfig = new ChannelConfig {}
    channelConfig.fetch = sinon.stub().yields null

    channelConfig._channels = [
      require('../data/github-channel.json'),
      require('../data/weather-channel.json')
    ]

    @server = new Server serverOptions, {meshbluConfig, @users, channelConfig}

    @server.run =>
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop done

  afterEach (done) ->
    @meshblu.close done

  describe 'when a user is stored in mongo', ->
    beforeEach (done) ->
      user =
        skynet: {
          uuid: 'user-uuid'
        }
        resource: {
          uuid: 'user-uuid'
        }
        api: [
          {
            authtype: "none",
            channelid: ObjectId("5337a38d76a65b9693bc2a9f"),
            _id: ObjectId("569fc2fd0c626601000186ee"),
            type: "channel:weather",
            uuid: "channel-weather-uuid"
          }
        ]
      @users.insert user, done

    describe 'when the service succeeds', ->
      beforeEach (done) ->
        flowAuth = new Buffer('flow-uuid:flow-token').toString 'base64'

        @authDevice = @meshblu
          .get '/v2/whoami'
          .set 'Authorization', "Basic #{flowAuth}"
          .reply 200, uuid: 'flow-uuid', token: 'flow-token'

        options =
          uri: '/request'
          baseUrl: "http://localhost:#{@serverPort}"
          auth:
            username: 'flow-uuid'
            password: 'flow-token'
          json:
            userUuid: 'user-uuid'
            config:
              channelid: '5337a38d76a65b9693bc2a9f'
              channelActivationId: '569fc2fd0c626601000186ee'
              uuid: 'e56842b0-5e2e-11e5-8abf-b33a470ad64b'
              type: 'channel:weather'

        request.post options, (error, @response, @body) => done error

      it 'should auth handler', ->
        @authDevice.done()

      it 'should return a 200', ->
        expect(@response.statusCode).to.equal 200, @body
