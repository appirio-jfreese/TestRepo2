public without sharing class ActionAssignmentGoalSaver {

	public ActionAssignmentGoalSaver(ActionAssignmentController cont){}

	@RemoteAction
	public static Boolean saveGoals(List<Goal__c> childGoals){
		Goal__c parentGoal = 
			[SELECT Id,
					Name,
					Long_Name__c,
					Priority__c,
					Goal_Type__c,
					RecordTypeId,
					Program__c,
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
			  WHERE Id = :childGoals[0].Parent_Goal__c
			];
		
		for(Goal__c childGoal : childGoals){
			childGoal.Name = parentGoal.Name;
			childGoal.Long_Name__c = parentGoal.Long_Name__c;
			childGoal.Priority__c = parentGoal.Priority__c;
			childGoal.Goal_Type__c = parentGoal.Goal_Type__c;
			childGoal.RecordTypeId = parentGoal.RecordTypeId;
			childGoal.Program__c = parentGoal.Program__c;
			childGoal.State__c = parentGoal.State__c;
			childGoal.Comments__c = parentGoal.Comments__c;
			childGoal.SFA_POS_Items__c = parentGoal.SFA_POS_Items__c;
			childGoal.Account_Grade__c = parentGoal.Account_Grade__c;
			childGoal.Location_Grade__c = parentGoal.Location_Grade__c;
			childGoal.Start_Date__c = parentGoal.Start_Date__c;
			childGoal.Due_Date__c = parentGoal.Due_Date__c;
			childGoal.Content_Link__c = parentGoal.Content_Link__c;
			childGoal.Feature_Type__c = parentGoal.Feature_Type__c;
			childGoal.Length_of_Training__c = parentGoal.Length_of_Training__c;
			childGoal.Number_of_Attendees__c = parentGoal.Number_of_Attendees__c;
			childGoal.Product_Sample_s__c = parentGoal.Product_Sample_s__c;
			childGoal.Shelf_Set_Criteria__c = parentGoal.Shelf_Set_Criteria__c;
			childGoal.Size_of_Ad__c = parentGoal.Size_of_Ad__c;
			childGoal.Suggested_Price__c = parentGoal.Suggested_Price__c;
			childGoal.Tasted_Product__c = parentGoal.Tasted_Product__c;
			childGoal.Trainer__c = parentGoal.Trainer__c;
			childGoal.Training_Audience__c = parentGoal.Training_Audience__c;
			childGoal.Type_of_Ad__c = parentGoal.Type_of_Ad__c;
			
			childGoal.Goal_Level__c = 'Rep';
		}
		
		insert childGoals;
		
		if(parentGoal.Goal_Product_Links__r.size() > 0){
			List<Goal_Product_Link__c> gpls = new List<Goal_Product_Link__c>();
			for(Goal__c childGoal : childGoals){
				for(Goal_Product_Link__c oldGPL : parentGoal.Goal_Product_Links__r){
					Goal_Product_Link__c newGPL = new Goal_Product_Link__c();
					
					newGPL.Goal__c = childGoal.Id;
					newGPL.Product_Classification__c = oldGPL.Product_Classification__c;
					newGPL.Product_Group__c = oldGPL.Product_Group__c;
					newGPL.Report_Brand__c = oldGPL.Report_Brand__c;
					newGPL.Generic_Brand__c = oldGPL.Generic_Brand__c;
					newGPL.Sub_Brand__c = oldGPL.Sub_Brand__c;
					newGPL.Individual_Brand__c = oldGPL.Individual_Brand__c;
					newGPL.Size__c = oldGPL.Size__c;
					
					gpls.add(newGPL);
				}
			}
			insert gpls;
		}
		
		parentGoal.Completed__c = true;
		update parentGoal;
		
		return true;
	}

}