@isTest
private class ObjectiveTriggerActionsTest {

	static testMethod void testInsert() {
		
		Account account = Test_Helper.testInsertAccount('testAcct');
        
        Brand__c brand = new Brand__c();
        brand.Name = 'testBrand';
        brand.Innovation__c = true;
        brand.Brand_Type__c = 'Individual';
        insert brand;
        
        Bottle_Size__c bottleSize = new Bottle_Size__c();
        bottleSize.Name = '1000' ;
        insert bottleSize;
        
        BrandBottle_Size__c bbs = new BrandBottle_Size__c();
        bbs.Bottle_Size__c = bottleSize.Id;
        bbs.Brand__c = brand.Id;
        insert bbs;
		
		
		Objective__c objective = new Objective__c();
		//objective.Name = 'test123';
		objective.BrandBottle_Size__c = bbs.Id ;
		
		system.Test.startTest();
			insert objective ;
		system.Test.stopTest();		
		
	}
}