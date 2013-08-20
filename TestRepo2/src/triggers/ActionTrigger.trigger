trigger ActionTrigger on Action__c (before insert, before update, after insert, after update, after delete) {
	
	if (trigger.isBefore) {
		if (trigger.isInsert) {
			ActionTriggerActions.handleCompletedActions(trigger.new);
		}
		
		if (trigger.isUpdate) {
			ActionTriggerActions.handleCompletedActions(trigger.oldMap, trigger.new);
		}
		
		if (trigger.isDelete){
			ActionTriggerActions.handleDeletedActions(trigger.old);
		}
	}
	
	if (trigger.isAfter) {
		if (trigger.isInsert) {
			ActionTriggerActions.checkGoalParentage(trigger.new);
		}
		
		if (trigger.isUpdate) {
			ActionTriggerActions.checkGoalParentage(trigger.oldMap, trigger.new);
		}
	}
	
}