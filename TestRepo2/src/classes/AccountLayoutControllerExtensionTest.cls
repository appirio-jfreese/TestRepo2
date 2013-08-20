@isTest
private class AccountLayoutControllerExtensionTest {
	 
	 
	 
	 static testMethod void testControllerExtension() {
	 	Account account = Test_Helper.testInsertAccount('test_account');
	 	Brand__c brand = Test_Helper.testInsertBrand('testBrand');
	 	
	 	//2a
	 	Sales_Volume__c salesVol1 = new Sales_Volume__c();
	 	salesVol1.Account__c = account.Id;
	 	salesVol1.Generic_Brand__c = 'gen brand';
	 	salesVol1.Division__c = 'Spirits';
	 	salesVol1.Month_End__c = Date.today();
	 	salesVol1.Batf_Volume_12_Mo_TY_vs_LY_Chg__c = .5;
	 	insert salesVol1;
	 	
	 	//3a
	 	Sales_Volume__c salesVol2 = new Sales_Volume__c();
	 	salesVol2.Account__c = account.Id;
	 	salesVol2.Brcat_Fin_Plan_Brand__c = 'test2';
	 	salesVol2.Division__c = 'Spirits';
	 	salesVol2.Batf_Volume_12_Mo_TY_vs_LY_Chg__c = .5;
	 	salesVol2.Individual_Brand__c = 'tester';
	 	salesVol2.Generic_Brand__c = 'tester';
	 	salesVol2.Brcat_Fin_Plan_Brand__c = 'tester';
	 	insert salesVol2;
	 	
	 	Sales_Volume__c salesVol2b = new Sales_Volume__c();
	 	salesVol2b.Account__c = account.Id;
	 	salesVol2b.Brcat_Fin_Plan_Brand__c = 'test2';
	 	salesVol2b.Division__c = 'Spirits';
	 	salesVol2b.Batf_Volume_12_Mo_TY_vs_LY_Chg__c = .5;
	 	salesVol2b.Individual_Brand__c = 'tester';
	 	salesVol2b.Generic_Brand__c = 'tester';
	 	salesVol2b.Brcat_Fin_Plan_Brand__c = 'tester';
	 	//insert later
	 	
	 	Sales_Volume__c salesVol2c = new Sales_Volume__c();
	 	salesVol2c.Account__c = account.Id;
	 	salesVol2c.Brcat_Fin_Plan_Brand__c = 'test2';
	 	salesVol2c.Division__c = 'Spirits';
	 	salesVol2c.Batf_Volume_12_Mo_TY_vs_LY_Chg__c = .5;
	 	salesVol2c.Individual_Brand__c = 'tester';
	 	salesVol2c.Generic_Brand__c = 'tester';
	 	salesVol2c.Brcat_Fin_Plan_Brand__c = 'tester';
	 	//insert later;
	 	
	 	Sales_Volume__c salesVol2a = new Sales_Volume__c();
	 	salesVol2a.Account__c = account.Id;
	 	salesVol2a.Brcat_Fin_Plan_Brand__c = 'test2';
	 	salesVol2a.Division__c = 'Spirits';
	 	salesVol2a.Batf_Volume_12_Mo_TY_vs_LY_Chg__c = .5;
	 	salesVol2a.Individual_Brand__c = 'tester';
	 	salesVol2a.Generic_Brand__c = 'tester';
	 	salesVol2a.Brcat_Fin_Plan_Brand__c = 'tester';
		//insert later
		
		Sales_Volume__c salesVol2d = new Sales_Volume__c();
	 	salesVol2d.Account__c = account.Id;
	 	salesVol2d.Brcat_Fin_Plan_Brand__c = 'test2';
	 	salesVol2d.Division__c = 'Spirits';
	 	salesVol2d.Batf_Volume_12_Mo_TY_vs_LY_Chg__c = .5;
	 	salesVol2d.Individual_Brand__c = 'tester';
	 	salesVol2d.Generic_Brand__c = 'tester';
	 	salesVol2d.Brcat_Fin_Plan_Brand__c = 'tester';
		//insert later	 	
	 	
	 	Sales_Volume__c salesVol3 = new Sales_Volume__c();
	 	salesVol3.Account__c = account.Id;
	 	salesVol3.State_Batf_Volume_12_Mo_TY__c = .9;
	 	salesVol3.Batf_Volume_12_Mo_TY_vs_LY_Chg__c = 50;
	 	salesVol3.State_12M_Chg_vs_YA__c = 40;
	 	salesVol3.Division__c = 'Spirits';
	 	salesVol3.Individual_Brand__c = 'tester';
	 	salesVol3.State_Distro__c = .8;
	 	salesVol3.Size__c = '1.5 L';
	 	insert salesVol3;
	 	
	 	Sales_Volume__c salesVol4 = new Sales_Volume__c();
	 	salesVol4.Account__c = account.Id;
	 	salesVol4.State_Batf_Volume_12_Mo_TY__c = .6;
	 	salesVol4.Batf_Volume_12_Mo_TY_vs_LY_Chg__c = 55;
	 	salesVol4.State_12M_Chg_vs_YA__c = 20;
	 	salesVol4.Division__c = 'Spirits';
	 	salesVol4.Individual_Brand__c = 'tester';
	 	salesVol4.State_Distro__c = .83;
	 	salesVol4.Size__c = '1.5 L';
	
	 	
	 	system.Test.StartTest();
	 		
	 		ApexPages.StandardController sc = new ApexPages.standardController(account);
	 		
	 		AccountLayoutControllerExtension ext = new AccountLayoutControllerExtension(sc);
	 		ext.getWineSpiritsOptions();
	 		
	 		insert salesVol4;
	 		insert salesVol2a;
	 		insert salesVol2d;
	 		insert salesVol2b;
	 		insert salesVol2c;
	 		AccountLayoutControllerExtension ext2 = new AccountLayoutControllerExtension(sc);
	 		
	 		AccountLayoutControllerExtension.DataFor3a datum1;
	 		AccountLayoutControllerExtension.DataFor3a datum2;
	 		datum1 = new AccountLayoutControllerExtension.DataFor3a(salesVol3);
	 		datum2 = new AccountLayoutControllerExtension.DataFor3a(salesVol4);
			datum1.compareTo(datum2);
			datum2.compareTo(datum1);
			//
			ext2.executeChartBrandChange();
			ext2.executeChartBrandChange2();
			ext2.executeChartBrandChange3();
	 		
	 	system.Test.stopTest();
	 }
	 
	 
	 static testMethod void testControllerExtension2() {
	 	
	 	
	 }
	 
	 

}