function recreateTabs(){
	var tabDiv = j$('#priorityTabDiv');
	j$(tabDiv).empty();
	j$(tabDiv).append('<ul/>');
	
	priorities = parentGoalsByPriority.keySet();
	priorities.sort();
	priorities.reverse();
	
	for(var i = 0; i < priorities.length; i++){
		var name = priorities[i];
		j$(tabDiv).find('ul').append('<li><a href="#invisibleDiv' + i + '" class="priorityTab" name="' + name + '" onclick="priorityChanged(\'' + name + '\')"></a></li>');
		j$(tabDiv).append('<div id="invisibleDiv' + i + '"/>');
	}
	
	j$(tabDiv).tabs();
	
	/*j$(tabDiv).mouseup(function() {
		j$(this).css('-moz-box-shadow', 'none');
		j$(this).css('-webkit-box-shadow', 'none');
		j$(this).css('box-shadow', 'none');
		
		j$('#invisibleDiv0').css('-moz-box-shadow', 'none');
		j$('#invisibleDiv0').css('-webkit-box-shadow', 'none');
		j$('#invisibleDiv0').css('box-shadow', 'none');
	});*/
	
	priorityChanged(priorities[0]);
}

function priorityChanged(priorityValue){
	currentPriority = priorityValue;

	var buttonDiv = j$('#premiseButtonDiv');
	j$(buttonDiv).empty();
	
	premises = [];
	var resetPremise = true;
	var goalsForCurrentPriority = parentGoalsByPriority.get(currentPriority);
	if(goalsForCurrentPriority != null){
		for(var i = 0; i < goalsForCurrentPriority.length; i++){
			var goal = goalsForCurrentPriority[i];
			if(goal.visible){
				if(premises.indexOf(goal.goal.Goal_Type__c) == -1){
					premises.push(goal.goal.Goal_Type__c);
					if(goal.goal.Goal_Type__c == currentPremise){
						resetPremise = false;
					}
				}
			}
		}
	}
	premises.sort();
	premises.reverse();
	if(resetPremise){
		currentPremise = premises[0];
	}
	
	var buttonString = '';
	for(i = 0; i < premises.length; i++){
		var premName = premises[i].split('-')[0];
		buttonString += '<input type="radio" id="premRadio' + premName + '" name="premRadio" class="premiseButton" onclick="premiseChanged(\'' + premises[i] + '\')"';
		if(premises[i] == currentPremise){
			buttonString += ' checked="checked"';
		}
		buttonString += '/>';
		buttonString += '<label class="premButtonLabel" nameVal="' + premises[i] + '" for="premRadio' + premName + '"/>';
	}
	j$(buttonDiv).append(buttonString);
	j$(buttonDiv).buttonset();

	premiseChanged(currentPremise);
}

function premiseChanged(premVal){
	currentPremise = premVal;

	var buttonDiv = j$('#rtButtonDiv');
	j$(buttonDiv).empty();
	
	recTypes = [];
	var resetRT = true;
	var goalsForCurrentPriorityAndPremise = parentGoalsByPriorityAndPremise.get(currentPriority + '|' + currentPremise);
	if(goalsForCurrentPriorityAndPremise != null){
		for(var i = 0; i < goalsForCurrentPriorityAndPremise.length; i++){
			var goal = goalsForCurrentPriorityAndPremise[i];
			if(goal.visible){
				if(recTypes.indexOf(goal.goal.RecordType.Name) == -1){
					recTypes.push(goal.goal.RecordType.Name);
					if(currentRT == goal.goal.RecordType.Name){
						resetRT = false;
					}
				}
			}
		}
	}
	recTypes.sort();
	if(resetRT){
		currentRT = recTypes[0];
	}
	
	var buttonString = '';
	for(i = 0; i < recTypes.length; i++){
		buttonString += '<input type="radio" id="rtRadio' + recTypes[i] + '" name="rtRadio" onclick="rtChanged(\'' + recTypes[i] + '\')"';
		if(recTypes[i] == currentRT){
			buttonString += ' checked="checked"';
		}
		buttonString += '/>';
		buttonString += '<label class="rtButtonLabel" nameVal="' + recTypes[i] + '" for="rtRadio' + recTypes[i] + '"/>';
	}
	j$(buttonDiv).append(buttonString);
	j$(buttonDiv).buttonset();
	
	rtChanged(currentRT);
}

function rtChanged(rtValue){
	currentRT = rtValue;
	currentKey = currentPriority + '|' + currentPremise + '|' + currentRT;
	currentGoals = [];
	
	var matchGoals = parentGoalsByPriorityPremiseAndRT.get(currentKey);
	if(matchGoals != null){
		for(var i = 0; i < matchGoals.length; i++){
			var goal = matchGoals[i];
			if(goal.visible){
				currentGoals.push(goal);
			}
		}
	}
	
	updateTabAndButtonNumbers();
	displayTotalBlock();
	displayRepBlocks();
}

