Socket = require 'socket.io'
bundle = require 'socket.io-bundle'
secrets = require '../config/secrets'

class Sockets
  constructor: (@server, @app, @session) ->
    @clients = {}

  setup: (app) ->
    @io = Socket.listen @server
    @io.on 'connection', @onConnection
    @io.use (socket, next) =>
      console.log "SOCKET MIDDLEWARE"
      @session socket.request, {}, next

  emit: (guid, name, data) =>
    # console.log "EMITTING", guid, name, data
    unless @clients[guid] is undefined
      @clients[guid].socket.emit name, data

  onConnection: (socket) =>
    console.log "GOT SOCKET CONNECTION", socket.request.session.passport.user
    @clients[socket.request.session.passport.user] =
      socket: socket

    socket.on 'disconnect', =>
      delete @clients[socket.request.session.passport.user]

module.exports = Sockets