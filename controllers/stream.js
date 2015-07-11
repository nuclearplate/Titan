var User = require('../models/User');
var Stream = require('../models/Stream');

function StreamController(emitter) {
	this.emitter = emitter;
}

StreamController.prototype.push = function(req, res) {
	console.log("GOT PUSH EVENT");
	var username = req.params.user;
	var streamId = req.params.streamId;
	
	var eventName = username + '/' + streamId + '/data';
	console.log("PUSH EMITTING", eventName);
	this.emitter.emit(eventName, req.body);

	res.json(req.body);
};

StreamController.prototype.create = function(req, res, next) {
	if(req.body.user === undefined) {
		return res.status(500).json({error: "Can't create stream, no email provided"})
	}

	if(req.body.location === undefined) {
		return res.status(500).json({error: "Can't create stream, no email provided"})
	}

	var streamData = {
    name: req.body.name,
    user: req.body.user,
  };

  var stream = new Stream(streamData);

  Stream.findOne({name: req.body.name}, function(err, existingStream) {
    if (existingStream) {
    	error = 'Stream with that name address already exists.';
      req.flash('errors', { msg: error });
      return res.status(500).json({error: error})
    }

    stream.save(function(err) {
      if (err) return next(err);
      req.logIn(stream, function(err) {
        if (err) return next(err);
        res.json({created: streamData})
      });
    });
  });
};

StreamController.prototype.delete = function(req, res) {

};

module.exports = StreamController;
