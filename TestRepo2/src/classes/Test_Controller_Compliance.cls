@isTest
private class Test_Controller_Compliance {
    
     class TestSettings {
         Contact contact;
         Account account;
         User user;
         Brand__c brand;
         Content_Description__c[] contentDescriptionList;
         Content_Property__c[] contentPropertyList;
         
         public TestSettings(){
            
                Content_Property__c[] cp =[select id from Content_Property__c where Category__c =: Constant.COMPLIANCE];
                delete cp;
                
                account = Test_Helper.testInsertAccount('test_account1');
                contact = Test_Helper.testInsertContact('firstName', 'lastName', account.id);
                User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      
                System.runAs (thisUser) {
                    user = Test_Helper.testInsertDistributorPortalUser(contact.id);
                }
                brand = Test_Helper.testInsertBrand('brand1');
                
                
                Test_Helper.testInsertAccountBrand(account.id, brand.id);
                
                contentDescriptionList = new Content_Description__c[]{
                    Test_Helper.testInsertContentDescriptionExtended('title1'),
                    Test_Helper.testInsertContentDescriptionExtended('title2'),
                    Test_Helper.testInsertContentDescriptionExtended('title3'),
                    Test_Helper.testInsertContentDescriptionExtended('title4'),
                    Test_Helper.testInsertContentDescriptionExtended('title5'),
                    Test_Helper.testInsertContentDescriptionExtended('title6'),
                    Test_Helper.testInsertContentDescriptionExtended('title7')
                };
                
                for(Content_Description__c cont : contentDescriptionList){
                    Test_Helper.testInsertContentBrand(cont.id, brand.id);
                }
            
                contentPropertyList = new Content_Property__c[]{
                    Test_Helper.testInsertContentProperty('property1', null, contentDescriptionList[0].Id, Constant.COMPLIANCE, null, null, null),
                    Test_Helper.testInsertContentProperty('property2', null, contentDescriptionList[1].Id, Constant.COMPLIANCE, null, null, null),
                    Test_Helper.testInsertContentProperty('property3', null, contentDescriptionList[2].Id, Constant.COMPLIANCE, null, null, null),
                    Test_Helper.testInsertContentProperty('property4', null, contentDescriptionList[3].Id, Constant.COMPLIANCE, null, null, null),
                    Test_Helper.testInsertContentProperty('property5', null, contentDescriptionList[4].Id, Constant.POS, null, null, null)
                };
         }
         
     }
     
     static testmethod void testComplance(){
        
        PageReference pageRef = Page.Compliance;
        Test.setCurrentPage(pageRef);
        
        TestSettings ts = new  TestSettings();
        Test.StartTest();
        System.RunAs(ts.user){
            Controller_Compliance c = new Controller_Compliance();
            System.assertEquals(4, c.content.size());
        }
        Test.stopTest();
     }
}