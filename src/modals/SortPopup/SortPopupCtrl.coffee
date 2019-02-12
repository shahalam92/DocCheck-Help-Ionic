angular.module("HelpPatient.controllers").controller("SortPopupCtrl", ($scope, ExpertFilter) ->

  @current = ExpertFilter.getSortMode()
  @items = ExpertFilter.SORT_MODES

  ###*
   * [set]
  ###
  @set = ($event, index) ->
    $event.preventDefault()
    $event.stopPropagation()
    ExpertFilter.hideSortPopup()
    ExpertFilter.setSortMode(index)
    return

  return
)