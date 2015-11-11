###*
# IMPORTANT  IMPORTANT  IMPORTANT  IMPORTANT  IMPORTANT  IMPORTANT  IMPORTANT
#
# You should never commit this file to a public repository on GitHub!
# All public code on GitHub can be searched, that means anyone can see your
# uploaded secrets.js file.
#
# I did it for your convenience using "throw away" API keys and passwords so
# that all features could work out of the box.
#
# Use config vars (environment variables) below for production API keys
# and passwords. Each PaaS (e.g. Heroku, Nodejitsu, OpenShift, Azure) has a way
# for you to set it up from the dashboard.
#
# Another added benefit of this approach is that you can use two different
# sets of keys for local development and production mode without making any
# changes to the code.

# IMPORTANT  IMPORTANT  IMPORTANT  IMPORTANT  IMPORTANT  IMPORTANT  IMPORTANT
###

module.exports =
  db: process.env.MONGODB or process.env.MONGOLAB_URI or 'mongodb://localhost:27017/test'
  sessionSecret: process.env.SESSION_SECRET or 'Your Session Secret goes here'
  mailgun:
    user: process.env.MAILGUN_USER or 'postmaster@sandbox697fcddc09814c6b83718b9fd5d4e5dc.mailgun.org'
    password: process.env.MAILGUN_PASSWORD or '29eldds1uri6'
  mandrill:
    user: process.env.MANDRILL_USER or 'hackathonstarterdemo'
    password: process.env.MANDRILL_PASSWORD or 'E1K950_ydLR4mHw12a0ldA'
  sendgrid:
    user: process.env.SENDGRID_USER or 'hslogin'
    password: process.env.SENDGRID_PASSWORD or 'hspassword00'
  nyt: key: process.env.NYT_KEY or '9548be6f3a64163d23e1539f067fcabd:5:68537648'
  lastfm:
    api_key: process.env.LASTFM_KEY or 'c8c0ea1c4a6b199b3429722512fbd17f'
    secret: process.env.LASTFM_SECRET or 'is cb7857b8fba83f819ea46ca13681fe71'
  facebook:
    clientID: process.env.FACEBOOK_ID or '754220301289665'
    clientSecret: process.env.FACEBOOK_SECRET or '41860e58c256a3d7ad8267d3c1939a4a'
    callbackURL: '/auth/facebook/callback'
    passReqToCallback: true
  instagram:
    clientID: process.env.INSTAGRAM_ID or '9f5c39ab236a48e0aec354acb77eee9b'
    clientSecret: process.env.INSTAGRAM_SECRET or '5920619aafe842128673e793a1c40028'
    callbackURL: '/auth/instagram/callback'
    passReqToCallback: true
  github:
    clientID: process.env.GITHUB_ID or 'cb448b1d4f0c743a1e36'
    clientSecret: process.env.GITHUB_SECRET or '815aa4606f476444691c5f1c16b9c70da6714dc6'
    callbackURL: '/auth/github/callback'
    passReqToCallback: true
  twitter:
    consumerKey: process.env.TWITTER_KEY or '6NNBDyJ2TavL407A3lWxPFKBI'
    consumerSecret: process.env.TWITTER_SECRET or 'ZHaYyK3DQCqv49Z9ofsYdqiUgeoICyh6uoBgFfu7OeYC7wTQKa'
    callbackURL: '/auth/twitter/callback'
    passReqToCallback: true
  google:
    clientID: process.env.GOOGLE_ID or '828110519058.apps.googleusercontent.com'
    clientSecret: process.env.GOOGLE_SECRET or 'JdZsIaWhUFIchmC1a_IZzOHb'
    callbackURL: '/auth/google/callback'
    passReqToCallback: true
  linkedin:
    clientID: process.env.LINKEDIN_ID or '77chexmowru601'
    clientSecret: process.env.LINKEDIN_SECRET or 'szdC8lN2s2SuMSy8'
    callbackURL: process.env.LINKEDIN_CALLBACK_URL or 'http://localhost:3000/auth/linkedin/callback'
    scope: [
      'r_fullprofile'
      'r_emailaddress'
      'r_network'
    ]
    passReqToCallback: true
  steam: apiKey: process.env.STEAM_KEY or 'D1240DEF4D41D416FD291D0075B6ED3F'
  twilio:
    sid: process.env.TWILIO_SID or 'AC6f0edc4c47becc6d0a952536fc9a6025'
    token: process.env.TWILIO_TOKEN or 'a67170ff7afa2df3f4c7d97cd240d0f3'
  clockwork: apiKey: process.env.CLOCKWORK_KEY or '9ffb267f88df55762f74ba2f517a66dc8bedac5a'
  stripe:
    secretKey: process.env.STRIPE_SKEY or 'sk_test_BQokikJOvBiI2HlWgH4olfQ2'
    publishableKey: process.env.STRIPE_PKEY or 'pk_test_6pRNASCoBOKtIshFeQd4XMUh'
  tumblr:
    consumerKey: process.env.TUMBLR_KEY or 'FaXbGf5gkhswzDqSMYI42QCPYoHsu5MIDciAhTyYjehotQpJvM'
    consumerSecret: process.env.TUMBLR_SECRET or 'QpCTs5IMMCsCImwdvFiqyGtIZwowF5o3UXonjPoNp4HVtJAL4o'
    callbackURL: '/auth/tumblr/callback'
  foursquare:
    clientId: process.env.FOURSQUARE_ID or '2STROLSFBMZLAHG3IBA141EM2HGRF0IRIBB4KXMOGA2EH3JG'
    clientSecret: process.env.FOURSQUARE_SECRET or 'UAABFAWTIHIUFBL0PDC3TDMSXJF2GTGWLD3BES1QHXKAIYQB'
    redirectUrl: process.env.FOURSQUARE_REDIRECT_URL or 'http://localhost:3000/auth/foursquare/callback'
  venmo:
    clientId: process.env.VENMO_ID or '1688'
    clientSecret: process.env.VENMO_SECRET or 'uQXtNBa6KVphDLAEx8suEush3scX8grs'
    redirectUrl: process.env.VENMO_REDIRECT_URL or 'http://localhost:3000/auth/venmo/callback'
  paypal:
    host: 'api.sandbox.paypal.com'
    client_id: process.env.PAYPAL_ID or 'AdGE8hDyixVoHmbhASqAThfbBcrbcgiJPBwlAM7u7Kfq3YU-iPGc6BXaTppt'
    client_secret: process.env.PAYPAL_SECRET or 'EPN0WxB5PaRaumTB1ZpCuuTqLqIlF6_EWUcAbZV99Eu86YeNBVm9KVsw_Ez5'
    returnUrl: process.env.PAYPAL_RETURN_URL or 'http://localhost:3000/api/paypal/success'
    cancelUrl: process.env.PAYPAL_CANCEL_URL or 'http://localhost:3000/api/paypal/cancel'
  lob: apiKey: process.env.LOB_KEY or 'test_814e892b199d65ef6dbb3e4ad24689559ca'
  bitgo: accessToken: process.env.BITGO_ACCESS_TOKEN or '4fca3ed3c2839be45b03bbd330e5ab1f9b3989ddd949bf6b8765518bc6a0e709'
  bitcore: bitcoinNetwork: process.env.BITCORE_BITCOIN_NETWORK or 'testnet'
