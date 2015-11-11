_ = require 'lodash'
async = require 'async'
crypto = require 'crypto'
nodemailer = require 'nodemailer'
passport = require 'passport'
User = require '../models/user'
Stream = require '../models/stream'
DataType = require '../models/data_type'
secrets = require '../config/secrets'

exports.getAll = (req, res) ->
  User.find({}).then((err, users) ->
    res.json arguments
    return
  ).catch (err) ->
    throw new Error(err)
    return
  return

exports.getStream = (req, res) ->
  res.json ok: true
  return

exports.getStreams = (req, res) ->
  query = user: req.user.username
  Stream.find(query).then (streams) ->
    res.json streams
    return
  return

exports.getDataTypes = (req, res) ->
  query = user: req.user.username
  DataType.find(query).then (types) ->
    res.json types
    return
  return

###*
# GET /login
# Login page.
###

exports.getLogin = (req, res) ->
  if req.user
    return res.redirect('/')
  res.render 'account/login', title: 'Login'
  return

###*
# POST /login
# Sign in using email and password.
###

exports.postLogin = (req, res, next) ->
  req.assert('email', 'Email is not valid').isEmail()
  req.assert('password', 'Password cannot be blank').notEmpty()
  errors = req.validationErrors()
  if errors
    req.flash 'errors', errors
    return res.redirect('/login')
  passport.authenticate('local', (err, user, info) ->
    if err
      return next(err)
    if !user
      req.flash 'errors', msg: info.message
      return res.redirect('/login')
    req.logIn user, (err) ->
      if err
        return next(err)
      req.flash 'success', msg: 'Success! You are logged in.'
      res.redirect req.session.returnTo or '/'
      return
    return
  ) req, res, next
  return

###*
# GET /logout
# Log out.
###

exports.logout = (req, res) ->
  req.logout()
  res.redirect '/'
  return

###*
# GET /signup
# Signup page.
###

exports.getSignup = (req, res) ->
  if req.user
    return res.redirect('/')
  res.render 'account/signup', title: 'Create Account'
  return

###*
# POST /signup
# Create a new local account.
###

exports.postSignup = (req, res, next) ->
  req.assert('email', 'Email is not valid').isEmail()
  req.assert('password', 'Password must be at least 4 characters long').len 4
  req.assert('confirmPassword', 'Passwords do not match').equals req.body.password
  errors = req.validationErrors()
  if errors
    req.flash 'errors', errors
    return res.redirect('/signup')
  user = new User(
    email: req.body.email
    password: req.body.password)
  User.findOne { email: req.body.email }, (err, existingUser) ->
    if existingUser
      req.flash 'errors', msg: 'Account with that email address already exists.'
      return res.redirect('/signup')
    user.save (err) ->
      if err
        return next(err)
      req.logIn user, (err) ->
        if err
          return next(err)
        res.redirect '/'
        return
      return
    return
  return

###*
# GET /account
# Profile page.
###

exports.getAccount = (req, res) ->
  res.render 'account/profile', title: 'Account Management'
  return

###*
# POST /account/profile
# Update profile information.
###

exports.postUpdateProfile = (req, res, next) ->
  User.findById req.user.id, (err, user) ->
    if err
      return next(err)
    user.email = req.body.email or ''
    user.profile.name = req.body.name or ''
    user.profile.gender = req.body.gender or ''
    user.profile.location = req.body.location or ''
    user.profile.website = req.body.website or ''
    user.save (err) ->
      if err
        return next(err)
      req.flash 'success', msg: 'Profile information updated.'
      res.redirect '/account'
      return
    return
  return

###*
# POST /account/password
# Update current password.
###

exports.postUpdatePassword = (req, res, next) ->
  req.assert('password', 'Password must be at least 4 characters long').len 4
  req.assert('confirmPassword', 'Passwords do not match').equals req.body.password
  errors = req.validationErrors()
  if errors
    req.flash 'errors', errors
    return res.redirect('/account')
  User.findById req.user.id, (err, user) ->
    if err
      return next(err)
    user.password = req.body.password
    user.save (err) ->
      if err
        return next(err)
      req.flash 'success', msg: 'Password has been changed.'
      res.redirect '/account'
      return
    return
  return

###*
# POST /account/delete
# Delete user account.
###

exports.postDeleteAccount = (req, res, next) ->
  User.remove { _id: req.user.id }, (err) ->
    if err
      return next(err)
    req.logout()
    req.flash 'info', msg: 'Your account has been deleted.'
    res.redirect '/'
    return
  return

###*
# GET /account/unlink/:provider
# Unlink OAuth provider.
###

