angular.module("HelpPatient.services").factory('CallIntro', ($ionicModal) ->

  ###*
   * [show]
   * @return {[type]} []
  ###
  show: ($scope) ->
    $ionicModal.fromTemplateUrl('templates/CallIntroModal.html',
      scope : $scope
      animation: 'slide-in-left'
    ).then((modal) ->
      $scope.callIntroModal = modal
      $scope.callIntroModal.show()
      $scope.hideModal = ->
        $scope.callIntroModal.hide()
    )

)

angular.module("HelpPatient.controllers").controller('CallIntroCtrl', ($rootScope, $scope, $ionicSlideBoxDelegate) ->

  ###*
   * [init]
   * @return {[type]} []
  ###
  @init = ->
    return

  ###*
   * [getSlideBox]
   * @return {[type]} []
  ###
  @getSlideBox = ->
    return $ionicSlideBoxDelegate.$getByHandle('CallIntroSlides')

  ###*
   * [nextSlide]
   * @return {[type]} []
  ###
  @nextSlide = ->
    @getSlideBox().next()
    return

  ###*
   * [nextSlide]
   * @return {[type]} []
  ###
  @previousSlide = ->
    @getSlideBox().previous()
    return

  ###*
   * [isFirstSlide]
   * @return {Boolean} []
  ###
  @isFirstSlide = ->
    return @getSlideBox().currentIndex() == 0

  ###*
   * [isLastSlide]
   * @return {Boolean} []
  ###
  @isLastSlide = ->
    return @getSlideBox().currentIndex() == @getSlideBox().slidesCount() - 1

  ###*
   * [hideModal]
   * @param  {[type]} modal []
   * @return {[type]}       []
  ###
  @hideModal = (modal) ->
    modal.hide().then(->
      modal.remove()
    )
    return

  @init()

  return
)