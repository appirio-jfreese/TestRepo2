/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        06/19/2012
 * @description Class exposing Active Carts as REST Outbound service.
 */
 
@RestResource(urlMapping='/GetCartItems2/*')
global with sharing class POS_APIGetCartItems2 {
	
	
    @HttpPost
     global static APICartResponse doPost (String UpdateTime, Integer Offset, String WindowId, String CartId) {
    	RestRequest req = RestContext.request; 
        RestResponse res = RestContext.response;	
        
        POSAPIConfiguration__c settings;
        if (Test.isRunningTest()) {
        	settings=new POSAPIConfiguration__c(Row_Limit__c=100);	
        }
        else {
        	settings = POSAPIConfiguration__c.getOrgDefaults();
        }
        Integer ROW_LIMIT = (Integer)settings.Row_Limit__c;
    	
    	if (UpdateTime==null) {
    		res.StatusCode = 400;
    		res.addHeader('Error','UpdateTime is a required field');
    		
			return null;
    	}
    	
		
    	String soql = 'Select i.Status__c, i.Ship_To__c, i.Quantity__c, i.Name, i.Item__c, i.Id, i.WBS__c, i.Company_Code__c, ' +
			'Custom_Attribute_Value__c, Item_Customization__r.Name, Cart__r.Name, Cart__r.Status__c, Cart__r.Shopper__c, Cart__r.Order_Window__c, '+
			'Cart__r.Order_Window__r.Status__c, Cart__r.Order_Window__r.Name, '+
			'i.Carrier__c, i.Tracking_Code__c From Cart_Item__c i where Quantity__c>0 and (SystemModstamp > '+UpdateTime+' OR Cart__r.SystemModstamp > '+ UpdateTime +')';
			
			
    	if (WindowId!=null) {
    		soql = soql + ' AND Cart__r.Order_Window__c = \''+WindowId+'\' ';
    	}
    	if (CartId!=null) {
    		soql = soql + ' AND Cart__c= \''+CartId+'\'';
    	}
    	
    	//To avoid erroring out we limit the total results to 50K
    	soql = soql + ' limit 50000';
    	
    	
    	/*if (Offset!=null) {
    		soql = soql + ' offset '+Offset;
    	}else {
    		Offset = 0; //Set this to zero going forward
    	}*/
    	
    	System.debug('Query: '+soql);
    	
    	integer index=0;
    	
    	List<Cart_Item__c> cartsReturned = new List<Cart_Item__c>();
    	
    	APICartResponse apiResponse = new APICartResponse();
    	
    	for (Cart_Item__c cartItem:Database.query(soql)) {
    		
    		if (index<offset) {
    			index++;
    			continue;
    		}
    		index++;
    		
    		cartsReturned.add(cartItem);
    		
    		if (index==offset+ROW_LIMIT) {
    			apiResponse.moreResults=true;
    			break;
    		}
    	}
    	
    	
        apiResponse.lastRowIndex = Offset+cartsReturned.size();
    	apiResponse.carts=cartsReturned;
    	if (Offset+cartsReturned.size()==50000) {
    		//limit reached, so flag it
    		apiResponse.maxResults=true;
    	}
    	else {
    		apiResponse.maxResults=false;
    	}


    	return apiResponse;
     }
    
    
    global class APICartResponse {

        global List <Cart_Item__c> carts { get; set; }
        global Integer lastRowIndex {get; set;}
        global Boolean moreResults {get;set;}
        global Boolean maxResults {get;set;}

    } 
    
    
    /**
    	Just test the basic request to get the list based on update time
    */ 
    //@IsTest
    public static void testGetCartItems () {
    	
    	//Get the current time
    	Datetime now = System.now();
    	
    	Profile p = [select id from profile where name='System Administrator'];
         
		User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id,
		timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
		
		System.runAs(u) {
			
			POS_TestDataUtil.initializeTestData();
    	
    		//Create Agency
    		Account agency = POS_TestDataUtil.createProductionAgency();
	    	
	    	Program__c program = POS_TestDataUtil.createProgram();
	    	Item__c item = POS_TestDataUtil.populateItem(program, agency);
	    	insert item;
	    	
	    	Order_Window__c ow = POS_TestDataUtil.createOrderWindow();
	    	Cart__c crt = POS_TestDataUtil.createCart(u, ow);
	    	
	    	Cart_Item__c ci = POS_TestDataUtil.populateCartItem(item, crt);
	    	insert ci;
	    	
	    	//APICartResponse response1 = POS_APIGetCartItems.doPost(null, null);
	    	//System.assertEquals(null, response1);
	    	
	    	APICartResponse response = POS_APIGetCartItems2.doPost(now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''), null, null, null);
	    	
	    	//Should only see the one record
	    	System.assert(response.carts.size()==1);
	    	System.assert(response.lastRowIndex==1);
	    	System.assert(response.moreResults==false);
	    	
	    	// add another cart Item
			Cart_Item__c ci2 = POS_TestDataUtil.populateCartItem(item, crt);
	    	insert ci2;	 
	    	
	        response = POS_APIGetCartItems2.doPost(now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''), null, null, null);
	    	
	    	//Should see 2 CartItem records 
	    	System.assert(response.carts.size()==2);
	    	System.assertEquals(1, response.lastRowIndex);
	    	System.assert(response.moreResults==false);	    	   	
	    	
	    	//Update the time and try again so that record doesn't appear
	    	now=now.addDays(1);
	    	response = POS_APIGetCartItems2.doPost(now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),0, null, null);
	    	System.assert(response.carts.size()==0);
	    	System.assert(response.lastRowIndex==0);
	    	System.assert(response.moreResults==false);
	    	
	    	//Now test queries for offset filter, set the offset so we get one again
	    	response = POS_APIGetCartItems2.doPost(now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),1, null, null);
	    	System.assert(response.carts.size()==0);
	    	System.assert(response.lastRowIndex==1);
	    	System.assert(response.moreResults==false);
	    	
	    	//Now create enough items to hit row limit and make sure that the pagination works
	    	Cart__c crt2 = POS_TestDataUtil.createCart(u, ow);
	    	
	    	List<Cart_Item__c> testCItems = new List<Cart_Item__c>();
	    	integer citemCount=0;
	    	integer ROW_LIMIT=25;
	    	while (true) {
	    		if (citemCount==ROW_LIMIT) {
	    			break;
	    		}
	    		citemCount++;

		    	Cart_Item__c citem = POS_TestDataUtil.populateCartItem(item, crt2);
		    	
	    		testCItems.add(citem);
	    	}
	 
	    	
	    	insert testCItems;
	    	
	    	now = System.now();
	    	response = POS_APIGetCartItems2.doPost(now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''), 0, null, null);
	    	System.assertEquals(ROW_LIMIT, response.carts.size());
	    	System.assert(response.lastRowIndex==2);
	    	System.assert(response.moreResults==false);
	    	
	    	//Now test for the order window
	    	response = POS_APIGetCartItems2.doPost(now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''), 0, ow.Id, null);
	    	System.assertEquals(ROW_LIMIT, response.carts.size());
	    	System.assert(response.lastRowIndex==2);
	    	System.assert(response.moreResults==false);
	    	
	    	//Make sure a bad window id gets no results
	    	Order_Window__c ow2 = POS_TestDataUtil.createOrderWindow();
	    	response = POS_APIGetCartItems2.doPost(now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''), 0, ow2.Id, null);
	    	System.assert(response.carts.size()==0);
		}
		
		
    	
    }	
    
 
}