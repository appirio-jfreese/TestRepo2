trigger HomeVideo on HomeVideo__c (after insert, after update) {
	TriggerHomeVideo.onAfterInsertAndUpdate(trigger.new);
}