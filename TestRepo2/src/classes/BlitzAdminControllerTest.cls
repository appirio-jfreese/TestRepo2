@isTest
private class BlitzAdminControllerTest {

    static testMethod void testMassArchival() {
    	User inactiveUser = new User(alias = 'unittest', email='unittest@modelmetrics.com', 
	        emailencodingkey='UTF-8', lastname='Testing', 
	        languagelocalekey='en_US', 
	        localesidkey='en_US', profileid = UserInfo.getProfileId(),
	        timezonesidkey='America/Chicago', 
	        username='unittest@modelmetrics.com');
	    insert inactiveUser;
		
    	Account acc = new Account();
    	acc.Name = 'Test Account';
    	insert acc;
    	
    	Blitz__c blitz = new Blitz__c();
    	blitz.Account__c = acc.Id;
    	blitz.OwnerId = inactiveUser.Id;
    	blitz.Amount__c = 27;
    	blitz.Blitz_Brand__c = 'brand';
    	blitz.Blitz_Details__c = 'details';
    	blitz.Blitz_Program__c = 'program';
    	blitz.Comments__c = 'comments';
    	blitz.Date_Finished__c = Date.today().addDays(7);
    	blitz.PDF_Link__c = 'http://google.com';
    	insert blitz;
    	
		inactiveUser.isActive = false;
		update inactiveUser;
    	
    	List<Blitz__c> allBlitzes = [SELECT Id FROM Blitz__c];
    	List<Blitz_History__c> allHistories = [SELECT Id FROM Blitz_History__c];
    	
    	Test.startTest();
    	
    	BlitzAdminController cont = new BlitzAdminController();
    	System.assertEquals(allBlitzes.size(), cont.activeCount);
    	
    	/*
    	inactiveUser.isActive = true;
		update inactiveUser;
    	
    	cont.doMassArchival();
    	
    	Test.stopTest();
    	
    	System.assertEquals(0, [SELECT Id FROM Blitz__c].size());
    	System.assertEquals(allBlitzes.size() + allHistories.size(), [SELECT Id FROM Blitz_History__c].size());
    	*/
    }
}