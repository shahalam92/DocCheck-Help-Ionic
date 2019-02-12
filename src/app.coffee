angular.module('HelpPatient', [
  'ionic'
  'ngIOS9UIWebViewPatch'
  # exported templates (see gulp file / templates.js)
  'templates'
  'pouchdb'
  # TODO: Remove 'angular-cache'
  'ionic-native-transitions'
  # ngCordova
  'ngCordova'
  'ngCordova.plugins'
  'ngCordova.plugins.nativeStorage'
  'ngCordova.plugins.network'
  'ngCordova.plugins.vibration'
  'ngCordova.plugins.camera'
  'ngCordova.plugins.file'
  'ngCordova.plugins.fileTransfer'
  'ngCordova.plugins.statusbar'
  # Mocking
  'ngMockE2E'
  # authentication helper services
  'http-auth-interceptor'
  'http-auth-interceptor-buffer'
  # general Help modules (shared between Patient and Expert app)
  'Help.controllers'
  'Help.services'
  'Help.directives'
  'Help.decorators'
  'Help.filters'
  # patient specific Help modules
  'HelpPatient.controllers'
  'HelpPatient.services'
  'HelpPatient.directives'
  'HelpPatient.decorators'
  'HelpPatient.translations'
  'HelpPatient.filters'
]).run ($ionicPlatform, $state, $ionicTabsDelegate, $timeout, $log, $translate, $translatePartialLoader, Api, Config, PayPal, SecureStorage, Authentication, Push, GA, LogInit, DcInit, HelpMocking, CacheLast, GuidedTour, ApiToS, ApiPrivacy) ->

  # enhance logging style
  $translate.refresh()

  ###
  # Initial config
  ###

  $ionicPlatform.ready ->
    # hide splashscreen after rendering
    $timeout(->
      navigator?.splashscreen?.hide?()

      GuidedTour.start('home', GuidedTour.getStepsFromConfig('home'))
    , 1500)

    #CacheLast.clear()
    LogInit.init()
    DcInit.init()

    PayPal.initPaymentUI()

    if !localStorage.getItem('dchelp_' + Api.getApp() + '_initialized')
      localStorage.setItem('dchelp_' + Api.getApp() + '_initialized', true)
      localStorage.setItem('dchelp_' + Api.getApp() + '_initialized_timestamp', Date.now())

    return
  return

