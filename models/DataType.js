var mongoose = require('mongoose');

var fieldDefsSchema = new mongoose.Schema({
	name: String,
	path: String,
	type: String,
});

var dataTypeSchema = new mongoose.Schema({
  name: String,
  user: String, // username of the owner
  defs: [fieldDefsSchema],
});

module.exports = mongoose.model('DataType', dataTypeSchema);
