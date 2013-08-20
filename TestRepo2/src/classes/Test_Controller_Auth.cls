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
private class Test_Controller_Auth {

    // standard test method
    public static testMethod void testController_Auth () {
        // test login
        Controller_Auth controllerLogin = new Controller_Auth();
        controllerLogin.userName = 'test@salesforce.com';
        controllerLogin.userPassword = '123456';
        controllerLogin.startUrlPage = Page.HomePage.getUrl();
        System.assertEquals(controllerLogin.logUser(),null);
        
        //test password forgot
        Controller_Auth controllerForgot = new Controller_Auth();
        controllerForgot.userName = 'test@salesforce.com';      
        System.assertEquals(controllerForgot.forgotPassword(),null);
        
        // test change password
        Controller_Auth controllerChangePasswd = new Controller_Auth();
        controllerChangePasswd.oldPassword = '123456';
        controllerChangePasswd.newPassword = 'qwerty1'; 
        controllerChangePasswd.verifyNewPassword = 'qwerty1';                
        

        // test change password
        Controller_Auth controllerForgotUser = new Controller_Auth();
        Account account = Test_Helper.testInsertAccount('test_account1');
        Contact contact = Test_Helper.testInsertContact('firstName', 'lastName', account.id);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];   
        User user;
        System.runAs (thisUser) {
            user = Test_Helper.testInsertDistributorPortalUser(contact.id);
        } 
        Test.StartTest();
        System.RunAs(user){
            user.email = 'test@test.com';
            update user;
            controllerForgotUser.userEmail = 'test@test.com';
            controllerForgotUser.forgotUsername();
            system.assert(!controllerForgotUser.isDiageoNetwork());
            controllerForgotUser.checkLoggedIn();           
            
            System.assertEquals(controllerChangePasswd.changePassword(),null);    
        }
        Test.StopTest();      
    }    
}