function updateTabAndButtonNumbers(){
	var triggeredReset = false;
	var count;
	var goals;
	j$('.priorityTab').each(function() {
		count = 0;
		var name = j$(this).attr('name');
		goals = parentGoalsByPriority.get(name);
		for(var i = 0; i < goals.length; i++){
			if(goals[i].visible){
				count++;
			}
		}
		if(count > 0){
			j$(this).text(name + ' (' + count + ')');
		} else {
			triggeredReset = true;
			j$(this).parent().remove();
			priorities.splice(priorities.indexOf(name), 1);
			if(priorities.length > 0){
				priorityChanged(priorities[0]);
			} else {
				doneGoaling();
			}
		}
	});
	
	if(triggeredReset == false){
		j$('.premButtonLabel').each(function() {
			var name = j$(this).attr('nameVal');
			count = 0;
			goals = parentGoalsByPriorityAndPremise.get(currentPriority + '|' + name);
			for(var i = 0; i < goals.length; i++){
				if(goals[i].visible){
					count++;
				}
			}
			if(count > 0){
				j$(this).text(name.split(' - ')[0] + ' (' + count + ')');
			} else {
				triggeredReset = true;
				j$(this).remove();
				premises.splice(premises.indexOf(name), 1);
				if(premises.length > 0){
					priorityChanged(priorities[0]);
				} else if(priorities.length > 0){
					priorityChanged(priorities[0]);
				} else {
					doneGoaling();
				}
			}
		});
	}
	
	if(triggeredReset == false){
		j$('.rtButtonLabel').each(function() {
			var name = j$(this).attr('nameVal');
			count = 0;
			goals = parentGoalsByPriorityPremiseAndRT.get(currentPriority + '|' + currentPremise + '|' + name);
			if(goals != null){
				for(var i = 0; i < goals.length; i++){
					if(goals[i].visible){
						count++;
					}
				}
			}
			if(count > 0){
				j$(this).text(name.split(' - ')[0] + ' (' + count + ')');
			} else {
				j$(this).remove();
				recTypes.splice(recTypes.indexOf(name), 1);
				if(recTypes.length > 0){
					premiseChanged(premises[0]);
				} else if(premises.length > 0){
					priorityChanged(priorities[0]);
				} else if(priorities.length > 0){
					priorityChanged(priorities[0]);
				} else {
					doneGoaling();
				}
			}
		});
	}
}

var isDoneGoaling = false;
function doneGoaling(){
	isDoneGoaling = true;
}

function displayTotalBlock(){
	var totalBlocks = j$('#totalBlocks');
	j$(totalBlocks).find('.totalBlock').css('display', 'none');
	
	if(totalBlocksByCurrentKey.get(currentKey) == null){
		buildTotalBlock(totalBlocks);
	} else {
		j$(totalBlocks).find('.totalBlock[displayKey="' + currentKey + '"]').css('display', 'block');
	}
}

function buildTotalBlock(totalBlocks){
	var shouldShowCasesInLabels = false;
	if(repMode == false){
		for(var i = 0; i < currentGoals.length; i++){
			if(currentGoals[i].shouldShowCases == true){
				shouldShowCasesInLabels = true;
				i = currentGoals.length;
			}
		}
	}
	
	var tempString = '';
	tempString += 	'<div class="totalBlock" displayKey="' + currentKey + '">';
	tempString += 		'<div class="titleBar">';
	tempString += 			'<div class="repName">Totals</div>';
	tempString += 		'</div>';
	tempString +=		'<div class="goalGrayBarLine">';
	tempString += 			'<div class="totalFirstColumnCell"></div>';
	tempString += 			'<div class="goalGrayBlock">Goals</div>';
	tempString +=		'</div>';
	tempString +=		'<div class="totalHeaderLine">';
	tempString +=		'</div>';
	tempString +=		'<div class="totalLine" style="background-color: #F0F0F0">';
	tempString += 			'<div class="totalFirstColumnCell">Accounts available</div>';
	tempString +=		'</div>';
	tempString +=		'<div class="totalLine">';
	if(shouldShowCasesInLabels){
		tempString += 		'<div class="totalFirstColumnCell">Accounts / Cases needed</div>';
	} else {
		tempString += 		'<div class="totalFirstColumnCell">Accounts needed</div>';
	}
	tempString +=		'</div>';
	tempString +=		'<div class="totalLine" style="background-color: #F0F0F0">';
	if(repMode){
		tempString += 		'<div class="totalFirstColumnCell">Accounts your manager has chosen</div>';
	} else {
		tempString += 		'<div class="totalFirstColumnCell">Accounts you have chosen</div>';
	}
	tempString +=		'</div>';
	tempString +=		'<div class="totalLine">';
	if(shouldShowCasesInLabels){
		tempString += 		'<div class="totalFirstColumnCell">Accounts / Cases reps will choose</div>';
	} else if(repMode){
		tempString += 		'<div class="totalFirstColumnCell">Accounts you have chosen</div>';
	} else {
		tempString += 		'<div class="totalFirstColumnCell">Accounts reps will choose</div>';
	}
	tempString +=		'</div>';
	tempString +=		'<div class="finalTotalLine">';
	if(shouldShowCasesInLabels){
		tempString += 		'<div class="totalFirstColumnCell">Accounts / Cases still needed</div>';
	} else if(repMode){
		tempString += 		'<div class="totalFirstColumnCell">Actions you will create later</div>';
	} else {
		tempString += 		'<div class="totalFirstColumnCell">Accounts still needed</div>';
	}
	tempString +=		'</div>';
	tempString +=		'<div class="submitTotalLine">';
	tempString += 			'<div class="totalFirstColumnCell"></div>';
	tempString +=		'</div>';
	tempString +=	'</div>';
	
	j$(totalBlocks).append(tempString);
	
	var totalBlock = j$('.totalBlock[displayKey="' + currentKey + '"]');
	totalBlocksByCurrentKey.putInArray(currentKey, totalBlock);
	
	var totalHeaderLine = j$(totalBlock).find('.totalHeaderLine');
	j$(totalHeaderLine).append('<div class="totalFirstColumnCell"/>');
	
	for(var i = 0; i < currentGoals.length; i++){
		var goal = currentGoals[i];
		var headerString = '';
		headerString += '<div class="totalGoalHeader" goalId="' + goal.goal.Id + '">';
		if(goal.isRepAcceptable){
			headerString += '<div class="goalName">' + goal.goal.Long_Name__c + '<br/>(Due ' + goal.dueDate + ')</div>';
		} else {
			headerString += '<div class="goalNameGray">' + goal.goal.Long_Name__c + '<br/>(Due ' + goal.dueDate + ')</div>';
		}
		if(repMode){
			headerString += '<div class="goalViewButton" goalId="' + goal.goal.Id + '" onclick="viewGoal(\'' + goal.goal.Id + '\', false)">View Goal</div>';
		} else {
			headerString += '<div class="goalViewButton" goalId="' + goal.goal.Id + '" onclick="viewGoal(\'' + goal.goal.Id + '\', true)">Edit Goal</div>';
		}
		headerString += '</div>';
		j$(totalHeaderLine).append(headerString);
		
		var submitButtonLabel = 'Submit';
		if(repMode){
			submitButtonLabel = 'Accept';
		}
		
		j$(totalBlock).find('.totalLine:eq(0)').append('<div class="totalGoalCell" goalId="' + goal.goal.Id + '" type="avail"/>');
		j$(totalBlock).find('.totalLine:eq(1)').append('<div class="totalGoalCell" goalId="' + goal.goal.Id + '" type="req"/>');
		j$(totalBlock).find('.totalLine:eq(2)').append('<div class="totalGoalCell" goalId="' + goal.goal.Id + '" type="you"/>');
		j$(totalBlock).find('.totalLine:eq(3)').append('<div class="totalGoalCell" goalId="' + goal.goal.Id + '" type="reps"/>');
		j$(totalBlock).find('.finalTotalLine').append('<div class="totalGoalCell" goalId="' + goal.goal.Id + '" type="needed"/>');
		if(goal.isRepAcceptable){
			j$(totalBlock).find('.submitTotalLine').append('<div class="totalGoalCell" goalId="' + goal.goal.Id + '" type="button">' +
														   		'<div class="newSubmitButton" goalId="' + goal.goal.Id + '" onclick="submitGoal(\'' + goal.goal.Id + '\')">' + submitButtonLabel + '</div>' +
														   '</div>');
		} else {
			j$(totalBlock).find('.submitTotalLine').append('<div class="totalGoalCell"/>');
		}
	
		goal.accsAvailable = 0;
	}
	j$('.goalViewButton').button();
}

