public with sharing class POS_OnDemandController extends Controller_Base {
	public String tangerineUrl {get;set;}
	
	public List<POS_BreadCrumb> breadcrumbs {get;set;} 
	
	public POS_OnDemandController () {
		POS_Magento_Configuration__c settings = POS_Magento_Configuration__c.getOrgDefaults();
    	tangerineUrl = settings.Tangerine_Url__c;
    	
    	breadCrumbs = new List<POS_BreadCrumb>();
       	breadCrumbs.add(new POS_BreadCrumb('POS','/apex/POS_OrderWindowView'));
       	breadCrumbs.add(new POS_BreadCrumb('On Demand','#'));
		
	}
	
	@isTest
    public static void testOnDemandController () {
    	Test.startTest();
    	
    	PageReference currPage = new PageReference('/apex/POS_OnDemand');
		Test.setCurrentPage(currPage);
			
    	POS_OnDemandController cont = new POS_OnDemandController();
    	
    	Test.stopTest();
    }
}