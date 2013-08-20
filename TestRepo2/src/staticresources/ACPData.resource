/******************************************************

channels (map of Indexes by String)

premises (map of Indexes by String)

territories (map of Territory__c recs by OwnerId)

reps, map by repId of:
Rep - JS Object
	repId			String
	repName			String
	territoryId		String
	territoryName	String
	premisesByName	Map (Strings by String)
	accountsById	Map (Accounts by Id)
	childGoals		Map (childGoals by parentId)
	
repsByTerritory, map by territoryId of Rep

parentGoals, map by goalId of:
Goal - JS Object
	goalId			String
	name			String
	channel			String
	premise			String
	numAccsSel		Number
	numAccsNeeded	Number
	isComplete		Boolean
	isAssigned		Boolean
	children		Hash of children goals by repId (manager view) or Hash of children actions by accountId (rep view)
	
childGoals, map by key of:
Goal - JS Object
	goalId			String (own Id, if already exists)
	parentId		String (Id of parent goal)
	repId			String
	key				String (goalId + | + repId)
	mode			String
	detail			String
	numAccsSel		Number
	numAccsAvail	Number

actions, map by key of:
Action - JS Object (eventually translated to SFObject)
	accountId		String
	goalId			String
	repId			String
	key				String (accountId + | + goalKey)
	selected		Boolean (default false)
	isAssigned		Boolean

******************************************************/

var repMode = false;

var channels;
var premises;
var territories;
var territoryOwnerIds;
var reps;
var repsByTerritory;
var parentGoals;
var childGoals;
var actions;

