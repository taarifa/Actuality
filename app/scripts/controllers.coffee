'use strict'

angular.module('actualityApp')

  .controller 'NavCtrl', ($scope, $location) ->
    $scope.location = $location

  .controller 'MainCtrl', ($scope, $http, $location, Movement, Map, flash) ->
    map = Map "map", showScale:true
    $scope.where = $location.search()
    $scope.where.max_results = parseInt($scope.where.max_results) || 100

    $scope.resetParameters = ->
      $scope.where = 
        max_results: 100

    $scope.updateMap = (nozoom) ->
      $location.search($scope.where)
      where = {}
      if $scope.where.status
        where.status = $scope.where.status
      query where, $scope.where.max_results, nozoom

    $scope.reset = ->
      $scope.resetParameters()
      $scope.updateMap()

    query = (where, max_results, nozoom) ->
      map.clearMarkers()
      Movement.query
        max_results: max_results
        where: where
      , (movements) ->
        if movements._items.length == 0
          flash.info = 'No movements match your filter criteria!'
          return
        map.addMovements(movements._items)
        map.zoomToMarkers() unless nozoom
    $scope.updateMap()

  .controller 'MovementCreateCtrl', (Movement, FacilityCreate, $scope) ->
    FacilityCreate $scope, Movement, 'mvf001', 'movement'

  .controller 'MovementEditCtrl', (Movement, FacilityEdit, $scope) ->
    FacilityEdit $scope, Movement, 'mvf001'

  .controller 'MovementListCtrl', ($scope, $location, Movement, flash) ->
    $scope.where = $location.search()
    $scope.filterStatus = () ->
      $location.search($scope.where)
      query = where: {}
      if $scope.where.report_status
        query.where.report_status = $scope.where.report_status
      if $scope.where.status
        query.where.status = $scope.where.status
      if $scope.where.license_plate
        query.where.license_plate = $scope.where.license_plate
      Movement.query query, (movements) ->
        $scope.movements = movements._items
        if $scope.movements.length == 0
          flash.info = "No movements matching the criteria!"
    $scope.filterStatus()

  .controller 'VehicleCreateCtrl', (Vehicle, FacilityCreate, $scope) ->
    FacilityCreate $scope, Vehicle, 'vhf001', 'vehicle'

  .controller 'VehicleEditCtrl', ($routeParams, Vehicle, FacilityEdit, $scope) ->
    FacilityEdit $scope, Vehicle, 'vhf001'

  .controller 'VehicleListCtrl', ($scope, $location, Vehicle, flash) ->
    $scope.where = $location.search()
    $scope.filterStatus = () ->
      $location.search($scope.where)
      query = where: {}
      if $scope.where.kind
        query.where.kind = $scope.where.kind
      if $scope.where.license_plate
        query.where.license_plate = $scope.where.license_plate
      Vehicle.query query, (vehicles) ->
        $scope.vehicles = vehicles._items
        if $scope.vehicles.length == 0
          flash.info = "No vehicles matching the criteria!"
    $scope.filterStatus()
