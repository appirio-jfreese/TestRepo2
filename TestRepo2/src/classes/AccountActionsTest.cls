@isTest
private class AccountActionsTest {
	
    static testMethod void testUpdateRecordTypes() {
    	List<Account> accs = new List<Account>();
    	
        Account acc1 = new Account();
        acc1.Name = 'test account';
        acc1.NABCA_Sector_Code__c = 'o';
        accs.add(acc1);
        
        Account acc2 = new Account();
        acc2.Name = 'test account';
        acc2.NABCA_Sector_Code__c = 'f';
        accs.add(acc2);
        
        Account acc3 = new Account();
        acc3.Name = 'test account';
        accs.add(acc3);
        
        Account acc4 = new Account();
        acc4.Name = 'test account';
        accs.add(acc4);
        
        Test.startTest();
        
       	insert accs;
       	
       	acc3.NABCA_Sector_Code__c = 'o';
       	acc4.NABCA_Sector_Code__c = 'c';
       	
       	update accs;
       	
       	Test.stopTest();
       	
       	acc1 = [SELECT Id, RecordType.Name FROM Account WHERE Id = :acc1.Id];
       	System.assertEquals('On-Premise - Control', acc1.RecordType.Name);
       	
       	acc2 = [SELECT Id, RecordType.Name FROM Account WHERE Id = :acc2.Id];
       	System.assertEquals('Off-Premise - Control', acc2.RecordType.Name);
       	
       	acc3 = [SELECT Id, RecordType.Name FROM Account WHERE Id = :acc3.Id];
       	System.assertEquals('On-Premise - Control', acc3.RecordType.Name);
       	
       	acc4 = [SELECT Id, RecordType.Name FROM Account WHERE Id = :acc4.Id];
       	System.assertEquals('Off-Premise - Control', acc4.RecordType.Name);
    }
    
