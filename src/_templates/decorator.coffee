# Decorator for service <%= name %>
angular.module('<%= app %>.decorators').config(($provide) ->

  ###*
   * []
   * @param  {[type]} $delegate []
   * @return {[type]}           []
  ###
  $provide.decorator('<%= name %>', ($delegate) ->

    <%= name %> = $delegate



  )

)