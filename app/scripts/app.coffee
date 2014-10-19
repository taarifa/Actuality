'use strict'

app = angular
  .module('actualityApp', [
    'ui.bootstrap'
    'ngResource',
    'ngRoute',
    'dynform',
    'angular-flash.service',
    'angular-flash.flash-alert-directive',
    'geolocation'
  ])

  .config ($routeProvider, $httpProvider, flashProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
        reloadOnSearch: false
      .when '/vehicles/new',
        templateUrl: 'views/edit.html'
        controller: 'VehicleCreateCtrl'
      .when '/vehicles/:id',
        templateUrl: 'views/edit.html'
        controller: 'VehicleEditCtrl'
      .when '/vehicles',
        templateUrl: 'views/vehicles.html'
        controller: 'VehicleListCtrl'
      .when '/movements/new',
        templateUrl: 'views/edit.html'
        controller: 'MovementCreateCtrl'
      .when '/movements/:id',
        templateUrl: 'views/edit.html'
        controller: 'MovementEditCtrl'
      .when '/movements',
        templateUrl: 'views/movements.html'
        controller: 'MovementListCtrl'
      .otherwise
        redirectTo: '/'
    $httpProvider.defaults.headers.patch =
      'Content-Type': 'application/json;charset=utf-8'
    flashProvider.errorClassnames.push 'alert-danger'

  .filter('titlecase', () -> 
    return (s) -> 
      return s.toString().toLowerCase().replace( /\b([a-z])/g, (ch) -> return ch.toUpperCase()))

  .run ($rootScope, flash) ->
    $rootScope.$on '$locationChangeSuccess', ->
      # Clear all flash messages on route change
      flash.info = ''
      flash.success = ''
      flash.warn = ''
      flash.error = ''
