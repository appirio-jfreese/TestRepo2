trigger ObjectiveTrigger on Objective__c (after insert, after update, before insert, before update) 
{
	
	
	if (trigger.isBefore) {
		if (trigger.isInsert) {
			
			
		} 
		
		if (trigger.isUpdate) {
			
		}
	}
	
	if (trigger.isAfter) {
		if (trigger.isInsert) {
			
			ObjectiveTriggerActions.generateActionRecordsFromObjectiveInsert(trigger.new);
		
		}
		
		if (trigger.isUpdate) {
		
		}
	}
	
	
	
	
	
}