function Hash(){
    var lengthCounter = 0;
    var valueHolder = new Object();
    this.put = function(key, val){
    	if(valueHolder[key] == null){
    		lengthCounter++;
    	}
        valueHolder[key] = val;
    };
    this.remove = function(key){
    	delete valueHolder[key];
    }
    this.get = function(key) {
    	return valueHolder[key];
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
	var retResult;
	if(params != null){
		Visualforce.remoting.Manager.invokeAction(
			'Controller_ActionCreationPage.' + funcName,
			params,
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
	} else {
		Visualforce.remoting.Manager.invokeAction(
			'Controller_ActionCreationPage.' + funcName,
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
	if(params != null){
		Visualforce.remoting.Manager.invokeAction(
			'Controller_ActionCreationPage.' + funcName,
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
	} else {
		Visualforce.remoting.Manager.invokeAction(
			'Controller_ActionCreationPage.' + funcName,
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
	var hideAll = false;
	if(step == "getManagerTerritories"){
		repMode = true;
		setupTerritories();
	} else if(step == "getRepTerritories"){
		alert("No territories found. Please contact your administrator if you feel you are seeing this message in error.");
		hideAll = true;
		finishAll();
	} else if(step == "getAccounts"){
		alert("No valid Accounts found. Please contact your administrator if you feel you are seeing this message in error.");
		hideAll = true;
		finishAll();
	} else if(step == "getManagerGoals"){
		alert("No goals found. Please contact your administrator if you feel you are seeing this message in error.");
		//hideAll = true;
		//finishAll();
		doNextSetupStep();
	} else if(step == "getRepGoals"){
		alert("No goals found. Please check with your Manager if you feel you are seeing this message in error.");
		//hideAll = true;
		//finishAll();
		doNextSetupStep();
	}
	if(hideAll){
		j$('#channelTabDiv').hide();
		j$('.messagePanelDiv').hide();
		j$('.saveButtons').hide();
	}
}

function saveClicked(){
	doSave(false);
}
	

function submitClicked(){
	if(validateData()){
		doSave(true);
	}
}

function validateData(){
	var incompleteGoalCount = countIncompleteGoals();
	if(incompleteGoalCount == 0){
		return true;
	} else if(incompleteGoalCount == 1){
		if(repMode){
			alert(incompleteGoalCount + ' goal still needs accounts selected. Please check all tabs and premises and try again.');
		} else {
			alert(incompleteGoalCount + ' goal is still incomplete. Please ensure that all goals have a 0 for "Accounts still needed" in the totals box, on all tabs and premises.');
		}
	} else {
		if(repMode){
			alert(incompleteGoalCount + ' goals still need accounts selected. Please check all tabs and premises and try again.');
		} else {
			alert(incompleteGoalCount + ' goal(s) are still incomplete. Please ensure that all goals have a 0 for "Accounts still needed" in the totals box, on all tabs and premises.');
		}
	}
	return false;
}

function countIncompleteGoals(){
	var count = 0;
	var goals = parentGoals.values();
	for(var i = 0; i < goals.length; i++){
		if(goals[i].isComplete == false){
			count++;
		}
	}
	return count;
}

var alreadySaving = false;
function acceptGoal(goalKey){
	if(alreadySaving == false){
		alreadySaving = true;
		var goal = parentGoals.get(goalKey);
		
		if(goal.isComplete){
			var sfActions = [];
			var accIds = goal.selectedAccountIds.values();
			for(var i = 0; i < accIds.length; i++){
				var sfAction = new Object();
				
				sfAction.Account__c = accIds[i];
				if(goal.premise == 'Off-Premise - Control'){
					sfAction.Cases_Displayed__c = goal.casesByAccountId.get(accIds[i]);
					if(sfAction.Cases_Displayed__c == 'undefined'){
						sfAction.Cases_Displayed__c = 0;
					}
				}
				sfAction.Goal__c = goal.goalId;
				
				sfActions.push(sfAction);
			}
			
			contSaveFunc("saveActions" , [sfActions, true], function(result){
				alert("Actions have been created for this goal. It will now be removed from the view.");
				
				j$('.goalHeader[goalKey="' + goalKey + '"]').css('display', 'none');
				j$('.accountTopCell[goalKey="' + goalKey + '"]').css('display', 'none');
				j$('.actionCell[goalKey="' + goalKey + '"]').css('display', 'none');
				j$('.sumLineCell[goalKey="' + goalKey + '"]').css('display', 'none');
				
				alreadySaving = false;
				var rep = reps.get(goal.repId);
				rep.childGoals.remove(goal.key);
				updateRepCounts(false, false);
			});
		}
	}
}

function newSubmitGoal(goalId){
	var parentGoal = parentGoals.get(goalId);
	if(alreadySaving == false && parentGoal.isComplete == true){
		alreadySaving = true;
		var sfGoals = [];
		var children = parentGoal.children.values();
		for(var i = 0; i < children.length; i++){
			var jsGoal = children[i];
			if(jsGoal.isAssigned == false && jsGoal.numAccsSel > 0){
				var sfGoal = new Object();
				
				sfGoal.Id = jsGoal.Id;
				sfGoal.Parent_Goal__c = jsGoal.parentId;
				sfGoal.Assignment_Mode__c = jsGoal.mode;
				sfGoal.Minimum_of_Accounts__c = 0;
				if(jsGoal.mode == 'manual'){
					var accIdsAndCaseValues = [];
					var actVals = actions.values();
					sfGoal.Assignment_Mode_Detail__c = '';
					for(var j = 0; j < actVals.length; j++){
						var action = actVals[j];
						if(action.goalKey == jsGoal.key && action.selected){
							accIdsAndCaseValues.push(action.accountId + ',' + action.caseCount);
						}
					}
					sfGoal.Assignment_Mode_Detail__c = accIdsAndCaseValues.join('|');
					sfGoal.Minimum_of_Accounts__c = accIdsAndCaseValues.length;
					sfGoal.Cases_Displayed__c = jsGoal.numCasesSel;
				} else if(jsGoal.mode == 'count'){
					sfGoal.Assignment_Mode_Detail__c = jsGoal.detail;
					sfGoal.Minimum_of_Accounts__c = jsGoal.detail;
					sfGoal.Cases_Displayed__c = jsGoal.numCasesSel;
				} else {
					sfGoal.Assignment_Mode_Detail__c = Math.floor((jsGoal.detail / 100) * parentGoal.numAccsNeeded);
					sfGoal.Minimum_of_Accounts__c = Math.floor((jsGoal.detail / 100) * parentGoal.numAccsNeeded);
					sfGoal.Cases_Displayed__c = Math.floor(jsGoal.numCasesSel / parentGoal.numCasesNeeded);
				}
				if(jsGoal.detail == 0 || jsGoal.detail == null){
					jsGoal.detail = '';
				}
				sfGoal.Goal_For__c = jsGoal.repId;
				sfGoal.OwnerId = jsGoal.repId;
				
				sfGoal.Assignment_Mode_Detail__c = String(sfGoal.Assignment_Mode_Detail__c);
				
				sfGoals.push(sfGoal);
			}
		}
		
		contSaveFunc("saveGoals" , [sfGoals, true], function(result){
			alert("This goal has been submitted. It will now be removed from the view.");
			
			j$('.totalGoalHeader[goalId="' + goalId + '"]').css('display', 'none');
			j$('.totalGoalCell[goalId="' + goalId + '"]').css('display', 'none');
			j$('.goalHeader[goalKey^="' + goalId + '"]').css('display', 'none');
			j$('.accountTopCell[goalKey^="' + goalId + '"]').css('display', 'none');
			j$('.actionCell[goalKey^="' + goalId + '"]').css('display', 'none');
			j$('.sumLineCell[goalKey^="' + goalId + '"]').css('display', 'none');
			
			alreadySaving = false;
			parentGoals.remove(parentGoal);
			for(var i = 0; i < children.length; i++){
				var goal = children[i];
				childGoals.remove(goal);
				var rep = reps.get(goal.repId);
				rep.childGoals.remove(goal.parentId);
			}
			updateRepCounts(true, false);
				
		});
	}
}


function doSave(andSubmit){
	if(alreadySaving == false){
		alreadySaving = true;
		if(repMode){
			var sfActions = [];
			var jsActions = actions.values();
			for(var i = 0; i < jsActions.length; i++){
				var jsAction = jsActions[i];
				var goal = parentGoals.get(jsAction.goalKey);
				if(goal.isAssigned == false && jsAction.selected){
					var sfAction = new Object();
					
					sfAction.Account__c = jsAction.accountId;
					sfAction.Goal__c = jsAction.goalId;
					
					sfActions.push(sfAction);
				}
			}
			
			contSaveFunc("saveActions" , [sfActions, andSubmit], function(result){
				alert("All actions have been created.");
				window.open ('/apex/ActionCreationPage','_self',false);
			});
		} else {
			var sfGoals = [];
			var jsGoals = childGoals.values();
			for(var i = 0; i < jsGoals.length; i++){
				var jsGoal = jsGoals[i];
				if(jsGoal.isAssigned == false){
					var sfGoal = new Object();
					
					sfGoal.Id = jsGoal.Id;
					sfGoal.Parent_Goal__c = jsGoal.parentId;
					sfGoal.Assignment_Mode__c = jsGoal.mode;
					sfGoal.Minimum_of_Accounts__c = 0;
					if(jsGoal.mode == 'manual'){
						var accIds = [];
						var actVals = actions.values();
						for(var j = 0; j < actVals.length; j++){
							var action = actVals[j];
							if(action.goalKey == jsGoal.key && action.selected){
								accIds.push(action.accountId);
							}
						}
						sfGoal.Assignment_Mode_Detail__c = accIds.join('|');
						sfGoal.Minimum_of_Accounts__c = accIds.length;
					} else if(jsGoal.mode == 'count'){
						sfGoal.Assignment_Mode_Detail__c = jsGoal.detail;
						sfGoal.Minimum_of_Accounts__c = jsGoal.detail;
					} else {
						sfGoal.Assignment_Mode_Detail__c = jsGoal.detail;
						sfGoal.Minimum_of_Accounts__c = Math.floor((jsGoal.detail / 100) * jsGoal.numAccsAvail);
					}
					if(jsGoal.detail == 0 || jsGoal.detail == null){
						jsGoal.detail = '';
					}
					sfGoal.Goal_For__c = jsGoal.repId;
					if(andSubmit){
						sfGoal.OwnerId = jsGoal.repId;
					}
					sfGoal.Assignment_Mode_Detail__c = '' + sfGoal.Assignment_Mode_Detail__c;
					
					sfGoals.push(sfGoal);
				}
			}
			
			contSaveFunc("saveGoals" , [sfGoals, andSubmit], function(result){
				alreadySaving = false;
				if(andSubmit){
					alert("All goals have been submitted for acceptance by your reps. This page will be reloaded in a read-only view.");
				} else {
					alert("Goals have been saved, but not submitted. This page will be reloaded. You may continue working or return at a later date.");
				}
				window.open ('/apex/ActionCreationPage','_self',false);
			});
		}
	}
}





