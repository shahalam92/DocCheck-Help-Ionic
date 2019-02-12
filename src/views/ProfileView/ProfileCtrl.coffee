# Profile Controller

angular.module("HelpPatient.controllers").controller('ProfileCtrl', ($scope, $state, GA) ->

  $scope.$on('$ionicView.enter', ->
    GA.trackView('Profile')
  )
  
)