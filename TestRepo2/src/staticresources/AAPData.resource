var repMode = false;

var territoriesByOwnerId;
var territoryIds;
var underlingsById;
var parentGoalsById;
var parentGoalsByPriority;
var parentGoalsByPriorityAndPremise;
var parentGoalsByPriorityPremiseAndRT;
var childGoalsByKey;
var accountsById;

var priorities;
var premises;
var recTypes;

var currentKey;
var currentPriority;
var currentPremise;
var currentRT;
var currentGoals;

var totalBlocksByCurrentKey = new Hash();
var repBlocksByCurrentKey = new Hash();

var showCases = false;

function Hash(){
    var lengthCounter = 0;
    var valueHolder = new Object();
    var keyArray = [];
    this.put = function(key, val){
    	if(valueHolder[key] == null){
    		lengthCounter++;
    		keyArray.push(key);
    	}
        valueHolder[key] = val;
    };
    this.putInArray = function(key, val){
    	if(valueHolder[key] == null){
    		valueHolder[key] = [];
    		lengthCounter++;
    		keyArray.push(key);
    	}
    	valueHolder[key].push(val);
    };
    this.putInUniqueArray = function(key, val){
    	if(valueHolder[key] == null){
    		valueHolder[key] = [];
    		lengthCounter++;
    		keyArray.push(key);
    	}
    	if(valueHolder[key].indexOf(val) == -1){
    		valueHolder[key].push(val);
    	}
    };
    this.remove = function(key){
    	delete valueHolder[key];
    	keyArray.splice(keyArray.indexOf(key), 1);
    	lengthCounter--;
    };
    this.removeFromArray = function(key, val){
    	var index = valueHolder[key].indexOf(val);
    	valueHolder[key].splice(index, 1);
    	if(valueHolder[key].length == 0){
    		delete valueHolder[key];
    		lengthCounter--;
    	}
    };
    this.get = function(key) {
    	return valueHolder[key];
    };
    this.keySet = function(){
    	return keyArray;
    };
    this.values = function(){
    	var arr = [];
    	for(var propString in valueHolder){
    		arr.push(valueHolder[propString]);
    	}
    	return arr;
    };
    this.length = function(){
        return lengthCounter;
    };
}

function contLoadFunc(funcName, params, callback){
	if(params == null){
		Visualforce.remoting.Manager.invokeAction(
			'ActionAssignmentController.' + funcName,
			function(result, event){
				if(result){
					if(result.length == 0){
						noRecordsFound(funcName);
					} else {
						callback(result);
					}
				} else {
					genericError(funcName, event);
				}
			},
			{escape: true}
		);
	} else if(params.length == 1){
		Visualforce.remoting.Manager.invokeAction(
			'ActionAssignmentController.' + funcName,
			params[0],
			function(result, event){
				if(result){
					if(result.length == 0){
						noRecordsFound(funcName);
					} else {
						callback(result);
					}
				} else {
					genericError(funcName, event);
				}
			},
			{escape: true}
		);
	}
}

function contSaveFunc(funcName, params, callback){
	var retResult;
	if(funcName == 'saveGoals'){
		Visualforce.remoting.Manager.invokeAction(
			'ActionAssignmentGoalSaver.' + funcName,
			params[0],
			function(result, event){
				if(result){
					callback(result);
				} else {
					genericError(funcName, event);
				}
			},
			{escape: true}
		);
	} else {
		Visualforce.remoting.Manager.invokeAction(
			'ActionAssignmentController.' + funcName,
			params[0], params[1],
			function(result, event){
				if(result){
					callback(result);
				} else {
					genericError(funcName, event);
				}
			},
			{escape: true}
		);
	}
}

function genericError(source, event){
	alert('Error in ' + source + ': ' + event.message);
}

function noRecordsFound(step){
	if(step == 'getManagerTerritories'){
		repMode = true;
		setupTerritories();
	} else if(step == 'getRepTerritories'){
		alert('No territories found. Please contact your administrator if you feel you are seeing this message in error.');
		gotoMyGoals();
	} else if(step == 'getUserGoals'){
		alert('No current goals found. Please contact your administrator if you feel you are seeing this message in error.');
		gotoMyGoals();
	}
}