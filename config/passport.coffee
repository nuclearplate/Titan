_ = require('lodash')
passport = require('passport')
InstagramStrategy = require('passport-instagram').Strategy
LocalStrategy = require('passport-local').Strategy
FacebookStrategy = require('passport-facebook').Strategy
TwitterStrategy = require('passport-twitter').Strategy
GitHubStrategy = require('passport-github').Strategy
GoogleStrategy = require('passport-google-oauth').OAuth2Strategy
LinkedInStrategy = require('passport-linkedin-oauth2').Strategy
OAuthStrategy = require('passport-oauth').OAuthStrategy
OAuth2Strategy = require('passport-oauth').OAuth2Strategy
secrets = require('./secrets')
User = require '../models/user'
passport.serializeUser (user, done) ->
  done null, user.id
  return
passport.deserializeUser (id, done) ->
  User.findById id, (err, user) ->
    done err, user
    return
  return

###*
# Sign in with Instagram.
###

passport.use new InstagramStrategy(secrets.instagram, (req, accessToken, refreshToken, profile, done) ->
  if req.user
    User.findOne { instagram: profile.id }, (err, existingUser) ->
      if existingUser
        req.flash 'errors', msg: 'There is already an Instagram account that belongs to you. Sign in with that account or delete it, then link it with your current account.'
        done err
      else
        User.findById req.user.id, (err, user) ->
          user.instagram = profile.id
          user.tokens.push
            kind: 'instagram'
            accessToken: accessToken
          user.profile.name = user.profile.name or profile.displayName
          user.profile.picture = user.profile.picture or profile._json.data.profile_picture
          user.profile.website = user.profile.website or profile._json.data.website
          user.save (err) ->
            req.flash 'info', msg: 'Instagram account has been linked.'
            done err, user
            return
          return
      return
  else
    User.findOne { instagram: profile.id }, (err, existingUser) ->
      if existingUser
        return done(null, existingUser)
      user = new User
      user.instagram = profile.id
      user.tokens.push
        kind: 'instagram'
        accessToken: accessToken
      user.profile.name = profile.displayName
      # Similar to Twitter API, assigns a temporary e-mail address
      # to get on with the registration process. It can be changed later
      # to a valid e-mail address in Profile Management.
      user.email = profile.username + '@instagram.com'
      user.profile.website = profile._json.data.website
      user.profile.picture = profile._json.data.profile_picture
      user.save (err) ->
        done err, user
        return
      return
  return
)

###*
# Sign in using Email and Password.
###

passport.use new LocalStrategy({ usernameField: 'email' }, (email, password, done) ->
  email = email.toLowerCase()
  User.findOne { email: email }, (err, user) ->
    if !user
      return done(null, false, message: 'Email ' + email + ' not found')
    user.comparePassword password, (err, isMatch) ->
      if isMatch
        done null, user
      else
        done null, false, message: 'Invalid email or password.'
    return
  return
)

###*
# OAuth Strategy Overview
#
# - User is already logged in.
#   - Check if there is an existing account with a provider id.
#     - If there is, return an error message. (Account merging not supported)
#     - Else link new OAuth account with currently logged-in user.
# - User is not logged in.
#   - Check if it's a returning user.
#     - If returning user, sign in and we are done.
#     - Else check if there is an existing account with user's email.
#       - If there is, return an error message.
#       - Else create a new account.
###

###*
# Sign in with Facebook.
###

passport.use new FacebookStrategy(secrets.facebook, (req, accessToken, refreshToken, profile, done) ->
  if req.user
    User.findOne { facebook: profile.id }, (err, existingUser) ->
      if existingUser
        req.flash 'errors', msg: 'There is already a Facebook account that belongs to you. Sign in with that account or delete it, then link it with your current account.'
        done err
      else
        User.findById req.user.id, (err, user) ->
          user.facebook = profile.id
          user.tokens.push
            kind: 'facebook'
            accessToken: accessToken
          user.profile.name = user.profile.name or profile.displayName
          user.profile.gender = user.profile.gender or profile._json.gender
          user.profile.picture = user.profile.picture or 'https://graph.facebook.com/' + profile.id + '/picture?type=large'
          user.save (err) ->
            req.flash 'info', msg: 'Facebook account has been linked.'
            done err, user
            return
          return
      return
  else
    User.findOne { facebook: profile.id }, (err, existingUser) ->
      if existingUser
        return done(null, existingUser)
      User.findOne { email: profile._json.email }, (err, existingEmailUser) ->
        if existingEmailUser
          req.flash 'errors', msg: 'There is already an account using this email address. Sign in to that account and link it with Facebook manually from Account Settings.'
          done err
        else
          user = new User
          user.email = profile._json.email
          user.facebook = profile.id
          user.tokens.push
            kind: 'facebook'
            accessToken: accessToken
          user.profile.name = profile.displayName
          user.profile.gender = profile._json.gender
          user.profile.picture = 'https://graph.facebook.com/' + profile.id + '/picture?type=large'
          user.profile.location = if profile._json.location then profile._json.location.name else ''
          user.save (err) ->
            done err, user
            return
        return
      return
  return
)

