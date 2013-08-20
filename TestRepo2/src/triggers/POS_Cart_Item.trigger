/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        07/03/2012
 * @description Takes care of updating the Parent Cart timestamp when a cart Item is deleted.
 */
 
trigger POS_Cart_Item on Cart_Item__c (after delete) {
	
	   List<Cart__c> parentCarts = new 	List<Cart__c>();
	   List<Id> parentCartIds = new List<Id>();
	   for(Cart_Item__c o : trigger.old) {
			parentCartIds.add(o.Cart__c);
		}	
		
		/* updating the parent carts will automatically set the LastModifiedDate to current datetime
		   this helps making the cart available for fetch with the next API call */
		parentCarts = [Select Id from Cart__c where Id in :parentCartIds];
		update parentCarts;
}