http       = require 'http'
request    = require 'request'
mongojs    = require 'mongojs'
{ObjectId} = require 'mongojs'
shmock     = require '@octoblu/shmock'
Server     = require '../../src/server'

describe 'Make Request', ->
  beforeEach (done) ->
    database = mongojs 'octoblu-test-database', ['users']
    @collection = database.users
    @collection.remove => done()

  beforeEach (done) ->
    @meshblu = shmock 0xd00d

    serverOptions =
      port: undefined,
      disableLogging: true

    meshbluConfig =
      server: 'localhost'
      port: 0xd00d

    @server = new Server serverOptions, {meshbluConfig, @collection}

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
          uuid: 'some-uuid'
        }
        resource: {
          uuid: 'some-uuid'
        }
        api: [
          {
            authtype: "none",
            channelid: ObjectId("5337a38d76a65b9693bc2a9f"),
            _id: ObjectId("569fc2fd0c626601000186ee"),
            type: "channel:weather",
            uuid: "channel-weather-uuid"
          },
          {
            authtype: "none",
            channelid: ObjectId("53275d4841da719147d9e36a"),
            _id: ObjectId("569fc2fd0c626601000186ef"),
            type: "channel:stock-price",
            uuid: "channel-stock-price-uuid"
          }
        ]
      @collection.insert user, done

    describe 'when the service succeeds', ->
      beforeEach (done) ->
        userAuth = new Buffer('some-uuid:some-token').toString 'base64'

        @authDevice = @meshblu
          .get '/v2/whoami'
          .set 'Authorization', "Basic #{userAuth}"
          .reply 200, uuid: 'some-uuid', token: 'some-token'

        options =
          uri: '/request'
          baseUrl: "http://localhost:#{@serverPort}"
          auth:
            username: 'some-uuid'
            password: 'some-token'
          json: true

        request.get options, (error, @response, @body) => done error

      it 'should auth handler', ->
        @authDevice.done()

      it 'should return a 200', ->
        expect(@response.statusCode).to.equal 200