exports.getOauthUnlink = (req, res, next) ->
  provider = req.params.provider
  User.findById req.user.id, (err, user) ->
    if err
      return next(err)
    user[provider] = undefined
    user.tokens = _.reject(user.tokens, (token) ->
      token.kind == provider
    )
    user.save (err) ->
      if err
        return next(err)
      req.flash 'info', msg: provider + ' account has been unlinked.'
      res.redirect '/account'
      return
    return
  return

###*
# GET /reset/:token
# Reset Password page.
###

exports.getReset = (req, res) ->
  if req.isAuthenticated()
    return res.redirect('/')
  User.findOne(resetPasswordToken: req.params.token).where('resetPasswordExpires').gt(Date.now()).exec (err, user) ->
    if !user
      req.flash 'errors', msg: 'Password reset token is invalid or has expired.'
      return res.redirect('/forgot')
    res.render 'account/reset', title: 'Password Reset'
    return
  return

###*
# POST /reset/:token
# Process the reset password request.
###

exports.postReset = (req, res, next) ->
  req.assert('password', 'Password must be at least 4 characters long.').len 4
  req.assert('confirm', 'Passwords must match.').equals req.body.password
  errors = req.validationErrors()
  if errors
    req.flash 'errors', errors
    return res.redirect('back')
  async.waterfall [
    (done) ->
      User.findOne(resetPasswordToken: req.params.token).where('resetPasswordExpires').gt(Date.now()).exec (err, user) ->
        if !user
          req.flash 'errors', msg: 'Password reset token is invalid or has expired.'
          return res.redirect('back')
        user.password = req.body.password
        user.resetPasswordToken = undefined
        user.resetPasswordExpires = undefined
        user.save (err) ->
          if err
            return next(err)
          req.logIn user, (err) ->
            done err, user
            return
          return
        return
      return
    (user, done) ->
      transporter = nodemailer.createTransport(
        service: 'SendGrid'
        auth:
          user: secrets.sendgrid.user
          pass: secrets.sendgrid.password)
      mailOptions = 
        to: user.email
        from: 'hackathon@starter.com'
        subject: 'Your Hackathon Starter password has been changed'
        text: 'Hello,\n\n' + 'This is a confirmation that the password for your account ' + user.email + ' has just been changed.\n'
      transporter.sendMail mailOptions, (err) ->
        req.flash 'success', msg: 'Success! Your password has been changed.'
        done err
        return
      return
  ], (err) ->
    if err
      return next(err)
    res.redirect '/'
    return
  return

###*
# GET /forgot
# Forgot Password page.
###

exports.getForgot = (req, res) ->
  if req.isAuthenticated()
    return res.redirect('/')
  res.render 'account/forgot', title: 'Forgot Password'
  return

###*
# POST /forgot
# Create a random token, then the send user an email with a reset link.
###

exports.postForgot = (req, res, next) ->
  req.assert('email', 'Please enter a valid email address.').isEmail()
  errors = req.validationErrors()
  if errors
    req.flash 'errors', errors
    return res.redirect('/forgot')
  async.waterfall [
    (done) ->
      crypto.randomBytes 16, (err, buf) ->
        token = buf.toString('hex')
        done err, token
        return
      return
    (token, done) ->
      User.findOne { email: req.body.email.toLowerCase() }, (err, user) ->
        if !user
          req.flash 'errors', msg: 'No account with that email address exists.'
          return res.redirect('/forgot')
        user.resetPasswordToken = token
        user.resetPasswordExpires = Date.now() + 3600000
        # 1 hour
        user.save (err) ->
          done err, token, user
          return
        return
      return
    (token, user, done) ->
      transporter = nodemailer.createTransport(
        service: 'SendGrid'
        auth:
          user: secrets.sendgrid.user
          pass: secrets.sendgrid.password)
      mailOptions = 
        to: user.email
        from: 'hackathon@starter.com'
        subject: 'Reset your password on Hackathon Starter'
        text: 'You are receiving this email because you (or someone else) have requested the reset of the password for your account.\n\n' + 'Please click on the following link, or paste this into your browser to complete the process:\n\n' + 'http://' + req.headers.host + '/reset/' + token + '\n\n' + 'If you did not request this, please ignore this email and your password will remain unchanged.\n'
      transporter.sendMail mailOptions, (err) ->
        req.flash 'info', msg: 'An e-mail has been sent to ' + user.email + ' with further instructions.'
        done err, 'done'
        return
      return
  ], (err) ->
    if err
      return next(err)
    res.redirect '/forgot'
    return
  return