    static testMethod void testCheckNABCATerritory() {
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
    
    static testMethod void testSURIUpdating() {
    	Map<String, Id> accRTIDsByName = new Map<String, Id>();
		for(RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name LIKE '%Premise%']){
			accRTIDsByName.put(rt.Name, rt.Id);
		}
		
    	State__c state = new State__c();
    	state.Abbreviation__c = 'DM';
    	state.Name__c = 'Davebraska';
    	insert state;
    	
    	User use = new User(alias = 'unittest', email='unittest@modelmetrics.com', 
	        emailencodingkey='UTF-8', lastname='Testing', 
	        languagelocalekey='en_US', 
	        localesidkey='en_US', profileid = UserInfo.getProfileId(),
	        timezonesidkey='America/Chicago', 
	        username='unittest@modelmetrics.com');
	    insert use;
	    
	    List<Account> accs = new List<Account>();
    	
    	Account acc1 = new Account();
    	acc1.Name = 'acc1';
    	acc1.NABCA_Licensee_State__c = 'DM';
    	acc1.OwnerId = use.Id;
    	acc1.Account_Segmentatiobn__c = 'A';
    	acc1.Primary_Demographic__c = 'Asian';
    	acc1.RecordTypeId = accRTIDsByName.get('On-Premise - Control');
    	accs.add(acc1);
    	
    	Account acc2 = new Account();
    	acc2.Name = 'acc2';
    	acc2.NABCA_Licensee_State__c = 'DM';
    	acc2.OwnerId = use.Id;
    	acc2.Account_Segmentatiobn__c = 'A';
    	acc2.Primary_Demographic__c = 'AfAm';
    	acc2.RecordTypeId = accRTIDsByName.get('On-Premise - Control');
    	accs.add(acc2);
    	
    	Account acc3 = new Account();
    	acc3.Name = 'acc3';
    	acc3.NABCA_Licensee_State__c = 'DM';
    	acc3.OwnerId = use.Id;
    	acc3.Account_Segmentatiobn__c = 'A';
    	acc3.Primary_Demographic__c = 'Asian';
    	acc3.RecordTypeId = accRTIDsByName.get('On-Premise - Control');
    	acc3.Called_On__c = true;
    	accs.add(acc3);
    	
    	
    	Account acc4 = new Account();
    	acc4.Name = 'acc4';
    	acc4.NABCA_Licensee_State__c = 'DM';
    	acc4.OwnerId = use.Id;
    	acc4.Account_Segmentatiobn__c = 'A';
    	acc4.Primary_Demographic__c = 'AfAm';
    	acc4.RecordTypeId = accRTIDsByName.get('On-Premise - Control');
    	acc4.Called_On__c = true;
    	//accs.add(acc4);
    	
    	Test.startTest();
    	
    	insert accs;
    	insert acc4;
    	
    	Test.stopTest();
    	
    	String stateId = String.valueOf(state.Id).subString(0, 15);
    	String useId = String.valueOf(use.Id).subString(0, 15);
    	
    	List<State_User_Report_Item__c> suris = [SELECT Id, Key__c, Accounts__c, Called_On_Accounts__c FROM State_User_Report_Item__c WHERE State__c = :state.Id OR User__c = :use.Id ORDER BY Key__c];
    	System.assertEquals(6, suris.size());
    	for(State_User_Report_Item__c suri : suris){
    		if(suri.Key__c == stateId + '|' + 'A' + '|On' || suri.Key__c == useId + '|' + 'A' + '|On'){
    			System.assertEquals(4, suri.Accounts__c);
    			System.assertEquals(2, suri.Called_On_Accounts__c);
    		} else if(suri.Key__c == stateId + '|' + 'Asian' + '|On' || suri.Key__c == useId + '|' + 'Asian' + '|On'){
    			System.assertEquals(2, suri.Accounts__c);
    			System.assertEquals(1, suri.Called_On_Accounts__c);
    		} else if(suri.Key__c == stateId + '|' + 'AfAm' + '|On' || suri.Key__c == useId + '|' + 'AfAm' + '|On'){
    			System.assertEquals(2, suri.Accounts__c);
    			System.assertEquals(1, suri.Called_On_Accounts__c);
    		}
    	}
    	
    	acc4.Primary_Demographic__c = 'Asian';
    	update acc4;
    	
    	suris = [SELECT Id, Key__c, Accounts__c, Called_On_Accounts__c FROM State_User_Report_Item__c WHERE State__c = :state.Id OR User__c = :use.Id];
    	System.assertEquals(6, suris.size());
    	for(State_User_Report_Item__c suri : suris){
    		if(suri.Key__c == stateId + '|' + 'A' + '|On' || suri.Key__c == useId + '|' + 'A' + '|On'){
    			System.assertEquals(4, suri.Accounts__c);
    			System.assertEquals(2, suri.Called_On_Accounts__c);
    		} else if(suri.Key__c == stateId + '|' + 'Asian' + '|On' || suri.Key__c == useId + '|' + 'Asian' + '|On'){
    			System.assertEquals(3, suri.Accounts__c);
    			System.assertEquals(2, suri.Called_On_Accounts__c);
    		} else if(suri.Key__c == stateId + '|' + 'AfAm' + '|On' || suri.Key__c == useId + '|' + 'AfAm' + '|On'){
    			System.assertEquals(1, suri.Accounts__c);
    			System.assertEquals(0, suri.Called_On_Accounts__c);
    		}
    	}
    	
    	delete acc2;
    	
    	suris = [SELECT Id, Key__c, Accounts__c, Called_On_Accounts__c FROM State_User_Report_Item__c WHERE State__c = :state.Id OR User__c = :use.Id];
    	System.assertEquals(6, suris.size());
    	for(State_User_Report_Item__c suri : suris){
    		if(suri.Key__c == stateId + '|' + 'A' + '|On' || suri.Key__c == useId + '|' + 'A' + '|On'){
    			System.assertEquals(3, suri.Accounts__c);
    			System.assertEquals(2, suri.Called_On_Accounts__c);
    		} else if(suri.Key__c == stateId + '|' + 'Asian' + '|On' || suri.Key__c == useId + '|' + 'Asian' + '|On'){
    			System.assertEquals(3, suri.Accounts__c);
    			System.assertEquals(2, suri.Called_On_Accounts__c);
    		} else if(suri.Key__c == stateId + '|' + 'AfAm' + '|On' || suri.Key__c == useId + '|' + 'AfAm' + '|On'){
    			System.assertEquals(0, suri.Accounts__c);
    			System.assertEquals(0, suri.Called_On_Accounts__c);
    		}
    	}
    }
    
