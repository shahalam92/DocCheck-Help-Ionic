# Balance Controller

angular.module("HelpPatient.controllers").controller('BalanceCtrl', ($scope, $state, GA) ->

  $scope.$on('$ionicView.enter', ->
    GA.trackView('Balance')
  )

  
)