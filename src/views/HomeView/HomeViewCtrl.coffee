# Controller
#

angular.module("HelpPatient.controllers").controller('HomeCtrl', ($scope, $rootScope, $q, $timeout, $interval, $state, $translate, $ionicLoading, $ionicScrollDelegate, $ionicHistory, $ionicPopover, $filter, DcXMPP, HelpApi, ApiTransactions, FavoriteExperts, Authentication, Tools, Experts, GA, FileTransfer, FileModal, SecureStorage, ExpertFilter, DcConnectivityMonitor) ->

  translationListener = $rootScope.$on('$translateChangeSuccess', =>
    @title = $filter('translate')('HOME.TITLE')
    translationListener?()
  )

  @title = ''

  @listener = []

  @experts = Experts.getAll()
  @error   = Experts.error
  @fetching = Experts.fetching
  @timedOut = false

  @listing =
    page: 0
    epp:  10
    more: false

  @infinite =
    max     : 10
    interval: 10

  @stats =
    chats : -1
    calls : -1

  ###*
   * [init]
   * @return {[type]} []
  ###
  @init = =>
    @fetchExperts()

    $ionicPopover.fromTemplateUrl('balancePopover.html',
      scope    : $scope
      animation: 'scale-in-if'
    ).then((popover) =>
      popover.hide()

      @balancePopover = popover
    )

    $ionicPopover.fromTemplateUrl('templates/ConnectivityPopover.html',
      scope    : $scope
      animation: 'scale-in-if'
    ).then((popover) =>
      popover.hide()

      @connectivityPopover = popover
    )

    $rootScope.$on('dc-factory-reset', @clear)

    $scope.$watch(=>
      return @experts
    , (n, o) =>
      if ( @experts? )
        @sortExperts()
    , true)

    $scope.$on('dc_experts_sorting-changed', =>
      @sortExperts()
    )

    ###*
     * [$ionicView - beforeEnter]
     * @return
    ###
    $scope.$on('$ionicView.beforeEnter', =>
      if @title.length == 0
        title = $filter('translate')('HOME.TITLE')
        if title != 'HOME.TITLE'
          translationListener?()
          @title = title

      @listing.more = true

      @fetchExperts()
      @getAvailableConsultationCount()

      $scope.$broadcast('beforeEnter')
    )

    ###*
     * [$ionicView - enter]
     * @return
    ###
    $scope.$on('$ionicView.enter', =>
      GA.trackView('Home')

      #@disconnected = DcConnectivityMonitor.isOffline()
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

    @checkExpertsAfterTimeout();

  ###*
   * [checkExpertsAfterTimeout]
   * @param  {[type]} page []
   * @return {[type]}      []
  ###
  @checkExpertsAfterTimeout = () =>
    setTimeout(() =>
      if @experts.length > 0
        return

      @timedOut = true
      return
    , 10000)

  ###*
   * [checkExpertsAfterTimeout]
   * @param  {[type]} page []
   * @return {[type]}      []
  ###
  @retryAfterTimeout = () =>
    if !@timedOut
      return
    @timedOut = false
    @fetchExperts(1, true)
    @checkExpertsAfterTimeout()

  ###*
   * [fetchExperts]
   * @param  {[type]} page []
   * @return {[type]}      []
  ###
  @fetchExperts = (page = 1, pullToRefresh = false) ->
    if @experts.length > 0 && !pullToRefresh
      return Experts.refreshStatus()

    return Experts.fetchAll().finally(=>
      $scope.$broadcast('scroll.refreshComplete')
    )

  ###*
   * [getAvailableConsultationCount]
   * @return {[type]} []
  ###
  @getAvailableConsultationCount = =>
    return $q.allSettled([
      @getAvailableChatCount()
      @getAvailableCallCount()
    ])

  ###*
   * [getAvailableChatCount]
   * @return {[type]} ]
  ###
  @getAvailableChatCount = =>
    return ApiTransactions.getApprovedTransactions(HelpApi.CONSULTATIONTYPES.CHAT)
    .then((response) =>
      if response.data?
        return @stats.chats = response.data.length
      return @stats.chats = 0
    )

  ###*
   * [getAvailableCallCount]
   * @return {[type]} []
  ###
  @getAvailableCallCount = =>
    return ApiTransactions.getApprovedTransactions(HelpApi.CONSULTATIONTYPES.CALL)
    .then((response) =>
      if response.data?
        return @stats.calls = response.data.length
      return @stats.calls = 0
    )

  ###*
   * [infiniteScroll]
   * @return {[type]} []
  ###
  @infiniteScroll = =>
    @infinite.max += @infinite.interval
    $scope.$broadcast('scroll.infiniteScrollComplete')
    return

  ###*
   * [openProfile]
   * @param  {int}    expertId []
   * @param  {Object} expert   []
   * @return
  ###
  @openProfile = (expertId, expert) ->
    if $scope.scrollPreventsClick
      return

    $state.go('^.expertprofile' , {id: expertId, expert: expert})
    return

  ###*
   * [showBalancePopover]
   * @param  {[type]} $event []
   * @return {[type]}        []
  ###
  @showBalancePopover = ($event) =>
    @balancePopover.show($event)
    return

  ###*
   * [showConnectivityPopover]
   * @param  {[type]} $event []
   * @return {[type]}        []
  ###
  @showConnectivityPopover = ($event) =>
    @connectivityPopover.show($event)
    return

  ###*
   * [getFilteredCount]
   * @return {[type]} []
  ###
  @getFilteredCount = ->
    return ''

  ###*
   * [checkFilterCriteria]
   * @return {[type]} []
  ###
  @checkFilterCriteria = ->
    return (expert) ->
      return !ExpertFilter.isExpertFiltered( expert )

  ###*
   * [getSortArray]
   * @return {[type]} []
  ###
  @getSortArray = ->
    return ExpertFilter.getSortArray()

  ###*
   * [sortExperts]
   * @return {[type]} []
  ###
  @sortExperts = ->
    @sortedExperts = angular.copy( Experts.getAll() )
    sortCriteria = @getSortArray()

    if ( !@experts? )
      return

    @infinite.max = 10
    $ionicScrollDelegate.scrollTop()

    @sortedExperts.sort( (expA, expB) ->
      ###*
       * [resolve - resolve nested attributes]
       * @param  {[type]} obj []
       * @param  {[type]} key []
       * @return {[type]}     []
      ###
      resolve = (obj, key) ->
        if ( key.indexOf('.') < 0 )
          return obj[key]

        attribute = obj
        key = key.split('.')
        while ( key.length > 0 )
          if ( !attribute? )
            return null

          attribute = attribute[ key.shift() ]
        return attribute

      ###*
       * [sort ]
       * @param  {[type]} a         []
       * @param  {[type]} b         []
       * @param  {[type]} critIndex []
       * @return {[type]}           []
      ###
      sort = (a, b, critIndex = 0) ->
        crit = sortCriteria[ critIndex ]
        inverted = false

        if ( crit.indexOf('-') == 0 )
          crit = crit.substr(1)
          inverted = true

        aAttr = resolve(a, crit)
        bAttr = resolve(b, crit)

        if ( aAttr == bAttr )
          if ( critIndex < sortCriteria.length - 1 )
            return sort( a, b, ++critIndex )
          return 1

        if ( !inverted )
          return if (aAttr < bAttr) then 1 else -1

        return if (aAttr < bAttr) then -1 else 1

      return sort( expA, expB )
    )

  ###*
   * [clear]
   * @return {[type]} []
  ###
  @clear = =>
    @stats =
      chats : 0
      calls : 0
    return

  @init()
  return
)