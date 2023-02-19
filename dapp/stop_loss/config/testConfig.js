
var ExerciseC6A = artifacts.require("ExerciseC6A");

var Config = async function(accounts) {
    
    // These test addresses are useful when you need to add
    // multiple users in test scripts
    let testAddresses = [
        "0xDf35eb1f42cb9378c6b546A6A087e68B231dCB74",
        "0x4215466D39Fa5A48d2406D0f537895a319Edb5A8",
        "0x8a21c008470131c111E74712AF6b408f1b076A64",
        "0x811d9E833d80257D8752D268747670d0Fe900127",
        "0xf4FD0eB6293013B7f21cFbC6924d54b7969075b3",
        "0x1884Cfff4330EB66cD30F6C3208CD89662F49F59",
        "0x6793b43b04787F56789231ec6Aa30f5ba0cb97C9",
        "0x7744A22c6B9F7515e28F945D07a0B1b44C80f205",
        "0x8893C15DB1Ff3611Cd8A498A02d3ba553C11A920"
    ];


    let owner = accounts[0];
    let exerciseC6A = await ExerciseC6A.new();
    
    return {
        owner: owner,
        testAddresses: testAddresses,
        exerciseC6A: exerciseC6A
    }
}

module.exports = {
    Config: Config
};