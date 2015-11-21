CreateView = require './views/create'
BrowseView = require './views/browse'
LayoutView = require './views/layout'
WelcomeView = require './views/welcome'

Router = Backbone.Router.extend
  routes:
    '': 'welcome'
    'browse': 'browse'
    'create': 'create'

  showView: (callback) ->
    layout = new LayoutView
    $('.main-container').html layout.render().el
    callback()

  welcome: ->
    @showView ->
      welcome = new WelcomeView
      $('.main-housing').html welcome.render().el

  create: ->
    @showView ->
      create = new CreateView
      $('.main-housing').html create.render().el

  browse: ->
    @showView ->
      browse = new BrowseView
      $('.main-housing').html browse.render().el

module.exports = Router