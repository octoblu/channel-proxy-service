http          = require 'http'
request       = require 'request'
mongojs       = require 'mongojs'
{ObjectId}    = require 'mongojs'
shmock        = require '@octoblu/shmock'
Server        = require '../../src/server'
ChannelConfig = require '../../src/models/channel-config'
textCrypt = require '../../src/models/text-crypt'

describe 'Github Make Request', ->
  beforeEach ->
    @mongoDbUri = 'octoblu-test-database'
    @database = mongojs @mongoDbUri, ['users', 'flows']

  beforeEach (done) ->
    @database.users.remove => done()

  beforeEach (done) ->
    @database.flows.remove => done()

  beforeEach (done) ->
    @meshblu = shmock 0xd00d
    @github = shmock 0xbabe

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

    @server = new Server serverOptions, {meshbluConfig, @mongoDbUri, channelConfig}

    @server.run =>
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop done

  afterEach (done) ->
    @meshblu.close done

  afterEach (done) ->
    @github.close done

  describe 'when a flows is stored in mongo', ->
    beforeEach (done) ->
      flow =
        flowId: 'flow-uuid'
        resource:
          owner:
            uuid: 'user-uuid'
      @database.flows.insert flow, done

    describe 'when a user is stored in mongo', ->
      beforeEach (done) ->
        user =
          resource:
            uuid: 'user-uuid'
          api: [
            authtype: "oauth",
            token_crypt: textCrypt.encrypt 'github-auth-access-token'
            channelid: ObjectId("532a258a50411e5802cb8053"),
            _id: ObjectId("56a1254b0c6266010001875e"),
            type: "channel:github",
            uuid: "channel-github-uuid"
          ]
        @database.users.insert user, done

      describe 'when the service succeeds', ->
        beforeEach (done) ->
          flowAuth = new Buffer('flow-uuid:flow-token').toString 'base64'

          @authDevice = @meshblu
            .get '/v2/whoami'
            .set 'Authorization', "Basic #{flowAuth}"
            .reply 200, uuid: 'flow-uuid', token: 'flow-token'

          @getGithub = @github
            .get '/users/sqrtofsaturn/followers'
            .query access_token: 'github-auth-access-token'
            .reply 200,
              login: 'travist'
              id: 130052
              avatar_url: 'https://avatars.githubusercontent.com/u/130052?v=3'

          options =
            uri: '/request'
            baseUrl: "http://localhost:#{@serverPort}"
            auth:
              username: 'flow-uuid'
              password: 'flow-token'
            json:
              channelid: '532a258a50411e5802cb8053'
              channelActivationId: '56a1254b0c6266010001875e'
              uuid: 'e56842b0-5e2e-11e5-8abf-b33a470ad64b'
              type: 'channel:github'
              headerParams: {}
              urlParams:
                ':username': 'sqrtofsaturn'
              queryParams: {}
              bodyParams: {}
              url: "http://localhost:#{0xbabe}/users/:username/followers",
              method: 'GET'

          request.post options, (error, @response, @body) => done error

        it 'should auth handler', ->
          @authDevice.done()

        it 'should get the github', ->
          @getGithub.done()

        it 'should return a 200', ->
          expect(@response.statusCode).to.equal 200

        it 'should return a body', ->
          expect(@body).to.deep.equal
            login: 'travist'
            id: 130052
            avatar_url: 'https://avatars.githubusercontent.com/u/130052?v=3'
