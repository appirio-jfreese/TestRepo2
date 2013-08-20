@isTest
private class Test_AccountActions {

    static testMethod void testUpdateRecordTypes() {
        //create data
        List<Account> accs = new List<Account>();
        
        Account acc0 = new Account();
        acc0.Name = 'acc0';
        acc0.NABCA_Sector_Code__c = 'O';
        accs.add(acc0);
        
        Account acc1 = new Account();
        acc1.Name = 'acc1';
        acc1.NABCA_Sector_Code__c = 'F';
        accs.add(acc1);
        
        Account acc2 = new Account();
        acc2.Name = 'acc2';
        acc2.NABCA_Sector_Code__c = 'C';
        accs.add(acc2);
        
        //start test
        Test.startTest();
        
        //insert accounts
        insert accs;
        
        //stop test
        Test.stopTest();
        
        //read back data and assert its values
        acc0 = [SELECT Id, RecordType.Name FROM Account WHERE Id = :acc0.Id];
        System.assertEquals('On-Premise - Control', acc0.RecordType.Name);
        
        acc1 = [SELECT Id, RecordType.Name FROM Account WHERE Id = :acc1.Id];
        System.assertEquals('Off-Premise - Control', acc1.RecordType.Name);
        
        acc2 = [SELECT Id, RecordType.Name FROM Account WHERE Id = :acc2.Id];
        System.assertEquals('Off-Premise - Control', acc2.RecordType.Name);
        
        update acc0;
        
    }
    
    static testMethod void testCheckNabcaTerritory(){
    	State_Code__c code = new State_Code__c();
    	code.State_Code__c = 'DM';
    	insert code;
    	
    	Territory__c terr = new Territory__c();
    	terr.Name = 'DM1 Holding';
    	insert terr;
    	
    	Account acc1 = new Account();
    	acc1.Name = 'Test Account';
    	acc1.Nabca_Account_Name__c = 'Test Account (test)';
    	acc1.Licensee_State_Code__c = code.Id;
    	
    	Account acc2 = new Account();
    	acc2.Name = 'Test Account';
    	acc2.Nabca_Account_Name__c = 'Test Account (test)';
    	
    	Test.startTest();
    	
    	insert acc1;
    	insert acc2;
    	
    	Test.stopTest();
    	
    	acc1 = [SELECT Id, Territory__c FROM Account WHERE Id = :acc1.Id];
    	System.assertEquals(terr.Id, acc1.Territory__c);
    	acc2 = [SELECT Id, Territory__c FROM Account WHERE Id = :acc2.Id];
    	System.assertEquals(null, acc2.Territory__c);
    	
    	acc2.Licensee_State_Code__c = code.Id;
    	update acc2;
    	acc2 = [SELECT Id, Territory__c FROM Account WHERE Id = :acc2.Id];
    	System.assertEquals(terr.Id, acc2.Territory__c);
    	
    }
}