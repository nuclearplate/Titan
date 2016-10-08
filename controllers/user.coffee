_ = require 'lodash'
async = require 'async'
crypto = require 'crypto'
nodemailer = require 'nodemailer'
passport = require 'passport'
User = require '../models/user'
Stream = require '../models/stream'
DataType = require '../models/data_type'
secrets = require '../config/secrets'

class UserController
  constructor: (@api) ->

  getAll: (req, res) ->
    User.find({}).then (err, users) ->
      res.json arguments
    .catch (err) ->
      throw new Error err

  getStream: (req, res) ->
    res.json ok: true

  getStreams: (req, res) ->
    query =
      user: req.user.username

    Stream.find(query).then (streams) ->
      res.json streams

  getDataTypes: (req, res) ->
    query =
      user: req.user.username

    DataType.find(query).then (types) ->
      res.json types

  getUser: (req, res) ->
    res.json
      username: req.user?.username

  getGithubOrgs: (req, res) =>
    if req.user.githubOrgs
      res.json req.user.githubOrgs
    else
      @api.userOrgs req.user, (orgs) ->
        query =
          _id: req.user._id

        update =
          $set:
            githubOrgs: orgs

        User.update query, update, {upsert: false}, (err, results) ->
          console.log "UPDATED", query, update, err, results
          res.json orgs

  ###*
  # POST /login
  # Sign in using email and password.
  ###

  postLogin: (req, res, next) ->
    req.assert('email', 'Email is not valid').isEmail()
    req.assert('password', 'Password cannot be blank').notEmpty()
    errors = req.validationErrors()
    
    if errors
      req.flash 'errors', errors
      res.redirect('/login')
    else
      passport.authenticate 'local', (err, user, info) ->
        if err
          return next(err)
        
        if user
          req.logIn user, (err) ->
            if err
              next(err)
            else
              req.flash 'success', msg: 'Success! You are logged in.'
              res.redirect req.session.returnTo or '/'
        else
          req.flash 'errors', msg: info.message
          res.redirect('/login')

  ###*
  # GET /logout
  # Log out.
  ###

  logout: (req, res) ->
    req.logout()
    res.redirect '/'

  ###*
  # GET /signup
  # Signup page.
  ###

  getSignup: (req, res) ->
    if req.user
      res.redirect('/')
    else
      res.render 'account/signup', title: 'Create Account'

  ###*
  # POST /signup
  # Create a new local account.
  ###

  postSignup: (req, res, next) ->
    req.assert('email', 'Email is not valid').isEmail()
    req.assert('password', 'Password must be at least 4 characters long').len 4
    req.assert('confirmPassword', 'Passwords do not match').equals req.body.password
    
    errors = req.validationErrors()

    if errors
      req.flash 'errors', errors
      return res.redirect('/signup')

    user = new User
      email: req.body.email
      password: req.body.password
    
    query =
      email: req.body.email

    User.findOne query, (err, existingUser) ->
      if existingUser
        req.flash 'errors', msg: 'Account with that email address already exists.'
        res.redirect '/signup'
      else
        user.save (err) ->
          if err
            return next err
          
          req.logIn user, (err) ->
            if err
              next err
            else
              res.redirect '/'

  ###*
  # GET /account
  # Profile page.
  ###

  getAccount: (req, res) ->
    res.render 'account/profile', title: 'Account Management'

  ###*
  # POST /account/profile
  # Update profile information.
  ###

  postUpdateProfile: (req, res, next) ->
    User.findById req.user.id, (err, user) ->
      if err
        return next(err)

      user.email = req.body.email or ''
      user.profile.name = req.body.name or ''
      user.profile.gender = req.body.gender or ''
      user.profile.website = req.body.website or ''
      user.profile.location = req.body.location or ''
      
      user.save (err) ->
        if err
          return next(err)

        req.flash 'success', msg: 'Profile information updated.'
        res.redirect '/account'

  ###*
  # POST /account/password
  # Update current password.
  ###

  postUpdatePassword: (req, res, next) ->
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

  ###*
  # POST /account/delete
  # Delete user account.
  ###

  postDeleteAccount: (req, res, next) ->
    query =
      _id: req.user.id

    User.remove query, (err) ->
      if err
        return next(err)

      req.logout()
      req.flash 'info', msg: 'Your account has been deleted.'
      res.redirect '/'

  ###*
  # GET /account/unlink/:provider
  # Unlink OAuth provider.
  ###

  getOauthUnlink: (req, res, next) ->
    provider = req.params.provider
    
    User.findById req.user.id, (err, user) ->
      if err
        return next(err)
      
      user[provider] = undefined
      user.tokens = _.reject user.tokens, (token) ->
        token.kind == provider
      
      user.save (err) ->
        if err
          return next(err)

        req.flash 'info', msg: provider + ' account has been unlinked.'
        res.redirect '/account'

  ###*
  # GET /reset/:token
  # Reset Password page.
  ###

  getReset: (req, res) ->
    if req.isAuthenticated()
      return res.redirect('/')

    User.findOne(resetPasswordToken: req.params.token).where('resetPasswordExpires').gt(Date.now()).exec (err, user) ->
      if !user
        req.flash 'errors', msg: 'Password reset token is invalid or has expired.'
        return res.redirect('/forgot')

      res.render 'account/reset', title: 'Password Reset'

  ###*
  # POST /reset/:token
  # Process the reset password request.
  ###

  postReset: (req, res, next) ->
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

    ], (err) ->
      if err
        return next(err)
      res.redirect '/'

  ###*
  # GET /forgot
  # Forgot Password page.
  ###

  getForgot: (req, res) ->
    if req.isAuthenticated()
      return res.redirect('/')
    res.render 'account/forgot', title: 'Forgot Password'

  ###*
  # POST /forgot
  # Create a random token, then the send user an email with a reset link.
  ###

  postForgot: (req, res, next) ->
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
    ], (err) ->
      if err
        return next(err)
      res.redirect '/forgot'

module.exports = UserController