@RestResource(urlMapping='/UpsertKitItem/*')
global with sharing class POS_APIUpsertKitItem {
	
	public static String STATUS_SUCCESS='success';
    public static String STATUS_FAIL='fail';
	
	@HttpPost 
    global static UpsertResponse doPost (Kit_Item__c kitItem, RestResponse res) {
    	
    	String userId = UserInfo.getUserId();
    	
    	POSAPIConfiguration__c settings = POSAPIConfiguration__c.getOrgDefaults();
        String PROFILE_NAME = settings.POS_Agency_Profile_Name__c;
    	
    	List<Account_Member__c> accountMembers = [select a.Account__c from Account_Member__c a where a.User__c= :userId
    		and a.Account__r.RecordType.Name = :PROFILE_NAME];
    		
    	//There should be one and only one agency associated with this account
    	if (accountMembers == null || accountMembers.size()!=1) {
    		res.StatusCode = 400;
    		res.addHeader('Error','Misconfiguration: account not configured for a single POS agency');
			return null;
    		
    	}
    	
    	Id agency = accountMembers.get(0).Account__c;
    	
    	//They must own the items that are associated with the kit item
    	List<String> itemIds = new List<String>();
    	itemIds.add(kitItem.Kit__c);
    	itemIds.add(kitItem.Item__c);
    	List<Item__c> items = [select Id, Agency__c from Item__c where Id in :itemIds];
    	
    	//Make sure that the items they are referencing actually exist
    	if (items==null || items.size()!=2) {
    		res.StatusCode = 500;
    		res.addHeader('Error','The Kit or Item you specified does not exist');
			return null;
    	}
    	else {
    		for (Item__c item:items) {
    			System.debug('Agency comparison: '+item.Agency__c+'->'+agency);
    			System.debug('They dont match: '+(item.Agency__c!=agency));
    			if (item.Agency__c!=agency) {
    				res.StatusCode = 500;
		    		res.addHeader('Error','The Kit or Item you specified does not belong to your agency');
					return null;
    			}
    		}
    	}
    	
    	
    	
    	
    	UpsertResponse upsertResponse = new UpsertResponse();
    	try {
	    	upsert kitItem;
	    	upsertResponse.status=STATUS_SUCCESS;
	    	upsertResponse.Id=kitItem.Id;
    	}
    	catch (Exception e) {
    		upsertResponse.status=STATUS_FAIL;
    		upsertResponse.statusDetail=e.getMessage();
    	}
    	return upsertResponse;
    	
    }
    
    global class UpsertResponse {
    	public String Id {get;set;}
    	public String status {get;set;}
    	public String statusDetail {get;set;}
    	
    }
    
    @IsTest
    public static void testUpsertItem () {
    	
    	//Get the current time
    	Datetime now = System.now();
    	
    	Profile p = [select id from profile where name='POS - API User Agency'];
         
		User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id,
		timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
		
		RecordType kitRecordType = [select Id from RecordType where Name='Kit' and sObjectType='Item__c'];
	    RecordType standardRecordType = [select Id from RecordType where Name='Standard' and sObjectType='Item__c'];
		RecordType posAgencyRecordType = [select Id from RecordType where Name='POS Production Agency' and sObjectType='Account'];
		
		
		System.runAs(u) {
	    	
	    	//Create Agency
	    	
			Account agency = POS_TestDataUtil.createProductionAgency();
			
			
			Program__c program = POS_TestDataUtil.createProgram();
	    	
	   	
	    	//Create the kit
	    	Item__c kit = POS_TestDataUtil.createKit(program,agency);
	    	 	
	    	Test.startTest();
	    	//Create an item to add to the kit
	    	Item__c item = POS_TestDataUtil.populateItem(program, agency);
	    	item.RecordType=standardRecordType;
	    	insert item; 
	    	
	    	Kit_Item__c kitItem = new Kit_Item__c();
			kitItem.Kit__c = kit.Id;
			kitItem.Item__c = item.Id;
			kitItem.Packout_Quantity__c = 5;
	    	
	    	System.debug('KIT ITEM:'+kitItem);
		
			//Upsert will fail here because we aren't associated to an agency
			UpsertResponse response = POS_APIUpsertKitItem.doPost(kitItem, new RestResponse());
			System.assert(response==null);
		
			Account_Member__c member = new Account_Member__c();
			member.Account__c = agency.Id;
			member.User__c = u.Id;
			insert member;
			
			//Now it should work
			response = POS_APIUpsertKitItem.doPost(kitItem, new RestResponse());
	    	
	    	System.debug('Response: '+response.statusDetail);
	    	
	    	//Make sure item got added
	    	String kitItemId = response.Id;
	    	List<Kit_Item__c> loadedKitItems = [select Id from Kit_Item__c where Id=:kitItemId];
	    	System.assert(loadedKitItems.size()==1);
	    	
	    	//Test an update
	    	response = POS_APIUpsertKitItem.doPost(kitItem, new RestResponse());
	    	String secondItemId = response.Id;
	    	
	    	//If it reinserted the same record we'd have different results here
	    	System.assert(kitItemId==secondItemId);
	    	
	    	
	    	//Test that it's rejected if the item had the wrong agency isn't there
	    	//Create Agency
		    Account agency2 = POS_TestDataUtil.createProductionAgency();
			
	    	item = POS_TestDataUtil.populateItem(program, agency2);
	    	item.RecordType=standardRecordType;
	    	insert item;
	    	kitItem.Item__c = item.Id;
	    	
	    	try {
	    		response = POS_APIUpsertKitItem.doPost(kitItem, new RestResponse());
	    		System.assert(response==null); //Should be null because it's invalid request
	    	}
	    	catch (Exception e) {
	    		//Expected
	    	}
    	
    		Test.stopTest();
		}
    	
    	
    }
        
     
}