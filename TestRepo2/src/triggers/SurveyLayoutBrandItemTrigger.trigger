trigger SurveyLayoutBrandItemTrigger on SurveyLayout_Brand_Items__c (before insert) 
{
	
	
	if (trigger.isBefore) {
		if (trigger.isInsert) {
			
			SurveyLayoutChildRecordActions.validateParentSurveyIsNotClosedOnInsert(trigger.new) ;
			
		}
		
		if (trigger.isUpdate) {
			
		}
	}
	
	
	
	
}