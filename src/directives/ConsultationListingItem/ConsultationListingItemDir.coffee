# ConsultationListingItem directive

angular.module("HelpPatient.directives").directive('consultationListingItem', ->
  restrict: 'E'
  scope:
    consultation: '&'
  templateUrl: 'templates/ConsultationListingItemTemplate.html'
  bindToController: true
  controller: 'ConsultationListingItemCtrl as cli'
)