    static testMethod void testSURIUpdatingWithGARIs() {
    	Map<String, Id> accRTIDsByName = new Map<String, Id>();
		for(RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name LIKE '%Premise%']){
			accRTIDsByName.put(rt.Name, rt.Id);
		}
		
    	State__c state = new State__c();
    	state.Abbreviation__c = 'DM';
    	state.Name__c = 'Davebraska';
    	insert state;
    	
    	User use = new User(alias = 'unittest', email='unittest@modelmetrics.com', 
	        emailencodingkey='UTF-8', lastname='Testing', 
	        languagelocalekey='en_US', 
	        localesidkey='en_US', profileid = UserInfo.getProfileId(),
	        timezonesidkey='America/Chicago', 
	        username='unittest@modelmetrics.com');
	    insert use;
	    
	    List<Account> accs = new List<Account>();
    	
    	Account acc1 = new Account();
    	acc1.Name = 'acc1';
    	acc1.NABCA_Licensee_State__c = 'DM';
    	acc1.OwnerId = use.Id;
    	acc1.Account_Segmentatiobn__c = 'A';
    	acc1.Primary_Demographic__c = 'Asian';
    	acc1.RecordTypeId = accRTIDsByName.get('On-Premise - Control');
    	accs.add(acc1);
    	
    	Account acc2 = new Account();
    	acc2.Name = 'acc2';
    	acc2.NABCA_Licensee_State__c = 'DM';
    	acc2.OwnerId = use.Id;
    	acc2.Account_Segmentatiobn__c = 'A';
    	acc2.Primary_Demographic__c = 'AfAm';
    	acc2.RecordTypeId = accRTIDsByName.get('On-Premise - Control');
    	accs.add(acc2);
    	
    	Account acc3 = new Account();
    	acc3.Name = 'acc3';
    	acc3.NABCA_Licensee_State__c = 'DM';
    	acc3.OwnerId = use.Id;
    	acc3.Account_Segmentatiobn__c = 'A';
    	acc3.Primary_Demographic__c = 'Asian';
    	acc3.RecordTypeId = accRTIDsByName.get('On-Premise - Control');
    	acc3.Called_On__c = true;
    	accs.add(acc3);
    	
    	
    	Account acc4 = new Account();
    	acc4.Name = 'acc4';
    	acc4.NABCA_Licensee_State__c = 'DM';
    	acc4.OwnerId = use.Id;
    	acc4.Account_Segmentatiobn__c = 'A';
    	acc4.Primary_Demographic__c = 'AfAm';
    	acc4.RecordTypeId = accRTIDsByName.get('On-Premise - Control');
    	acc4.Called_On__c = true;
    	accs.add(acc4);
    	
    	insert accs;
    	
    	Goal__c goal = new Goal__c();
    	insert goal;
    	
    	Goal_Product_Link__c gpl = new Goal_Product_Link__c();
    	gpl.Goal__c = goal.Id;
    	gpl.Product_Classification__c = 'test class';
    	gpl.Product_Group__c = 'test group';
    	gpl.Report_Brand__c = 'test report brand';
    	gpl.Generic_Brand__c = 'test generic brand';
    	gpl.Sub_Brand__c = 'test sub brand';
    	gpl.Individual_Brand__c = 'test individual brand';
    	gpl.Size__c = 'test size';
    	insert gpl;
    	
