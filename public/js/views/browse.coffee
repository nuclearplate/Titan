Summary = require '../models/summary'

Browse = Backbone.View.extend
  template: require '../../html/views/browse.jade'

  render: ->
    summary = new Summary
    summary.fetch().then (data) => @$el.html @template(data)
    @

module.exports = Browse