var setupChain = [createLoadModal,
				  setupChannels,
				  setupTerritories,
				  setupAccounts,
				  setupGoals,
				  setupActions,
				  updateAllTotals,
				  addSaveButtons,
				  applyAll,
				  finishAll
				 ];
var setupIndex = -1;

var buttonString;

var ie8Widths;

function doNextSetupStep(){
	setupIndex++;
	j$("#loadProgressBar").progressbar("option", "value", setupIndex / (setupChain.length-1) * 100);
	setupChain[setupIndex]();
}

function updateLoadModal(text){
	j$("#loadModal > p").remove();
	j$("#loadModal").append("<p>" + text + "</p>");
}

function createLoadModal(){
	j$("#loadModal").dialog({
		modal: true,
		closeOnEscape: false,
		open: function(event, ui) { 
				//hide close button
				j$(".ui-dialog-titlebar-close", j$(this).parent()).hide();
			}
	});
	j$("#loadProgressBar").progressbar();
	doNextSetupStep();
}

function setupChannels(){
	updateLoadModal("Setting up tabs...");
	
	j$("#channelTabDiv").append("<ul/>");
	contLoadFunc("getChannels", null, function(result){
		channels = new Hash();
		for(i = 0; i < result.length; i++){
			var name = result[i];
			channels.put(name, channels.length());
			j$("#channelTabDiv > ul").append("<li><a href='#tabs-" + i + "'>" + name + "</a></li>");
			j$("#channelTabDiv").append("<div id='tabs-" + i + "'>");
		}
		
		var createString = '';
		createString += '<div class="createGoalBlock">';
		createString += 	'<div class="createGoalInnerBlock">';
		createString += 		'Create new associate goal that is related to an existing goal:&nbsp;&nbsp;&nbsp;';
		createString += 	'</div>';
		createString += 	'<div class="createGoalButton" onclick="createNewGoal(false)">Create</div>';
		createString += 	'<br/>';
		createString += 	'<br/>';
		createString += 	'<b>OR</b><br/>';
		createString += 	'<br/>';
		createString += 	'<div class="createGoalInnerBlock">';
		createString += 		'Create new local ';
		createString += 		'<select class="createGoalSelect">';
		createString += 			'<option value="General Goals">General</option>';
		createString += 			'<option value="Display Goals">Display</option>';
		createString += 			'<option value="Distribution Goals">Distribution</option>';
		createString += 			'<option value="Ad Execution">Ad Execution</option>';
		createString += 			'<option value="Bar Promotion Goals">Bar Promotion</option>';
		createString += 			'<option value="Cold Box Goals">Cold Box</option>';
		createString += 			'<option value="Feature Goals">Feature</option>';
		createString += 			'<option value="Menu Goals">Menu</option>';
		createString += 			'<option value="Shelf Set Goals">Shelf Set</option>';
		createString += 			'<option value="Staff Training Goals">Staff Training</option>';
		createString += 			'<option value="Tasting Goals">Tasting</option>';
		createString += 			'<option value="Window Display Goals">Window Display</option>';
		createString += 		'</select>';
		createString += 		'<select class="createGoalSelect2">';
		createString += 			'<option value="On-Premise - Control">On-Premise</option>';
		createString += 			'<option value="Off-Premise - Control">Off-Premise</option>';
		createString += 		'</select>';
		createString += 		' goal not associated to an existing goal:&nbsp;&nbsp;&nbsp;';
		createString += 	'</div>';
		createString += 	'<div class="createGoalButton" onclick="createNewGoal(true)">Create</div>';
		createString += '</div>';
		i--;
		j$("#tabs-" + i).append(createString);
		j$(".createGoalButton").button();
		
		j$("#channelTabDiv").tabs({
			   select: function(event, ui) { updateSubDiv(ui.index, null); }
			});
			
		doNextSetupStep();
	});
}

function setupTerritories(){
	updateLoadModal("Setting up territories...");
	if(repMode){
		contLoadFunc("getRepTerritories", null, function(result){
			territories = new Hash();
			territoryOwnerIds = [];
			
			for(var i = 0; i < result.length; i++){
				var terr = result[i];
				territories.put(terr.OwnerId, terr);
				territoryOwnerIds.push(terr.OwnerId);
			}
			
			doNextSetupStep();
		});
	} else {
		contLoadFunc("getManagerTerritories", null, function(result){
			territories = new Hash();
			territoryOwnerIds = [];
			
			for(var i = 0; i < result.length; i++){
				var terr = result[i];
				territories.put(terr.OwnerId, terr);
				territoryOwnerIds.push(terr.OwnerId);
			}
			
			doNextSetupStep();
		});
	}
}

