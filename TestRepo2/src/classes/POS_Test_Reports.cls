@isTest
private class POS_Test_Reports {
	public static testmethod void testReportsFilters(){
		Test.startTest();
		
		//UserRole role = [select id from UserRole where name='Diageo NA' limit 1];
		User currUser = [select id from User where id = :Userinfo.getUserId()];
		System.runas(currUser){
			
			Organizational_Unit__c orgUnit = new Organizational_Unit__c(Name = 'test ou', Label__c = 'Division', Type__c = 'Spirits');
			insert orgUnit;
			
			Account account = Test_Helper.testInsertAccount('acc name', orgUnit.id);
			
			Contact contact = Test_Helper.testInsertContact('first', 'last', account.id);
			User user = Test_Helper.testInsertDiageoPortalUser(contact.id);
			
			Order_Window__c orderWindow = new Order_Window__c(Name = 'test order window', Type__c = 'Monthly', Fiscal_Year__c = '2013', Order_Start_Date__c = Date.today(), Order_Close_Date__c = Date.today().addMonths(1), Order_Delivery_Date__c = Date.today().addMonths(2), Status__c = 'Open');
			insert orderWindow;
			Order_Window_Customer__c orderWindowCustomer = new Order_Window_Customer__c(Customer__c = user.id, Order_Window__c = orderWindow.id);
			insert orderWindowCustomer;
			
			Brand__c brand = Test_Helper.testInsertBrand('test brand');
			Test_Helper.testInsertAccountBrand(account.ID, brand.ID);
			
			PageReference currPage = new PageReference('/apex/POS_Reports');
			Test.setCurrentPage(currPage);
			
			System.runAs(user){
				POS_ReportsController cont = new POS_ReportsController();
				
				cont.classification = 'Spirits';
				cont.fillOrganizationalUnitOptions();
				cont.orgUnitsString = orgUnit.id;
				cont.fillDistributorOptions();
				
				system.assertEquals(1, cont.orderWindowOptions.size());
				system.assertEquals(2, cont.classificationOptions.size());
				//system.assertEquals(1, cont.brandOptions.size());
				system.assertEquals(new Set<Id>{account.id}, POS_ReportsController.aids);
				system.assertEquals(1, cont.organizationalUnitOptions.size());
				system.assertEquals(1, cont.distributorOptions.size());
				
				cont.resetClassification();
				cont.reset();
				cont.resetOrganizationalUnitOptions();
				
			}
		}
		
		Test.stopTest();
	}
	
	public static testmethod void testRenderers(){
		Test.startTest();
		
		User currUser = [select id from User where id = :Userinfo.getUserId()];
		System.runas(currUser){
			
			Organizational_Unit__c orgUnit = new Organizational_Unit__c(Name = 'test ou', Label__c = 'Division', Type__c = 'Spirits');
			insert orgUnit;
			
			Account account = Test_Helper.testInsertAccount('acc name', orgUnit.id);
			
			Order_Window__c orderWindow = new Order_Window__c(Name = 'test order window', Type__c = 'Monthly', Fiscal_Year__c = '2013', Order_Start_Date__c = Date.today(), Order_Close_Date__c = Date.today().addMonths(1), Order_Delivery_Date__c = Date.today().addMonths(2), Status__c = 'Open');
			insert orderWindow;
			
			Brand__c brand = Test_Helper.testInsertBrand('test brand');
			
			PageReference currPage = new PageReference('/apex/POS_ReportRendererCSV?ow='+orderWindow.id+'&cl=Spirits&br='+brand.id+'&ou='+orgUnit.id+'&ds='+account.id);
			Test.setCurrentPage(currPage);
			
			POS_ReportRendererController cont = new POS_ReportRendererController();
		}
		
		Test.stopTest();
	}
}