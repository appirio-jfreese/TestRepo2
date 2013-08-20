@isTest(SeeAllData=false)
private class Test_Controller_BrandMarketingInform {

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
                    Test_Helper.testCreateContentProperty('property1', null, contentDescriptionList[0].Id, Constant.BRAND_MARKETING_INFORMATION, Constant.PROGRAMMING, Constant.PROGRAM, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
                    Test_Helper.testCreateContentProperty('property1', null, contentDescriptionList[1].Id, Constant.BRAND_MARKETING_INFORMATION, Constant.PROGRAMMING, Constant.COUPONS, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
                    Test_Helper.testCreateContentProperty('property1', null, contentDescriptionList[2].Id, Constant.BRAND_MARKETING_INFORMATION, Constant.PROGRAMMING, Constant.PROGRAM, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
                    Test_Helper.testCreateContentProperty('property1', null, contentDescriptionList[0].Id, Constant.BRAND_MARKETING_INFORMATION, Constant.MEDIA, Constant.COMMERCIALS , null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
                    Test_Helper.testCreateContentProperty('property2', null, contentDescriptionList[1].Id, Constant.BRAND_MARKETING_INFORMATION, Constant.MEDIA, Constant.COMMERCIALS, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
                    Test_Helper.testCreateContentProperty('property6', null, contentDescriptionList[5].Id, Constant.BRAND_MARKETING_INFORMATION, Constant.FACT_SHEETS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
                    Test_Helper.testCreateContentProperty('property7', null, contentDescriptionList[6].Id, Constant.BRAND_MARKETING_INFORMATION, Constant.FACT_SHEETS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
                    Test_Helper.testCreateContentProperty('property8', null, contentDescriptionList[1].Id, Constant.BRAND_MARKETING_INFORMATION, Constant.FACT_SHEETS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
                    Test_Helper.testCreateContentProperty('property9', null, contentDescriptionList[2].Id, Constant.BRAND_MARKETING_INFORMATION, Constant.FACT_SHEETS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'))
                };
                
                insert contentPropertyList;
           }
       }
       
       static testmethod void testSections1(){
           PageReference pageRef = Page.BrandMarketingInformation;
           Test.setCurrentPage(pageRef);
           TestSettings ts = new TestSettings();
           Test.startTest();
           System.runAs(ts.user){            
                Controller_BrandMarketingInformation c = new Controller_BrandMarketingInformation();
                c.currentSection = Constant.MEDIA;
                c.switchSection();
           }
           Test.stopTest();
       }
       
        static testmethod void testSections2(){
           PageReference pageRef = Page.BrandMarketingInformation;
           Test.setCurrentPage(pageRef);
           TestSettings ts = new TestSettings();
           Test.startTest();
           System.runAs(ts.user){            
               Controller_BrandMarketingInformation c = new Controller_BrandMarketingInformation();
               c.currentSection = Constant.FACT_SHEETS;
               c.switchSection();
           }           
           Test.stopTest();
       }
       
        static testmethod void testSections3(){
           Test.startTest();
           PageReference pageRef = Page.BrandMarketingInformation;
           Test.setCurrentPage(pageRef);
           TestSettings ts = new TestSettings();
           System.runAs(ts.user){ 
                Controller_BrandMarketingInformation c = new Controller_BrandMarketingInformation();
                c.currentSection = 'unknown section';
                c.switchSection();
                System.assertEquals(true, ApexPages.hasMessages());
           }
           Test.stopTest();
       }
       
       static testmethod void testCnstructor1(){
         Test.startTest();
         TestSettings ts = new TestSettings();
         System.RunAs(ts.user){
            PageReference pageRef = Page.BrandMarketingInformation;
             Test.setCurrentPage(pageRef);
             Controller_BrandMarketingInformation c = new Controller_BrandMarketingInformation();
             c.selectedRTS = false;
             c.selectedPortfolio = false;
             c.currentSection = Constant.PROGRAMMING;
             c.currentSubSection = 'unknow';
             c.switchSubSection();
          }
          Test.stopTest();
       }

       static testmethod void testCnstructor2(){
         TestSettings ts = new TestSettings();
         Test.startTest();
         System.RunAs(ts.user){
            PageReference pageRef = Page.BrandMarketingInformation;
             Test.setCurrentPage(pageRef);
             Controller_BrandMarketingInformation c = new Controller_BrandMarketingInformation();
             c.currentSection = Constant.PROGRAMMING;
             c.switchSection();
             c.currentSubSection = Constant.COUPONS;
          }
          Test.stoptest();
       }

       static testmethod void testCnstructor4(){
         TestSettings ts = new TestSettings();
         
         Test.startTest();
         
         System.RunAs(ts.user){
           
            PageReference pageRef = Page.BrandMarketingInformation;
             Test.setCurrentPage(pageRef);
           
             Controller_BrandMarketingInformation c = new Controller_BrandMarketingInformation();
           
             c.currentSection = 'unknow';
             c.selectedTimePeriods = '0';
             c.refreshPageContent();             
          }
         Test.stopTest();
       }

       static testmethod void testCnstructor5(){
        
         TestSettings ts = new TestSettings();
         Test.startTest();
         System.RunAs(ts.user){
           
            PageReference pageRef = Page.BrandMarketingInformation;
             Test.setCurrentPage(pageRef);
           
             Controller_BrandMarketingInformation c = new Controller_BrandMarketingInformation();
             c.resetFilter();
         }
         Test.stopTest();
       }
           
       static testmethod void testCnstructor6(){

         TestSettings ts = new TestSettings();
         
         Test.startTest();
         
         System.RunAs(ts.user){
           
            PageReference pageRef = Page.BrandMarketingInformation;
             Test.setCurrentPage(pageRef);
           
             Controller_BrandMarketingInformation c = new Controller_BrandMarketingInformation();

             c.currentSection = 'unknow';
             c.switchToQuarterView();
          }
          Test.stopTest();
       }
       
       static testmethod void testCnstructor7(){

         TestSettings ts = new TestSettings();
         
         Test.startTest();
         System.RunAs(ts.user){
           
            PageReference pageRef = Page.BrandMarketingInformation;
             Test.setCurrentPage(pageRef);
           
             Controller_BrandMarketingInformation c = new Controller_BrandMarketingInformation();

             c.currentSection = 'unknow';
             c.selectedTimePeriods = '0';
             c.switchToQuarterView();
          }
          Test.stopTest();
       }
       
       static testmethod void testSearch(){
            TestSettings ts = new TestSettings();
         Test.startTest();
         System.RunAs(ts.user){
           
            PageReference pageRef = Page.BrandMarketingInformation;
             Test.setCurrentPage(pageRef);
           
             Controller_BrandMarketingInformation c = new Controller_BrandMarketingInformation();
             c.selectedBrandIds = ts.childBrands1[0].id;
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
             //System.assertEquals(4, c.childBrandList.size());
             
             c.clearVariantBrands();
             System.assertEquals(0, c.childBrandList.size());
             
         }
         Test.stoptest();
       }
       
       static testmethod void testMore(){
         PageReference pageRef = Page.BrandMarketingInformation;
         pageRef.getParameters().put('section', Constant.PROGRAMMING);
         pageRef.getParameters().put('subsection', Constant.PROGRAMMING);
         pageRef.getParameters().put('openfilter', 'true');
         Test.setCurrentPage(pageRef);
         
         
         TestSettings ts = new TestSettings();
            
         Test.startTest();
         System.RunAs(ts.user){
             Controller_BrandMarketingInformation c = new Controller_BrandMarketingInformation();
             c.currentSection = Constant.PROGRAMMING;
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
         PageReference pageRef = Page.BrandMarketingInformation;
         pageRef.getParameters().put('section', Constant.PROGRAMMING);
         pageRef.getParameters().put('subsection', Constant.PROGRAMMING);
         pageRef.getParameters().put('openfilter', 'true');
         Test.setCurrentPage(pageRef);
         
         
         TestSettings ts = new TestSettings();
            
         Test.startTest();
         System.RunAs(ts.user){
             Controller_BrandMarketingInformation c = new Controller_BrandMarketingInformation();
             c.currentSection = Constant.PROGRAMMING;
             c.monthOrQuarterRender = false;
             c.nextPeriod();
             c.previousPeriod();
             c.resetFilter();
             c.monthOrQuarterRender = true;
             c.nextPeriod();
             c.previousPeriod();

        }
        Test.stopTest();
       }
}