function setupAccounts(){
	updateLoadModal("Setting up accounts...");
	contLoadFunc("getAccounts", territoryOwnerIds, function(result){
		var accounts = result;
		
		reps = new Hash();
		repsByTerritory = new Hash();
		premises = new Hash();
		
		buttonString = '<div class="premiseButtonDiv">';
		
		//create premises
		premises.put('On-Premise - Control', 0);
		premises.put('Off-Premise - Control', 1);
		//REMOVE COMBINED premises.put('Combined Premise - Control', 2);
		
		buttonString += '<input type="radio" name="radio-tab-INDEX_REPLACE" class="premiseButton" value="0" id="radio-tab-INDEX_REPLACE-button-0" checked="true"/>';
		buttonString += 	'<label for="radio-tab-INDEX_REPLACE-button-0">On Premise</label>'
		buttonString += '<input type="radio" name="radio-tab-INDEX_REPLACE" class="premiseButton" value="1" id="radio-tab-INDEX_REPLACE-button-1"/>';
		buttonString += 	'<label for="radio-tab-INDEX_REPLACE-button-1">Off Premise</label>'
		//REMOVE COMBINED buttonString += '<input type="radio" name="radio-tab-INDEX_REPLACE" class="premiseButton" value="2" id="radio-tab-INDEX_REPLACE-button-2"/>';
		//REMOVE COMBINED buttonString += 	'<label for="radio-tab-INDEX_REPLACE-button-2">Combined Premise</label>'
		
		for(var i = 0; i < accounts.length; i++){
			var acc = accounts[i];
			
			//modify name string
			acc.Name = acc.Name.split(' ( ')[0];
			if(acc.Doing_Business_As__c != null){
				acc.Name = acc.Doing_Business_As__c;
			}
			if(acc.Nabca_Licensee_Address__c != null){
				acc.Name += '<br/>(' + acc.Nabca_Licensee_Address__c + ')';
			}
			
			var rep;
			var terr = territories.get(acc.OwnerId);
			if(reps.get(acc.OwnerId) == null){
				//rep object has not yet been created
				
				//create rep object
				rep = new Object();
				rep.repId = acc.OwnerId;
				rep.repName = acc.Owner.Name;
				rep.territoryId = terr.Id;
				rep.territoryName = terr.Name;
				rep.premisesByName = new Hash();
				rep.accountsById = new Hash();
				rep.childGoals = new Hash();
				addPremiseToRep(acc.RecordType.Name, rep);
				
				reps.put(rep.repId, rep);
				repsByTerritory.put(rep.territoryId, rep);
			} else {
				//grab existing rep
				rep = reps.get(acc.OwnerId);
				addPremiseToRep(acc.RecordType.Name, rep);
			}
			
			//add account to rep's accounts
			rep.accountsById.put(acc.Id, acc);
		}
		buttonString += '</div>';
		
		//add buttons to each tab
		for(var i = 0; i < channels.length(); i++){
			var tempString = buttonString.split("INDEX_REPLACE").join(i);
			var j = 0;
			for(var j = 0; j < premises.length(); j++){
				var showCases = false;
				if(j == 1 && (i == 0 || i == 2)){
				//if(j == 1 && (i == 0 || i == 2 || i == 5)){
					showCases = true;
				}
			
				tempString += '<div id="tab' + i + '-premise' + j + '">';
				tempString += 	'<div class="noGoalsBlock">';
				tempString += 		'No Goals found. Please select a different channel or premise.';
				tempString += 	'</div>';
				if(repMode == false){
					tempString += 	'<div class="totalBlock" channel="' + i + '" premise="' + j + '">';
					tempString += 		'<div class="titleBar">';
					tempString += 			'<div class="repName">Totals</div>';
					tempString += 		'</div>';
					tempString +=		'<div class="goalGrayBarLine">';
					tempString += 			'<div class="totalFirstColumnCell"></div>';
					tempString += 			'<div class="goalGrayBlock">Goals</div>';
					tempString +=		'</div>';
					tempString +=		'<div class="totalHeaderLine">';
					tempString += 			'<div class="totalFirstColumnCell"></div>';
					tempString +=		'</div>';
					tempString +=		'<div class="totalLine" style="background-color: #F0F0F0">';
					tempString += 			'<div class="totalFirstColumnCell">Accounts available</div>';
					tempString +=		'</div>';
					tempString +=		'<div class="totalLine">';
					if(!showCases){
						tempString += 			'<div class="totalFirstColumnCell">Accounts needed</div>';
					} else {
						tempString += 			'<div class="totalFirstColumnCell">Accounts / Cases needed</div>';
					}
					tempString +=		'</div>';
					tempString +=		'<div class="totalLine" style="background-color: #F0F0F0">';
					if(!showCases){
						tempString += 			'<div class="totalFirstColumnCell">Accounts you have chosen</div>';
					} else {
						tempString += 			'<div class="totalFirstColumnCell">Accounts / Cases you have chosen</div>';
					}
					tempString +=		'</div>';
					tempString +=		'<div class="totalLine">';
					if(!showCases){
						tempString += 			'<div class="totalFirstColumnCell">Accounts reps will choose</div>';
					} else {
						tempString += 			'<div class="totalFirstColumnCell">Accounts / Cases reps will choose</div>';
					}
					tempString +=		'</div>';
					tempString +=		'<div class="finalTotalLine">';
					if(!showCases){
						tempString += 			'<div class="totalFirstColumnCell">Accounts still needed</div>';
					} else {
						tempString += 			'<div class="totalFirstColumnCell">Accounts / Cases still needed</div>';
					}
					tempString +=		'</div>';
					tempString +=		'<div class="submitTotalLine">';
					tempString += 			'<div class="totalFirstColumnCell"></div>';
					tempString +=		'</div>';
					tempString += 	'</div>';
				}
				tempString += '</div>';
			}
			j$("#channelTabDiv > #tabs-" + i).append(tempString);
		}
		
		//convert radios to button set and add functionality
		j$(".premiseButtonDiv").buttonset();
		j$(".premiseButton").click(function(){
				updateSubDiv(null, this.index);
			});
		
		//create divs for reps
		var chanValues = channels.values();
		var repValues = reps.values();
		for(var i = 0; i < chanValues.length; i++){
			for(var j = 0; j < repValues.length; j++){
				var rep = repValues[j];
				var repPremiseValues = rep.premisesByName.values();
				for(var k = 0; k < repPremiseValues.length; k++){
					var premiseString = repPremiseValues[k];
					var premiseIndex = premises.get(premiseString);
					
					var repBlockKey = rep.repId + '|' + i + '|' + premiseIndex;
					j$("#tab" + i + "-premise" + premiseIndex).append(createRepBlock(rep.repId, premiseString, repBlockKey));
					var repBlock = j$("#tab" + i + "-premise" + premiseIndex + " .repBlock:last");
					
					repBlock.find(".repName").append(rep.repName);
					repBlock.find(".territoryName").append(' - ' + rep.territoryName);
					var accValues = rep.accountsById.values();
					for(var l = 0; l < accValues.length; l++){
						var acc = accValues[l];
						if(acc.RecordType.Name == premiseString){
							var lineString = '';
							lineString += '<div class="accountLine" accId="' + acc.Id + '" repBlockKey="' + repBlockKey + '" segment="' + acc.Account_Segmentatiobn__c + '" accName="' + acc.Name + '" premise="' + premiseString + '" channel="' + chanValues[i] + '" shown="true">';
							lineString += 		'<div class="accountNameCell">';
							lineString += 			acc.Name;
							lineString += 		'</div>';
							lineString += '</div>';
							repBlock.find(".accountLines").append(lineString);
						}
					}
				}
			}
		}
		
		doNextSetupStep();
	});
}

