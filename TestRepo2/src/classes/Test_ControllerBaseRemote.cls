@isTest
private class Test_ControllerBaseRemote {

     static testMethod void testController1() {
	
        Account a = Test_Helper.testInsertAccount('Test Account');
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];   
        User u;
      	System.runAs (thisUser) {
        	u = Test_Helper.testInsertDistributorPortalUser(c.ID);
      	}
      	
    	Test.StartTest();    
    	System.runAs(u){	
	    	String searchFor = 'mar';
	       	Controller_BaseRemote.getPossibleShareUsers(searchFor, '');
	       	Controller_BaseRemote.downloadVideoFromBC('1234');
	       	Controller_BaseRemote cc  = new Controller_BaseRemote();
	       	Controller_Base		  bb  = new Controller_Base();
	       	Controller_BaseRemote dd = new Controller_BaseRemote(bb);
	       	
	       	Controller_BaseRemote.searchPILBrand('Smirnoff');
    	}       	
       	Test.StopTest();
     }
      
      static testmethod void testController(){
        // insert test user data  
        Account a = Test_Helper.testInsertAccount('Test Account');
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];   
        User u;
      	System.runAs (thisUser) {
        	u = Test_Helper.testInsertDistributorPortalUser(c.ID);
      	}
        
        // insert test brands
        Brand__c brandA = Test_Helper.testInsertBrand('Test Brand A');
        
        // hook one of the parent brands too the user's account
        AccountBrand__c accBrand = Test_Helper.testInsertAccountBrand(a.ID, brandA.ID);
        
        // insert test content that looks up to the previoulsy inserted brands 
        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        Content_Description__c contentC = Test_Helper.testInsertContentDescriptionExtended('tulip');
		
		contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
		contentA.Content_Version_Id__c = null;
		update contentA;
		
        // insert the join records between content and brand        
        ContentBrand__c cbA = Test_Helper.testInsertContentBrand(contentA.id, brandA.id);
        ContentBrand__c cbB = Test_Helper.testInsertContentBrand(contentB.id, brandA.id);
        ContentBrand__c cbC = Test_Helper.testInsertContentBrand(contentC.id, brandA.id);

        Test.startTest();

        System.runAs(u){       	
	  		    
		    Controller_BaseRemote.cacheDownload(contentB.Content_Version_Id__c);
       		Controller_BaseRemote.cacheDownload(contentA.Content_Version_Id_Low__c);
       		
       		Controller_BaseRemote.searchPILBrand('Smirnoff');
        }
        
        Test.stopTest();
    }
}