function displayRepBlocks(){
	var repBlocks = j$('#repBlocks');
	j$(repBlocks).find('.repBlock').css('display', 'none');
	
	if(repBlocksByCurrentKey.get(currentKey) == null){
		buildRepBlocks(repBlocks);
		if(repMode){
			j$('.accountLines').css('max-height', 300);
		}
		for(var i = 0; i < currentGoals.length; i++){
			updateTotals(currentGoals[i].goal.Id, true);
		}
	} else {
		j$(repBlocks).find('.repBlock[displayKey="' + currentKey + '"]').css('display', 'block');
	}
}

function buildRepBlocks(repBlocks){
	var underlings = underlingsById.values();
	
	for(var i = 0; i < underlings.length; i++){
		var underling = underlings[i];
		
		if(underling.accountArraysByPremise.get(currentPremise) != null){
			var accSegments = underling.accSegmentationsByPremise.get(currentPremise);
			accSegments.sort();
			
			var blockString = '';
			blockString += '<div class="repBlock" rep="' + underling.id + '" displayKey="' + currentKey + '">';
			blockString += 		'<div class="titleBar">';
			blockString += 			'<div class="repName">';
			blockString += 				underling.name;
			blockString += 			'</div>';
			blockString += 			'<div class="territoryName">';
			blockString += 				' - ' + underling.territoryNamesById.values().join(', ');
			blockString += 			'</div>';
			blockString += 		'</div>';
			blockString +=		'<div class="goalGrayBarLine">';
			blockString += 			'<div class="totalFirstColumnCell"></div>';
			blockString += 			'<div class="goalGrayBlock">Goals</div>';
			blockString +=		'</div>';
			blockString += 		'<div class="gridHeader">';
			blockString += 			'<div class="accountHeader">';
			blockString += 				'Show Accounts with Segmentation:';
			blockString += 				'<br/>';
			for(var j = 0; j < accSegments.length; j++){
				blockString += 			'<input type="checkbox" class="accountFilterCheckbox" value="' + accSegments[j] + '" checked="checked" onchange="updateAccountFilters(\'' + underling.id + '\')">';
				blockString += 				'<span class="accountFilterCheckboxLabel">' + accSegments[j] + '</span>';
				blockString += 			'</input>';
			}
			blockString += 			'</div>';
			blockString += 		'</div>';
			blockString +=		'<div class="accountTopLine">';
			blockString += 			'<div class="accountTopFirst"/>';
			blockString +=		'</div>';
			blockString += 		'<div class="accountLines"/>';
			blockString +=		'<div class="sumLine">';
			blockString += 			'<div class="sumFirst">';
			blockString += 				'&nbsp;';
			blockString += 			'</div>';
			blockString += 		'</div>';
			blockString += '</div>';
			
			j$(repBlocks).append(blockString);
			
			var repBlock = j$('.repBlock[rep="' + underling.id + '"][displayKey="' + currentKey + '"]');
			repBlocksByCurrentKey.putInArray(currentKey, repBlock);
			
			var gridHeader = j$(repBlock).find('.gridHeader');
			var accountTopLine = j$(repBlock).find('.accountTopLine');
			var accLines = j$(repBlock).find('.accountLines');
			var sumLine = j$(repBlock).find('.sumLine');
			
			var underlingAccs = underling.accountArraysByPremise.get(currentPremise);
			for(var j = 0; j < underlingAccs.length; j++){
				var acc = underlingAccs[j]
				var lineString = '';
				lineString += '<div class="accountLine" accId="' + acc.Id + '" segment="' + acc.Account_Segmentatiobn__c + '" shown="true">';
				lineString += 		'<div class="accountNameCell">';
				lineString += 			acc.Name;
				lineString += 		'</div>';
				lineString += '</div>';
				
				j$(accLines).append(lineString);
			}
			
			updateAccountFilters(underling.id);
			
			var accountLinesByAccId = new Hash();
			j$(repBlock).find('.accountLine').each(function(){
				var accId = j$(this).attr('accId');
				accountLinesByAccId.put(accId, this);
			});
			
			var childGoals = underling.childGoalsByKey.get(currentKey);
			for(j = 0; j < childGoals.length; j++){
				var childGoal = childGoals[j];
				
				var headerString = '';
				headerString += '<div class="goalHeader" goalKey="' + childGoal.key + '">';
				if(childGoal.parentGoal.isRepAcceptable){
					headerString += '<div class="goalName">' + childGoal.parentGoal.goal.Long_Name__c + '<br/>(Due ' + childGoal.parentGoal.dueDate + ')</div>';
				} else {
					headerString += '<div class="goalNameGray">' + childGoal.parentGoal.goal.Long_Name__c + '<br/>(Due ' + childGoal.parentGoal.dueDate + ')</div>';
				}
				if(!repMode){
					headerString += 'Select: ';
					headerString += '<select class="assignTypeSelect" goalKey="' + childGoal.key + '" onchange="assignTypeChanged(\'' + childGoal.key + '\', this.value, false, true)">';
					headerString += 	'<option value="count">By count</option>';
					headerString += 	'<option value="percent">By percentage</option>';
					headerString += 	'<option value="manual">Manually</option>';
					headerString += '</select>';
				}
				headerString += '<div/>';
				j$(gridHeader).append(headerString);
				
				var topString = '';
				topString += '<div class="accountTopCell" goalKey="' + childGoal.key + '">';
				if(repMode == false){
					topString += '<div class="assignCountInput" goalKey="' + childGoal.key + '">';
					topString += 	'#Accs:';	
					topString += 	'<input class="assignInput" onkeyup="valueChanged(\'' + childGoal.key + '\', this.value, \'accounts\', true)" value="0"/>';
					topString += '</div>';
					topString += '<div class="assignPercentInput" goalKey="' + childGoal.key + '">';
					topString += 	'%Accs:';	
					topString += 	'<input class="assignInput" onkeyup="valueChanged(\'' + childGoal.key + '\', this.value, \'accounts\', true)" value="0"/>';
					topString += '</div>';
				}
				topString += 	'<div class="assignSelectAll" goalKey="' + childGoal.key + '" onclick="assignAll(\'' + childGoal.key + '\', true, true)">Select all</div>';
				topString += 	'<div class="assignSelectAll" goalKey="' + childGoal.key + '" onclick="assignAll(\'' + childGoal.key + '\', false, true)">Deselect all</div>';
				if(repMode == false){
					topString += '<div class="assignOverageInput" goalKey="' + childGoal.key + '">';
					topString +=	'   Additional:';	
					topString += 	'<input class="assignInput" onkeyup="valueChanged(\'' + childGoal.key + '\', this.value, \'overage\', true)" value="0"/>';
					topString += '</div>';
				}
				if(repMode == false && childGoal.shouldShowCases == true){
					topString += '<div class="assignCasesInput" goalKey="' + childGoal.key + '">';
					topString +=	'   #Cases:';	
					topString += 	'<input class="assignInput" onkeyup="valueChanged(\'' + childGoal.key + '\', this.value, \'cases\', true)" value="0"/>';
					topString += '</div>';
				}
				topString += '</div>';
				j$(accountTopLine).append(topString);
				
				var sumString = '';
				sumString += 	'<div class="sumLineCell" goalKey="' + childGoal.key + '">';
				sumString += 		'<div class="sumText"/>';
				if(repMode == false){
					sumString += 	'<div class="assignCopyButtons">';
					sumString += 		'Copy:';
					sumString += 		'<div class="assignCopyButton" onclick="copyVert(\'' + childGoal.key + '\')">↕</div>';
					sumString += 		'<div class="assignCopyButton" onclick="copyHorz(\'' + childGoal.key + '\')">↔</div>';
					sumString += 	'</div>';
				}
				sumString += 	'</div>';
				j$(sumLine).append(sumString);
				
				if(childGoal.actions.length == 0){
					buildChildGoalActions(childGoal, underling.accounts);
				}
				
				for(var k = 0; k < childGoal.actions.length; k++){
					var action = childGoal.actions[k];
					var cellString = '';
					cellString += '<div class="actionCell" goalKey="' + childGoal.key + '">';
					cellString += '<input type="checkbox" class="actionSelectCheckbox" accId="' + action.account.Id + '" goalKey="' + childGoal.key + '" onchange="actionSelected(\'' + childGoal.key + '\', \'' + action.account.Id + '\')"';
					if(action.selected){
						cellString += ' checked="true"'
					}
					cellString += 	'/>';
					cellString += '</div>';
					j$(accountLinesByAccId.get(action.account.Id)).append(cellString);
				}
				
				/*if(repMode == false && childGoal.parentGoal.goal.RecordType.Name == 'Distribution Goals'){
					childGoal.assignMode = 'manual';
					j$('.assignTypeSelect[goalKey="' + childGoal.key + '"]').val(childGoal.assignMode);
					assignTypeChanged(childGoal.key, childGoal.assignMode, false, false);
					assignAll(childGoal.key, true, true);
				} else {
					assignTypeChanged(childGoal.key, childGoal.assignMode, false, true);
				}*/
				assignTypeChanged(childGoal.key, childGoal.assignMode, false, true);
				
				updateGoalSumText(childGoal.key);
			}
		}
	}
	
	j$('.assignSelectAll').button();
	j$('.assignCopyButton').button();
	j$('.newSubmitButton').button();
}

