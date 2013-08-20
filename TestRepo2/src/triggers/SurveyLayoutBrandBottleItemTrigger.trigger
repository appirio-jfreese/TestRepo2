trigger SurveyLayoutBrandBottleItemTrigger on Survey_Layout_Brand_Bottle_Item__c (before insert) 
{
	
	
	if (trigger.isBefore) {
		if (trigger.isInsert) {
			SurveyLayoutChildRecordActions.validateParentSurveyIsNotClosedOnInsert(trigger.new) ;
		}
		
		if (trigger.isUpdate) {
			
		}
	}
	
	
	
	
	
	
}