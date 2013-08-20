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
private class Test_Controller_UserProfile {

    static testMethod void myUnitTest() {
        Contact contact;
        Account account;
        User user;
        account = Test_Helper.testInsertAccount('test_account1');
        contact = Test_Helper.testInsertContact('firstName', 'lastName', account.id);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            user    = Test_Helper.testInsertDistributorPortalUser(contact.id);
        }
        PageReference pageRef = Page.UserProfile;
        Test.setCurrentPage(pageRef);
        System.RunAs(user){
            Controller_UserProfile up =  new Controller_UserProfile();
            System.assertEquals(user.Id, up.UserRecord.Id);
            up.UserRecord.Phone = '+48668176578';
            up.updateUserRecord();
            user = [SELECT phone FROM user WHERE Id =: up.UserRecord.Id]; 
            System.assertEquals('+48668176578', user.phone);
            
            up.cancelEdit();            
            up.getTimezones();            

        }
    }
}