
View = Backbone.View.extend
  template: require '../../../html/views/books/list.jade'

  render: ->
    @$el.html @template()
    @

module.exports = View