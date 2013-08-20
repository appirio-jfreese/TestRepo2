var setupChain = [createLoadModal,
				  setupTerritories,
				  setupUnderlings,
				  setupAccounts,
				  setupGoals,
				  applyAll,
				  finishAll
				 ];
var setupIndex = -1;

function doNextSetupStep(){
	setupIndex++;
	j$('#loadProgressBar').progressbar();
	j$('#loadProgressBar').progressbar('option', 'value', setupIndex / (setupChain.length-1) * 100);
	setupChain[setupIndex]();
}

function updateLoadModal(text){
	j$('#loadModal > p').remove();
	j$('#loadModal').append('<p>' + text + '</p>');
}

function finishAll(){
	updateLoadModal('All done!');
	j$('#loadModal').dialog('close');
}

function createLoadModal(){
	j$('#loadModal').dialog({
		modal: true,
		closeOnEscape: false,
		open: function(event, ui) { 
				//hide close button
				j$('.ui-dialog-titlebar-close', j$(this).parent()).hide();
			}
	});
	j$('#loadProgressBar').progressbar();
	doNextSetupStep();
}

function setupTerritories(){
	updateLoadModal('Setting up territories...');
	
	territoriesByOwnerId = new Hash();
	territoryIds = [];
	
	var methodName;
	if(repMode == true){
		methodName = 'getRepTerritories';
	} else {
		methodName = 'getManagerTerritories';
	}
	contLoadFunc(methodName, null, function(result){
		for(var i = 0; i < result.length; i++){
			var terr = result[i];
			territoriesByOwnerId.put(terr.OwnerId, terr);
			territoryIds.push(terr.Id);
		}
		
		doNextSetupStep();
	});
}

function setupUnderlings(){
	updateLoadModal('Setting up users...');
	
	underlingsById = new Hash();
	
	var terrs = territoriesByOwnerId.values();
	for(var i = 0; i < terrs.length; i++){
		var terr = terrs[i];
		var ownerId = terr.OwnerId;
		
		if(underlingsById.get(ownerId) == null){
			var underling = new Object();
			underling.id = ownerId;
			underling.name = terr.Owner.Name;
			underling.territoryNamesById = new Hash();
			underling.accountsById = new Hash();
			underling.accounts = [];
			underling.accountArraysByPremise = new Hash();
			underling.accSegmentationsByPremise = new Hash();
			underling.childGoalsByKey = new Hash();
			underlingsById.put(ownerId, underling);
		}
		underlingsById.get(ownerId).territoryNamesById.put(terr.Id, terr.Name);
	}
	
	doNextSetupStep();
}

function setupGoals(){
	updateLoadModal('Setting up goals...');
	
	parentGoalsById = new Hash();
	parentGoalsByPriority = new Hash();
	parentGoalsByPriorityAndPremise = new Hash();
	parentGoalsByPriorityPremiseAndRT = new Hash();
	
	childGoalsByKey = new Hash();
	
	contLoadFunc('getUserGoals', null, function(result){
		var validGoals = 0;
		for(var i = 0; i < result.length; i++){
			if(result[i].Long_Name__c != null){
				validGoals++;
				var parentGoal = new Object();
				
				parentGoal.goal = result[i];
				parentGoal.visible = true;
				parentGoal.key = parentGoal.goal.Priority__c + '|' + parentGoal.goal.Goal_Type__c + '|' + parentGoal.goal.RecordType.Name;
				
				var dueDate = new Date(parentGoal.goal.Due_Date__c);
				parentGoal.dueDate = (dueDate.getUTCMonth() + 1) + '/' + dueDate.getUTCDate() + '/' + dueDate.getUTCFullYear();
				if(repMode == true){
					parentGoal.isRepAcceptable = false;
					var minutes = 1000*60;
		    		var hours = minutes*60;
		    		var days = hours*24;
		    		var allowableDaysOut = 5;
					var startDate = new Date(parentGoal.goal.Start_Date__c);
		    		var today = new Date();
		
		    		var daysBetween = Math.round((startDate - today)/days);
		    		parentGoal.isRepAcceptable = daysBetween <= allowableDaysOut;
				} else {
					parentGoal.isRepAcceptable = true;
				}
			
				parentGoal.accsAvailable = 0;
				parentGoal.accsNeeded = parentGoal.goal.Minimum_of_Accounts__c;
				parentGoal.accsYouHaveChosen = 0;
				parentGoal.accsRepsWillChoose = 0;
				parentGoal.accsStillNeeded = 0;
				parentGoal.casesNeeded = parentGoal.goal.Cases_Displayed__c;
				parentGoal.casesRepsWillChoose = 0;
				parentGoal.casesStillNeeded = 0;
				
				parentGoal.shouldShowCases = false;
				if(repMode == false &&
					parentGoal.goal.Goal_Type__c == 'Off-Premise - Control' &&
					(parentGoal.goal.RecordType.Name == 'Display Goals' || parentGoal.goal.RecordType.Name == 'Volume/QD Goals')
					){
					parentGoal.shouldShowCases = true;
				}
				
				parentGoal.childGoalsByRepId = new Hash();
				
				parentGoalsById.put(parentGoal.goal.Id, parentGoal);
				parentGoalsByPriority.putInArray(parentGoal.goal.Priority__c, parentGoal);
				parentGoalsByPriorityAndPremise.putInArray(parentGoal.goal.Priority__c + '|' + parentGoal.goal.Goal_Type__c, parentGoal);
				parentGoalsByPriorityPremiseAndRT.putInArray(parentGoal.key, parentGoal);
				
				if(repMode == true){
					createRepGoals(parentGoal);
				} else {
					createRepGoals(parentGoal);
				}
			}
		}
		
		if(validGoals == 0){
			alert('No current goals found. Please contact your administrator if you feel you are seeing this message in error.');
			gotoMyGoals();
		} else {
			doNextSetupStep();
		}
	});
}

