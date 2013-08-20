/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        05/01/2012
 * @description Takes care of synching updates to Magento.
 */
 
trigger POS_Category_OrderWindow on Order_Window__c (after delete, after insert, after update) {
	   
	   if (trigger.isDelete) {
		   for(Order_Window__c o : trigger.old) {
		   	
		   		if(o.Status__c != 'New') {
					o.addError('Cannot delete Order Window once it leaves \'New\' status');
					
				} else {
				
					POS_MagentoCategory.deleteMagentoCategory(o.Magento_Id__c);
					System.debug('o.Magento_Id__c -' +o.Magento_Id__c);
		   		}
				
			}		   	
	   	
	   } else if (trigger.isInsert) {
	   	
		   for(Order_Window__c n : trigger.new) {
				
				String isActive = (n.Status__c=='Open')?'1':'0'; //Magento has only 2 status - Active, Inactive
				if(!Test.isRunningTest()) { // avoid futureCallouts
					POS_MagentoCategory.createMagentoCategoryWindow(n.id, n.Name, isActive);
				}
				System.debug('n.Name -' +n.Name);
				
			}	
			   
		} else if (trigger.isUpdate) {
	   		
	   		Map<Id, Order_Window__c> owWithCustomers = new Map<Id, Order_Window__c>([Select o.Id, (Select Id, Name, Order_Window__c, Customer__c, Open_For_Shopping__c 
	   																From Order_Window_Customers__r) From Order_Window__c o where o.id in :trigger.new]);
		   List<Order_Window_Customer__c> owCustomerForUpdate =	new List<Order_Window_Customer__c>();
		   for(Order_Window__c n : trigger.new) {
		   	
				Order_Window__c o = trigger.oldMap.get(n.id);
				
				//System.debug('n.Status__c -' +n.Status__c + ' o.Status__c -' + o.Status__c + ' n.Name -' +n.Name + ' o.Name -' + o.Name);
				
				/* Manage OrderWindow status on Magento */
				if(n.Status__c != o.Status__c || n.Name != o.Name) { // update only if Status or Name is updated
					
					String isActive = (n.Status__c=='Open' || n.Status__c=='Closed')?'1':'0'; //Magento has only 2 status - Active, Inactive
					if(!Test.isRunningTest()) { // avoid futureCallouts
						POS_MagentoCategory.updateMagentoCategory(n.Magento_Id__c, n.Name, isActive);
					}
				}
				System.debug('n.Name -' +n.Name);
				
				
				/* set OrderWindowCustomer 'Open for Shopping' flag based on the OrderWindow status */
				List<Order_Window_Customer__c> owCustomers = owWithCustomers.get(n.id).Order_Window_Customers__r;
				if(n.Status__c != o.Status__c && owCustomers != null) {
					Boolean openForShopping = false;
					if(n.Status__c=='Open') {
						openForShopping = true;
					}
					
					for(Order_Window_Customer__c owc :owCustomers ) {
						if(owc.Open_For_Shopping__c != openForShopping) {
							owc.Open_For_Shopping__c = openForShopping;
							owCustomerForUpdate.add(owc);
						}
					}
					
				}
				
			}	
			
			System.debug('owCustomerForUpdate.size() -' + owCustomerForUpdate.size());
			update(owCustomerForUpdate);
			   
		}

}