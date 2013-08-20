@isTest
private class Test_Controller_CodesPolicies {
	
	static testmethod void testController(){
		List <Page_Content__c> pContents = [select id from Page_Content__c where Page_Name__c = :Constant.CODES_POLICIES];
		delete pContents;
		
		PageReference pageRef = Page.CodesPolicies;
        Test.setCurrentPage(pageRef);
		
		Page_Content__c pageContent = new Page_Content__c();
		pageContent.Page_Content_Value__c = 'Test content';
		pageContent.Page_Name__c = Constant.CODES_POLICIES;
		pageContent.Order__c = 1;
		insert pageContent;

 		Test.StartTest();

	 	Controller_CodesPolicies c = new Controller_CodesPolicies();
	 	System.assertEquals(1, c.contentItems.size());

		Test.StopTest();
	}
}