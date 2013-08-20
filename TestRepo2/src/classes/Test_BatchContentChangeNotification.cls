/*****************************************************************************
 * Name           : Test_BatchContentChangeNotification
 * Created On     : June 6, 2013
 * Created By     : Parul Gupta(Appirio Offshore)
 * Task Number    : TA1000
 * Implementation : Test class for BatchContentChangeNotification
******************************************************************************/
@isTest
private class Test_BatchContentChangeNotification {

    // Test method for scheduling the batch class.
    public static testmethod void testScheduleContentChangeNotification() {
      
        String CRON_EXP = '0 0 ' + System.now().hour() + ' * * ?';
        System.debug('CRON_EXP ::::::::::::::::: ' + CRON_EXP);
       
        Test.startTest();
        
        // Instance of batch class.
        BatchContentChangeNotification batchCommissions = new BatchContentChangeNotification();
        
        // Schedule the job
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, batchCommissions);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = : jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
    }
    
    // Test method for executing the batch class.
    public static testmethod void testBatchContentChangeNotification() {
        system.debug('::Start::testBatchContentChangeNotification::');
        
        // Create test data 
        createTestData();       
       
        Test.startTest();
       
        // Instance of batch class.
        BatchContentChangeNotification batchCommissions = new BatchContentChangeNotification();
        batchCommissions.sendAckEmail = true;
        
        // Execute batch.
        String batchProcessid = Database.executeBatch(batchCommissions, 200);      
       
        List<AsyncApexJob> jobList = [Select Id
                                      from AsyncApexJob where Id = : batchProcessid];                                                                              
        System.assert(jobList != null);        
        Test.stopTest();
        system.debug('::Stop::testBatchContentChangeNotification::');
    }
    
    // Create test data
    private static void createTestData() {
    	
    	// Create admin test user
        User testUser = Test_Helper.generateTestUser('TUser', false, 'System Administrator');
        testUser.content_Notification_Frequency__c = 'Daily';
        insert testUser;
		system.assert(testUser.id != null);
		
		// Insert notificaiton setting
        Content_Notification__c notificationSetting = new Content_Notification__c();
        notificationSetting.Content_Notification_Retries__c = 3;
        notificationSetting.Delete_Sent_Notification_Threshhold__c = 6;
        insert notificationSetting;     
		
		// Get Collaboration contentworkspace
		ContentWorkspace selectedWorkspace;
		for(ContentWorkspace workspace : [SELECT Name, Id, DefaultRecordTypeId  
                                FROM ContentWorkspace WHERE 
                                DefaultRecordTypeId != NULL 
                                AND Name =: constant.COLLABORATION_LIBRARY LIMIT 1 ]){
        	selectedWorkspace = workspace;
        }
    	system.assert(selectedWorkspace.id != null);
    	
    	// Insert ContentVersion to get contentDocument Id for first time;
    	ContentVersion cVersion = new ContentVersion();
    	cVersion.pathOnClient = 'test1.xml';
	  	cVersion.VersionData = Blob.valueOf('Hello');
	  	cVersion.FirstPublishLocationId = selectedWorkspace.Id;
	  	cVersion.RecordTypeId = selectedWorkspace.defaultRecordTypeId;
	  	cVersion.Description = 'TestDescription1';
    	insert cVersion;
    	system.assert(cVersion.id != null);
    	
    	// Fetch ContentDocument
    	ContentDocument cDoc = [Select id from ContentDocument where id = :[select ContentDocumentId 
    					from ContentVersion where id = :cVersion.id].ContentDocumentId];
    	system.assert(cDoc.id != null);
    	
    	      	
    	// Create Content_Subscription__c
    	Content_Subscription__c sub = new Content_Subscription__c();
    	sub.User__c = testUser.Id;
    	sub.Content__c = cDoc.Id;
    	insert sub;
    	system.assert(sub.id != null); 
    	
    	// Create new ContentVersion
    	cVersion = new ContentVersion();
    	cVersion.pathOnClient = 'test2.xml';
	  	cVersion.VersionData = Blob.valueOf('Hello1');
	  	cVersion.RecordTypeId = selectedWorkspace.defaultRecordTypeId;
	  	cVersion.ReasonForChange = 'Updated';
	  	cVersion.ContentDocumentId = cDoc.id;
	  	cVersion.Description = 'TestUpdatedDescription';
	  	cVersion.Title = 'TitleHello1';
    	insert cVersion;
    	system.assert(cVersion.id != null);
    	
        // Insert a Distributor Portal User
        Account a = Test_Helper.testInsertAccount('Test Account');
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];   
        User u;
        System.runAs (thisUser) {
        	u = Test_Helper.testInsertDistributorPortalUser(c.ID);
        	u.content_Notification_Frequency__c = 'Daily';
        	update u;
        }
        
        // Create content in Distributor Portal Library
        Content_Description__c descp = Test_Helper.testInsertContentDescriptionExtended('TestPortalContent');
        
        ContentVersion portalContentVersion;
        
        // Fetch inserted version
        for(ContentVersion version : [select ContentDocumentId, RecordTypeId 
        							from ContentVersion 
        							where id = :descp.Content_Version_Id__c]){
        	portalContentVersion = version;						
        }
        
        // Follow content as Portal User
        system.runAs(u){
	    	Content_Subscription__c sub1 = new Content_Subscription__c();
	    	sub1.User__c = u.Id;
	    	sub1.Content__c = portalContentVersion.ContentDocumentId;
	    	insert sub1;
	    	system.assert(sub1.id != null);
        }
        
        // Create new content version
    	ContentVersion pVersion = new ContentVersion();
    	pVersion.pathOnClient = 'testPortal.xml';
	    pVersion.VersionData = Blob.valueOf('Portal File Version2');
	  	pVersion.RecordTypeId = portalContentVersion.RecordTypeId;
	  	pVersion.ReasonForChange = 'Updated';
	  	pVersion.ContentDocumentId = portalContentVersion.ContentDocumentId;
	  	pVersion.Description = 'TestPortalContentDesc';
	  	pVersion.Title = 'TitlePortalContentVersion';
	  	pVersion.Content_Description__c = descp.id;       
    	insert pVersion;   	
    	system.assert(pVersion.id != null);
    	
    	// Update content description with new version
    	descp.Content_Version_Id__c = pVersion.id;
    	update descp;
    	
    	// Update Content_Change_Notification__c with the past date
    	/*List<Content_Change_Notification__c> contentNotList = [Select id, Send_Date__c, Content_Version__c
    													from Content_Change_Notification__c
    													where content_version__c =: pVersion.id
    													or content_version__c =: cVersion.id];
    	contentNotList[0].Send_Date__c = system.today().addDays(-5);
    	contentNotList[1].Send_Date__c = system.today().addDays(-5);
    													 	
		update contentNotList;*/		               
    }   
}