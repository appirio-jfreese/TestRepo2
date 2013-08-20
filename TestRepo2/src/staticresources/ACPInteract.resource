function updateSubDiv(tabIndex, premiseIndex){
	if(tabIndex == null){
		tabIndex = j$("#channelTabDiv .ui-tabs-selected").index();
	}
	if(premiseIndex == null){
		var radioButtons = j$("input:radio[name='radio-tab-" + tabIndex + "']");
		var premiseIndex = radioButtons.index(radioButtons.filter(':checked'));
	}
	
	updateIEWidth(tabIndex, premiseIndex);
	
	for(var i = 0; i < premises.length(); i++){
		var repDiv = j$("#tab" + tabIndex + "-premise" + i);
		if(i == premiseIndex){
			repDiv.css("display", "block");
		} else {
			repDiv.css("display", "none");
		}
	}
}

function updateIEWidth(tabIndex, premiseIndex){
	if(isIE8()){
		var newWidth = 288 + (216 * ie8Widths.get(tabIndex + '|' + premiseIndex));
		if(newWidth < 800){
			newWidth = 800;
		}
		j$('#channelTabDiv').css('width', newWidth);
	}
}

var goalCount;
var repBlocksByKey;

function updateRepCounts(doAccounts, isPossiblyFilterOn){
	repBlocksByKey = new Hash();
	j$('.repBlock').each(function(){
		var key = j$(this).attr('key');
		repBlocksByKey.put(key, this);
	});
	for(var j = 0; j < channels.length(); j++){
		for(var k = 0; k < premises.length(); k++){
			var tab = j$("#tab" + j + "-premise" + k);
			var repValues = reps.values();
			
			goalCount = 0;
			var i = 0;
			var ro = new RepeatingOperation(function() {
				var rep = repValues[i];
				var repBlockKey = rep.repId + '|' + j + '|' + k;
				var repBlock = repBlocksByKey.get(repBlockKey);
				updateCountsForRep(rep, repBlock, j, k, doAccounts, isPossiblyFilterOn);
				if(goalCount == 0){
					j$(tab).children(".noGoalsBlock").show();
					j$(tab).children(":not(.noGoalsBlock)").hide();
				} else { 
					j$(tab).children().show();
					j$(tab).children(".noGoalsBlock").hide();
					j$(repBlock).find('.goalGrayBlock').empty();
					j$(repBlock).find('.goalGrayBlock').append('Goals (' + goalCount + ')');
				}
				i++;
				if(i < repValues.length){
					ro.step();
				}
			}, 10);
			ro.step();
		}
	}
}

function updateCountsForRep(rep, repBlock, j, k, doAccounts, isPossiblyFilterOn){
	var childGoalValues = rep.childGoals.values();
	for(var l = 0; l < childGoalValues.length; l++){
		var parentGoal;
		if(repMode){
			parentGoal = parentGoals.get(childGoalValues[l].key);
		} else {
			parentGoal = parentGoals.get(childGoalValues[l].parentId);
		}
		var channelIndex = channels.get(parentGoal.channel);
		var premiseIndex = premises.get(parentGoal.premise);
		if(channelIndex == j && premiseIndex == k){
			goalCount++;
		}
	}
	
	if(doAccounts){
		var accsShown = 0;
		var accsAvail = 0;
		var vals = rep.accountsById.values()
		for(var l = 0; l < vals.length; l++){
			var acc = vals[l];
			var accPremise = acc.RecordType.Name;
			if(premises.get(accPremise) == k){
				accsAvail++;
				if(isPossiblyFilterOn){
					var accLineShown = j$(repBlock).find('.accountLine[accId="' + acc.Id + '"]').attr("shown");
					if(accLineShown == "true"){
						accsShown++;
					}
				} else {
					accsShown++;
				}
			}
		}
		j$(repBlock).find('.accountTopFirst').empty();
		j$(repBlock).find('.accountTopFirst').append('Accounts (' + accsShown + ' of ' + accsAvail + ')');
	}
}

