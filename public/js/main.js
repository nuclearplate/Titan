require('../css/main.less');
require('../vendor/vex/css/vex.css');
require('../vendor/vex/css/vex-theme-wireframe.css');

window.Backbone = require('backbone');
window.jQuery = require('jquery');
window.Backbone.$ = jQuery;
window.$ = jQuery;
window.vex = require('../vendor/vex/js/vex');
window.vex.defaultOptions.className = 'vex-theme-wireframe';
require('../vendor/vex/js/vex.dialog');

var Router = require('./router');

var router = new Router();

Backbone.history.start();