function addPremiseToRep(premise, rep){
	//add premise to rep's premise
	if(rep.premisesByName.get(premise) == null){
		rep.premisesByName.put(premise, premise);
	}
}

function colorAccounts(andSort){
	if(isIE8()){
		//do not color lines in IE8
	} else {
		j$(".accountLines").each(
			function(){
				/*if(andSort){
					j$(this).find('.accountLine[shown="true"]').sortElements(function (a, b){
						var nameA = j$(a).attr('accName');
						var nameB = j$(b).attr('accName');
						if(nameA < nameB){
							return -1;
						} else {
							return 1;
						}
					});
				}*/
				j$(this).find('.accountLine[shown="true"]:even').css("background-color", "#F0F0F0");
				j$(this).find('.accountLine[shown="true"]:odd').css("background-color", "#FFFFFF");
			}
		);
	}
}

function setupGoals(){
	updateLoadModal("Setting up goals...");
	
	parentGoals = new Hash();
	childGoals = new Hash();
	actions = new Hash();
	
	if(repMode){
		contLoadFunc("getRepGoals", null, function(result){
			doRepGoalSetup(result);
		});
	} else {
		contLoadFunc("getManagerGoals", null, function(result){
			doManagerGoalSetup(result);
		});
	}
}

function doRepGoalSetup(result){
	for(var i = 0; i < result.length; i++){
		var goal = new Object();
		goal.goalId = result[i].Id;
		goal.repId = result[i].OwnerId;
		goal.key = goal.goalId + '|' + goal.repId;
		goal.name = result[i].Name;
		goal.channel = result[i].Sales_Channel__c;
		goal.premise = result[i].Goal_Type__c;
		goal.recTypeName = result[i].RecordType.Name;
		goal.shouldShowCases = false;
		if(goal.premise == 'Off-Premise - Control' && (goal.channel == 'Integrated National Program' || goal.channel == 'Display/Visibility')){
			goal.shouldShowCases = true;
		}
		goal.children = new Hash();
		goal.mode = result[i].Assignment_Mode__c;
		goal.numAccsAvail = 0;
		goal.numCasesNeeded = result[i].Cases_Displayed__c;
		var dueDate = new Date(result[i].Due_Date__c);
		goal.dueDate = (dueDate.getUTCMonth() + 1) + '/' + dueDate.getUTCDate() + '/' + dueDate.getUTCFullYear();
		
		goal.selectedAccountIds = new Hash();
		goal.casesByAccountId = new Hash();
		if(goal.mode == 'manual'){
			if(result[i].Assignment_Mode_Detail__c != null){
				var accIdsAndCaseValues = result[i].Assignment_Mode_Detail__c.split('|');
				for(var k = 0; k < accIdsAndCaseValues.length; k++){
					var accIdsAndCaseValue = accIdsAndCaseValues[k].split(',');
					var accId = accIdsAndCaseValue[0];
					var caseValue = accIdsAndCaseValue[1];
					goal.selectedAccountIds.put(accId, accId);
					goal.casesByAccountId.put(accId, caseValue);
				}
			}
		} else {
			goal.detail = result[i].Assignment_Mode_Detail__c;
			if(result[i].Actions__r != null){
				var actions = result[i].Actions__r;
				for(var k = 0; k < actions.length; k++){
					var accId = actions[k].Account__c;
					goal.selectedAccountIds.put(accId, accId);
				}
			}
		}
		goal.numAccsSel = goal.selectedAccountIds.length();
		
		goal.isAssigned = false;
		if(result[i].Actions__r != null && result[i].Actions__r.length > 0){
			goal.isAssigned = true;
			for(var j = 0; j < result[i].Actions__r.length; j++){
				var action = result[i].Actions__r[j];
				goal.children.put(action.Account__c, action);
			}
		}
		
		parentGoals.put(goal.key, goal);
		
		var channelIndex = channels.get(goal.channel);
		var premiseIndex = premises.get(goal.premise);
		var tab = j$("#tab" + channelIndex + "-premise" + premiseIndex);
		
		for(var j = 0; j < reps.length(); j++){
			var rep = reps.values()[j];
			if(rep.premisesByName.get(goal.premise) != null){
				//rep's premise matches
				rep.childGoals.put(goal.key, goal);
				
				j$("#tab" + channelIndex + "-premise" + premiseIndex + " .repBlock").each(function(){
					var repId = j$(this).attr("repId");
					if(repId == goal.repId){
						j$(this).find(".gridHeader").append(createGoalHeader(goal));
						
						var topString = '';
						topString += '<div class="accountTopCell" goalKey="' + goal.key + '">';
						topString += 	'<div class="topText"/>';
						topString += 	'<div class="assignSelectAll" goalKey="' + goal.key + '" onclick="assignAll(\'' + goal.key + '\', true)">Select all</div>';
						topString += 	'<div class="assignSelectAll" goalKey="' + goal.key + '" onclick="assignAll(\'' + goal.key + '\', false)">Deselect all</div>';
						topString += '</div>';
						j$(this).find(".accountTopLine").append(topString);
						
						var sumString = '';
						sumString += 	'<div class="sumLineCell" goalKey="' + goal.key + '">';
						sumString += 		'<div class="sumText"/>';
						sumString += 		'<div class="acceptButton" goalId="' + goal.goalId + '" onclick="acceptGoal(\'' + goal.key + '\')">Accept</div>';
						sumString += 	'</div>';
						j$(this).find(".sumLine").append(sumString);
					}
				});
			}
		}
	}
	j$(".goalViewButton").button();
	j$(".acceptButton").button();
	j$(".assignSelectAll").button();
	
	doNextSetupStep();
}