function updateAccountFilters(repId){
	var repBlock = j$('.repBlock[rep="' + repId + '"][displayKey="' + currentKey + '"]');
	var accsShown = 0;
	var allowedSegments = [];
	j$(repBlock).find('.accountFilterCheckbox').each(function(){
		if(j$(this).attr('checked') == 'checked'){
			allowedSegments.push(j$(this).attr('value'));
		}
	});
	j$(repBlock).find('.accountLine').each(function(){
		var acc = accountsById.get(j$(this).attr('accId'));
		var segment = j$(this).attr('segment');
		if(allowedSegments.indexOf(segment) == -1){
			j$(this).hide();
			j$(this).attr("shown", "false");
			acc.visible = false;
		} else {
			accsShown++;
			j$(this).show();
			j$(this).attr("shown", "true");
			acc.visible = true;
		}
	});
	
	var str = 'Accounts (' + accsShown + ' of ' + underlingsById.get(repId).accountArraysByPremise.get(currentPremise).length + ')';
	j$(repBlock).find('.accountTopFirst').empty();
	j$(repBlock).find('.accountTopFirst').append(str);
	
	colorAccounts(false);
}

function buildChildGoalActions(childGoal, accArray){
	var preselectedAccountIds = new Hash();
	if(repMode && childGoal.parentGoal.goal.Assignment_Mode__c == 'manual' && childGoal.parentGoal.goal.Assignment_Mode_Detail__c != null){
		var accIds = childGoal.parentGoal.goal.Assignment_Mode_Detail__c.split('|');
		for(var i = 0; i < accIds.length; i++){
			preselectedAccountIds.put(accIds[i], accIds[i]);
		}
	}
	
	for(var i = 0; i < accArray.length; i++){
		var acc = accArray[i];
		
		if(acc.RecordType.Name == childGoal.parentGoal.goal.Goal_Type__c){
			var action = new Object();
			action.account = acc;
			action.childGoal = childGoal;
			if(preselectedAccountIds.get(acc.Id) != null){
				action.selected = true;
				childGoal.actionsSelected++;
			} else {
				action.selected = false;
			}
			
			childGoal.actions.push(action);
			childGoal.actionsByAccId.put(acc.Id, action);
			childGoal.actionsAvailable++;
		}
	}
}

