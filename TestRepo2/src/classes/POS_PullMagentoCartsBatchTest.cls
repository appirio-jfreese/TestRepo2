/**
Test Class for : POS_PullMagentoCartsBatch
Created for case 00005338 by Jai Gupta
**/
@isTest (seeAllData = true)
private class POS_PullMagentoCartsBatchTest {

    
    static testMethod void myUnitTest1() {
    Test.startTest();
        // setup test data
      User u = createStdUser();
      u.Magento_Id__c = '12345';
      update u;
        
        //Create Agency
        Account agency = POS_TestDataUtil.createProductionAgency();
        
        //Create Distributor Account
        Account dist = POS_TestDataUtil.createDistributorAccount();         
        
        Program__c program = POS_TestDataUtil.createProgram();
        Item__c item = POS_TestDataUtil.populateItem(program, agency);
        item.RecordTypeId = [select Id, Name, DeveloperName from RecordType where DeveloperName='Customizable' limit 1].id;
        insert item;
                 
        Item_Customization__c iCust = new Item_Customization__c(Name='Personalization Label 1', Custom_Attribute_Length__c=120, Item__c=item.Id, Magento_Id__c='60');
        insert iCust;
        
        Order_Window__c ow = POS_TestDataUtil.createOrderWindow();
        Cart__c crt = POS_TestDataUtil.createCart(u, ow);
        crt.Magento_ID__c='12345';
        crt.Status__c = 'Open';
        update crt;
        
        Order_Window_Customer__c cust = new Order_Window_Customer__c();
        cust.Order_Window__c = ow.Id;
        cust.Customer__c=u.Id;
        cust.Magento_Id__c='12345';
        insert cust;
        
        
        Cart_Item__c ci = POS_TestDataUtil.populateCartItem(item, crt);
        insert ci;
      
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
       
        req.addParameter('sfdcid', u.id);
        req.addParameter('magentoid', u.Magento_Id__c);
        req.addParameter('cart_id','12345');
    
        req.requestURI =  POS_Magento_Configuration__c.getOrgDefaults().Salesforce_apexrest_uri__c +'syncmagentocart';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Database.executeBatch(new POS_PullMagentoCartsBatch('12345'));
        
        Test.stopTest();
    }
    
    private static User createStdUser(){
        Profile p = [select id from profile where name='Standard User' limit 1]; 
        User testUser = new User(alias = 'standt', email='standarduser@modelmetrics.pos.com', 
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p.Id, firstname='phil',
        timezonesidkey='America/Los_Angeles', username='standarduser'+system.now().getTime()+'@modelmetrics.pos.com');
        insert testUser;
        return testUser ;
    }
}