/**
 * @author      Model Metrics {Steve Stearns}
 * @date        06/20/2012
 * @description Takes care of synching kit item updates to Magento.
 */

trigger POS_Kit_Item_Sync on Kit_Item__c (after delete, after insert) {

	Map<String,String> itemIdMap = new Map<String,String>();
	
	if (trigger.isInsert) {
		for(Kit_Item__c kitItem : trigger.new) {
			if(trigger.new.size() > 2) {
				POS_MagentoProduct.syncMagentoKitItem(kitItem, 'create', false); // donot useFutureCall
			} else {
				POS_MagentoProduct.syncMagentoKitItem(kitItem, 'create', true); // useFuturecall
			}			
		}
	}
	else {
		for(Kit_Item__c kitItem : trigger.old) {
			if(trigger.old.size() > 2) {
				POS_MagentoProduct.syncMagentoKitItem(kitItem, 'delete', false); // donot useFutureCall
			} else {
				POS_MagentoProduct.syncMagentoKitItem(kitItem, 'delete', true); // useFuturecall
			}			
		}
	}
	
	
 
}