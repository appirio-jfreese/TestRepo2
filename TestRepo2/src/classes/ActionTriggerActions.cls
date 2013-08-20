global without sharing class ActionTriggerActions {
	
	public static Boolean inActionAssignment = false;
	public static Boolean recountCompleteActions = true;
	public static Set<Id> dupeFuturePreventerSet = new Set<Id>();
	
	public static void checkGoalParentage(List<Action__c> actions){
		if(inActionAssignment == false){
			checkToCopyLinks(actions);
		}
		
		List<Action__c> orphans = new List<Action__c>();
		for(Action__c act : actions){
			if(act.Goal__c == null && act.Account__c != null){
				orphans.add(act);
			}
		}
		if(orphans.size() > 0){
			findOrCreateParents(orphans);
		}
	}
	
	public static void checkGoalParentage(Map<Id, Action__c> oldMap, List<Action__c> actions){
		List<Action__c> orphans = new List<Action__c>();
		List<Action__c> actionsNewlyParented = new List<Action__c>();
		List<Action__c> actionsWithOldAPLsToDelete = new List<Action__c>();
		
		for(Action__c act : actions){
			Action__c old = oldMap.get(act.Id);
			if(old.Goal__c == null && act.Goal__c != null){
				actionsNewlyParented.add(act);
				actionsWithOldAPLsToDelete.add(act);
			} else if(old.Goal__c != null && act.Goal__c == null){
				if(act.Account__c != null){
					orphans.add(act);
				}
			} else if(old.Goal__c != act.Goal__c){
				actionsNewlyParented.add(act);
				actionsWithOldAPLsToDelete.add(act);
			}
		}
		
		if(actionsWithOldAPLsToDelete.size() > 0){
			deleteAPLsFromActions(actionsWithOldAPLsToDelete);
		}
		if(actionsNewlyParented.size() > 0){
			checkToCopyLinks(actionsNewlyParented);
		}
		if(orphans.size() > 0){
			findOrCreateParents(orphans);
		}
	}
	
	private static void deleteAPLsFromActions(List<Action__c> actions){
		List<Action_Product_Link__c> apls = [SELECT Id FROM Action_Product_Link__c WHERE Action__c IN :actions];
		if(apls.size() > 0){
			delete apls;
		}
	}
	
	private static void checkToCopyLinks(List<Action__c> actions){
		actions = [SELECT Id,
						  Product_Link_Count__c,
						  Goal__c,
						  Goal__r.Product_Link_Count__c
					 FROM Action__c
					WHERE Id IN :actions
				  ];
		List<Action__c> actionsMissingLinks = new List<Action__c>();
		for(Action__c act : actions){
			if(act.Product_Link_Count__c == 0 && act.Goal__c != null && act.Goal__r.Product_Link_Count__c > 0){
				actionsMissingLinks.add(act);
			}
		}
		if(actionsMissingLinks.size() > 0){
			copyLinksToActions(actionsMissingLinks);
		}
	}
		
	private static void copyLinksToActions(List<Action__c> actions){	
		Set<Id> goalIds = new Set<Id>();
		for(Action__c act : actions){
			goalIds.add(act.Goal__c);
		}
		
		Map<Id, Goal__c> goalsById = new Map<Id, Goal__c>([
			SELECT Id,
				   Cases_Displayed__c,
				   Comments__c,
				   Length_of_Training__c,
				   Location_Grade__c,
				   Number_of_Attendees__c,
				   SFA_POS_Items__c,
				   Product_Sample_s__c,
				   Shelf_Set_Criteria__c,
				   Size_of_Ad__c,
				   State__c,
				   Suggested_Price__c,
				   Tasted_Product__c,
				   Trainer__c,
				   Training_Audience__c,
				   Type_of_Ad__c,
				   (SELECT Id,
				   		   Product_Classification__c,
						   Product_Group__c,
						   Generic_Brand__c,
						   Sub_Brand__c,
						   Individual_Brand__c,
						   Size__c,
						   Report_Brand__c
					  FROM Goal_Product_Links__r)
			  FROM Goal__c
			 WHERE Id IN :goalIds]);
		
		List<Action_Product_Link__c> aplsToInsert = new List<Action_Product_Link__c>();
		for(Action__c act : actions){
			Goal__c goal = goalsById.get(act.Goal__c);
			
			act.Cases_Displayed__c = goal.Cases_Displayed__c;
			act.Comments__c = goal.Comments__c;
			act.Length_of_Training__c = goal.Length_of_Training__c;
			act.Location_Grade__c = goal.Location_Grade__c;
			act.Number_of_Attendees__c = goal.Number_of_Attendees__c;
			act.POS_Items_SFA__c = goal.SFA_POS_Items__c;
			act.Product_Sample_s__c = goal.Product_Sample_s__c;
			act.Shelf_Set_Criteria__c = goal.Shelf_Set_Criteria__c;
			act.Size_of_Ad__c = goal.Size_of_Ad__c;
			act.State__c = goal.State__c;
			act.Suggested_Price__c = goal.Suggested_Price__c;
			act.Tasted_Product__c = goal.Tasted_Product__c;
			act.Trainer__c = goal.Trainer__c;
			act.Training_Audience__c = goal.Training_Audience__c;
			act.Type_of_Ad__c = goal.Type_of_Ad__c;
			
			for(Goal_Product_Link__c gpl : goal.Goal_Product_Links__r){
				Action_Product_Link__c apl = new Action_Product_Link__c();
				
				apl.Action__c = act.Id;
				apl.Product_Classification__c = gpl.Product_Classification__c;
				apl.Product_Group__c = gpl.Product_Group__c;
				apl.Generic_Brand__c = gpl.Generic_Brand__c;
				apl.Sub_Brand__c = gpl.Sub_Brand__c;
				apl.Individual_Brand__c = gpl.Individual_Brand__c;
				apl.Size__c = gpl.Size__c;
				apl.Report_Brand__c = gpl.Report_Brand__c;
				
				aplsToInsert.add(apl);
			}
		}
		
		insert aplsToInsert;
		update actions;
	}
	
	private static void findOrCreateParents(List<Action__c> actions){
		actions = [SELECT Id,
						  RecordType.DeveloperName,
						  RecordType.Name,
						  Account__r.RecordType.DeveloperName,
						  OwnerId,
						  Account__r.Territory__r.State__c
					 FROM Action__c
					WHERE Id IN :actions
				  ];
	
		Map<String, String> goalRTsByActionRTs = new Map<String, String>();
		goalRTsByActionRTs.put('Ad_Execution', 'Ad_Execution');
		goalRTsByActionRTs.put('Ad_Execution_Franchise', 'Ad_Execution');
		goalRTsByActionRTs.put('Bar_Promotion_Control', 'Bar_Promotion_Goals');
		goalRTsByActionRTs.put('Bar_Promotion_Franchise', 'Bar_Promotion_Goals');
		goalRTsByActionRTs.put('Cold_Box_Control', 'Cold_Box_Goals');
		goalRTsByActionRTs.put('Cold_Box_Franchise', 'Cold_Box_Goals');
		goalRTsByActionRTs.put('Display_Control', 'Display_Goals');
		goalRTsByActionRTs.put('Display_Franchise', 'Display_Goals');
		goalRTsByActionRTs.put('Display', 'Display_Goals');
		goalRTsByActionRTs.put('Distribution_POD_Control', 'Distribution_POD_Goals');
		goalRTsByActionRTs.put('Distribution_POD_Franchise', 'Distribution_POD_Goals');
		goalRTsByActionRTs.put('Distribution_Accts_Sold_Control', 'Distribution_Accts_Sold_Goals');
		goalRTsByActionRTs.put('Distribution_Accts_Sold_Franchise', 'Distribution_Accts_Sold_Goals');
		goalRTsByActionRTs.put('Feature_Execution', 'Feature');
		goalRTsByActionRTs.put('Feature_Execution_Franchise', 'Feature');
		goalRTsByActionRTs.put('General_Control', 'General_Goals');
		goalRTsByActionRTs.put('General_Franchise', 'General_Goals');
		goalRTsByActionRTs.put('Menu_Execution', 'Menu');
		goalRTsByActionRTs.put('Menu_Execution_Franchise', 'Menu');
		goalRTsByActionRTs.put('Shelf_Set', 'Shelf_Set_Goals');
		goalRTsByActionRTs.put('Shelf_Set_Franchise', 'Shelf_Set_Goals');
		goalRTsByActionRTs.put('Staff_Training', 'Staff_Training_Goals');
		goalRTsByActionRTs.put('Staff_Training_Franchise', 'Staff_Training_Goals');
		goalRTsByActionRTs.put('Tasting_Control', 'Tasting_Goals');
		goalRTsByActionRTs.put('Tasting_Franchise', 'Tasting_Goals');
		goalRTsByActionRTs.put('Training', 'Staff_Training_Goals');
		goalRTsByActionRTs.put('Training_Franchise', 'Staff_Training_Goals');
		goalRTsByActionRTs.put('Volume_Control', 'Volume_Goals');
		goalRTsByActionRTs.put('Volume_Control_Franchise', 'Volume_Goals');
		goalRTsByActionRTs.put('Window_Display', 'Window_Display_Goals');
		goalRTsByActionRTs.put('Window_Display_Franchise', 'Window_Display_Goals');
	
		Map<String, String> goalPremsByActionPrems = new Map<String, String>();
		goalPremsByActionPrems.put('On_Premise_Control', 'On-Premise - Control');
		goalPremsByActionPrems.put('Off_Premise_Control', 'Off-Premise - Control');
		goalPremsByActionPrems.put('On_Premise', 'On-Premise');
		goalPremsByActionPrems.put('Off_Premise', 'Off-Premise');
		
		Set<String> goalRTDevNames = new Set<String>();
		Set<String> goalTypes = new Set<String>();
		Set<Id> goalIds = new Set<Id>();
		
		for(Action__c act : actions){
			String goalRTDevName = goalRTsByActionRTs.get(act.RecordType.DeveloperName);
			if(goalRTDevName == null){
				goalRTDevName = 'General_Goals';
			}
			goalRTDevNames.add(goalRTDevName);
			
			goalTypes.add(goalPremsByActionPrems.get(act.Account__r.RecordType.DeveloperName));
			
			goalIds.add(act.OwnerId);
		}
		
		Date startOfMonth = Date.today().toStartOfMonth();
		Date endOfMonth = startOfMonth.addMonths(1).addDays(-1);
		
		//rec type, genericness, premise, rep, due date
		List<Goal__c> possibleParents =
			[SELECT Id,
					RecordType.DeveloperName,
					Goal_Type__c,
					Goal_For__c,
					Minimum_of_Accounts__c
			   FROM Goal__c
			  WHERE RecordType.DeveloperName IN :goalRTDevNames
			    AND Name LIKE '%Rep Goal%'
			    AND Goal_Type__c IN :goalTypes
			    AND Goal_For__c IN :goalIds
			    AND Due_Date__c = :endOfMonth
			];
			
		Map<String, Goal__c> possibleParentsByKey = new Map<String, Goal__c>();
		for(Goal__c goal : possibleParents){
			String key = goal.RecordType.DeveloperName;
			key += '|' + goal.Goal_Type__c;
			key += '|' + goal.Goal_For__c;
			possibleParentsByKey.put(key, goal);
		}
		
		List<RecordType> goalRTs = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Goal__c'];
		Map<Id, RecordType> goalRTsById = new Map<Id, RecordType>(goalRTs);
		Map<String, Id> goalRTIdsByDevName = new Map<String, Id>();
		for(RecordType rt : goalRTs){
			goalRTIdsByDevName.put(rt.DeveloperName, rt.Id);
		}
		
		Map<Action__c, Goal__c> newGoalParentsByChildAction = new Map<Action__c, Goal__c>();
		List<Goal__c> goalsToInsert = new List<Goal__c>();
		Map<Id, Goal__c> goalsToUpdateById = new Map<Id, Goal__c>();
		
		for(Action__c act : actions){			
			String goalRTDevName = goalRTsByActionRTs.get(act.RecordType.DeveloperName);
			if(goalRTDevName == null){
				goalRTDevName = 'General_Goals';
			}
			String key = goalRTDevName;
			key += '|' + goalPremsByActionPrems.get(act.Account__r.RecordType.DeveloperName);
			key += '|' + act.OwnerId;
			
			String goalType = goalPremsByActionPrems.get(act.Account__r.RecordType.DeveloperName);
			if(goalType != null){
				Goal__c goal = possibleParentsByKey.get(key);
				if(goal == null){
					goal = new Goal__c();
					goal.RecordTypeId = goalRTIdsByDevName.get(goalRTDevName);
					goal.Goal_Type__c = goalType;
					goal.Goal_For__c = act.OwnerId;
					goal.OwnerId = act.OwnerId;
					goal.Start_Date__c = startOfMonth;
					goal.Due_Date__c = endOfMonth;
					goal.Completed__c = true;
					goal.Goal_Level__c = 'Rep';
					goal.Priority__c = 'Local';
					goal.State__c = act.Account__r.Territory__r.State__c;
					
					String name = goalRTsById.get(goal.RecordTypeId).Name + ' - Rep Goal - ';
					if(goal.Goal_Type__c != null){
						name += goal.Goal_Type__c.split('-')[0];
					}
					if(act.RecordType.Name.contains('Control')){
						name += ' - Control';
					} else {
						name += ' - Franchise';
					}
					goal.Name = name;
					goal.Long_Name__c = name;
					
					goal.Completed__c = true;
					goal.Goal_Level__c = 'Rep';
					goal.Priority__c = 'Local';
					//goal.Minimum_of_Accounts__c = 1;
					
					goalsToInsert.add(goal);
					possibleParentsByKey.put(key, goal);
				} else {
					act.Goal__c = goal.Id;
					//goal.Minimum_of_Accounts__c++;
					
					if(goal.Id != null && goalsToUpdateById.get(goal.Id) == null){
						goalsToUpdateById.put(goal.Id, goal);
					}
				}
				newGoalParentsByChildAction.put(act, goal);
			}
		}
		
		if(goalsToInsert.size() > 0){
			insert goalsToInsert;
		}
		
		if(goalsToUpdateById.size() > 0){
			update goalsToUpdateById.values();
		}
		
		for(Action__c act : newGoalParentsByChildAction.keyset()){
			act.Goal__c = newGoalParentsByChildAction.get(act).Id;
			act.RecordTypeId = null;
		}
		List<Action__c> actsToUpdate = new List<Action__c>();
		actsToUpdate.addAll(newGoalParentsByChildAction.keyset());
		update actsToUpdate;
	}
	
	public static void handleCompletedActions(List<Action__c> actions){
		Set<Id> goalIds = new Set<Id>();
		for(Action__c act : actions){
			if(act.Goal__c != null && act.Status__c == 'Closed - Complete'){
				goalIds.add(act.Goal__c);
			}
		}
		if(goalIds.size() > 0){
			prepareGoalUpdate(goalIds);
		}
	}
	
	public static void handleCompletedActions(Map<Id, Action__c> oldMap, List<Action__c> actions){
		List<Action__c> validActions = new List<Action__c>();
		Set<Id> goalIds = new Set<Id>();
		for(Action__c act : actions){
			Action__c matchingOld = oldMap.get(act.Id);
			if(matchingOld.Status__c != 'Closed - Complete' && act.Status__c == 'Closed - Complete'){
				validActions.add(act);
			}
			if(act.Goal__c != null && (act.Status__c != matchingOld.Status__c || act.Goal__c != matchingOld.Goal__c)){
				goalIds.add(act.Goal__c);
			}
			if(act.Goal__c != matchingOld.Goal__c && matchingOld.Goal__c != null){
				goalIds.add(matchingOld.Goal__c);
			}
			if(act.Product_Link_Count__c != matchingOld.Product_Link_Count__c){
				goalIds.add(act.Goal__c);
			}
		}
		if(validActions.size() > 0){
			validateProductLinks(validActions);
		}
		if(goalIds.size() > 0){
			prepareGoalUpdate(goalIds);
		}
	}
	
	public static void handleDeletedActions(List<Action__c> actions){
		Set<Id> goalIds = new Set<Id>();
		for(Action__c act : actions){
			if(act.Goal__c != null && act.Status__c == 'Closed - Complete'){
				goalIds.add(act.Goal__c);
			}
		}
		if(goalIds.size() > 0){
			prepareGoalUpdate(goalIds);
		}
	}
	
	public static void validateProductLinks(List<Action__c> actions){
		Map<Id, Action__c> actsById = new Map<Id, Action__c>(actions);
		List<Action_Product_Link__c> apls =
			[SELECT Id,
					Action__c,
					Individual_Brand__c,
					Size__c
			   FROM Action_Product_Link__c
			  WHERE Action__c IN :actions
			];
		
		for(Action_Product_Link__c apl : apls){
			if(apl.Individual_Brand__c == null || apl.Size__c == null){
				Action__c parentAct = actsById.get(apl.Action__c);
				parentAct.addError(' All Brands for this Action must have Individual Brand and Size values before you can mark it Closed - Complete. Please edit the Action Brands below and try again.');
			}
		}
	}
	
	public static void prepareGoalUpdate(Set<Id> goalIds){
		List<Goal__c> goals =
			[SELECT Id,
					Parent_Goal__c,
					Parent_Goal__r.Parent_Goal__c
			   FROM Goal__c
			  WHERE Id IN :goalIds
			];
		
		if(goals.size() > 0){
			Set<Id> allIds = new Set<Id>();
			for(Goal__c goal : goals){
				allIds.add(goal.Id);
				if(goal.Parent_Goal__c != null){
					allIds.add(goal.Parent_Goal__c);
					if(goal.Parent_Goal__r.Parent_Goal__c != null){
						allIds.add(goal.Parent_Goal__r.Parent_Goal__c);
					}
				}
				/*if(!dupeFuturePreventerSet.contains(goal.Id)){
					dupeFuturePreventerSet.add(goal.Id);
					allIds.add(goal.Id);
				}
				if(goal.Parent_Goal__c != null){
					if(!dupeFuturePreventerSet.contains(goal.Parent_Goal__c)){
						dupeFuturePreventerSet.add(goal.Parent_Goal__c);
						allIds.add(goal.Parent_Goal__c);
					}
				}
				if(goal.Parent_Goal__r.Parent_Goal__c != null){
					if(!dupeFuturePreventerSet.contains(goal.Parent_Goal__r.Parent_Goal__c)){
						dupeFuturePreventerSet.add(goal.Parent_Goal__r.Parent_Goal__c);
						allIds.add(goal.Parent_Goal__r.Parent_Goal__c);
					}
				}*/
			}
			System.assertNotEquals(0, allIds.size());
			futurePerformGoalUpdate(allIds);
		}
	}
	
	public static void performGoalUpdate(Set<Id> allIds){
		if(recountCompleteActions){
			countCompletedActionsForGoals(allIds);
		}
		createGBRIsForGoals(allIds);
		createGARIsForGoals(allIds);
	}
	
	@future
	public static void futurePerformGoalUpdate(Set<Id> allIds){
		performGoalUpdate(allIds);
	}
	
	@future
	public static void futureCountCompletedActionsForGoals(Set<Id> allIds){
		countCompletedActionsForGoals(allIds);
	}
	
	@future
	public static void futureCreateGBRIsForGoals(Set<Id> allIds){
		createGBRIsForGoals(allIds);
	}
	
	@future
	public static void futureCreateGARIsForGoals(Set<Id> allIds){
		createGARIsForGoals(allIds);
	}
	
	public static void countCompletedActionsForGoals(Set<Id> allIds){
		List<Goal__c> allGoals =
			[SELECT Id,
					Parent_Goal__c,
					Parent_Goal__r.Parent_Goal__c,
					RecordType.DeveloperName,
					(SELECT Id,
							Cases_Displayed__c,
							Product_Link_Count__c
					   FROM Actions__r
					  WHERE Status__c = 'Closed - Complete'
					),
					(SELECT Id,
							Goal__c,
							Level__c,
							Label__c,
							Product_Classification__c,
							Product_Group__c,
							Generic_Brand__c,
							Sub_Brand__c,
							Individual_Brand__c,
							Size__c,
							Report_Brand__c,
							Ind_Brand_Size__c,
							API_Level__c
					   FROM Goal_Brand_Report_Items__r
					)
			   FROM Goal__c
			   WHERE Id IN :allIds
			   OR Parent_Goal__c IN :allIds
			   OR Parent_Goal__r.Parent_Goal__c IN :allIds
			];
			
		Set<Id> allActionIds = new Set<Id>();
		gbrisByKey = new Map<String, Goal_Brand_Report_Item__c>();
		
		Map<Id, Map<Id,Integer>> actionCompletesByGoalIdBySourceId = new Map<Id, Map<Id, Integer>>();
		Map<Id, Map<Id,Integer>> actionCasesByGoalIdBySourceId = new Map<Id, Map<Id, Integer>>();
		
		for(Goal__c goal : allGoals){
			Integer count = 0;
			Integer cases = 0;
			
			Boolean shouldCountPODStyle = false;
			if(goal.RecordType.DeveloperName == 'Distribution_POD_Goals'){
				shouldCountPODStyle = true;
			}
			
			for(Action__c act : goal.Actions__r){
				allActionIds.add(act.Id);
				if(act != null && act.Cases_Displayed__c != null){
					cases += Integer.valueOf(act.Cases_Displayed__c);
				}
				if(shouldCountPODStyle){
					count += Integer.valueOf(act.Product_Link_Count__c);
				} else {
					count++;
				}
			}
			
			for(Goal_Brand_Report_Item__c gbri : goal.Goal_Brand_Report_Items__r){
				gbri.Completed_Actions__c = 0;
				if(gbri.Level__c == 'Product Classification'){
					gbrisByKey.put(goal.Id + '|Product_Classification__c|' + gbri.Product_Classification__c, gbri);
				} else if(gbri.Level__c == 'Product Group'){
					gbrisByKey.put(goal.Id + '|Product_Group__c|' + gbri.Product_Group__c, gbri);
				} else if(gbri.Level__c == 'Generic Brand'){
					gbrisByKey.put(goal.Id + '|Generic_Brand__c|' + gbri.Generic_Brand__c, gbri);
				} else if(gbri.Level__c == 'Sub Brand'){
					gbrisByKey.put(goal.Id + '|Sub_Brand__c|' + gbri.Sub_Brand__c, gbri);
				} else if(gbri.Level__c == 'Individual Brand'){
					gbrisByKey.put(goal.Id + '|Individual_Brand__c|' + gbri.Individual_Brand__c, gbri);
				} else if(gbri.Level__c == 'Size'){
					gbrisByKey.put(goal.Id + '|Size__c|' + gbri.Size__c, gbri);
				} else if(gbri.Level__c == 'Report Brand'){
					gbrisByKey.put(goal.Id + '|Report_Brand__c|' + gbri.Report_Brand__c, gbri);
				} else if(gbri.Level__c == 'Ind. Brand / Size'){
					gbrisByKey.put(goal.Id + '|Ind_Brand_Size__c|' + gbri.Ind_Brand_Size__c, gbri);
				}
			}
			
			addToMap(actionCompletesByGoalIdBySourceId, goal.Id, goal.Id, count);
			addToMap(actionCasesByGoalIdBySourceId, goal.Id, goal.Id, cases);
			
			if(goal.Parent_Goal__c != null){
				addToMap(actionCompletesByGoalIdBySourceId, goal.Parent_Goal__c, goal.Id, count);
				addToMap(actionCasesByGoalIdBySourceId, goal.Parent_Goal__c, goal.Id, cases);
			}
			
			if(goal.Parent_Goal__r.Parent_Goal__c != null){
				addToMap(actionCompletesByGoalIdBySourceId, goal.Parent_Goal__r.Parent_Goal__c, goal.Id, count);
				addToMap(actionCasesByGoalIdBySourceId, goal.Parent_Goal__r.Parent_Goal__c, goal.Id, cases);
			}
		}
		
		for(Goal__c goal : allGoals){
			Integer count = 0;
			Integer cases = 0;
			for(Integer i : actionCompletesByGoalIdBySourceId.get(goal.Id).values()){
				count += i;
			}
			for(Integer i : actionCasesByGoalIdBySourceId.get(goal.Id).values()){
				cases += i;
			}
			goal.Action_Complete__c = count;
			goal.Cases_Complete__c = cases;
		}
		
		update allGoals;
	}
	
	public static void createGBRIsForGoals(Set<Id> allIds){
		List<Goal__c> allGoals =
			[SELECT Id,
					Parent_Goal__c,
					Parent_Goal__r.Parent_Goal__c,
					RecordType.DeveloperName,
					(SELECT Id,
							Cases_Displayed__c,
							Product_Link_Count__c
					   FROM Actions__r
					  WHERE Status__c = 'Closed - Complete'
					),
					(SELECT Id,
							Goal__c,
							Level__c,
							Label__c,
							Product_Classification__c,
							Product_Group__c,
							Generic_Brand__c,
							Sub_Brand__c,
							Individual_Brand__c,
							Size__c,
							Report_Brand__c,
							Ind_Brand_Size__c,
							API_Level__c
					   FROM Goal_Brand_Report_Items__r
					)
			   FROM Goal__c
			   WHERE Id IN :allIds
			   OR Parent_Goal__c IN :allIds
			   OR Parent_Goal__r.Parent_Goal__c IN :allIds
			];
		
		Set<Id> allActionIds = new Set<Id>();
		gbrisByKey = new Map<String, Goal_Brand_Report_Item__c>();
		
		for(Goal__c goal : allGoals){
			for(Action__c act : goal.Actions__r){
				allActionIds.add(act.Id);
			}
			for(Goal_Brand_Report_Item__c gbri : goal.Goal_Brand_Report_Items__r){
				gbri.Completed_Actions__c = 0;
				if(gbri.Level__c == 'Product Classification'){
					gbrisByKey.put(goal.Id + '|Product_Classification__c|' + gbri.Product_Classification__c, gbri);
				} else if(gbri.Level__c == 'Product Group'){
					gbrisByKey.put(goal.Id + '|Product_Group__c|' + gbri.Product_Group__c, gbri);
				} else if(gbri.Level__c == 'Generic Brand'){
					gbrisByKey.put(goal.Id + '|Generic_Brand__c|' + gbri.Generic_Brand__c, gbri);
				} else if(gbri.Level__c == 'Sub Brand'){
					gbrisByKey.put(goal.Id + '|Sub_Brand__c|' + gbri.Sub_Brand__c, gbri);
				} else if(gbri.Level__c == 'Individual Brand'){
					gbrisByKey.put(goal.Id + '|Individual_Brand__c|' + gbri.Individual_Brand__c, gbri);
				} else if(gbri.Level__c == 'Size'){
					gbrisByKey.put(goal.Id + '|Size__c|' + gbri.Size__c, gbri);
				} else if(gbri.Level__c == 'Report Brand'){
					gbrisByKey.put(goal.Id + '|Report_Brand__c|' + gbri.Report_Brand__c, gbri);
				} else if(gbri.Level__c == 'Ind. Brand / Size'){
					gbrisByKey.put(goal.Id + '|Ind_Brand_Size__c|' + gbri.Ind_Brand_Size__c, gbri);
				}
			}
		}
		
		List<Action__c> completedActs =
			[SELECT Id,
					Goal__c,
					Goal__r.Parent_Goal__c,
					Goal__r.Parent_Goal__r.Parent_Goal__c,
					Goal__r.RecordType.DeveloperName,
					(SELECT Id,
							Product_Classification__c,
							Product_Group__c,
							Generic_Brand__c,
							Sub_Brand__c,
							Individual_Brand__c,
							Size__c,
							Report_Brand__c,
							Ind_Brand_Size__c
					   FROM Action_Product_Links__r
					)
			   FROM Action__c
			  WHERE Id IN :allActionIds
			    AND Product_Link_Count__c > 0
			];
			
		String key;
		Goal_Brand_Report_Item__c gbri;
		levelGoalKeys = new Set<String>();
		if(completedActs.size() > 0){
			Boolean shouldCountPODStyle = completedActs[0].Goal__r.RecordType.DeveloperName == 'Distribution_POD_Goals';
			
			for(Action__c act : completedActs){
				keysAlreadyUpdatedForThisAction = new Set<String>();
				
				for(Action_Product_Link__c apl : act.Action_Product_Links__r){
					buildGBRI(apl, act.Goal__c, 'Product_Classification__c', shouldCountPODStyle);
					buildGBRI(apl, act.Goal__c, 'Product_Group__c', shouldCountPODStyle);
					buildGBRI(apl, act.Goal__c, 'Generic_Brand__c', shouldCountPODStyle);
					buildGBRI(apl, act.Goal__c, 'Sub_Brand__c', shouldCountPODStyle);
					buildGBRI(apl, act.Goal__c, 'Individual_Brand__c', shouldCountPODStyle);
					buildGBRI(apl, act.Goal__c, 'Size__c', shouldCountPODStyle);
					buildGBRI(apl, act.Goal__c, 'Report_Brand__c', shouldCountPODStyle);
					buildGBRI(apl, act.Goal__c, 'Ind_Brand_Size__c', shouldCountPODStyle);
					if(act.Goal__r.Parent_Goal__c != null){
						buildGBRI(apl, act.Goal__r.Parent_Goal__c, 'Product_Classification__c', shouldCountPODStyle);
						buildGBRI(apl, act.Goal__r.Parent_Goal__c, 'Product_Group__c', shouldCountPODStyle);
						buildGBRI(apl, act.Goal__r.Parent_Goal__c, 'Generic_Brand__c', shouldCountPODStyle);
						buildGBRI(apl, act.Goal__r.Parent_Goal__c, 'Sub_Brand__c', shouldCountPODStyle);
						buildGBRI(apl, act.Goal__r.Parent_Goal__c, 'Individual_Brand__c', shouldCountPODStyle);
						buildGBRI(apl, act.Goal__r.Parent_Goal__c, 'Size__c', shouldCountPODStyle);
						buildGBRI(apl, act.Goal__r.Parent_Goal__c, 'Report_Brand__c', shouldCountPODStyle);
						buildGBRI(apl, act.Goal__r.Parent_Goal__c, 'Ind_Brand_Size__c', shouldCountPODStyle);
						if(act.Goal__r.Parent_Goal__r.Parent_Goal__c != null){
							buildGBRI(apl, act.Goal__r.Parent_Goal__r.Parent_Goal__c, 'Product_Classification__c', shouldCountPODStyle);
							buildGBRI(apl, act.Goal__r.Parent_Goal__r.Parent_Goal__c, 'Product_Group__c', shouldCountPODStyle);
							buildGBRI(apl, act.Goal__r.Parent_Goal__r.Parent_Goal__c, 'Generic_Brand__c', shouldCountPODStyle);
							buildGBRI(apl, act.Goal__r.Parent_Goal__r.Parent_Goal__c, 'Sub_Brand__c', shouldCountPODStyle);
							buildGBRI(apl, act.Goal__r.Parent_Goal__r.Parent_Goal__c, 'Individual_Brand__c', shouldCountPODStyle);
							buildGBRI(apl, act.Goal__r.Parent_Goal__r.Parent_Goal__c, 'Size__c', shouldCountPODStyle);
							buildGBRI(apl, act.Goal__r.Parent_Goal__r.Parent_Goal__c, 'Report_Brand__c', shouldCountPODStyle);
							buildGBRI(apl, act.Goal__r.Parent_Goal__r.Parent_Goal__c, 'Ind_Brand_Size__c', shouldCountPODStyle);
						}
					}
				}
			}
		}
		
		List<Goal_Brand_Report_Item__c> gbrisToUpsert = new List<Goal_Brand_Report_Item__c>();
		List<Goal_Brand_Report_Item__c> gbrisToDelete = new List<Goal_Brand_Report_Item__c>();
		for(Goal_Brand_Report_Item__c gbri2 : gbrisByKey.values()){
			if(gbri2.Completed_Actions__c > 0){
				gbrisToUpsert.add(gbri2);
			} else if(levelGoalKeys.contains(gbri2.Goal__c + '|' + gbri2.API_Level__c)){
				gbrisToDelete.add(gbri2);
			}
		}
		upsert gbrisToUpsert;
		try {
			delete gbrisToDelete;
		} catch (Exception e){
			
		}
	}
	
	public static Map<String, Goal_Brand_Report_Item__c> gbrisByKey {get;set;}
	public static Set<String> keysAlreadyUpdatedForThisAction {get;set;}
	public static Set<String> levelGoalKeys {get;set;}
	
	public static void buildGBRI(Action_Product_Link__c apl, Id goalId, String fieldName, Boolean shouldCountPODStyle){
		if(apl.get(fieldName) != null){
			levelGoalKeys.add(goalId + '|' + fieldName);
			
			String key = goalId + '|' + fieldName + '|' + apl.get(fieldName);
			Goal_Brand_Report_Item__c gbri = gbrisByKey.get(key);
			if(gbri == null){
				gbri = new Goal_Brand_Report_Item__c();
				gbri.Goal__c = goalId;
				gbri.put(fieldName, apl.get(fieldName));
				gbri.Completed_Actions__c = 0;
			}
			if(shouldCountPODStyle){
				gbri.Completed_Actions__c++;
				gbrisByKey.put(key, gbri);
			} else if(keysAlreadyUpdatedForThisAction.contains(key) == false){
				keysAlreadyUpdatedForThisAction.add(key);
				gbri.Completed_Actions__c++;
				gbrisByKey.put(key, gbri);
			}
		}
	}
	
	public static void addToMap(Map<Id, Map<Id, Integer>> theMap, Id mainId, Id sourceId, Integer value){
		if(theMap.get(mainId) == null){
			theMap.put(mainId, new Map<Id, Integer>());
		}
		if(value > 0){
			theMap.get(mainId).put(sourceId, value);
		}
	}
	
	public static void createGARIsForGoals(Set<Id> allIds){
		List<Goal__c> allGoals =
			[SELECT Id,
					Parent_Goal__c,
					Parent_Goal__r.Parent_Goal__c,
					(SELECT Id,
							Account__c,
							Account__r.State__c,
							Account__r.OwnerId,
							Account__r.Account_Segmentatiobn__c,
							Account__r.Primary_Demographic__c,
							Account__r.RecordType.Name
					   FROM Actions__r
					  WHERE Status__c = 'Closed - Complete'
					    AND Account__c != null
					    AND Account__r.RecordType.Name LIKE '%Premise%'
					    AND ((Account__r.State__c != null AND Account__r.Account_Segmentatiobn__c != null)
					    OR   (Account__r.State__c != null AND Account__r.Primary_Demographic__c != null)
					    OR   (Account__r.OwnerId != null AND Account__r.Account_Segmentatiobn__c != null)
					    OR   (Account__r.OwnerId != null AND Account__r.Primary_Demographic__c != null))
					),
					(SELECT Id,
							Goal__c,
							Account__c
					   FROM Goal_Account_Report_Items__r
					)
			   FROM Goal__c
			   WHERE (Id IN :allIds
			   OR Parent_Goal__c IN :allIds
			   OR Parent_Goal__r.Parent_Goal__c IN :allIds)
			   AND Action_Complete__c > 0
			];
		
		Set<Id> stateAndUserIds = new Set<Id>();
		for(Goal__c goal : allGoals){
			for(Action__c act : goal.Actions__r){
				stateAndUserIds.add(act.Account__r.State__c);
				stateAndUserIds.add(act.Account__r.OwnerId);
			}
		}
		List<State_User_Report_Item__c> suris =
			[SELECT Id,
					Key__c,
					Accounts__c,
					Called_On_Accounts__c
			   FROM State_User_Report_Item__c
			  WHERE State__c IN :stateAndUserIds
			     OR User__c IN :stateAndUserIds
			];
		Map<String, Id> suriIDsByKey = new Map<String, Id>();
		
		for(State_User_Report_Item__c suri : suris){
			suriIDsByKey.put(suri.Key__c, suri.Id);
		}
		
		Map<String, Goal_Account_Report_Item__c> garisByKey = new Map<String, Goal_Account_Report_Item__c>();
		Id goalId;
		String stateId;
		String userId;
		String key;
		Goal_Account_Report_Item__c gari;
		Id stateASSURIId;
		Id statePDSURIId;
		Id userASSURIId;
		Id userPDSURIId;
		String prem;
		
		for(Goal__c goal : allGoals){
			for(Goal_Account_Report_Item__c gari2 : goal.Goal_Account_Report_Items__r){
				gari2.Completed_Actions__c = 0;
				garisByKey.put(gari2.Goal__c + '|' + gari2.Account__c, gari2);
			}
			for(Action__c act : goal.Actions__r){
				if(act.Account__r.RecordType.Name == 'On Premise' || act.Account__r.RecordType.Name == 'On-Premise - Control'){
					prem = 'On';
				} else {
					prem = 'Off';
				}
				stateASSURIId = null;
				statePDSURIId = null;
				userASSURIId = null;
				userPDSURIId = null;
				
				if(act.Account__r.State__c != null){		
					stateId = String.valueOf(act.Account__r.State__c).subString(0, 15);
					if(act.Account__r.Account_Segmentatiobn__c != null){
						stateASSURIId = suriIDsByKey.get(stateId + '|' + act.Account__r.Account_Segmentatiobn__c + '|' + prem);
					}
					if(act.Account__r.Primary_Demographic__c != null){
						statePDSURIId = suriIDsByKey.get(stateId + '|' + act.Account__r.Primary_Demographic__c + '|' + prem);
					}
				}
				if(act.Account__r.OwnerId != null){
					userId = String.valueOf(act.Account__r.OwnerId).subString(0, 15);
					if(act.Account__r.Account_Segmentatiobn__c != null){
						userASSURIId = suriIDsByKey.get(userId + '|' + act.Account__r.Account_Segmentatiobn__c + '|' + prem);
					}
					if(act.Account__r.Primary_Demographic__c != null){
						userPDSURIId = suriIDsByKey.get(userId + '|' + act.Account__r.Primary_Demographic__c + '|' + prem);
					}
				}
				
				goalId = goal.Id;
				key = goalId + '|' + act.Account__c;
				gari = garisByKey.get(key);
				if(gari == null){
					gari = new Goal_Account_Report_Item__c();
					gari.Goal__c = goalId;
					gari.Account__c = act.Account__c;
					gari.State_AS_SURI__c = stateASSURIId;
					gari.State_PD_SURI__c = statePDSURIId;
					gari.User_AS_SURI__c = userASSURIId;
					gari.User_PD_SURI__c = userPDSURIId;
					gari.Completed_Actions__c = 1;
				} else {
					gari.Completed_Actions__c++;
				}
				garisByKey.put(key, gari);
				
				if(goal.Parent_Goal__c != null){
					goalId = goal.Parent_Goal__c;
					key = goalId + '|' + act.Account__c;
					gari = garisByKey.get(key);
					if(gari == null){
						gari = new Goal_Account_Report_Item__c();
						gari.Goal__c = goalId;
						gari.Account__c = act.Account__c;
						gari.State_AS_SURI__c = stateASSURIId;
						gari.State_PD_SURI__c = statePDSURIId;
						gari.User_AS_SURI__c = userASSURIId;
						gari.User_PD_SURI__c = userPDSURIId;
						gari.Completed_Actions__c = 1;
					} else {
						gari.Completed_Actions__c++;
					}
					garisByKey.put(key, gari);
					
					if(goal.Parent_Goal__r.Parent_Goal__c != null){
						goalId = goal.Parent_Goal__r.Parent_Goal__c;
						key = goalId + '|' + act.Account__c;
						gari = garisByKey.get(key);
						if(gari == null){
							gari = new Goal_Account_Report_Item__c();
							gari.Goal__c = goalId;
							gari.Account__c = act.Account__c;
							gari.State_AS_SURI__c = stateASSURIId;
							gari.State_PD_SURI__c = statePDSURIId;
							gari.User_AS_SURI__c = userASSURIId;
							gari.User_PD_SURI__c = userPDSURIId;
							gari.Completed_Actions__c = 1;
						} else {
							gari.Completed_Actions__c++;
						}
						garisByKey.put(key, gari);
					}
				}
			}
		}
		
		List<Goal_Account_Report_Item__c> garisToUpsert = new List<Goal_Account_Report_Item__c>();
		List<Goal_Account_Report_Item__c> garisToDelete = new List<Goal_Account_Report_Item__c>();
		for(Goal_Account_Report_Item__c gari2 : garisByKey.values()){
			if(gari2.Completed_Actions__c > 0){
				garisToUpsert.add(gari2);
			} else {
				garisToDelete.add(gari2);
			}
		}
		upsert garisToUpsert;
		delete garisToDelete;
	}
}