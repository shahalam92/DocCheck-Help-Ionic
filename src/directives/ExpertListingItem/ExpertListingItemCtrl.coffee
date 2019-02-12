# ExpertListingItem Controller

angular.module("HelpPatient.controllers").controller('ExpertListingItemCtrl', ($scope, $state, $timeout, $ionicLoading, $interval, FavoriteExperts, Experts) ->

  ###*
   * [init description]
   * @return {[type]} [description]
  ###
  @init = =>
    $scope.$on('expert-remove-if-flagged', =>
      if @removalFlag
        @removeFavorite()
      @removalFlag = false
    )
    return

  ###*
   * [toggleFavoriteState]
   * @param  {Event} $event []
   * @return
  ###
  @toggleFavoriteState = ($event) =>
    $event?.preventDefault()
    $event?.stopPropagation()

    return @removalFlag = !@removalFlag

  ###*
   * [addFavorite]
  ###
  @addFavorite = ($event) =>
    $event?.preventDefault()
    $event?.stopPropagation()

    return Experts.addToFavorites(@expert())

  ###*
   * [removeFavorite]
   * @return
  ###
  @removeFavorite = =>
    return Experts.removeFromFavorites(@expert())

  ###*
   * [initChat]
   * @param  {Event} $event  []
   * @return
  ###
  @initChat = ($event) ->
    if $scope.$parent.scrollPreventsClick
      return

    $event.preventDefault()
    $event.stopPropagation()

    $state.go('^.initchat',
      id     : @expert().id
      expert : @expert()
    ,
      reload: true
    )
    return

  ###*
   * [initChat]
   * @param  {Event} $event  []
   * @return
  ###
  @initCall = ($event) ->
    if $scope.$parent.scrollPreventsClick
      return

    $event.preventDefault()
    $event.stopPropagation()

    if ( @expert().state == 'offline' )
      return

    $state.go('^.initcall',
      id     : @expert().id
      expert : @expert()
    ,
      reload: true
    )
    return

  @init()

  return
)