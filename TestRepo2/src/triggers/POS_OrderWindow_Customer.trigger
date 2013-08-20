/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        06/18/2012
 * @description Takes care of synching updates to Magento.
 */
trigger POS_OrderWindow_Customer on Order_Window_Customer__c (after delete, after insert, after update) {
	
	   if (trigger.isDelete) {
		   for(Order_Window_Customer__c o : trigger.old) {
				
				//POS_MagentoCategory.deleteMagentoCategory(o.Magento_Id__c);
				//System.debug('o.Magento_Id__c -' +o.Magento_Id__c);
				
			}		   	
	   	
	   } else if (trigger.isInsert) {
	   	
		   for(Order_Window_Customer__c n : trigger.new) {
				

				System.debug('n.Name -' +n.Name);
				
			}	
			
			//POS_MagentoCart.createMagentoCart(owcList);
			   
		} else if (trigger.isUpdate) {
			
		}	
	

}