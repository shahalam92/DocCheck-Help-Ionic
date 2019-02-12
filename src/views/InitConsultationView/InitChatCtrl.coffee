angular.module("HelpPatient.controllers").controller('InitChatCtrl', ($scope, $log, DcLoading, ApiConsultations, DcXMPP) ->

  @parent = $scope.vm

  @targetState = 'chat'
  @translationIdent = 'INITCHATVIEW'
  @logger = $log.getInstance('InitChatView', 'color: #63F')

  ###*
   * [initializeChat]
   * @param  {[type]} paymentId [description]
   * @return {[type]}           [description]
  ###
  @initializeChat = (code, type) =>
    if type == @parent.PAYMENT_TYPES.VOUCHER
      approvalPromise = @parent.approveVoucherTransaction(code)
    else
      approvalPromise = @parent.approvePayPalTransaction(code)

    return approvalPromise
      .then(@createChat)
      .catch(@parent.catchError)

  ###*
   * [createChatConsultation]
   * @return {Deferred} []
  ###
  @createChatConsultation = =>
    DcLoading.show('translationKey' : @translationIdent + '.LOADING.INIT')
    return ApiConsultations.createChatConsultation(@parent.expert.id).then((response)=>
      @parent.consultationId = response.data.id
      DcXMPP.connect()
    )

  ###*
   * [createChat]
   * @return {[type]} []
  ###
  @createChat = =>
    return @createChatConsultation(@parent.expert)
      .then(@parent.getConsultations)
      .then(@parent.getConsultationDetails)
      .then(@parent.startConsultation)
      .catch(@parent.catchError)

  return
)