secrets = require '../config/secrets'
querystring = require 'querystring'
validator = require 'validator'
async = require 'async'
cheerio = require 'cheerio'
request = require 'request'
graph = require 'fbgraph'
LastFmNode = require('lastfm').LastFmNode
tumblr = require('tumblr.js')
foursquare = require('node-foursquare')(secrets: secrets.foursquare)
Github = require('github-api')
Twit = require('twit')
stripe = require('stripe')(secrets.stripe.secretKey)
twilio = require('twilio')(secrets.twilio.sid, secrets.twilio.token)
Linkedin = require('node-linkedin')(secrets.linkedin.clientID, secrets.linkedin.clientSecret, secrets.linkedin.callbackURL)
BitGo = require('bitgo')
clockwork = require('clockwork')(key: secrets.clockwork.apiKey)
paypal = require('paypal-rest-sdk')
lob = require('lob')(secrets.lob.apiKey)
ig = require('instagram-node').instagram()
Y = require('yui/yql')
_ = require('lodash')

###*
# GET /api
# List of API examples.
###

exports.getApi = (req, res) ->
  res.render 'api/index', title: 'API Examples'
  return

###*
# GET /api/foursquare
# Foursquare API example.
###

exports.getFoursquare = (req, res, next) ->
  token = _.find(req.user.tokens, kind: 'foursquare')
  async.parallel {
    trendingVenues: (callback) ->
      foursquare.Venues.getTrending '40.7222756', '-74.0022724', { limit: 50 }, token.accessToken, (err, results) ->
        callback err, results
        return
      return
    venueDetail: (callback) ->
      foursquare.Venues.getVenue '49da74aef964a5208b5e1fe3', token.accessToken, (err, results) ->
        callback err, results
        return
      return
    userCheckins: (callback) ->
      foursquare.Users.getCheckins 'self', null, token.accessToken, (err, results) ->
        callback err, results
        return
      return

  }, (err, results) ->
    if err
      return next(err)
    res.render 'api/foursquare',
      title: 'Foursquare API'
      trendingVenues: results.trendingVenues
      venueDetail: results.venueDetail
      userCheckins: results.userCheckins
    return
  return

###*
# GET /api/tumblr
# Tumblr API example.
###

exports.getTumblr = (req, res, next) ->
  token = _.find(req.user.tokens, kind: 'tumblr')
  client = tumblr.createClient(
    consumer_key: secrets.tumblr.consumerKey
    consumer_secret: secrets.tumblr.consumerSecret
    token: token.accessToken
    token_secret: token.tokenSecret)
  client.posts 'withinthisnightmare.tumblr.com', { type: 'photo' }, (err, data) ->
    if err
      return next(err)
    res.render 'api/tumblr',
      title: 'Tumblr API'
      blog: data.blog
      photoset: data.posts[0].photos
    return
  return

###*
# GET /api/facebook
# Facebook API example.
###

exports.getFacebook = (req, res, next) ->
  token = _.find(req.user.tokens, kind: 'facebook')
  graph.setAccessToken token.accessToken
  async.parallel {
    getMe: (done) ->
      graph.get req.user.facebook, (err, me) ->
        done err, me
        return
      return
    getMyFriends: (done) ->
      graph.get req.user.facebook + '/friends', (err, friends) ->
        done err, friends.data
        return
      return

  }, (err, results) ->
    if err
      return next(err)
    res.render 'api/facebook',
      title: 'Facebook API'
      me: results.getMe
      friends: results.getMyFriends
    return
  return

###*
# GET /api/scraping
# Web scraping example using Cheerio library.
###

exports.getScraping = (req, res, next) ->
  request.get 'https://news.ycombinator.com/', (err, request, body) ->
    if err
      return next(err)
    $ = cheerio.load(body)
    links = []
    $('.title a[href^="http"], a[href^="https"]').each ->
      links.push $(this)
      return
    res.render 'api/scraping',
      title: 'Web Scraping'
      links: links
    return
  return

###*
# GET /api/github
# GitHub API Example.
###