function doManagerGoalSetup(result){
	/*for(var i = 0; i < result.length; i++){
		addMgrGoal(result[i], true);
	}*/
	var i = 0;
	var ro = new RepeatingOperation(function() {
		addMgrGoal(result[i], true);
		i++;
		if(i < result.length){
			ro.step();
		} else {
			j$(".goalEditButton").button();
			j$(".assignSelectAll").button();
			j$(".assignCopyButton").button();
			j$('.newSubmitButton').button();
			
			doNextSetupStep();
		}
	}, 10);
	ro.step();
}

function addMgrGoal(source, fromSOQL){
	var goal;
	if(fromSOQL){
		goal = new Object()
		goal.goalId = source.Id;
		goal.name = source.Name;
		goal.channel = source.Sales_Channel__c;
		goal.premise = source.Goal_Type__c;
		goal.recTypeName = source.RecordType.Name;
		goal.shouldShowCases = false;
		if(goal.premise == 'Off-Premise - Control' && (goal.channel == 'Integrated National Program' || goal.channel == 'Display/Visibility')){
			goal.shouldShowCases = true;
		}
		goal.numAccsNeeded = source.Minimum_of_Accounts__c;
		goal.numCasesNeeded = source.Cases_Displayed__c;
		goal.savedChildren = new Hash();
		goal.submittedChildren = new Hash();
		var dueDate = new Date(source.Due_Date__c);
		goal.dueDate = (dueDate.getUTCMonth() + 1) + '/' + dueDate.getUTCDate() + '/' + dueDate.getUTCFullYear();
		if(source.Child_Goals__r != null){
			for(var i = 0; i < source.Child_Goals__r.length; i++){
				var child = source.Child_Goals__r[i];
				if(child.OwnerId == child.Goal_For__c){
					goal.submittedChildren.put(child.Goal_For__c, child);
				} else {
					goal.savedChildren.put(child.Goal_For__c, child);
				}
			}
		}
	} else {
		goal = source;
		goal.savedChildren = new Hash();
		goal.submittedChildren = new Hash();
		goal.shouldShowCases = false;
		if(goal.premise == 'Off-Premise - Control' && (goal.channel == 'Integrated National Program' || goal.channel == 'Display/Visibility')){
			goal.shouldShowCases = true;
		}
	}
	goal.children = new Hash();
	goal.numAccsSel = 0;
	goal.numCasesSel = 0;
	
	//check for premise validity
	if(checkPremValidity(goal)){
		//add to records
		parentGoals.put(goal.goalId, goal);
		
		//update total box
		var channelIndex = channels.get(goal.channel);
		var premiseIndex = premises.get(goal.premise);
		var tab = j$("#tab" + channelIndex + "-premise" + premiseIndex);
		var headerString = '';
		headerString += '<div class="totalGoalHeader" goalId="' + goal.goalId + '">';
		if(goal.channel == 'Local'){
			headerString += 	'<div class="goalName">' + goal.name + '<br/><i>' + goal.recTypeName + '</i><br/>(Due ' + goal.dueDate + ')</div>';
		} else {
			headerString += 	'<div class="goalName">' + goal.name + '<br/>(Due ' + goal.dueDate + ')</div>';
		}
		headerString += 	'<div class="goalEditButton" goalId="' + goal.goalId + '" onclick="editGoal(\'' + goal.goalId + '\')">Edit Goal</div>';
		headerString += '</div>';
		j$(tab).find(".totalHeaderLine").append(headerString);
		j$(tab).find(".totalLine:eq(0)").append('<div class="totalGoalCell" goalId="' + goal.goalId + '" type="avail"/>');
		j$(tab).find(".totalLine:eq(1)").append('<div class="totalGoalCell" goalId="' + goal.goalId + '" type="req"/>');
		j$(tab).find(".totalLine:eq(2)").append('<div class="totalGoalCell" goalId="' + goal.goalId + '" type="you"/>');
		j$(tab).find(".totalLine:eq(3)").append('<div class="totalGoalCell" goalId="' + goal.goalId + '" type="reps"/>');
		j$(tab).find(".finalTotalLine").append('<div class="totalGoalCell" goalId="' + goal.goalId + '" type="needed"/>');
		j$(tab).find(".submitTotalLine").append('<div class="totalGoalCell" goalId="' + goal.goalId + '" type="button"><div class="newSubmitButton" goalId="' + goal.goalId + '" onclick="newSubmitGoal(\'' + goal.goalId + '\')">Submit</div></div>');
		
		var repValues = reps.values();
		for(var j = 0; j < repValues.length; j++){
			var rep = repValues[j];
			/*if(rep.premisesByName.get(goal.premise) == null){
				addPremiseToRep(goal.premise, rep);
			}*/
			if(rep.premisesByName.get(goal.premise) != null){
				//rep's premise matches
				
				//try to find existing child goal
				var childGoal = new Object();
				childGoal.parentId = goal.goalId;
				childGoal.repId = rep.repId;
				childGoal.premise = goal.premise;
				childGoal.channel = goal.channel;
				childGoal.shouldShowCases = false;
				if(childGoal.premise == 'Off-Premise - Control' && (childGoal.channel == 'Integrated National Program' || childGoal.channel == 'Display/Visibility')){
					childGoal.shouldShowCases = true;
				}
				childGoal.key = childGoal.parentId + "|" + childGoal.repId;
				childGoal.numAccsAvail = 0;
				childGoal.numAccsSel = 0;
				childGoal.numCasesSel = 0;
				childGoal.isAssigned = false;
				childGoal.selectedAccountIds = new Hash();
				childGoal.casesByAccountId = new Hash();
				
				var existGoal = goal.submittedChildren.get(childGoal.repId);
				if(existGoal == null){
					existGoal = goal.savedChildren.get(childGoal.repId);
				}
				if(existGoal == null){
					//no previously saved goal, create a child goal from parent
					childGoal.mode = "count";
					childGoal.detail = "0";
					childGoal.numCasesSel = "0";
				} else {
					//previously saved child goal exists
					childGoal.Id = existGoal.Id;
					if(existGoal.OwnerId == existGoal.Goal_For__c){
						childGoal.isAssigned = true;
					}
					childGoal.mode = existGoal.Assignment_Mode__c;
					if(childGoal.mode == 'manual' && existGoal.Assignment_Mode_Detail__c != '' && existGoal.Assignment_Mode_Detail__c != null){
						var accIdsAndCaseValues = existGoal.Assignment_Mode_Detail__c.split('||');
						for(var k = 0; k < accIdsAndCaseValues.length; k++){
							var accIdsAndCaseValues = accIdsAndCaseValues[k].split('|');
							var accId = accIdsAndCaseValues[0];
							var caseValue = accIdsAndCaseValues[1];
							childGoal.selectedAccountIds.put(accId, accId);
							childGoal.casesByAccountId.put(accId, caseValue);
						}
					} else {
						childGoal.detail = existGoal.Assignment_Mode_Detail__c;
					}
				}
				
				childGoals.put(childGoal.key, childGoal);
				rep.childGoals.put(childGoal.parentId, childGoal);
				goal.children.put(childGoal.repId, childGoal);
				
				/*if(existGoal == null && (goal.channel == 'Distribution' || goal.channel == 'Innovation' || goal.channel == 'Sustainovation')){
					childGoal.mode = 'manual';
					childGoal.defaultSelectAll = true;
				}*/
				
				j$(tab).find(".repBlock").each(function(){
					var repId = j$(this).attr("repId");
					if(repId == childGoal.repId){
						j$(this).find(".gridHeader").append(createGoalHeader(childGoal));
						
						var topString = '';
						topString += 	'<div class="accountTopCell" goalKey="' + childGoal.key + '">';
						topString += 		'<div class="assignSelectAll" goalKey="' + childGoal.key + '" onclick="assignAll(\'' + childGoal.key + '\', true)">Select all</div>';
						topString += 		'<div class="assignSelectAll" goalKey="' + childGoal.key + '" onclick="assignAll(\'' + childGoal.key + '\', false)">Deselect all</div>';
						topString += 		'<div class="assignCountInput" style="display: none">';
						topString += 			'#Accs:';	
						topString += 			'<input class="assignInput" onkeyup="valueChanged(\'' + childGoal.key + '\', this.value, 0)"/>';
						if(childGoal.shouldShowCases == true){
							topString += 		'   #Cases:';	
							topString += 		'<input class="assignInput2" onkeyup="valueChanged(\'' + childGoal.key + '\', this.value, 1)"/>';
						}
						topString += 		'</div>';
						topString += 		'<div class="assignPercentInput" style="display: none">';
						topString += 			'%Accs:';
						topString += 			'<input class="assignInput" onkeyup="valueChanged(\'' + childGoal.key + '\', this.value, 0)"/>';
						if(childGoal.shouldShowCases == true){
							topString += 		'   %Cases:';
							topString += 		'<input class="assignInput2" onkeyup="valueChanged(\'' + childGoal.key + '\', this.value, 1)"/>';
						}
						topString += 		'</div>';
						topString += 	'</div>';
						j$(this).find(".accountTopLine").append(topString);
						
						var sumString = '';
						sumString += 	'<div class="sumLineCell" goalKey="' + childGoal.key + '">';
						sumString += 		'<div class="sumText"/>';
						sumString += 		'<div class="assignCopyButtons">';
						sumString += 			'Copy:';
						sumString += 			'<div class="assignCopyButton" onclick="copyVert(\'' + childGoal.key + '\')">↕</div>';
						sumString += 			'<div class="assignCopyButton" onclick="copyHorz(\'' + childGoal.key + '\')">↔</div>';
						sumString += 		'</div>';
						sumString += 	'</div>';
						j$(this).find(".sumLine").append(sumString);
						
						
						
					}
				});
				
				updateGoalSumText(childGoal.key, false);
			}
		}
	}
}

