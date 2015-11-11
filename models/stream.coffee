mongoose = require 'mongoose'

streamSchema = new mongoose.Schema
  name: String
  user: String
  location:
    lat: Number
    long: Number

module.exports = mongoose.model 'Stream', streamSchema
