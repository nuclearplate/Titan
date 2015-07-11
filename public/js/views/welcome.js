require('../../css/views/welcome.less');

var WelcomeView = Backbone.View.extend({
	template: require('../../html/views/welcome.jade'),
	
	render: function() {
		var _this = this;
		this.$el.html(this.template());
		return this;
	},

});

module.exports = WelcomeView;