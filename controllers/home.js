/**
 * GET /
 * Home page.
 */
exports.index = function(req, res) {
  res.sendFile(__dirname + '../index.html');
};