###*
# Sign in with GitHub.
###

passport.use new GitHubStrategy(secrets.github, (req, accessToken, refreshToken, profile, done) ->
  if req.user
    User.findOne { github: profile.id }, (err, existingUser) ->
      if existingUser
        req.flash 'errors', msg: 'There is already a GitHub account that belongs to you. Sign in with that account or delete it, then link it with your current account.'
        done err
      else
        User.findById req.user.id, (err, user) ->
          user.github = profile.id
          user.username = user.username or profile._json.login
          user.tokens.push
            kind: 'github'
            accessToken: accessToken
          user.profile.name = user.profile.name or profile.displayName
          user.profile.picture = user.profile.picture or profile._json.avatar_url
          user.profile.location = user.profile.location or profile._json.location
          user.profile.website = user.profile.website or profile._json.blog
          user.save (err) ->
            req.flash 'info', msg: 'GitHub account has been linked.'
            done err, user
            return
          return
      return
  else
    User.findOne { github: profile.id }, (err, existingUser) ->
      if existingUser
        return done(null, existingUser)
      User.findOne { email: profile._json.email }, (err, existingEmailUser) ->
        if existingEmailUser
          req.flash 'errors', msg: 'There is already an account using this email address. Sign in to that account and link it with GitHub manually from Account Settings.'
          done err
        else
          user = new User
          user.email = profile._json.email
          user.github = profile.id
          user.username = profile._json.login
          user.tokens.push
            kind: 'github'
            accessToken: accessToken
          user.profile.name = profile.displayName
          user.profile.picture = profile._json.avatar_url
          user.profile.location = profile._json.location
          user.profile.website = profile._json.blog
          user.save (err) ->
            done err, user
            return
        return
      return
  return
)
# Sign in with Twitter.
passport.use new TwitterStrategy(secrets.twitter, (req, accessToken, tokenSecret, profile, done) ->
  if req.user
    User.findOne { twitter: profile.id }, (err, existingUser) ->
      if existingUser
        req.flash 'errors', msg: 'There is already a Twitter account that belongs to you. Sign in with that account or delete it, then link it with your current account.'
        done err
      else
        User.findById req.user.id, (err, user) ->
          user.twitter = profile.id
          user.tokens.push
            kind: 'twitter'
            accessToken: accessToken
            tokenSecret: tokenSecret
          user.profile.name = user.profile.name or profile.displayName
          user.profile.location = user.profile.location or profile._json.location
          user.profile.picture = user.profile.picture or profile._json.profile_image_url_https
          user.save (err) ->
            req.flash 'info', msg: 'Twitter account has been linked.'
            done err, user
            return
          return
      return
  else
    User.findOne { twitter: profile.id }, (err, existingUser) ->
      if existingUser
        return done(null, existingUser)
      user = new User
      # Twitter will not provide an email address.  Period.
      # But a person’s twitter username is guaranteed to be unique
      # so we can "fake" a twitter email address as follows:
      user.email = profile.username + '@twitter.com'
      user.twitter = profile.id
      user.tokens.push
        kind: 'twitter'
        accessToken: accessToken
        tokenSecret: tokenSecret
      user.profile.name = profile.displayName
      user.profile.location = profile._json.location
      user.profile.picture = profile._json.profile_image_url_https
      user.save (err) ->
        done err, user
        return
      return
  return
)

###*
# Sign in with Google.
###

passport.use new GoogleStrategy(secrets.google, (req, accessToken, refreshToken, profile, done) ->
  if req.user
    User.findOne { google: profile.id }, (err, existingUser) ->
      if existingUser
        req.flash 'errors', msg: 'There is already a Google account that belongs to you. Sign in with that account or delete it, then link it with your current account.'
        done err
      else
        User.findById req.user.id, (err, user) ->
          user.google = profile.id
          user.tokens.push
            kind: 'google'
            accessToken: accessToken
          user.profile.name = user.profile.name or profile.displayName
          user.profile.gender = user.profile.gender or profile._json.gender
          user.profile.picture = user.profile.picture or profile._json.picture
          user.save (err) ->
            req.flash 'info', msg: 'Google account has been linked.'
            done err, user
            return
          return
      return
  else
    User.findOne { google: profile.id }, (err, existingUser) ->
      if existingUser
        return done(null, existingUser)
      User.findOne { email: profile.emails[0].value }, (err, existingEmailUser) ->
        if existingEmailUser
          req.flash 'errors', msg: 'There is already an account using this email address. Sign in to that account and link it with Google manually from Account Settings.'
          done err
        else
          user = new User
          user.email = profile.emails[0].value
          user.google = profile.id
          user.tokens.push
            kind: 'google'
            accessToken: accessToken
          user.profile.name = profile.displayName
          user.profile.gender = profile._json.gender
          user.profile.picture = profile._json.picture
          user.save (err) ->
            done err, user
            return
        return
      return
  return
)

