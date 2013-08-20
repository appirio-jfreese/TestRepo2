@isTest
private class GoalCreation2ControllerTest {

    static testMethod void testGoalCreation2Controller() {
        //Create data
        Id samProfId = [SELECT Id FROM Profile WHERE Name = 'Control - Sales Manager'].Id;
        User sam = Test_RecordUtil.newUser('sam', samProfId);
        
        Id dirProfId = [SELECT Id FROM Profile WHERE Name = 'Control - Sales Manager'].Id;
        User dir1 = Test_RecordUtil.newUser('dir1', dirProfId);
        User dir2 = Test_RecordUtil.newUser('dir2', dirProfId);
        
        User mgr1 = Test_RecordUtil.newUser('mgr1', dirProfId);
        User mgr2 = Test_RecordUtil.newUser('mgr2', dirProfId);
        
        List<User> users = new List<User>();
        users.add(sam);
        users.add(dir1);
        users.add(dir2);
        users.add(mgr1);
        users.add(mgr2);
        insert users;
        
        //create territories
        Territory__c terr1 = Test_RecordUtil.newTerritory('terr1');
        terr1.SAM__c = sam.Id;
        terr1.Director__c = dir1.Id;
        terr1.Manager__c = mgr1.Id;
        Territory__c terr2 = Test_RecordUtil.newTerritory('terr2');
        terr2.SAM__c = sam.Id;
        terr2.Director__c = dir2.Id;
        terr2.Manager__c = mgr2.Id;
        
        List<Territory__c> terrs = new List<Territory__c>();
        terrs.add(terr1);
        terrs.add(terr2);
        insert terrs;
        
        //create accounts
        Map<String, Id> accRTIdsByName = new Map<String, Id>();
        for(RecordType accRT : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account']){
        	accRTIdsByName.put(accRT.name, accRT.Id);
        }
        
        List<Account> accs = new List<Account>();
        for(Integer i = 0; i < 10; i++){
        	accs.add(Test_RecordUtil.newAccount('onPrem terr1 acc' + i, terr1.Id, accRTIdsByName.get('On-Premise - Control')));
        	accs.add(Test_RecordUtil.newAccount('onPrem terr2 acc' + i, terr2.Id, accRTIdsByName.get('On-Premise - Control')));
        	accs.add(Test_RecordUtil.newAccount('offPrem terr1 acc' + i, terr1.Id, accRTIdsByName.get('Off-Premise - Control')));
        	accs.add(Test_RecordUtil.newAccount('offPrem terr2 acc' + i, terr2.Id, accRTIdsByName.get('Off-Premise - Control')));
       	}
        insert accs;
        
        List<AccountShare> accShares = new List<AccountShare>();
        for(Account acc : accs){
        	AccountShare share1 = new AccountShare();
        	share1.AccountId = acc.Id;
        	share1.UserOrGroupId = sam.Id;
        	share1.AccountAccessLevel = 'Read';
        	share1.OpportunityAccessLevel = 'Read';
        	accShares.add(share1);
        	
        	AccountShare share2 = new AccountShare();
        	share2.AccountId = acc.Id;
        	share2.UserOrGroupId = dir1.Id;
        	share2.AccountAccessLevel = 'Read';
        	share2.OpportunityAccessLevel = 'Read';
        	accShares.add(share2);
        	
        	AccountShare share3 = new AccountShare();
        	share3.AccountId = acc.Id;
        	share3.UserOrGroupId = dir2.Id;
        	share3.AccountAccessLevel = 'Read';
        	share3.OpportunityAccessLevel = 'Read';
        	accShares.add(share3);
        }
		insert accShares;
		
		//create programs
        Calendar__c dispProg = Test_RecordUtil.newCalendar('dispProg', 'Integrated National Program');
        dispProg.Start_Date__c = Date.today();
   		insert dispProg;
		
		Product__c prod = new Product__c();
		prod.Product_Group__c = 'testGroup';
		prod.Product_Classification__c = 'testClassification';
		prod.Report_Brand__c = 'testReport';
		prod.Generic_Brand__c = 'testGene\'ric';
		prod.Sub_Brand__c = 'testSub';
		prod.Individual_Brand__c = 'testInd';
		prod.Size__c = 'testSize';
		prod.Brand_Composite_Key__c = 'testKey';
		insert prod;
		
		//*** START TEST ***
        Test.startTest();
        
        //*** TEST CONTENT ***
        System.runAs(sam){
        	//init
        	GoalCreation2Controller cont = new GoalCreation2Controller();
        	
        	cont.dummyGoal.Priority__c = 'Local';
        	cont.prioritySelected();
        	cont.dummyGoal.Priority__c = 'National';
        	cont.prioritySelected();
        	
        	cont.dummyGoal.Program__c = dispProg.Id;
        	cont.programSelected();
        	
        	cont.populatePLSelects();
        	
        	cont.currentPLIndex = 0;
        	cont.pls[0].prodSel1 = prod.Generic_Brand__c;
        	cont.prodSel1Changed();
        	
        	GoalCreation2Controller.errorMessage = 'test';
        	
        	GoalCreation2Controller.ProductLine pl = new GoalCreation2Controller.ProductLine(0);
        	pl.prodSel1 = 'something';
        	pl.calculateLowestName();
        	pl.prodSel2 = 'something';
        	pl.calculateLowestName();
        	pl.prodSel3 = 'something';
        	pl.calculateLowestName();
        	pl.addExistingData(new Goal_Product_Link__c());
        	pl.addExistingData(pl);
        	
        	GoalCreation2Controller.SubPremLine spl = new GoalCreation2Controller.SubPremLine('id', 'name', 'prem', terr1);
        	
        	cont.confirmDirector();
        	cont.confirmManager();
        }
    }
}