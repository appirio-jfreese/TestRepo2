@isTest
private class AttachmentActionsTest {

    static testMethod void testUpdateParentActions() {
        Action__c rec = new Action__c();
        insert rec;
        
        rec = [SELECT Id, Has_Attachment__c FROM Action__c WHERE Id = :rec.Id];
        System.assertEquals(false, rec.Has_Attachment__c);
        
        Attachment att = new Attachment();
        att.ParentId = rec.Id;
        att.Name = 'test';
        att.Body = Blob.valueOf('test');
        
        Test.startTest();
        
        insert att;
        
        Test.stopTest();
        
        rec = [SELECT Id, Has_Attachment__c FROM Action__c WHERE Id = :rec.Id];
        System.assertEquals(true, rec.Has_Attachment__c);
        
        delete att;
        
        rec = [SELECT Id, Has_Attachment__c FROM Action__c WHERE Id = :rec.Id];
        System.assertEquals(false, rec.Has_Attachment__c);
    }

    static testMethod void testUpdateParentAccounts() {
        Account rec = new Account();
        rec.Name = 'test account';
        insert rec;
        
        rec = [SELECT Id, Has_Attachment__c FROM Account WHERE Id = :rec.Id];
        System.assertEquals(false, rec.Has_Attachment__c);
        
        Attachment att = new Attachment();
        att.ParentId = rec.Id;
        att.Name = 'test';
        att.Body = Blob.valueOf('test');
        
        Test.startTest();
        
        insert att;
        
        Test.stopTest();
        
        rec = [SELECT Id, Has_Attachment__c FROM Account WHERE Id = :rec.Id];
        System.assertEquals(true, rec.Has_Attachment__c);
        
        delete att;
        
        rec = [SELECT Id, Has_Attachment__c FROM Account WHERE Id = :rec.Id];
        System.assertEquals(false, rec.Has_Attachment__c);
    }
}