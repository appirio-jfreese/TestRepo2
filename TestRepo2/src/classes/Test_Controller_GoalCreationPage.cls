@isTest
private class Test_Controller_GoalCreationPage {
/* This class is no longer used -- kept for archival purposes
    static testMethod void testPageAsSAM() {
        //*** CREATE DATA ***
        
        //create users
        Id samProfId = [SELECT Id FROM Profile WHERE Name = 'Control - Sales Manager'].Id;
        User sam = Test_RecordUtil.newUser('sam', samProfId);
        
        Id dirProfId = [SELECT Id FROM Profile WHERE Name = 'Control - Sales Manager'].Id;
        User dir1 = Test_RecordUtil.newUser('dir1', dirProfId);
        User dir2 = Test_RecordUtil.newUser('dir2', dirProfId);
        
        List<User> users = new List<User>();
        users.add(sam);
        users.add(dir1);
        users.add(dir2);
        insert users;
        
        //create territories
        Territory__c terr1 = Test_RecordUtil.newTerritory('terr1');
        terr1.SAM__c = sam.Id;
        terr1.Director__c = dir1.Id;
        Territory__c terr2 = Test_RecordUtil.newTerritory('terr2');
        terr2.SAM__c = sam.Id;
        terr2.Director__c = dir2.Id;
        
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
        	//REMOVE COMBINED accs.add(Test_RecordUtil.newAccount('combined terr1 acc' + i, terr1.Id, accRTIdsByName.get('Combined Premise - Control')));
        	//REMOVE COMBINED accs.add(Test_RecordUtil.newAccount('combined terr2 acc' + i, terr2.Id, accRTIdsByName.get('Combined Premise - Control')));
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
        Calendar__c distProg = Test_RecordUtil.newCalendar('distProg', 'Innovation');
        dispProg.Start_Date__c = Date.today();
        distProg.Start_Date__c = Date.today();
   		insert dispProg;
   		insert distProg;
        
        //create brand
        Brand__c brand = Test_RecordUtil.newBrand('Captain Morgan');
        insert brand;
        
        //create bottle sizes
        Bottle_Size__c bots1 = Test_RecordUtil.newBottleSize('1L');
        Bottle_Size__c bots2 = Test_RecordUtil.newBottleSize('1.5L');
        insert bots1;
        insert bots2;
        
        //create brand bottle sizes
        BrandBottle_Size__c bbs1 = Test_RecordUtil.newBrandBottleSize('Captain Morgan 1L', brand.Id, bots1.Id);
        BrandBottle_Size__c bbs2 = Test_RecordUtil.newBrandBottleSize('Captain Morgan 1.5L', brand.Id, bots2.Id);
        insert bbs1;
        insert bbs2;
        
        
        //*** START TEST ***
        Test.startTest();
        
        //*** TEST CONTENT ***
        System.runAs(sam){
        	//init
        	Controller_GoalCreationPage cont = new Controller_GoalCreationPage(new ApexPages.StandardSetController(new List<Goal__c>()));
        	System.assertEquals(false, cont.isProgramSelected);
        	
        	//select program
        	cont.dummyGoal.Program__c = dispProg.Id;
        	cont.programSelected();
        	System.assertEquals(true, cont.isProgramSelected);
        	System.assertEquals(false, cont.readOnlyMode);
        	System.assertEquals(dispProg.Id, cont.cal.Id);
        	System.assertEquals('Display', cont.goalRecType);
        	System.assertEquals('On-Premise - Control', cont.premiseValue);
        	//System.assertEquals(2, cont.dispMPs.size());
        	System.assertEquals(0, cont.totalAccsSelected);
        	
        	//add brand bottle goal
        	Controller_GoalCreationPage.ManagerPremise firstMP = cont.mpsByMgrByPrem.get('On-Premise - Control').get(dir1.Id);
        	cont.bbgMPPrem = 'On-Premise - Control';
        	cont.bbgMPMgrId = dir1.Id;
        	cont.bbgSelName = 'Captain Morgan 1L';
        	firstMP.dummyBBG.BrandBottle_Size__c = bbs1.Id;
        	cont.addBBG();
        	System.assertEquals(1, firstMP.bbgOptions.size());
        	
        	//copy brand bottle goal;
        	Controller_GoalCreationPage.ManagerPremise secondMP = cont.mpsByMgrByPrem.get('On-Premise - Control').get(dir1.Id);
        	firstMP.selectedBBGs.add(bbs1.Id);
        	cont.copyBBGs();
        	System.assertEquals(1, secondMP.bbgOptions.size());
        	
        	//add another brand bottle goal
        	cont.bbgSelName = 'Captain Morgan 1.5L';
        	firstMP.dummyBBG.BrandBottle_Size__c = bbs2.Id;
        	cont.addBBG();
        	System.assertEquals(2, firstMP.bbgOptions.size());
        	
        	//remove brand bottle goal
        	firstMP.selectedBBGs = new List<String>();
        	firstMP.selectedBBGs.add(bbs1.Id);
        	cont.removeBBGs();
        	System.assertEquals(1, firstMP.bbgOptions.size());
        	
        	//test error checking
        	System.assertEquals(true, cont.checkForErrors());
        	System.assertEquals(null, cont.saveClicked());
        	
        	//resolve errors
        	for(Map<Id, Controller_GoalCreationPage.ManagerPremise> mpMap : cont.mpsByMgrByPrem.values()){
				for(Controller_GoalCreationPage.ManagerPremise mp : mpMap.values()){
					mp.goal.Minimum_of_Accounts__c = 5;
				}
        	}
        	
        	//test save
        	cont.saveClicked();
        	
        	//come back in
        	System.assertEquals(false, cont.isProgramSelected);
        	cont.dummyGoal.Program__c = dispProg.Id;
        	cont.programSelected();
        	System.assertEquals(true, cont.isProgramSelected);
        	System.assertEquals(false, cont.readOnlyMode);
        	
        	//test save and submit
        	cont.submitClicked();
        	cont.confirmationSubmitClicked();
        	
        	//come back in
        	System.assertEquals(false, cont.isProgramSelected);
        	cont.dummyGoal.Program__c = dispProg.Id;
        	cont.programSelected();
        	System.assertEquals(true, cont.isProgramSelected);
        	//System.assertEquals(true, cont.readOnlyMode);
        	
        	//come back in and load distribution program
        	cont = new Controller_GoalCreationPage(new ApexPages.StandardSetController(new List<Goal__c>()));
        	cont.dummyGoal.Program__c = distProg.Id;
        	cont.programSelected();
        	//System.assertEquals(false, cont.readOnlyMode);
        	System.assertEquals('Distribution', cont.goalRecType);
        	
        }
        
        System.runAs(dir1){
        	//init
        	Controller_GoalCreationPage cont = new Controller_GoalCreationPage(new ApexPages.StandardSetController(new List<Goal__c>()));
        	System.assertEquals(false, cont.isProgramSelected);
        	
        	//select program
        	cont.dummyGoal.Program__c = dispProg.Id;
        	cont.programSelected();
        	
        	//resolve errors
        	for(Map<Id, Controller_GoalCreationPage.ManagerPremise> mpMap : cont.mpsByMgrByPrem.values()){
				for(Controller_GoalCreationPage.ManagerPremise mp : mpMap.values()){
					mp.goal.Minimum_of_Accounts__c = 5;
				}
        	}
        	
        	//test save
        	cont.saveClicked();
        	
        	//come back in
        	System.assertEquals(false, cont.isProgramSelected);
        	cont.dummyGoal.Program__c = dispProg.Id;
        	cont.programSelected();
        	System.assertEquals(true, cont.isProgramSelected);
        	System.assertEquals(false, cont.readOnlyMode);
        }
        
        //*** STOP TEST ***
        Test.stopTest();
        
        //*** VALIDATION ***
        

    }
*/
}