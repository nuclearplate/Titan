var CreateView = require('./views/create');
var BrowseView = require('./views/browse');
var LayoutView = require('./views/layout');
var WelcomeView = require('./views/welcome');

var Router = Backbone.Router.extend({
	routes: {
		'': 'welcome',
		'browse': 'browse',
		'create': 'create',
	},

	showView: function(callback) {
		var layout = new LayoutView();
		$('.main-container').html(layout.render().el);
		callback();
	},

	welcome: function() {
		this.showView(function() {
			var welcome = new WelcomeView();
			$('.main-housing').html(welcome.render().el);
		});
	},

	create: function() {
		this.showView(function() {
			var create = new CreateView();
			$('.main-housing').html(create.render().el);
		});
	},

	browse: function() {
		this.showView(function() {
			var browse = new BrowseView();
			$('.main-housing').html(browse.render().el);
		});
	},

});

module.exports = Router;
