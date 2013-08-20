@isTest
private class Test_Controller_TerritoryPerformance {
	
	
	static testMethod void testController()
	{
		Account account = Test_Helper.testInsertAccount('test_account');
		Objective__c objective = insertObjective('test objective');
		Action__c action = insertAction(objective.Id, account);
		
		system.test.startTest();
			Controller_TerritoryPerformance controller = new Controller_TerritoryPerformance(objective.Id);
			Controller_TerritoryPerformance controller2 = new Controller_TerritoryPerformance();
			
			Controller_TerritoryPerformance.ObjectiveData datum;
			datum  = new Controller_TerritoryPerformance.ObjectiveData('test', UserInfo.getUserId()) ;
			datum.closedCount = 2;
			datum.totalCount = 4;
			datum.getMainLabel();
			datum.getClosedPercentage();
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
	
	private static Action__c insertAction(Id objectiveId, Account account) {
		Action__c action = new Action__c();
		action.Objective__c = objectiveId;
		action.Account__c = account.Id;
		insert action;
		
		return action;
	}
	
	
}