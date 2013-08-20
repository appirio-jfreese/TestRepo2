/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        07/12/2012
 * @description Takes care of synching updates to Magento.
 */
trigger POS_Product_Customization on Item_Customization__c (before insert, before update,
												after delete, after insert, after update) {
													
	if(trigger.isBefore) {
		List<Id> itemIds = new List<Id>();
		// 1 : check to see if the currentList contains duplicate Attribute Label
		for(Item_Customization__c ic1: trigger.new) {
			Integer matchCt = 0;
			itemIds.add(ic1.Item__c);
			
			for(Item_Customization__c ic2: trigger.new) {
				if(ic1.Name.trim() == ic2.Name.trim()) {
					matchCt++;
				}
				
				if(matchCt > 1) {
					ic1.addError('Duplicate Custom Attribute Label for the same Item.');
					break;
				}
			}
		}
		
		// 2 : check to see if the database already contains same Attribute Label
		Map<Id, Item__c> itemWithOptions = new Map<Id, Item__c>([SELECT id, Name, (select id, Name from Item_Customizations__r) from Item__c where Id in :itemIds]);
		for(Item_Customization__c ic1: trigger.new) {
			Item__c existingItemWithOptions = itemWithOptions.get(ic1.Item__c);
			
			for(Item_Customization__c ic2: existingItemWithOptions.Item_Customizations__r) {
				if(ic1.Id != ic2.Id && ic1.Name.trim() == ic2.Name.trim()) { // if the Id is same that would correspond to update
					ic1.addError('Duplicate Custom Attribute Label for the same Item.');
					break;
				}
			}
		}		
		
	} else {												
	
		if (trigger.isInsert) {
				
			for(Item_Customization__c ic: trigger.new) {
				POS_MagentoProductOption.syncMagentoProductOption(ic, 'create');
				System.debug('ic -' + ic);
			}				
					 
		} else if (trigger.isUpdate) {
			   
			for(Item_Customization__c ic: trigger.new) {
				
				if(ic.Magento_Id__c != null && trigger.oldMap.get(ic.id).Magento_Id__c != null ) { // don't fire sync call when only the Magento Id is updated
					POS_MagentoProductOption.syncMagentoProductOption(ic, 'update');
				}
				System.debug('ic -' + ic);
			}					
										
		} else if (trigger.isDelete) {
			
		    for(Item_Customization__c o : trigger.old) {
				POS_MagentoProductOption.deleteMagentoProductOption(o.Magento_Id__c);
				System.debug('o.Magento_Id__c -' +o.Magento_Id__c);
			}		   	
		   	
		}	
	}	

}