function createRepGoals(parentGoal){
	var underlings = underlingsById.values();
	
	for(var i = 0; i < underlings.length; i++){
		var underling = underlings[i];
		
		if(underling.accountArraysByPremise.get(parentGoal.goal.Goal_Type__c) != null){
			var childGoal = new Object();
			childGoal.underling = underling;
			childGoal.parentGoal = parentGoal;
			childGoal.shouldShowCases = parentGoal.shouldShowCases;
			childGoal.key = childGoal.parentGoal.goal.Id + '|' + underling.id;
			
			if(repMode){
				childGoal.assignMode = parentGoal.goal.Assignment_Mode__c;
			} else {
				childGoal.assignMode = 'count';
			}
			childGoal.actions = [];
			childGoal.actionsByAccId = new Hash();
			childGoal.actionsSelected = 0;
			childGoal.actionsAvailable = 0;
			childGoal.assignDetail = null;
			childGoal.casesDetail = null;
			childGoal.hasAssignError = false;
			
			underling.childGoalsByKey.putInArray(parentGoal.key, childGoal);
			parentGoal.childGoalsByRepId.put(underling.id, childGoal);
			childGoalsByKey.put(childGoal.key, childGoal);
		}
	}
}

function setupAccounts(){
	updateLoadModal('Setting up accounts...');
	
	accountsById = new Hash();
	
	contLoadFunc('getAccounts', [territoryIds], function(result){
		for(var i = 0; i < result.length; i++){
			var account = result[i];
			account.visible = true;
			
			//modify name string
			account.Name = account.Name.split(' ( ')[0];
			if(account.Doing_Business_As__c != null){
				account.Name = account.Doing_Business_As__c;
			}
			if(account.NABCA_Licensee_Address__c != null){
				account.Name += '<br/>(' + account.NABCA_Licensee_Address__c + ')';
			} else {
				account.Name += '<br/>(' + account.BillingStreet + ')';
			}
			
			var underling = underlingsById.get(account.OwnerId);
			underling.accountsById.put(account.Id, account);
			underling.accounts.push(account);
			underling.accountArraysByPremise.putInArray(account.RecordType.Name, account);
			if(account.Account_Segmentatiobn__c != 'A' &&
			   account.Account_Segmentatiobn__c != 'B' &&
			   account.Account_Segmentatiobn__c != 'C' &&
			   account.Account_Segmentatiobn__c != 'D'){
				account.Account_Segmentatiobn__c = 'Other';
			}
			underling.accSegmentationsByPremise.putInUniqueArray(account.RecordType.Name, account.Account_Segmentatiobn__c);
			
			accountsById.put(account.Id, account);
		}
		
		doNextSetupStep();
	});
}

function applyAll(){
	updateLoadModal('Building UI...');
	
	recreateTabs();
	
	doNextSetupStep();
}

































//page end
