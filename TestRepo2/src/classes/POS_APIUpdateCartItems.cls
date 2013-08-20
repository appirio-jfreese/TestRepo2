/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        06/25/2012
 * @description Class exposing Update to Carts as REST Inbound service for Agency interface.
 */
 
@RestResource(urlMapping='/UpdateCartItems/*')
global with sharing class POS_APIUpdateCartItems {
	
	@HttpPost
    global static List<Cart_Item__c> doPost (List<Cart_Item__c> CartItems) {
    	RestRequest req = RestContext.request; 
        RestResponse res = RestContext.response;	
    	
    	if (cartItems==null || cartItems.size() == 0) {
    		res.StatusCode = 400;
    		res.addHeader('Error','CartItems list is a required field');
    		
			return null;
    	}
    	
		Map<Id, Cart_Item__c> cItmIdMap = new Map<Id, Cart_Item__c>();
    	for(Cart_Item__c cItm : cartItems) {
    		cItmIdMap.put(cItm.Id, cItm);
    	}
    	
    	List<Cart_Item__c> cartItemsForUpdate = [Select Id, Status__c, Tracking_Code__c, Carrier__c from Cart_Item__c where id in :cItmIdMap.keySet()];
    	
    	for(Cart_Item__c cItm : cartItemsForUpdate) {
    		if(cItmIdMap.get(cItm.id).Status__c != null) {
    			cItm.Status__c = cItmIdMap.get(cItm.id).Status__c;
    		}
    		if(cItmIdMap.get(cItm.id).Carrier__c != null) {
    			cItm.Carrier__c = cItmIdMap.get(cItm.id).Carrier__c;
    		}    		
    		if(cItmIdMap.get(cItm.id).Tracking_Code__c != null) {
    			cItm.Tracking_Code__c = cItmIdMap.get(cItm.id).Tracking_Code__c;
    		}
    		
    		System.debug('cItm.Tracking_Code__c - ' + cItmIdMap.get(cItm.id).Tracking_Code__c);
    	} 
    	
    	update(cartItemsForUpdate); 
    	System.debug('cartItemsForUpdate.size() - ' + cartItemsForUpdate.size());  	   	
 
		return cartItemsForUpdate;
    }   
    	
    	
   	@IsTest(SeeAllData=true)
    public static void testUpdateCartItem () {
    	
    	//Get the current time
    	Datetime now = System.now();
    	
    	Profile p = [select id from profile where name='POS - API User Agency'];
         
		User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id,
		timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
		RecordType posAgencyRecordType = [select Id from RecordType where Name='POS Production Agency' and sObjectType='Account'];
		
		
		System.runAs(u) {
			POSAPIConfiguration__c settings = POSAPIConfiguration__c.getOrgDefaults();
    	
	    	Order_Window__c window = POS_TestDataUtil.createOrderWindow();
	    	window.Status__c='Open';
	   		update window;
	   		
	    	Program__c program = POS_TestDataUtil.createProgram();
	    	Account account = POS_TestDataUtil.createAccount();
	    	account.RecordTypeId = posAgencyRecordType.Id;
	    	update account;
	    
	    	Item__c item = POS_TestDataUtil.createItem(program);
	    	Cart__c cart = POS_TestDataUtil.createCart(u, window);
	    	Cart_Item__c cartItem = POS_TestDataUtil.populateCartItem(item, cart);
	    	insert cartItem;
	    	
	    	//Flag item as shipped so there's a change
	    	cartItem.Status__c = 'Shipped';
	    	cartItem.Carrier__c = 'Fedex';
	    	cartItem.Tracking_Code__c = 'TESTING123';
			
			List<Cart_Item__c> cartItems = new List<Cart_Item__c>();
			cartItems.add(cartItem);
			
	    	
	        POS_APIUpdateCartItems.doPost(cartItems);
	        
	        Id cartItemId=cartItem.Id;
	        
	        //Now load the item and see if it changed
	        Cart_Item__c loaded = [select Id, Status__C from Cart_Item__c where Id=:cartItemId];
	        System.assert(loaded.Status__c == 'Shipped');
    	
		}
    }

}