###*
# Sign in with LinkedIn.
###

passport.use new LinkedInStrategy(secrets.linkedin, (req, accessToken, refreshToken, profile, done) ->
  if req.user
    User.findOne { linkedin: profile.id }, (err, existingUser) ->
      if existingUser
        req.flash 'errors', msg: 'There is already a LinkedIn account that belongs to you. Sign in with that account or delete it, then link it with your current account.'
        done err
      else
        User.findById req.user.id, (err, user) ->
          user.linkedin = profile.id
          user.tokens.push
            kind: 'linkedin'
            accessToken: accessToken
          user.profile.name = user.profile.name or profile.displayName
          user.profile.location = user.profile.location or profile._json.location.name
          user.profile.picture = user.profile.picture or profile._json.pictureUrl
          user.profile.website = user.profile.website or profile._json.publicProfileUrl
          user.save (err) ->
            req.flash 'info', msg: 'LinkedIn account has been linked.'
            done err, user
            return
          return
      return
  else
    User.findOne { linkedin: profile.id }, (err, existingUser) ->
      if existingUser
        return done(null, existingUser)
      User.findOne { email: profile._json.emailAddress }, (err, existingEmailUser) ->
        if existingEmailUser
          req.flash 'errors', msg: 'There is already an account using this email address. Sign in to that account and link it with LinkedIn manually from Account Settings.'
          done err
        else
          user = new User
          user.linkedin = profile.id
          user.tokens.push
            kind: 'linkedin'
            accessToken: accessToken
          user.email = profile._json.emailAddress
          user.profile.name = profile.displayName
          user.profile.location = profile._json.location.name
          user.profile.picture = profile._json.pictureUrl
          user.profile.website = profile._json.publicProfileUrl
          user.save (err) ->
            done err, user
            return
        return
      return
  return
)

###*
# Tumblr API OAuth.
###

passport.use 'tumblr', new OAuthStrategy({
  requestTokenURL: 'http://www.tumblr.com/oauth/request_token'
  accessTokenURL: 'http://www.tumblr.com/oauth/access_token'
  userAuthorizationURL: 'http://www.tumblr.com/oauth/authorize'
  consumerKey: secrets.tumblr.consumerKey
  consumerSecret: secrets.tumblr.consumerSecret
  callbackURL: secrets.tumblr.callbackURL
  passReqToCallback: true
}, (req, token, tokenSecret, profile, done) ->
  User.findById req.user._id, (err, user) ->
    user.tokens.push
      kind: 'tumblr'
      accessToken: token
      tokenSecret: tokenSecret
    user.save (err) ->
      done err, user
      return
    return
  return
)

###*
# Foursquare API OAuth.
###

passport.use 'foursquare', new OAuth2Strategy({
  authorizationURL: 'https://foursquare.com/oauth2/authorize'
  tokenURL: 'https://foursquare.com/oauth2/access_token'
  clientID: secrets.foursquare.clientId
  clientSecret: secrets.foursquare.clientSecret
  callbackURL: secrets.foursquare.redirectUrl
  passReqToCallback: true
}, (req, accessToken, refreshToken, profile, done) ->
  User.findById req.user._id, (err, user) ->
    user.tokens.push
      kind: 'foursquare'
      accessToken: accessToken
    user.save (err) ->
      done err, user
      return
    return
  return
)

###*
# Venmo API OAuth.
###

passport.use 'venmo', new OAuth2Strategy({
  authorizationURL: 'https://api.venmo.com/v1/oauth/authorize'
  tokenURL: 'https://api.venmo.com/v1/oauth/access_token'
  clientID: secrets.venmo.clientId
  clientSecret: secrets.venmo.clientSecret
  callbackURL: secrets.venmo.redirectUrl
  passReqToCallback: true
}, (req, accessToken, refreshToken, profile, done) ->
  User.findById req.user._id, (err, user) ->
    user.tokens.push
      kind: 'venmo'
      accessToken: accessToken
    user.save (err) ->
      done err, user
      return
    return
  return
)

###*
# Login Required middleware.
###

exports.isAuthenticated = (req, res, next) ->
  if req.isAuthenticated()
    return next()
  res.redirect '/login'
  return

###*
# Authorization Required middleware.
###

exports.isAuthorized = (req, res, next) ->
  provider = req.path.split('/').slice(-1)[0]
  if _.find(req.user.tokens, kind: provider)
    next()
  else
    res.redirect '/auth/' + provider
  return
