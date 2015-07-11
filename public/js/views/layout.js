var Layout = Backbone.View.extend({

	template: require('../../html/layout.jade'),
	
	render: function() {
		var context = {
			title: 'Emits.io',
			messages: [],
			user: {
				profile: {
					picture: 'https://avatars2.githubusercontent.com/u/1222872?v=3&s=460'
				}
			},
		};

		this.$el.html(this.template(context));
		return this;
	},

});

module.exports = Layout;
