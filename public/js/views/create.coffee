CreateView = Backbone.View.extend
  template: require '../../html/views/create.jade'
  
  render: ->
    @$el.html @template()
    vex.dialog.confirm
      message: 'Are you absolutely sure you want to destroy the alien planet?'
      callback: (value) ->
        console.log if value then 'Successfully destroyed the planet.' else 'Chicken.'
    @

module.exports = CreateView
