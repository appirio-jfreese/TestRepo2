/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        05/21/2012
 * @description Takes care of synching updates to Magento.
 */
 
trigger POS_Product_Brand on Item_Brand__c (after delete, after insert, after update) {
	
	private static String itemsForSyncQuery = 'Select i.Id, i.Status__c, i.Program__r.Magento_Id__c, i.Program__r.Order_Window__r.Magento_Id__c, i.Order_Window_Name__c, i.Name, i.Current_Price__c,' +
		 'i.Description__c, i.Estimated_Price__c, i.Category__c, i.Minimum_Quantity__c, i.Packout_Quantity__c, i.Item_Category__r.Name, i.Item_Category__r.Friendly_Name__c,' +
		 'i.RecordTypeId, i.Estimated_Shipping_Tax__c, i.RecordType.DeveloperName, i.Parent__c, i.Kit_Only__c, i.Magento_Option_Id__c,' +
		 '(Select Brand__r.Magento_Id__c, Primary__c From Item_Brands__r), (SELECT Id,Magento_ID__c FROM Items__r where Status__c != \'Removed\') From Item__c i where i.id in :itemIdsForSync';
	
	if (trigger.isInsert) {
	   		
	   	   Set<ID> itemIdsForSync = new Set<ID>();	
		   for(Item_Brand__c n : trigger.new) {
		   	 // avoids repeat update callout on Item when Brands are added to same Item
		   	 if(!itemIdsForSync.contains(n.Item__c)) {
		   	 	itemIdsForSync.add(n.Item__c);
		   	 }
		   }
		
		   System.debug('itemIdsForSync.size() -' + itemIdsForSync.size());
		   
		   List<Item__c> itemsForSync = Database.query(itemsForSyncQuery); 
						 
			for(Item__c itm: itemsForSync) {
				System.debug('itemsForSync.size() insert-' +itemsForSync.size());
				if(itemsForSync.size() > 2) {
					POS_MagentoProduct.syncMagentoProduct(itm, 'update', false); // donot useFutureCall
				} else {
					POS_MagentoProduct.syncMagentoProduct(itm, 'update', true); // useFuturecall
				}				
			}		   

			   
	} else if (trigger.isUpdate) {
	   	
	   	   Set<ID> itemIdsForSync = new Set<ID>();
		   for(Item_Brand__c n : trigger.new) {
				
				Item_Brand__c o = trigger.oldMap.get(n.id);
				
				if (n.Item__c != o.Item__c || n.Brand__c != o.Brand__c) { // sync to Magento only if this relation has changed
					 // avoids repeat update callout on Item when Brands are added to same Item
				   	 if(!itemIdsForSync.contains(o.Item__c)) {
				   	 	itemIdsForSync.add(o.Item__c);
				   	 }
				}
		   }
			
		   System.debug('trigger.isUpdate - itemIdsForSync.size() -' + itemIdsForSync.size());
		   List<Item__c> itemsForSync = Database.query(itemsForSyncQuery); 

			for(Item__c itm: itemsForSync) {
				System.debug('itemsForSync.size() Update-' +itemsForSync.size());
				if(itemsForSync.size() > 2) {
					POS_MagentoProduct.syncMagentoProduct(itm, 'update', false); // donot useFutureCall
				} else {
					POS_MagentoProduct.syncMagentoProduct(itm, 'update', true); // useFuturecall
				}	
			}				
				
	} else if (trigger.isDelete) {
		
	   	   Set<ID> itemIdsForSync = new Set<ID>();	
		   for(Item_Brand__c o : trigger.old) {
		   	 // avoids repeat update callout on Item when Brands are added to same Item
		   	 if(!itemIdsForSync.contains(o.Item__c)) {
		   	 	itemIdsForSync.add(o.Item__c);
		   	 }
		   }
		
		   System.debug('trigger.isDelete - itemIdsForSync.size() -' + itemIdsForSync.size());
		   List<Item__c> itemsForSync = Database.query(itemsForSyncQuery);

			for(Item__c itm: itemsForSync) {
				System.debug('itemsForSync.size() delete -' +itemsForSync.size());
				if(itemsForSync.size() > 2) {
					POS_MagentoProduct.syncMagentoProduct(itm, 'update', false); // donot useFutureCall
				} else {
					POS_MagentoProduct.syncMagentoProduct(itm, 'update', true); // useFuturecall
				}
			}				
	   	
	  }	

}