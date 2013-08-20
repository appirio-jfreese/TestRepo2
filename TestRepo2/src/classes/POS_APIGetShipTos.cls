/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        06/20/2012
 * @description Class exposing ShipTos stored in SFDC as REST Outbound service.
 */
 
@RestResource(urlMapping='/GetShipTos/*')
global without sharing class POS_APIGetShipTos {
	
 	@HttpPost
    global static APIShipToResponse doPost (String UpdateTime, Integer Offset) {
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
    	
    	System.debug('UPDATE TIME: '+UpdateTime);
		String soql = 'Select s.Zip__c, s.Street__c, s.Street_2__c, s.State__c, s.Phone__c, s.Address_Type__c, s.Contact_Email__c, s.Notes__c, s.Name, s.Id, s.City__c, s.Attention__c, s.Account__c ' +
					'From Ship_To__c s where s.SystemModstamp > '+UpdateTime ;
    	
    	//We limit to ROW_LIMIT results in a response, but we query for 101 so that we know if we hit the limit
   		System.debug('Row limit: '+ROW_LIMIT);
    	soql = soql + ' limit '+(ROW_LIMIT+1);
    	
    	if (Offset!=null) {
    		soql = soql + ' offset '+Offset;
    	} else {
    		Offset = 0; //Set this to zero going forward
    	}
    	
    	System.debug('Query: '+soql);
    	List<Ship_To__c> shipTosReturned = (List<Ship_To__c>)Database.query(soql);
    
    	APIShipToResponse apiResponse = new APIShipToResponse();
    	if (shipTosReturned != null) {
    		System.debug('shipTosReturned returned: '+shipTosReturned.size());
    		
	    	if (shipTosReturned.size()>ROW_LIMIT) {
	    		//We hit the limit, so set the flag and remove the 101st item from the list
	    		apiResponse.moreResults=true;
	    		shipTosReturned.remove(ROW_LIMIT); // remove the last element
	    		
	    	} else {
	    		apiResponse.moreResults=false;
	    	}
	    	
	        apiResponse.lastRowIndex = Offset+shipTosReturned.size();
	    	apiResponse.shipTos=shipTosReturned;
    	}


    	return apiResponse;
    	
    }
    
    
    global class APIShipToResponse {

        global List <Ship_To__c> shipTos { get; set; }
        global Integer lastRowIndex {get; set;}
        global Boolean moreResults {get;set;}

    } 	
    
    /**
    	Just test the basic request to get the list based on update time
    */ 
    @IsTest
    public static void testGetShipTos () {
    	
    	//Get the current time
    	Datetime now = System.now();
    	now=now.addMinutes(-1);
		POS_TestDataUtil.initializeTestData();
	
		//Create ShipTo
		Account act = POS_TestDataUtil.createAccount();
    	Ship_To__c st = POS_TestDataUtil.createShipTo(act);
    	
    	
	    APIShipToResponse response = POS_APIGetShipTos.doPost(now.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''), null);
	    	
    	//Should only see the one record
    	System.assert(response.shipTos.size()==1);
    	System.assert(response.lastRowIndex==1);
    	System.assert(response.moreResults==false);
	    	
	    Ship_To__c st2 = POS_TestDataUtil.createShipTo(act); 
	    response = POS_APIGetShipTos.doPost(now.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''), null);
	    	
    	//Should see 2 records
    	System.assert(response.shipTos.size()==2);
    	System.assertEquals(2, response.lastRowIndex);
    	System.assert(response.moreResults==false);	    	   	
	    	
    	//Update the time and try again so that record doesn't appear
    	now=now.addDays(1);
    	response = POS_APIGetShipTos.doPost(now.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),0);
    	System.assert(response.shipTos.size()==0);
    	System.assert(response.lastRowIndex==0);
    	System.assert(response.moreResults==false);
    	
    	//Now test queries for offset filter, set the offset so we get one again
    	now = System.now();
    	now=now.addMinutes(-1);
    	Account act2 = POS_TestDataUtil.createAccount();
    	st2 = POS_TestDataUtil.createShipTo(act2);
    	response = POS_APIGetShipTos.doPost(now.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),1);
    	System.assert(response.shipTos.size()==2);
    	System.assert(response.lastRowIndex==3);
    	System.assert(response.moreResults==false);
    	
	}     

}