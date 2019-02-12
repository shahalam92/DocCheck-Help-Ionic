# PaymentHistory Controller

angular.module("HelpPatient.controllers").controller('PaymentHistoryCtrl', ($scope, $state, GA) ->

  $scope.$on('$ionicView.enter', ->
    GA.trackView('PaymentHistory')
  )
  
)