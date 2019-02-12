# FilterPicker Controller

angular.module("HelpPatient.controllers").controller('FilterPickerCtrl', ($scope, $state, $ionicModal, $filter, ExpertFilter) ->

  ###*
   * [init - intialize the controller]
   * @return
  ###
  @init = ->
    @filter = ExpertFilter.getFilter()
    return

  ###*
   * Insert code here
  ###

  ###*
   * [showFilterModal]
   * @return {[type]} []
  ###
  @showFilterModal = ->
    ExpertFilter.showFilterModal()
    return

  ###*
   * [showSortModal]
   * @return {[type]} []
  ###
  @showSortModal = ->
    ExpertFilter.showSortModal()
    return

  ###*
   * [getFilterResultAmount]
   * @return {[type]} []
  ###
  @getFilterResultAmount = ->
    return ExpertFilter.getResultAmount()

  ###*
   * [getInfoText]
   * @return {[type]} []
  ###
  @getInfoText = ->
    count = @getFilterResultAmount()

    if ( count < 0 )
      return ''

    if ( count > 0 )
      return $filter('translate')('FILTERPICKER.INFO.AVAILABLE', {
        count : count
      })

    return $filter('translate')('FILTERPICKER.INFO.NONE')

  ###*
   * [isFilterActive]
   * @return {Boolean} []
  ###
  @isFilterActive = ->
    return ExpertFilter.isFilterActive()

  ###*
   * [isSortingActive]
   * @return {Boolean} []
  ###
  @isSortingActive = ->
    return ExpertFilter.isSortingActive()

  ###*
   * [getSortIcon]
   * @return {[type]} []
  ###
  @getSortIcon = ->
    return ExpertFilter.getSortIcon()

  ###*
   * End of code section
  ###

  # call to init function
  @init()

  return
)