###*
# Module dependencies.
###

_ = require 'lodash'
path = require 'path'
lusca = require 'lusca'
flash = require 'express-flash'.
logger = require 'morgan'
multer = require 'multer'
express = require 'express'
compress = require 'compression'
favicon = require 'serve-favicon'
session = require 'express-session'
mongoose = require 'mongoose'
passport = require 'passport'
bodyParser = require 'body-parser'
MongoStore = require('connect-mongo')(session)
errorHandler = require 'errorhandler'
cookieParser = require 'cookie-parser'
methodOverride = require 'method-override'
connectAssets = require 'connect-assets'
{EventEmitter} = require 'events'
expressValidator = require 'express-validator'

###*
# Central Data Event Emitter
###

emitter = new EventEmitter

###*
# Controllers (route handlers).
###

apiController = require './controllers/api'
homeController = require './controllers/home'
userController = require './controllers/user'
SummaryController = require './controllers/summary'
summaryController = new SummaryController
DataTypeController = require './controllers/datatype'
dataTypeController = new DataTypeController
StreamController = require './controllers/stream'
streamController = new StreamController emitter
contactController = require './controllers/contact'

###*
# API keys and Passport configuration.
###

secrets = require './config/secrets'
passportConf = require './config/passport'

###*
# Create Express server.
###

app = express()

###*
# Connect to MongoDB.
###

mongoose.connect secrets.db
mongoose.connection.on 'error', ->
  console.error 'MongoDB Connection Error. Please make sure that MongoDB is running.'
  return

###*
# Express configuration.
###

allowCrossDomain = (req, res, next) ->
  res.header 'Access-Control-Allow-Origin', 'example.com'
  res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
  res.header 'Access-Control-Allow-Headers', 'Content-Type'
  next()
  return

app.set 'port', process.env.PORT or 3333
app.use express.static(__dirname + '/node_modules')
app.use '/build', express.static('build')
app.use '/node_modules', express.static('node_modules')
app.use '/package.json', express.static('package.json')
#app.use('/index.html', express.static('index.html'));
app.use compress()
app.use connectAssets(paths: [
  path.join(__dirname, 'public/css')
  path.join(__dirname, 'public/js')
  path.join(__dirname, 'public/img')
])
app.use logger('dev')
app.use favicon(path.join(__dirname, 'public/favicon.png'))
app.use bodyParser.json()
app.use bodyParser.raw()
app.use bodyParser.text()
app.use bodyParser.urlencoded(extended: true)
app.use multer(dest: path.join(__dirname, 'uploads'))
app.use expressValidator()
#app.use(allowCrossDomain);
app.use methodOverride()
app.use cookieParser()
app.use session(
  resave: true
  saveUninitialized: true
  secret: secrets.sessionSecret
  store: new MongoStore(
    url: secrets.db
    autoReconnect: true))
app.use passport.initialize()
app.use passport.session()
app.use flash()
app.use (req, res, next) ->
  res.locals.user = req.user
  next()
  return
app.use (req, res, next) ->
  if /api/i.test(req.path)
    req.session.returnTo = req.path
  next()
  return
app.use express.static(path.join(__dirname, 'public'), maxAge: 31557600000)

###*
# Primary app routes.
###

app.get '/', (req, res) ->
  res.sendFile __dirname + '/index.html'
  return
app.get '/index.html', (req, res) ->
  res.sendFile __dirname + '/index.html'
  return
app.get '/login', userController.getLogin
app.post '/login', userController.postLogin
app.get '/logout', userController.logout
app.get '/forgot', userController.getForgot
app.post '/forgot', userController.postForgot
app.get '/reset/:token', userController.getReset
app.post '/reset/:token', userController.postReset
app.get '/signup', userController.getSignup
app.post '/signup', userController.postSignup
app.get '/contact', contactController.getContact
app.post '/contact', contactController.postContact
app.get '/account', passportConf.isAuthenticated, userController.getAccount
app.post '/account/profile', passportConf.isAuthenticated, userController.postUpdateProfile
app.post '/account/password', passportConf.isAuthenticated, userController.postUpdatePassword
app.post '/account/delete', passportConf.isAuthenticated, userController.postDeleteAccount
app.get '/account/unlink/:provider', passportConf.isAuthenticated, userController.getOauthUnlink

###*
# DataFountain routes
###

app.get '/api/users', userController.getAll
app.get '/api/summary', summaryController.summary
app.get '/api/:user/streams/:streamId', userController.getStream
app.get '/api/:user/streams', userController.getStreams
app.get '/api/:user/datatypes', userController.getDataTypes
app.post '/api/datatype', dataTypeController.create
app.post '/api/stream', streamController.create
app.delete '/api/stream', streamController.delete
app.post '/api/:user/streams/:streamId', ->
  streamController.push.apply streamController, arguments
  return
