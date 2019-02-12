angular.module("HelpPatient.controllers").controller("FilterModalCtrl", ($scope, $filter, ExpertFilter, Discipline) ->

  @page = 0
  @disciplines = Discipline.distributed

  ###*
   * []
   * @return {[type]} []
  ###
  $scope.$on('modal.shown', =>
    @filter = angular.copy( ExpertFilter.getFilter() )

    @initDisciplines()

    @ratingWatcher = $scope.$watch(() =>
      return @minRating
    , () =>
      ExpertFilter.setMinRating( @minRating )
    )

    @statusWatcher = $scope.$watch(() =>
      return @status
    , () =>
      ExpertFilter.setStatus( @status )
    )
  )

  ###*
   * []
   * @return {[type]} []
  ###
  $scope.$on('modal.hidden', =>
    @statusWatcher?()
    @ratingWatcher?()
  )

  ###*
   * [initDisciplines]
   * @return {[type]} []
  ###
  @initDisciplines = () =>
    @setDisciplineInfoText()

    selectedIds = @filter.disciplines.map(( disc ) ->
      return disc.id
    )

    for key, disc of @disciplines
      disc.selected = ( selectedIds.indexOf( disc.id ) >= 0 )

      if (disc.subdisciplines?)
        for key, subdisc of disc.subdisciplines
          subdisc.selected = ( selectedIds.indexOf( subdisc.id ) >= 0 )

  ###*
   * [openPage]
   * @param  {[type]} index []
   * @return {[type]}       []
  ###
  @openPage = (index) ->
    @page = index
    return

  ###*
   * [toggleDiscipline]
   * @param  {[type]} discipline []
   * @return {[type]}            []
  ###
  @toggleDiscipline = ($event, discipline, parent) ->
    if ( parent? )
      $event.preventDefault()
      $event.stopPropagation()

    if ( discipline.subdisciplines? )
      discipline.expanded = !discipline.expanded
      return

    discipline.selected = !discipline.selected
    @modifyFilterDisciplines( discipline )

    if ( !parent? )
      return

    if ( discipline.selected )
      parent.selected = true
      return

    selected = false
    for cname, cdisc in parent.subdisciplines
      if ( cdisc.selected )
        parent.selected = true
        break

    parent.selected = false
    return

  ###*
   * [modifyFilterDisciplines]
   * @param  {[type]} discipline []
   * @return {[type]}            []
  ###
  @modifyFilterDisciplines = ( discipline ) ->
    if ( discipline.selected )
      @filter.disciplines.push( discipline )
      return

    i = 0
    while ( i < @filter.disciplines.length )
      if ( @filter.disciplines[i].id == discipline.id )
        @filter.disciplines.splice(i, 1)
        break
      i++

    return

  ###*
   * [setDisciplineInfoText]
  ###
  @setDisciplineInfoText = ->
    if ( @filter.disciplines.length == 0 )
      @disciplineInfoText = $filter('translate')('FILTERMODAL.NO_DISCIPLINES_SET')
      return

    @disciplineInfoText = $filter('translate')('FILTERMODAL.DISCIPLINES_SET',
      disciplineCount: @filter.disciplines.length
    )
    return

  ###*
   * [saveDisciplines]
   * @return {[type]} []
  ###
  @saveDisciplines = ->
    angular.merge(@filter, angular.copy( ExpertFilter.setDisciplines( @filter.disciplines ) ))
    @setDisciplineInfoText()
    @openPage( 0 )
    return

  ###*
   * [discardDiscplines]
   * @return {[type]} []
  ###
  @discardDisciplines = ->
    while ( @filter.disciplines.length > 0 )
      disc = @filter.disciplines.pop()
      disc.selected = false
      if disc.parent
        @disciplines[disc.parent].selected = false
        @disciplines[disc.parent].subdisciplines[disc.name].selected = false
      else
        @disciplines[disc.name].selected = false

    @filter.disciplines = angular.copy( ExpertFilter.setDisciplines( [] ).disciplines )
    return

  ###*
   * [saveFilters]
   * @return {[type]} []
  ###
  @saveFilters = () =>
    @filter = ExpertFilter.setMinRating( @minRating || 0 )
    @filter = ExpertFilter.setStatus( @status || "" )

    @hideFilterModal()
    return

  ###*
   * [hideFilterModal]
   * @return {[type]} []
  ###
  @hideFilterModal = () =>
    if ( @page > 0 )
      @filter = ExpertFilter.getFilter()
      @initDisciplines()
      @openPage(0)

    ExpertFilter.hideFilterModal()
    return

  ###*
   * [discardFilters]
   * @return {[type]} []
  ###
  @discardFilters = () ->
    @minRating = 0
    ExpertFilter.setMinRating( @minRating )

    @status = ""
    ExpertFilter.setStatus( @status )

    @discardDisciplines()
    @setDisciplineInfoText()

    return

  return

)