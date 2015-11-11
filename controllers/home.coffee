###*
# GET /
# Home page.
###

exports.index = (req, res) ->
  res.sendFile __dirname + '../index.html'