function colorAccounts(){
	j$('.accountLines').each(
		function(){
			j$(this).find('.accountLine[shown="true"]:even').css('background-color', '#F0F0F0');
			j$(this).find('.accountLine[shown="true"]:odd').css('background-color', '#FFFFFF');
		}
	);
}

function actionSelected(childGoalKey, accountId){
	var childGoal = childGoalsByKey.get(childGoalKey);
	var action = childGoal.actionsByAccId.get(accountId);
	action.selected = !action.selected;
	if(action.selected){
		childGoal.actionsSelected++;
	} else {
		childGoal.actionsSelected--;
	}
	updateGoalSumText(childGoalKey);
	updateTotals(childGoal.parentGoal.goal.Id, false);
}

function assignAll(childGoalKey, selected, doUpdateTotals){
	var childGoal = childGoalsByKey.get(childGoalKey);
	
	childGoal.actionsSelected = 0;
	for(var i = 0; i < childGoal.actions.length; i++){
		var action = childGoal.actions[i];
		if(action.account.visible == false || selected == false){
			action.selected = false;
		} else {
			action.selected = true;
			childGoal.actionsSelected++;
		}
		var checkbox = j$('.actionSelectCheckbox[goalKey="' + childGoal.key + '"][accId="' + action.account.Id + '"]');
		j$(checkbox).attr('checked', action.selected);
	}
	
	updateGoalSumText(childGoalKey);

	if(doUpdateTotals){
		updateTotals(childGoal.parentGoal.goal.Id, false);
	}
}

function updateTotals(parentGoalId, isFirstTime){
	var parentGoal = parentGoalsById.get(parentGoalId);
	var totalGoalCells = j$(totalBlocksByCurrentKey.get(currentKey))[0].find('.totalGoalCell[goalId="' + parentGoalId + '"]');

	var childGoals = parentGoal.childGoalsByRepId.values();
	if(isFirstTime){
		parentGoal.accsAvailable = 0;
		for(var i = 0; i < childGoals.length; i++){
			var childGoal = childGoals[i];
			parentGoal.accsAvailable += childGoal.actions.length;
		}
	}
	
	parentGoal.accsYouHaveChosen = 0;
	parentGoal.accsRepsWillChoose = 0;
	parentGoal.casesRepsWillChoose = 0;
	parentGoal.isSubmittable = true;
	
	for(var i = 0; i < childGoals.length; i++){
		var childGoal = childGoals[i];
		if(childGoal.hasAssignError == false){
			if(childGoal.assignMode == 'manual'){
				parentGoal.accsYouHaveChosen += childGoal.actionsSelected;
				var overageValue = parseInt(childGoal.overageDetail);
				if (isNaN(overageValue)){
					overageValue = 0;
				}
				parentGoal.accsRepsWillChoose += overageValue;
			} else {
				parentGoal.accsRepsWillChoose += childGoal.actionsSelected;
			}
			if(parentGoal.shouldShowCases){
				parentGoal.casesRepsWillChoose += childGoal.casesDetail;
			}
		} else {
			parentGoal.isSubmittable = false;
		}
	}
	
	parentGoal.accsStillNeeded = parentGoal.accsNeeded - parentGoal.accsYouHaveChosen - parentGoal.accsRepsWillChoose;
	if(parentGoal.accsStillNeeded < 0){
		parentGoal.accsStillNeeded = 0;
	}
	if(parentGoal.shouldShowCases){
		parentGoal.casesStillNeeded = parentGoal.casesNeeded - parentGoal.casesRepsWillChoose;
		if(parentGoal.casesStillNeeded < 0){
			parentGoal.casesStillNeeded = 0;
		}
	}
	
	if(repMode == false && (parentGoal.accsStillNeeded > 0 || parentGoal.casesStillNeeded > 0)){
		parentGoal.isSubmittable = false;
	}
	
	if(repMode == true && parentGoal.accsStillNeeded > 0 && parentGoal.accsYouHaveChosen + parentGoal.accsRepsWillChoose < parentGoal.accsAvailable){
		parentGoal.isSubmittable = false;
	}

	j$(totalGoalCells).each(function(){
		var type = j$(this).attr("type");
		if(isFirstTime){
			if(type == 'avail'){
				j$(this).empty();
				j$(this).append(parentGoal.accsAvailable);
			} else if(type == 'req'){
				j$(this).empty();
				if(parentGoal.shouldShowCases){
					j$(this).append(parentGoal.accsNeeded + '/' + parentGoal.casesNeeded);
				} else {
					j$(this).append(parentGoal.accsNeeded);
				}
			}
		}
		if(type == 'you'){
			j$(this).empty();
			j$(this).append(parentGoal.accsYouHaveChosen);
		} else if(type == 'reps'){
			j$(this).empty();
			if(parentGoal.shouldShowCases){
				j$(this).append(parentGoal.accsRepsWillChoose + '/' + parentGoal.casesRepsWillChoose);
			} else {
				j$(this).append(parentGoal.accsRepsWillChoose);
			}
		} else if(type == 'needed'){
			j$(this).empty();
			var neededString = '<span';
			if(parentGoal.accsStillNeeded > 0){
				neededString += ' style="color: red">'
			} else {
				neededString += ' style="color: green">'
			}
			neededString += parentGoal.accsStillNeeded;
			neededString += '</span>';
			if(parentGoal.shouldShowCases){
				neededString += ' / <span';
				if(parentGoal.casesStillNeeded > 0){
					neededString += ' style="color: red">'
				} else {
					neededString += ' style="color: green">'
				}
				neededString += parentGoal.casesStillNeeded;
				neededString += '</span>';
			}
			j$(this).append(neededString);
		}
	});
	
	var submitButton = j$('.newSubmitButton[goalId="' + parentGoal.goal.Id + '"]');
	if(parentGoal.isSubmittable){
		j$(submitButton).removeClass('ui-state-disabled');
	} else {
		j$(submitButton).addClass('ui-state-disabled');
	}
}