exports.getGithub = (req, res, next) ->
  token = _.find(req.user.tokens, kind: 'github')
  github = new Github(token: token.accessToken)
  repo = github.getRepo('sahat', 'requirejs-library')
  repo.show (err, repo) ->
    if err
      return next(err)
    res.render 'api/github',
      title: 'GitHub API'
      repo: repo
    return
  return

###*
# GET /api/aviary
# Aviary image processing example.
###

exports.getAviary = (req, res) ->
  res.render 'api/aviary', title: 'Aviary API'
  return

###*
# GET /api/nyt
# New York Times API example.
###

exports.getNewYorkTimes = (req, res, next) ->
  query = querystring.stringify(
    'api-key': secrets.nyt.key
    'list-name': 'young-adult')
  url = 'http://api.nytimes.com/svc/books/v2/lists?' + query
  request.get url, (err, request, body) ->
    if err
      return next(err)
    if request.statusCode == 403
      return next(Error('Missing or Invalid New York Times API Key'))
    bestsellers = JSON.parse(body)
    res.render 'api/nyt',
      title: 'New York Times API'
      books: bestsellers.results
    return
  return

###*
# GET /api/lastfm
# Last.fm API example.
###

exports.getLastfm = (req, res, next) ->
  lastfm = new LastFmNode(secrets.lastfm)
  async.parallel {
    artistInfo: (done) ->
      lastfm.request 'artist.getInfo',
        artist: 'The Pierces'
        handlers:
          success: (data) ->
            done null, data
            return
          error: (err) ->
            done err
            return
      return
    artistTopTracks: (done) ->
      lastfm.request 'artist.getTopTracks',
        artist: 'The Pierces'
        handlers:
          success: (data) ->
            tracks = []
            _.each data.toptracks.track, (track) ->
              tracks.push track
              return
            done null, tracks.slice(0, 10)
            return
          error: (err) ->
            done err
            return
      return
    artistTopAlbums: (done) ->
      lastfm.request 'artist.getTopAlbums',
        artist: 'The Pierces'
        handlers:
          success: (data) ->
            albums = []
            _.each data.topalbums.album, (album) ->
              albums.push album.image.slice(-1)[0]['#text']
              return
            done null, albums.slice(0, 4)
            return
          error: (err) ->
            done err
            return
      return

  }, (err, results) ->
    if err
      return next(err.message)
    artist = 
      name: results.artistInfo.artist.name
      image: results.artistInfo.artist.image.slice(-1)[0]['#text']
      tags: results.artistInfo.artist.tags.tag
      bio: results.artistInfo.artist.bio.summary
      stats: results.artistInfo.artist.stats
      similar: results.artistInfo.artist.similar.artist
      topAlbums: results.artistTopAlbums
      topTracks: results.artistTopTracks
    res.render 'api/lastfm',
      title: 'Last.fm API'
      artist: artist
    return
  return

###*
# GET /api/twitter
# Twiter API example.
###

exports.getTwitter = (req, res, next) ->
  token = _.find(req.user.tokens, kind: 'twitter')
  T = new Twit(
    consumer_key: secrets.twitter.consumerKey
    consumer_secret: secrets.twitter.consumerSecret
    access_token: token.accessToken
    access_token_secret: token.tokenSecret)
  T.get 'search/tweets', {
    q: 'nodejs since:2013-01-01'
    geocode: '40.71448,-74.00598,5mi'
    count: 10
  }, (err, reply) ->
    if err
      return next(err)
    res.render 'api/twitter',
      title: 'Twitter API'
      tweets: reply.statuses
    return
  return

###*
# POST /api/twitter
# Post a tweet.
###

exports.postTwitter = (req, res, next) ->
  req.assert('tweet', 'Tweet cannot be empty.').notEmpty()
  errors = req.validationErrors()
  if errors
    req.flash 'errors', errors
    return res.redirect('/api/twitter')
  token = _.find(req.user.tokens, kind: 'twitter')
  T = new Twit(
    consumer_key: secrets.twitter.consumerKey
    consumer_secret: secrets.twitter.consumerSecret
    access_token: token.accessToken
    access_token_secret: token.tokenSecret)
  T.post 'statuses/update', { status: req.body.tweet }, (err, data, response) ->
    if err
      return next(err)
    req.flash 'success', msg: 'Tweet has been posted.'
    res.redirect '/api/twitter'
    return
  return

