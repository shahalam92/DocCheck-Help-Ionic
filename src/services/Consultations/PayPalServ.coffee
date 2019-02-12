# PayPal service

angular.module("HelpPatient.services").factory("PayPal", ($rootScope, $log, Api, ApiConsultations) ->

  @logger = $log.getInstance('PayPal', 'color: #005')

  ###*
   * [initPaymentUI]
   * @return
  ###
  @initPaymentUI = =>
    if !PayPalMobile?
      @logger.debug('Plugin not avaiable in the browser!')
      return

    clientIDs =
      "PayPalEnvironmentSandbox"   : "AaVAiQAY2tJPKxLQY3t1F1ZLdQAJDP5uHNEtZAHigTygf-aMmZmMZFgcU0MShl3kEbgo8UNhuFr4gVHv"
      "PayPalEnvironmentProduction": "AThevT6kuypi-Kvjyy5yusEXvtYFDt6B0hd69kto-DdVkl46DNkR7NXkdeVwERDQY9uQBCu5biwuRGAV"
    PayPalMobile.init(clientIDs, =>
      @onPayPalMobileInit()
    )
    return

  ###*
   * [onAuthorizationCallback]
   * @param  {Object} authorization []
   * @return
  ###
  @onAuthorizationCallback = (authorization) =>
    @logger.debug('Authorization: ' + JSON.stringify(authorization, null, 4))
    return

  ###*
   * [createPayment]
   * @return {Object} [payment object]
  ###
  @createPayment = (price, name) ->
    # for simplicity use predefined amount
    # optional payment details for more information check [helper js file](https://github.com/paypal/PayPal-Cordova-Plugin/blob/master/www/paypal-mobile-js-helper.js)
    paymentDetails = new PayPalPaymentDetails(price, "0.00", "0.00")
    payment = new PayPalPayment(price, "EUR", name, "Sale", paymentDetails)
    return payment

  ###*
   * [configuration]
   * @return {Object} [payment config]
  ###
  @configuration = ->
    # for more options see `paypal-mobile-js-helper.js`
    config = new PayPalConfiguration(
      merchantName: "DocCheck Help"
      merchantPrivacyPolicyURL: "http://info.doccheck.com/de/privacy/"
      merchantUserAgreementURL: "http://info.doccheck.com/de/termsofuse/"
      acceptCreditCards: false
    )
    return config

  ###*
   * [triggerPayment]
   * @param  {Function} successCallback []
   * @param  {Function} cancelCallback  []
   * @return
  ###
  @triggerPayment = (consultationType, successCallback, cancelCallback, price, name) =>
    if !PayPalMobile?
      @logger.debug('Plugin not avaiable in the browser! ')
      return
    PayPalMobile.renderSinglePaymentUI(@createPayment(price, name), successCallback, cancelCallback)
    return

  ###*
   * [triggerFuturePayment]
   * @return
  ###
  @triggerFuturePayment = =>
    PayPalMobile.renderFuturePaymentUI(@onAuthorizationCallback, @onUserCanceled)
    return

  ###*
   * [triggerProfileSharing]
   * @return
  ###
  @triggerProfileSharing = =>
    PayPalMobile.renderProfileSharingUI(["profile", "email", "phone", "address", "futurepayments", "paypalattributes"], @onAuthorizationCallback, @onUserCanceled)
    return

  ###*
   * [onPayPalMobileInit]
   * @return
  ###
  @onPayPalMobileInit = =>
    # must be called
    # use PayPalEnvironmentNoNetwork mode to get look and feel of the flow
    if ( Api.isProductionEnv() )
      PayPalMobile.prepareToRender("PayPalEnvironmentProduction", @configuration(), ->)
    else
      PayPalMobile.prepareToRender("PayPalEnvironmentSandbox", @configuration(), ->)

  return @
)