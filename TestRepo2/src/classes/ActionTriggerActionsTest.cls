@IsTest
private class ActionTriggerActionsTest {
	
	static testmethod void testCheckGoalParentage(){
		Goal__c goal = new Goal__c();
		insert goal;
		
		Goal__c goal2 = new Goal__c();
		insert goal2;
		
		Goal_Product_Link__c gpl1 = new Goal_Product_Link__c();
		gpl1.Goal__c = goal.Id;
		gpl1.Product_Classification__c = 'test1';
		gpl1.Product_Group__c = 'test1';
		gpl1.Report_Brand__c = 'test1';
		gpl1.Generic_Brand__c = 'test1';
		gpl1.Sub_Brand__c = 'test1';
		gpl1.Individual_Brand__c = 'test1';
		gpl1.Size__c = 'test1';
		insert gpl1;
		
		Goal_Product_Link__c gpl2 = new Goal_Product_Link__c();
		gpl2.Goal__c = goal.Id;
		gpl2.Product_Classification__c = 'test2';
		gpl2.Product_Group__c = 'test2';
		gpl2.Report_Brand__c = 'test2';
		gpl2.Generic_Brand__c = 'test2';
		gpl2.Sub_Brand__c = 'test2';
		gpl2.Individual_Brand__c = 'test2';
		gpl2.Size__c = 'test2';
		insert gpl2;
		
		Goal_Product_Link__c gpl3 = new Goal_Product_Link__c();
		gpl3.Goal__c = goal2.Id;
		gpl3.Product_Classification__c = 'test3';
		gpl3.Product_Group__c = 'test3';
		gpl3.Report_Brand__c = 'test3';
		gpl3.Generic_Brand__c = 'test3';
		gpl3.Sub_Brand__c = 'test3';
		gpl3.Individual_Brand__c = 'test3';
		gpl3.Size__c = 'test3';
		insert gpl3;
		
		gpl1 = [SELECT Id, Match_Key__c FROM Goal_Product_Link__c WHERE Id = :gpl1.Id];
		gpl2 = [SELECT Id, Match_Key__c FROM Goal_Product_Link__c WHERE Id = :gpl2.Id];
		gpl3 = [SELECT Id, Match_Key__c FROM Goal_Product_Link__c WHERE Id = :gpl3.Id];
		
		List<Action__c> acts = new List<Action__c>();
		
		Action__c act1 = new Action__c();
		act1.Goal__c = goal.Id;
		acts.add(act1);
		
		Action__c act2 = new Action__c();
		acts.add(act2);
		
		Test.startTest();
		
		//test insert on act1
		insert acts;
		
		Test.stopTest();
	}
	/*
	static testmethod void testCheckGoalParentage2(){
		Map<Id, RecordType> actionRTs = new Map<Id, RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Action__c']);
		
		Id onAccRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'On-Premise - Control'].Id;
		Id offAccRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Off-Premise - Control'].Id;
		
		Account onAcc = new Account();
		onAcc.Name = 'test on acc';
		onAcc.RecordTypeId = onAccRTId;
		insert onAcc;
		
		Account offAcc = new Account();
		offAcc.Name = 'test off acc';
		offAcc.RecordTypeId = offAccRTId;
		insert offAcc;
		
		List<Action__c> actsToInsert = new List<Action__c>();
		
		for(RecordType rt : actionRTs.values()){
			if(rt.DeveloperName.startsWith('Ease_of_Shop') == false){
				Action__c onAct = new Action__c();
				onAct.RecordTypeId = rt.Id;
				onAct.Account__c = onAcc.Id;
				actsToInsert.add(onAct);
				
				Action__c offAct = new Action__c();
				offAct.RecordTypeId = rt.Id;
				offAct.Account__c = offAcc.Id;
				actsToInsert.add(offAct);
			}
		}
		
		Test.startTest();
		
		insert actsToInsert;
		
		Test.stopTest();
		
		actsToInsert = [SELECT Id, Goal__c, RecordTypeId, RecordType.Name FROM Action__c WHERE Id IN :actsToInsert];
		for(Action__c act : actsToInsert){
			System.assertNotEquals(null, act.Goal__c, act.RecordType.Name);
		}
		
		Action__c newAct = new Action__c();
		newAct.RecordTypeId = actsToInsert[0].RecordTypeId;
		newAct.Account__c = onAcc.Id;
		insert newAct;
		
		newAct = [SELECT Id, Goal__c FROM Action__c WHERE Id = :newAct.Id];
		Goal__c newActParent = [SELECT Id, (SELECT Id FROM Actions__r) FROM Goal__c WHERE Id = :newAct.Goal__c];
		System.assertNotEquals(null, newActParent);
		//System.assertEquals(16, newActParent.Actions__r.size());
		
		Action__c oldAct = actsToInsert[0];
		oldAct.Goal__c = null;
		update oldAct;
		
		oldAct = [SELECT Id, Goal__c FROM Action__c WHERE Id = :oldAct.Id];
		System.assertEquals(newActParent.Id, oldAct.Goal__c);
	}*/
	
