# DcPasswordReset service

angular.module("HelpPatient.services").factory("DcPasswordReset", ($filter, $ionicLoading, $timeout, $ionicPopup, ApiUser, Tools, DcErrorParser) ->

  ###*
   * [init - initialize the service]
   * @return {[type]} []
  ###
  @init = ->
    return

  ###*
   * Insert service functions here
  ###

  ###*
   * [showInfoPopup]
   * @return {[type]} []
  ###
  @showInfoPopup = =>
    @vm.password = ''

    @vm.infoPopup = $ionicPopup.prompt(
      title: $filter('translate')('LOGIN.PASSWORD_RESET_INFO.TITLE')
      templateUrl: 'templates/DcPasswordResetInfo.html'
      cssClass: 'dc-popup'
      scope: @scope
      buttons: []
    )

    @vm.dcPasswordReset.info =
      confirm : @initializePasswordReset
      cancel  : ($event) =>
        $event.preventDefault()
        $event.stopPropagation()
        @vm.infoPopup.close()
        return

  ###*
   * [initializePasswordReset]
   * @return {[type]} []
  ###
  @initializePasswordReset = =>
    @vm.infoPopup.close()

    delete @vm.dcPasswordReset.info

    @triggerResetPasswordMail()
    .then(@showResetPopup)
    .catch((error) =>
      @vm.currentState = @vm.state.ERROR
      @vm.currentError = DcErrorParser.parse(error.data).first
    )

  ###*
   * [show]
   * @return {[type]} []
  ###
  @showResetPopup = =>
    @vm.reset =
      code : ''

    @codeWatcher = @scope.$watch(=>
      return @vm.reset.code
    , (n, o) =>
      @vm.dcPasswordReset.submitted = false
      @vm.reset.code = Tools.splitStringIntoBrackets(n, o, 4)
    )

    @passwordWatcher = @scope.$watch(=>
      return @vm.reset.password
    , (n, o) =>
      @vm.dcPasswordReset.submitted = false
    )

    @vm.formPopup = $ionicPopup.confirm(
      scope: @scope
      title: $filter('translate')('LOGIN.PASSWORD_RESET_INPUT.TITLE')
      cssClass: 'dc-popup login-password-reset'
      templateUrl: 'templates/DcPasswordResetForm.html' #@prepareResetPopupTemplate()
      buttons: []
    )

    @vm.dcPasswordReset.form =
        confirm : @submitPasswordReset
        cancel  : ($event) =>
          delete @vm.dcPasswordReset

          $event.preventDefault()
          $event.stopPropagation()
          @codeWatcher?()
          @passwordWatcher?()
          @vm.formPopup.close()
          return

    return


  ###*
   * [submitPasswordReset]
   * @param  {[type]} $event []
   * @return {[type]}   []
  ###
  @submitPasswordReset = ($event) =>
    $event?.preventDefault()

    if !@vm.dcPasswordReset.valid
      @vm.dcPasswordReset.submitted = true
      return

    if @vm.reset.code.length > 0 && (@vm.reset.password?) && @vm.reset.password.length >= 6

      $ionicLoading.show(
        template: '
          <ion-spinner icon="spiral"></ion-spinner>
          <div class="loading-hint" translate="LOGIN.RESETTING_PASSWORD.PENDING"></div>
        ',
      )
      ApiUser.resetPassword(@vm.username, @vm.reset.code, @vm.reset.password)
      .then(=>
        @vm.reset.password = @vm.reset.code = ''

        delete @vm.dcPasswordReset
        @vm.formPopup.close()
        @vm.formPopup = undefined
        @codeWatcher?()
        @passwordWatcher?()

        return $timeout(->
          $ionicLoading.show(
            template: '
              <ion-spinner icon="spiral"></ion-spinner>
              <div class="loading-hint" translate="LOGIN.RESETTING_PASSWORD.SUCCESS"></div>
            ',
          )
        , 2000)
        .then(->
          $ionicLoading.hide()
        )
      )
      .catch((result) =>
        @vm.dcPasswordReset.error = DcErrorParser.parse(result.data).first
        @vm.dcPasswordReset.submitted = true

        return $timeout(->
          $ionicLoading.show(
            template: '
              <ion-spinner icon="spiral"></ion-spinner>
              <div class="loading-hint" translate="LOGIN.RESETTING_PASSWORD.FAILED"></div>
            ',
          )
        , 2000)
        .then(->
          $ionicLoading.hide()
        )
      )

  ###*
   * [triggerResetPasswordMail]
   * @return {[type]} []
  ###
  @triggerResetPasswordMail = =>
    $ionicLoading.show(
      template: '
        <ion-spinner icon="spiral"></ion-spinner>
        <div class="loading-hint" translate=""></div>
      ',
    )

    return ApiUser.triggerResetPasswordMail(@vm.username)
    .finally($ionicLoading.hide)

  ###*
   * [show]
   * @param  {[type]} scope []
   * @return {[type]}       []
  ###
  @show = (scope) =>
    @scope = scope
    @vm = scope.vm

    @vm.dcPasswordReset =
      valid    : false
      submitted: false
      error    : ''

    @showInfoPopup()
    return

  ###*
   * Call to init
  ###
  @init()

  ###*
   * Exposed functions for service
  ###
  return @
)