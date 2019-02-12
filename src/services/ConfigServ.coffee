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
    IDENT     : 'PROD'
    API_URL   : 'https://help.doccheck.com/'
    XMPP_URL  : 'xmpp.doccheck.com'
    LOGIN_URL : 'https://help.doccheck.com/oauth/v2/token'

  ###*
   * [GA_TRACKING_ID - Google Analytics Tracking ID]
   * @type {}
  ###
  @GA_TRACKING_ID = 'UA-2421261-73'

  ###*
   * [LOG FILE CONFIG]
   * @type {Object}
  ###
  @LOG =
    CONSOLE: -1
    FILE: 3
    MAX_FILE_SIZE: 128

  ###*
   * [CREDENTIALS]
   * @type {}
  ###
  @CREDENTIALS =
    ANDROID     :
      ID                : '38_1vnnypwsvun4k0gcgkowgco4wkwkw8kc8wc4coogk044c08g40'
      SECRET            : 'x88cl7nwnqoo40w0c888wk44k0ckkwswokkgw48kcos04cc0g'
    IOS         :
      ID                : '34_2xcrsd9teps0gww4gk84w0sws0o0s8o4cgow4cc4wo0o40oss0'
      SECRET            : '5yojqtmch340wks8c4osw4gcskcc8sg4oc4kcwkggsoo4swk88'

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