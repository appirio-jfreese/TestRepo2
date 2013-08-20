@isTest
private class ActionAssignmentControllerTest {

    static testMethod void testActionAssignmentController() {
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
        
        Account acc1 = new Account();
        acc1.Name = 'Test Account';
        acc1.Territory__c = terr1.Id;
        acc1.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'On Premise'].Id;
        acc1.Called_On__c = true;
        acc1.OwnerId = rep1.Id;
        insert acc1;
        
        Account acc2 = new Account();
        acc2.Name = 'Test Account';
        acc2.Territory__c = terr1.Id;
        acc2.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Off Premise'].Id;
        acc2.Called_On__c = true;
        acc2.OwnerId = rep1.Id;
        insert acc2;
        
        Goal__c goal1 = new Goal__c();
        goal1.Priority__c = 'National';
        goal1.OwnerId = mgr1.Id;
        goal1.Goal_For__c = mgr1.Id;
        goal1.Name = 'Distribution Goals - Dave Test - On';
        goal1.Goal_Type__c = 'On-Premise - Control';
        goal1.State__c = 'PA';
        goal1.Minimum_of_Accounts__c = 2;
        goal1.Start_Date__c = Date.today();
        goal1.Due_Date__c = Date.today().addDays(1);
        goal1.Goal_Level__c = 'Manager';
        insert goal1;
        
        Goal_Product_Link__c gpl1 = new Goal_Product_Link__c();
        gpl1.Generic_Brand__c = 'Test Brand';
        gpl1.Goal__c = goal1.Id;
        insert gpl1;
        
        Goal__c goal2 = new Goal__c();
        goal2.Priority__c = 'National';
        goal2.OwnerId = rep1.Id;
        goal2.Goal_For__c = rep1.Id;
        goal2.Name = 'Distribution Goals - Dave Test - On';
        goal2.Goal_Type__c = 'On-Premise - Control';
        goal2.State__c = 'PA';
        goal2.Minimum_of_Accounts__c = 2;
        goal2.Start_Date__c = Date.today();
        goal2.Due_Date__c = Date.today().addDays(1);
        goal2.Goal_Level__c = 'Rep';
        insert goal2;
        
        Goal_Product_Link__c gpl2 = new Goal_Product_Link__c();
        gpl2.Generic_Brand__c = 'Test Brand';
        gpl2.Goal__c = goal2.Id;
        insert gpl2;
        
        Map<String, Id> goalRTIdsByDevName = new Map<String, Id>();
        for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Goal__c']){
        	goalRTIdsByDevName.put(rt.DeveloperName, rt.Id);
        }
        
        Test.startTest();
        
        System.runAs(mgr1){
        	ActionAssignmentController cont = new ActionAssignmentController();
        	
        	cont.dummyGoalId = goal1.Id;
        	ActionAssignmentController.getManagerTerritories();
        	ActionAssignmentController.getUserGoals();
        	ActionAssignmentController.getPriorities();
        	cont.assignDummyEditGoal();
        	cont.doNothing();
        	cont.saveDummyGoal();
        	
        	List<Goal__c> childGoals = new List<Goal__c>();
        	Goal__c childGoal = new Goal__c();
        	childGoal.Parent_Goal__c = goal1.Id;
        	childGoal.Goal_For__c = rep1.Id;
        	childGoals.add(childGoal);
        	ActionAssignmentGoalSaver.saveGoals(childGoals);
        }
        
        System.runAs(rep1){
        	ActionAssignmentController cont = new ActionAssignmentController();
        	
        	cont.dummyGoalId = goal2.Id;
        	ActionAssignmentController.getRepTerritories();
        	cont.assignDummyViewGoal();
        	
        	goal2.RecordTypeId = goalRTIdsByDevName.get('Ad_Execution');
        	update goal2;
        	cont.assignDummyViewGoal();
        	
        	goal2.RecordTypeId = goalRTIdsByDevName.get('Cold_Box_Goals');
        	update goal2;
        	cont.assignDummyViewGoal();
        	
        	goal2.RecordTypeId = goalRTIdsByDevName.get('Display_Goals');
        	update goal2;
        	cont.assignDummyViewGoal();
        	
        	goal2.RecordTypeId = goalRTIdsByDevName.get('Distribution_POD_Goals');
        	update goal2;
        	cont.assignDummyViewGoal();
        	
        	goal2.RecordTypeId = goalRTIdsByDevName.get('Ease_of_Shop');
        	update goal2;
        	cont.assignDummyViewGoal();
        	
        	goal2.RecordTypeId = goalRTIdsByDevName.get('Feature');
        	update goal2;
        	cont.assignDummyViewGoal();
        	
        	goal2.RecordTypeId = goalRTIdsByDevName.get('Menu');
        	update goal2;
        	cont.assignDummyViewGoal();
        	
        	goal2.RecordTypeId = goalRTIdsByDevName.get('Shelf_Set_Goals');
        	update goal2;
        	cont.assignDummyViewGoal();
        	
        	goal2.RecordTypeId = goalRTIdsByDevName.get('Staff_Training_Goals');
        	update goal2;
        	cont.assignDummyViewGoal();
        	
        	goal2.RecordTypeId = goalRTIdsByDevName.get('Tasting_Goals');
        	update goal2;
        	cont.assignDummyViewGoal();
        	
        	goal2.RecordTypeId = goalRTIdsByDevName.get('Volume_Goals');
        	update goal2;
        	cont.assignDummyViewGoal();
        	
        	goal2.RecordTypeId = goalRTIdsByDevName.get('Window_Display_Goals');
        	update goal2;
        	cont.assignDummyViewGoal();
        	
        	List<String> terrIds = new List<String>();
        	terrIds.add(terr1.Id);
        	ActionAssignmentController.getAccounts(terrIds);
        	
        	ActionAssignmentController.saveActions(goal2.Id, acc1.Id + ',' + acc2.Id);
        }
    }
}