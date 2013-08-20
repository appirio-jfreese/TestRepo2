@isTest
private class Test_Controller_Links {

	class TestSettings {
		public TestSettings(){
			
			List <Hyperlink__c> links = [select id from Hyperlink__c];
			delete links;
			Test_Helper.testInsertLink('url', 'name', 'Brand');
			Test_Helper.testInsertLink('url', 'name', 'Brand');
			Test_Helper.testInsertLink('url', 'name', 'Brand');
			Test_Helper.testInsertLink('url', 'name', 'Industry');
			Test_Helper.testInsertLink('url', 'name', 'Industry');
			Test_Helper.testInsertLink('url', 'name', 'Facebook');
			Test_Helper.testInsertLink('url', 'name', 'Facebook');
			Test_Helper.testInsertLink('url', 'name', 'Facebook');
			Test_Helper.testInsertLink('url', 'name', 'Facebook');
		}
	}
	
	static testmethod void testLinks(){
		PageReference pageRef = Page.Links;
        Test.setCurrentPage(pageRef);
        
	 	TestSettings ts = new  TestSettings();
	 	Controller_Links c = new Controller_Links();
	 	System.assertEquals(3, c.brandLinks.size());
	 	System.assertEquals(4, c.facebookLinks.size());
	 	System.assertEquals(2, c.industryLinks.size());
	}
}