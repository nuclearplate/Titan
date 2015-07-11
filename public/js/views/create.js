var CreateView = Backbone.View.extend({
	template: require('../../html/views/create.jade'),
	
	render: function() {
		var _this = this;
		this.$el.html(this.template());

		vex.dialog.confirm({
		  message: 'Are you absolutely sure you want to destroy the alien planet?',
		  callback: function(value) {
		    return console.log(value ? 'Successfully destroyed the planet.' : 'Chicken.');
		  }
		});

		return this;
	},

});

module.exports = CreateView;