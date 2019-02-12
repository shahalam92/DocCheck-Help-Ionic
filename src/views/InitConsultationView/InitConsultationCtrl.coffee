
# InitChat Controller

angular.module("HelpPatient.controllers").controller('InitConsultationCtrl', ($scope, $state, $q, $controller, $timeout, $ionicHistory, $ionicTabsDelegate, $ionicNativeTransitions, $ionicPopup, $ionicModal, $filter, PayPal, Constants, DcErrorParser, HelpApi, ApiConsultations, ApiTransactions, Authentication, Tools, Consultations, Experts, GA, DcXMPP, DcLoading, ApiToS, ApiPrivacy, CallIntro, Facebook) ->

  @currentConsultationType = $state.params.consultationType

  @expert = Experts.get($state.params.expert.id).current

  $scope.vm = @

  if @currentConsultationType == HelpApi.CONSULTATIONTYPES.CHAT
    angular.extend(@, $controller('InitChatCtrl',
      $scope: $scope
    ))
  else
    angular.extend(@, $controller('InitCallCtrl',
      $scope: $scope
    ))

  @VOUCHERLENGTH = 12

  @PAYMENT_TYPES =
    PAYPAL : 0
    VOUCHER: 1

  @paymentMethod = @PAYMENT_TYPES.PAYPAL
  @agb =
    checked : false

  @consultationId = undefined
  @voucherModel = ''
  @price = @priceString = undefined

  @credit = undefined
  @isFirstChat = false

  ###*
   * [init]
   * @return {[type]} []
  ###
  @init = =>
    $scope.$on('$ionicView.enter', =>
      GA.trackView('InitChat')

      @upToDate = false
      @price = @priceString = undefined

      @runningConsultations = Consultations.getActiveWithExpert(@expert.id)

      @isFirstChat = false
      @retrieveConsultationTypes()
      @checkToSState()

      @initializeErrorWatcher()
    )

    $scope.$on('$ionicView.leave', =>
      @errorWatcher?()
      @voucherModelWatcher?()
    )

  ###*
   * [isCall ]
   * @return {Boolean} []
  ###
  @isCall = =>
    return @currentConsultationType == HelpApi.CONSULTATIONTYPES.CALL

  ###*
   * [openIntroModal]
   * @return {[type]} ]
  ###
  @openIntroModal = () ->
    CallIntro.show($scope)
    return

  ###*
   * [getTranslation]
   * @param  {[type]} 'key' []
   * @return {[type]}       []
  ###
  @getTranslation = (key, params) =>
    return $filter('translate')(@translationIdent + '.' + key, params)

  ###*
   * [initializeErrorWatcher]
   * @return {[type]} []
  ###
  @initializeErrorWatcher = =>
    @errorWatcher = $scope.$watchGroup([=>
      return @paymentMethod
    , =>
      return @voucherModel
    ], (n, o) =>
      @initializationError = undefined
    )

  ###*
   * [retrieveConsultationTypes]
   * @return {[type]} []
  ###
  @retrieveConsultationTypes = =>
    @error = false

    ApiConsultations.getConsultationTypes()
    .catch((err) =>
      @error = true
    )
    .then((response) =>
      for type in response.data
        if type.id == @currentConsultationType
          @price = Math.round(type.price_netto * 119) / 100
          @priceString = (@price.toFixed(2) + '').replace('.', ',')
          @name = type.name

      return ApiTransactions.getApprovedTransactions(@currentConsultationType)
    ).then((response) =>
      if response.data?
        @credit = response.data.length

      if (@credit == 1 && @currentConsultationType == HelpApi.CONSULTATIONTYPES.CHAT)
        @isFirstChat = Consultations.all.filter((consultation) ->
          return consultation.consultation_type.id == HelpApi.CONSULTATIONTYPES.CHAT
        ).length == 0

      return HelpApi.getSettings()
    ,
      HelpApi.getSettings
    ).then((response) =>
      if ( response["data"]?["expire_pending_consultation_hours"]? )
        @expiryInHours = response["data"]["expire_pending_consultation_hours"]
    ).finally(=>
      if @price?
        @upToDate = true
    )

  ###*
   * [setPaymentMethod]
   * @param {[type]} method []
  ###
  @setPaymentMethod = (method) =>
    if @paymentMethod != method
      @paymentMethod = method

      if @paymentMethod == @PAYMENT_TYPES.VOUCHER
        $timeout(->
          $('#voucherInput').focus()
        )
    return

  ###*
   * [leaveInitialization]
   * @return
  ###
  @leaveInitialization = =>
    @voucherModel = ''
    @price = @priceString = undefined
    @upToDate = false
    @agb.checked = false

    delay = 0
    if (Keyboard?.isVisible)
      Keyboard?.hide?()
      Keyboard?.close?()
      angular.element('body').removeClass('keyboard-open')
      delay = 300

    $timeout(() ->
      if ionic.Platform.isAndroid()
        $ionicNativeTransitions.goBack()
        return

      $ionicHistory.goBack()
    , delay)
    return

  ###*
   * [initPayment]
   * @return {[type]} []
  ###
  @initPayment = =>
    @checkAuthenticationState()
      .then(=>
        return @checkIdentity()
      )
      .then(=>
        return @acceptToS()
      )
      .then(=>
        if @credit > 0
          return @createConsultation()

        switch @paymentMethod
          when @PAYMENT_TYPES.VOUCHER then @initVoucherPayment()
          when @PAYMENT_TYPES.PAYPAL  then @initPaypalPayment()
          else @logger.warn('Unknown payment method!')
      )

  ###*
   * [initVoucherPayment]
   * @return {[type]} []
  ###
  @initVoucherPayment = =>
    if @voucherModel.replace(/-/gmi, '').length < @VOUCHERLENGTH
      @voucherError = $filter('translate')('INITCONSULTATION.VOUCHER.LENGTH', {
        length : @VOUCHERLENGTH
      })
      return

    @initializeConsultation(@voucherModel.replace(/-/gmi, ''), @PAYMENT_TYPES.VOUCHER)
    return

  ###*
   * [initPaypalPayment]
   * @return
  ###
  @initPaypalPayment = =>
    if !@agb.checked
      return

    if !ionic.Platform.isWebView() || ionic.Platform.is('browser')
      mockedPaymentResponse = {
        "client":
          "environment": "sandbox",
          "product_name": "PayPal iOS SDK",
          "paypal_sdk_version": "2.12.7",
          "platform": "iOS"
        "response":
          "id": Date.now() + '', #"PAY-5C532516TG997374WK2KLCNI",
          "state": "approved",
          "create_time": "2016-01-12T07:54:34Z",
          "intent": "sale"
        "response_type": "payment"
      }

      $ionicPopup.prompt(
        title           : 'PayPal Payment ID',
        inputType       : 'text',
        inputPlaceholder: 'Payment ID',
        #defaultText     : 'PAY-5C532516TG997374WK2KLCNI'
        cssClass        : 'paypal-popup'
      )
      .then((res) =>
        if !res?
          DcLoading.hide()
          return

        mockedPaymentResponse.response.id = res
        @successfulPaymentCallback(mockedPaymentResponse)
        return
      )
      return

    PayPal.triggerPayment(
      @currentConsultationType,
      @successfulPaymentCallback,
      @userCanceledCallback,
      @price,
      @name
    )
    return

  ###*
   * [successfulPaymentCallback]
   * @param  {JSON Object} payment []
    {
      "client":
      {
        "environment": "sandbox",
        "product_name": "PayPal iOS SDK",
        "paypal_sdk_version": "2.12.7",
        "platform": "iOS"
      }
      "response":
      {
        "id": "PAY-5C532516TG997374WK2KLCNI",
        "state": "approved",
        "create_time": "2016-01-12T07:54:34Z",
        "intent": "sale"
      }
      "response_type": "payment"
   }
   *
   * @return
  ###
  @successfulPaymentCallback = (payment) =>
    @logger.debug('Payment response | ', 'color: #005; font-weight: 700', payment)

    strConsultationType = 'Chat'
    if (@currentConsultationType == HelpApi.CONSULTATIONTYPES.CALL)
      strConsultationType = 'Call'

    Facebook.trackEvent('PayPal Purchase ' + strConsultationType)
    Facebook.trackPurchase(@price)

    ionic.trigger('native.keyboardhide')
    $timeout(->
      ionic.trigger('native.keyboardhide')
    )

    DcLoading.show()

    return @initializeConsultation(payment.response.id, @PAYMENT_TYPES.PAYPAL)

  ###*
   * [checkToSState]
   * @return {[type]} []
  ###
  @checkToSState = ->
    return ApiToS.isAccepted()
    .then(=>
      @agb.hidden = @agb.checked = true
    , =>
      @agb.hidden = @agb.checked = false
    )

  ###*
   * [acceptToS]
   * @return {[type]} []
  ###
  @acceptToS = ->
    DcLoading.show()

    return ApiToS.accept()
      .finally(->
        DcLoading.hide()
      )

  ###*
   * [checkAuthenticationState]
   * @param  {Function} callback []
   * @return {[type]}            []
  ###
  @checkAuthenticationState = ->
    return $q((resolve, reject) ->
      Authentication.isValid('PATIENT')
        .then(resolve
        , ->
          $timeout(->
            DcLoading.hide()
            $state.go('^.login',
              callback        : reject
              allowBack       : true
              omitHistoryClear: true
            )
          )
        )
        .catch(->
          DcLoading.hide()
        )
    )

  ###*
   * [checkIdentity]
   * @return {[type]} []
  ###
  @checkIdentity = ->
    return $q((resolve, reject) =>
      if ( Authentication.getUser().id == @expert.id )
        @initializationError = $filter( 'translate' )( 'INITCONSULTATION.ERROR.IDENTITY' )
        reject()
        return
      resolve()
    )

  ###*
   * [userCanceledCallback]
   * @param  {JSON Object} result []
   * @return
  ###
  @userCanceledCallback = (result) =>
    @logger.debug('Payment cancelled | ', 'color: #005; font-weight: 700', result)

  ###*
   * [initializeConsultation ]
   * @return {[type]} []
  ###
  @initializeConsultation = (code, type) ->
    if @currentConsultationType == HelpApi.CONSULTATIONTYPES.CHAT
      return @initializeChat(code, type)
    return @initializeCall(code, type)

  ###*
   * [initializeConsultation ]
   * @return {[type]} []
  ###
  @createConsultation = =>
    if @currentConsultationType == HelpApi.CONSULTATIONTYPES.CHAT
      return @createChat(@expert)
    return @createCall(@expert)

  ###*
   * [catchError ]
   * @param  {[type]} error []
   * @return {[type]}       []
  ###
  @catchError = (error) =>
    @logger.warn('ChatConsultation creation process failed | %o', error)
    DcLoading.hide()

    if !( error?.data? )
      @initializationError = DcErrorParser.parse().first
      return

    @initializationError = DcErrorParser.parse(error.data).first
    return

  ###*
   * [approveVoucherTransaction]
   * @param  {[type]} voucher []
   * @return {[type]}         []
  ###
  @approveVoucherTransaction = (voucher) =>
    DcLoading.show('translationKey' : @translationIdent + '.LOADING.VOUCHER')

    return ApiTransactions.approveVoucher(@currentConsultationType, voucher)
    .then(=>
      @voucherModel = ''
    )

  ###*
   * [approvePayPalTransaction]
   * @return {Deferred} []
  ###
  @approvePayPalTransaction = (paymentId) =>
    DcLoading.show('translationKey' : @translationIdent + '.LOADING.VALIDATE')

    return ApiTransactions.approvePayPalTransaction(@currentConsultationType, paymentId)

  ###*
   * [getConsultations]
   * @param  {[type]} response []
   * @return {Deferred}        []
  ###
  @getConsultations = (response) =>
    DcLoading.show('translationKey' : @translationIdent + '.LOADING.PREPARE')
    return Consultations.fetchActive()

  ###*
   * [getConsultationDetails]
   * @param  {[type]} response []
   * @return {Deferred}        []
  ###
  @getConsultationDetails = (response) =>
    DcLoading.show('translationKey' : @translationIdent + '.LOADING.PREPARE')
    return Consultations.get(@consultationId).fetch

  ###*
   * [startChat]
   * @param  {[type]} response []
   * @return {[type]}          []
  ###
  @startConsultation = (consultation) =>
    DcLoading.show('translationKey' : @translationIdent + '.LOADING.START')

    @agb.checked = false

    $ionicTabsDelegate.select(1)
    $state.go('tabs.consultations.overview', {consultation: consultation})
    .then(=>
      $timeout =>
        $state.go('^.' + @targetState, {id: consultation.id, consultation : consultation})

        @price = @priceString = undefined
        @upToDate = false

        DcLoading.hide()
    )

  ###*
   * [showPrivacyOrToS]
   * @param  {[type]} $event []
   * @return {[type]}        []
  ###
  @showPrivacyOrToS = ($event) =>
    if ($event?.target?.id == 'terms')
      ApiToS.showToSModal($scope)
    else if ($event?.target?.id == 'privacy')
      ApiPrivacy.showPrivacyModal($scope)

    return

    $event.preventDefault()
    $event.stopPropagation()

    @preparePrivacyModal().then(=>
      @privacyModal.show()
    )
    return

  ###*
   * [prepareTermsModal]
   * @return {[type]} []
  ###
  @preparePrivacyModal = =>
    if @privacyModal?
      return $q.resolve()

    return $ionicModal.fromTemplateUrl('templates/PrivacyModalTemplate.html',
      scope : $scope
      animation: 'scale-in-if'
    ).then((modal) =>
      modal.hide()

      @privacyModal = modal
      $scope.$on('$destroy', @privacyModal.remove)
    )

  ###*
   * [goBack]
   * @return {[type]} []
  ###
  @goBack = ->
    $ionicHistory.goBack()
    return

  ###*
   * [openActiveConsultation]
   * @return {[type]} []
  ###
  @openActiveConsultation = ->
    $ionicTabsDelegate.select(1)
    $state.go('tabs.consultations.overview')

    if ( @runningConsultations.length == 1 )
      runningConsultation = @runningConsultations[0]

      $timeout(->
        $state.go('tabs.consultations.' + runningConsultation.consultation_type.ident,
          id : runningConsultation['id']
        )
      , 100, false)

  @init()

  return
)