var Summary = require('../models/summary');

var Browse = Backbone.View.extend({
	template: require('../../html/views/browse.jade'),
	
	render: function() {
		var _this = this;

		var summary = new Summary();

		summary.fetch().then(function(data) {
			_this.$el.html(_this.template(data));
		});

		return this;
	},

});

module.exports = Browse;