function assignTypeChanged(goalKey, value, fromCopy, doUpdateTotals){
	var childGoal = childGoalsByKey.get(goalKey);
	childGoal.assignMode = value;
	
	var checkboxes = j$('.actionSelectCheckbox[goalKey="' + childGoal.key + '"]');
	var countInputs = j$('.assignCountInput[goalKey="' + childGoal.key + '"]');
	var percentInputs = j$('.assignPercentInput[goalKey="' + childGoal.key + '"]');
	var overageInputs = j$('.assignOverageInput[goalKey="' + childGoal.key + '"]');
	var selectAllButtons = j$('.assignSelectAll[goalKey="' + childGoal.key + '"]');
	
	if(repMode){
		if(value == 'manual' || childGoal.parentGoal.isRepAcceptable == false){
			j$(checkboxes).each(function() {
				j$(this).attr('disabled', true);
			});
			j$(selectAllButtons).css("display", "none");
		} else {
			j$(checkboxes).each(function() {
				j$(this).attr('disabled', false);
				j$(this).attr('checked', false);
			});
			j$(selectAllButtons).css("display", "block");
		}
	} else {
		if(fromCopy == false){
			childGoal.assignDetail = 0;
			childGoal.actionsSelected = 0;
			j$('.assignCountInput[goalKey="' + childGoal.key + '"] > .assignInput').val(0);
			j$('.assignPercentInput[goalKey="' + childGoal.key + '"] > .assignInput').val(0);
		}
		
		if(value == 'manual'){
			j$(checkboxes).each(function() {
				j$(this).attr('disabled', false);
			});
			j$(countInputs).css("display", "none");
			j$(percentInputs).css("display", "none");
			j$(overageInputs).css("display", "block");
			j$(selectAllButtons).css("display", "block");
		} else if(value == 'count'){
			j$(checkboxes).each(function() {
				j$(this).attr('disabled', true);
				j$(this).attr('checked', false);
			});
			j$(countInputs).css("display", "block");
			j$(percentInputs).css("display", "none");
			j$(overageInputs).css("display", "none");
			j$(selectAllButtons).css("display", "none");
		} else if(value == 'percent'){
			j$(checkboxes).each(function() {
				j$(this).attr('disabled', true);
				j$(this).attr('checked', false);
			});
			j$(countInputs).css("display", "none");
			j$(percentInputs).css("display", "block");
			j$(overageInputs).css("display", "none");
			j$(selectAllButtons).css("display", "none");
		}
	}
		
	updateGoalSumText(goalKey);
	
	if(doUpdateTotals){
		updateTotals(childGoal.parentGoal.goal.Id, false);
	}
}

function copyVert(goalKey){
	var childGoal = childGoalsByKey.get(goalKey);
	var parentGoal = childGoal.parentGoal;
	var allChildren = parentGoal.childGoalsByRepId.values();
		
	for(var i = 0; i < allChildren.length; i++){
		var child = allChildren[i];
		if(child != childGoal){
			copyGoalModeAndDetail(childGoal, child);
		}
	}
	updateTotals(parentGoal.goal.Id, false);
}

function copyHorz(goalKey){
	var childGoal = childGoalsByKey.get(goalKey);
	var underling = childGoal.underling;
	var allChildren = childGoalsByKey.values();
	
	for(var i = 0; i < allChildren.length; i++){
		var child = allChildren[i];
		if(child != childGoal &&
			child.underling == childGoal.underling &&
			child.parentGoal.goal.Goal_Type__c == childGoal.parentGoal.goal.Goal_Type__c &&
			child.parentGoal.goal.Priority__c == childGoal.parentGoal.goal.Priority__c &&
			child.parentGoal.goal.RecordTypeId == childGoal.parentGoal.goal.RecordTypeId){
				copyGoalModeAndDetail(childGoal, child);
				updateTotals(child.parentGoal.goal.Id, false);
		}
	}
}

