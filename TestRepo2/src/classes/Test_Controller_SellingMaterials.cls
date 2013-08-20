@isTest
private class Test_Controller_SellingMaterials{

       class TestSettings {
           Contact contact;
           Account account;
           User user;
           Brand__c[] childBrands1;
           Brand__c[] childBrands2;
           Brand__c[] parentBrands;
           Brand__c testBrand;
           Brand__c failBrand;
           
           Calendar__c[] calendars;
           Content_Description__c[] contentDescriptionList;
           Content_Property__c[] contentPropertyList;
           
           String baseDate;
           public TestSettings(){
                 account = Test_Helper.testInsertAccount('test_account1');
                 contact = Test_Helper.testInsertContact('firstName', 'lastName', account.id);
                 User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
                 System.runAs (thisUser) {
                     user = Test_Helper.testInsertDistributorPortalUser(contact.id);
                 }
                 
                 parentBrands = new Brand__c[]{
                     Test_Helper.testCreateBrand('parentBrand1', null, 'Gin'),
                     Test_Helper.testCreateBrand('parentBrand2', null, 'Scotch'),
                     Test_Helper.testCreateBrand('testBrand', null, 'Gin'),
                     Test_Helper.testCreateBrand('failBrand', null, null)
                 };
                 
                 insert parentBrands;
                 
                 Test_Helper.testInsertAccountBrand(account.ID, parentBrands[2].ID);
                 Test_Helper.testInsertAccountBrand(account.ID, parentBrands[0].ID);
                 
                 childBrands1 = new Brand__c[]{
                     Test_Helper.testCreateBrand('childBrand1_1', parentBrands[0].id, 'Gin'),
                     Test_Helper.testCreateBrand('childBrand1_2', parentBrands[0].id, 'Gin'),
                     Test_Helper.testCreateBrand('childBrand1_3', parentBrands[0].id, 'Gin'),
                     Test_Helper.testCreateBrand('childBrand1_4', parentBrands[0].id, 'Gin')
                 };
                 
                 insert childBrands1;
                 
                 childBrands2 = new Brand__c[]{
                     Test_Helper.testCreateBrand('childBrand2_1', parentBrands[1].id, null),
                     Test_Helper.testCreateBrand('childBrand2_2', parentBrands[1].id, null),
                     Test_Helper.testCreateBrand('childBrand2_3', parentBrands[1].id, null)
                 };
                 
                 insert childBrands2;
                 
                 Test_Helper.testInsertAccountBrand(account.ID, childBrands1);
                 Test_Helper.testInsertAccountBrand(account.ID, childBrands2);
                 
                contentDescriptionList = new Content_Description__c[]{
                    Test_Helper.testInsertContentDescriptionExtended('title1'), 
                    Test_Helper.testInsertContentDescriptionExtended('title2'),
                    Test_Helper.testInsertContentDescriptionExtended('title3'),
                    Test_Helper.testInsertContentDescriptionExtended('title4'),
                    Test_Helper.testInsertContentDescriptionExtended('title5'),
                    Test_Helper.testInsertContentDescriptionExtended('title6'),
                    Test_Helper.testInsertContentDescriptionExtended('title7')
                };
                
                system.debug(contentDescriptionList);
                
                List<ContentBrand__c> cb = new ContentBrand__c[]{
                    Test_Helper.testCreateContentBrand(contentDescriptionList[0].id, parentBrands[0].id),
                    Test_Helper.testCreateContentBrand(contentDescriptionList[1].id, childBrands1[0].id),
                    Test_Helper.testCreateContentBrand(contentDescriptionList[2].id, parentBrands[1].id),
                    Test_Helper.testCreateContentBrand(contentDescriptionList[3].id, childBrands2[1].id),
                    Test_Helper.testCreateContentBrand(contentDescriptionList[4].id, parentBrands[2].id),
                    Test_Helper.testCreateContentBrand(contentDescriptionList[5].id, parentBrands[2].id),
                    Test_Helper.testCreateContentBrand(contentDescriptionList[6].id, parentBrands[3].id)
                };
                
                insert cb;
                
                baseDate = date.today().year()+'-'+date.today().month();
                contentPropertyList = new Content_Property__c[]{
                    Test_Helper.testCreateContentProperty('property1', null, contentDescriptionList[0].Id, Constant.SELLING_MATERILAS, Constant.QUARTERLY_SELLING_MATERIALS, Constant.PROGRAM_SELLING_MATERIALS, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
                    Test_Helper.testCreateContentProperty('property1', null, contentDescriptionList[1].Id, Constant.SELLING_MATERILAS, Constant.QUARTERLY_SELLING_MATERIALS, Constant.PROGRAM_SELLING_MATERIALS, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
                    Test_Helper.testCreateContentProperty('property1', null, contentDescriptionList[2].Id, Constant.SELLING_MATERILAS, Constant.QUARTERLY_SELLING_MATERIALS, Constant.PROGRAM_SELLING_MATERIALS, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
                    Test_Helper.testCreateContentProperty('property1', null, contentDescriptionList[0].Id, Constant.SELLING_MATERILAS, 'Category Development', Constant.SELLING_SOLUTIONS, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
                    Test_Helper.testCreateContentProperty('property2', null, contentDescriptionList[1].Id, Constant.SELLING_MATERILAS, 'Category Development', Constant.SELLING_SOLUTIONS, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
                    Test_Helper.testCreateContentProperty('property3', null, contentDescriptionList[2].Id, Constant.SELLING_MATERILAS, Constant.STANDARDS, 'On Premise', null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
                    Test_Helper.testCreateContentProperty('property4', null, contentDescriptionList[3].Id, Constant.SELLING_MATERILAS, Constant.STANDARDS, 'On Premise', null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
                    Test_Helper.testCreateContentProperty('property5', null, contentDescriptionList[4].Id, Constant.SELLING_MATERILAS, Constant.STANDARDS, 'Off Premise', null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
                    Test_Helper.testCreateContentProperty('property6', null, contentDescriptionList[5].Id, Constant.SELLING_MATERILAS, Constant.FACT_SHEETS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
                    Test_Helper.testCreateContentProperty('property7', null, contentDescriptionList[6].Id, Constant.SELLING_MATERILAS, Constant.FACT_SHEETS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
                    Test_Helper.testCreateContentProperty('property8', null, contentDescriptionList[1].Id, Constant.SELLING_MATERILAS, Constant.FACT_SHEETS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
                    Test_Helper.testCreateContentProperty('property9', null, contentDescriptionList[2].Id, Constant.SELLING_MATERILAS, Constant.FACT_SHEETS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'))
                };
                
                insert contentPropertyList;
           }
       }
       
       static testmethod void testSections(){
       		TestSettings ts = new TestSettings();
        	Test.startTest();
        	System.RunAs(ts.user){         
	            PageReference pageRef = Page.SellingMaterials;
	            Test.setCurrentPage(pageRef);          
           		Controller_SellingMaterials c = new Controller_SellingMaterials();         
           		c.currentSection = Constant.CATEGOTY_DEVELOPMENT;
		        c.switchSection();
		        c.currentSection = Constant.STANDARDS;
		        c.switchSection();
				c.currentSection = 'unknown section';
		        c.switchSection();
		        System.assertEquals(true, ApexPages.hasMessages());
        	}
          	Test.stopTest();
       }
       
       static testmethod void testCnstructorA(){
         
          PageReference pageRef = Page.SellingMaterials;
         Test.setCurrentPage(pageRef);
         
         TestSettings ts = new TestSettings();
         Test.startTest();
         System.RunAs(ts.user){
             Controller_SellingMaterials c = new Controller_SellingMaterials();

             c.currentSection = 'Category Development';
             c.switchSection();           
       
          }
         Test.stopTest();
       }
       
       static testmethod void testCnstructorB(){
         
          PageReference pageRef = Page.SellingMaterials;
         Test.setCurrentPage(pageRef);
         
         TestSettings ts = new TestSettings();
         Test.startTest();
         System.RunAs(ts.user){
             Controller_SellingMaterials c = new Controller_SellingMaterials();

             c.currentSubSection = Constant.SELLING_SOLUTIONS;
             c.switchSubSection();             
       
          }
         Test.stopTest();
       }
       
       static testmethod void testCnstructor11(){
         
          PageReference pageRef = Page.SellingMaterials;
         Test.setCurrentPage(pageRef);
         
         TestSettings ts = new TestSettings();
         Test.startTest();
         System.RunAs(ts.user){
             Controller_SellingMaterials c = new Controller_SellingMaterials();
                        
             c.currentSection = Constant.STANDARDS;
             c.switchSection();
             c.currentSubSection = 'Off Premise';
          }
         Test.stopTest();
       }
       
       static testmethod void testCnstructor2(){
         
          PageReference pageRef = Page.SellingMaterials;
         Test.setCurrentPage(pageRef);
         
         TestSettings ts = new TestSettings();
         Test.startTest();
         System.RunAs(ts.user){
             Controller_SellingMaterials c = new Controller_SellingMaterials();
             c.currentSection = Constant.FACT_SHEETS;
             c.selectedTimePeriods = '3';
             c.refreshPageContent();
          }
         Test.stopTest();
       }
       
       static testmethod void testCnstructor2a(){
         
          PageReference pageRef = Page.SellingMaterials;
         Test.setCurrentPage(pageRef);
         
         TestSettings ts = new TestSettings();
         Test.startTest();
         System.RunAs(ts.user){
             Controller_SellingMaterials c = new Controller_SellingMaterials();
             c.currentSection = Constant.FACT_SHEETS;
             c.selectedTimePeriods = '0';
             c.nextPeriod();
             
          }
         Test.stopTest();
       }   
       
       static testmethod void testCnstructor2b(){
         
          PageReference pageRef = Page.SellingMaterials;
         Test.setCurrentPage(pageRef);
         
         TestSettings ts = new TestSettings();
         Test.startTest();
         System.RunAs(ts.user){
             Controller_SellingMaterials c = new Controller_SellingMaterials();
             c.currentSection = Constant.FACT_SHEETS;
             c.selectedTimePeriods = '0';
             
             c.previousPeriod();
          }
         Test.stopTest();
       }       
       
       static testmethod void testCnstructor3(){
         
          PageReference pageRef = Page.SellingMaterials;
         Test.setCurrentPage(pageRef);
         
         TestSettings ts = new TestSettings();
         Test.startTest();
         System.RunAs(ts.user){
             Controller_SellingMaterials c = new Controller_SellingMaterials();

             c.currentSection = Constant.FACT_SHEETS;
             c.selectedTimePeriods = '0';
             c.previousPeriod();
          }
         Test.stopTest();
       }       

       static testmethod void testCnstructor4a(){
         
          PageReference pageRef = Page.SellingMaterials;
         Test.setCurrentPage(pageRef);
         
         TestSettings ts = new TestSettings();
         Test.startTest();
         System.RunAs(ts.user){
             Controller_SellingMaterials c = new Controller_SellingMaterials();

             c.currentSection = Constant.FACT_SHEETS;
             c.nextPeriod();
             
          }
         Test.stopTest();
       }
        
       static testmethod void testCnstructor4b(){
         
          PageReference pageRef = Page.R_SellingMaterials;
         Test.setCurrentPage(pageRef);
         
         TestSettings ts = new TestSettings();
         Test.startTest();
         System.RunAs(ts.user){
             Controller_SellingMaterials c = new Controller_SellingMaterials();
            
             c.selectedTimePeriods = '0';
             c.refreshPageContent(); 
          }
         Test.stopTest();
       }
       
       static testmethod void testCnstructor5(){
         
          PageReference pageRef = Page.SellingMaterials;
         Test.setCurrentPage(pageRef);
         
         TestSettings ts = new TestSettings();
         Test.startTest();
         System.RunAs(ts.user){
             Controller_SellingMaterials c = new Controller_SellingMaterials();

             c.currentSection = Constant.FACT_SHEETS;
             c.switchToQuarterView();
          }
         Test.stopTest();
       }
       
       static testmethod void testCnstructor6(){
         
          PageReference pageRef = Page.SellingMaterials;
         Test.setCurrentPage(pageRef);
         
         TestSettings ts = new TestSettings();
         Test.startTest();
         System.RunAs(ts.user){
             Controller_SellingMaterials c = new Controller_SellingMaterials();

             c.currentSection = Constant.FACT_SHEETS;
             c.clearVariantBrandsSelected();
       		 c.switchToMonthView();
       		 c.selectedTimePeriods = '0,1,2,3,4,5,6,7,8,9,10,11';
             c.refreshPageContent(); 
          }
         Test.stopTest();
       }       
       
       static testmethod void testSearch(){
         
         PageReference pageRef = Page.SellingMaterials;
         Test.setCurrentPage(pageRef);
         
         TestSettings ts = new TestSettings();
            
         Test.startTest();
         System.RunAs(ts.user){
             Controller_SellingMaterials c = new Controller_SellingMaterials();
             c.selectedBrandIds = ts.parentBrands[0].id;
             c.selectedChildBrandIds = ts.childBrands1[0].id;
             c.selectedRTS = true;
             c.selectedTBA = true;
             c.selectedPortfolio = true;
             c.changeFilter();
             
             c.renderAsList();
             System.assertEquals(true, c.displayAsList);
             
             c.renderAsBox();
             System.assertEquals(false, c.displayAsList);
             
             
             c.parentId = '';
             c.updateVariantBrands();
             System.assertEquals(0, c.childBrandList.size());
             
             c.parentId = ts.parentBrands[0].id;
             c.updateVariantBrands();
             System.assertEquals(4, c.childBrandList.size());
             
             c.clearVariantBrands();
             System.assertEquals(0, c.childBrandList.size());

         }
        Test.stopTest();
       }
       
       static testmethod void testMore(){
         PageReference pageRef = Page.SellingMaterials;
         pageRef.getParameters().put('section', Constant.FACT_SHEETS);
		 pageRef.getParameters().put('subsection', Constant.FACT_SHEETS);
		 pageRef.getParameters().put('openfilter', 'true');
         Test.setCurrentPage(pageRef);
         
         
         TestSettings ts = new TestSettings();
            
         Test.startTest();
         System.RunAs(ts.user){
             Controller_SellingMaterials c = new Controller_SellingMaterials();
             c.currentSection = Constant.FACT_SHEETS;
             c.selectedRTS = true;
             c.selectedPortfolio = true;
             c.switchSection();
             System.assert(null != c.contentHolder);
             c.resetFilter();
			 c.clearVariantBrandsSelected();
        }
        Test.stopTest();
       }

       static testmethod void testMore2(){
         PageReference pageRef = Page.SellingMaterials;
         Test.setCurrentPage(pageRef);
         
         
         TestSettings ts = new TestSettings();
            
         Test.startTest();
         System.RunAs(ts.user){
             Controller_SellingMaterials c = new Controller_SellingMaterials();
             c.currentSection = Constant.FACT_SHEETS;
			 c.monthOrQuarterRender = true;
			 c.nextPeriod();
			 c.previousPeriod();

        }
        Test.stopTest();
       }
       
       static testmethod void testMore22(){
         PageReference pageRef = Page.SellingMaterials;
         Test.setCurrentPage(pageRef);
         
         
         TestSettings ts = new TestSettings();
            
         Test.startTest();
         System.RunAs(ts.user){
             Controller_SellingMaterials c = new Controller_SellingMaterials();
             c.currentSection = Constant.FACT_SHEETS;
			 c.monthOrQuarterRender = false;
			 c.nextPeriod();
			 c.previousPeriod();
        }
        Test.stopTest();
       }
}