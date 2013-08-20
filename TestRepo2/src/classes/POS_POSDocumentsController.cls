public with sharing class POS_POSDocumentsController extends Controller_Base {
    public String tangerineUrl {get;set;}
    public String monthlyOrderingUrl {get;set;}
    public String quarterlyOrderingUrl {get;set;}
    
    public List<POS_BreadCrumb> breadcrumbs {get;set;} 
    
    public POS_POSDocumentsController () {
        POS_Magento_Configuration__c settings = POS_Magento_Configuration__c.getOrgDefaults();
        tangerineUrl = settings.Tangerine_Url__c;
        monthlyOrderingUrl = settings.Monthly_Ordering_Url__c;
        quarterlyOrderingUrl = settings.Quarterly_Ordering_Url__c;
        
        breadCrumbs = new List<POS_BreadCrumb>();
        breadCrumbs.add(new POS_BreadCrumb('POS','/apex/POS_OrderWindowView'));
        breadCrumbs.add(new POS_BreadCrumb('POS Documents','#'));
        
    }
    
    @isTest
    public static void testOnDemandController () {
        Test.startTest();
        
        PageReference currPage = new PageReference('/apex/POS_POSDocuments');
        Test.setCurrentPage(currPage);
            
        POS_POSDocumentsController cont = new POS_POSDocumentsController();
        
        Test.stopTest();
    }
}