function checkPremValidity(goal){
	var repValues = reps.values();
	for(var j = 0; j < repValues.length; j++){
		if(repValues[j].premisesByName.get(goal.premise) != null){
			return true;
		}
	}
	showPremiseMessage(goal.premise);
	return false;
}

function setupActions(){
	updateLoadModal("Setting up actions...");
	
	var goalValues;
	if(repMode){
		goalValues = parentGoals.values();
	} else {
		goalValues = childGoals.values();
	}
	var repValues = reps.values();
	
	var i = 0;
	var ro = new RepeatingOperation(function() {
		var childGoal = goalValues[i];
		if(childGoal != null){
			doNextActionStep(childGoal, repValues);
		}
		i++;
		if(i < goalValues.length){
			ro.step();
		} else {
			doNextSetupStep();
		}
	}, 1);
	ro.step();
}

function doNextActionStep(childGoal, repValues){
	childGoal.numAccsSel = 0;
	childGoal.numCasesSel = 0;
	
	var channelIndex = channels.get(childGoal.channel);
	var premiseIndex = premises.get(childGoal.premise);
	
	if(isIE8()){
		var key = channelIndex + '|' + premiseIndex;
		var count = ie8Widths.get(key);
		if(count == null){
			count = 0;
		}
		count++;
		ie8Widths.put(key, count);
	}
	
	var rep = reps.get(childGoal.repId);
	var repBlock = j$('.repBlock[key="' + rep.repId + '|' + channelIndex + '|' + premiseIndex + '"]');
	
	var accLines = new Hash();
	j$(repBlock).find('.accountLine').each( function(){
		accLines.put(j$(this).attr('accId'), j$(this));
	});
	
	var accValues = rep.accountsById.values();	
	for(var i = 0; i < accValues.length; i++){
		var acc = accValues[i];
		if(acc.RecordType.Name == childGoal.premise){
			doNextActionSubStep(acc, childGoal, rep, accLines.get(acc.Id));
		}
	}
}

