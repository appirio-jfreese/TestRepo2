trigger ActionProductLinkTrigger on Action_Product_Link__c (after delete, after insert, after update, before delete, before insert, before update) {

	if (trigger.isBefore) {
		if (trigger.isInsert) {
			ActionProductLinkActions.updateOnlineFields(trigger.new);
			ActionProductLinkActions.checkToPopulateReportBrand(trigger.new);
		}
		
		if (trigger.isUpdate) {
			ActionProductLinkActions.updateOnlineFields(trigger.oldMap, trigger.new);
			ActionProductLinkActions.checkToPopulateReportBrand(trigger.oldMap, trigger.new);
		}
	}
	
	if (trigger.isAfter) {
		if (trigger.isInsert) {
			ActionProductLinkActions.deduplicateLinks(trigger.newMap);
		}
		
		if (trigger.isUpdate) {
		}
		
		if (trigger.isDelete){
		}
	}

}