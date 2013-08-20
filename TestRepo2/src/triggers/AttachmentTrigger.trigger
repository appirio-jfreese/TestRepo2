trigger AttachmentTrigger on Attachment (after insert, after delete) {

	if(trigger.isInsert){
		AttachmentActions.updateParentActions(trigger.new);
		AttachmentActions.updateParentAccounts(trigger.new);
	}
	if(trigger.isDelete){
		AttachmentActions.updateParentActions(trigger.old);
		AttachmentActions.updateParentAccounts(trigger.old);
	}

}