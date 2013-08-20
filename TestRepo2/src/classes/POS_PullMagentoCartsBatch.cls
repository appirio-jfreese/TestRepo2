/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        06/19/2012
 * @description Callout to Magento and fetch Carts corresponding to Open for shopping Customer Order Windows
 **/
global class POS_PullMagentoCartsBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
	global final String cartMagentoId;
	// Changes done by Jai Gupta [Appirio Jaipur] for case 00005338 on May 23,2013
	global List<POS_MagentoCartRESTResource.CartItemWrapper> errorCartItems = new List<POS_MagentoCartRESTResource.CartItemWrapper>();
	// End for case 00005338
	global POS_PullMagentoCartsBatch(String cmId) {
		cartMagentoId = cmId;
	}	
    /**
     * @description Kicks off the batch job with the batch query.
     * @param       Database.BatchableContext bc - the context of the batch.
     * @return      Database.QueryLocator - an object which holds records that will be passed to the execute methods in batch.
     */
    global Iterable<SObject> start(Database.BatchableContext bc) {
        
        System.debug('Batch POS_PullMagentoCartsBatch start');
        List<Cart__c> cartsWithMagentoIds = new List<Cart__c>();
        
        Cart__c crt = new Cart__c(magento_Id__c=cartMagentoId);
        cartsWithMagentoIds.add(crt);
        
        return cartsWithMagentoIds;
    }
    
    /**
     * @description Executes one batch (10 records), only 10 callouts are allowed per batch.
     * @param       Database.BatchableContext bc - the context of the batch.
     * @return      List<SObject> scope - the set of records in this batch.
     */
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        
        System.debug('Batch POS_PullMagentoCartsBatch execute - START');
		/*RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = URL.getSalesforceBaseUrl()+'/services/apexrest/syncmagentocart';
    	req.httpMethod = 'GET';		
		//req.addParameter('cart_id', '100765');
		
		for(sobject s : scope){
			Cart__c crt = (Cart__c)s;
		    req.addParameter('cart_id', crt.Magento_ID__c);
	        RestContext.request = req;
	    	RestContext.response = res;
        
        	POS_MagentoCartRESTResource.doGet();
		}
		
        System.debug('Batch POS_PullMagentoCartsBatch execute - END'); 
        */
        try {
        POS_MagentoCartRestResource.batchProcessCart(cartMagentoId);
        } catch(Exception e){
        	system.debug('=======errorCartItems========'+errorCartItems);
        	POS_MagentoCartRESTResource.sendError(e,errorCartItems,null,true);
        }
    }
    
    /**
     * @description Executes when all records selected by the query have been processed.
     * @param       Database.BatchableContext bc - the context of the batch.
     */
    global void finish(Database.BatchableContext bc) {
  		System.debug('Batch POS_PullMagentoCartsBatch Finished');
    }

}