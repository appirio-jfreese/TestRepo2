@isTest
private class Test_ReassignRelatedContactsAndEvents {

    static testMethod void testReassignContactsEvents() {
        
       Test.startTest();
        
       Id samProfId = [SELECT Id FROM Profile WHERE Name = 'Control - Sales Manager'].Id;
       User user1 = Test_RecordUtil.newUser('rep1', samProfId);
       User user2 = Test_RecordUtil.newUser('rep2', samProfId);
         
        // Create Users
        List<User> users = new List<User>();
        users.add(user1);
        users.add(user2);
        insert users;
        system.runAs(user1){ // Line added by Jai Gupta to increase coverage to 75%
            //create account
            Account acc1 = new Account();
            acc1.Name = 'Test Account';
            acc1.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'On-Premise - Control'].Id;
            acc1.Called_On__c = true;
            acc1.OwnerId = user1.Id;
            insert acc1;
                 
            //create contact
            Contact con1 = new Contact();
            con1.FirstName = 'Fname';
            con1.LastName = 'Lname';
            con1.Phone = '8821234';
            con1.Email = 'testclass@appirio.com';
            con1.Account = acc1;     
            con1.OwnerId = user1.Id;
            insert con1;
                    
            //create event
            Event eve = new Event();
            eve.whoId = con1.Id; 
            eve.whatId = acc1.Id; 
            eve.StartDateTime = Datetime.Now();
            eve.EndDateTime = Datetime.now().addHours(1);
            insert eve ;        
                    
            //create action
            Action__c act1 = new Action__c();
            act1.RecordType = [Select Id FROM RecordType WHERE SObjectType = 'Action__c' AND Name = 'Feature Execution - Control']; 
            act1.Status__c = 'Open - In Progress';
          //act1.OwnerId = user1.Id;
          //act1.Account__c = acc1;
            insert act1;
            
            acc1.Called_On__c = false;
            acc1.OwnerId = user2.Id;
            update acc1;
        }
    }
}