function doNextActionSubStep(acc, childGoal, rep, accLine){	
	//create data
	var action = new Object();
	action.accountId = acc.Id.substring(0,15);
	action.goalKey = childGoal.key;
	action.goalId = childGoal.goalId;
	action.key = action.accountId + "|" + action.goalKey;
	action.repId = rep.Id;
	action.selected = false;
	if(childGoal.selectedAccountIds.get(action.accountId) != null){
		action.selected = true;
		childGoal.numAccsSel++;
		var caseValue = parseInt(childGoal.casesByAccountId.get(action.accountId));
		action.caseValue = caseValue;
		childGoal.numCasesSel += caseValue;
	} else if(childGoal.defaultSelectAll){
		action.selected = true;
		childGoal.numAccsSel++;
		action.caseValue = 1;
		childGoal.numCasesSel++;
	}
	if(isNaN(action.caseValue)){
		action.caseValue = 0;
	}
	actions.put(action.key, action);
	
	childGoal.numAccsAvail++;
	
	//add to layout
	var cellString = '';
	cellString += '<div class="actionCell" goalKey="' + action.goalKey + '">';
	if(action.selected){
		cellString += '<input type="checkbox" class="actionSelectCheckbox" key="' + action.key + '" goalKey="' + action.goalKey + '" accId="' + action.accountId + '" onchange="actionSelected(\'' + action.key + '\', this.checked)" checked="true"/>';
	} else {
		cellString += '<input type="checkbox" class="actionSelectCheckbox" key="' + action.key + '" goalKey="' + action.goalKey + '" accId="' + action.accountId + '" onchange="actionSelected(\'' + action.key + '\', this.checked)"/>';
	}
	/*
	if(childGoal.shouldShowCases){
		cellString += '<span class="casesLabel">Cases:</span>';
		if(action.selected){
			if(repMode){
				cellString += '<span class="casesLabel">' + action.caseValue + '</span>';
			} else {
				cellString += '<input class="casesInput" type="number" key="' + action.key + '" goalKey="' + action.goalKey + '" accId="' + action.accountId + '" onfocus="setOldCaseValue(this.value)" oninput="casesChanged(\'' + action.key + '\', this.value) value="' + action.caseValue + '"/>';
			}				
		} else {
			cellString += '<input class="casesInput" type="number" key="' + action.key + '" goalKey="' + action.goalKey + '" accId="' + action.accountId + '" onfocus="setOldCaseValue(this.value)" oninput="casesChanged(\'' + action.key + '\', this.value)" readonly="true"/>';
		}
	}
	*/
	cellString += '</div>';
	j$(accLine).append(cellString);
}

