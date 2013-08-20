@isTest
private class Test_Controller_SearchResult {
    static User u; 
    static testmethod void testController(){
        PageReference pageRef = Page.SearchResult;
        Test.setCurrentPage(pageRef);
        
        Test.StartTest();
        createTestData();
        
        ApexPages.currentPage().getParameters().put('query', 'testquery');

        System.runAs(u){
            Controller_SearchResult controller = new Controller_SearchResult();
            System.assertEquals(controller.isDetails, false);
            controller.currentSection = Constant.BRAND_MARKETING_INFORMATION;

            controller.switchSection();
            System.assertEquals(controller.isDetails, true);
            System.assertEquals(controller.contentHolderMap.size()>0,true);
            System.assertEquals(controller.contentDownloadShare.size(),0);
            System.assertEquals(controller.sectionContentHolder.size(),0);
                        
            controller.clearSection();
            System.assertEquals(controller.isDetails, false);
            System.assertEquals(controller.firstZeroResult, false);
            System.assertEquals(controller.secondZeroResult, false);
            System.assertEquals(controller.sectionContent.size(), 0);
            System.assertEquals(controller.limitPerSection>0,true);
            controller.R_usersearchOrdertBy();
            controller.userResearch();
            
                   
       }   

        Test.StopTest();
    }
    
    static testmethod void testControllerForResponsive(){
        PageReference pageRef = Page.R_SearchResult;
        Test.setCurrentPage(pageRef);
        
        Test.StartTest();
        createTestData();
        ApexPages.currentPage().getParameters().put('query', 'test');

        System.runAs(u){
            Controller_SearchResult controller = new Controller_SearchResult();
            System.assertEquals(controller.isInternalUser, false);
            controller.currentSection = Constant.BRAND_MARKETING_INFORMATION;

            controller.switchSection();
            System.assertEquals(controller.isDetails, true);
            controller.R_OrdertByDate = 'ASC';
            controller.R_usersearchOrdertBy();
            controller.searchPhrase ='Test';
            controller.userResearch();
            
                   
       }   

        Test.StopTest();
    }
    
    static void createTestData(){
    	//Account diageo = Test_Helper.testInsertAccount('DIAGEO');
    	Account a = Test_Helper.testInsertAccount('DIAGEO');
    	for(Id recId : Service_API.getAccountRecordTypeIds()){
    		a.RecordTypeId = recId;
    		break;
    	}
    	update a;
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs (thisUser) {
            u = Test_Helper.testInsertDistributorPortalUser(c.ID);
        }
                
        Brand__c testBrand1 = Test_Helper.testInsertBrand('Test Brand1');
        Brand__c testBrand2 = Test_Helper.testInsertBrand('Test Brand2');
        
        Test_Helper.testInsertAccountBrand(a.ID, testBrand1.ID);
        Test_Helper.testInsertAccountBrand(a.ID, testBrand2.ID);     
    }
}