.config ($stateProvider, $urlRouterProvider, $ionicConfigProvider, $translateProvider, $translatePartialLoaderProvider, $httpProvider, $compileProvider, $logProvider, $ionicNativeTransitionsProvider, DcInitProvider) ->

  ###
  # Tab config
  ###

  # transition configuration
  if ( ionic.Platform.isAndroid() )
    # on Android use native transitions plugin instead
    $ionicConfigProvider.views.transition('none')
    $ionicNativeTransitionsProvider.setDefaultOptions(
      duration: 300
      slowdownfactor: -1
      slidePixels: 20
      fixedPixelsTop: 0
      fixedPixelsBottom: 49
      backInOppositeDirection: false
   )
  else
    # on iOS (as the native transition plugin isn't stable there) use default Ionic transitions
    $ionicNativeTransitionsProvider.enable(false)
    $ionicConfigProvider.views.transition('ios')

  # disable swipe back (might cause confusion no certain views)
  $ionicConfigProvider.views.swipeBackEnabled(false)

  # fix tabs to bottom and default tab style
  $ionicConfigProvider.tabs.position("bottom")
  $ionicConfigProvider.tabs.style("standard")

  # configure back button to apply to DC style
  $ionicConfigProvider.backButton.text('').icon('fa fa-chevron-left')
  $ionicConfigProvider.backButton.previousTitleText(false)

  # set max cache
  $ionicConfigProvider.views.maxCache(100)
  $ionicConfigProvider.views.forwardCache(true)

  # disable JS scrolling (use native overflow scroll)
  $ionicConfigProvider.scrolling.jsScrolling(false)

  # add error interceptor
  $httpProvider.interceptors.push('HttpErrorInterceptor')

  $translatePartialLoaderProvider.addPart('Global')
  $translatePartialLoaderProvider.addPart('API')

  $translatePartialLoaderProvider.addPart('Views/Call')
  $translatePartialLoaderProvider.addPart('Views/Chat')
  $translatePartialLoaderProvider.addPart('Views/Consultations')
  $translatePartialLoaderProvider.addPart('Views/Contact')
  $translatePartialLoaderProvider.addPart('Views/ExpertProfile')
  $translatePartialLoaderProvider.addPart('Views/Favorites')
  $translatePartialLoaderProvider.addPart('Views/Home')
  $translatePartialLoaderProvider.addPart('Views/InitCall')
  $translatePartialLoaderProvider.addPart('Views/InitChat')
  $translatePartialLoaderProvider.addPart('Views/InitConsultation')
  $translatePartialLoaderProvider.addPart('Views/Login')
  $translatePartialLoaderProvider.addPart('Views/Rating')
  $translatePartialLoaderProvider.addPart('Views/RatingListing')
  $translatePartialLoaderProvider.addPart('Views/Settings')
  $translatePartialLoaderProvider.addPart('Views/Hints')

  $translatePartialLoaderProvider.addPart('Directives/ConsultationReview')
  $translatePartialLoaderProvider.addPart('Directives/DcPasswordStrength')
  $translatePartialLoaderProvider.addPart('Directives/ExpertFilter')
  $translatePartialLoaderProvider.addPart('Directives/ExpertHeadline')
  $translatePartialLoaderProvider.addPart('Directives/FavoriteButton')
  $translatePartialLoaderProvider.addPart('Directives/GuidedTour')
  $translatePartialLoaderProvider.addPart('Directives/FilterPicker')

  $translatePartialLoaderProvider.addPart('Modals/ClientUpdate')
  $translatePartialLoaderProvider.addPart('Modals/ToS')
  $translatePartialLoaderProvider.addPart('Modals/FilterModal')
  $translatePartialLoaderProvider.addPart('Modals/SortModal')
  $translatePartialLoaderProvider.addPart('Modals/WelcomePopup')
  $translatePartialLoaderProvider.addPart('Modals/CallIntroModal')

  $translateProvider.useStaticFilesLoader(
    prefix: 'locale-'
    suffix: '.json'
  )
  $translateProvider.useLoader('$translatePartialLoader',
    urlTemplate: 'translations/{part}/{lang}.json'
  )

  # Language
  if !$translateProvider.use()
    $translateProvider.use('de_DE')

  ###*
   * [Routing]
  ###
  $stateProvider.state("tabs",
  {
    url: "/tabs"
    templateUrl: "templates/TabView.html"
    abstract: true
    controller: "TabCtrl as tab"
  })
  .state("tabs.home",
  {
    ###*
     * [Home]
    ###
    url: "/home"
    abstract: true
    views: "home":
      template: "<ion-nav-view></ion-nav-view>"
    }).state("tabs.home.overview", {
      url: "/overview"
      templateUrl: "templates/HomeView.html"
      controller: "HomeCtrl as home"
    }).state("tabs.home.expertprofile", {
      url: "/expertprofile/:id"
      params:
        expert: null
        hideTabs: false
      templateUrl: "templates/ExpertProfileView.html"
      controller: "ExpertProfileCtrl as expertProfile"
    }).state("tabs.home.ratinglisting", {
      url: "/ratinglisting/:id"
      templateUrl: "templates/RatingListingView.html"
      params:
        name: null
      controller: "RatingListingCtrl as ratingListing"
    }).state("tabs.home.initchat", {
      url: "/initchat/:id"
      params:
        expert: null
        consultationType: 1
      templateUrl: "templates/InitConsultationView.html"
      controller: "InitConsultationCtrl as initConsultation"
    }).state("tabs.home.initcall", {
      url: "/initcall/:id"
      params:
        expert: null
        consultationType: 2
      templateUrl: "templates/InitConsultationView.html"
      controller: "InitConsultationCtrl as initConsultation"
    }).state("tabs.home.login", {
      url: "/login/:id"
      params:
        fromTab  : null
        fromState: null
        toState  : null
        toTab    : null
        callback : null
        allowBack: true
        omitHistoryClear: false
      templateUrl: "templates/LoginView.html"
      controller: "LoginCtrl as login"
    })
  .state("tabs.consultations",
  {
    ###*
     * [Consultations]
    ###
    url: "/consultations"
    abstract: true
    views: "consultations":
      template: "<ion-nav-view></ion-nav-view>"
    }).state("tabs.consultations.overview", {
      url: "/overview"
      templateUrl: "templates/ConsultationsView.html"
      params:
        consultation: {}
      controller: "ConsultationsCtrl as consultations"
    }).state("tabs.consultations.initchat", {
      url: "/initchat/:id"
      params:
        expert: null
        consultationType: 1
      templateUrl: "templates/InitConsultationView.html"
      controller: "InitConsultationCtrl as initConsultation"
    }).state("tabs.consultations.chat", {
      url: "/chat/:id"
      params:
        consultation: null
        hideTabs: true
      templateUrl: "templates/ChatView.html"
      controller: "ChatCtrl as chat"
      resolve:
        Resolved : ($q, $stateParams, $timeout, DcLoading, Consultations, ChatUser, DcXMPP) ->
          return $q((resolve, reject) ->

            result = {}

            debouncedLoading = $timeout(->
              DcLoading.show(
                spinner: 'spiral'
              )
            , 600, false)

            dismissLoading = ->
              $timeout.cancel(debouncedLoading)
              DcLoading.hide()
              return

            obj = Consultations.get($stateParams.id)
            result.consultation = obj.consultation

            if result.consultation?.hasMetaData?()
              dismissLoading()
              return resolve(result)

            obj.cached.finally(->
              if result.consultation.hasMetaData()
                dismissLoading()
                return resolve(result)

              obj.fetch.then(->
                dismissLoading()
                return resolve(result)
              ).catch(->
                return resolve()
              )
            )
          )
    }).state("tabs.consultations.call", {
      url: "/call/:id"
      params:
        consultation: null
        hideTabs: true
      templateUrl: "templates/CallView.html"
      controller: "CallCtrl as call"
      resolve:
        Resolved : ($q, $stateParams, $timeout, DcLoading, Consultations, ChatUser) ->
          return $q((resolve, reject) ->

            result = {}

            debouncedLoading = $timeout(->
              DcLoading.show(
                spinner: 'spiral'
              )
            , 600, false)

            dismissLoading = ->
              $timeout.cancel(debouncedLoading)
              DcLoading.hide()
              return

            obj = Consultations.get($stateParams.id)
            result.consultation = obj.consultation

            obj.cached.then(->
              dismissLoading()
              return resolve(result)
            )

            obj.fetch.finally(->
              dismissLoading()
              return resolve(result)
            )

          )
    }).state("tabs.consultations.rating", {
      url: "/rating/:id"
      params:
        consultation: null
      templateUrl: "templates/RatingView.html"
      controller: "RatingCtrl as rating"
    }).state("tabs.consultations.expertprofile", {
      url: "/expertprofile/:id"
      params:
        expert: null
        hideTabs: true
      templateUrl: "templates/ExpertProfileView.html"
      controller: "ExpertProfileCtrl as expertProfile"
    }).state("tabs.consultations.ratinglisting", {
      url: "/ratinglisting/:id"
      templateUrl: "templates/RatingListingView.html"
      params:
        name: null
      controller: "RatingListingCtrl as ratingListing"
    })
  .state("tabs.favorites",
  {
    ###*
     * [Favorites]
    ###
    url: "/favorites"
    abstract: true
    views: "favorites":
      template: "<ion-nav-view></ion-nav-view>"
    }).state("tabs.favorites.overview", {
      url: "/overview"
      templateUrl: "templates/FavoritesView.html"
      controller: "FavoritesCtrl as favorites"
    }).state("tabs.favorites.expertprofile", {
      url: "/expertprofile/:id"
      params:
        expert: null
        hideTabs: false
      templateUrl: "templates/ExpertProfileView.html"
      controller: "ExpertProfileCtrl as expertProfile"
    }).state("tabs.favorites.ratinglisting", {
      url: "/ratinglisting/:id"
      templateUrl: "templates/RatingListingView.html"
      params:
        name: null
      controller: "RatingListingCtrl as ratingListing"
    }).state("tabs.favorites.initchat", {
      url: "/initchat/:id"
      params:
        expert: null
        consultationType: 1
      templateUrl: "templates/InitConsultationView.html"
      controller: "InitConsultationCtrl as initConsultation"
    }).state("tabs.favorites.initcall", {
      url: "/initcall/:id"
      params:
        expert: null
        consultationType: 2
      templateUrl: "templates/InitConsultationView.html"
      controller: "InitConsultationCtrl as initConsultation"
    }).state("tabs.favorites.login", {
      url: "/login/:id"
      params:
        fromTab  : null
        fromState: null
        toState  : null
        toTab    : null
        callback : null
        allowBack: true
      templateUrl: "templates/LoginView.html"
      controller: "LoginCtrl as login"
    })
  .state("tabs.settings",
  {
    ###*
     * [Settings]
    ###
    url: "/settings"
    abstract: true
    views: "settings":
      template: "<ion-nav-view></ion-nav-view>"
    }).state("tabs.settings.overview", {
      url: "/overview"
      templateUrl: "templates/SettingsView.html"
      controller: "SettingsCtrl as settings"
    }).state("tabs.settings.paymenthistory", {
      url: "/paymenthistory"
      templateUrl: "templates/PaymentHistoryView.html"
      controller: "PaymentHistoryCtrl as paymentHistory"
    }).state("tabs.settings.profile", {
      url: "/profile"
      templateUrl: "templates/ProfileView.html"
      controller: "ProfileCtrl as profile"
    }).state("tabs.settings.balance", {
      url: "/balance"
      templateUrl: "templates/BalanceView.html"
      controller: "BalanceCtrl as balance"
    }).state("tabs.settings.notifications", {
      url: "/notifications"
      templateUrl: "templates/NotificationsView.html"
      controller: "NotificationsCtrl as notifications"
    }).state("tabs.settings.hints", {
      url: "/hints"
      templateUrl: "templates/HintsView.html"
      controller: "HintsCtrl as hints"
    }).state("tabs.settings.terms", {
      url: "/terms"
      templateUrl: "templates/TermsView.html"
      controller: "TermsCtrl as terms"
    }).state("tabs.settings.contact", {
      url: "/contact"
      templateUrl: "templates/ContactView.html"
      controller: "ContactCtrl as contact"
    }).state("tabs.settings.impress", {
      url: "/impress"
      templateUrl: "templates/ImpressView.html"
      controller: "ImpressCtrl as impress"
    }).state("tabs.settings.privacy", {
      url: "/privacy"
      templateUrl: "templates/PrivacyView.html"
      controller: "PrivacyCtrl as privacy"
    }).state("tabs.settings.newsfeed", {
      url: "/newsfeed"
      templateUrl: "templates/NewsfeedView.html"
      controller: "NewsfeedCtrl as newsfeed"
    }).state("tabs.settings.newsfeeditem", {
      url: "/newsfeeditem/:id"
      templateUrl: "templates/NewsfeedItemView.html"
      controller: "NewsfeedItemCtrl as newsfeeditem"
      params:
        item: null
    }).state("tabs.settings.promotion", {
      url: "/promotion"
      templateUrl: "templates/PromotionView.html"
      controller: "PromotionCtrl as promotion"
    }).state("tabs.settings.login", {
      url: "/login/:id"
      params:
        fromTab  : null
        fromState: null
        toState  : null
        toTab    : null
        callback : null
        allowBack: true
      templateUrl: "templates/LoginView.html"
      controller: "LoginCtrl as login"
    })

  $urlRouterProvider.otherwise('/tabs/home/overview')


###*
 * Modules
###
angular.module("Help.services", [])
angular.module("Help.controllers", [])
angular.module("Help.directives", [])
angular.module("Help.decorators", [])
angular.module("Help.filters", [])
angular.module("HelpPatient.services", [])
angular.module("HelpPatient.controllers", [])
angular.module("HelpPatient.directives", [])
angular.module("HelpPatient.decorators", [])
angular.module("HelpPatient.filters", [])
angular.module("HelpPatient.translations", ['pascalprecht.translate'])
angular.module("templates", [])