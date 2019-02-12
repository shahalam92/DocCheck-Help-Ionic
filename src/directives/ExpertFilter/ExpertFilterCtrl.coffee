# ExpertFilter Controller

angular.module("HelpPatient.controllers").controller('ExpertFilterCtrl', ($scope, $state, $ionicModal, $q, ApiDisciplines, Authentication, Discipline, CacheLast, Tools, DcLoading) ->

  @refreshed  = -1
  @showHint   = true

  @fetching   = Discipline.fetching

  $scope.vm = @

  @fetched      = false
  @fetchedStamp = -1

  ###*
   * [init]
   * @return {[type]} []
  ###
  @init = =>

    ###*
     * [modal preparation]
     * @param  {Object} modal []
     * @return
    ###
    $ionicModal.fromTemplateUrl('templates/DisciplineModalTemplate.html',
      scope: $scope
      animation: 'slide-in-up'
    ).then((modal) =>
      modal.hide()
      
      @modal = modal
      @noCheckboxes = true
      @noHeader = true
      return
    )

    ###*
     * [$destroy]
     * @return
    ###
    $scope.$on '$destroy', =>
      heightListener?()
      @modal.remove()
      return

    ###*
     * [beforeEnter]
     * @return
    ###
    $scope.$on 'beforeEnter', =>
      @fetchDisciplines()
      return

    @fetchDisciplines()

  ###*
   * [fetchDisciplines]
   * @return {[type]} []
  ###
  @fetchDisciplines = =>
    @error = false

    if @fetched && Date.now() < @fetchedStamp + 1000 * 60 * 60 * 24
      return $q.resolve()

    @disciplineObject = Discipline.distributed
    return Discipline.fetchDistribution()
    .then(=>
      @fetched = true
      @fetchedStamp = Date.now()
    )
    .catch(=>
      @error = true
    )

  ###*
   * [openModal]
   * @return
  ###
  @openModal = =>
    promise = undefined
    if Object.keys(@disciplineObject).length == 0
      promise = @fetchDisciplines()
    else
      promise = $q.resolve(@disciplineObject)

    return promise.then(=>
      @modal.show()
      @checkHeight()
    )

  ###*
   * [checkHeight ]
   * @return {[type]} []
  ###
  @checkHeight = =>
    headerHeight = angular.element(@modal.el).find('.all-disciplines.item')[0].getBoundingClientRect().height
    listHeight = angular.element(@modal.el).find('ion-list .list').height()

    if listHeight + headerHeight > window.screen.height
      return

    top = window.screen.height - headerHeight - listHeight - 24
    if top < 100
      top = 100
    #if top > 300
    #  top = 300
    angular.element(@modal.el).find('ion-modal-view').css('top', top)

  ###*
   * [closeHint]
   * @return
  ###
  @closeHint = =>
    @showHint = false
    return

  ###*
   * [closeModal]
   * @return
  ###
  @closeModal = =>
    @modal.hide()
    return

  ###*
   * [select]
   * @param  {Event} $event      []
   * @param  {String} discipline []
   * @return
  ###
  @select = ($event, discipline) =>
    $event.preventDefault()
    $event.stopPropagation()
    if discipline.subdisciplines?
      discipline.expanded = !discipline.expanded
      return
    @disciplineModel = discipline.fullname
    @selectedDiscipline = discipline
    @closeModal()
    return

  ###*
   * [clear]
   * @param  {[type]} $event []
   * @return {[type]}        []
  ###
  @clear = ($event) =>
    $event.preventDefault()
    $event.stopPropagation()
    @disciplineModel = ''
    @selectedDiscipline = undefined
    @closeModal()
    return

  @init()

  return
  
)