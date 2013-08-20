@RestResource(urlMapping='/UpsertItem/*')
global with sharing class POS_APIUpsertItem {
    
    public static String STATUS_SUCCESS='success';
    public static String STATUS_FAIL='fail';
    
    @HttpPost
    global static UpsertResponse doPost (Item__c item, RestResponse res) {
        
        String userId = UserInfo.getUserId();
        
        POSAPIConfiguration__c settings = POSAPIConfiguration__c.getOrgDefaults();
        String PROFILE_NAME = settings.POS_Agency_Profile_Name__c;
        
        List<Account_Member__c> accountMembers = [select a.Account__c from Account_Member__c a where a.User__c= :userId
            and a.Account__r.RecordType.Name = :PROFILE_NAME];
            
        //There should be one and only one agency associated with this account
        if (accountMembers == null || accountMembers.size()!=1) {
            res.StatusCode = 400;
            res.addHeader('Error','Misconfiguration: account not configured for a single POS agency');
            return new UpsertResponse();
            
        }
        
        //They must provide an agency item Id
        if (item.Agency_Item_Id__c==null) {
            res.StatusCode = 400;
            res.addHeader('Error','Agency Item ID is a required field');
            return new UpsertResponse();
        }
        
        //They must set the program if it's a new item
        if (item.Id==null && item.Program__c==null) {
            res.StatusCode = 400;
            res.addHeader('Error','Items must be associated with a valid Program');
            return new UpsertResponse();
        }
        
        Id agency = accountMembers.get(0).Account__c;
        
        UpsertResponse upsertResponse = new UpsertResponse();
        try {
            
            upsertResponse.AgencyItemId=item.Agency_Item_Id__c;
            //Check to see if this is an update
            if (item.Id!=null) {
                //It's an update
                //Get Magento ID from the current version of the item (API should not allow change of Magento ID)
                Id itemId = item.Id;
                Item__c currentItem = [select Magento_Id__c from Item__c where Id=:itemId];
                item.Magento_ID__c=currentItem.Magento_ID__c;
                upsertResponse.Id=item.Id;
                update item;
                upsertResponse.status=STATUS_SUCCESS;
            }
            else {
                item.Agency__c=agency;
                insert item;
                upsertResponse.Id=item.Id;
                upsertResponse.status=STATUS_SUCCESS;
            }
        }
        catch (Exception e) {
            upsertResponse.status=STATUS_FAIL;
            upsertResponse.statusDetail=e.getMessage();
        }
        return upsertResponse;
        
    }
    
    global class UpsertResponse {
        public String Id {get;set;}
        public String AgencyItemId {get;set;}
        public String status {get;set;}
        public String statusDetail {get;set;}
        
    }
    
    @IsTest(SeeAllData=true)
    public static void testUpsertItem () {
        
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
        
            //Now test queries for other filters
            Order_Window__c window = POS_TestDataUtil.createOrderWindow();
            window.Status__c='In Review';
            update window;
            
            Program__c program = POS_TestDataUtil.createProgram();
            Account account = POS_TestDataUtil.createAccount();
            account.RecordTypeId = posAgencyRecordType.Id;
            update account;
            
            
            //Test if this user isn't associated with an agency account
            Item__c item = POS_TestDataUtil.populateItem(program,account);
            item.Agency_Item_Id__c = 'AGENCYID';
            
            RestResponse restResponse = new RestResponse();
            UpsertResponse response = POS_APIUpsertItem.doPost(item, restResponse);
            System.assert(restResponse.StatusCode==400);  //We get 400 because it's not permitted
            
            //Now associate them then try again
            POS_TestDataUtil.createAccountMember(account, u);
            
            restResponse = new RestResponse();
            response = POS_APIUpsertItem.doPost(item, restResponse);
            System.debug('Response: '+restResponse);
            
            //Make sure item got added
            String itemId = response.Id;
            List<Item__c> loadedItems = [select Id, Agency_Item_Id__c from Item__c where Id=:itemId];
            
            System.assert(loadedItems.size()==1);
            
            //Test an update
            restResponse = new RestResponse();
            response = POS_APIUpsertItem.doPost(item, new RestResponse());
            String agencyId = response.AgencyItemId;
            
            //If it reinserted the same record we'd have two results here
            loadedItems = [select Id, Agency_Item_Id__c from Item__c where Agency_Item_Id__c=:agencyId];
            System.assert(loadedItems.size()==1);
            
            
            //Test that it's rejected if the agency ID isn't there
            item = new Item__c();
            item.Program__c = program.Id;
    
            restResponse = new RestResponse();
            response = POS_APIUpsertItem.doPost(item, restResponse);
            System.assert(restResponse.StatusCode==400);  //We get 400 because it's not permitted
            
            //Test if no program is associated
            
            item = new Item__c();
            item.Program__c = null;
            restResponse = new RestResponse();
            response = POS_APIUpsertItem.doPost(item, restResponse);
            System.assert(restResponse.StatusCode==400);  //We get 400 because it's not permitted
            
            
        
        }
    }
        
     
}