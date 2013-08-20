@isTest
private class ActionProductLinkActionsTest {
	
	static testMethod void testPopulateReportBrand() {
		Product__c prod = new Product__c();
		prod.Generic_Brand__c = 'generic brand unique';
		prod.Sub_Brand__c = 'sub brand unique';
		prod.Report_Brand__c = 'report brand unique';
		prod.Brand_Composite_Key__c = 'something';
		prod.Individual_Brand__c = 'ind brand unique';
        prod.Size__c = 'size uniqu';
		insert prod;
		
		Action__c parent = new Action__c();
        insert parent;
        
        Action_Product_Link__c link1 = new Action_Product_Link__c();
        link1.Action__c = parent.Id;
        link1.Generic_Brand__c = 'generic brand unique';
        link1.Sub_Brand__c = 'sub brand unique';
        
        Action_Product_Link__c link2 = new Action_Product_Link__c();
        link2.Action__c = parent.Id;
        link2.Generic_Brand__c = 'generic brand unique';
        link2.Sub_Brand__c = 'sub brand different';
        
        Action_Product_Link__c link3 = new Action_Product_Link__c();
        link3.Action__c = parent.Id;
        link3.Generic_Brand__c = 'generic brand unique';
        
        Test.startTest();
        
        insert link1;
        insert link2;
        insert link3;
        
        Test.stopTest();
        
        link1 = [SELECT Id, Report_Brand__c FROM Action_Product_Link__c WHERE Id = :link1.Id];
        System.assertEquals('report brand unique', link1.Report_Brand__c);
        
        link2 = [SELECT Id, Report_Brand__c FROM Action_Product_Link__c WHERE Id = :link2.Id];
        System.assertEquals('generic brand unique', link2.Report_Brand__c);
        
        link2.Sub_Brand__c = 'sub brand unique';
        update link2;
        link2 = [SELECT Id, Report_Brand__c FROM Action_Product_Link__c WHERE Id = :link2.Id];
        System.assertEquals('report brand unique', link2.Report_Brand__c);
        
        link3.Individual_Brand_Offline__c = 'ind brand unique';
        link3.Size_Offline__c = 'size uniqu';
        update link3;
        link3 = [SELECT Id, Report_Brand__c FROM Action_Product_Link__c WHERE Id = :link3.Id];
        System.assertEquals('report brand unique', link3.Report_Brand__c);
	}
	
	static testMethod void testUpdateOnlineFields() {
		List<Product__c> prods = new List<Product__c>();
		for(Integer i = 1; i <= 5; i++){
			Product__c testProd = new Product__c();
			testProd.Brand_Composite_Key__c = 'testme' + i;
			testProd.Product_Classification__c = 'testme' + i;
			testProd.Product_Group__c = 'testme' + i;
			testProd.Report_Brand__c = 'testme' + i;
			testProd.Generic_Brand__c = 'testme' + i;
			testProd.Sub_Brand__c = 'testme' + i;
			testProd.Individual_Brand__c = 'testme' + i;
			testProd.Size__c = 'testme' + i;
			prods.add(testProd);
		}
		insert prods;
		
		Action__c parent = new Action__c();
        insert parent;
        
        List<Action_Product_Link__c> links = new List<Action_Product_Link__c>();
        
        Action_Product_Link__c link1 = new Action_Product_Link__c();
        link1.Action__c = parent.Id;
        link1.Individual_Brand_Offline__c = 'testme1';
        link1.Size_Offline__c = 'testme1';
        links.add(link1);

        Action_Product_Link__c link2 = new Action_Product_Link__c();
        link2.Action__c = parent.Id;
        link2.Individual_Brand_Offline__c = 'testme2';
        links.add(link2);
        
        Action_Product_Link__c link3 = new Action_Product_Link__c();
        link3.Action__c = parent.Id;
        link3.Product_Classification__c = 'testme3';
        link3.Product_Group__c = 'testme3';
        link3.Report_Brand__c = 'testme3';
        link3.Generic_Brand__c = 'testme3';
        link3.Sub_Brand__c = 'testme3';
        link3.Individual_Brand__c = 'testme3';
        link3.Size__c = 'testme3';
        links.add(link3);
        
        Action_Product_Link__c link4 = new Action_Product_Link__c();
        link4.Action__c = parent.Id;
        link4.Product_Classification__c = 'testme4';
        link4.Product_Group__c = 'testme4';
        link4.Report_Brand__c = 'testme4';
        link4.Generic_Brand__c = 'testme4';
        link4.Sub_Brand__c = 'testme4';
        link4.Individual_Brand__c = 'testme4';
        links.add(link4);
        
        Test.startTest();
        
        insert links;
        
        Test.stopTest();
        
        assertVals(link1, 'testme1', true);
        assertVals(link2, 'testme2', false);
        assertVals(link3, 'testme3', true);
        assertVals(link4, 'testme4', false);
        
        Action_Product_Link__c link5 = new Action_Product_Link__c();
        link5.Action__c = parent.Id;
        link5.Product_Classification__c = 'testme5';
        link5.Product_Group__c = 'testme5';
        link4.Report_Brand__c = 'testme5';
        link5.Generic_Brand__c = 'testme5';
        link5.Sub_Brand__c = 'testme5';
        link5.Individual_Brand_Offline__c = 'something';
        link5.Size_Offline__c = 'something';
        Boolean hadError = false;
        try {
        	insert link5;
        } catch (Exception e){
        	hadError = true;
        }
        System.assert(true, hadError);
	}
	
