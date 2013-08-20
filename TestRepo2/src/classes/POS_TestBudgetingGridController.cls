@isTest
public class POS_TestBudgetingGridController {
	public static testmethod void test(){
		Test.startTest();
		
		User currUser = [select id from User where id = :Userinfo.getUserId()];
		System.runas(currUser){
			
			POS_TestDataUtil.initializeTestData();
			Order_Window__c orderWindow = POS_TestDataUtil.createOrderWindow();
			Brand__c brand 				= POS_TestDataUtil.createBrand();
			Program__c program 			= POS_TestDataUtil.createProgram(brand.id, orderWindow.id);
			User user 					= POS_TestDataUtil.createStdUser();
			Organizational_Unit__c orgUnit = new Organizational_Unit__c(Name = 'test ou', Label__c = 'Division', Type__c = 'Spirits');
			insert orgUnit;
			Account account = Test_Helper.testInsertAccount('acc name', orgUnit.id);
			Account_Member__c member	= new Account_Member__c(Account__c = account.id, User__c = user.id);
			insert member;
			Budget__c budget			= new Budget__c();
			AccountBrand__c ab = new AccountBrand__c(Account__c = account.id, Brand__c = brand.id);
			insert ab;
			
			POS_BudgetingGridController.SlickGridRow sgr1 = new POS_BudgetingGridController.SlickGridRow();
			sgr1.indent			= '0';
			sgr1.updated		= true;
			sgr1.Budget			= 2000;
			sgr1.Shopper		= user.UserName;
			sgr1.ShopperId		= user.Id;
			sgr1.Brand			= brand.Name;
			sgr1.BrandId		= brand.Id;
			sgr1.Id				= 'new_1234';
			sgr1.Program		= program.Name;
			sgr1.ProgramId		= program.Id;
			//sgr1.parentId		= program.Id;
			sgr1.DistributorId 	= account.Id;
			sgr1.GeographyId	= orgUnit.Id;
			sgr1.Channel		= 'On Premise';
			POS_BudgetingGridController.SlickGridRow sgr2 = new POS_BudgetingGridController.SlickGridRow();
			sgr2.indent			= '0';
			sgr2.updated		= true;
			sgr2.Budget			= 2000;
			sgr2.Shopper		= user.UserName;
			sgr2.ShopperId		= user.Id;
			sgr2.Brand			= brand.Name;
			sgr2.BrandId		= brand.Id;
			sgr2.Id				= 'new_1234';
			sgr2.Program		= program.Name;
			
			List<POS_BudgetingGridController.SlickGridRow> rows = new List<POS_BudgetingGridController.SlickGridRow>();
			rows.add(sgr1);
			rows.add(sgr2);
			
			PageReference currPage = new PageReference('/apex/POS_BudgetingGrid?owId='+orderWindow.Id+'&gridData=');
			Test.setCurrentPage(currPage);
			
			System.runAs(user){
				POS_BudgetingGridController controller = new POS_BudgetingGridController();
				Budget__c nbudget1 = sgr1.populateBudgetObjectRecord(budget);
				Budget__c nbudget2 = sgr2.populateBudgetObjectRecord(budget);
				List<Budget__c> budgetRecs = controller.getBudgetObjectRecords(rows);
				System.assertEquals(2, budgetRecs.size());
				List<Budget__c> deleted = controller.getBudgetObjectRecordsForDelete('');
				//controller.propogateRowData();
				//controller.saveGrid();
			}
		}
		
		Test.stopTest();
	}
}