function assignTypeChanged(goalKey, value, updateSums, updateInputs){
	var goal;
	if(repMode){
		goal = parentGoals.get(goalKey);
	} else {
		goal = childGoals.get(goalKey);
	}
	goal.mode = value;
	if(repMode == false){
		goal.numCasesSel = 0;
	}
	
	j$('.assignTypeSelect[goalKey="' + goalKey + '"]').val(value);
	
	var assignDiv = j$(".accountTopCell[goalKey='" + goalKey + "']");
	var actionChecks = j$('.actionSelectCheckbox[goalKey="' + goalKey + '"]');
	//var caseInputs = j$('.casesInput[goalKey="' + goalKey + '"]');
	
	j$(assignDiv).find(".assignInput").val("");
	j$(assignDiv).find(".assignInput2").val("");
	
	if(goal.mode == "manual"){
		j$(assignDiv).find(".assignSelectAll").css("display", "block");
		j$(assignDiv).find(".assignCountInput").css("display", "none");
		j$(assignDiv).find(".assignPercentInput").css("display", "none");
		
		if(repMode){
			j$(actionChecks).attr('disabled', true);
			//j$(caseInputs).attr('readonly', true);
		} else {
			j$(actionChecks).attr('disabled', false);
		}
		
	} else if(goal.mode == "count"){
		j$(assignDiv).find(".assignCountInput").css("display", "block");
		j$(assignDiv).find(".assignPercentInput").css("display", "none");
		
		if(repMode){
			j$(actionChecks).attr('disabled', false);
		} else {
			j$(assignDiv).find(".assignSelectAll").css("display", "none");
			j$(actionChecks).attr('checked', false);
			j$(actionChecks).attr('disabled', true);
			//j$(caseInputs).attr('readonly', true);
			//j$(caseInputs).attr('value', null);
			goal.numAccsSel = 0;
		}
		
		if(updateInputs){
			j$(assignDiv).find(".assignCountInput > .assignInput").val(goal.detail);
			j$(assignDiv).find(".assignCountInput > .assignInput2").val(goal.numCasesSel);
		}
	} else if(goal.mode == "percent"){
		j$(assignDiv).find(".assignCountInput").css("display", "none");
		j$(assignDiv).find(".assignPercentInput").css("display", "block");
		
		if(repMode){
			j$(actionChecks).attr('disabled', false);
		} else {
			j$(assignDiv).find(".assignSelectAll").css("display", "none");
			j$(actionChecks).attr('checked', false);
			j$(actionChecks).attr('disabled', true);
			//j$(caseInputs).attr('readonly', true);
			//j$(caseInputs).attr('value', null);
			goal.numAccsSel = 0;
		}
		
		if(updateInputs){
			j$(assignDiv).find(".assignPercentInput > .assignInput").val(goal.detail);
			j$(assignDiv).find(".assignPercentInput > .assignInput2").val(goal.numCasesSel);
		}
	}
	
	if(goal.isAssigned){
		j$('.assignTypeSelect[goalKey="' + goalKey + '"]').attr('disabled', true);
		j$(assignDiv).find(".assignSelectAll").css("display", "none");
		j$(assignDiv).find(".goalEditButton").css("display", "none");
		j$(assignDiv).find(".assignCountInput > .assignInput").attr('disabled', true);
		j$(assignDiv).find(".assignPercentInput > .assignInput").attr('disabled', true);
		j$(assignDiv).find(".assignCountInput > .assignInput2").attr('disabled', true);
		j$(assignDiv).find(".assignPercentInput > .assignInput2").attr('disabled', true);
		j$(actionChecks).attr('disabled', true);
		//j$(caseInputs).attr('readonly', true);
	}
	
	if(updateSums){
		updateGoalSumText(goalKey, true);
	}
}

