# DcConnectivityMonitor service

angular.module("HelpPatient.services").factory("DcConnectivityMonitor", ($cordovaNetwork, $rootScope) ->

  @onlineWatcher = null
  @offlineWatcher = null

  @subscribtions = null

  ###*
   * [init - initialize the service]
   * @return {[type]} []
  ###
  @init = ->
    @subscribtions = {}
    return

  ###*
   * Insert service functions here
  ###

  ###*
   * [isOnline]
   * @return {Boolean} []
  ###
  @isOnline = () =>
    if ( ionic.Platform.isWebView() )
      return $cordovaNetwork.isOnline()

    return navigator.onLine;

  ###*
   * [isOffline]
   * @return {Boolean} []
  ###
  @isOffline = () =>
    return !@isOnline()

  ###*
   * [subscribe]
   * @param  {Function} callback []
   * @return {[type]}            []
  ###
  @subscribe = (callback) =>
    if ( typeof callback != 'function' )
      console.warn( '[DcConnectivityMonitor] Callback must be a function!' )

    subscribtionHandle = 'sub' + Date.now() + '_' + Math.random() * 1000
    @subscribtions[subscribtionHandle] = callback

    if ( Object.keys( @subscribtions ).length == 1 )
      @startWatching()

    return =>
      @unsubscribe( subscribtionHandle )

  ###*
   * [unsubscribe]
   * @param  {[type]} id []
   * @return {[type]}    []
  ###
  @unsubscribe = (id) =>
    delete @subscribtions[id]

    if ( Object.keys( @subscribtions ).length == 0 )
      @stopWatching()

    return

  ###*
   * [startWatching]
   * @return {[type]} []
  ###
  @startWatching = =>
    if ( ionic.Platform.isWebView() )
      @onlineWatcher = $rootScope.$on('$cordovaNetwork:online', @online)
      @offlineWatcher = $rootScope.$on('$cordovaNetwork:offline', @offline)
      return

    @onlineWatcher = window.addEventListener('online', @online, false)
    @offlineWatcher = window.addEventListener('offline', @offline, false)
    return

  ###*
   * [stopWatching]
   * @return {[type]} []
  ###
  @stopWatching = =>
    if ( ionic.Platform.isWebView() )
      @onlineWatcher?()
      @offlineWatcher?()
      return

    window.removeEventListener('online', @online, false)
    window.removeEventListener('offline', @offline, false)    
    return

  ###*
   * [online]
   * @return {[type]} []
  ###
  @online = =>
    for subscribtionHandle, callback of @subscribtions
      callback('online')

    return

  ###*
   * [offline]
   * @return {[type]} []
  ###
  @offline = =>
    for subscribtionHandle, callback of @subscribtions
      callback('offline')

    return

  ###*
   * Call to init
  ###
  @init()

  ###*
   * Exposed functions for service
  ###
  return {
    subscribe : @subscribe
    isOnline : @isOnline
    isOffline : @isOffline
  }
)