# DcPin Controller

angular.module("HelpPatient.controllers").controller('DcPinCtrl', ($scope, $state) ->


  ###*
   * [init - intialize the controller]
   * @return
  ###
  @init = =>
    @pinLength = parseInt(@pinLength) || 2

    @prepareInputs()

    @watchers = []

    @watchers.push($scope.$watch(=>
      return @pinModel
    , @modelWatcher))
    @watchers.push($scope.$watch(=>
      return @inputs
    , @inputWatcher, true))

    $scope.$on('$destroy', =>
      for watcher in @watchers
        watcher?()
    )

    return

  ###*
   * Insert code here
  ###

  ###*
   * [prepareInputs]
   * @return {[type]} []
  ###
  @prepareInputs = =>
    @inputs = []

    for i in [0..@pinLength - 1]
      @inputs[i] = ''

    return

  ###*
   * [modelWatcher]
   * @param  {[type]} n []
   * @param  {[type]} o []
   * @return {[type]}   []
  ###
  @modelWatcher = (n, o) =>
    if @preventSplit
      @preventSplit = false
      return

    n = n + ''
    o = o + ''

    for char, index in n.split('')
      @inputs[index] = char

    @inputs.splice(@pinLength)

    @preventJoin = true

  ###*
   * [inputWatcher]
   * @param  {[type]} n []
   * @param  {[type]} o []
   * @return {[type]}   []
  ###
  @inputWatcher = (n, o) =>
    if @preventJoin
      @preventJoin = false
      return

    if !o?
      return

    for value, index in n

      if (n[index] + '').length > 0
        n[index] = parseInt('' + (value % 10))

        if n[index] != o[index] && index < @inputs.length - 1
          $scope.focus(index + 1)
        else if n[index] != o[index] && index == @inputs.length - 1
          $scope.blur(index)

      if (n[index] + '').length == 0 && (o[index] + '').length > 0 && index > 0
        $scope.focus(index - 1)

    @preventSplit = true
    @pinModel = @inputs.join('')

  ###*
   * End of code section
  ###

  # call to init function
  @init()

  return
)