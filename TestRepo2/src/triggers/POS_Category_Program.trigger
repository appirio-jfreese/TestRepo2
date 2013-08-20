/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        05/08/2012
 * @description Takes care of synching updates to Magento.
 */
 
trigger POS_Category_Program on Program__c (after delete, after insert, after update) {
	   
	   if (trigger.isDelete) {
		   for(Program__c o : trigger.old) {
				
				POS_MagentoCategory.deleteMagentoCategory(o.Magento_Id__c);
				System.debug('o.Magento_Id__c -' +o.Magento_Id__c);
				
			}		   	
	   	
	   } else if (trigger.isInsert) {
	   	
		   for(Program__c n : trigger.new) {
				
				String isActive = '1'; //Magento has 2 status - Active, Inactive for category, but Inactive doesn't applie to Brand.
				if(!Test.isRunningTest()) { // avoid futureCallouts
					POS_MagentoCategory.createMagentoCategoryProgram(n.id, n.Name, n.Sales_Channel_Group__c, n.Sales_Driver__c, isActive);
				}
				System.debug('n.Name -' +n.Name);
				
			}	
			   
		} else if (trigger.isUpdate) {
	   		
	   	   List<Id> programIdsWithBrandChange = new List<Id>();
		   for(Program__c n : trigger.new) {
		   	
				Program__c o = trigger.oldMap.get(n.id);
				//add to the list for updating itembarnds only if the Brand field on the Item has changed.
				if (o.Brand__c != n.Brand__c) {
					programIdsWithBrandChange.add(n.id); 
				}
							
				System.debug('n.Name -' +n.Name + ' o.Name -' + o.Name);
				if(o.Magento_Id__c != null) { // donot sync when unpdating the Magento Id back on the record after creation
					
					String isActive = '1'; //Magento has 2 status - Active, Inactive for category, but Inactive doesn't applie to Brand.
					if(!Test.isRunningTest()) { // avoid futureCallouts
						POS_MagentoCategory.updateMagentoCategoryProgram(n.Magento_Id__c, n.Name, n.Sales_Channel_Group__c, n.Sales_Driver__c, isActive);
					}
				}
				
			}	
			
			// Update Item Brand record based on the new Brand a Program is associated with. 	
	   	   /* delete any existing ItemBrand records per requirment - 
	   	   	US140 - the brand must align with the program's brand unless the program's brand is a portfolio brand */
	   	   	
	   	   List<Item_Brand__c> ibDeleteList = new List<Item_Brand__c>();
	   	   
	   	   List<Item_Brand__c> ibCreateList = new List<Item_Brand__c>();
		   List<Item__c> itemsWithItemBrand = new List<Item__c>([Select i.Id, Program__r.Brand__r.Portfolio_Brand__c, (Select Id, Item__c, Brand__c, Primary__c From Item_Brands__r) From Item__c i where i.Program__c in :programIdsWithBrandChange]);
		   
		   for(Item__c itm:itemsWithItemBrand) {
		   		
		   		ibDeleteList.addAll(itm.Item_Brands__r);
		   		if (!itm.Program__r.Brand__r.Portfolio_Brand__c) { //If the Program is tied to a Portfolio Brand, then no Item Brand record is created
		   			System.debug('itmId - ' + itm.Id + ' itm.Program__r.Brand__c - ' + itm.Program__r.Brand__c);
					Item_Brand__c ib = new Item_Brand__c(Brand__c=itm.Program__r.Brand__c, Item__c=itm.Id, Primary__c=true);
					ibCreateList.add(ib);
		   		}		   		
		   }
		   System.debug('ibDeleteList.size() -' + ibDeleteList.size());
		   delete ibDeleteList;

		   System.debug('ibCreateList.size() -' + ibCreateList.size());
		   insert  ibCreateList;			
			   
		}

}