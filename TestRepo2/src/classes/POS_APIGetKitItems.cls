@RestResource(urlMapping='/GetKitItems/*')
global with sharing class POS_APIGetKitItems {
 	
 	private static String fieldList = ' k.SystemModstamp,  k.Packout_Quantity__c,'+
 	  '  k.Kit__c, k.Item__c, k.Id From Kit_Item__c k';
 	
 	
 	private static Integer TEST_ROW_LIMIT=10;
 	
 	@HttpPost
    global static APIKitItemResponse doPost (String UpdateTime, List<String> KitItems, Integer Offset) {
    	RestRequest req = RestContext.request; 
        RestResponse res = RestContext.response;	
        
        POSAPIConfiguration__c settings; 
        if (Test.isRunningTest()) {
        	settings=new POSAPIConfiguration__c(Row_Limit__c=TEST_ROW_LIMIT);	
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
    	
		String soql = 'select '+fieldList+' where SystemModstamp > '+UpdateTime;
    	
    
    	
    	if (KitItems!=null && KitItems.size()>0) {
    		soql=soql + ' and Id in (';
    		integer itemCount=0;
    		for (String kitItem:KitItems) {
    			kitItem=String.escapeSingleQuotes(kitItem);
    			soql=soql+'\''+kitItem+'\'';
    			itemCount++;
    			if (itemCount<KitItems.size()) {
    				soql=soql+',';
    			}
    		}
    		soql=soql+')';
    	}
    	
    	//We limit to ROW_LIMIT results in a response, but we query for 101 so that we know if we hit the limit
   		System.debug('Row limit: '+ROW_LIMIT);
    	soql = soql + ' limit '+(ROW_LIMIT+1);
    	
    	if (Offset!=null) {
    		soql = soql + ' offset '+Offset;
    	}
    	else {
    		Offset = 0; //Set this to zero going forward
    	}
    	
    	System.debug('Query: '+soql);
    	
    	List<Kit_Item__c> itemsReturned = (List<Kit_Item__c>)Database.query(soql);
    
    	APIKitItemResponse apiResponse = new APIKitItemResponse();
    	if (itemsReturned != null) {
    		System.debug('Items returned: '+itemsReturned.size());
	    	if (itemsReturned.size()>ROW_LIMIT) {
	    		//We hit the limit, so set the flag and remove the 101st item from the list
	    		apiResponse.moreResults=true;
	    		itemsReturned.remove(ROW_LIMIT); 
	    	}
	    	else {
	    		apiResponse.moreResults=false;
	    	}
	    	
	        apiResponse.lastRowIndex = Offset+itemsReturned.size();
	    	apiResponse.kitItems=itemsReturned;
    	}


    	return apiResponse;
    	
    }
    
    
    global class APIKitItemResponse {

        global List <Kit_Item__c> kitItems { get; set; }
        global Integer lastRowIndex {get; set;}
        global Boolean moreResults {get;set;}

    }   
    
    
   
    @IsTest
    public static void testGetKitItems () {
    	
    	//Get the current time
    	Datetime now = System.now();
    	
    	Profile p = [select id from profile where name='POS - API User Agency'];
         
		User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id,
		timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
		
		RecordType kitRecordType = [select Id from RecordType where Name='Kit' and sObjectType='Item__c'];
	    RecordType standardRecordType = [select Id from RecordType where Name='Standard' and sObjectType='Item__c'];
		
		System.runAs(u) {
    	
    		POS_TestDataUtil.initializeTestData();
    		
    		//Create Agency
    		Account agency = POS_TestDataUtil.createProductionAgency(); 
    		
    		Account_Member__c member = new Account_Member__c();
    		member.Account__c = agency.Id;
    		member.User__c = u.Id;
    		insert member;
    		
    		System.debug('Pre-test 1');
	    	
	    	
	    	Program__c program = POS_TestDataUtil.createProgram();
	    	
	   	
	    	//Create the kit
	    	Item__c kit = POS_TestDataUtil.createKit(program);
	    	 	
    		System.debug('Pre-test 2');
    		
    		Test.startTest();
	    	
	    	//Create an item to add to the kit
	    	Item__c item = POS_TestDataUtil.populateItem(program, agency);
	    	item.RecordType=standardRecordType;
	    	insert item; 
	    	
	    	
    		System.debug('Pre-test 3');
	    	
	    	
	    	
	    	
	    	
			Kit_Item__c kitItem = new Kit_Item__c();
			kitItem.Kit__c = kit.Id;
			kitItem.Item__c = item.Id;
			kitItem.Packout_Quantity__c = 5;
			insert kitItem;
				    	
	    	
	    	//create enough items to hit row limit and make sure that the pagination works
	    	
	    	
	    	List<Item__c> testItems = new List<Item__c>();
	    	List<Kit_Item__c> testKitItems = new List<Kit_Item__c>();
	    	integer itemCount=0;
	    	Integer ROW_LIMIT = TEST_ROW_LIMIT;
	    	
	    	while (true) {
	    		System.debug('Loop count: '+itemCount);
	    		if (itemCount==ROW_LIMIT) {
	    			break;
	    		}
	    		itemCount++;
		    	item = POS_TestDataUtil.populateItem(program, agency);
		    	kitItem = new Kit_Item__c();
				kitItem.Kit__c = kit.Id;
				kitItem.Item__c = item.Id;
				kitItem.Packout_Quantity__c = 5;
		    	
	    		testItems.add(item);
	    		testKitItems.add(kitItem);
	    	}
	 
	    	
	    	insert testItems;
	    	insert testKitItems;
	    	
	    	List<String> itemsIds = new List<String>();
	    	for(Kit_Item__c kitem : testKitItems){
	    		itemsIds.add(kitem.Id);
	    	}
	    	
	    	System.debug('Run test 7');
	    	APIKitItemResponse response = POS_APIGetKitItems.doPost(now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),null,null);
	    	System.assert(response.kitItems.size()==ROW_LIMIT);
	    	System.assert(response.lastRowIndex==ROW_LIMIT);
	    	System.assert(response.moreResults==true);
	    	
	    	APIKitItemResponse response2 = POS_APIGetKitItems.doPost(now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),itemsIds,null);
	    	System.assert(response2.kitItems.size()==ROW_LIMIT);
	    	System.assert(response2.lastRowIndex==ROW_LIMIT);
	    	
	    	Test.stopTest();
	    	
		}
		
		
    	
    }
  	
}