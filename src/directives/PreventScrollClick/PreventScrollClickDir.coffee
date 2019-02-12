# PreventScrollClick directive

angular.module("Help.directives").directive('preventScrollClick', ($ionicScrollDelegate, $ionicGesture) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    tagName = element[0].tagName.toUpperCase()

    @viewScope = scope.$parent

    if ( tagName == 'ION-SCROLL' )
      scrollScope = scope.$parent
      @viewScope = scrollScope.$parent

    @INTERVAL = 100

    @lastPos = 0
    @lastStamp = 0
    @shifts = [0, 0, 0]

    ###*
     * [init]
     * @return {[type]} []
    ###
    @init = ->
      viewScope.$on('$ionicView.afterEnter', @onEnter)
      viewScope.$on('$ionicView.leave', @onLeave)
      return

    ###*
     * [onEnter ]
     * @return {[type]} []
    ###
    @onEnter = ->
      @viewScope = scope.$parent

      if element[0].tagName.toUpperCase() == 'ION-SCROLL'
        scrollScope = scope.$parent
        @viewScope = scrollScope.$parent

      @interrupted = false
      @onScroll()
      return

    ###*
     * [onLeave ]
     * @return {[type]} []
    ###
    @onLeave = ->
      @viewScope.scrollPreventsClick = false
      @interrupted = true
      return

    ###*
     * [onTap]
     * @param  {[type]} event []
     * @return {[type]}       []
    ###
    @checkPreventState = ->
      if ( Math.max.apply( null, @shifts ) > 5 )
        if ( !@viewScope.scrollPreventsClick )
          @viewScope.scrollPreventsClick = true
        return

      if @viewScope.scrollPreventsClick
        @viewScope.scrollPreventsClick = false
      return

    ###*
     * [onScroll ]
     * @return {[type]} []
    ###
    @onScroll = =>
      if Date.now() - @lastStamp > 100
        scrollPosition = $ionicScrollDelegate.getScrollPosition()

        if ( !scrollPosition? )
          return

        currentTop = scrollPosition.top
        @shifts.push( Math.abs(@lastPos - currentTop) )
        @shifts.shift()
        @lastPos = currentTop
        @lastStamp = Date.now()
        @checkPreventState()

      if !@interrupted
        ionic.DomUtil.requestAnimationFrame(@onScroll)
      else
        @viewScope.scrollPreventsClick = false

      return

    @init()
)