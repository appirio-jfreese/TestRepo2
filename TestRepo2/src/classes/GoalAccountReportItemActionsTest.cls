@isTest
private class GoalAccountReportItemActionsTest {

    static testMethod void testCopyPrimaryDemographicFromAccount() {
        Goal__c goal = new Goal__c();
        insert goal;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Primary_Demographic__c = 'Asian;AfAm';
        insert acc;
        
        Goal_Account_Report_Item__c gari = new Goal_Account_Report_Item__c();
        gari.Goal__c = goal.Id;
        gari.Account__c = acc.Id;
        
        Test.startTest();
        
        insert gari;
        
        Test.stopTest();
        
        gari = [SELECT Id, Primary_Demographic__c FROM Goal_Account_Report_Item__c WHERE Id = :gari.Id];
        System.assertEquals(acc.Primary_Demographic__c, gari.Primary_Demographic__c);
        
        acc.Primary_Demographic__c = 'LGBT';
        update acc;
        
        gari = [SELECT Id, Primary_Demographic__c FROM Goal_Account_Report_Item__c WHERE Id = :gari.Id];
        System.assertEquals(acc.Primary_Demographic__c, gari.Primary_Demographic__c);
    }
}