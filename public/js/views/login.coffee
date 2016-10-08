View = Backbone.View.extend
  template: require '../../html/views/login.jade'
  
  render: ->
    @$el.html @template()
    @

module.exports = View
