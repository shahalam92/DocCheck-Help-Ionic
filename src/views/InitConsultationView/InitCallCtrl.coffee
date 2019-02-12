angular.module("HelpPatient.controllers").controller('InitCallCtrl', ($scope, $log, DcLoading, ApiConsultations) ->

  @parent = $scope.vm

  @targetState = 'call'
  @translationIdent = 'INITCALLVIEW'
  @logger = $log.getInstance('InitCallView', 'color: #63F')

  ###*
   * [initializeCall]
   * @param  {[type]} paymentId []
   * @return {[type]}           []
  ###
  @initializeCall = (code, type) =>
    if type == @parent.PAYMENT_TYPES.VOUCHER
      approvalPromise = @parent.approveVoucherTransaction(code)
    else
      approvalPromise = @parent.approvePayPalTransaction(code)
    approvalPromise

    return approvalPromise
      .then(@createCall)
      .catch(@parent.catchError)

  ###*
   * [createCallConsultation]
   * @return {Deferred} []
  ###
  @createCallConsultation = =>
    DcLoading.show('translationKey' : @translationIdent + '.LOADING.INIT')
    return ApiConsultations.createCallConsultation(@parent.expert.id).then((response)=>
      @parent.consultationId = response.data.id
    )

  ###*
   * [createCall]
   * @return {[type]} []
  ###
  @createCall = =>
    return @createCallConsultation(@parent.expert)
      .then(@parent.getConsultations)
      .then(@parent.getConsultationDetails)
      .then(@parent.startConsultation)
      .catch(@parent.catchError)

  return
)