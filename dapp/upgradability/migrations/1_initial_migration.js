var Migrations = artifacts.require("Migrations");
var ExerciseC6C = artifacts.require("ExerciseC6C");
var ExerciseC6CApp = artifacts.require("ExerciseC6CApp");

module.exports = function(deployer) {
    deployer.deploy(Migrations);
    deployer.deploy(ExerciseC6C);
    deployer.deploy(ExerciseC6CApp);
};
