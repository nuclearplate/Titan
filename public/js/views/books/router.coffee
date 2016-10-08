ListView = require './list'

Router = Backbone.SubRoute.extend
  routes:
    "": "list"

  initialize: ({@page, @parent}) ->

  list: () ->
    view = new ListView
    $('.main-housing').html view.render().el

module.exports = Router