###*
# GET /api/steam
# Steam API example.
###

exports.getSteam = (req, res, next) ->
  steamId = '76561197982488301'
  query = 
    l: 'english'
    steamid: steamId
    key: secrets.steam.apiKey
  async.parallel {
    playerAchievements: (done) ->
      query.appid = '49520'
      qs = querystring.stringify(query)
      request.get {
        url: 'http://api.steampowered.com/ISteamUserStats/GetPlayerAchievements/v0001/?' + qs
        json: true
      }, (error, request, body) ->
        if request.statusCode == 401
          return done(new Error('Missing or Invalid Steam API Key'))
        done error, body
        return
      return
    playerSummaries: (done) ->
      query.steamids = steamId
      qs = querystring.stringify(query)
      request.get {
        url: 'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?' + qs
        json: true
      }, (err, request, body) ->
        if request.statusCode == 401
          return done(new Error('Missing or Invalid Steam API Key'))
        done err, body
        return
      return
    ownedGames: (done) ->
      query.include_appinfo = 1
      query.include_played_free_games = 1
      qs = querystring.stringify(query)
      request.get {
        url: 'http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?' + qs
        json: true
      }, (err, request, body) ->
        if request.statusCode == 401
          return done(new Error('Missing or Invalid Steam API Key'))
        done err, body
        return
      return

  }, (err, results) ->
    if err
      return next(err)
    res.render 'api/steam',
      title: 'Steam Web API'
      ownedGames: results.ownedGames.response.games
      playerAchievemments: results.playerAchievements.playerstats
      playerSummary: results.playerSummaries.response.players[0]
    return
  return

###*
# GET /api/stripe
# Stripe API example.
###

exports.getStripe = (req, res) ->
  res.render 'api/stripe',
    title: 'Stripe API'
    publishableKey: secrets.stripe.publishableKey
  return

###*
# POST /api/stripe
# Make a payment.
###

exports.postStripe = (req, res, next) ->
  stripeToken = req.body.stripeToken
  stripeEmail = req.body.stripeEmail
  stripe.charges.create {
    amount: 395
    currency: 'usd'
    card: stripeToken
    description: stripeEmail
  }, (err, charge) ->
    if err and err.type == 'StripeCardError'
      req.flash 'errors', msg: 'Your card has been declined.'
      res.redirect '/api/stripe'
    req.flash 'success', msg: 'Your card has been charged successfully.'
    res.redirect '/api/stripe'
    return
  return

###*
# GET /api/twilio
# Twilio API example.
###

exports.getTwilio = (req, res) ->
  res.render 'api/twilio', title: 'Twilio API'
  return

###*
# POST /api/twilio
# Send a text message using Twilio.
###

exports.postTwilio = (req, res, next) ->
  req.assert('number', 'Phone number is required.').notEmpty()
  req.assert('message', 'Message cannot be blank.').notEmpty()
  errors = req.validationErrors()
  if errors
    req.flash 'errors', errors
    return res.redirect('/api/twilio')
  message = 
    to: req.body.number
    from: '+13472235148'
    body: req.body.message
  twilio.sendMessage message, (err, responseData) ->
    if err
      return next(err.message)
    req.flash 'success', msg: 'Text sent to ' + responseData.to + '.'
    res.redirect '/api/twilio'
    return
  return

###*
# GET /api/clockwork
# Clockwork SMS API example.
###

exports.getClockwork = (req, res) ->
  res.render 'api/clockwork', title: 'Clockwork SMS API'
  return

###*
# POST /api/clockwork
# Send a text message using Clockwork SMS
###

exports.postClockwork = (req, res, next) ->
  message = 
    To: req.body.telephone
    From: 'Hackathon'
    Content: 'Hello from the Hackathon Starter'
  clockwork.sendSms message, (err, responseData) ->
    if err
      return next(err.errDesc)
    req.flash 'success', msg: 'Text sent to ' + responseData.responses[0].to
    res.redirect '/api/clockwork'
    return
  return

###*
# GET /api/venmo
# Venmo API example.
###

