# ConsultationListingItem Controller

angular.module("Help.controllers").controller('ConsultationListingItemCtrl', (Consultations, Experts) ->

  @STATE             = Consultations.STATE

  ###*
   * [init]
   * @return {[type]} []
  ###
  @init = =>
    if @consultation().isChat()
      @type = 'chat'
    else
      @type = 'call'

  ###*
   * [getClasses]
   * @return {[type]} []
  ###
  @getClasses = =>
    classes = ''

    # unread stuff highlighting
    if @consultation().unreadMessageCount > 0
      classes += 'unread '

    # expert availability
    if @consultation().expert_user.state != 'offline '
      classes += 'available '

    switch @consultation().status
      when @STATE.PREPARE
        classes += 'prepare' # fa-pencil '
      when @STATE.REJECTED || @STATE.CANCELED
        classes += 'rejected ended' # fa-close-bold
      when @STATE.PENDING
        classes += 'pending' # fa-comment-wait '
      when @STATE.ACTIVE
        classes += 'active' # fa-comment '
      when @STATE.CLOSURE_AWAITING
        classes += 'closure-awaiting' # fa-comment-question '
      when @STATE.CLOSURE_ACKNOWLEDGED
        classes += 'closure-awaiting'
      when @STATE.CLOSED
        classes += 'closed ended' # fa-check-bold'
      when @STATE.EXPIRED
        classes += 'expired ended' # fa-check-bold'
      when @STATE.CANCELED
        classes += 'rejected ended' #fa-close-bold'
      when @STATE.ERROR
        classes += 'rejected error' #fa-ask'

    return classes

  @init()

  return
  
)