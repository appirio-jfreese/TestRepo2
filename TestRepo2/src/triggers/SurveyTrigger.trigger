trigger SurveyTrigger on Survey__c (after insert, after update, before insert, before update) 
{
	
	
	if (trigger.isBefore) {
		if (trigger.isInsert) {
		
		} 
		
		if (trigger.isUpdate) {
			
			for(Survey__c survey : trigger.new) {
				Survey__c oldRecord = trigger.oldMap.get(survey.Id);
				if(oldRecord != null && 
						(oldRecord.Survey_Status__c == 'Closed - Complete' || oldRecord.Survey_Status__c == 'Closed - Incomplete')) {
					survey.addError( 'Surveys cannot be edited or updated after they have been marked Closed.' );
				}
			}
			
			
		}
	}

	
	
	
}