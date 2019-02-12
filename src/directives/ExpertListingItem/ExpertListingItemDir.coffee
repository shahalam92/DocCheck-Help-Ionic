# ExpertListingItem directive

angular.module("HelpPatient.directives").directive('expertListingItem', ->
  restrict: 'E'
  scope:
    expert: '&'
  templateUrl: 'templates/ExpertListingItemTemplate.html'
  bindToController: true
  controller: 'ExpertListingItemCtrl as eli'
)