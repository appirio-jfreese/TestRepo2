@isTest
private class Test_Controller_FAQ {

	class TestSettings {
		public TestSettings(){
			
			List <FAQ__c> faqs = [select id, Question__c, Answer__c from FAQ__c];
			delete faqs;
			Test_Helper.testInsertFAQ('q1', 'a1');
			Test_Helper.testInsertFAQ('q2', 'a2');
			Test_Helper.testInsertFAQ('q3', 'a3');
			Test_Helper.testInsertFAQ('q4', 'a4');
			Test_Helper.testInsertFAQ('q5', 'a5');
			Test_Helper.testInsertFAQ('q6', 'a6');
		}
	}
	
	static testmethod void testFaq(){
		
		PageReference pageRef = Page.FAQ;
        Test.setCurrentPage(pageRef);
		
	 	TestSettings ts = new  TestSettings();
	 	Controller_FAQ c = new Controller_FAQ();
	 	System.assertEquals(6, c.faqs.size());
	}
}