function assignAll(goalKey, value){
	var goal = childGoals.get(goalKey);
	
	//change data
	var acts = actions.values();
	var accountIds = [];
	var tabIndex = j$("#channelTabDiv .ui-tabs-selected").index();
	
	var accountLinesByAccId = new Hash();
	j$('.accountLine').each( function() {
		if(j$(this).attr('channel') == tabIndex){
			var accId = j$(this).attr('accId');
			if(accId != null){
				accId = accId.substring(0,15);
			}
			accountLinesByAccId.put(accId, j$(this));
		}
	});
	
	var actionChecksByAccId = new Hash();
	j$('.actionSelectCheckbox[goalKey="' + goalKey + '"]').each( function() {
		var accId = j$(this).attr('accId');
		if(accId != null){
			accId = accId.substring(0,15);
		}
		actionChecksByAccId.put(accId, j$(this));
	});
	
	for(var i = 0; i < acts.length; i++){
		var accLine = accountLinesByAccId.get(acts[i].accountId);
		var accLineShown = j$(accLine).attr("shown");
		if(acts[i].goalKey == goalKey && accLineShown == 'true'){
			var valChanged = (acts[i].selected != value);
			if(valChanged){
				var actionCheck = actionChecksByAccId.get(acts[i].accountId);
				j$(actionCheck).attr('checked', value);
				actionSelected(acts[i].key, value);
			}
		}
	}
	
	//goal.numAccsSel = goal.numAccsAvail;
	updateGoalSumText(goalKey, true);
}

function updateTotals(goalId){
	var goal = parentGoals.get(goalId);
	var accNeeded = 0;
	var caseNeeded = 0;
	var accsAndCasesMatch = true;
	var tooManyAccountsSelected = false;
	j$('.totalGoalCell[goalId="' + goalId + '"]').each(function(index, element){
		var type = j$(element).attr("type");
		if(type != 'button'){
			var accNum = 0;
			var caseNum = 0;
			if(type == 'req'){
				accNum = goal.numAccsNeeded;
				caseNum = goal.numCasesNeeded;
				accNeeded += accNum;
				caseNeeded += caseNum;
			} else if(type == 'avail' || type == 'you' || type == 'reps'){
				var children = goal.children.values();
				for(var i = 0; i < children.length; i++){
					var childGoal = children[i];
					if(type == 'avail'){
						accNum += childGoal.numAccsAvail;
						caseNum = '--';
					} else if(type == 'you' && childGoal.mode == 'manual'){
						accNum += childGoal.numAccsSel;
						accNeeded -= childGoal.numAccsSel;
						caseNum += childGoal.numCasesSel;
						caseNeeded -= childGoal.numCasesSel;
					} else if(type == 'reps' && childGoal.mode == 'count'){
						var tempNum = parseInt(childGoal.detail);
						if(isNaN(tempNum)){
							tempNum = 0;
						}
						accNum += tempNum;
						accNeeded -= tempNum;
						
						var tempNum2 = parseInt(childGoal.numCasesSel);
						if(isNaN(tempNum2)){
							tempNum2 = 0;
						}
						caseNum += tempNum2;
						caseNeeded -= tempNum2;
						
						if((tempNum > 0 && tempNum2 == 0) || (tempNum == 0 && tempNum2 > 0)){
							accsAndCasesMatch = false;
						}
						if(tempNum > childGoal.numAccsAvail){
							tooManyAccountsSelected = true;
						}
					} else if(type == 'reps' && childGoal.mode == 'percent'){
						var tempNum = parseInt(childGoal.detail);
						if(isNaN(tempNum)){
							tempNum = 0;
						}
						tempNum = Math.floor((tempNum / 100) * goal.numAccsNeeded);
						accNum += tempNum;
						accNeeded -= tempNum;
						
						var tempNum2 = parseInt(childGoal.numCasesSel);
						if(isNaN(tempNum2)){
							tempNum2 = 0;
						}
						tempNum2 = Math.floor((tempNum2 / 100) * goal.numCasesNeeded);
						caseNum += tempNum2;
						caseNeeded -= tempNum2;
						
						if((tempNum > 0 && tempNum2 == 0) || (tempNum == 0 && tempNum2 > 0)){
							accsAndCasesMatch = false;
						}
						if(accNum > childGoal.numAccsAvail){
							tooManyAccountsSelected = true;
						}
					}
				}
			}
			j$(element).empty();
			if(goal.shouldShowCases == false){
				j$(element).append(accNum);
			} else {
				if(isNaN(accNum)){
					accNum = 0;
				}
				if(isNaN(caseNum)){
					caseNum = 0;
				}
				j$(element).append(Math.floor(accNum) + ' / ' + Math.floor(caseNum));
			}
		}
	});
	
	if(accNeeded < 0){
		accNeeded = 0;
	}
	if(caseNeeded < 0){
		caseNeeded = 0;
	}
	
	/*var children = goal.children.values();
	var allAreManual = true;
	for(var i = 0; i < children.length; i++){
		var child = children[i];
		if(child.mode != 'manual'){
			allAreManual = false;
			i = children.length;
		}
	}*/
	
	if(goal.shouldShowCases == false){
		goal.isComplete = accNeeded == 0 && tooManyAccountsSelected == false;
	} else {
		goal.isComplete = accNeeded == 0 && tooManyAccountsSelected == false && (goal.numCasesNeeded == 0 || (caseNeeded == 0 && accsAndCasesMatch));
	}
	
	var spanString = '<span style="color: ';
	if(goal.isComplete){
		spanString += 'green';
		j$('.newSubmitButton[goalId="' + goal.goalId + '"]').removeClass("ui-state-disabled");
	} else {
		spanString += 'red';
		j$('.newSubmitButton[goalId="' + goal.goalId + '"]').addClass("ui-state-disabled");
	}
	if(goal.shouldShowCases == false){
		spanString += '">' + accNeeded + '</span>';
	} else {
		spanString += '">' + accNeeded + ' / ' + caseNeeded;
		if(accsAndCasesMatch == false){
			spanString += '<br/>All reps with accounts assigned must have cases assigned, and vice versa.';
		}
		spanString += '</span>';
	}
	
	var totalCell = j$('.finalTotalLine > .totalGoalCell[goalId="' + goalId + '"]');
	j$(totalCell).empty();
	j$(totalCell).append(spanString);
}

