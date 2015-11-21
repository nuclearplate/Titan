Stream = require '../models/stream'

class StreamController
  constructor: (@emitter) ->

  push: (req, res) ->
    console.log 'GOT PUSH EVENT'
    username = req.params.user
    streamId = req.params.streamId
    eventName = username + '/' + streamId + '/data'
    console.log 'PUSH EMITTING', eventName
    @emitter.emit eventName, req.body
    res.json req.body

  create: (req, res, next) ->
    if req.body.user == undefined
      return res.status(500).json(error: 'Can\'t create stream, no email provided')
    if req.body.location == undefined
      return res.status(500).json(error: 'Can\'t create stream, no email provided')

    streamData =
      name: req.body.name
      user: req.body.user
    
    stream = new Stream streamData
    
    Stream.findOne { name: req.body.name }, (err, existingStream) ->
      if existingStream
        error = 'Stream with that name address already exists.'
        req.flash 'errors', msg: error
        return res.status(500).json(error: error)
      
      stream.save (err) ->
        if err
          return next(err)
        req.logIn stream, (err) ->
          if err
            return next(err)
          res.json created: streamData

  delete: (req, res) ->

module.exports = StreamController
