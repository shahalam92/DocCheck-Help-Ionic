# Impress Controller

angular.module("HelpPatient.controllers").controller('ImpressCtrl', ($scope, $state, GA) ->

  $scope.$on('$ionicView.enter', ->
    GA.trackView('Impress')
  )
  
)