function copyVert(goalKey){
	var goal = childGoals.get(goalKey);
	var allGoals = childGoals.values();
	
	for(var i = 0; i < allGoals.length; i++){
		if(allGoals[i] != goal
				&& allGoals[i].parentId == goal.parentId
				&& allGoals[i].premise == goal.premise
				&& allGoals[i].channel == goal.channel){
			//match found
			copyGoalModeAndDetail(goal, allGoals[i]);
		}
	}
}

function copyHorz(goalKey){
	var goal = childGoals.get(goalKey);
	var allGoals = childGoals.values();
	
	for(var i = 0; i < allGoals.length; i++){
		if(allGoals[i] != goal
				&& allGoals[i].repId == goal.repId
				&& allGoals[i].premise == goal.premise
				&& allGoals[i].channel == goal.channel){
			//match found
			copyGoalModeAndDetail(goal, allGoals[i]);
		}
	}
}

function copyGoalModeAndDetail(source, target){
	if(target.isAssigned == false){
		target.mode = source.mode;
		
		assignTypeChanged(target.key, target.mode, false, false);
		
		if(target.mode == 'manual'){
			if(source.numAccsSel == source.numAccsAvail){
				assignAll(target.key, true);
			}
		} else {
			target.detail = source.detail;
			target.numCasesSel = source.numCasesSel;
			valueChanged(target.key, target.detail, 0);
			valueChanged(target.key, target.numCasesSel, 1);
			if(target.mode == 'count'){
				j$('.accountTopCell[goalKey="' + target.key + '"] > .assignCountInput > .assignInput').val(target.detail);
				j$('.accountTopCell[goalKey="' + target.key + '"] > .assignCountInput > .assignInput2').val(target.numCasesSel);
			} else if(target.mode == 'percent'){
				j$('.accountTopCell[goalKey="' + target.key + '"] > .assignPercentInput > .assignInput').val(target.detail);
				j$('.accountTopCell[goalKey="' + target.key + '"] > .assignPercentInput > .assignInput2').val(target.numCasesSel);
			}
		}
	}
}

