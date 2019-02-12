# Consultations Controller

angular.module("HelpPatient.controllers").controller('ConsultationsCtrl', ($scope, $q, $rootScope, $state, $timeout, $ionicTabsDelegate, $ionicNativeTransitions, $ionicPopover, Authentication, Consultations, HelpApi, GA, DcConnectivityMonitor) ->

  @listing =
    current : Consultations.all
    fetching: Consultations.fetching
    error   : Consultations.error

  @infinite =
    max     : 10
    interval: 20

  ###*
   * [init]
   * @return {[type]} []
  ###
  @init = =>

    $ionicPopover.fromTemplateUrl('templates/ConnectivityPopover.html',
      scope    : $scope
      animation: 'scale-in-if'
    ).then((popover) =>
      popover.hide()

      @connectivityPopover = popover
    )

    ###*
     * [$ionicView - beforeEnter]
     * @return
    ###
    $scope.$on('$ionicView.beforeEnter', =>
      @onBeforeEnter()
    )

    ###*
     * [$ionicView - enter]
     * @return
    ###
    $scope.$on('$ionicView.enter', =>
      GA.trackView('Consultations')

      @disconnected = DcConnectivityMonitor.isOffline()
      @connectionWatcher = DcConnectivityMonitor.subscribe((status) =>
        $timeout(=>
          @disconnected = (status == 'offline')
        )
      )
    )

    ###*
     * [$ionicView - leave]
     * @return
    ###
    $scope.$on('$ionicView.leave', =>
      @connectionWatcher?()
    )

    ###*
     * [Login successful]
    ###
    $rootScope.$on('event:auth-loginConfirmed', =>
      @authenticated = true
    )

    ###*
     * [Signout or access token expired]
    ###
    $rootScope.$on('dc-signout', =>
      @authenticated = false
    )

    ###*
     * [Signout or access token expired]
    ###
    $rootScope.$on('dc-authentication-failed', =>
      @authenticated = false
    )

  ###*
   * [onBeforeEnter]
   * @return
  ###
  @onBeforeEnter = ->
    # reference to all consultations
    @listing.current = Consultations.all

    return Authentication.isValid()
    .then(=>
      # authentication successful
      @authenticated = true
      @error         = false
      @fetchConsultations()
    , =>
      # authentication needed
      @authenticated   = false
      @listing.current = []
    )
    .catch(=>
      @error = false
    )

  ###*
   * [isLoading]
   * @return {Boolean} []
  ###
  @isLoading = =>
    return (
      @authenticated               &&
      @listing.current.length == 0 &&
      @listing.fetching.length > 0 &&
      @listing.error.pending
    )

  ###*
   * [isEmpty]
   * @return {Boolean} []
  ###
  @isListingEmpty = =>
    return (
      @authenticated                &&
      #@listing.fetching.length == 0 &&
      @listing.current.length == 0  &&
      !@listing.error.pending
    )


  ###*
   * [fetchConsultations]
   * @return {[type]} []
  ###
  @fetchConsultations = ->
    return $q.allSettled([
      Consultations.fetchActive()
      Consultations.fetchClosed()
    ])

  ###*
   * [openLogin]
   * @return {[type]} []
  ###
  @openLogin = ->
    $ionicTabsDelegate.select(3)
    $state.go('tabs.settings.login',
      fromTab   : 1
      fromState : 'tabs.consultations.overview'
    )
    return

  ###*
   * [openExpertListing description]
   * @return {[type]} [description]
  ###
  @openExpertListing = ->
    $ionicTabsDelegate.select(0)

    if ( ionic.Platform.isAndroid() )
      $ionicNativeTransitions.stateGo('tabs.home.overview', {}, {}, {
        "type": "fade",
        "duration": 200
      })
      return

    $state.go('tabs.home.overview')
    return

  ###*
   * [openConsultation]
   * @param  {[type]} consultation []
   * @return {[type]}              []
  ###
  @openDetails = (consultation) =>
    if $scope.scrollPreventsClick
      return

    if consultation.consultation_type.id == HelpApi.CONSULTATIONTYPES.CHAT
      return @openChatFor(consultation)
    return @openCallFor(consultation)

  ###*
   * [openChatFor]
   * @param  {[type]} consultation [description]
   * @return {[type]}              [description]
  ###
  @openChatFor = (consultation) ->
    return $state.go('^.chat',
      id : consultation.id
    )

  ###*
   * [openChatFor]
   * @param  {[type]} consultation [description]
   * @return {[type]}              [description]
  ###
  @openCallFor = (consultation) ->
    return $state.go('^.call',
      id : consultation.id
    )

  ###*
   * [showConnectivityPopover]
   * @param  {[type]} $event []
   * @return {[type]}        []
  ###
  @showConnectivityPopover = ($event) =>
    @connectivityPopover.show($event)
    return

  ###*
   * [infiniteScroll]
   * @return {[type]} []
  ###
  @infiniteScroll = =>
    @infinite.max += @infinite.interval
    $scope.$broadcast('scroll.infiniteScrollComplete')
    return

  @init()

  return

)