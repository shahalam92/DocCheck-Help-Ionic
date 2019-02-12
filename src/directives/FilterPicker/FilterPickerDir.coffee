# FilterPicker directive

angular.module("HelpPatient.directives").directive('filterPicker', ->
  restrict: 'E'
  scope: true
  templateUrl: 'templates/FilterPickerTemplate.html'
  controller: 'FilterPickerCtrl as picker'
)