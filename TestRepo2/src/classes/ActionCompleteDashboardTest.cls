@isTest
private class ActionCompleteDashboardTest {
	/*
    static testMethod void testActionCompleteDashboardController() {
        ActionCompleteDashboardController cont = new ActionCompleteDashboardController();
          //Update by Akanksha(CM Offshore)
        Date startD = Date.today();
		Date endD = Date.today().addDays(7);
		Order_Window__c ow = POS_TestDataUtil.createOrderWindow();
        Brand__c  bd = POS_TestDataUtil.createBrand();
        Account account = Test_Helper.testInsertAccount('testAcct');
        Program__c o = new Program__c(Name = 'Test Program1', Order_Window__c=ow.id, Brand__c=bd.id);
        insert o;
		Calendar__c cal = Test_Helper.testCreateCalendar('test1','Integrated National Program','tesSegment','1','desc', startD, endD, true, true);
		insert cal;
		User testUser = Test_Helper.generateTestUser('A4L91', true, 'Diageo - Sales Manager');
		account.OwnerId = testUser.Id;
		update account;
		//State__c s = new State__c(Name = 'State ' + i, Name__c = 'State ' + i);
		
        Goal__c dirGoal = new Goal__c();
    	dirGoal.Minimum_of_Accounts__c = 1;
    	dirGoal.Goal_Level__c = 'Director';
    	dirGoal.Name = 'dirGoal';
    	//dirGoal.Program_Start_Date__c = startD; 
    	dirGoal.Due_Date__c = endD;
    	dirGoal.Goal_Type__c = 'Combined Premise - Control';
    	dirGoal.Action_Complete__c = 1;
    	dirGoal.Program__c = cal.id;
    	dirGoal.State__c = 'Alabama';
    	dirGoal.Due_Date__c =  Date.today().addDays(10);
    	dirGoal.Goal_For__c = testUser.id;
    	insert dirGoal;
    	system.debug('#######dirGoal'+dirGoal);
    	system.debug('#######cal'+cal);
    	
		Goal__c mgrGoal = new Goal__c();
    	mgrGoal.Minimum_of_Accounts__c = 1;
    	mgrGoal.Goal_Level__c = 'Manager';
    	mgrGoal.Parent_Goal__c = dirGoal.Id;
    	mgrGoal.Name = 'mgrGoal';
    	mgrGoal.Due_Date__c = endD;
    	mgrGoal.Goal_Type__c = 'Combined Premise - Control';
    	mgrGoal.Action_Complete__c = 1;
    	mgrGoal.Program__c = cal.id;
    	mgrGoal.State__c = 'Michigan';
    	dirGoal.Due_Date__c =  Date.today().addDays(10);
    	dirGoal.Goal_For__c = testUser.id;
    	insert mgrGoal;
    	system.debug('#######mgrGoal'+mgrGoal);
    	
		Goal__c repGoal = new Goal__c();
    	repGoal.Minimum_of_Accounts__c = 1;
    	repGoal.Goal_Level__c = 'Rep';
    	repGoal.Parent_Goal__c = mgrGoal.Id;
    	repGoal.Name = 'repGoal';
    	repGoal.Due_Date__c = endD;
    	repGoal.Goal_Type__c = 'Combined Premise - Control';
    	repGoal.Action_Complete__c = 1;
    	repGoal.Program__c = cal.id;
    	repGoal.State__c = 'Michigan';
    	dirGoal.Due_Date__c =  Date.today().addDays(10);
    	dirGoal.Goal_For__c = testUser.id;
    	insert repGoal;
    	system.debug('#######repGoal'+repGoal);
    	
        cont.mode = 'exec';
        cont.chart = 'state';
        
        cont.mode = 'exec';
        cont.chart = 'west';
        cont.init();
        
        cont.mode = 'exec';
        cont.chart = 'east';
        cont.init();
        
        cont.mode = 'exec';
        cont.chart = 'goalFor';
        cont.init();
        
        cont.mode = 'dir';
        cont.chart = 'state';
        cont.init();
        
        cont.mode = 'dir';
        cont.chart = 'west';
        cont.init();
        
        cont.mode = 'dir';
        cont.chart = 'east';
        cont.init();
        
        
        cont.mode = 'mgr';
        cont.chart = 'state';
        cont.init();
        
        cont.mode = 'mgr';
        cont.chart = 'prog';
        cont.init();
        
        
        cont.mode = 'rep';
        cont.chart = 'state';
        cont.init();
        
        cont.mode = 'rep';
        cont.chart = 'prog';
        cont.init();
        
        cont.nameChanged();
      	cont.typeChanged();
    	cont.forChanged();
        cont.chanChanged();
        cont.rtChanged();
    }
    */
}