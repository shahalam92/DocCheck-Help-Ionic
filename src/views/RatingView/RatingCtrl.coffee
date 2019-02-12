# Rating Controller

angular.module("HelpPatient.controllers").controller('RatingCtrl', ($scope, $state, $ionicLoading, $ionicHistory, $ionicNativeTransitions, $timeout, Consultations, Experts, ApiConsultations, FavoriteExperts, GA) ->

  angular.extend(@, $state.params)

  @comment      = ''
  @points       = 0

  @consultation = Consultations.get($state.params.consultation).consultation
  @expert       = Experts.get(@consultation.expert_user.id).current

  $scope.vm = @

  ###*
   * [init]
   * @return {[type]} []
  ###
  @init = =>
    $scope.$on('$ionicView.enter', ->
      GA.trackView('Rating')
    )

    $scope.$on('$ionicView.leave', =>
      @comment = ''
      @points  = 0
    )

  ###*
   * [submitRating]
   * @return {[type]} []
  ###
  @submitRating = ($event) =>
    $ionicLoading.show(
      template: '<ion-spinner icon="spiral"></ion-spinner><div class="loading-hint" translate="RATING.SUBMITTING"></div>',
    )

    @comment = @comment.trim()

    trackingLabel = 'uncommented'
    if ( @comment.length > 0 )
      trackingLabel = 'commented'

    GA.trackEvent('Rating', 'sendRating', trackingLabel, @points)

    ApiConsultations.addConsultationReview(@consultation.id, @points, @comment)
    .then((response) =>
      $ionicLoading.show(
        template: '<div class="loading-hint" translate="RATING.THANKS"></div>',
      )

      return $timeout(=>
        if $ionicHistory.backView().stateName.indexOf('chat') > 0
          if ionic.Platform.isAndroid()
            $ionicNativeTransitions.goBack()
          else
            $ionicHistory.goBack()

        $timeout(=>
          @consultation.review = response.data
        , 1000, false)
      , 1500)
      .then(->
        return $timeout(->
          if ionic.Platform.isAndroid()
            $ionicNativeTransitions.goBack()
          else
            $ionicHistory.goBack()
        )
      )
    )
    .finally(->
      $ionicLoading.hide()
    )

  ###*
   * [hideKeyboard]
   * @return {[type]} []
  ###
  @hideKeyboard = =>
    @hiding = true

    $timeout(() =>
      @hiding = false
      angular.element( 'body' ).removeClass( 'keyboard-open' )
    , 500)
    return

  ###*
   * [back]
   * @return {[type]} []
  ###
  @back = ->
    if ionic.Platform.isAndroid()
      $ionicNativeTransitions.goBack()
    else
      $ionicHistory.goBack()

  @init()

  return
  
)