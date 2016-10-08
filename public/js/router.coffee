async = require 'async'

User = require './models/user'

BooksRouter = require './views/books/router'

LoginView = require './views/login'
CreateView = require './views/create'
LayoutView = require './views/layout'
WelcomeView = require './views/welcome'

Router = Backbone.Router.extend
  routes:
    '': 'welcome'
    'login': 'login'
    'books': 'books'
    'create': 'create'

  initialize: ->
    @user = new User

  models: {}

  beforeRender: (opts, callback) ->
    @user.fetch
      success: =>
        zeno.models.user = @user.toJSON()
        @loadSharedModels =>
          @setupPage callback
      
      error: (err) =>
        if opts.noAuth
          @setupPage callback
        else
          @navigate 'login', {trigger: true}

  loadSharedModels: (callback) ->
    fetchFns = []
    for name, model of @models
      closure = (name, model) ->
        fetchFns.push (done) ->
          model.fetch().then ->
            zeno.models[name] = model.toJSON()
            done()
          , (err) ->
            console.log "ERROR FETCHING MODEL #{name}", err
      closure name, model

    async.parallel fetchFns, (err, results) =>
      callback()

  login: ->
    @beforeRender {noAuth: true}, ->
      view = new LoginView
      $('.main-housing').html view.render().el

  setupPage: (callback) ->
    layout = new LayoutView
    $('.main-container').html layout.render().el
    callback()

  showView: (callback) ->
    layout = new LayoutView
    $('.main-container').html layout.render().el
    callback()

  welcome: ->
    @showView ->
      welcome = new WelcomeView
      $('.main-housing').html welcome.render().el

  create: ->
    @showView ->
      create = new CreateView
      $('.main-housing').html create.render().el

  books: ->
    @showView ->
      browse = new BooksView
      $('.main-housing').html browse.render().el

  books: ->
    @beforeRender {page: 'books'}, =>
      router = new BooksRouter 'books',
        parent: zeno.routers.main
        page: 'books'

module.exports = Router