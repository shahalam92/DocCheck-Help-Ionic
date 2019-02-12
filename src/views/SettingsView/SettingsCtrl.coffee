# Settings Controller

angular.module("HelpPatient.controllers").controller('SettingsCtrl', ($scope, $state, $ionicTabsDelegate, $q, $ionicPopover, $ionicPopup, $ionicHistory, $filter, $ionicLoading, $timeout, $rootScope, Authentication, Tools, ApiUser, ApiNewsfeed, GuidedTour, GA, SecureStorage, DcInit, PouchLogin, DcErrorParser, Toast, ApiLog, DcLoading) ->

  $scope.vm = @

  @unreadNewsfeedCount = 0;

  #@authenticated = false
  @user = Authentication.user

  ###*
   * [init]
   * @return
  ###
  @init = ->
    $scope.$on('$ionicView.beforeEnter', @isAuthenticated)

    $scope.$on('$ionicView.enter', =>
      GA.trackView('Settings')
      @updateNewsfeedBadge()
    )

    @newsfeedListener?()
    @newsfeedListener = $rootScope.$on('dc-newsfeed-updated', @updateNewsfeedBadge)

    ###*
     * Sign Out Listener
    ###
    @signOutListener?()
    @signOutListener = $rootScope.$on('dc-signout', =>
      @isAuthenticated()
    )

    ###*
     * Sign In Listener
    ###
    @signInListener?()
    @signInListener = $rootScope.$on('event:auth-loginConfirmed', =>
      @isAuthenticated()
    )

  @updateNewsfeedBadge = =>
    @unreadNewsfeedCount = ApiNewsfeed.getUnreadCount()

  ###*
   * [isAuthenticated]
   * @return {Boolean} []
  ###
  @isAuthenticated = =>
    return Authentication.isValid().then(=>
      $timeout(=>
        @authenticated = true
        Authentication.getOwnUser()
        return
      )
    )
    .catch(=>
      return @authenticated = false
    )

  ###*
   * [authenticated ]
   * @return
  ###
  @authentication = =>
    if @authenticated
      @signOut()
    else
      @signIn()
    return

  ###*
   * [signOut]
   * @return
  ###
  @signOut = =>
    $ionicLoading.show(
      template: '<ion-spinner icon="spiral"></ion-spinner><div class="loading-hint" translate="SETTINGS.SIGNING_OUT"></div>',
    )

    signOutPromise = Authentication.signOut()
    .then(@isAuthenticated())

    $q.all([
      signOutPromise
      $timeout(->
        doNothing = 'show loading spinner for at least one second'
      , 1000)
    ])
    .finally(=>
      $ionicLoading.hide()
      @authenticated = false
    )
    return

  ###*
   * [signIn]
   * @return
  ###
  @signIn = ->
    $state.go('^.login',
      callback : =>
        @isAuthenticated()
      toState : 'tabs.home.overview'
      toTab   : 0
    )
    return

  ###*
   * [headToDocCheck]
   * @return {[type]} []
  ###
  @headToDocCheck = =>
    @resetDocCheckEmail()
    return

  ###*
   * [registerDocCheck]
   * @return {[type]} []
  ###
  @resetDocCheckEmail = ->
    window.open('https://www.doccheck.com/de/account/mydata/index/', '_blank')
    return

  ###*
   * [submitEmailChange]
   * @return {[type]} []
  ###
  @submitEmailChange = =>
    @changeEmail.error = ''

    $ionicLoading.show(
      template: '<ion-spinner icon="spiral"></ion-spinner><div class="loading-hint" translate="SETTINGS.EMAIL_CHANGE_POPUP.LOADING"></div>',
    )

    email = @changeEmailNew
    password = @changeEmailPassword

    user = null

    Authentication.getOwnUser()
    .then((own) =>
      user = own
      return ApiUser.changeEmail(@user.email, @changeEmailNew, @changeEmailPassword)
    )
    .then((user) =>
      PouchLogin.insertOrUpdate('username', email)

      @user = Authentication.setOwnUser(user)
      @emailChangePopup.close()

      $ionicLoading.show(
        template: '<ion-spinner icon="spiral"></ion-spinner><div class="loading-hint" translate="SETTINGS.EMAIL_CHANGE_POPUP.REQUEST_SUCCEEDED"></div>'
      )

      return Authentication.signIn(email, password)
      .then(() =>
        $ionicLoading.show(
          template: '<div class="loading-hint" translate="SETTINGS.EMAIL_CHANGE_POPUP.AUTHENTICATION_SUCCEEDED"></div>'
        )

        @changeEmailNew = ''
        @changeEmailPassword = ''
      )

    )
    .catch((error) =>
      @changeEmail.error = DcErrorParser.parse(error.data).first

      $ionicLoading.show(
        template: '<div class="loading-hint" translate="SETTINGS.EMAIL_CHANGE_POPUP.REQUEST_FAILED"></div>',
      )
    )
    .finally(() ->
      $timeout($ionicLoading.hide, 2000)
    )

  ###*
   * [hideEmailChangePopup]
   * @return {[type]} []
  ###
  @hideEmailChangePopup = =>
    return @emailChangePopup.close()

  ###*
   * [showEmailChangePopup]
   * @param  {[type]} $event []
   * @return {[type]}        []
  ###
  @showEmailChangePopup = ($event) =>
    @changeEmail =
      error : ''

    @emailChangePopup = $ionicPopup.prompt(
      title: $filter('translate')('SETTINGS.EMAIL_CHANGE_POPUP.TITLE')
      templateUrl: 'emailChangePopup.html'
      cssClass: 'dc-popup settings-email-activation-popup'
      scope: $scope
      buttons    : []
    )

  ###*
   * [showGuidedTour]
   * @return {[type]} []
  ###
  @showGuidedTour = ->
    GA.trackEvent('Settings', 'guidedTour', 'restart')

    GuidedTour.unsetPassed('home')
    GuidedTour.start('home', GuidedTour.getStepsFromConfig('home'))
    return

  ###*
   * [sendLogfile]
   * @return {[type]} []
  ###
  @sendLogfile = ->
    DcLoading.show()

    ApiLog.sendLogfile(@registerLogfileProgress)
      .then(() ->
        if (!ionic.Platform.isWebView())
          return

        Toast.show('SETTINGS.LOGFILE_SENT.SUCCESS')
      )
      .catch(() ->
        if (!ionic.Platform.isWebView())
          return

        Toast.show('SETTINGS.LOGFILE_SENT.FAIL')
      )
      .finally(DcLoading.hide)
    return

  ###*
   *
   *
  ###
  @registerLogfileProgress = (sent, total, finished) =>
    progress = (sent * 100 / total).toFixed(2)

    if (!ionic.Platform.isWebView())
      console.log('Progress: %s%', progress)
      return

    Toast.show('SETTINGS.LOGFILE_SENT.PROGRESS', "short", "bottom", null, {
      progress
    })
    return

  ###*
   * [restoreFactoryConditions]
   * @return {[type]} []
  ###
  @restoreFactoryConditions = ->
    $ionicLoading.show(
      template: '<ion-spinner icon="spiral"></ion-spinner><div class="loading-hint" translate="SETTINGS.RESTORE_FACTORY_CONDITIONS.LOADING"></div>',
    )

    DcInit.restoreFactoryConditions()
    .finally(->
      $ionicLoading.hide()
      $ionicTabsDelegate.select(0)
      $ionicHistory.clearCache().then(->
        $state.go('tabs.home.overview').then($ionicHistory.clearHistory)
      )
    )

  ###*
   * [clearEncryptionKeys]
   * @return {[type]} []
  ###
  @regenerateEncryptionKeys = ->
    $ionicLoading.show(
      template: '<ion-spinner icon="spiral"></ion-spinner><div class="loading-hint" translate="SETTINGS.REGENERATE_KEYS"></div>',
    )

    $q.allSettled([
      DcInit.regenerateEncryptionKeys()
      $timeout(() ->
        return
      , 2000)
    ])
    .finally($ionicLoading.hide)

  ###*
   * [openImpress]
   * @return {[type]} []
  ###
  @openImpress = ->
    window.open('http://info.doccheck.com/de/imprint/', '_blank')
    return

  @init()

  return
)