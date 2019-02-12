angular.module("HelpPatient.controllers").controller("WelcomePopup", ($scope) ->

  ###*
   * [hide]
   * @return {[type]} []
  ###
  @hide = () ->
    $scope.$parent.welcomePopup.close()
    return

  return
  
)