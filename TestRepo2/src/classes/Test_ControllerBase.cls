/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_ControllerBase {
	static User user; 
	static Account account;
	static Contact c;
	static{
		account = Test_Helper.testInsertAccount('Test Account');
        c = Test_Helper.testInsertContact('TestFirst', 'TestLast', account.ID);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            user = Test_Helper.testInsertDistributorPortalUser(c.ID);
        }
	}
    static testMethod void isInternalUserTest() {
        Test.StartTest();
        System.runAs(user){
            PageReference pageRef = Page.HomePage;
            Test.setCurrentPage(pageRef);
            Controller_Base bController = new Controller_Base();
            System.assertEquals(bController.isInternalUser, false);
        }
        Test.StopTest();
    }    

    static testMethod void userShareOverviewTest() {
        Content_Description__c cDescription = Test_Helper.testInsertContentDescription();

        Test.StartTest();
        
        PageReference pageRef = Page.HomePage;
        Test.setCurrentPage(pageRef);
        
        Controller_Base bController = new Controller_Base();

        bController.userShareOverview();
        System.assertEquals(bController.cDescr, null);
        bController.cVersionId = cDescription.Content_Version_Id__c;
        bController.userShareOverview();
        System.assertEquals(bController.cDescr, cDescription.Description__c);
        System.assertEquals(bController.cVideoId, cDescription.Video_Id__c);
        System.assertEquals(bController.cIsVideo, cDescription.Is_Video__c);
        System.assertEquals(bController.cIsPreview, cDescription.Preview_Available__c);
        System.assertEquals(bController.cPreviewId, cDescription.Preview_Id__c);
        System.assertEquals(bController.cShareLink, cDescription.share_link__c);
        
        Test.StopTest();
    }
    
    static testMethod void showLastPageTest() {

        Test.StartTest();
        
        PageReference pageRef = Page.HomePage;
        Test.setCurrentPage(pageRef);

        Controller_Base bController = new Controller_Base();
        bController.showLastPage();
        System.assertEquals(bController.numberOfCurrentPage, bController.numberOfPages);
        System.assert(bController.numberOfCurrentPage <= bController.numberOfPages);
        System.assert(bController.numberOfCurrentPage >= 1);        
        Test.StopTest();
    }
    
    static testMethod void showFirstPageTest() {

        Test.StartTest();
        
        PageReference pageRef = Page.HomePage;
        Test.setCurrentPage(pageRef);

        Controller_Base bController = new Controller_Base();
        bController.showFirstPage();
        System.assertEquals(bController.numberOfCurrentPage, bController.numberOfPages);
        System.assert(bController.numberOfCurrentPage <= bController.numberOfPages);
        System.assert(bController.numberOfCurrentPage >= 1);        
        Test.StopTest();
    }
    
    static testMethod void showPrevPageTest() {

        Test.StartTest();
        
        PageReference pageRef = Page.HomePage;
        Test.setCurrentPage(pageRef);

        Controller_Base bController = new Controller_Base();
        bController.showPrevPage();
        System.assertEquals(bController.numberOfCurrentPage, bController.numberOfPages);
        System.assert(bController.numberOfCurrentPage <= bController.numberOfPages);
        System.assert(bController.numberOfCurrentPage >= 1);        
        Test.StopTest();
    }
    
    static testMethod void showNextPageTest() {

        Test.StartTest();
        
        PageReference pageRef = Page.HomePage;
        Test.setCurrentPage(pageRef);

        Controller_Base bController = new Controller_Base();
        Integer actualPage = bController.numberOfCurrentPage;
        bController.numberOfPages = 2;
        bController.showNextPage();
        System.assertEquals(bController.numberOfCurrentPage, actualPage+1);
        System.assert(bController.numberOfCurrentPage <= bController.numberOfPages);
        System.assert(bController.numberOfCurrentPage >= 1);
                
        Test.StopTest();
    }
    
    static testMethod void showPageRequestedTest() {

        Test.StartTest();
        
        PageReference pageRef = Page.HomePage;
        Test.setCurrentPage(pageRef);

        Controller_Base bController = new Controller_Base();
        Integer actualPage = bController.numberOfCurrentPage;
        bController.showPageRequested();
        System.assert(bController.numberOfCurrentPage <= bController.numberOfPages);
        System.assert(bController.numberOfCurrentPage >= 1);        
        
        Test.StopTest();
    }

    static testMethod void getRequestedPageTest() {
        
        Test.StartTest();

        PageReference pageRef = Page.HomePage;
        Test.setCurrentPage(pageRef);

        Controller_Base bController = new Controller_Base();
        bController.showFromIndex = 0;
        bController.showToIndex = 0;
        list<sobject> request = new list<sobject>();
        list<sobject> result = bController.getRequestedPage(request);
        System.assert(bController.showFromIndex <= bController.showToIndex);
        System.assert(bController.showFromIndex - bController.showToIndex <= result.size());
        
        Test.StopTest();    
    }
    
    static testMethod void pageNumbersTest() {
        
        Test.StartTest();
        
        PageReference pageRef = Page.HomePage;
        Test.setCurrentPage(pageRef);

        Controller_Base bController = new Controller_Base();
        bController.numberOfItems = 24;
        System.assertEquals(bController.numberOfPages, bController.pageNumbers.size());
        
        Test.StopTest();    
    }
    
    static testMethod void lastLoginTest() {
        
        System.RunAs(user){
            user.loginDate__c = datetime.valueOf('2008-12-01 12:00:00');
            update user;
            Test.StartTest();
            
            PageReference pageRef = Page.HomePage;
            Test.setCurrentPage(pageRef);
            Controller_Base bController = new Controller_Base();
            System.assertEquals(datetime.valueOf('2008-12-01 12:00:00'), bController.lastLoginDate );
            List<String> tmp = bController.distributorNames;
            
            Test.StopTest();    
        }
    }
    
    static testMethod void noOfItemsTest() {
        
        System.RunAs(user){
            user.loginDate__c = datetime.valueOf('2008-12-01 12:00:00');
            update user;
            Test.StartTest();
            
            PageReference pageRef = Page.HomePage;
            Test.setCurrentPage(pageRef);
            Controller_Base bController = new Controller_Base();
            List<SelectOption> tmp = bController.getNumberOfItemsPerPageList();
            bController.numberOfItemsOnPage = 20;
            bController.changeNumberOfItemPerPage();
            
            Test.StopTest();    
        }
    }
    
    static testMethod void themesTest() {
        System.RunAs(user){
            user.loginDate__c = datetime.valueOf('2008-12-01 12:00:00');
            update user;
            Test.StartTest();
            
            PageReference pageRef = Page.HomePage;
            Test.setCurrentPage(pageRef);
            Controller_Base bController = new Controller_Base();
            List<SelectOption> themes = bController.getSiteThemes();
            bController.siteTheme = 'Spirits';
            bController.changeSiteTheme();
            
            Test.StopTest();    
        }
    }
    
    static testMethod void searchTest() {
        
        System.RunAs(user){
            user.loginDate__c = datetime.valueOf('2008-12-01 12:00:00');
            update user;
            Test.StartTest();
            
            PageReference pageRef = Page.HomePage;
            Test.setCurrentPage(pageRef);
            Controller_Base bController = new Controller_Base();
            String tmp = bController.getRandomId();
            bController.searchPhrase = 'abnc';
            bController.userSearch();
            
            Test.StopTest();    
        }
    }
    
    static testmethod void testFollowups(){
        Content_Description__c cd = Test_Helper.testInsertContentDescription();
        
        System.RunAs(user){
            PageReference pageRef = Page.HomePage;
            Test.setCurrentPage(pageRef);
            Controller_Base bController = new Controller_Base();
            bController.cVersionId = cd.id;
            bController.addToFollowMultiple();
            bController.addToFollow();
            Integer followItems = bController.followItemsNo;
            bController.removeFromFollowMultiple();
            bController.removeFromFollow();
        }
    }

    static testmethod void testGetThemeString(){
        
 		Brand__c brand = Test_Helper.testInsertBrand('brand1');
 		Test_Helper.testInsertAccountBrand(account.id, brand.id);
 		       
        System.RunAs(user){
            PageReference pageRef = Page.HomePage;
            Test.setCurrentPage(pageRef);
	        ApexPages.currentPage().getParameters().put('themetype1','Spirits');
            Controller_Base bController = new Controller_Base();
            system.assertEquals('Spirits', bController.themeOptionsString);
        }
    } 
    
    // Start : Code Covergae For Controller Base : Toggle Functionality
    static testmethod void testToggelAndMisc(){
    		
	 		Brand__c brand = Test_Helper.testInsertBrand('brand1');
	 		Test_Helper.testInsertAccountBrand(account.id, brand.id);
	 		
    	Test.startTest();
    	System.runAs (user) {
    		Integer num = Service_API.getUserNumberOfItemsPerPage();
 				PageReference pageRef = Page.HomePage;
 				Test.setCurrentPage(pageRef);
 				Controller_Base bController = new Controller_Base();
 				System.assert(bController.isNeedToggle);
 				bController.toggleToWine();
 				System.assertEquals(bController.clickedTheme, 'Wine');
 				
 				bController.toggleToSpirits();
 				System.assertEquals(bController.clickedTheme, 'Spirits');
 				num = Service_API.getUserNumberOfItemsPerPage();
 				System.assertEquals(Service_API.getSectionTheme(), 'Spirits');
 				String sDefTheme = Service_API.getSectionThemeDefault();
 				String goalFolderId = Service_API.getGoalsFolderId();
 				
 				bController.planningTheme = 'Spirits';
 				pageRef = bController.openPlanningPage();
 				
 				bController.planningTheme = '';
 				pageRef = bController.openPlanningPage();
 				
 				bController.planningTheme = 'Wine';
 				pageRef = bController.openPlanningPage();
 				
 				bController.planningTheme = 'Spirits';
 				pageRef = bController.openPlanningPage();
 				Test.setCurrentPage(pageRef);
 				ApexPages.currentPage().getParameters().put('themetype1','Spirits');
 				System.assert(!bController.isNeedToggle);
 				
 				bController.siteTheme = 'Wine';
 				bController.changeCurrentSiteTheme();
 				System.assertEquals(bController.siteTheme, 'Wine');
 				bController.toggleToSpirits();
 				bController.toggleToWine();
 				
 				bController.siteTheme = '';
 				bController.changeCurrentSiteTheme();
 				System.assertNotEquals(ApexPages.getMessages(), null);
 				bController.siteTheme = 'Spirits';
 				bController.changeCurrentSiteTheme();
 				System.assertEquals(bController.siteTheme, 'Spirits');
 				bController.toggleToWine();
 				bController.toggleToSpirits();
 				
 				bController.changeListOrder();
 				
 				bController.siteTheme = '';
 				bController.changeSiteTheme();
 				System.assertNotEquals(ApexPages.getMessages(), null);
 				
 				//bController.siteTheme = 'Spirits';
 				bController.openSpiritsPlanningPage();
 				
 				//bController.siteTheme = 'Wine';
 				bController.openWinePlanningPage();
    	}
    	Test.stopTest();
    }
    
    static testmethod void testMEPThemes(){
    	    
	 		
	 		Brand__c brand = Test_Helper.testInsertBrand('brand1');
	 		Test_Helper.testInsertAccountBrand(account.id, brand.id);
	 		
	    System.RunAs(user){
		    PageReference pageRef = Page.MonthlyExecutionPlanPDF;
		    Test.setCurrentPage(pageRef);
		    Controller_MonthlyExecutionPlan bController = new Controller_MonthlyExecutionPlan();
		    bController.toggleToSpirits();
		    List<SelectOption> tmp = Service_UserInput.getSiteThemes();
		    for(CheckboxOption cbo : bController.themeOptions){
		    	if(cbo.name.equalsIgnoreCase(Label.CatalystParentTheme)){
		    		System.assert(true);
		    		cbo.chosen = true;
		    		System.assertEquals(cbo.subOptions.size(), 2);
		    		for(CheckboxOption cb : cbo.subOptions){
		    			cb.chosen = true;
		    		}
		    	}
		    }
		    bController.refreshContent();
		    System.assertEquals(bController.themeOptions.size(), tmp.size());
		    
		    for(CheckboxOption cbo : bController.themeOptions){
		    	if(cbo.name.equalsIgnoreCase(Label.CatalystParentTheme)){
		    		System.assert(true);
		    		cbo.chosen = true;
		    		System.assertEquals(cbo.subOptions.size(), 2);
		    		for(CheckboxOption cb : cbo.subOptions){
		    			if(cb.name.equalsIgnoreCase('US Spirits'))
		    				cb.chosen = true;
		    			else
		    				cb.chosen = false;
		    		}
		    	}
		    }
		    bController.refreshContent();
		    System.assertEquals(bController.themeOptions.size(), tmp.size());
	    }
    }
    
    static testmethod void testAllMisc(){
    	   
	 		
	 		Brand__c brand = Test_Helper.testInsertBrand('brand1');
	 		Test_Helper.testInsertAccountBrand(account.id, brand.id);
	 		
	 		Brand__c brand2 = Test_Helper.testInsertBrand('brand2');
	 		Brand__c brand3 = Test_Helper.testInsertChildBrand('ChildBrand1', brand2.Id);
	 		Test_Helper.testInsertAccountBrand(account.id, brand2.id);
	 		Test_Helper.testInsertAccountBrand(account.id, brand3.id);
	 		
	    System.RunAs(user){
	    	PageReference pageRef = Page.HomePage;
		    Test.setCurrentPage(pageRef);
		    Controller_Base bController = new Controller_Base();
		    
	    	System.assertEquals(user.Diageo_Direct_Theme__c, 'Spirits');
	    	System.assertEquals(Service_API.getSectionTheme(), 'Spirits');
	    	user.Diageo_Direct_Theme__c = 'Wine';
	    	update user;
	    	Service_API.prepareSiteThemeAfterLogin(user.Id);
	    	Service_API.refreshUserPreferances();
	    	System.assertNotEquals(Service_API.getSectionTheme(), 'Wine');
	    	
	    	Set<Id> accBrandSet = Service_API.getAccBrandIdsForUser(user.Id);
	    	List<Brand__c> lst = Service_API.getBrandsByCategories(null);
	    	lst = Service_API.getBrandsForFilters('');
	    	lst = Service_API.getParentBrands();
	    	Set<Id> idSet = Service_API.getCalendarBrands();
	    	idSet = Service_API.getAllContentBrandIDs();
	    }
    }
    
    static testmethod void testCheckBoxOption(){
    	CheckBoxOption opParent1 = new CheckboxOption('Parent1', true, false);
    	CheckBoxOption opParent2 = new CheckboxOption('Parent2', true, false);
    	
    	List<CheckBoxOption> subOp = new List<CheckBoxOption>();
    	subOp.add(new CheckboxOption('SubOp1', true, false));
    	subOp.add(new CheckboxOption('SubOp2', true, false));
    	
    	CheckBoxOption opParent3 = new CheckboxOption('Parent3', true, false, subOp);
    	
    	System.assertEquals(opParent1.subOptions.size(), 0);
    	System.assertEquals(opParent2.subOptions.size(), 0);
    	System.assertEquals(opParent3.subOptions.size(), subOp.size());
    }

	static testMethod void testShowAvatar() {
	     User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
	     User u2; 
         System.runAs (thisUser) {
             u2 = Test_Helper.testInsertDiageoEmployee();
         }
	             
	     Test.StartTest();
	
	     System.runAs(user){
             PageReference pageRef = Page.HomePage;
             Test.setCurrentPage(pageRef);
	         Controller_Base bController = new Controller_Base();
	         System.assertEquals(bController.showAvatar,false);
	     }

         System.runAs(u2){
             PageReference pageRef = Page.HomePage;
             Test.setCurrentPage(pageRef);
             Controller_Base bController = new Controller_Base();
             System.assertEquals(bController.showAvatar,true);

             String str = bController.avatarUrl;
             List<String> parts = str.split('/');
             if (parts.size() == 6){
             	String photo='/'+parts[3]+'/'+parts[4]+'/'+parts[5];
                System.assertEquals(photo,'/profilephoto/005/T');
             }
             else{
                System.assertEquals(str,'https://c.cs9.content.force.com/profilephoto/005/T');
             }
         }
	     Test.StopTest();
    }
    // End : Code Covergae For Controller Base : Toggle Functionality
}