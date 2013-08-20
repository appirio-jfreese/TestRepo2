@isTest
private class PerformanceControllerTest {

    static testMethod void testPerformanceController() {
    	Id samProfId = [SELECT Id FROM Profile WHERE Name = 'Control - Sales Manager'].Id;
        User sam = Test_RecordUtil.newUser('sam', samProfId);
        User dir1 = Test_RecordUtil.newUser('dir1', samProfId);
        User mgr1 = Test_RecordUtil.newUser('mgr1', samProfId);
        User rep1 = Test_RecordUtil.newUser('rep1', samProfId);
        User dirmgr1 = Test_RecordUtil.newUser('dirmgr1', samProfId);
        
        List<User> users = new List<User>();
        users.add(sam);
        users.add(dir1);
        users.add(mgr1);
        users.add(rep1);
        users.add(dirmgr1);
        insert users;
        
        //create territories
        Territory__c terr1 = Test_RecordUtil.newTerritory('terr1');
        terr1.SAM__c = sam.Id;
        terr1.Director__c = dir1.Id;
        terr1.Manager__c = mgr1.Id;
        terr1.OwnerId = rep1.Id;
        insert terr1;
        Territory__c terr2 = Test_RecordUtil.newTerritory('terr2');
        terr2.SAM__c = sam.Id;
        terr2.Director__c = dirmgr1.Id;
        terr2.Manager__c = dirmgr1.Id;
        terr2.OwnerId = rep1.Id;
        insert terr2;
        
        Goal__c goal1 = new Goal__c();
        goal1.Priority__c = 'National';
        goal1.OwnerId = dir1.Id;
        goal1.Goal_For__c = dir1.Id;
        goal1.Name = 'Distribution Goals - Dave Test - On';
        goal1.Goal_Type__c = 'On-Premise - Control';
        goal1.State__c = 'PA';
        goal1.Minimum_of_Accounts__c = 2;
        goal1.Action_Complete__c = 1;
        goal1.Start_Date__c = Date.today();
        goal1.Due_Date__c = Date.today().addDays(1);
        goal1.Goal_Level__c = 'Director';
        insert goal1;
    	
    	Goal__Share gs1 = new Goal__Share();
    	gs1.ParentId = goal1.Id;
    	gs1.UserOrGroupId = sam.Id;
    	gs1.AccessLevel = 'Read';
    	insert gs1;
    	
        //*** START TEST ***
        Test.startTest();
        
        //*** TEST CONTENT ***
    	PerformanceController cont;
		cont = new PerformanceController();
    	System.runAs(sam){
    		cont = new PerformanceController();
    	}
    	System.runAs(dir1){
    		cont = new PerformanceController();
    	}
    	System.runAs(mgr1){
    		cont = new PerformanceController();
    	}
    	System.runAs(rep1){
    		cont = new PerformanceController();
    	}
    	System.runAs(dirmgr1){
    		cont = new PerformanceController();
    		cont.levelSel = 'mgr';
    		cont.levelChanged();
    		cont.dateSel = 'last';
    		cont.dateChanged();
    		cont.dateSel = 'next';
    		cont.dateChanged();
    		cont.nameChanged();
    		//cont.gBrandChanged();
    		//cont.iBrandChanged();
    		cont.typeChanged();
    		cont.forChanged();
    		cont.priorChanged();
    		cont.rtChanged();
    		cont.stateChanged();
    		cont.groupByChanged();
    		cont.sortByChanged();
    	}
        	
    }
}