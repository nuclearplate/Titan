var DataType = require('../models/DataType');

function DataTypeController(emitter) {

}

DataTypeController.prototype.create = function(req, res, next) {
  if(req.body.constructor === String) {
    var data = JSON.parse(req.body);  
  } else {
    var data = req.body
  }

	if(data.user === undefined) {
		return res.status(500).json({error: "Can't create data type, no creator provided"})
	}

	var dataTypeData = {
    name: data.name,
    defs: data.defs,
    user: data.user,
  };

  var dataType = new DataType(dataTypeData);

  var query = {
    name: dataTypeData.name,
    user: dataTypeData.user
  };

  DataType.findOne(query, function(err, existing) {
    if(existing) {
    	error = 'DataType with that name address already exists.';
      req.flash('errors', { msg: error });
      return res.status(500).json({error: error})
    }

    dataType.save(function(err) {
      if (err) return next(err);
      req.logIn(dataType, function(err) {
        if (err) return next(err);
        res.json({created: dataTypeData});
      });
    });
  });
};

DataTypeController.prototype.delete = function(req, res) {

};

module.exports = DataTypeController;
