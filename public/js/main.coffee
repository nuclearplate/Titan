io = require 'socket.io-client'
uuid = require 'node-uuid'
loadDeps = require './deps'

loadDeps ->
  Router = require './router'
  window.vulcan = {
    guid: uuid.v1()
    routers:
      main: new Router
    models: {}
    socket: io(window.location.origin)
  }

  vulcan.socket.on 'connect', ->
    vulcan.socket.emit 'identify',
      guid: vulcan.guid

  Backbone.history.start()