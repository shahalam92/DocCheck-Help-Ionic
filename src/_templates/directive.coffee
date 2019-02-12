# <%= name %> directive

angular.module("<%= app %>.directives").directive('<%= directive %>', ->
  restrict: 'E'
  scope: true
  templateUrl: 'templates/<%= name %>Template.html'
  controller: '<%= name %>Ctrl'
)