    	List<Action__c> acts = new List<Action__c>();
    	
    	Action__c act1 = new Action__c();
    	act1.Goal__c = goal.Id;
    	act1.Account__c = acc1.Id;
    	acts.add(act1);
    	
    	Action__c act2 = new Action__c();
    	act2.Goal__c = goal.Id;
    	act2.Account__c = acc2.Id;
    	acts.add(act2);
    	
    	Action__c act3 = new Action__c();
    	act3.Goal__c = goal.Id;
    	act3.Account__c = acc3.Id;
    	acts.add(act3);
    	
    	Action__c act4 = new Action__c();
    	act4.Goal__c = goal.Id;
    	act4.Account__c = acc4.Id;
    	acts.add(act4);
    	
    	insert acts;
    	
    	Test.startTest();
    	
    	act1.Status__c = 'Closed - Complete';
    	act2.Status__c = 'Closed - Complete';
    	act3.Status__c = 'Closed - Complete';
    	act4.Status__c = 'Closed - Complete';
    	update acts;
    	
    	Test.stopTest();
    	
    	String stateId = String.valueOf(state.Id).subString(0, 15);
    	String useId = String.valueOf(use.Id).subString(0, 15);
    	
    	List<State_User_Report_Item__c> suris = [SELECT Id, Key__c, Accounts__c, Called_On_Accounts__c FROM State_User_Report_Item__c WHERE State__c = :state.Id OR User__c = :use.Id];
    	System.assertEquals(6, suris.size());
    	for(State_User_Report_Item__c suri : suris){
    		if(suri.Key__c == stateId + '|' + 'A' + '|On' || suri.Key__c == useId + '|' + 'A' + '|On'){
    			System.assertEquals(4, suri.Accounts__c);
    			System.assertEquals(2, suri.Called_On_Accounts__c);
    		} else if(suri.Key__c == stateId + '|' + 'Asian' + '|On' || suri.Key__c == useId + '|' + 'Asian' + '|On'){
    			System.assertEquals(2, suri.Accounts__c);
    			System.assertEquals(1, suri.Called_On_Accounts__c);
    		} else if(suri.Key__c == stateId + '|' + 'AfAm' + '|On' || suri.Key__c == useId + '|' + 'AfAm' + '|On'){
    			System.assertEquals(2, suri.Accounts__c);
    			System.assertEquals(1, suri.Called_On_Accounts__c);
    		}
    	}
    	
    	List<Goal_Account_Report_Item__c> garis =
    		[SELECT Id,
    				Account__c,
    				State_Accounts_AS__c,
    				State_Accounts_PD__c,
    				State_Called_On_Accounts_AS__c,
    				State_Called_On_Accounts_PD__c,
    				User_Accounts_AS__c,
    				User_Accounts_PD__c,
    				User_Called_On_Accounts_AS__c,
    				User_Called_On_Accounts_PD__c
    		   FROM Goal_Account_Report_Item__c
    		  WHERE Goal__c = :goal.Id
    		];
    	System.assertEquals(4, garis.size());
    	for(Goal_Account_Report_Item__c gari : garis){
    		if(gari.Account__c == acc1.Id){
    			System.assertEquals(4, gari.State_Accounts_AS__c);
    			System.assertEquals(2, gari.State_Accounts_PD__c);
    			System.assertEquals(2, gari.State_Called_On_Accounts_AS__c);
    			System.assertEquals(1, gari.State_Called_On_Accounts_PD__c);
    		} else if(gari.Account__c == acc2.Id){
    			System.assertEquals(4, gari.State_Accounts_AS__c);
    			System.assertEquals(2, gari.State_Accounts_PD__c);
    			System.assertEquals(2, gari.State_Called_On_Accounts_AS__c);
    			System.assertEquals(1, gari.State_Called_On_Accounts_PD__c);
    		} else if(gari.Account__c == acc3.Id){
    			System.assertEquals(4, gari.State_Accounts_AS__c);
    			System.assertEquals(2, gari.State_Accounts_PD__c);
    			System.assertEquals(2, gari.State_Called_On_Accounts_AS__c);
    			System.assertEquals(1, gari.State_Called_On_Accounts_PD__c);
    		} else if(gari.Account__c == acc4.Id){
    			System.assertEquals(4, gari.State_Accounts_AS__c);
    			System.assertEquals(2, gari.State_Accounts_PD__c);
    			System.assertEquals(2, gari.State_Called_On_Accounts_AS__c);
    			System.assertEquals(1, gari.State_Called_On_Accounts_PD__c);
    		}
    	}
    	