	private static void assertVals(Action_Product_Link__c link, String val, Boolean sizeShouldMatch){
        link  = [SELECT Id, Product_Classification__c, Product_Group__c,
        				Report_Brand__c, Generic_Brand__c, Sub_Brand__c, Individual_Brand__c,
        				Size__c, Individual_Brand_Offline__c, Size_Offline__c
        		   FROM Action_Product_Link__c
        		  WHERE Id = :link.Id
        		];
        System.assertEquals(val, link.Product_Classification__c);
        System.assertEquals(val, link.Product_Group__c);
        System.assertEquals(val, link.Report_Brand__c);
        System.assertEquals(val, link.Generic_Brand__c);
        System.assertEquals(val, link.Sub_Brand__c);
        System.assertEquals(val, link.Individual_Brand__c);
        System.assertEquals(val, link.Individual_Brand_Offline__c);
        if(sizeShouldMatch){
	        System.assertEquals(val, link.Size__c);
	        System.assertEquals(val, link.Size_Offline__c);
        }
	}

    static testMethod void testDeduplicateLinks() {
        Action__c parent = new Action__c();
        insert parent;
        
        List<Action_Product_Link__c> links = new List<Action_Product_Link__c>();
        
        Action_Product_Link__c link1 = new Action_Product_Link__c();
        link1.Action__c = parent.Id;
        link1.Generic_Brand__c = 'gen brand unique';
        links.add(link1);
        
        Action_Product_Link__c link2 = new Action_Product_Link__c();
        link2.Action__c = parent.Id;
        link2.Generic_Brand__c = 'gen brand dupe';
        links.add(link2);
        
        Action_Product_Link__c link3 = new Action_Product_Link__c();
        link3.Action__c = parent.Id;
        link3.Generic_Brand__c = 'gen brand dupe';
        links.add(link3);
        
        Test.startTest();
        
        insert links;
        
        Test.stopTest();
        
        links = [SELECT Id FROM Action_Product_Link__c WHERE Id IN :links];
        System.assertEquals(2, links.size());
    }
    
    
    static testMethod void testDeduplicateLinks2() {
        Action__c parent = new Action__c();
        insert parent;
        
        Action_Product_Link__c link1 = new Action_Product_Link__c();
        link1.Action__c = parent.Id;
        link1.Generic_Brand__c = 'gen brand unique';
        insert link1;
        
        Action_Product_Link__c link2 = new Action_Product_Link__c();
        link2.Action__c = parent.Id;
        link2.Generic_Brand__c = 'gen brand dupe';
        insert link2;
        
        Action_Product_Link__c link3 = new Action_Product_Link__c();
        link3.Action__c = parent.Id;
        link3.Generic_Brand__c = 'gen brand dupe';
        
        Test.startTest();
        
        insert link3;
        
        Test.stopTest();
        
       	List<Action_Product_Link__c> links = [SELECT Id FROM Action_Product_Link__c WHERE Id = :link3.Id];
        System.assertEquals(0, links.size());
    }
}