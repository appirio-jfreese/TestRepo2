@isTest
private class GoalProductLinkActionsTest {
	
	static testMethod void testPopulateReportBrand() {
		Product__c prod = new Product__c();
		prod.Generic_Brand__c = 'generic brand unique';
		prod.Sub_Brand__c = 'sub brand unique';
		prod.Report_Brand__c = 'report brand unique';
		prod.Brand_Composite_Key__c = 'something';
		insert prod;
		
		Goal__c parent = new Goal__c();
        insert parent;
        
        Goal_Product_Link__c link1 = new Goal_Product_Link__c();
        link1.Goal__c = parent.Id;
        link1.Generic_Brand__c = 'generic brand unique';
        link1.Sub_Brand__c = 'sub brand unique';
        
        Goal_Product_Link__c link2 = new Goal_Product_Link__c();
        link2.Goal__c = parent.Id;
        link2.Generic_Brand__c = 'generic brand unique';
        link2.Sub_Brand__c = 'sub brand different';
        
        Test.startTest();
        
        insert link1;
        insert link2;
        
        Test.stopTest();
        
        link1 = [SELECT Id, Report_Brand__c FROM Goal_Product_Link__c WHERE Id = :link1.Id];
        System.assertEquals('report brand unique', link1.Report_Brand__c);
        
        link2 = [SELECT Id, Report_Brand__c FROM Goal_Product_Link__c WHERE Id = :link2.Id];
        System.assertEquals('generic brand unique', link2.Report_Brand__c);
        
        link2.Sub_Brand__c = 'sub brand unique';
        update link2;
        link2 = [SELECT Id, Report_Brand__c FROM Goal_Product_Link__c WHERE Id = :link2.Id];
        System.assertEquals('report brand unique', link2.Report_Brand__c);
	}

    static testMethod void testDeduplicateLinks() {
        Goal__c parent = new Goal__c();
        insert parent;
        
        List<Goal_Product_Link__c> links = new List<Goal_Product_Link__c>();
        
        Goal_Product_Link__c link1 = new Goal_Product_Link__c();
        link1.Goal__c = parent.Id;
        link1.Generic_Brand__c = 'gen brand unique';
        links.add(link1);
        
        Goal_Product_Link__c link2 = new Goal_Product_Link__c();
        link2.Goal__c = parent.Id;
        link2.Generic_Brand__c = 'gen brand dupe';
        links.add(link2);
        
        Goal_Product_Link__c link3 = new Goal_Product_Link__c();
        link3.Goal__c = parent.Id;
        link3.Generic_Brand__c = 'gen brand dupe';
        links.add(link3);
        
        Test.startTest();
        
        insert links;
        
        Test.stopTest();
        
        links = [SELECT Id FROM Goal_Product_Link__c WHERE Id IN :links];
        System.assertEquals(2, links.size());
    }
    
    
    static testMethod void testDeduplicateLinks2() {
        Goal__c parent = new Goal__c();
        insert parent;
        
        Goal_Product_Link__c link1 = new Goal_Product_Link__c();
        link1.Goal__c = parent.Id;
        link1.Generic_Brand__c = 'gen brand unique';
        insert link1;
        
        Goal_Product_Link__c link2 = new Goal_Product_Link__c();
        link2.Goal__c = parent.Id;
        link2.Generic_Brand__c = 'gen brand dupe';
        insert link2;
        
        Goal_Product_Link__c link3 = new Goal_Product_Link__c();
        link3.Goal__c = parent.Id;
        link3.Generic_Brand__c = 'gen brand dupe';
        
        Test.startTest();
        
        insert link3;
        
        Test.stopTest();
        
       	List<Goal_Product_Link__c> links = [SELECT Id FROM Goal_Product_Link__c WHERE Id = :link3.Id];
        System.assertEquals(0, links.size());
    }
}