function actionSelected(key, selected){
	var action = actions.get(key);
	action.selected = selected;
	
	var goal;
	if(repMode){
		goal = parentGoals.get(action.goalKey);
	} else {
		goal = childGoals.get(action.goalKey);
	}

	//var caseInput = j$('.casesInput[key="' + key + '"]');
	if(selected == true){
		goal.numAccsSel++;
		goal.selectedAccountIds.put(action.accountId, action.accountId);
		//goal.casesByAccountId.put(action.accountId, 0);
		//j$(caseInput).attr('readonly', false);
		//j$(caseInput).attr('value', 0);
		//action.caseCount = 0;
	} else {
		goal.numAccsSel--;
		//goal.numCasesSel -= j$(caseInput).attr('value');
		goal.selectedAccountIds.remove(action.accountId);
		//goal.casesByAccountId.remove(action.accountId);
		//j$(caseInput).attr('readonly', true);
		//j$(caseInput).attr('value', null);
		//action.caseCount = 0;
	}
	updateGoalSumText(action.goalKey, true);
}

function valueChanged(goalKey, value, mode){
	var goal = childGoals.get(goalKey);
	value = parseInt(value);
	if(mode == 0){
		goal.detail = value;
		goal.numAccsSel = value;
	} else {
		goal.numCasesSel = value;
	}
	updateGoalSumText(goalKey, true);
}

