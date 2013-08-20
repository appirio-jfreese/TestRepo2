/**
Name        : Test_Service_FilterSection.cls
Created By  : Geeta kumawat (Appirio Offshore)   
Date        : 7/15/13
Description : Test class for Service_FilterSection controller
****/
@isTest
private class Test_Service_FilterSection {
	static Contact contact;
   	static Account account;
   	static User user;
   	static Brand__c[] childBrands1;
   	static Brand__c[] childBrands2;
   	static Brand__c[] parentBrands;
   	static Brand__c testBrand;
   	static Brand__c failBrand;
   
   static Calendar__c[] calendars;
   static Content_Description__c[] contentDescriptionList;
   static Content_Property__c[] contentPropertyList;
   
   
   static String baseDate;
   
   
   static testmethod void testFilerSectionFunctionality(){
     createTestData();
     Test.startTest();
     System.RunAs(user){
         Service_FilterSection c = new Service_FilterSection();
         c.selectedTimePeriods ='quarterly';
         //For Quarterly
         c.nextPeriodComp();
         c.previousPeriodComp();
         //For Monthly
         c.selectedTimePeriods ='monthly';
         c.monthOrQuarterRender = false;
         c.nextPeriodComp();
         c.previousPeriodComp();
         c.updateVariantBrands();
         c.parentId = c.parentBrandList[0].Id;
         c.updateVariantBrands();
         c.resetFilter();
      }
     Test.stopTest();
   }
           
	// Method Creates test data
    private static void createTestData(){
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