	static testmethod void testValidateProductLinks(){
    	Goal__c repGoal = new Goal__c();
    	repGoal.Minimum_of_Accounts__c = 1;
    	repGoal.Goal_Level__c = 'Rep';
    	repGoal.Name = 'repGoal';
    	insert repGoal;
    	
    	Action__c act = new Action__c();
    	act.Goal__c = repGoal.Id;
    	insert act;
    	
    	Action_Product_Link__c apl = new Action_Product_Link__c();
    	apl.Action__c = act.Id;
    	apl.Generic_Brand__c = 'Generic test value';
    	insert apl;
    	
    	Test.startTest();
    	
    	Boolean errorThrown = false;
    	try {
	    	act.Status__c = 'Closed - Complete';
	    	update act;
    	} catch(Exception e){
    		errorThrown = true;
    	}
    	
    	System.assertEquals(true, errorThrown);
    	act = [SELECT Id, Status__c FROM Action__c WHERE Id = :act.Id];
    	System.assertEquals(false, act.Status__c == 'Closed - Complete');
    	
		apl.Individual_Brand__c = 'Individual test value';
		apl.Size__c = 'Size test value';
		update apl;
    	
    	act.Status__c = 'Closed - Complete';
    	update act;
    	
    	act = [SELECT Id, Status__c FROM Action__c WHERE Id = :act.Id];
    	System.assertEquals('Closed - Complete', act.Status__c);
    	
    	Test.stopTest();
	}
	