function updateGoalSumText(goalKey, doTotalUpdate){
	var goal;
	var topString;
	var sumString;
	if(repMode){
		goal = parentGoals.get(goalKey);
		goal.detail = parseInt(goal.detail);
		if(goal.mode == "manual"){
			if(goal.shouldShowCases == false){
				topString = "Manager has selected " + goal.numAccsSel + ' accounts';
			} else {
				topString = "Manager has selected " + goal.numAccsSel + ' accounts and ' + goal.numCasesSel + ' cases';
			}
			sumString = '<span style="color: green">No action required</span>';
			goal.isComplete = true;
		} else if(goal.mode == "count"){
			topString = "You must select " + goal.detail + " accounts";
			goal.isComplete = false;
			if(goal.numAccsSel >= goal.detail){
				goal.isComplete = true;
			}
			
			if(goal.isComplete){
				sumString = '<span style="color: green">' + goal.numAccsSel + ' accounts selected</span>';
				j$('.acceptButton[goalId="' + goal.goalId + '"]').removeClass("ui-state-disabled");
			} else {
				sumString = '<span style="color: red">Select ' + (goal.detail - goal.numAccsSel) + ' more accounts</span>';
				j$('.acceptButton[goalId="' + goal.goalId + '"]').addClass("ui-state-disabled");
			}
		} else if(goal.mode == "percent"){
			topString = "You must select " + goal.detail + " accounts";
			goal.isComplete = false;
			if(goal.numAccsSel >= goal.detail){
				goal.isComplete = true;
			}
			
			if(goal.isComplete){
				sumString = '<span style="color: green">' + goal.numAccsSel + ' accounts selected</span>';
				j$('.acceptButton[goalId="' + goal.goalId + '"]').removeClass("ui-state-disabled");
			} else {
				sumString = '<span style="color: red">Select ' + (goal.detail - goal.numAccsSel) + ' more accounts';
				j$('.acceptButton[goalId="' + goal.goalId + '"]').addClass("ui-state-disabled");
			}
		}
		
		var topText = j$(".accountTopCell[goalKey='" + goalKey + "'] > .topText");
		j$(topText).empty();
		j$(topText).append(topString);
		
		var sumText = j$(".sumLineCell[goalKey='" + goalKey + "'] > .sumText");
		j$(sumText).empty();
		j$(sumText).append(sumString);
	} else {
		goal = childGoals.get(goalKey);
		var parent = parentGoals.get(goal.parentId);
		if(goal.mode == "manual"){
			var percent = Math.floor(goal.numAccsSel / parent.numAccsNeeded * 100);
			sumString = goal.numAccsSel + "/" + goal.numAccsAvail + " selected (" + percent + "%)";
		} else if(goal.mode == "count"){
			var tempNum = parseInt(goal.detail);
			if(isNaN(tempNum)){
				tempNum = 0;
				goal.detail = 0;
			}
			tempNum = Math.floor(tempNum / parent.numAccsNeeded * 100);
			if(goal.shouldShowCases == false){
				sumString = "Rep will choose " + goal.detail + " accounts (" + tempNum + "%)";
			} else {
				var caseNum = parseInt(goal.numCasesSel);
				if(isNaN(caseNum)){
					caseNum = 0;
					goal.numCasesSel = 0;
				}
				
				caseNum = Math.floor(caseNum / parent.numCasesNeeded * 100);
				sumString = "Rep will choose " + goal.detail + " accounts (" + tempNum + "%) and " + goal.numCasesSel + " (" + caseNum + "%) cases";
			}
			if(parseInt(goal.detail) > goal.numAccsAvail){
				sumString += '<br/><span style="color: red">Not enough accounts available</span>';
			}
		} else if(goal.mode == "percent"){
			var tempNum = parseInt(goal.detail);
			if(isNaN(tempNum)){
				tempNum = 0;
			}
			tempNum = Math.floor((tempNum / 100) * parent.numAccsNeeded);
			if(goal.shouldShowCases == false){
				sumString = "Rep will choose " + goal.detail + "% (" + tempNum + " accounts)";
			} else {
				var caseNum = parseInt(goal.numCasesSel);
				if(isNaN(caseNum)){
					caseNum = 0;
					goal.numCasesSel = 0;
				}
				caseNum = Math.floor((caseNum / 100) * parent.numCasesNeeded);
				sumString = "Rep will choose " + goal.detail + "% (" + tempNum + " accounts) and " + goal.numCasesSel + "% (" + caseNum + " cases)";
			}
			if(tempNum > goal.numAccsAvail){
				sumString += '<br/><span style="color: red">Not enough accounts available</span>';
			}
		}
		
		var sumText = j$(".sumLineCell[goalKey='" + goalKey + "'] > .sumText");
		j$(sumText).empty();
		j$(sumText).append(sumString);
		
		if(doTotalUpdate){
			updateTotals(goal.parentId);
		}
	}
}

function viewGoal(goalId){
	j$("#loadProgressBar").progressbar("option", "value", 50);
	updateLoadModal("Loading goal details...");
	j$("#loadModal").dialog({
		modal: true,
		closeOnEscape: false,
		open: function(event, ui) { 
				//hide close button
				j$(".ui-dialog-titlebar-close", j$(this).parent()).hide();
			}
	});
	var goal = parentGoals.get(goalId);
	assignDummyViewGoal(goalId);
}

function editGoal(goalId){
	j$("#loadProgressBar").progressbar("option", "value", 50);
	updateLoadModal("Loading goal details...");
	j$("#loadModal").dialog({
		modal: true,
		closeOnEscape: false,
		open: function(event, ui) { 
				//hide close button
				j$(".ui-dialog-titlebar-close", j$(this).parent()).hide();
			}
	});
	var goal = parentGoals.get(goalId);
	assignDummyGoal(goalId);
}

