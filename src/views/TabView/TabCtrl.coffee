# Tab Controller

###*
 * [handleOpenURL
 *   - handles custom url scheme
 *   - MUST be outside of the angular context
 *   - URL is bridged to angular context via localStorage
 * ]
 * @param  {[type]} url []
 * @return {[type]}     []
###
handleOpenURL = (url) ->
  window.localStorage.setItem("external_load", url)
  return

angular.module("HelpPatient.controllers").controller('TabCtrl', ($rootScope, $state, $ionicTabsDelegate, $ionicNativeTransitions, $timeout, Consultations, DcXMPP, DcDeepLink, Push, HelpMocking) ->

  @paused = false;

  ###*
   * [init]
   * @return {[type]} []
  ###
  @init = =>
    # refresh tab message badge on startup
    $rootScope.$on('refresh-unread-message-count', =>
      @refreshMessageBadge()
    )
    @refreshMessageBadge()

    # check for launch by push notification on resume
    document.removeEventListener('resume', @onResume)
    document.removeEventListener('pause', @onPause)
    document.addEventListener('resume', @onResume, false)
    document.addEventListener('pause', @onPause, false)

    # fetch messages on successful login
    $rootScope.$on('dc-signout', @refreshMessageBadge)

    # make sure to remove keyboard-open class on state change
    $rootScope.$on('$stateChangeStart', ->
      angular.element(document.querySelector('body')).removeClass('keyboard-open')
    )
    return

  ###*
   * [goTo]
   * @param  {[type]} state []
   * @param  {[type]} index []
   * @return {[type]}       []
  ###
  @goTo = ($event, state, index) ->
    if state == $state.current.name
      $event.preventDefault()
      $event.stopPropagation()
      return

    if $ionicTabsDelegate.selectedIndex() != index
      $ionicTabsDelegate.select(index)

    if ionic.Platform.isAndroid()
      $ionicNativeTransitions.stateGo(state, {}, {},
          "type" : "fade"
          "duration" : 200
      )
    else
      $state.go(state)
    return

  ###*
   * [checkExternalLoad]
   * @return {[type]} []
  ###
  @checkExternalLoad = ->
    externalLoadUrl = window.localStorage.getItem("external_load")
    if externalLoadUrl?
      #alert(externalLoadUrl)
      window.localStorage.removeItem("external_load")
      DcDeepLink.handleDeepLink(externalLoadUrl)
    return

  ###*
   * [onPause]
   * @return {[type]} []
  ###
  @onPause = =>
    @paused = true

    Keyboard?.hide?()
    Keyboard?.close?()
    return

  ###*
  * [onResume]
  * @return {[type]} []
  ###
  @onResume = =>
    @paused = false

    @checkExternalLoad()
    @refreshMessageBadge()
    return

  ###*
   * [refreshMessageBadge]
   * @return {[type]} []
  ###
  @refreshMessageBadge = =>
    if (@paused)
      return

    @messageBadge = DcXMPP.getTotalUnreadMessageCount()
    if ionic.Platform.isWebView() && cordova.plugins?.notification?.badge?
      cordova.plugins.notification.badge.set(@messageBadge)
    return

  @init()

  return
)