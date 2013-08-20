public with sharing class Controller_ActionCreationPage {
	
	/* This class is no longer used -- kept for archival purposes
	
	public Goal__c dummyGoal				{get;set;}
	public String dummyGoalId				{get;set;}
	public String dummyGoalRecTypeName		{get;set;}
	public String dummyGoalPremType 		{get;set;}
	public String dummyGoalCreateIsLocal	{get;set;}
	public Boolean isGoalModalShown			{get;set;}
	public String dummyMode					{get;set;}
	public Goal__c assocParentGoal			{get;set;}
	public Boolean assocParentGoalSelected	{get;set;}
	
	public Boolean showFeatures				{get;set;}
	public Boolean showCases				{get;set;}
	public Boolean showLocationGrade		{get;set;}
	public Boolean showSFAPOS				{get;set;}
	public Boolean showContentLink			{get;set;}
	public Boolean showTypeOfAd				{get;set;}
	public Boolean showSizeOfAd				{get;set;}
	public Boolean showFeatureType			{get;set;}
	public Boolean showSuggestedPrice		{get;set;}
	public Boolean showAccomplishment		{get;set;}
	public Boolean showProductSamples		{get;set;}
	public Boolean showTrainer				{get;set;}
	public Boolean showTrainingAud			{get;set;}
	public Boolean showTrainingLength		{get;set;}
	public Boolean showNumAttendees			{get;set;}
	public Boolean showTastedProduct		{get;set;}
	
	public Brand_Bottle_Goal__c dummyBBG	{get;set;}
	public String bbgSelValue				{get;set;}
	public String bbgSelName				{get;set;}
	public List<SelectOption> bbgOptions	{get;set;}
	public List<String> selectedBBGs		{get;set;}
	
	public String premiseMessagePremise		{get;set;}

	public Controller_ActionCreationPage(){
		isGoalModalShown = false;
		dummyGoalId = '';
	}
	
	public void showPremiseMessage(){
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'One or more ' + premiseMessagePremise + ' goals were found, but you do not have any accounts of that type. Those goals will not be shown.'));
	}
	
	public String getUserAgent() {
		return ApexPages.currentPage().getHeaders().get('User-Agent');
	}
	
	public PageReference addReadOnlyMessage(){
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You have already submitted all available goals for rep acceptance. This page will run in a read-only mode to allow you to view the goals, but no changes may be made or saved.'));
		return null;
	}
	
	public PageReference addRepReadOnlyMessage(){
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You have already accepted and created actions for all available goals. This page will run in a read-only mode.'));
		return null;
	}
	
	public PageReference assignDummyViewGoal(){
		dummyMode = 'view';
		return assignDummyGoal();
	}
	
	public PageReference assignDummyCreateGoal(){
		dummyGoalId = '';
		return assignDummyGoal();
	}
	
	public PageReference assignDummyGoal(){
		assocParentGoal = null;
		assocParentGoalSelected = false;
		
		if(dummyGoalId == ''){
			dummyMode = 'create';
			if(dummyGoalRecTypeName == null){
				dummyGoalRecTypeName = 'General Goals';
			}
			Id recTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Goal__c' AND Name =:dummyGoalRecTypeName].Id;
			dummyGoal = new Goal__c();
			dummyGoal.Goal_Type__c = dummyGoalPremType;
			dummyGoal.RecordTypeId = recTypeId;
			dummyGoal.Goal_Level__c = 'Manager';
			dummyGoal.Sales_Channel__c = 'Local';
			dummyGoal.OwnerId = UserInfo.getUserId();
			dummyGoal.Goal_For__c = UserInfo.getUserId();
		} else {
			if(dummyMode != 'view'){
				dummyMode = 'edit';
			}
			dummyGoal = 
				[SELECT Id,
						Name,
						Sales_Channel__c,
						Goal_Type__c,
						Program__c,
						Due_Date__c,
						State__c,
						Minimum_of_Accounts__c,
						RecordTypeId,
						RecordType.Name,
						OwnerId,
						CreatedById,
						Goal_For__c,
						Cases_Displayed__c,
						Account_Grade__c,
						Location_Grade__c,
						Comments__c,
						Content_Link__c,
						Percent_of_Universe__c,
						Features_Displayed__c,
						SFA_POS_Items__c,
						Brand_Category__c,
						Type_of_Ad__c,
						Size_of_Ad__c,
						Feature_Type__c,
						Suggested_Price__c,
						Accomplishment_Recap__c,
						Product_Sample_s__c,
						Trainer__c,
						Training_Audience__c,
						Length_of_Training__c,
						Number_of_Attendees__c,
						Tasted_Product__c,
						(SELECT Id,
								BrandBottle_Size__c,
								BrandBottle_Size__r.Name
						   FROM Brand_Bottle_Goals__r
						)
				   FROM Goal__c
				  WHERE Id = :dummyGoalId
			 	];
			dummyGoalRecTypeName = dummyGoal.RecordType.Name;
		}
		
		isGoalModalShown = true;
		
		checkShowsBasedOnRecType();
		
		dummyBBG = new Brand_Bottle_Goal__c();
		selectedBBGs = new List<String>();
		bbgOptions = new List<SelectOption>();
		
		for(Brand_Bottle_Goal__c bbg : dummyGoal.Brand_Bottle_Goals__r){
			bbgOptions.add(new SelectOption(bbg.BrandBottle_Size__c, bbg.BrandBottle_Size__r.Name));
		}
		
		return null;
	}
	
	private void checkShowsBasedOnRecType(){		
		showFeatures		= dummyGoal.Goal_Type__c == 'On-Premise - Control'
			&& dummyGoal.Sales_Channel__c != 'Distribution' && dummyGoalRecTypeName != 'Distribution Goals'
			&& dummyGoal.Sales_Channel__c != 'Innovation' && dummyGoalRecTypeName != 'Innovation Goals'
			&& dummyGoal.Sales_Channel__c != 'Sustainovation' && dummyGoalRecTypeName != 'Sustainovation Goals';
		showCases			= dummyGoal.Goal_Type__c == 'Off-Premise - Control'
			&& dummyGoal.Sales_Channel__c != 'Distribution' && dummyGoalRecTypeName != 'Distribution Goals'
			&& dummyGoal.Sales_Channel__c != 'Innovation' && dummyGoalRecTypeName != 'Innovation Goals'
			&& dummyGoal.Sales_Channel__c != 'Sustainovation' && dummyGoalRecTypeName != 'Sustainovation Goals';
		showLocationGrade	= false;
		showSFAPOS			= false;
		showContentLink		= false;
		showTypeOfAd		= false;
		showSizeOfAd		= false;
		showFeatureType		= false;
		showSuggestedPrice	= false;
		showAccomplishment	= false;
		showProductSamples	= false;
		showTrainer			= false;
		showTrainingAud		= false;
		showTrainingLength	= false;
		showNumAttendees	= false;
		showTastedProduct	= false;
		
		if(dummyGoalRecTypeName == 'Display Goals'){
			showLocationGrade	= true;
			showSFAPOS			= true;
		} else if(dummyGoalRecTypeName == 'Distribution Goals'){
			showContentLink		= true;
		} else if(dummyGoalRecTypeName == 'General Goals'
			   || dummyGoalRecTypeName == 'Cold Box Goals'
			   || dummyGoalRecTypeName == 'Tasting Goals'){
		} else if(dummyGoalRecTypeName == 'Ad Execution'){
			showTypeOfAd		= true;
			showSizeOfAd		= true;
			showFeatureType		= true;
			showSuggestedPrice	= true;
		} else if(dummyGoalRecTypeName == 'Feature Goals'){
			showFeatureType		= true;
			showSuggestedPrice	= true;
		} else if(dummyGoalRecTypeName == 'Menu Goals'){
			showSFAPOS			= true;
			showFeatureType		= true;
			showSuggestedPrice	= true;
		} else if(dummyGoalRecTypeName == 'Shelf Set Goals'
			   || dummyGoalRecTypeName == 'Bar Promotion Goals'){
			showSFAPOS			= true;
			showFeatureType		= true;
			showSuggestedPrice	= true;
		} else if(dummyGoalRecTypeName == 'Staff Training Goals'){
			showSFAPOS			= true;
			showSuggestedPrice	= true;
			showProductSamples	= true;
			showTrainer			= true;
			showTrainingAud		= true;
			showTrainingLength	= true;
			showNumAttendees	= true;
			showTastedProduct	= true;
		} else if(dummyGoalRecTypeName == 'Window Display Goals'){
			showSFAPOS			= true;
		}
	}
	
	public PageReference addBBG(){
		SelectOption opt = new SelectOption(dummyBBG.BrandBottle_Size__c, bbgSelName);
		bbgOptions.add(opt);
		return null;
	}
	
	public PageReference removeBBGs(){
		List<SelectOption> optsToKeep = new List<SelectOption>();
		for(SelectOption opt : bbgOptions){
			Boolean keep = true;
			for(String remId : selectedBBGs){
				if(opt.getValue() == remId){
					keep = false;
				}
			}
			if(keep){
				optsToKeep.add(opt);
			}
		}
		bbgOptions = optsToKeep;
		return null;
	}
	
	public PageReference assocParentSelected(){
		dummyGoal.Parent_Goal__c = dummyGoal.Associate_Parent__c;
		assocParentGoalSelected = true;
		assocParentGoal = 
			[SELECT Id,
					Name,
					Due_Date__c,
					Program__c,
					Minimum_of_Accounts__c,
					Cases_Displayed__c,
					Sales_Channel__c,
					Account_Grade__c,
					RecordTypeId,
					RecordType.Name,
					Goal_Type__c,
					Brand_Category__c,
					Percent_of_Universe__c,
					Comments__c
			   FROM Goal__c
			  WHERE Id = :dummyGoal.Parent_Goal__c
			];
			
		dummyGoal.Parent_Goal__c = assocParentGoal.Id;
		dummyGoal.Name = assocParentGoal.Name;
		dummyGoal.Due_Date__c = assocParentGoal.Due_Date__c;
		dummyGoal.Program__c = assocParentGoal.Program__c;
		dummyGoal.Minimum_of_Accounts__c = assocParentGoal.Minimum_of_Accounts__c;
		dummyGoal.Cases_Displayed__c = assocParentGoal.Cases_Displayed__c;
		dummyGoal.Sales_Channel__c = assocParentGoal.Sales_Channel__c;
		dummyGoal.Account_Grade__c = assocParentGoal.Account_Grade__c;
		dummyGoal.RecordTypeId = assocParentGoal.RecordTypeId;
		dummyGoalRecTypeName = assocParentGoal.RecordType.Name;
		dummyGoal.Goal_Type__c = assocParentGoal.Goal_Type__c;
		dummyGoal.Brand_Category__c = assocParentGoal.Brand_Category__c;
		dummyGoal.Percent_of_Universe__c = assocParentGoal.Percent_of_Universe__c;
		dummyGoal.Comments__c = assocParentGoal.Comments__c;
		
		checkShowsBasedOnRecType();
			
		return null;
	}
	
	public PageReference saveGoal(){
		if(dummyGoal.Goal_Type__c == 'On Premise'){
			dummyGoal.Goal_Type__c = 'On-Premise - Control';
		} else if(dummyGoal.Goal_Type__c == 'Off Premise'){
			dummyGoal.Goal_Type__c = 'Off-Premise - Control';
		//REMOVE COMBINED } else if(dummyGoal.Goal_Type__c == 'Combined Premise'){
		//REMOVE COMBINED 	dummyGoal.Goal_Type__c = 'Combined Premise - Control';
		}
		if(dummyGoal.Name == null){
			String progName = [SELECT Id, Name FROM Calendar__c WHERE Id = :dummyGoal.Program__c].Name;
			dummyGoal.Name = progName + ' - ' + dummyGoal.Goal_Type__c;
		}
		if(dummyGoal.State__c == null){
			List<Territory__c> terrs = [SELECT Id, State__c FROM Territory__c WHERE Manager__c = :UserInfo.getUserId() LIMIT 1];
			if(terrs.size() > 0){
				dummyGoal.State__c = terrs[0].State__c;
			}
		}
		if(dummyGoal.Cases_Displayed__c == null){
			dummyGoal.Cases_Displayed__c = 0;
		}
		upsert dummyGoal;
		
		List<Brand_Bottle_Goal__c> oldBBGs = dummyGoal.Brand_Bottle_Goals__r;
		List<Brand_Bottle_Goal__c> bbgsToInsert = new List<Brand_Bottle_Goal__c>();
		List<Brand_Bottle_Goal__c> bbgsToDelete = new List<Brand_Bottle_Goal__c>();
		
		for(SelectOption opt : bbgOptions){
			Boolean matchFound = false;
			for(Integer i = 0; i < oldBBGs.size() && matchFound == false; i++){
				if(oldBBGs[i].Id == opt.getValue()){
					matchFound = true;
					oldBBGs.remove(i);
				}
			}
			if(matchFound == false){
				Brand_Bottle_Goal__c bbg = new Brand_Bottle_Goal__c();
				bbg.BrandBottle_Size__c = opt.getValue();
				bbg.Goal__c = dummyGoal.Id;
				bbgsToInsert.add(bbg);
			}
		}
		if(oldBBGs != null){
			bbgsToDelete.addAll(oldBBGs);
		}
		
		if(bbgsToInsert.size() > 0){
			insert bbgsToInsert;
		}
		if(bbgsToDelete.size() > 0){
			delete bbgsToDelete;
		}
		
		return cancelGoal();
	}
	
	public PageReference cancelGoal(){
		//dummyGoal = null;
		dummyGoalId = '';
		//isGoalModalShown = false;
		return null;
	}
	
	@RemoteAction
	public static List<String> getChannels(){
		List<String> retList = new List<String>();
		List<Schema.PicklistEntry> entries = Goal__c.Sales_Channel__c.getDescribe().getPicklistValues();
		for(Integer i = 0; i < entries.size(); i++){
			retList.add(entries[i].getLabel());
		}
		return retList;
	}
	
	@RemoteAction
	public static List<Territory__c> getManagerTerritories(){
		List<Territory__c> terrs =
			[SELECT Id,
					Name,
					OwnerId,
					State__c
			   FROM Territory__c
			  WHERE Manager__c = :UserInfo.getUserId()
		   ORDER BY Name
			];
		return terrs;
	}
	
	@RemoteAction
	public static List<Territory__c> getRepTerritories(){
		List<Territory__c> terrs =
			[SELECT Id,
					Name,
					OwnerId
			   FROM Territory__c
			  WHERE OwnerId = :UserInfo.getUserId()
		   ORDER BY Name
			];
		return terrs;
	}
	
	@RemoteAction
	public static List<Account> getAccounts(String[] ownerIdStrings, String[] terrIdStrings){
		List<Account> accounts =
			[SELECT Id,
					Name,
					OwnerId,
					Owner.Name,
					RecordType.Name,
					Account_Segmentatiobn__c,
					NABCA_Licensee_Address__c,
					Doing_Business_As__c
			   FROM Account
			  WHERE OwnerId IN :ownerIdStrings
			    AND Territory__c IN :terrIdStrings
			    AND RecordType.Name LIKE '% - Control'
			    AND Called_On__c = true
		   ORDER BY Name
			];
		return accounts;
	}
	
	@RemoteAction
	public static List<Goal__c> getManagerGoals(){
		List<Goal__c> goals =
			[SELECT Id,
					Name,
					Sales_Channel__c,
					Goal_Type__c,
					Minimum_of_Accounts__c,
					Cases_Displayed__c,
					OwnerId,
					Goal_For__c,
					Due_Date__c,
					RecordType.Name,
					(SELECT Id,
							Name,
							OwnerId,
							Goal_For__c,
							Assignment_Mode__c,
							Assignment_Mode_Detail__c
					   FROM Child_Goals__r
					)
			   FROM Goal__c
			  WHERE OwnerId = :UserInfo.getUserId()
			    AND Goal_For__c = :UserInfo.getUserId()
			    AND Due_Date__c >= :Date.today()
			    AND Goal_Level__c = 'Manager'
			    AND Minimum_of_Accounts__c <> null
			    AND Minimum_of_Accounts__c <> 0
			    AND Completed__c = false
		   ORDER BY	Due_Date__c, Name
			];
			
		return goals;
	}
	
	@RemoteAction
	public static List<Goal__c> getRepGoals(){
		List<Goal__c> goals =
			[SELECT Id,
					Name,
					OwnerId,
					Sales_Channel__c,
					Goal_Type__c,
					Assignment_Mode__c,
					Assignment_Mode_Detail__c,
					Cases_Displayed__c,
					Due_Date__c,
					RecordType.Name,
					(SELECT Id,
							OwnerId,
							Goal__c,
							Account__c
					   FROM Actions__r
					)
			   FROM Goal__c
			  WHERE OwnerId = :UserInfo.getUserId()
			    AND Due_Date__c >= :Date.today()
			    AND Minimum_of_Accounts__c <> null
			    AND Minimum_of_Accounts__c <> 0
			    AND Completed__c = false
		   ORDER BY	Due_Date__c, Name
			];
			
		return goals;
	}
	
	@RemoteAction
	public static Boolean saveGoals(List<Goal__c> jsGoals, Boolean isSubmit){
		Set<Id> parentGoalIds = new Set<Id>();
		for(Goal__c jsGoal : jsGoals){
			parentGoalIds.add(jsGoal.Parent_Goal__c);
		}
		List<Goal__c> parentGoals = 
			[SELECT Id,
					Name,
					Sales_Channel__c,
					Goal_Type__c,
					Program__c,
					Due_Date__c,
					RecordTypeId,
					OwnerId,
					Goal_For__c,
					Cases_Displayed__c,
					Account_Grade__c,
					Location_Grade__c,
					Comments__c,
					Content_Link__c,
					Percent_of_Universe__c,
					Features_Displayed__c,
					SFA_POS_Items__c,
					State__c,
					(SELECT Id,
							BrandBottle_Size__c
					   FROM Brand_Bottle_Goals__r
					)
			   FROM Goal__c
			  WHERE Id IN :parentGoalIds
			];
		Map<Id, Goal__c> parentGoalsById = new Map<Id, Goal__c>(parentGoals);
		
		List<Goal__c> childGoalsToInsert = new List<Goal__c>();
		List<Goal__c> childGoalsToUpdate = new List<Goal__c>();
		for(Goal__c jsGoal : jsGoals){
			Goal__c childGoal;
			if(jsGoal.Id == null){
				//create new child goal
				childGoal = new Goal__c();
				Goal__c parentGoal = parentGoalsById.get(jsGoal.Parent_Goal__c);
				
				childGoal.Parent_Goal__c = parentGoal.Id;
				childGoal.Goal_For__c = jsGoal.Goal_For__c;
				childGoal.Minimum_of_Accounts__c = jsGoal.Minimum_of_Accounts__c;
				childGoal.Cases_Displayed__c = jsGoal.Cases_Displayed__c;
				childGoal.Goal_Level__c = 'Rep';
				
				childGoal.Name = parentGoal.Name;
				childGoal.State__c = parentGoal.State__c;
				childGoal.Sales_Channel__c = parentGoal.Sales_Channel__c;
				childGoal.Goal_Type__c = parentGoal.Goal_Type__c;
				childGoal.Program__c = parentGoal.Program__c;
				childGoal.Due_Date__c = parentGoal.Due_Date__c;
				childGoal.RecordTypeId = parentGoal.RecordTypeId;
				childGoal.Account_Grade__c = parentGoal.Account_Grade__c;
				childGoal.Location_Grade__c = parentGoal.Location_Grade__c;
				childGoal.Comments__c = parentGoal.Comments__c;
				childGoal.Content_Link__c = parentGoal.Content_Link__c;
				childGoal.Percent_of_Universe__c = parentGoal.Percent_of_Universe__c;
				childGoal.Features_Displayed__c = parentGoal.Features_Displayed__c;
				childGoal.SFA_POS_Items__c = parentGoal.SFA_POS_Items__c;
				
				childGoal.Assignment_Mode__c = jsGoal.Assignment_Mode__c;
				childGoal.Assignment_Mode_Detail__c = jsGoal.Assignment_Mode_Detail__c;
				
				if(jsGoal.OwnerId != null){
					childGoal.OwnerId = jsGoal.OwnerId;
				}
				
				childGoalsToInsert.add(childGoal);
			} else {
				//update existing child goal
				childGoal = new Goal__c(Id = jsGoal.Id);
				childGoal.Assignment_Mode__c = jsGoal.Assignment_Mode__c;
				childGoal.Assignment_Mode_Detail__c = jsGoal.Assignment_Mode_Detail__c;
				childGoal.Minimum_of_Accounts__c = jsGoal.Minimum_of_Accounts__c;
				
				if(jsGoal.OwnerId != null){
					childGoal.OwnerId = jsGoal.OwnerId;
				}
				
				childGoalsToUpdate.add(childGoal);
			}
		}
		
		if(childGoalsToInsert.size() > 0){
			insert childGoalsToInsert;
			
			List<Brand_Bottle_Goal__c> childGoalBBGs = new List<Brand_Bottle_Goal__c>();
			for(Goal__c childGoal : childGoalsToInsert){
				Goal__c parentGoal = parentGoalsById.get(childGoal.Parent_Goal__c);
				for(Brand_Bottle_Goal__c parentBBG : parentGoal.Brand_Bottle_Goals__r){
					Brand_Bottle_Goal__c childBBG = new Brand_Bottle_Goal__c();
					childBBG.Goal__c = childGoal.Id;
					childBBG.BrandBottle_Size__c = parentBBG.BrandBottle_Size__c;
					childGoalBBGs.add(childBBG);
				}
			}
			
			insert childGoalBBGs;
		}
		
		if(childGoalsToUpdate.size() > 0){
			update childGoalsToUpdate;
		}
		
		if(isSubmit){
			for(Goal__c parentGoal : parentGoals){
				parentGoal.Completed__c = true;
			}
			update parentGoals;
		}
		
		return true;
	}
	
	@RemoteAction
	public static Boolean saveActions(List<Action__c> jsActions, Boolean isSubmit){
		Set<Id> goalIds = new Set<Id>();
		for(Action__c action : jsActions){
			action.OwnerId = UserInfo.getUserId();
			goalIds.add(action.Goal__c);
		}
		Map<Id, Goal__c> goalsById = new Map<Id, Goal__c>(
			[SELECT Id,
					RecordType.Name,
					Cases_Displayed__c,
					SFA_POS_Items__c,
					Suggested_Price__c,
					Location_Grade__c,
					Feature_Type__c,
					Brand_Category__c,
					Trainer__c,
					Training_Audience__c,
					Length_of_Training__c,
					Product_Sample_s__c,
					Number_of_Attendees__c,
					Tasted_Product__c,
					State__c,
					(SELECT Id,
							BrandBottle_Size__r.Name
					   FROM Brand_Bottle_Goals__r
					)
			   FROM Goal__c
			  WHERE Id IN :goalIds
			]
		);
		Map<String, Id> actionRTIdsByName = new Map<String, Id>();
		for(RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Action__c']){
			actionRTIdsByName.put(rt.Name, rt.Id);
		}
		for(Action__c action : jsActions){
			Goal__c goal = goalsById.get(action.Goal__c);
			
			if(goal.RecordType.Name == 'Ad Execution'){
				action.RecordTypeId = actionRTIdsByName.get('Ad Execution - Control');
			} else if(goal.RecordType.Name == 'Display Goals'){
				action.RecordTypeId = actionRTIdsByName.get('Display - Control');
			} else if(goal.RecordType.Name == 'Distribution Goals'){
				action.RecordTypeId = actionRTIdsByName.get('Distribution - Control');
			} else if(goal.RecordType.Name == 'Feature Goals'){
				action.RecordTypeId = actionRTIdsByName.get('Feature Execution - Control');
			} else if(goal.RecordType.Name == 'General Goals'){
				action.RecordTypeId = actionRTIdsByName.get('General - Control');
			} else if(goal.RecordType.Name == 'Cold Box Goals'){
				action.RecordTypeId = actionRTIdsByName.get('Cold Box - Control');
			} else if(goal.RecordType.Name == 'Tasting Goals'){
				action.RecordTypeId = actionRTIdsByName.get('Tasting - Control');
			} else if(goal.RecordType.Name == 'Menu Goals'){
				action.RecordTypeId = actionRTIdsByName.get('Menu Execution - Control');
			} else if(goal.RecordType.Name == 'Shelf Set Goals'){
				action.RecordTypeId = actionRTIdsByName.get('Shelf Set - Control');
			} else if(goal.RecordType.Name == 'Bar Promotion Goals'){
				action.RecordTypeId = actionRTIdsByName.get('Bar Promotion - Control');
			} else if(goal.RecordType.Name == 'Staff Training Goals'){
				action.RecordTypeId = actionRTIdsByName.get('Training - Control');
			} else if(goal.RecordType.Name == 'Window Display Goals'){
				action.RecordTypeId = actionRTIdsByName.get('Window Display - Control');
			}
			
			action.POS_Items_SFA__c = goal.SFA_POS_Items__c;
			action.Suggested_Price__c = goal.Suggested_Price__c;
			action.Location_Grade__c = goal.Location_Grade__c;
			action.Feature_Type__c = goal.Feature_Type__c;
			action.Brand_Category__c = goal.Brand_Category__c;
			action.Trainer__c = goal.Trainer__c;
			action.Training_Audience__c = goal.Training_Audience__c;
			action.Product_Sample_s__c = goal.Product_Sample_s__c;
			action.Number_of_Attendees__c = goal.Number_of_Attendees__c;
			action.Tasted_Product__c = goal.Tasted_Product__c;
			
		}
		insert jsActions;
		
		List<Brand_Bottle_Size_Action__c> bbas = new List<Brand_Bottle_Size_Action__c>();
		for(Action__c action : jsActions){
			Goal__c goal = goalsById.get(action.Goal__c);
			for(Brand_Bottle_Goal__c bbg : goal.Brand_Bottle_Goals__r){
				Brand_Bottle_Size_Action__c bba = new Brand_Bottle_Size_Action__c();
				bba.Action__c = action.Id;
				bba.BrandBottle_Size__c = bbg.BrandBottle_Size__c;
				bbas.add(bba);
			}
		}
		if(bbas.size() > 0){
			insert bbas;
		}
		for(Goal__c parentGoal : goalsById.values()){
			parentGoal.Completed__c = true;
		}
		
		if(isSubmit){
			update goalsById.values();
		}
		
		return true;
	}
	*/
}