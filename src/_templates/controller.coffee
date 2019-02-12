# <%= name %> Controller

angular.module("<%= app %>.controllers").controller('<%= name %>Ctrl', ($scope, $state) ->

  @watcher  = []
  @listener = []


  ###*
   * [init - intialize the controller]
   * @return
  ###
  @init = ->

    ###*
     * [do all the recurrent view and controller preparation here]
     * @return
    ###
    $scope.$on('$ionicView.enter', ->

    )

    ###*
     * [clean up controller before leaving]
     * @return {[type]} [description]
    ###
    $scope.$on('$ionicView.leave', =>
      
      for watcher in @watcher
        watcher?()

      for listener in @listener
        listener?()
    )
    return

  ###*
   * Insert code here
  ###



  ###*
   * End of code section
  ###

  # call to init function
  @init()

  return
)