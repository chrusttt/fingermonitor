"use strict";
 angular.module("App", ["ngResource"]);

function AppCtrl($scope, $resource) {
  $scope.name = "world";
}