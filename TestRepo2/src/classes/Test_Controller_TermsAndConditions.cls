@isTest
private class Test_Controller_TermsAndConditions {
	
	static testmethod void testController(){
		PageReference pageRef = Page.TermsAndConditions;
        Test.setCurrentPage(pageRef);
        
		List <Page_Content__c> pContents = [select id from Page_Content__c where Page_Name__c = :Constant.TERMS_AND_CONDITIONS];
		delete pContents;
		
		Page_Content__c pageContent = new Page_Content__c();
		pageContent.Page_Content_Value__c = 'Test content';
		pageContent.Page_Name__c = Constant.TERMS_AND_CONDITIONS;
		pageContent.Order__c = 1;
		insert pageContent;

	 	Controller_TermsAndConditions c = new Controller_TermsAndConditions();
	 	System.assertEquals(1, c.contentItems.size());
	}
}