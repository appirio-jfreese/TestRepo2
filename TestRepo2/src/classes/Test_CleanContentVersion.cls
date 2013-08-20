@isTest
private class Test_CleanContentVersion {
	
	List<Content_Description__c> contentDescriptionList;
	class TestSettings {
		List<Content_Description__c> contentDescriptionList;
	 	public TestSettings(){
	 		Content_Description__c[] cd = [select Id from Content_Description__c];
			delete cd;
		
		contentDescriptionList = new Content_Description__c[]{
 					Test_Helper.testInsertContentDescriptionExtended('title1'),
 					Test_Helper.testInsertContentDescriptionExtended('title2'),
 					Test_Helper.testInsertContentDescriptionExtended('title3'),
 					Test_Helper.testInsertContentDescriptionExtended('title4'),
 					Test_Helper.testInsertContentDescriptionExtended('title5'),
 					Test_Helper.testInsertContentDescriptionExtended('title6'),
 					Test_Helper.testInsertContentDescriptionExtended('title7')
 				};
	 	}
	}
	static testmethod void testCleanContentVersion1(){
		TestSettings ts = new TestSettings();
		
 		ts.contentDescriptionList[0].Content_Version_Id__c = null;
 		ts.contentDescriptionList[0].Content_Version_Id_Low__c = null;
 		update ts.contentDescriptionList[0];
 		
 		
 		Test.StartTest();
 		CleanContentVersion jobToDo = new CleanContentVersion();
		Database.executeBatch(jobToDo);
 		
		Test.StopTest();
		
		/*System.AssertEquals(
           database.countquery('SELECT COUNT()'
              +' from Content_Description__c'),
           7);  */
          
        Set<Id> tsSet = new Set<Id>();
        tsSet.add(ts.contentDescriptionList[0].Id); 
        tsSet.add(ts.contentDescriptionList[1].Id); 
        tsSet.add(ts.contentDescriptionList[2].Id); 
        tsSet.add(ts.contentDescriptionList[3].Id); 
        tsSet.add(ts.contentDescriptionList[4].Id);
        tsSet.add(ts.contentDescriptionList[5].Id); 
        tsSet.add(ts.contentDescriptionList[6].Id);  
        
        Content_Description__c[] cds = [select Id from Content_Description__c Where Id In :tsSet];
		delete cds;      
	}
	
	static testmethod void testCleanContentVersion2(){
		TestSettings ts = new TestSettings();
		
 		ts.contentDescriptionList[0].Content_Version_Id_Low__c = null;
 		update ts.contentDescriptionList[0];
 		
 		List<ContentDocument> contentDocuments = [SELECT id FROM ContentDocument WHERE LatestPublishedVersionId = :ts.contentDescriptionList[0].Content_Version_Id__c];                    	
		delete contentDocuments;
		
 		Test.StartTest();
 		CleanContentVersion jobToDo = new CleanContentVersion();
		Database.executeBatch(jobToDo);
 		
		Test.StopTest();
		
		/*
		System.AssertEquals(
           6, database.countquery('SELECT COUNT()'
              +' from Content_Description__c')
           ); */
           
        Set<Id> tsSet = new Set<Id>();
        tsSet.add(ts.contentDescriptionList[0].Id); 
        tsSet.add(ts.contentDescriptionList[1].Id); 
        tsSet.add(ts.contentDescriptionList[2].Id); 
        tsSet.add(ts.contentDescriptionList[3].Id); 
        tsSet.add(ts.contentDescriptionList[4].Id);
        tsSet.add(ts.contentDescriptionList[5].Id); 
        tsSet.add(ts.contentDescriptionList[6].Id);  
        
        Content_Description__c[] cds = [select Id from Content_Description__c Where Id In :tsSet];
		delete cds;       
	}
	
	static testmethod void testCleanContentVersion3(){
		TestSettings ts = new TestSettings();
		
 		ts.contentDescriptionList[0].Content_Version_Id__c = null;
 		ts.contentDescriptionList[0].Content_Version_Id_Low__c = ts.contentDescriptionList[1].Content_Version_Id__c;
 		update ts.contentDescriptionList[0];
 		
 		List<ContentDocument> contentDocuments = [SELECT id FROM ContentDocument WHERE LatestPublishedVersionId = :ts.contentDescriptionList[0].Content_Version_Id_Low__c];                    	
		delete contentDocuments;
		
 		Test.StartTest();
 		CleanContentVersion jobToDo = new CleanContentVersion();
		Database.executeBatch(jobToDo);
 		
		Test.StopTest();
		
		/*System.AssertEquals(
           5, database.countquery('SELECT COUNT()'
              +' from Content_Description__c'));  */
		
		Set<Id> tsSet = new Set<Id>();
        tsSet.add(ts.contentDescriptionList[0].Id); 
        tsSet.add(ts.contentDescriptionList[1].Id); 
        tsSet.add(ts.contentDescriptionList[2].Id); 
        tsSet.add(ts.contentDescriptionList[3].Id); 
        tsSet.add(ts.contentDescriptionList[4].Id);
        tsSet.add(ts.contentDescriptionList[5].Id); 
        tsSet.add(ts.contentDescriptionList[6].Id);  
        
        Content_Description__c[] cds = [select Id from Content_Description__c Where Id In :tsSet];
		delete cds;      
	}
	
	static testmethod void testCleanContentVersion4(){
		TestSettings ts = new TestSettings();
		
 		ts.contentDescriptionList[0].Content_Version_Id_Low__c = ts.contentDescriptionList[0].Content_Version_Id__c;
 		update ts.contentDescriptionList[0];
 		
 		ts.contentDescriptionList[2].Content_Version_Id_Low__c = ts.contentDescriptionList[1].Content_Version_Id__c;
 		update ts.contentDescriptionList[2];
 		
 		List<ContentDocument> contentDocuments = [SELECT id FROM ContentDocument WHERE LatestPublishedVersionId = :ts.contentDescriptionList[0].Content_Version_Id_Low__c or LatestPublishedVersionId = :ts.contentDescriptionList[1].Content_Version_Id_Low__c ];                    	
		delete contentDocuments;
		
 		Test.StartTest();
 		CleanContentVersion jobToDo = new CleanContentVersion();
		Database.executeBatch(jobToDo);
 		
		Test.StopTest();
		
/* @todo check it on production
		System.AssertEquals(
           6, database.countquery('SELECT COUNT()'
              +' from Content_Description__c'));  
*/	   
	    Set<Id> tsSet = new Set<Id>();
        tsSet.add(ts.contentDescriptionList[0].Id); 
        tsSet.add(ts.contentDescriptionList[1].Id); 
        tsSet.add(ts.contentDescriptionList[2].Id); 
        tsSet.add(ts.contentDescriptionList[3].Id); 
        tsSet.add(ts.contentDescriptionList[4].Id);
        tsSet.add(ts.contentDescriptionList[5].Id); 
        tsSet.add(ts.contentDescriptionList[6].Id);  
        
        Content_Description__c[] cds = [select Id from Content_Description__c Where Id In :tsSet];
		delete cds;      
	}
}