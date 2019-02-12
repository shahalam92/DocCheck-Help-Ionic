# Promotion Controller

angular.module("HelpPatient.controllers").controller('PromotionCtrl', ($scope, $timeout, $ionicScrollDelegate, $sce, $state, GA) ->

  $scope.$on('$ionicView.enter', ->
    GA.trackView('Promotion')
  )

  $timeout(->
    $ionicScrollDelegate.resize()
  )

  window.iframeLoad = ->
    document.getElementById("iframe").contentWindow.document.body.onclick = (e) ->

      if e.target.href != undefined or e.srcElement.href != undefined or e.target.parentElement.href != undefined
        e = e or window.event
        if e.target.href? || e.srcElement.href
          element = e.target or e.srcElement
        else
          element = e.target.parentElement
        if element.tagName == 'A' and element.href != undefined and element.href != '' and (element.href.indexOf('http') > -1 or element.href.indexOf('www') > -1 or element.href.indexOf('market') > -1) and element.href.indexOf('#/app') == -1
          window.open element.href, '_system', 'location=no'
          return false
      return true

  $scope.link = "http://www.doccheck.com/"
  $scope.link += "de"
  $scope.link += "/cms/apps/iframe/device/"
  $scope.link += if ionic.Platform.isAndroid() then "android" else "iphone"
  $scope.link += "/app/help"

  $scope.link = $sce.trustAsResourceUrl($scope.link)
)