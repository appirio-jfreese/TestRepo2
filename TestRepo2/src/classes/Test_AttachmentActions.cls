@isTest
private class Test_AttachmentActions {

    static testMethod void testInsertDeleteActionAttachments() {
    	//Create data
    	
        Action__c act = new Action__c();
        insert act;
        
        Contact con = new Contact();
        con.LastName = 'Jones';
        insert con;
        
        List<Attachment> attachments = new List<Attachment>();
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        
        Attachment att1 = new Attachment();
        att1.ParentId = act.Id;
        att1.Name = 'test att';
    	att1.Body = bodyBlob;
        attachments.add(att1);
        
        Attachment att2 = new Attachment();
        att2.ParentId = con.Id;
        att2.Name = 'test att';
    	att2.Body = bodyBlob;
        attachments.add(att2);
        
        //Start test
        Test.startTest();
        
        System.assertEquals(false, [SELECT Has_Attachment__c FROM Action__c WHERE Id = :act.Id].Has_Attachment__c);
        
        insert attachments;
        
        System.assertEquals(true, [SELECT Has_Attachment__c FROM Action__c WHERE Id = :act.Id].Has_Attachment__c);
        
        delete attachments;
        
        System.assertEquals(false, [SELECT Has_Attachment__c FROM Action__c WHERE Id = :act.Id].Has_Attachment__c);
    }
}