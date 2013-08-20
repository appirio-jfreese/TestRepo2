@isTest
private class Test_Controller_PIL {

    static testmethod void testConstructorSpirits(){
        PageReference pageRef = Page.PIL;
        Test.setCurrentPage(pageRef);
        
        Test.StartTest();
        Account a = Test_Helper.testInsertAccount('Test Account');
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User u; 
        System.runAs (thisUser) {
            u = Test_Helper.testInsertDistributorPortalUser(c.ID);
        }
                
        Brand__c testBrand1 = new Brand__c();
        testBrand1.Name = 'Test Brand1';
        testBrand1.Classification__c = 'Spirits';
        testBrand1.Core_Trademarks__c = true;
        testBrand1.diageo_direct_visible__c = true;
        insert testBrand1;
        
        Brand__c testBrand2 = new Brand__c();
        testBrand2.Name = 'Test Brand2';
        testBrand2.Classification__c = 'Spirits';
        testBrand2.Reserve_Brand__c = true;
        testBrand2.diageo_direct_visible__c = true;
        insert testBrand2;
        
        Brand__c testBrand3 = new Brand__c();
        testBrand3.Name = 'Test Brand3';
        testBrand3.Classification__c = 'Spirits';
        testBrand3.diageo_direct_visible__c = true;
        insert testBrand3;
        
        Brand__c testBrand4 = new Brand__c();
        testBrand4.Name = 'Test Brand3';
        testBrand4.Classification__c = 'Spirits';
        testBrand4.Innovation__c = true;
        testBrand4.diageo_direct_visible__c = true;
        insert testBrand4;

        Test_Helper.testInsertAccountBrand(a.ID, testBrand1.ID);
        Test_Helper.testInsertAccountBrand(a.ID, testBrand2.ID);
        Test_Helper.testInsertAccountBrand(a.ID, testBrand3.ID);
        Test_Helper.testInsertAccountBrand(a.ID, testBrand4.ID);

        System.runAs(u){
            Controller_PIL controller = new Controller_PIL();
        }   

        Test.StopTest();  
    }
    
    static testmethod void testConstructorWine(){
        PageReference pageRef = Page.PIL;
        Test.setCurrentPage(pageRef);
        
        Test.StartTest();
        Account a = Test_Helper.testInsertAccount('Test Account');
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User u; 
        System.runAs (thisUser) {
            u = Test_Helper.testInsertDistributorPortalUser(c.ID);
            u.Diageo_Direct_Theme__c = 'Wine';
            update u;
        }
                
        Brand__c testBrand1 = new Brand__c();
        testBrand1.Name = 'Test Brand1';
        testBrand1.Classification__c = 'Wine';
        testBrand1.Core_Trademarks__c = true;
        testBrand1.diageo_direct_visible__c = true;
        insert testBrand1;
        
        Brand__c testBrand2 = new Brand__c();
        testBrand2.Name = 'Test Brand2';
        testBrand2.Classification__c = 'Wine';
        testBrand2.Reserve_Brand__c = true;
        testBrand2.diageo_direct_visible__c = true;
        insert testBrand2;
        
        Brand__c testBrand3 = new Brand__c();
        testBrand3.Name = 'Test Brand3';
        testBrand3.Classification__c = 'Wine';
        testBrand3.diageo_direct_visible__c = true;
        insert testBrand3;
        
        Brand__c testBrand4 = new Brand__c();
        testBrand4.Name = 'Test Brand3';
        testBrand4.Classification__c = 'Wine';
        testBrand4.Innovation__c = true;
        testBrand4.diageo_direct_visible__c = true;
        insert testBrand4;
        
        Brand__c testBrand5 = new Brand__c();
        testBrand5.Name = 'Test Brand3';
        testBrand5.Classification__c = 'Wine';
        testBrand5.Innovation__c = true;
        testBrand5.diageo_direct_visible__c = true;
        testBrand5.Heritage__c = true;
        insert testBrand5;
        
        Brand__c testBrand6 = new Brand__c();
        testBrand6.Name = 'Test Brand3';
        testBrand6.Classification__c = 'Wine';
        testBrand6.Innovation__c = true;
        testBrand6.diageo_direct_visible__c = true;
        testBrand6.Lifestyle__c = true;
        insert testBrand6;
        
        Brand__c testBrand7 = new Brand__c();
        testBrand7.Name = 'Test Brand3';
        testBrand7.Classification__c = 'Wine';
        testBrand7.Innovation__c = true;
        testBrand7.diageo_direct_visible__c = true;
        testBrand7.Luxury__c = true;
        insert testBrand7;

        Test_Helper.testInsertAccountBrand(a.ID, testBrand1.ID);
        Test_Helper.testInsertAccountBrand(a.ID, testBrand2.ID);
        Test_Helper.testInsertAccountBrand(a.ID, testBrand3.ID);
        Test_Helper.testInsertAccountBrand(a.ID, testBrand4.ID);
        Test_Helper.testInsertAccountBrand(a.ID, testBrand5.ID);
        Test_Helper.testInsertAccountBrand(a.ID, testBrand6.ID);
        Test_Helper.testInsertAccountBrand(a.ID, testBrand7.ID);

        System.runAs(u){
            Controller_PIL controller = new Controller_PIL();
        }   

        Test.StopTest();  
    }
    
