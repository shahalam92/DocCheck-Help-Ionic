# ExpertFilter directive

angular.module("HelpPatient.directives").directive('expertFilter', ($timeout) ->
  restrict: 'E'
  scope:
    disciplineModel: '='
  templateUrl: 'templates/ExpertFilterTemplate.html'
  controller: 'ExpertFilterCtrl as ef'
  bindToController: true
)