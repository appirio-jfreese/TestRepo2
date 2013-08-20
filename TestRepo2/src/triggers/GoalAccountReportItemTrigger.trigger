trigger GoalAccountReportItemTrigger on Goal_Account_Report_Item__c (after delete, after insert, after update, before delete, before insert, before update) {

	if (trigger.isBefore) {
		if (trigger.isInsert) {
			GoalAccountReportItemActions.copyFieldsFromAccount(trigger.new);
		}
		
		if (trigger.isUpdate) {
		}
	}
	
	if (trigger.isAfter) {
		if (trigger.isInsert) {
		}
		
		if (trigger.isUpdate) {
		}
		
		if (trigger.isDelete){
		}
	}

}