function createNewGoal(isLocal){
	var recTypeName = j$(".createGoalSelect").val();
	var premType = j$(".createGoalSelect2").val();
	
	if(recTypeName == 'Display Goals' && premType == 'On-Premise - Control'){
		alert('Display goals cannot be created for On-Premise accounts.');
		return null;
	}
	if(recTypeName == 'Cold Box Goals' && premType == 'On-Premise - Control'){
		alert('Cold Box goals cannot be created for On-Premise accounts.');
		return null;
	}
	if(recTypeName == 'Feature Goals' && premType == 'Off-Premise - Control'){
		alert('Feature goals cannot be created for Off-Premise accounts.');
		return null;
	}
	if(recTypeName == 'Bar Promotion Goals' && premType == 'Off-Premise - Control'){
		alert('Bar Promotion goals cannot be created for Off-Premise accounts.');
		return null;
	}
	
	j$("#loadProgressBar").progressbar("option", "value", 50);
	updateLoadModal("Creating goal details...");
	j$("#loadModal").dialog({
		modal: true,
		closeOnEscape: false,
		open: function(event, ui) { 
				//hide close button
				j$(".ui-dialog-titlebar-close", j$(this).parent()).hide();
			}
	});
	createDummyGoal(recTypeName, premType, isLocal);
}

function showGoalModal(andToggle){	
	j$(".goalEditSaveButton").button();
	j$(".goalEditSaveButton").click(
		function(){
			if(j$(".goalEditSaveButton").prop("disabled") != "disabled"){
				j$(".goalEditSaveButton").prop("disabled","disabled").addClass("ui-state-disabled");
				j$(".goalEditCancelButton").prop("disabled","disabled").addClass("ui-state-disabled");
				saveGoal();
			}
		}
	);
	
	j$(".goalEditCancelButton").button();
	j$(".goalEditCancelButton").click(
		function(){
			if(j$(".goalEditCancelButton").prop("disabled") != "disabled"){
				j$(".goalEditSaveButton").prop("disabled","disabled").addClass("ui-state-disabled");
				j$(".goalEditCancelButton").prop("disabled","disabled").addClass("ui-state-disabled");
				cancelGoal();
			}
		}
	);
	
	j$(".goalViewCloseButton").button();
	j$(".goalViewCloseButton").click(
		function(){
			if(j$(".goalViewCloseButton").prop("disabled") != "disabled"){
				j$(".goalViewCloseButton").prop("disabled","disabled").addClass("ui-state-disabled");
				cancelGoal();
			}
		}
	);
	j$("#loadModal").dialog("close");
	hideBBSLookups();
	if(andToggle){
		j$(".goalModal").slideToggle();
	}
}

function closeGoalModal(){
	if(j$('.messageCell').length == 0){
		j$(".goalModal").slideToggle();
	} else {
		j$(".goalEditSaveButton").prop("disabled","false").removeClass("ui-state-disabled");
		j$(".goalEditCancelButton").prop("disabled","false").removeClass("ui-state-disabled");
	}
}

