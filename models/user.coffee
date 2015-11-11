bcrypt = require 'bcrypt-nodejs'
crypto = require 'crypto'
mongoose = require 'mongoose'

userSchema = new mongoose.Schema
  email:
    type: String
    unique: true
    lowercase: true
  username: String
  password: String
  facebook: String
  twitter: String
  google: String
  github: String
  instagram: String
  linkedin: String
  tokens: Array
  profile:
    name:
      type: String
      default: ''
    gender:
      type: String
      default: ''
    location:
      type: String
      default: ''
    website:
      type: String
      default: ''
    picture:
      type: String
      default: ''
  resetPasswordToken: String
  resetPasswordExpires: Date

###*
# Password hash middleware.
###

userSchema.pre 'save', (next) ->
  user = this
  if !user.isModified('password')
    return next()
  bcrypt.genSalt 10, (err, salt) ->
    if err
      return next(err)
    bcrypt.hash user.password, salt, null, (err, hash) ->
      if err
        return next(err)
      user.password = hash
      next()

###*
# Helper method for validating user's password.
###

userSchema.methods.comparePassword = (candidatePassword, cb) ->
  bcrypt.compare candidatePassword, @password, (err, isMatch) ->
    if err
      return cb(err)
    cb null, isMatch

###*
# Helper method for getting user's gravatar.
###

userSchema.methods.gravatar = (size) ->
  if !size
    size = 200
  if !@email
    return 'https://gravatar.com/avatar/?s=' + size + '&d=retro'
  md5 = crypto.createHash('md5').update(@email).digest('hex')
  'https://gravatar.com/avatar/' + md5 + '?s=' + size + '&d=retro'

module.exports = mongoose.model 'User', userSchema