exports.getVenmo = (req, res, next) ->
  token = _.find(req.user.tokens, kind: 'venmo')
  query = querystring.stringify(access_token: token.accessToken)
  async.parallel {
    getProfile: (done) ->
      request.get {
        url: 'https://api.venmo.com/v1/me?' + query
        json: true
      }, (err, request, body) ->
        done err, body
        return
      return
    getRecentPayments: (done) ->
      request.get {
        url: 'https://api.venmo.com/v1/payments?' + query
        json: true
      }, (err, request, body) ->
        done err, body
        return
      return

  }, (err, results) ->
    if err
      return next(err)
    res.render 'api/venmo',
      title: 'Venmo API'
      profile: results.getProfile.data
      recentPayments: results.getRecentPayments.data
    return
  return

###*
# POST /api/venmo
# Send money.
###

exports.postVenmo = (req, res, next) ->
  req.assert('user', 'Phone, Email or Venmo User ID cannot be blank').notEmpty()
  req.assert('note', 'Please enter a message to accompany the payment').notEmpty()
  req.assert('amount', 'The amount you want to pay cannot be blank').notEmpty()
  errors = req.validationErrors()
  if errors
    req.flash 'errors', errors
    return res.redirect('/api/venmo')
  token = _.find(req.user.tokens, kind: 'venmo')
  formData = 
    access_token: token.accessToken
    note: req.body.note
    amount: req.body.amount
  if validator.isEmail(req.body.user)
    formData.email = req.body.user
  else if validator.isNumeric(req.body.user) and validator.isLength(req.body.user, 10, 11)
    formData.phone = req.body.user
  else
    formData.user_id = req.body.user
  request.post 'https://api.venmo.com/v1/payments', { form: formData }, (err, request, body) ->
    if err
      return next(err)
    if request.statusCode != 200
      req.flash 'errors', msg: JSON.parse(body).error.message
      return res.redirect('/api/venmo')
    req.flash 'success', msg: 'Venmo money transfer complete'
    res.redirect '/api/venmo'
    return
  return

###*
# GET /api/linkedin
# LinkedIn API example.
###

exports.getLinkedin = (req, res, next) ->
  token = _.find(req.user.tokens, kind: 'linkedin')
  linkedin = Linkedin.init(token.accessToken)
  linkedin.people.me (err, $in) ->
    if err
      return next(err)
    res.render 'api/linkedin',
      title: 'LinkedIn API'
      profile: $in
    return
  return

###*
# GET /api/instagram
# Instagram API example.
###

exports.getInstagram = (req, res, next) ->
  token = _.find(req.user.tokens, kind: 'instagram')
  ig.use
    client_id: secrets.instagram.clientID
    client_secret: secrets.instagram.clientSecret
  ig.use access_token: token.accessToken
  async.parallel {
    searchByUsername: (done) ->
      ig.user_search 'richellemead', (err, users, limit) ->
        done err, users
        return
      return
    searchByUserId: (done) ->
      ig.user '175948269', (err, user) ->
        done err, user
        return
      return
    popularImages: (done) ->
      ig.media_popular (err, medias) ->
        done err, medias
        return
      return
    myRecentMedia: (done) ->
      ig.user_self_media_recent (err, medias, pagination, limit) ->
        done err, medias
        return
      return

  }, (err, results) ->
    if err
      return next(err)
    res.render 'api/instagram',
      title: 'Instagram API'
      usernames: results.searchByUsername
      userById: results.searchByUserId
      popularImages: results.popularImages
      myRecentMedia: results.myRecentMedia
    return
  return

###*
# GET /api/yahoo
# Yahoo API example.
###

exports.getYahoo = (req, res) ->
  Y.YQL 'SELECT * FROM weather.forecast WHERE (location = 10007)', (response) ->
    location = response.query.results.channel.location
    condition = response.query.results.channel.item.condition
    res.render 'api/yahoo',
      title: 'Yahoo API'
      location: location
      condition: condition
    return
  return

###*
# GET /api/paypal
# PayPal SDK example.
###

