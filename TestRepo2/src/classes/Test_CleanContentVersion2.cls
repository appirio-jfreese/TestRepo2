@isTest
private class Test_CleanContentVersion2 {
	List<File__c> contentDescriptionList;
	class TestSettings {
		List<File__c> contentDescriptionList;
	 	public TestSettings(){
	 		File__c[] cd = [select Id from File__c];
			delete cd;
		
		contentDescriptionList = new File__c[]{
 					Test_Helper.testInsertFile(),
 					Test_Helper.testInsertFile(),
 					Test_Helper.testInsertFile(),
 					Test_Helper.testInsertFile(),
 					Test_Helper.testInsertFile(),
 					Test_Helper.testInsertFile(),
 					Test_Helper.testInsertFile()
 				};
	 	}
	}
	static testmethod void testCleanContentVersion1(){
		TestSettings ts = new TestSettings();
 		
 		Test.StartTest();
 		CleanContentVersion2 jobToDo = new CleanContentVersion2();
		Database.executeBatch(jobToDo);
 		
		Test.StopTest();
		
		/*System.AssertEquals(
           database.countquery('SELECT COUNT()'
              +' from File__c'),
           7); */ 
          
        Set<Id> tsSet = new Set<Id>();
        tsSet.add(ts.contentDescriptionList[0].Id); 
        tsSet.add(ts.contentDescriptionList[1].Id); 
        tsSet.add(ts.contentDescriptionList[2].Id); 
        tsSet.add(ts.contentDescriptionList[3].Id); 
        tsSet.add(ts.contentDescriptionList[4].Id);
        tsSet.add(ts.contentDescriptionList[5].Id); 
        tsSet.add(ts.contentDescriptionList[6].Id);  
        
        File__c[] cds = [select Id from File__c Where Id In :tsSet];
		delete cds;
	}
}