function closeGoalModalAndAdd(isCreate, newGoalId, newGoalName, newGoalDueDate, newGoalPremise, newGoalMinimum, newGoalCases, newGoalSalesChannel, newGoalRecTypeName){
	if(j$('.messageCell').length == 0){
		if(isCreate == 'create'){
			var goal = new Object();
			goal.goalId = newGoalId;
			goal.name = newGoalName;
			goal.dueDate = newGoalDueDate;
			goal.channel = newGoalSalesChannel;
			goal.recTypeName = newGoalRecTypeName;
			goal.premise = newGoalPremise;
			goal.children = new Hash();
			goal.numAccsSel = 0;
			goal.numAccsNeeded = newGoalMinimum;
			goal.numCasesNeeded = newGoalCases;
			goal.shouldShowCases = false;
			if(goal.premise == 'Off-Premise - Control' && (goal.channel == 'Integrated National Program' || goal.channel == 'Display/Visibility')){
				goal.shouldShowCases = true;
			}
			
			var hasPremiseMatch = false;
			var repValues = reps.values();
			for(var j = 0; j < repValues.length; j++){
				var rep = repValues[j];
				if(rep.premisesByName.get(goal.premise) != null){
					hasPremiseMatch = true;
				}
			}
			
			if(hasPremiseMatch){
				addMgrGoal(goal, false);
				
				var childValues = goal.children.values();
				for(var i = 0; i < childValues.length; i++){
					var childGoal = childValues[i];
					doNextActionStep(childGoal, repValues);
					assignTypeChanged(childGoal.key, childGoal.mode, true, true);
				}
				
				
				updateIEWidth(channels.get(goal.channel), premises.get(goal.premise));
				updateTotals(goal.goalId);
				updateRepCounts(true, true);
				
				j$(".goalEditButton").button();
				j$(".assignSelectAll").button();
				j$(".assignCopyButton").button();
				j$(".goalModal").slideToggle();
				j$(".saveButton").prop("disabled","false").removeClass("ui-state-disabled");
				j$(".submitButton").prop("disabled","false").removeClass("ui-state-disabled");
				j$(".saveButton").button();
				j$(".saveButton").button({disabled: false});
				j$(".saveButton").click(function(){saveClicked()});
				j$(".submitButton").button();
				j$(".submitButton").button({disabled: false});
				j$(".submitButton").click(function(){submitClicked()});
			} else {
				var alertString = 'You have attempted to create a local goal of type "' + goal.premise;
				alertString += '", but none of your reps have accounts in that premise. Please try again.';
				alert(alertString);
			}
		} else {
			j$(".goalModal").slideToggle();
		}
	}
	j$(".goalEditSaveButton").prop("disabled","false").removeClass("ui-state-disabled");
	j$(".goalEditCancelButton").prop("disabled","false").removeClass("ui-state-disabled");
	
	j$('.newSubmitButton').button();
	updateTotals(newGoalId);
}

function updateAccountFilters(repBlockKey){
	var repBlock = j$('.repBlock[key="' + repBlockKey + '"]');
	var showA = j$(repBlock).find('.accountFilterCheckbox[value="A"]').attr('checked') == 'checked';
	var showB = j$(repBlock).find('.accountFilterCheckbox[value="B"]').attr('checked') == 'checked';
	var showC = j$(repBlock).find('.accountFilterCheckbox[value="C"]').attr('checked') == 'checked';
	var showD = j$(repBlock).find('.accountFilterCheckbox[value="D"]').attr('checked') == 'checked';
	var showOther = j$(repBlock).find('.accountFilterCheckbox[value="other"]').attr('checked') == 'checked';
	var accsShown = 0;
	j$('.accountLine[repBlockKey="' + repBlockKey + '"]').each(
		function(){
			var segment = j$(this).attr('segment');
			var showThis;
			if(segment == 'A'){
				showThis = showA;
			} else if(segment == 'B'){
				showThis = showB;
			} else if(segment == 'C'){
				showThis = showC;
			} else if(segment == 'D'){
				showThis = showD;
			} else {
				showThis = showOther;
			}
			if(showThis){
				accsShown++;
				j$(this).show();
				j$(this).attr("shown", "true");
			} else {
				j$(this).hide();
				j$(this).attr("shown", "false");
			}
		}
	);
	
	colorAccounts(false);
	
	//update rep counts, in a more minimal fashion
	var str = j$(repBlock).find('.accountTopFirst').text();
	str = 'Accounts (' + accsShown + ' of ' + str.split(' of ')[1];
	j$(repBlock).find('.accountTopFirst').empty();
	j$(repBlock).find('.accountTopFirst').append(str);
	
	/*
	//updateRepCounts(true);
	var rep = reps.get(repBlockKey.split('|')[0]);
	var accsShown = 0;
	var vals = rep.accountsById.values();
	for(var l = 0; l < vals.length; l++){
		var acc = vals[l];
		var accLineShown = j$('.accountLine[accId="' + acc.Id + '"][repBlockKey="' + repBlockKey + '"]').attr("shown");
		if(accLineShown == "true"){
			accsShown++;
		}
	}
	var str = j$(repBlock).find('.accountTopFirst').text();
	str = 'Accounts (' + accsShown + ' of ' + str.split(' of ')[1];
	j$(repBlock).find('.accountTopFirst').empty();
	j$(repBlock).find('.accountTopFirst').append(str);*/
}