exports.getPayPal = (req, res, next) ->
  paypal.configure
    mode: 'sandbox'
    client_id: secrets.paypal.client_id
    client_secret: secrets.paypal.client_secret
  paymentDetails = 
    intent: 'sale'
    payer: payment_method: 'paypal'
    redirect_urls:
      return_url: secrets.paypal.returnUrl
      cancel_url: secrets.paypal.cancelUrl
    transactions: [ {
      description: 'Hackathon Starter'
      amount:
        currency: 'USD'
        total: '1.99'
    } ]
  paypal.payment.create paymentDetails, (err, payment) ->
    if err
      return next(err)
    req.session.paymentId = payment.id
    links = payment.links
    i = 0
    while i < links.length
      if links[i].rel == 'approval_url'
        res.render 'api/paypal', approvalUrl: links[i].href
      i++
    return
  return

###*
# GET /api/paypal/success
# PayPal SDK example.
###

exports.getPayPalSuccess = (req, res) ->
  paymentId = req.session.paymentId
  paymentDetails = payer_id: req.query.PayerID
  paypal.payment.execute paymentId, paymentDetails, (err) ->
    if err
      res.render 'api/paypal',
        result: true
        success: false
    else
      res.render 'api/paypal',
        result: true
        success: true
    return
  return

###*
# GET /api/paypal/cancel
# PayPal SDK example.
###

exports.getPayPalCancel = (req, res) ->
  req.session.paymentId = null
  res.render 'api/paypal',
    result: true
    canceled: true
  return

###*
# GET /api/lob
# Lob API example.
###

exports.getLob = (req, res, next) ->
  lob.routes.list { zip_codes: [ '10007' ] }, (err, routes) ->
    if err
      return next(err)
    res.render 'api/lob',
      title: 'Lob API'
      routes: routes.data[0].routes
    return
  return

###*
# GET /api/bitgo
# BitGo wallet example
###

exports.getBitGo = (req, res, next) ->
  bitgo = new (BitGo.BitGo)(
    env: 'test'
    accessToken: secrets.bitgo.accessToken)
  walletId = req.session.walletId
  # we use the session to store the walletid, but you should store it elsewhere

  renderWalletInfo = (walletId) ->
    bitgo.wallets().get { id: walletId }, (err, walletRes) ->
      walletRes.createAddress {}, (err, addressRes) ->
        walletRes.transactions {}, (err, transactionsRes) ->
          res.render 'api/bitgo',
            title: 'BitGo API'
            wallet: walletRes.wallet
            address: addressRes.address
            transactions: transactionsRes.transactions
          return
        return
      return
    return

  if walletId
    # wallet was created in the session already, just load it up
    renderWalletInfo walletId
  else
    bitgo.wallets().createWalletWithKeychains {
      passphrase: req.sessionID
      label: 'wallet for session ' + req.sessionID
      backupXpub: 'xpub6AHA9hZDN11k2ijHMeS5QqHx2KP9aMBRhTDqANMnwVtdyw2TDYRmF8PjpvwUFcL1Et8Hj59S3gTSMcUQ5gAqTz3Wd8EsMTmF3DChhqPQBnU'
    }, (err, res) ->
      req.session.walletId = res.wallet.wallet.id
      renderWalletInfo req.session.walletId
      return
  return

###*
# POST /api/bitgo
# BitGo send coins example
###

exports.postBitGo = (req, res, next) ->
  bitgo = new (BitGo.BitGo)(
    env: 'test'
    accessToken: secrets.bitgo.accessToken)
  walletId = req.session.walletId
  # we use the session to store the walletid, but you should store it elsewhere
  amount = parseInt(req.body.amount)
  try
    bitgo.wallets().get { id: walletId }, (err, wallet) ->
      wallet.sendCoins {
        address: req.body.address
        amount: parseInt(req.body.amount)
        walletPassphrase: req.sessionID
      }, (e, result) ->
        if e
          console.dir e
          req.flash 'errors', msg: e.message
          return res.redirect('/api/bitgo')
        req.flash 'info', msg: 'txid: ' + result.hash + ', hex: ' + result.tx
        res.redirect '/api/bitgo'
      return
  catch e
    req.flash 'errors', msg: e.message
    return res.redirect('/api/bitgo')
  return
