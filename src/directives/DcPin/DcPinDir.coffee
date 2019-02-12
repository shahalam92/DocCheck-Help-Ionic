# DcPin directive

angular.module("HelpPatient.directives").directive('dcPin', ($timeout) ->
  restrict: 'E'
  scope:
    pinModel: '='
    pinLength: '@'
  templateUrl: 'templates/DcPinTemplate.html'
  controller: 'DcPinCtrl as dcp'
  bindToController: true
  link: (scope, element, attrs) ->

    ###*
     * [focus]
     * @param  {[type]} index []
     * @return {[type]}       []
    ###
    scope.focus = (index) ->
      input = element.find('#dc-pin' + index)
      if input?
        input.focus()
      if input[0]?
        input[0].focus()
      return

    ###*
     * [blur ]
     * @param  {[type]} index []
     * @return {[type]}       []
    ###
    scope.blur = (index) ->
      input = element.find('#dc-pin' + index)
      if input?
        input.blur()
      if input[0]?
        input[0].blur()

      $timeout(->
        $('body').removeClass('keyboard-open')
      , 600, false)
      return
)