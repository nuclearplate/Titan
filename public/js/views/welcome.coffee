require '../../css/views/welcome.less'

WelcomeView = Backbone.View.extend
  template: require '../../html/views/welcome.jade'
  
  render: ->
    @$el.html @template()
    @

module.exports = WelcomeView