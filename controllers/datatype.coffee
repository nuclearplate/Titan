DataType = require('../models/DataType')

DataTypeController = (emitter) ->

DataTypeController::create = (req, res, next) ->
  `var data`
  if req.body.constructor == String
    data = JSON.parse(req.body)
  else
    data = req.body
  if data.user == undefined
    return res.status(500).json(error: 'Can\'t create data type, no creator provided')
  dataTypeData = 
    name: data.name
    defs: data.defs
    user: data.user
  dataType = new DataType(dataTypeData)
  query = 
    name: dataTypeData.name
    user: dataTypeData.user
  DataType.findOne query, (err, existing) ->
    if existing
      error = 'DataType with that name address already exists.'
      req.flash 'errors', msg: error
      return res.status(500).json(error: error)
    dataType.save (err) ->
      if err
        return next(err)
      req.logIn dataType, (err) ->
        if err
          return next(err)
        res.json created: dataTypeData
        return
      return
    return
  return

DataTypeController::delete = (req, res) ->

module.exports = DataTypeController