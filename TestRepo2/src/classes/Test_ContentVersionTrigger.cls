/*******************************************************************************
Name        : Test_ContentVersionTrigger.cls

Updated By  : Basant Verma (Appirio Offshore)   
Date        : 6/5/13
Story/Task  : US79/TA1001
Description	: Test Class which provide code coverage for 
									ContentVersionTrigger.trigger and
									ContentVersionTriggerHandler.cls 
*******************************************************************************/
@isTest
private class Test_ContentVersionTrigger {
	private static ContentWorkspace selectedWorkspace;
	private static ContentVersion cVersion;
	private static ContentDocument cDoc;
	private static User testUser;
	private static Content_Subscription__c sub;
	static testMethod void testContentNotification() {
	    Test.startTest();
	    createTestDate();
	    
	    // After Test Data
	    system.assertNotEquals(testUser.Id, null);
	    system.assertNotEquals(cVersion.Id, null);
	    system.assertNotEquals(cDoc.Id, null);
	    system.assertNotEquals(sub.Id, null);
	    
	    // Before Any Version
	    List<Content_Change_Notification__c> notifications = [Select Id, User__c, Content__c 
	    			From Content_Change_Notification__c 
	    				Where User__c = :testUser.Id
	    					AND Content__c = :cDoc.Id];
	   	system.assertEquals(notifications.size(), 0);
	    
	    // Create a new Version
	    ContentVersion cVersion2 = new ContentVersion();
	    cVersion2.ContentDocumentId = cDoc.Id;
	    cVersion2.ReasonForChange = 'TestClass';
	    cVersion2.pathOnClient = 'test1.xml';
		  cVersion2.VersionData = Blob.valueOf('Hello');
		  cVersion2.RecordTypeId = selectedWorkspace.defaultRecordTypeId;
		  cVersion2.Description = 'UpdatedTest';
	    insert cVersion2;
	    system.assertNotEquals(cVersion2.Id, null);
	    
	    // After a Version
	    notifications = [Select Id, User__c, Content__c 
	    			From Content_Change_Notification__c 
	    				Where User__c = :testUser.Id
	    					AND Content__c = :cDoc.Id];
	   	system.assertEquals(notifications.size(), 1);
	    
	    Test.stopTest();
	}
	
	private static void createTestDate(){
		testUser = Test_Helper.generateTestUser('TUser', false, 'System Administrator');
		testUser.content_Notification_Frequency__c = 'Real Time';
        insert testUser;
		
		selectedWorkspace = [SELECT Name, Id, DefaultRecordTypeId  
                                FROM ContentWorkspace WHERE 
                                DefaultRecordTypeId != NULL LIMIT 1 ];
    
    	//Insert ContentVersion to get contentDocument Id for first time;
    	cVersion = new ContentVersion();
    	cVersion.pathOnClient = 'test1.xml';
	  	cVersion.VersionData = Blob.valueOf('Hello');
	  	cVersion.ReasonForChange = 'Created';
	  	cVersion.FirstPublishLocationId = selectedWorkspace.Id;
	  	cVersion.RecordTypeId = selectedWorkspace.defaultRecordTypeId;
	  	cVersion.Description = 'TestDesc';
    	insert cVersion;
    
    	// Fetch ContentDocument
    	cDoc = [Select id from ContentDocument where id = :[select ContentDocumentId 
    					from ContentVersion where id = :cVersion.id].ContentDocumentId];
    
    	sub = new Content_Subscription__c();
    	sub.User__c = testUser.Id;
    	sub.Content__c = cDoc.Id;
    	insert sub;
	}
}