function updateAllTotals(){
	updateLoadModal("Updating all totals...");
	
	if(repMode){
		var goalVals = parentGoals.values();
		for(var i = 0; i < goalVals.length; i++){
			assignTypeChanged(goalVals[i].key, goalVals[i].mode, true, true);
		}
		doNextSetupStep();
	} else {
		confirmInt = 0;
		var goalVals = parentGoals.values();
		if(goalVals.length > 0){
			var i = 0;
			var ro = new RepeatingOperation(function() {
				updateTotals(goalVals[i].goalId);
				i++;
				if(i < goalVals.length){
					ro.step();
				} else {
					confirmNextSetupStep(2);
				}
			}, 100);
			ro.step();
		} else {
			confirmNextSetupStep(2);
		}
		
		var childGoalVals = childGoals.values();
		if(childGoalVals.length > 0){
			var j = 0;
			var ro = new RepeatingOperation(function() {
				var somethin = j;
				var something = childGoalVals[j];
				assignTypeChanged(childGoalVals[j].key, childGoalVals[j].mode, true, true);
				j++;
				if(j < childGoalVals.length){
					ro.step();
				} else {
					confirmNextSetupStep(2);
				}
			}, 100);
			ro.step();
		} else {
			confirmNextSetupStep(2);
		}
	}
}

var confirmInt;
function confirmNextSetupStep(maxInt){
	//this function is used to ensure that all async steps are finished before moving on to the next step
	confirmInt++;
	if(confirmInt == maxInt){
		doNextSetupStep();
	}
}

function addSaveButtons(){
	updateLoadModal("Adding buttons...");
	
	var buttonString = '';
	if(repMode){
		//buttonString += '<div class="submitButton">Accept & Create Actions</div>';
		//j$('.saveButtons').append(buttonString);
		
		//make sure at least one child goal is not yet assigned
		var oneIsUnassigned = false;
		var children = parentGoals.values();
		for(var i = 0; i < children.length && oneIsUnassigned == false; i++){
			if(children[i].isAssigned == false){
				oneIsUnassigned = true;
			}
		}
		
		if(oneIsUnassigned){
			j$(".submitButton").button();
			j$(".submitButton").click(function(){submitClicked()});
		} else {
			j$(".submitButton").button({disabled: true});
			addRepReadOnlyMessage();
		}
	} else {
		/*buttonString += '<div class="saveButton">Save</div>';
		buttonString += '<div class="submitButton">Submit for Rep Acceptance</div>';
		j$('.saveButtons').append(buttonString);*/
		
		//make sure at least one child goal is not yet assigned
		var oneIsUnassigned = false;
		if(childGoals != null){
			var children = childGoals.values();
			for(var i = 0; i < children.length && oneIsUnassigned == false; i++){
				if(children[i].isAssigned == false){
					oneIsUnassigned = true;
				}
			}
			
			if(oneIsUnassigned){
				j$(".saveButton").button();
				j$(".saveButton").click(function(){saveClicked()});
				j$(".submitButton").button();
				j$(".submitButton").click(function(){submitClicked()});
			} else {
				j$(".saveButton").button({disabled: true});
				j$(".submitButton").button({disabled: true});
				addReadOnlyMessage();
			}
		} else {
			j$(".saveButton").button({disabled: true});
			j$(".submitButton").button({disabled: true});
		}
	}
	
	doNextSetupStep();
}

