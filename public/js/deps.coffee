async = require 'async'
scriptjs = require 'scriptjs'

require '../css/main.less'
require '../../node_modules/vis/dist/vis.css'

window.jQuery = require 'jquery'
window.$ = jQuery

window.Backgrid = require 'backgrid'

require 'jquery-steps/build/jquery.steps'
require 'backbone.subroute'
require 'jquery-jsonview'
require 'json-editor'
require 'bootstrap'

window.Backbone = require 'backbone'
window.Backbone.$ = jQuery

module.exports = (callback) ->
  async.eachSeries [
    'http://d1n0x3qji82z53.cloudfront.net/src-min-noconflict/ace.js'
    'http://d1n0x3qji82z53.cloudfront.net/src-min-noconflict/mode-coffee.js'
    'https://cdnjs.cloudflare.com/ajax/libs/mermaid/0.5.6/mermaid.js'
  ], (url, done) ->
    scriptjs url, ->
      done()
  , (err) ->
    if err then console.log "ERROR LOADING DEPS", err
    callback()