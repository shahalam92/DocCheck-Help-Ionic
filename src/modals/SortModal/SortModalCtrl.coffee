angular.module("HelpPatient.controllers").controller("SortModalCtrl", ($scope, ExpertFilter) ->

  @current = ExpertFilter.getSortMode()
  @items = ExpertFilter.SORT_MODES

  ###*
   * [set]
  ###
  @set = ($event, index) =>
    $event.preventDefault()
    $event.stopPropagation()
    @current = ExpertFilter.setSortMode(index)
    @hideModal()
    return

  ###*
   * [hideModal]
   * @return {[type]} []
  ###
  @hideModal = ->
    ExpertFilter.hideSortModal()
    return

  return
)