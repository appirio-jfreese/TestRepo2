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
private class Test_Service_Messages {


    static testMethod void sendEmailMsgTest() {
        
        Account a = Test_Helper.testInsertAccount('Test Account');
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User u; 
        System.runAs (thisUser) {
            u = Test_Helper.testInsertDistributorPortalUser(c.ID);
        }

        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        
        contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
        contentA.Content_Version_Id__c = null;
        update contentA;
        
        Service_Messages mService = new Service_Messages();
        mService.sRecipientName = 'Test rec';
        mService.sRecipientEmail = 'test@test.com, test@test2.com';
        mService.sRecipientMsg = 'Test msg';
        mService.cvid = contentB.Content_Version_Id__c;
        
        Test.StartTest();
            System.runAs(u){
                mService.sendEmailMsg();
                System.assertEquals(mService.isSend, true);
            }
        Test.StopTest();
    }
    
    static testMethod void sendEmailMsgMultipleTest() {
        Account a = Test_Helper.testInsertAccount('Test Account');
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User u; 
        System.runAs (thisUser) {
            u = Test_Helper.testInsertDistributorPortalUser(c.ID);
        }
        
        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        
        contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
        contentA.Content_Version_Id__c = null;
        update contentA;
        
        Service_Messages mService = new Service_Messages();
        mService.sRecipientName = 'Test rec';
        mService.sRecipientEmail = 'test@test.com, test@test2.com';
        mService.sRecipientMsg = 'Test msg';
        mService.cvids = contentA.Content_Version_Id_Low__c+','+contentB.Content_Version_Id__c;
        
        Test.StartTest();
            System.runAs(u){
                mService.sendEmailMsgMultiple();
                System.assertEquals(mService.isSend, true);
            }
        Test.StopTest();
    }
    
    static testMethod void closeEmailMsgTest() {
        Service_Messages mService = new Service_Messages();
        
        Test.StartTest();

            mService.closeEmailMsg();           
            System.assertEquals(mService.isSend, false);        
            System.assertEquals(mService.sRecipientName, null);
            System.assertEquals(mService.sRecipientEmail, null);
            System.assertEquals(mService.sRecipientMsg, null);

        Test.StopTest();            
    }    
}