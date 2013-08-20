trigger GoalTrigger on Goal__c (after delete, after insert, after update, before delete, before insert, before update) {

	if (trigger.isBefore) {
		if (trigger.isInsert) {
		}
		
		if (trigger.isUpdate) {
		}
	}
	
	if (trigger.isAfter) {
		if (trigger.isInsert) {
			if(GoalTriggerActions.shouldCreateBlanksOrFilled){
				GoalTriggerActions.createBlankGBRIs(trigger.new);
			}
		}
		
		if (trigger.isUpdate) {
			if(GoalTriggerActions.shouldCreateBlanksOrFilled){
				GoalTriggerActions.createBlankOrFilledGBRIs(trigger.oldMap, trigger.new);
			}
		}
		
		if (trigger.isDelete){
		}
	}

}