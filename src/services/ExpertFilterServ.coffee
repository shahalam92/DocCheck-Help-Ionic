angular.module("HelpPatient.services").factory("ExpertFilter", ($rootScope, $ionicModal, $ionicPopup, $q, $filter, GA) ->

  ###*
   * [STATUS - possible status filters]
   * @type {Array}
  ###
  @STATUS = [
    "offline"
    "online"
  ]

  ###*
   * [SORT_MODES - possible sort modes including icons for presentation]
   * @type {Array}
  ###
  @SORT_MODES = [
    label : "RATING_DESC"
    icon : "fa fa-sort-attributes-ls"
  ,
    label : "ALPH_ASC"
    icon : "fa fa-sort-az"
    ###
    Excluded due to DCX-1096
  ,
    label : "ALPH_DESC"
    icon : "fa fa-sort-za"
    ###
  ]

  ###*
   * [resultAmount - storing amount of currently in filtering included docs]
   * @type {Number}
  ###
  @resultAmount = -1

  @modal = null

  ###*
   * [sort - current sort mode]
   * @type {Number}
  ###
  @sort = 0

  ###*
   * [filter - current filter object]
   * @type {Object}
  ###
  @filter = {
    disciplines: []
    status     : ''
    minRating  : 0
  }

  ###*
   * [init]
   * @return {[type]} []
  ###
  @init = ->
    @resetFilter()

    @modalPromise = $ionicModal.fromTemplateUrl('templates/FilterModal.html',
      animation: 'filter-appear'
    )
      .then((modal) =>
        modal.hide()

        @modal = modal
      )

    @sortModalPromise = $ionicModal.fromTemplateUrl('templates/SortModal.html',
      animation: 'filter-appear'
    )
      .then((modal) =>
        modal.hide()

        @sortModal = modal
      )

  ###*
   * [setResultAmount]
   * @param {[type]} amount []
  ###
  @setResultAmount = (amount) ->
    return @resultAmount = amount

  ###*
   * [getResultAmount]
   * @return {[type]} []
  ###
  @getResultAmount = ->
    return @resultAmount

  ###*
   * [show]
   * @return {[type]}        []
  ###
  @showFilterModal = () ->
    @modalPromise.then(=>
      @modal.show()
    )
    return

  ###*
   * [hideFilterModal]
   * @return {[type]} []
  ###
  @hideFilterModal = ->
    @modalPromise.then(=>
      @modal.hide()
    )
    return

  ###*
   * [showSortModal]
   * @return {[type]} []
  ###
  @showSortModal = () ->
    @sortModalPromise.then(=>
      @sortModal.show()
    )
    return

  ###*
   * [hideSortPopup]
   * @return {[type]} []
  ###
  @hideSortModal = () ->
    @sortModalPromise.then(=>
      return @sortModal.hide()
    )
    return

  ###*
   * [getFilter]
   * @return {[type]} []
  ###
  @getFilter = ->
    return @filter

  ###*
   * [setDisciplines]
   * @param {[type]} discplines=[] []
  ###
  @setDisciplines = (disciplines=[]) ->
    GA.trackEvent('Expert', 'filter', 'disciplines', disciplines.length)

    while ( @filter.disciplines.length > 0 )
      @filter.disciplines.pop()

    while ( disciplines.length > 0 )
      @filter.disciplines.push( disciplines.pop() )

    return @filter

  ###*
   * [unsetDisciplines ]
   * @return {[type]} []
  ###
  @unsetDisciplines = ->
    @setDisciplines( [] )
    return @filter

  ###*
   * [isDisciplineExcluded ]
   * @param  {[type]}              [] []
   * @return {Boolean}             []
  ###
  @isDisciplineExcluded = (disciplines = []) ->
    excluded = true

    if ( @filter.disciplines.length == 0 )
      return false

    if ( disciplines.length == 0 )
      return true

    for filterDisc in @filter.disciplines
      for expDisc in disciplines
        if ( filterDisc.id == expDisc.occupation_id )
          excluded = false
          break

    return excluded

  ###*
   * [setMinRating]
   * @param {[type]} minRating []
  ###
  @setMinRating = (minRating=0) ->
    GA.trackEvent('Expert', 'filter', 'rating', minRating)

    @filter.minRating = minRating
    return @filter

  ###*
   * [unsetMinRating]
   * @return {[type]} []
  ###
  @unsetMinRating = ->
    @setMinRating( 0 )
    return @filter

  ###*
   * [isRatingTooLow]
   * @return {Boolean} []
  ###
  @isRatingTooLow = (ratingAvg) ->
    return !( ratingAvg >= @filter.minRating )

  ###*
   * [setStatus]
   * @param {[type]} status='all' []
  ###
  @setStatus = (status='') ->
    trackingExtension = '_all'
    if ( status.length > 0 )
      trackingExtension = '_' + status

    GA.trackEvent('Expert', 'filter', 'status' + trackingExtension)
    @filter.status = status
    return @filter

  ###*
   * [unsetStatus]
   * @return {[type]} []
  ###
  @unsetStatus = ->
    @setStatus( '' )
    return @filter

  ###*
   * [isStatusFiltered]
   * @param  {[type]} status []
   * @return {[type]}        []
  ###
  @isStatusFiltered = (status) ->
    if ( @filter.status.length == 0 )
      return false

    return ( @STATUS[parseInt(@filter.status)] != status )

  ###*
   * [isExpertFiltered]
   * @param  {[type]}  expert []
   * @return {Boolean}        []
  ###
  @isExpertFiltered = ( expert ) ->
    if ( @isStatusFiltered( expert.state ) )
      return true

    if ( @isRatingTooLow( expert.rating_avg ) )
      return true

    discipline = []
    if ( expert.user_occupations?.discipline? )
      discipline = expert.user_occupations.discipline

    if ( @isDisciplineExcluded( discipline ) )
      return true

    return false

  ###*
   * [isFilterActive]
   * @return {Boolean} []
  ###
  @isFilterActive = ->
    return (
      @filter.minRating > 0 ||
      @filter.status.length > 0 ||
      @filter.disciplines.length > 0
    )

  ###*
   * [isSortingActive]
   * @return {Boolean} []
  ###
  @isSortingActive = ->
    return @sort > 0

  ###*
   * [getSortIcon]
   * @return {[type]} []
  ###
  @getSortIcon = ->
    return @SORT_MODES[@sort].icon

  ###*
   * [resetFilter]
   * @return {[type]} []
  ###
  @resetFilter = ->
    @unsetDisciplines()
    @unsetMinRating()
    @unsetStatus()
    return @filter

  ###*
   * [setSortMode]
   * @param {[type]} index=0 []
  ###
  @setSortMode = (index=0) ->
    if ( @sort == index )
      return @sort

    GA.trackEvent('Expert', 'sort', @SORT_MODES[index].label)
    @sort = index
    $rootScope.$broadcast( 'dc_experts_sorting-changed' )

    return @sort

  ###*
   * [getSortMode]
   * @return {[type]} []
  ###
  @getSortMode = () ->
    return @sort

  ###*
   * [getSortArray]
   * @return {[type]}        []
  ###
  @getSortArray = ->
    switch @sort
      when 0
        return ['state', 'isFavorite', 'rating_avg', '-expert_profile.last_name']
      when 1
        return ['-expert_profile.last_name', 'state']
      when 2
        return ['expert_profile.last_name', 'state']
      else
        ['isFavorite', 'rating_avg', '-expert_profile.last_name', 'state']

  @init()

  return @

)