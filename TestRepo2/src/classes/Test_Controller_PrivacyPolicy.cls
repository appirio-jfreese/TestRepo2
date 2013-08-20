@isTest
private class Test_Controller_PrivacyPolicy {
	
	static testmethod void testController(){
		PageReference pageRef = Page.PrivacyPolicy;
        Test.setCurrentPage(pageRef);
        
		List <Page_Content__c> pContents = [select id from Page_Content__c where Page_Name__c = :Constant.PRIVACY_POLICY];
		delete pContents;
		
		Page_Content__c pageContent = new Page_Content__c();
		pageContent.Page_Content_Value__c = 'Test content';
		pageContent.Page_Name__c = Constant.PRIVACY_POLICY;
		pageContent.Order__c = 1;
		insert pageContent;

	 	Controller_PrivacyPolicy c = new Controller_PrivacyPolicy();
	 	System.assertEquals(1, c.contentItems.size());
	}
}