# /**
#  * API examples routes.
#  */
# app.get('/api', apiController.getApi);
# app.get('/api/lastfm', apiController.getLastfm);
# app.get('/api/nyt', apiController.getNewYorkTimes);
# app.get('/api/aviary', apiController.getAviary);
# app.get('/api/steam', apiController.getSteam);
# app.get('/api/stripe', apiController.getStripe);
# app.post('/api/stripe', apiController.postStripe);
# app.get('/api/scraping', apiController.getScraping);
# app.get('/api/twilio', apiController.getTwilio);
# app.post('/api/twilio', apiController.postTwilio);
# app.get('/api/clockwork', apiController.getClockwork);
# app.post('/api/clockwork', apiController.postClockwork);
# app.get('/api/foursquare', passportConf.isAuthenticated, passportConf.isAuthorized, apiController.getFoursquare);
# app.get('/api/tumblr', passportConf.isAuthenticated, passportConf.isAuthorized, apiController.getTumblr);
# app.get('/api/facebook', passportConf.isAuthenticated, passportConf.isAuthorized, apiController.getFacebook);
# app.get('/api/github', passportConf.isAuthenticated, passportConf.isAuthorized, apiController.getGithub);
# app.get('/api/twitter', passportConf.isAuthenticated, passportConf.isAuthorized, apiController.getTwitter);
# app.post('/api/twitter', passportConf.isAuthenticated, passportConf.isAuthorized, apiController.postTwitter);
# app.get('/api/venmo', passportConf.isAuthenticated, passportConf.isAuthorized, apiController.getVenmo);
# app.post('/api/venmo', passportConf.isAuthenticated, passportConf.isAuthorized, apiController.postVenmo);
# app.get('/api/linkedin', passportConf.isAuthenticated, passportConf.isAuthorized, apiController.getLinkedin);
# app.get('/api/instagram', passportConf.isAuthenticated, passportConf.isAuthorized, apiController.getInstagram);
# app.get('/api/yahoo', apiController.getYahoo);
# app.get('/api/paypal', apiController.getPayPal);
# app.get('/api/paypal/success', apiController.getPayPalSuccess);
# app.get('/api/paypal/cancel', apiController.getPayPalCancel);
# app.get('/api/lob', apiController.getLob);
# app.get('/api/bitgo', apiController.getBitGo);
# app.post('/api/bitgo', apiController.postBitGo);
# /**
#  * OAuth authentication routes. (Sign in)
#  */
# app.get('/auth/instagram', passport.authenticate('instagram'));
# app.get('/auth/instagram/callback', passport.authenticate('instagram', { failureRedirect: '/login' }), function(req, res) {
#   res.redirect(req.session.returnTo || '/');
# });
# app.get('/auth/facebook', passport.authenticate('facebook', { scope: ['email', 'user_location'] }));
# app.get('/auth/facebook/callback', passport.authenticate('facebook', { failureRedirect: '/login' }), function(req, res) {
#   res.redirect(req.session.returnTo || '/');
# });
# app.get('/auth/github', passport.authenticate('github'));
# app.get('/auth/github/callback', passport.authenticate('github', { failureRedirect: '/login' }), function(req, res) {
#   res.redirect(req.session.returnTo || '/');
# });
# app.get('/auth/google', passport.authenticate('google', { scope: 'profile email' }));
# app.get('/auth/google/callback', passport.authenticate('google', { failureRedirect: '/login' }), function(req, res) {
#   res.redirect(req.session.returnTo || '/');
# });
# app.get('/auth/twitter', passport.authenticate('twitter'));
# app.get('/auth/twitter/callback', passport.authenticate('twitter', { failureRedirect: '/login' }), function(req, res) {
#   res.redirect(req.session.returnTo || '/');
# });
# app.get('/auth/linkedin', passport.authenticate('linkedin', { state: 'SOME STATE' }));
# app.get('/auth/linkedin/callback', passport.authenticate('linkedin', { failureRedirect: '/login' }), function(req, res) {
#   res.redirect(req.session.returnTo || '/');
# });
# /**
#  * OAuth authorization routes. (API examples)
#  */
# app.get('/auth/foursquare', passport.authorize('foursquare'));
# app.get('/auth/foursquare/callback', passport.authorize('foursquare', { failureRedirect: '/api' }), function(req, res) {
#   res.redirect('/api/foursquare');
# });
# app.get('/auth/tumblr', passport.authorize('tumblr'));
# app.get('/auth/tumblr/callback', passport.authorize('tumblr', { failureRedirect: '/api' }), function(req, res) {
#   res.redirect('/api/tumblr');
# });
# app.get('/auth/venmo', passport.authorize('venmo', { scope: 'make_payments access_profile access_balance access_email access_phone' }));
# app.get('/auth/venmo/callback', passport.authorize('venmo', { failureRedirect: '/api' }), function(req, res) {
#   res.redirect('/api/venmo');
# });

###*
# Error Handler.
###

app.use errorHandler()

###*
# Start Express server.
###

server = app.listen(app.get('port'), ->
  console.log 'Express server listening on port %d in %s mode', app.get('port'), app.get('env')
  return
)
io = require('socket.io').listen(server)
io.sockets.on 'connection', (client) ->
  console.log 'CONNECTION'
  username = null
  streamId = null
  client.on 'info', (info) ->
    console.log 'GOT INFO', info
    username = info.username
    streamId = info.streamId
    eventName = username + '/' + streamId + '/data'
    console.log 'LISTENING FOR', eventName
    emitter.on eventName, (data) ->
      console.log 'ABOUT TO EMIT DATA'
      client.emit 'data', data
      return
    return
  # client.on('data', function (data) {
  #   var eventName = username + '/' + streamId + '/data';
  #   emitter.emit(eventName, data);
  # });
  return
module.exports = app

# ---
# generated by js2coffee 2.1.0