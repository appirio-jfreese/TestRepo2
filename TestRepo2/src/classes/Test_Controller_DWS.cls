@isTest
private class Test_Controller_DWS {
    
    class TestSettings {
         Contact contact;
         Account account;
         User user;
         
          public TestSettings(){
                account = Test_Helper.testInsertAccount('test_account1');
                contact = Test_Helper.testInsertContact('firstName', 'lastName', account.id);
                User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()]; 
                System.runAs (thisUser) {
                    user = Test_Helper.testInsertDistributorPortalUser(contact.id);
                }
          }
    }
    
     static testmethod void testDWS(){
        TestSettings ts = new  TestSettings();
        
        PageReference pageRef = Page.DWS;
        Test.setCurrentPage(pageRef);
        
        Test.StartTest();
        System.RunAs(ts.user){
            Controller_DWS c = new Controller_DWS();
            System.assertEquals(true, c.ssoId != null);
            System.assertEquals(EncodingUtil.base64Encode(Blob.ValueOf('dest=diageowines.com,first_name=' + ts.user.FirstName + ',last_name=' + ts.user.LastName+', title=' + ts.user.Title )), c.hexDiageowines);
            System.assertEquals(EncodingUtil.base64Encode(Blob.ValueOf('dest=www.dwsacademies.com,first_name=' + ts.user.FirstName + ',last_name=' + ts.user.LastName+', title=' + ts.user.Title )), c.hexDwsacademies);
        }
        Test.stopTest();
     }
}