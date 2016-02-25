cors                = require 'cors'
morgan              = require 'morgan'
express             = require 'express'
bodyParser          = require 'body-parser'
errorHandler        = require 'errorhandler'
meshbluHealthcheck  = require 'express-meshblu-healthcheck'
meshbluAuth         = require 'express-meshblu-auth'
MeshbluConfig       = require 'meshblu-config'
debug               = require('debug')('channel-proxy-service:server')
Router              = require './router'
ChannelProxyService = require './services/channel-proxy-service'
UsersModel          = require './models/users'
FlowsModel          = require './models/flows'
mongojs             = require 'mongojs'

class Server
  constructor: ({@disableLogging, @port}, {@meshbluConfig, @mongoDbUri, @channelConfig})->
    @meshbluConfig ?= new MeshbluConfig().toJSON()

  address: =>
    @server.address()

  run: (callback) =>
    app = express()
    app.use meshbluHealthcheck()
    app.use morgan 'dev', immediate: false unless @disableLogging
    app.use cors()
    app.use errorHandler()
    app.use meshbluAuth(@meshbluConfig)
    app.use bodyParser.urlencoded limit: '1mb', extended : true
    app.use bodyParser.json limit : '1mb'

    app.options '*', cors()

    database = mongojs @mongoDbUri, ['users', 'flows']
    flows = new FlowsModel {flows: database.flows}
    users = new UsersModel {users: database.users}
    channelProxyService = new ChannelProxyService {@channelConfig, users, flows}
    router = new Router {@meshbluConfig, channelProxyService}

    router.route app

    @server = app.listen @port, callback

  stop: (callback) =>
    @server.close callback

module.exports = Server
