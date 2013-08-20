public with sharing class ActionAssignmentController {
	
	public Goal__c dummyGoal				{get;set;}
	public String dummyGoalId				{get;set;}
	public String dummyGoalMode				{get;set;} //'hide', 'view', 'edit'
	public String dummyGoalRecTypeName		{get;set;}
	public List<Goal_Product_Link__c> pls	{get;set;}
	
	public Boolean showCases								{get;set;}
	public Boolean showContentLink							{get;set;}
	public Boolean showTypeOfAd								{get;set;}
	public Boolean showSizeOfAd								{get;set;}
	public Boolean showFeatureType							{get;set;}
	public Boolean showSuggestedPrice						{get;set;}
	public Boolean showAccomplishment						{get;set;}
	public Boolean showProductSamples						{get;set;}
	public Boolean showTrainer								{get;set;}
	public Boolean showTrainingAud							{get;set;}
	public Boolean showTrainingLength						{get;set;}
	public Boolean showNumAttendees							{get;set;}
	public Boolean showTastedProduct						{get;set;}
	public Boolean showShelfSetCriteria						{get;set;}

	public ActionAssignmentController(){
		dummyGoalMode = 'hide';
	}
	
	public void assignDummyViewGoal(){
		dummyGoalMode = 'view';
		loadDummyGoal();
	}
	
	public void assignDummyEditGoal(){
		dummyGoalMode = 'edit';
		loadDummyGoal();
	}
	
	public void loadDummyGoal(){
		showCases			= false;
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
		showShelfSetCriteria = false;
		
		dummyGoal = 
			[SELECT Id,
					Name,
					Long_Name__c,
					OwnerId,
					Priority__c,
					Goal_Type__c,
					RecordTypeId,
					RecordType.Name,
					RecordType.DeveloperName,
					Program__c,
					Program__r.Name,
					Minimum_of_Accounts__c,
					Cases_Displayed__c,
					State__c,
					Comments__c,
					SFA_POS_Items__c,
					Account_Grade__c,
					Location_Grade__c,
					Start_Date__c,
					Due_Date__c,
					Content_Link__c,
					Feature_Type__c,
					Length_of_Training__c,
					Number_of_Attendees__c,
					Product_Sample_s__c,
					Shelf_Set_Criteria__c,
					Size_of_Ad__c,
					Suggested_Price__c,
					Tasted_Product__c,
					Trainer__c,
					Training_Audience__c,
					Type_of_Ad__c,
					(SELECT Id,
							Generic_Brand__c,
							Sub_Brand__c,
							Individual_Brand__c,
							Size__c
					   FROM Goal_Product_Links__r
					)
			   FROM Goal__c
			  WHERE Id = :dummyGoalId
			];
		
		pls = dummyGoal.Goal_Product_Links__r;
			
		dummyGoalRecTypeName = dummyGoal.RecordType.DeveloperName;
		if(dummyGoalRecTypeName == 'Ad_Execution'){
			showFeatureType			= true;
			showSizeOfAd			= true;
			showSuggestedPrice		= true;
			showTypeOfAd			= true;
		} else if(dummyGoalRecTypeName == 'Bar_Promotion_Goals'){
		} else if(dummyGoalRecTypeName == 'Cold_Box_Goals'){
			showSuggestedPrice		= true;
		} else if(dummyGoalRecTypeName == 'Display_Goals'){
			showCases				= true;
			showSuggestedPrice		= true;
		} else if(dummyGoalRecTypeName == 'Distribution_Accts_Sold_Goals'){
			showContentLink			= true;
			showSuggestedPrice		= true;
		} else if(dummyGoalRecTypeName == 'Distribution_POD_Goals'){
			showContentLink			= true;
			showSuggestedPrice		= true;
		} else if(dummyGoalRecTypeName == 'Ease_of_Shop'){
			showShelfSetCriteria 	= true;
			showSuggestedPrice		= true;
		} else if(dummyGoalRecTypeName == 'Feature'){
			showFeatureType			= true;
			showSuggestedPrice		= true;
		} else if(dummyGoalRecTypeName == 'General_Goals'){
		} else if(dummyGoalRecTypeName == 'Menu'){
			showFeatureType			= true;
		} else if(dummyGoalRecTypeName == 'Shelf_Set_Goals'){
			showShelfSetCriteria 	= true;
			showSuggestedPrice		= true;
		} else if(dummyGoalRecTypeName == 'Staff_Training_Goals'){
			showNumAttendees		= true;
			showTastedProduct		= true;
			showTrainer				= true;
			showTrainingAud			= true;
			showTrainingLength		= true;
		} else if(dummyGoalRecTypeName == 'Tasting_Goals'){
			showProductSamples		= true;
		} else if(dummyGoalRecTypeName == 'Volume_Goals'){
			showCases				= true;
			showSuggestedPrice		= true;
		} else if(dummyGoalRecTypeName == 'Window_Display_Goals'){
		}
	}
	
	public void doNothing(){}
	
	public void saveDummyGoal(){
		update dummyGoal;
	}
	
	@RemoteAction
	public static List<Territory__c> getManagerTerritories(){
		List<Territory__c> terrs =
			[SELECT Id,
					Name,
					OwnerId,
					Owner.Name,
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
					OwnerId,
					Owner.Name
			   FROM Territory__c
			  WHERE OwnerId = :UserInfo.getUserId()
		   ORDER BY Name
			];
		return terrs;
	}
	
	@RemoteAction
	public static List<Goal__c> getUserGoals(){
		List<Goal__c> goals =
			[SELECT Id,
					Name,
					Long_Name__c,
					OwnerId,
					Priority__c,
					Goal_Type__c,
					Assignment_Mode__c,
					Assignment_Mode_Detail__c,
					Minimum_of_Accounts__c,
					Cases_Displayed__c,
					Start_Date__c,
					Due_Date__c,
					RecordTypeId,
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
			    AND Priority__c != null
			    AND (Goal_Level__c = 'Manager' OR Goal_Level__c = 'Rep')
		   ORDER BY	RecordType.Name, Start_Date__c, Name
			];
			
		return goals;
	}
	
	@RemoteAction
	public static List<String> getPriorities(){
		List<String> retList = new List<String>();
		List<Schema.PicklistEntry> entries = Goal__c.Priority__c.getDescribe().getPicklistValues();
		for(Integer i = 0; i < entries.size(); i++){
			retList.add(entries[i].getLabel());
		}
		return retList;
	}
	
	@RemoteAction
	public static List<Account> getAccounts(String[] terrIdStrings){
		List<Account> accounts =
			[SELECT Id,
					Name,
					OwnerId,
					Owner.Name,
					RecordType.Name,
					Account_Segmentatiobn__c,
					NABCA_Licensee_Address__c,
					Doing_Business_As__c,
					BillingStreet
			   FROM Account
			  WHERE Territory__c IN :terrIdStrings
			    AND (RecordType.Name = 'On-Premise - Control' 
			     OR  RecordType.Name = 'Off-Premise - Control' 
			     OR  RecordType.Name = 'On Premise' 
			     OR  RecordType.Name = 'Off Premise') 
			    AND Called_On__c = true
		   ORDER BY Name
			];
			
		for(Account acc : accounts){
			if(acc.RecordType.Name == 'On Premise'){
				acc.RecordType.Name = 'On-Premise - Control';
			} else if(acc.RecordType.Name == 'Off Premise'){
				acc.RecordType.Name = 'Off-Premise - Control';
			}
		}
		
		return accounts;
	}
	
	@RemoteAction
	public static Boolean saveActions(String parentGoalId, String accIdString){
		String profileName = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
		String[] accIds = accIdString.split(',');
		
		Goal__c parentGoal = 
			[SELECT Id,
					Name,
					Long_Name__c,
					OwnerId,
					Priority__c,
					Goal_Type__c,
					RecordTypeId,
					RecordType.Name,
					Program__c,
					Cases_Displayed__c,
					State__c,
					Comments__c,
					SFA_POS_Items__c,
					Account_Grade__c,
					Location_Grade__c,
					Start_Date__c,
					Due_Date__c,
					Content_Link__c,
					Feature_Type__c,
					Length_of_Training__c,
					Number_of_Attendees__c,
					Product_Sample_s__c,
					Shelf_Set_Criteria__c,
					Size_of_Ad__c,
					Suggested_Price__c,
					Tasted_Product__c,
					Trainer__c,
					Training_Audience__c,
					Type_of_Ad__c,
					(SELECT Id,
							Product_Classification__c,
							Product_Group__c,
							Report_Brand__c,
							Generic_Brand__c,
							Sub_Brand__c,
							Individual_Brand__c,
							Size__c
					   FROM Goal_Product_Links__r
					)
			   FROM Goal__c
			  WHERE Id = :parentGoalId
			];
		
		Map<String, Id> actionRTIdsByName = new Map<String, Id>();
		for(RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Action__c']){
			actionRTIdsByName.put(rt.Name, rt.Id);
		}
		
		List<Action__c> actsToInsert = new List<Action__c>();
		for(String accId : accIds){
			if(accId != null && accId != ''){
				Action__c act = new Action__c();
				
				act.Goal__c = parentGoal.Id;
				act.Account__c = accId;
				act.OwnerId = parentGoal.OwnerId;
				
				String rtSuffix;
				if(profileName == 'Diageo - Sales Manager' || profileName == 'Diageo - Sales Specialist'){
					rtSuffix = ' - Franchise';
				} else {
					rtSuffix = ' - Control';
				}
				if(parentGoal.RecordType.Name == 'Ad Execution'){
					act.RecordTypeId = actionRTIdsByName.get('Ad Execution' + rtSuffix);
				} else if(parentGoal.RecordType.Name == 'Display Goals'){
					act.RecordTypeId = actionRTIdsByName.get('Display' + rtSuffix);
				} else if(parentGoal.RecordType.Name == 'Distribution (Accts Sold) Goals'){
					act.RecordTypeId = actionRTIdsByName.get('Distribution (Accts Sold)' + rtSuffix);
				} else if(parentGoal.RecordType.Name == 'Distribution (POD) Goals'){
					act.RecordTypeId = actionRTIdsByName.get('Distribution (POD)' + rtSuffix);
				} else if(parentGoal.RecordType.Name == 'Feature Goals'){
					act.RecordTypeId = actionRTIdsByName.get('Feature Execution' + rtSuffix);
				} else if(parentGoal.RecordType.Name == 'General Goals'){
					act.RecordTypeId = actionRTIdsByName.get('General' + rtSuffix);
				} else if(parentGoal.RecordType.Name == 'Cold Box Goals'){
					act.RecordTypeId = actionRTIdsByName.get('Cold Box' + rtSuffix);
				} else if(parentGoal.RecordType.Name == 'Tasting Goals'){
					act.RecordTypeId = actionRTIdsByName.get('Tasting' + rtSuffix);
				} else if(parentGoal.RecordType.Name == 'Menu Goals'){
					act.RecordTypeId = actionRTIdsByName.get('Menu Execution' + rtSuffix);
				} else if(parentGoal.RecordType.Name == 'Shelf Set Goals'){
					act.RecordTypeId = actionRTIdsByName.get('Shelf Set' + rtSuffix);
				} else if(parentGoal.RecordType.Name == 'Bar Promotion Goals'){
					act.RecordTypeId = actionRTIdsByName.get('Bar Promotion' + rtSuffix);
				} else if(parentGoal.RecordType.Name == 'Staff Training Goals'){
					act.RecordTypeId = actionRTIdsByName.get('Staff Training' + rtSuffix);
				} else if(parentGoal.RecordType.Name == 'Volume/QD Goals'){
					act.RecordTypeId = actionRTIdsByName.get('Volume/QD' + rtSuffix);
				} else if(parentGoal.RecordType.Name == 'Window Display Goals'){
					act.RecordTypeId = actionRTIdsByName.get('Window Display' + rtSuffix);
				}
				
				act.Cases_Displayed__c = parentGoal.Cases_Displayed__c;
				act.Comments__c = parentGoal.Comments__c;
				act.Length_of_Training__c = parentGoal.Length_of_Training__c;
				act.Location_Grade__c = parentGoal.Location_Grade__c;
				act.Number_of_Attendees__c = parentGoal.Number_of_Attendees__c;
				act.POS_Items_SFA__c = parentGoal.SFA_POS_Items__c;
				act.Product_Sample_s__c = parentGoal.Product_Sample_s__c;
				act.Shelf_Set_Criteria__c = parentGoal.Shelf_Set_Criteria__c;
				act.Size_of_Ad__c = parentGoal.Size_of_Ad__c;
				act.State__c = parentGoal.State__c;
				act.Suggested_Price__c = parentGoal.Suggested_Price__c;
				act.Tasted_Product__c = parentGoal.Tasted_Product__c;
				act.Trainer__c = parentGoal.Trainer__c;
				act.Training_Audience__c = parentGoal.Training_Audience__c;
				act.Type_of_Ad__c = parentGoal.Type_of_Ad__c;
				
				actsToInsert.add(act);
			}
		}
		
		if(actsToInsert.size() > 0){
			ActionTriggerActions.inActionAssignment = true;
			insert actsToInsert;
		
			if(parentGoal.Goal_Product_Links__r.size() > 0){
				List<Action_Product_Link__c> apls = new List<Action_Product_Link__c>();
				for(Action__c act : actsToInsert){
					for(Goal_Product_Link__c oldGPL : parentGoal.Goal_Product_Links__r){
						Action_Product_Link__c newAPL = new Action_Product_Link__c();
						
						newAPL.Action__c = act.Id;
						newAPL.Product_Classification__c = oldGPL.Product_Classification__c;
						newAPL.Product_Group__c = oldGPL.Product_Group__c;
						newAPL.Report_Brand__c = oldGPL.Report_Brand__c;
						newAPL.Generic_Brand__c = oldGPL.Generic_Brand__c;
						newAPL.Sub_Brand__c = oldGPL.Sub_Brand__c;
						newAPL.Individual_Brand__c = oldGPL.Individual_Brand__c;
						newAPL.Size__c = oldGPL.Size__c;
						
						apls.add(newAPL);
					}
				}
				insert apls;
			}
		}
		
		parentGoal.Completed__c = true;
		update parentGoal;
		
		return true;
	}

}