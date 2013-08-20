public with sharing class POS_SiteNavigationController extends Controller_Base  {
	public String baseUrl {get;set;}
	
	public POS_SiteNavigationController () {
		baseUrl = ApexPages.currentPage().getHeaders().get('Host');
	}
	
	@isTest
	public static void testNav () {
		POS_TestDataUtil.initializeTestData();
		PageReference pageRef = Page.HomePage;
       	Test.setCurrentPage(pageRef);
		POS_SiteNavigationController controller = new POS_SiteNavigationController();
	}
}