    static testmethod void testActionCountUpdatesOnGoal(){
    	Goal__c dirGoal = new Goal__c();
    	dirGoal.Minimum_of_Accounts__c = 100;
    	dirGoal.Goal_Level__c = 'Director';
    	dirGoal.Name = 'dirGoal';
    	insert dirGoal;
    	
    	List<Goal__c> mgrGoals = new List<Goal__c>();
    	for(Integer i = 0; i < 1; i++){
    		Goal__c mgrGoal = new Goal__c();
	    	mgrGoal.Minimum_of_Accounts__c = 10;
	    	mgrGoal.Goal_Level__c = 'Manager';
	    	mgrGoal.Parent_Goal__c = dirGoal.Id;
	    	mgrGoal.Name = 'mgrGoal' + i;
	    	mgrGoals.add(mgrGoal);
    	}
    	System.assertEquals(1, mgrGoals.size());
    	insert mgrGoals;
    	
    	List<Goal__c> repGoals = new List<Goal__c>();
    	for(Goal__c mgrGoal : mgrGoals){
    		for(Integer i = 0; i < 1; i++){
	    		Goal__c repGoal = new Goal__c();
		    	repGoal.Minimum_of_Accounts__c = 1;
		    	repGoal.Goal_Level__c = 'Rep';
		    	repGoal.Parent_Goal__c = mgrGoal.Id;
		    	repGoal.Name = 'repGoal' + i;
		    	repGoals.add(repGoal);
    		}
    	}
    	System.assertEquals(1, repGoals.size());
    	insert repGoals;
    	
    	List<Action__c> allActions = new List<Action__c>();
    	List<Action__c> compActions = new List<Action__c>();
    	for(Goal__c repGoal : repGoals){
    		for(Integer i = 0; i < 1; i++){
    			Action__c act = new Action__c();
    			act.Goal__c = repGoal.Id;
    			act.Cases_Displayed__c = 10;
    			allActions.add(act);
    			if(i < 4){
    				compActions.add(act);
    			}
    		}
    	}
    	System.assertEquals(1, allActions.size());
    	System.assertEquals(1, compActions.size());
    	
    	
    	Test.startTest();
    	
    	
    	insert allActions;
    	
    	repGoals = [SELECT Id, Action_Count__c, Action_Complete__c, Cases_Complete__c FROM Goal__c WHERE Id IN :repGoals];
    	for(Goal__c goal : repGoals){
	    	//System.assertEquals(10, goal.Action_Count__c);
	    	System.assertEquals(0, goal.Action_Complete__c);
	    	System.assertEquals(0, goal.Cases_Complete__c);
    	}
    	
    	mgrGoals = [SELECT Id, Action_Count__c, Action_Complete__c, Cases_Complete__c FROM Goal__c WHERE Id IN :mgrGoals];
    	for(Goal__c goal : mgrGoals){
	    	//System.assertEquals(100, goal.Action_Count__c);
	    	System.assertEquals(0, goal.Action_Complete__c);
	    	System.assertEquals(0, goal.Cases_Complete__c);
    	}
    	
    	dirGoal = [SELECT Id, Action_Count__c, Action_Complete__c, Cases_Complete__c FROM Goal__c WHERE Id = :dirGoal.Id];
    	//System.assertEquals(1000, dirGoal.Action_Count__c);
	    System.assertEquals(0, dirGoal.Action_Complete__c);
	    System.assertEquals(0, dirGoal.Cases_Complete__c);
    	
    	List<Action_Product_Link__c> apls = new List<Action_Product_Link__c>();
    	for(Action__c act : compActions){
    		act.Status__c = 'Closed - Complete';
    		
    		Action_Product_Link__c apl = new Action_Product_Link__c();
	    	apl.Action__c = act.Id;
	    	apl.Generic_Brand__c = 'Generic test value';
	    	apl.Sub_Brand__c = 'Generic test value';
	    	apl.Individual_Brand__c = 'Generic test value';
	    	apl.Size__c = 'Generic test value';
	    	apls.add(apl);
    	}
    	
    	insert apls;
    	update allActions;
    	
    	
    	Test.stopTest();
    	
    	
    	repGoals = [SELECT Id, Action_Count__c, Action_Complete__c, Cases_Complete__c FROM Goal__c WHERE Id IN :repGoals];
    	for(Goal__c goal : repGoals){
	    	//System.assertEquals(10, goal.Action_Count__c);
	    	System.assertEquals(1, goal.Action_Complete__c);
	    	System.assertEquals(10, goal.Cases_Complete__c);
    	}
    	
    	mgrGoals = [SELECT Id, Action_Count__c, Action_Complete__c, Cases_Complete__c FROM Goal__c WHERE Id IN :mgrGoals];
    	for(Goal__c goal : mgrGoals){
	    	//System.assertEquals(100, goal.Action_Count__c);
	    	System.assertEquals(1, goal.Action_Complete__c);
	    	System.assertEquals(10, goal.Cases_Complete__c);
    	}
    	
    	dirGoal = [SELECT Id, Action_Count__c, Action_Complete__c, Cases_Complete__c FROM Goal__c WHERE Id = :dirGoal.Id];
    	//System.assertEquals(1000, dirGoal.Action_Count__c);
    	System.assertEquals(1, dirGoal.Action_Complete__c);
    	System.assertEquals(10, dirGoal.Cases_Complete__c);
    }
    /*
    static testmethod void testActionCountUpdatesOnGoal3(){
    	Goal__c dirGoal = new Goal__c();
    	dirGoal.Minimum_of_Accounts__c = 1000;
    	dirGoal.Goal_Level__c = 'Director';
    	dirGoal.Name = 'dirGoal';
    	insert dirGoal;
    	
    	List<Goal__c> mgrGoals = new List<Goal__c>();
    	for(Integer i = 0; i < 10; i++){
    		Goal__c mgrGoal = new Goal__c();
	    	mgrGoal.Minimum_of_Accounts__c = 100;
	    	mgrGoal.Goal_Level__c = 'Manager';
	    	mgrGoal.Parent_Goal__c = dirGoal.Id;
	    	mgrGoal.Name = 'mgrGoal' + i;
	    	mgrGoals.add(mgrGoal);
    	}
    	System.assertEquals(10, mgrGoals.size());
    	insert mgrGoals;
    	
    	List<Goal__c> repGoals = new List<Goal__c>();
    	for(Goal__c mgrGoal : mgrGoals){
    		for(Integer i = 0; i < 10; i++){
	    		Goal__c repGoal = new Goal__c();
		    	repGoal.Minimum_of_Accounts__c = 10;
		    	repGoal.Goal_Level__c = 'Rep';
		    	repGoal.Parent_Goal__c = mgrGoal.Id;
		    	repGoal.Name = 'repGoal' + i;
		    	repGoals.add(repGoal);
    		}
    	}
    	System.assertEquals(100, repGoals.size());
    	insert repGoals;
    	
    	List<Action__c> allActions = new List<Action__c>();
    	for(Goal__c repGoal : repGoals){
    		for(Integer i = 0; i < 10; i++){
    			Action__c act = new Action__c();
    			act.Goal__c = repGoal.Id;
    			act.Cases_Displayed__c = 10;
    			allActions.add(act);
    			if(i < 4){
    				act.Status__c = 'Closed - Complete';
    			}
    		}
    	}
    	System.assertEquals(1000, allActions.size());
    	
    	insert allActions;
    	
    	Test.startTest();
    	
    	delete allActions;
    	
    	Test.stopTest();
    	
    	repGoals = [SELECT Id, Action_Count__c, Action_Complete__c, Cases_Complete__c FROM Goal__c WHERE Id IN :repGoals];
    	for(Goal__c goal : repGoals){
	    	//System.assertEquals(10, goal.Action_Count__c);
	    	System.assertEquals(0, goal.Action_Complete__c);
	    	System.assertEquals(0, goal.Cases_Complete__c);
    	}
    	
    	mgrGoals = [SELECT Id, Action_Count__c, Action_Complete__c, Cases_Complete__c FROM Goal__c WHERE Id IN :mgrGoals];
    	for(Goal__c goal : mgrGoals){
	    	//System.assertEquals(100, goal.Action_Count__c);
	    	System.assertEquals(0, goal.Action_Complete__c);
	    	System.assertEquals(0, goal.Cases_Complete__c);
    	}
    	
    	dirGoal = [SELECT Id, Action_Count__c, Action_Complete__c, Cases_Complete__c FROM Goal__c WHERE Id = :dirGoal.Id];
    	//System.assertEquals(1000, dirGoal.Action_Count__c);
    	System.assertEquals(0, dirGoal.Action_Complete__c);
    	System.assertEquals(0, dirGoal.Cases_Complete__c);
    	
    }*/
}