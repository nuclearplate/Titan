WriteView = require './list'

Router = Backbone.SubRoute.extend
  routes:
    "": "list"

  initialize: ({@page, @parent}) ->

  list: () ->
    view = new DeployView
    $('.main-housing').html view.render().el
    @parent.loadTheme @page

module.exports = Router