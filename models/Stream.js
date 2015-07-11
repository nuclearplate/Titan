var mongoose = require('mongoose');

var streamSchema = new mongoose.Schema({
  name: String,
  user: String, // The username of the user that created this stream
  location: {
  	lat: Number,
  	long: Number
  }
});

module.exports = mongoose.model('Stream', streamSchema);