    static testMethod void testAddAdditionalBrands(){
        PageReference pageRef = Page.PIL;
        Test.setCurrentPage(pageRef);
        
        Test.StartTest();
        Account a = Test_Helper.testInsertAccount('Test Account');
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User u; 
        System.runAs (thisUser) {
            u = Test_Helper.testInsertDistributorPortalUser(c.ID);
        }
        
        Brand__c testBrand = new Brand__c();
        testBrand.Name = 'Test Brand1';
		testBrand.Classification__c = 'Spirits';
        testBrand.diageo_direct_visible__c = true;
        insert testBrand;
        
        Test_Helper.testInsertAccountBrand(a.ID, testBrand.ID);     
        
        System.runAs(u){
            Controller_PIL controller = new Controller_PIL();
            controller.addAdditionalBrands(testBrand);
            System.assertNotEquals(null, controller.additionalBrandsMap.get(controller.additionalBrandsMap.size()));
        }

        Test.StopTest();  
    }
    
    static testMethod void testSwitchSection(){
        PageReference pageRef = Page.PIL;
        Test.setCurrentPage(pageRef);
        
        Test.StartTest();
        Account a = Test_Helper.testInsertAccount('Test Account');
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User u; 
        System.runAs (thisUser) {
            u = Test_Helper.testInsertDistributorPortalUser(c.ID);
        }
        
        Brand__c testBrand = new Brand__c();
        testBrand.Name = 'Test Brand1';
		testBrand.Classification__c = 'Spirits';
        testBrand.diageo_direct_visible__c = true;
        insert testBrand;
        
        Test_Helper.testInsertAccountBrand(a.ID, testBrand.ID);     
        
        System.runAs(u){
            Controller_PIL controller = new Controller_PIL();
            controller.switchSection();
            controller.currentSection = Constant.PRODUCT_SHOTS;
            controller.switchSection();
            controller.currentSection = Constant.LOGOS;
            controller.switchSection();
            controller.currentSection = Constant.FAMILY_SHOTS;
            controller.switchSection();
        }

        Test.StopTest();
    }
    
    static testMethod void testShowContent(){
        PageReference pageRef = Page.PIL;
        Test.setCurrentPage(pageRef);
        
        Test.StartTest();
        Account a = Test_Helper.testInsertAccount('Test Account');
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User u; 
        System.runAs (thisUser) {
            u = Test_Helper.testInsertDistributorPortalUser(c.ID);
        }
        
        Brand__c testBrand = new Brand__c();
        testBrand.Name = 'Test Brand1';
		testBrand.Classification__c = 'Spirits';
        testBrand.diageo_direct_visible__c = true;
        insert testBrand;
        
        Brand__c testBrandChild = new Brand__c();
        testBrandChild.Name = 'child';
        testBrandChild.Parent_Brand__c = testBrand.Id;
        testBrandChild.Brand_Variant_Grouping__c = 'abc';
		testBrandChild.Classification__c = 'Spirits';
        testBrandChild.diageo_direct_visible__c = true;
        insert testBrandChild;
        
        Test_Helper.testInsertAccountBrand(a.ID, testBrand.ID);
        Test_Helper.testInsertAccountBrand(a.ID, testBrandChild.ID);
        
        System.runAs(u){
            Controller_PIL controller = new Controller_PIL();
            controller.detailID = testBrand.Id;
            controller.showContent();
            String str = controller.currentSubBrandGroupName;
            controller.renderAsList();
            controller.renderAsBox();
            controller.getCategories();
            List<AggregateResultHolder> contentHolder = controller.contentHolder;
        }   

        Test.StopTest();
    }
    
    static testMethod void testRefreshPageContent(){
        PageReference pageRef = Page.PIL;
        Test.setCurrentPage(pageRef);
        
        Test.StartTest();
        Account a = Test_Helper.testInsertAccount('Test Account');
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User u; 
        System.runAs (thisUser) {
            u = Test_Helper.testInsertDistributorPortalUser(c.ID);
        }
        
        Brand__c testBrand = new Brand__c();
        testBrand.Name = 'Test Brand1';
        testBrand.Classification__c = 'Spirits';
        testBrand.diageo_direct_visible__c = true;
        insert testBrand;
        
        Test_Helper.testInsertAccountBrand(a.ID, testBrand.ID);
        
        ContentVersion contentA = Test_Helper.testInsertDistributorContent('rose', 'http://pixabay.com/static/uploads/photo/2011/05/31/21/33/rose-7771_150.jpg', null);
        
        Content_Property__c propertyA = Test_Helper.testInsertContentProperty('rose', null, contentA.Content_Description__c, Constant.PRODUCT_IMAGES_AND_LOGOS, null, null, null);
        
        ContentBrand__c cbA = Test_Helper.testInsertContentBrand(contentA.Content_Description__c, testBrand.id);
        System.runAs(u){
	        List<String> tmp = new List<String>{testBrand.id};
	        System.assert(!([
	                SELECT Content_Description__r.Content_ID__c 
	                FROM ContentBrand__c
	                WHERE (Content_Description__c in (select Content_Description__c from Content_Property__c where category__c = :Constant.PRODUCT_IMAGES_AND_LOGOS))
	            	and (
	                    	(Brand__c IN :tmp) and brand__c in :Service_API.getAccBrandIds()
	                    )
	            ]).isEmpty());
	        
	        System.assert(!(Service_API.getContentBrandIDs(new List<String>{testBrand.id} ,Constant.PRODUCT_IMAGES_AND_LOGOS, true)).isEmpty());
        
            Controller_PIL controller = new Controller_PIL();
            controller.selectedBrandIds = testBrand.Id;
            controller.selectedbottleSizes = new List<String>{'750'};
            controller.refreshPageContent();
        }   

        Test.StopTest();
    }

}