function applyAll(){
	if(repMode){
		j$('.accountLines').css('max-height', 300);
		j$('.createGoalBlock').hide();
	}
	
	colorAccounts(true);
	updateRepCounts(true, false);
	
	updateSubDiv(0, 0);
	
	doNextSetupStep();
}

function finishAll(){
	updateLoadModal("All done!");
	j$("#loadModal").dialog("close");
}

function createRepBlock(repId, premise, key){
	var blockString = '';
	blockString += '<div class="repBlock" repId="' + repId + '" key="' + key + '">';
	blockString += 		'<div class="titleBar">';
	blockString += 			'<div class="repName"/>';
	blockString += 			'<div class="territoryName"/>';
	blockString += 		'</div>';
	blockString +=		'<div class="goalGrayBarLine">';
	blockString += 			'<div class="totalFirstColumnCell"></div>';
	blockString += 			'<div class="goalGrayBlock"/>';
	blockString +=		'</div>';
	blockString += 		'<div class="gridHeader">';
	blockString += 			'<div class="accountHeader">';
	blockString += 				'Show Accounts with Segmentation:';
	blockString += 				'<br/>';
	blockString += 				'<input type="checkbox" class="accountFilterCheckbox" value="A" checked="true" onchange="updateAccountFilters(\'' + key + '\')">';
	blockString += 					'<span class="accountFilterCheckboxLabel">A</span>';
	blockString += 				'</input>';
	blockString += 				'<input type="checkbox" class="accountFilterCheckbox" value="B" checked="true" onchange="updateAccountFilters(\'' + key + '\')">';
	blockString += 					'<span class="accountFilterCheckboxLabel">B</span>';
	blockString += 				'</input>';
	blockString += 				'<input type="checkbox" class="accountFilterCheckbox" value="C" checked="true" onchange="updateAccountFilters(\'' + key + '\')">';
	blockString += 					'<span class="accountFilterCheckboxLabel">C</span>';
	blockString += 				'</input>';
	blockString += 				'<input type="checkbox" class="accountFilterCheckbox" value="D" checked="true" onchange="updateAccountFilters(\'' + key + '\')">';
	blockString += 					'<span class="accountFilterCheckboxLabel">D</span>';
	blockString += 				'</input>';
	blockString += 				'<input type="checkbox" class="accountFilterCheckbox" value="other" checked="true" onchange="updateAccountFilters(\'' + key + '\')">';
	blockString += 					'<span class="accountFilterCheckboxLabel">Other</span>';
	blockString += 				'</input>';
	blockString += 			'</div>';
	blockString += 		'</div>';
	blockString +=		'<div class="accountTopLine">';
	blockString += 			'<div class="accountTopFirst"/>';
	blockString +=		'</div>';
	blockString += 		'<div class="accountLines"/>';
	blockString +=		'<div class="sumLine" repId="' + repId + '" premise="' + premise + '">';
	blockString += 			'<div class="sumFirst">';
	blockString += 				'&nbsp;';
	blockString += 			'</div>';
	blockString += 		'</div>';
	blockString += '</div>';
	return blockString;
}

function createGoalHeader(childGoal){
	var goal;
	if(repMode){
		goal = childGoal;
	} else {
		goal = parentGoals.get(childGoal.parentId);
	}
	var headerString = '';
	headerString += '<div class="goalHeader" goalKey="' + childGoal.key + '">';
	if(goal.channel == 'Local'){
		headerString += 	'<div class="goalName">' + goal.name + '<br/><i>' + goal.recTypeName + '</i><br/>(Due ' + goal.dueDate + ')</div>';
	} else {
		headerString += 	'<div class="goalName">' + goal.name + '<br/>(Due ' + goal.dueDate + ')</div>';
	}
	
	if(repMode){
		headerString += 	'<div class="goalViewButton" goalId="' + childGoal.goalId + '" onclick="viewGoal(\'' + childGoal.goalId + '\')">View Goal</div>';
	} else {
		headerString += 	'Select: ';
		headerString += 	'<select class="assignTypeSelect" goalKey="' + childGoal.key + '" onchange="assignTypeChanged(\'' + childGoal.key + '\', this.value, true, false)">';
		headerString += 		'<option value="count">By count</option>';
		headerString += 		'<option value="percent">By percentage</option>';
		headerString += 		'<option value="manual">Manually</option>';
		headerString += 	'</select>';
	}
	headerString += '</div>';
	return headerString;
}