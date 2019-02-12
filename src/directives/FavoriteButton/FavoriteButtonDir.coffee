# FavoriteButton directive

angular.module("HelpPatient.directives").directive('favoriteButton', (Experts, $timeout, $state, $ionicGesture, GA) ->
  restrict: 'E'
  scope: false
  templateUrl: 'templates/FavoriteButtonTemplate.html'
  controller: 'FavoriteButtonCtrl'
  link: (scope, elem, attrs) ->
    scope.vm.addSuccess = false

    ###*
     * [init]
     * @return {[type]} []
    ###
    @init = =>
      @clickGesture = $ionicGesture.on('click', @addFavorite, elem)

      ###*
       * []
       * @return {[type]} []
      ###
      scope.$on('$destroy', ->
        $ionicGesture.off(@clickGesture, 'click', @addFavorite)
      )
      return

    ###*
     * [addFavorite]
    ###
    @addFavorite = ($event) ->
      $event?.preventDefault()
      $event?.stopPropagation()

      if ( $state.current.name.indexOf('.rating') > 0 )
        GA.trackEvent('Rating', 'favorite', 'add')

      Experts.addToFavorites(scope.vm.expert)
      .then(->
        scope.vm.addTriggered = true

        return $timeout(->
          scope.vm.addSuccess = true
        , 500)
      )
      .then(->
        return $timeout(->
          scope.vm.addedCallback?()
        , 2000, false)
      )
      .then(->
        return $timeout(->
          scope.vm.addSuccess = scope.vm.addTriggered = false
        , 200)
      )
      return

    @init()
    return

)