function copyGoalModeAndDetail(source, target){
	target.assignMode = source.assignMode;
	
	j$('.assignTypeSelect[goalKey="' + target.key + '"]').val(target.assignMode);
	
	if(target.assignMode == 'manual'){
		target.overageDetail = source.overageDetail;
		valueChanged(target.key, target.overageDetail, 'overage', false);
		j$('.assignOverageInput[goalKey="' + target.key + '"] > .assignInput').val(target.overageDetail);
		if(source.actionsSelected == source.actionsAvailable){
			assignAll(target.key, true, false);
		} else if(source.actionsSelected == 0){
			assignAll(target.key, false, false);
		}
	} else {
		target.assignDetail = source.assignDetail;
		target.casesDetail = source.casesDetail;
		valueChanged(target.key, target.assignDetail, 'accounts', false);
		valueChanged(target.key, target.casesDetail, 'cases', false);
		if(target.assignMode == 'count'){
			j$('.assignCountInput[goalKey="' + target.key + '"] > .assignInput').val(target.assignDetail);
		} else if(target.assignMode == 'percent'){
			j$('.assignPercentInput[goalKey="' + target.key + '"] > .assignInput').val(target.assignDetail);
		}
		if(target.shouldShowCases){
			j$('.assignCasesInput[goalKey="' + target.key + '"] > .assignInput').val(target.casesDetail);
		}
	}
	
	assignTypeChanged(target.key, target.assignMode, true, false);
}

function valueChanged(goalKey, value, type, doUpdateTotals){
	var childGoal = childGoalsByKey.get(goalKey);
	value = parseInt(value);
	if(value == null || isNaN(value)){
		value = 0;
	}
	if(type == 'cases'){
		childGoal.casesDetail = value;
	} else if(type == 'overage'){
		childGoal.overageDetail = value;
	} else {
		childGoal.assignDetail = value;
		if(childGoal.assignMode == 'count'){
			childGoal.actionsSelected = value;
		} else if(childGoal.assignMode == 'percent'){
			childGoal.actionsSelected = Math.floor(childGoal.parentGoal.accsNeeded * value / 100);
		}
	}
	
	updateGoalSumText(goalKey);
	if(doUpdateTotals){
		updateTotals(childGoal.parentGoal.goal.Id, false);
	}
}

function updateGoalSumText(goalKey){
	var childGoal = childGoalsByKey.get(goalKey);
	var parentGoal = childGoal.parentGoal;
	var sumString = '';
	
	childGoal.hasAssignError = false;
	
	if(childGoal.assignMode == 'manual'){
		var overageValue = parseInt(childGoal.overageDetail);
		if (isNaN(overageValue)){
			overageValue = 0;
		}
		var totalSelected = childGoal.actionsSelected + overageValue;
		var percent = Math.floor(totalSelected / parentGoal.accsNeeded * 100);
		if(repMode){
			sumString = 'Manager has selected ' + totalSelected + '/' + childGoal.actionsAvailable + ' accounts';
		} else {
			sumString = totalSelected + '/' + childGoal.actionsAvailable + ' selected (' + percent + '% of goal)';
		}
	} else if(repMode){
		var percent = Math.floor(childGoal.actionsSelected / parentGoal.accsNeeded * 100);
		sumString = 'You have chosen ' + childGoal.actionsSelected + ' accounts (' + percent + '% of goal)';
	} else if(childGoal.assignMode == 'count'){
		var tempNum = parseInt(childGoal.assignDetail);
		if(isNaN(tempNum) || tempNum < 0){
			tempNum = 0;
			childGoal.assignDetail = 0;
		}
		//if(tempNum > childGoal.actionsAvailable){
		//	childGoal.hasAssignError = true;
		//	sumString = '<span style="color: red">Not enough accounts available</span>';
		//} else {
			childGoal.actionsSelected = tempNum;
			var percent = Math.floor(tempNum / parentGoal.accsNeeded * 100);
			sumString = 'Rep will choose ' + childGoal.assignDetail + ' accounts (' + percent + '% of goal)';
		//}
	} else if(childGoal.assignMode == 'percent'){
		var tempNum = parseInt(childGoal.assignDetail);
		if(isNaN(tempNum) || tempNum < 0){
			tempNum = 0;
			childGoal.assignDetail = 0;
		}
		tempNum2 = Math.floor((tempNum / 100) * parentGoal.accsNeeded);
		//if(tempNum2 > childGoal.actionsAvailable){
		//	childGoal.hasAssignError = true;
		//	sumString = '<span style="color: red">Not enough accounts available</span>';
		//} else {
			childGoal.actionsSelected = tempNum2;
			var percent = Math.floor(tempNum / parentGoal.accsNeeded * 100);
			sumString = 'Rep will choose ' + tempNum + '% of goal (' + tempNum2 + ' accounts)';
		//}
	}
	if(repMode == false && childGoal.shouldShowCases){
		if(childGoal.hasAssignError == false){
			var tempNum = parseInt(childGoal.casesDetail);
			if(isNaN(tempNum) || tempNum < 0){
				tempNum = 0;
				childGoal.casesDetail = 0;
			}
			sumString += ' and ' + childGoal.casesDetail + ' cases';
		}
	}
	
	var sumText = j$('.sumLineCell[goalKey="' + goalKey + '"] > .sumText');
	j$(sumText).empty();
	j$(sumText).append(sumString);
}

