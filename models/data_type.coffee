mongoose = require 'mongoose'

fieldDefsSchema = new mongoose.Schema
  name: String
  path: String
  type: String

dataTypeSchema = new mongoose.Schema
  name: String
  user: String
  defs: [fieldDefsSchema]

module.exports = mongoose.model 'DataType', dataTypeSchema
