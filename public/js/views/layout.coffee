Layout = Backbone.View.extend
  template: require '../../html/layout.jade'
  
  render: ->
    context = 
      title: 'Emits.io'
      messages: []
      user: profile: picture: 'https://avatars2.githubusercontent.com/u/1222872?v=3&s=460'
    
    @$el.html @template(context)
    @

module.exports = Layout