    	acc4.Primary_Demographic__c = 'Asian';
    	update acc4;
    	
    	suris = [SELECT Id, Key__c, Accounts__c, Called_On_Accounts__c FROM State_User_Report_Item__c WHERE State__c = :state.Id OR User__c = :use.Id];
    	System.assertEquals(6, suris.size());
    	for(State_User_Report_Item__c suri : suris){
    		if(suri.Key__c == stateId + '|' + 'A' + '|On' || suri.Key__c == useId + '|' + 'A' + '|On'){
    			System.assertEquals(4, suri.Accounts__c);
    			System.assertEquals(2, suri.Called_On_Accounts__c);
    		} else if(suri.Key__c == stateId + '|' + 'Asian' + '|On' || suri.Key__c == useId + '|' + 'Asian' + '|On'){
    			System.assertEquals(3, suri.Accounts__c);
    			System.assertEquals(2, suri.Called_On_Accounts__c);
    		} else if(suri.Key__c == stateId + '|' + 'AfAm' + '|On' || suri.Key__c == useId + '|' + 'AfAm' + '|On'){
    			System.assertEquals(1, suri.Accounts__c);
    			System.assertEquals(0, suri.Called_On_Accounts__c);
    		}
    	}
    	
    	garis =
    		[SELECT Id,
    				Account__c,
    				State_Accounts_AS__c,
    				State_Accounts_PD__c,
    				State_Called_On_Accounts_AS__c,
    				State_Called_On_Accounts_PD__c,
    				User_Accounts_AS__c,
    				User_Accounts_PD__c,
    				User_Called_On_Accounts_AS__c,
    				User_Called_On_Accounts_PD__c
    		   FROM Goal_Account_Report_Item__c
    		  WHERE Goal__c = :goal.Id
    		];
    	System.assertEquals(4, garis.size());
    	for(Goal_Account_Report_Item__c gari : garis){
    		if(gari.Account__c == acc1.Id){
    			System.assertEquals(4, gari.State_Accounts_AS__c);
    			System.assertEquals(3, gari.State_Accounts_PD__c);
    			System.assertEquals(2, gari.State_Called_On_Accounts_AS__c);
    			System.assertEquals(2, gari.State_Called_On_Accounts_PD__c);
    		} else if(gari.Account__c == acc2.Id){
    			System.assertEquals(4, gari.State_Accounts_AS__c);
    			System.assertEquals(1, gari.State_Accounts_PD__c);
    			System.assertEquals(2, gari.State_Called_On_Accounts_AS__c);
    			System.assertEquals(0, gari.State_Called_On_Accounts_PD__c);
    		} else if(gari.Account__c == acc3.Id){
    			System.assertEquals(4, gari.State_Accounts_AS__c);
    			System.assertEquals(3, gari.State_Accounts_PD__c);
    			System.assertEquals(2, gari.State_Called_On_Accounts_AS__c);
    			System.assertEquals(2, gari.State_Called_On_Accounts_PD__c);
    		} else if(gari.Account__c == acc4.Id){
    			System.assertEquals(4, gari.State_Accounts_AS__c);
    			System.assertEquals(3, gari.State_Accounts_PD__c);
    			System.assertEquals(2, gari.State_Called_On_Accounts_AS__c);
    			System.assertEquals(2, gari.State_Called_On_Accounts_PD__c);
    		}
    	}
    }
}