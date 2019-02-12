# Notifications Controller

angular.module("HelpPatient.controllers").controller('NotificationsCtrl', ($scope, $state, GA) ->

  $scope.$on('$ionicView.enter', ->
    GA.trackView('Notifications')
  )
  
)