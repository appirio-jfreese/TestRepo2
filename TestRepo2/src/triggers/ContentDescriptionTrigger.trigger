trigger ContentDescriptionTrigger on Content_Description__c (before insert, before update) {
	TriggerContentDescription.onBeforeUpdate(Trigger.isUpdate, Trigger.newMap, Trigger.oldMap);
}