function viewGoal(goalId, isEdit){
	j$("#loadProgressBar").css('display', 'block').progressbar("option", "value", 50);
	updateLoadModal("Loading goal details...");
	j$("#loadModal").dialog({
		modal: true,
		closeOnEscape: false,
		resizable: false,
		draggable: false,
		buttons: null,
		open: function(event, ui) { 
				//hide close button
				j$(".ui-dialog-titlebar-close", j$(this).parent()).hide();
			}
	});
	if(isEdit){
		assignDummyEditGoal(goalId);
	} else {
		assignDummyViewGoal(goalId);
	}
}

var alreadySaving = false;
function submitGoal(parentGoalId){
	var parentGoal = parentGoalsById.get(parentGoalId);
	if(parentGoal.isSubmittable){
		j$('#loadProgressBar').progressbar('option', 'value', 50);
		updateLoadModal('Saving goal details...');
		j$('#loadModal').dialog("option", "buttons", []);
		j$('#loadModal').dialog({
			modal: true,
			closeOnEscape: false,
			resizeable: false,
			draggable: false,
			open: function(event, ui) { 
					//hide close button
					j$('.ui-dialog-titlebar-close', j$(this).parent()).hide();
				}
		});
	
		if(alreadySaving == false){
			alreadySaving = true;
			
			if(repMode){
				var jsGoal = parentGoal.childGoalsByRepId.values()[0];
				
				var str = '';
				for(var i = 0; i < jsGoal.actions.length; i++){
					var action = jsGoal.actions[i];
					if(action.selected){
						str += action.account.Id + ',';
					}
				}
				if(str != ''){
					str = str.substring(0, str.length - 1);
				}
				
				contSaveFunc('saveActions' , [parentGoalId, str], function(result){
					parentGoal.visible = false;
					
					updateTabAndButtonNumbers();
					
					if(isDoneGoaling){
						updateLoadModal('All goals have been accepted. You will now return to the My Goals page.');
						j$('#loadProgressBar').css('display', 'none');
						j$('#loadModal').dialog("option", "buttons", [
							{text: "Ok", click: function() {
								j$(this).dialog("close");
								gotoMyGoals();
							}}
						]);
					} else {
						j$('.totalGoalHeader[goalId="' + parentGoalId + '"]').remove();
						j$('.totalGoalCell[goalId="' + parentGoalId + '"]').remove();
						j$('.goalHeader[goalKey^="' + parentGoalId + '"]').remove();
						j$('.accountTopCell[goalKey^="' + parentGoalId + '"]').remove();
						j$('.actionCell[goalKey^="' + parentGoalId + '"]').remove();
						j$('.sumLineCell[goalKey^="' + parentGoalId + '"]').remove();
					
						alreadySaving = false;
						updateLoadModal('This goal has been accepted. It will now be removed from the view.');
						j$('#loadProgressBar').css('display', 'none');
						j$('#loadModal').dialog("option", "buttons", [
							{text: "Ok", click: function() {
								j$(this).dialog("close");
							}}
						]);
					}
				});
			} else {
				var sfGoals = [];
				var jsGoals = parentGoal.childGoalsByRepId.values();
				for(var i = 0; i < jsGoals.length; i++){
					var jsGoal = jsGoals[i];
					if(jsGoal.hasAssignError == false && jsGoal.actionsSelected > 0){
						var sfGoal = new Object();
						
						sfGoal.Parent_Goal__c = jsGoal.parentGoal.goal.Id;
						var overageValue = parseInt(jsGoal.overageDetail);
						if (isNaN(overageValue)){
							overageValue = 0;
						}
						sfGoal.Minimum_of_Accounts__c = jsGoal.actionsSelected + overageValue;
						if(jsGoal.shouldShowCases){
							sfGoal.Cases_Displayed__c = jsGoal.casesDetail;
						}
						sfGoal.Assignment_Mode__c = jsGoal.assignMode;
						
						if(jsGoal.assignMode == 'manual'){
							var str = '';
							for(var j = 0; j < jsGoal.actions.length; j++){
								var action = jsGoal.actions[j];
								if(action.selected){
									str += action.account.Id + '|';
								}
							}
							if(str != ''){
								str = str.substring(0, str.length - 1);
							}
							sfGoal.Assignment_Mode_Detail__c = str;
						} else if(jsGoal.assignMode == 'count'){
						} else if(jsGoal.assignMode == 'percent'){
						}
						
						sfGoal.Goal_For__c = jsGoal.underling.id;
						sfGoal.OwnerId = jsGoal.underling.id;
						
						sfGoals.push(sfGoal);
					}
				}
				
				contSaveFunc("saveGoals" , [sfGoals], function(result){
					parentGoal.visible = false;
					
					updateTabAndButtonNumbers();
					
					if(isDoneGoaling){
						updateLoadModal('All goals have been submitted. You will now return to the My Goals page.');
						j$('#loadProgressBar').css('display', 'none');
						j$('#loadModal').dialog("option", "buttons", [
							{text: "Ok", click: function() {
								j$(this).dialog("close");
								gotoMyGoals();
							}}
						]);
					} else {
						j$('.totalGoalHeader[goalId="' + parentGoalId + '"]').remove();
						j$('.totalGoalCell[goalId="' + parentGoalId + '"]').remove();
						j$('.goalHeader[goalKey^="' + parentGoalId + '"]').remove();
						j$('.accountTopCell[goalKey^="' + parentGoalId + '"]').remove();
						j$('.actionCell[goalKey^="' + parentGoalId + '"]').remove();
						j$('.sumLineCell[goalKey^="' + parentGoalId + '"]').remove();
					
						alreadySaving = false;
						updateLoadModal('This goal has been submitted. It will now be removed from the view.');
						j$('#loadProgressBar').css('display', 'none');
						j$('#loadModal').dialog("option", "buttons", [
							{text: "Ok", click: function() {
								j$(this).dialog("close");
							}}
						]);
					}
				});
			}
		}
	}
}

function gotoMyGoals(){
	window.location.assign('/apex/MyGoalsPage');
}




















//end of file