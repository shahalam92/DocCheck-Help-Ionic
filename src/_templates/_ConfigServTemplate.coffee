# This Configuration Service is generated automatically.
#
# Change configurations in <PROJECT_FOLDER>/config for the according environment.
#
# If additional configuration parameters are needed please adjust the template in
# <PROJECT_FOLDER>/www/src/_templates/_ConfigServTemplate
#

# Config service

angular.module("HelpPatient.services").factory("Config", (Constants) ->

  ###*
   * [APP]
   * @type {String}
  ###
  @APP       = 'patient'

  ###*
   * [ENVIRONMENT]
   * @type {}
  ###
  @ENVIRONMENT =
    IDENT     : '<%= environment %>'
    API_URL   : '<%= api_url %>'
    XMPP_URL  : '<%= xmpp_url %>'
    LOGIN_URL : '<%= login_url %>'

  ###*
   * [GA_TRACKING_ID - Google Analytics Tracking ID]
   * @type {}
  ###
  @GA_TRACKING_ID = '<%= ga_tracking_id %>'

  ###*
   * [LOG FILE CONFIG]
   * @type {Object}
  ###
  @LOG =
    CONSOLE: <%= log.console %>
    FILE: <%= log.file %>
    MAX_FILE_SIZE: <%= log.maxFileSize %>

  ###*
   * [CREDENTIALS]
   * @type {}
  ###
  @CREDENTIALS =
    ANDROID     :
      ID                : '<%= credentials.android.id %>'
      SECRET            : '<%= credentials.android.secret %>'
    IOS         :
      ID                : '<%= credentials.ios.id %>'
      SECRET            : '<%= credentials.ios.secret %>'

  ###*
   * [CHAT_USER]
   * @type {}
  ###
  @CHAT_USER =
    LOCAL     : 'patient_chat_user'
    REMOTE    : 'expert_chat_user'

  ###*
   * [EXPERTS]
   * @type {}
  ###
  @EXPERTS =
    REFRESH_INTERVAL :
      LISTING          : 1000 * 60 * 60
      STATUS           : 1000 * 30

  ###*
   * [CONSULTATIONS]
   * @type {}
  ###
  @CONSULTATIONS =
    REFRESH_INTERVAL : 1000 * 60 * 2

  ###*
   * [EXPERTS]
   * @type {}
  ###
  @EXPERTS =
    REFRESH_INTERVAL :
      LISTING          : 1000 * 60 * 60
      STATUS           : 1000 * 30

  ###*
   * [HTTP_REQUEST_TIMEOUT]
   * @type {Number}
  ###
  @HTTP_REQUEST_TIMEOUT = 30000
  @HTTP_REQUEST_TIMEOUT_SHORT = 15000

  ###*
   * [lastGuidedTourUpdate description]
   * @type {Number}
  ###
  @guidedTour =
    lastUpdate : new Date(2016, 9-1, 28)
    steps:
      home : [
        selector : []
        hint : 'GUIDED_TOUR.PATIENT.WELCOME'
      ,
        selector : [
          name  : '.tab-item i.guided-tour-home'
          shape : 'round'
        ]
        hint : 'GUIDED_TOUR.PATIENT.HOME'
      ,
        selector : [
          name  : '.tab-item i.guided-tour-consultations'
          shape : 'round'
        ]
        hint : 'GUIDED_TOUR.PATIENT.CONSULTATIONS'
      ,
        selector : [
          name  : '.tab-item i.guided-tour-favorites'
          shape : 'round'
        ]
        hint : 'GUIDED_TOUR.PATIENT.FAVORITES'
      ,
        selector : [
          name  : '.tab-item i.guided-tour-settings'
          shape : 'round'
        ]
        hint : 'GUIDED_TOUR.PATIENT.SETTINGS'
      ]

  ###*
   * [faq]
   * @type {Array}
  ###
  @faq = [
    'DOCS',
    'CHATS',
    'CALLS',
    'APPOINTMENTS',
    'PRICING',
    'PAYMENT',
    'PRESCRIPTION',
    'INSURANCE',
    'NOTIFICATIONS',
    'UPDATES'
  ]

  return @
)