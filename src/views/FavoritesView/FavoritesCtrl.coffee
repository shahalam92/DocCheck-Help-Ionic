# Favorites Controller

angular.module("HelpPatient.controllers").controller('FavoritesCtrl', ($scope, $state, $q, $timeout, FavoriteExperts, Authentication, Tools, Experts, GA) ->

  @experts = Experts.getAll()

  @expertIds = []

  @editFavorites = false

  @listeners = []

  ###*
   * [$ionicView - beforeEnter]
   * @return
  ###
  @listeners.push $scope.$on('$ionicView.beforeEnter', =>
    @editFavorites = false
  )

  $scope.$on('$ionicView.enter', ->
    GA.trackView('Favorites')
  )

  ###*
   * * [$ionicView - leave]
   * @return
  ###
  @listeners.push $scope.$on('$ionicView.leave', =>
    @editFavorites = false
  )

  ###*
   * [$destroy]
   * @return
  ###
  $scope.$on('$destroy', =>
    for listener in @listeners
      listener?()
  )

  ###*
   * [openProfile]
   * @param  {Object} expert []
   * @return
  ###
  @openProfile = (expert) =>
    if $scope.scrollPreventsClick
      return

    if @editFavorites
      return

    $state.go('^.expertprofile', {id: expert.id, expert: expert})
    return

  ###*
   * [toggleEditFavorites]
   * @return
  ###
  @toggleEditFavorites = =>
    if !@editFavorites && @experts.length == 0
      return
      
    @editFavorites = !@editFavorites
    if ( @editFavorites )
      GA.trackEvent('Expert', 'favorite', 'edit')

    if !@editFavorites
      $scope.$broadcast('expert-remove-if-flagged')
    return

  return
  
)