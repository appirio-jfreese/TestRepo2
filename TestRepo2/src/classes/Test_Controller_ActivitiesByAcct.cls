@isTest
private class Test_Controller_ActivitiesByAcct {
	
	
	static testMethod void testController()
	{
		Account account = Test_Helper.testInsertAccount('test_account');
		Account account2 = Test_Helper.testInsertAccount('test_account2');
		
		List<Action__c> actionsToInsert = new List<Action__c>();
		
		Objective__c lastInsertedObjective;
		for(String str : new String[]{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'}) {
			lastInsertedObjective = insertObjective(str);
			actionsToInsert.add(createAction(lastInsertedObjective.Id, account));
		}
		
		actionsToInsert.add(createAction(lastInsertedObjective.Id, account2));
		
		insert actionsToInsert;
		
		system.test.startTest();
			Controller_ActivitiesByAcct controller = new Controller_ActivitiesByAcct();
			controller.getDynamicPageBlockTableContent();
		system.test.stopTest();
	}
	
	private static Objective__c insertObjective(String name)
	{
		Objective__c objective = new Objective__c();
		objective.Name = 'test' + name;
		objective.Due_Date__c = Date.today().addDays(10);
		insert objective ;
		
		return objective;
	}
	
	private static Action__c createAction(Id objectiveId, Account account) {
		Action__c action = new Action__c();
		action.Objective__c = objectiveId;
		action.Account__c = account.Id;
		return action;
	}

}