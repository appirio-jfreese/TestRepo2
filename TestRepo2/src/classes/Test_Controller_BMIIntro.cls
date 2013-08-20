@isTest
private class Test_Controller_BMIIntro {

	static testmethod void testSections(){
		
		   PageReference pageRef = Page.BMIIntro;
           Test.setCurrentPage(pageRef);
		
           Controller_BMIIntro c = new Controller_BMIIntro();
          
       }
}