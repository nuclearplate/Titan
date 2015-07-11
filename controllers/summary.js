var Q = require('Q');
var User = require('../models/User');
var Stream = require('../models/Stream');

function SummaryController() {

}

SummaryController.prototype.summary = function(req, res) {
  
  mapper = function() {
  	emit('user:' + this.user, 1)
  	emit('name:' + this.name, 1)
  };

  reducer = function(type, counts) {
  	var total = 0;
  	for(var index in counts) {
  		total += Number(counts[index]);
  	}

  	return total;
  };

  var opts = {
    out: 'tmp_collection',
    map: mapper,
    query: {},
    reduce: reducer
  };

  Q.ninvoke(Stream, 'mapReduce', opts)
  	.then(function(results) {
  		model = results[0];
  		stats = results[1];

  		model.find(function(err, totals) {
  			console.log("TOTALS", arguments);
  			retval = {};

  			for(var iTotal=0; iTotal<totals.length; ++iTotal) {
  				var split = totals[iTotal]._id.split(':');
  				var type = split[0];
  				var value = split[1];
  				var count = totals[iTotal].value;

  				if(retval[type] === undefined) {
  					retval[type] = {};
  				}

  				if(retval[type][value] === undefined){
  					retval[type][value] = {};
  				}
  					
  				retval[type][value] = count;

  			}

				res.json(retval);
  		})
  	})

}

module.exports = SummaryController;
