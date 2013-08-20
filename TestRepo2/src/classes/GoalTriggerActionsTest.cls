@isTest
private class GoalTriggerActionsTest {

   static testMethod void testCreateBlankGBRI() {
        Goal__c goal = new Goal__c();
        
        Test.startTest();
        
        insert goal;
        
        Test.stopTest();
        
        List<Goal_Brand_Report_Item__c> gbris = [SELECT Id, Completed_Actions__c, Level__c, Label__c FROM Goal_Brand_Report_Item__c WHERE Goal__c = :goal.Id];
        System.assertEquals(8, gbris.size());
        System.assertEquals(0, gbris[0].Completed_Actions__c);
        System.assertEquals(0, gbris[1].Completed_Actions__c);
        System.assertEquals(0, gbris[2].Completed_Actions__c);
        System.assertEquals(0, gbris[3].Completed_Actions__c);
        System.assertEquals(0, gbris[4].Completed_Actions__c);
        System.assertEquals(0, gbris[5].Completed_Actions__c);
        System.assertEquals(0, gbris[6].Completed_Actions__c);
        System.assertEquals(0, gbris[7].Completed_Actions__c);
        System.assertEquals('(Undefined)', gbris[0].Label__c);
        System.assertEquals('(Undefined)', gbris[1].Label__c);
        System.assertEquals('(Undefined)', gbris[2].Label__c);
        System.assertEquals('(Undefined)', gbris[3].Label__c);
        System.assertEquals('(Undefined)', gbris[4].Label__c);
        System.assertEquals('(Undefined)', gbris[5].Label__c);
        System.assertEquals('(Undefined)', gbris[6].Label__c);
        System.assertEquals('(Undefined)', gbris[7].Label__c);
        System.assertEquals('Product Classification', 	gbris[0].Level__c);
        System.assertEquals('Product Group', 			gbris[1].Level__c);
        System.assertEquals('Generic Brand', 			gbris[2].Level__c);
        System.assertEquals('Sub Brand', 				gbris[3].Level__c);
        System.assertEquals('Individual Brand', 		gbris[4].Level__c);
        System.assertEquals('Size', 					gbris[5].Level__c);
        System.assertEquals('Report Brand', 			gbris[6].Level__c);
        System.assertEquals('Ind. Brand / Size', 		gbris[7].Level__c);
    }
    
    static testMethod void testCheckToDeleteBlankGBRI(){
    	Goal__c goal = new Goal__c();
    	insert goal;
    	
    	Goal_Product_Link__c gpl = new Goal_Product_Link__c();
    	gpl.Goal__c = goal.Id;
    	gpl.Product_Classification__c = 'Test Product Classification';
    	gpl.Product_Group__c = 'Test Product Group';
    	gpl.Generic_Brand__c = 'Test Generic Brand';
    	gpl.Sub_Brand__c = 'Test Sub Brand';
    	gpl.Individual_Brand__c = 'Test Individual Brand';
    	gpl.Size__c = 'Test Size';
    	gpl.Report_Brand__c = 'Test Report Brand';
    	
    	Test.startTest();
    	
    	insert gpl;
    	
    	Test.stopTest();
    	
        List<Goal_Brand_Report_Item__c> gbris = [SELECT Id, Completed_Actions__c, Level__c, Label__c FROM Goal_Brand_Report_Item__c WHERE Goal__c = :goal.Id];
        System.assertEquals(8, gbris.size());
        System.assertEquals(0, gbris[0].Completed_Actions__c);
        System.assertEquals(0, gbris[1].Completed_Actions__c);
        System.assertEquals(0, gbris[2].Completed_Actions__c);
        System.assertEquals(0, gbris[3].Completed_Actions__c);
        System.assertEquals(0, gbris[4].Completed_Actions__c);
        System.assertEquals(0, gbris[5].Completed_Actions__c);
        System.assertEquals(0, gbris[6].Completed_Actions__c);
        System.assertEquals(0, gbris[7].Completed_Actions__c);
        Integer foundCount = 0;
        for(Goal_Brand_Report_Item__c gbri : gbris){
        	if(gbri.Level__c == 'Product Classification' && gbri.Label__c == 'Test Product Classification'){
        		foundCount++;
        	}
        	if(gbri.Level__c == 'Product Group' && gbri.Label__c == 'Test Product Group'){
        		foundCount++;
        	}
        	if(gbri.Level__c == 'Generic Brand' && gbri.Label__c == 'Test Generic Brand'){
        		foundCount++;
        	}
        	if(gbri.Level__c == 'Sub Brand' && gbri.Label__c == 'Test Sub Brand'){
        		foundCount++;
        	}
        	if(gbri.Level__c == 'Individual Brand' && gbri.Label__c == 'Test Individual Brand'){
        		foundCount++;
        	}
        	if(gbri.Level__c == 'Size' && gbri.Label__c == 'Test Size'){
        		foundCount++;
        	}
        	if(gbri.Level__c == 'Report Brand' && gbri.Label__c == 'Test Report Brand'){
        		foundCount++;
        	}
        	if(gbri.Level__c == 'Ind. Brand / Size' && gbri.Label__c == 'Test Individual Brand, Test Size'){
        		foundCount++;
        	}
        }
        System.assertEquals(8, foundCount);
        
        delete gpl;
        delete gbris;
        
        gbris = [SELECT Id, Completed_Actions__c, Level__c, Label__c FROM Goal_Brand_Report_Item__c WHERE Goal__c = :goal.Id];
        System.assertEquals(8, gbris.size());
        System.assertEquals(0, gbris[0].Completed_Actions__c);
        System.assertEquals(0, gbris[1].Completed_Actions__c);
        System.assertEquals(0, gbris[2].Completed_Actions__c);
        System.assertEquals(0, gbris[3].Completed_Actions__c);
        System.assertEquals(0, gbris[4].Completed_Actions__c);
        System.assertEquals(0, gbris[5].Completed_Actions__c);
        System.assertEquals(0, gbris[6].Completed_Actions__c);
        System.assertEquals(0, gbris[7].Completed_Actions__c);
        System.assertEquals('(Undefined)', gbris[0].Label__c);
        System.assertEquals('(Undefined)', gbris[1].Label__c);
        System.assertEquals('(Undefined)', gbris[2].Label__c);
        System.assertEquals('(Undefined)', gbris[3].Label__c);
        System.assertEquals('(Undefined)', gbris[4].Label__c);
        System.assertEquals('(Undefined)', gbris[5].Label__c);
        System.assertEquals('(Undefined)', gbris[6].Label__c);
        System.assertEquals('(Undefined)', gbris[7].Label__c);
        System.assertEquals('Product Classification', 	gbris[0].Level__c);
        System.assertEquals('Product Group', 			gbris[1].Level__c);
        System.assertEquals('Generic Brand', 			gbris[2].Level__c);
        System.assertEquals('Sub Brand', 				gbris[3].Level__c);
        System.assertEquals('Individual Brand', 		gbris[4].Level__c);
        System.assertEquals('Size', 					gbris[5].Level__c);
        System.assertEquals('Report Brand', 			gbris[6].Level__c);
        System.assertEquals('Ind. Brand / Size', 		gbris[7].Level__c);
    }
}