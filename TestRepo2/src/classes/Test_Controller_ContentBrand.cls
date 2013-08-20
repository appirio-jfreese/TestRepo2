@isTest
private class Test_Controller_ContentBrand {
	 
	 static testMethod void testController() {	 	
	 		 	       		
		Content_Description__c contentDesc  = Test_Helper.testInsertContentDescription(); 
		Content_Description__c contentDesc2 = Test_Helper.testInsertContentDescription();		
		
		
		
		Brand__c brandFirst 	 = Test_Helper.testInsertBrand('smirnoff') ;    		
		Brand__c brandSecond	 = Test_Helper.testInsertBrand('smirnoff ice'); 	
		Brand__c brandThird 	 = Test_Helper.testInsertBrand('Johnnie Walker Black');
		Brand__c brandFourth  	 = Test_Helper.testInsertBrand('Johnnie Walker Blue');
		
		
		ContentBrand__c contentBra = Test_Helper.testInsertContentBrand(contentDesc.Id, brandFirst.Id);	
		
		
		Brand__c brandFive  		= Test_Helper.testInsertBrand('Johnnie Walker Gold');
		ContentBrand__c contentBra2 = Test_Helper.testInsertContentBrand(contentDesc2.Id, brandFive.Id);	
						
		
		ApexPages.StandardController sc = new ApexPages.standardController(contentBra);			
		ControllerContentBrand controller =  new ControllerContentBrand(sc);		
		
		controller.reloadLists();
		
		System.assertequals(1, (controller.setCtrl).getResultSize());		
		
		
		ContentBrand__c contentBraThird = Test_Helper.testInsertContentBrand(controller.ContentDescriptionId, brandThird.Id);
		ContentBrand__c contentBraFourth = Test_Helper.testInsertContentBrand(controller.ContentDescriptionId, brandFourth.Id);	
				
		controller.reloadLists();
		System.assertequals(3, (controller.setCtrl).getResultSize());
				
		controller.avaliableS = 'Johnnie';			
		controller.reloadListsAfterSearch();	
		String filter = '%'+controller.avaliableS+'%';
		
		ApexPages.StandardSetController testSetCtrlB = new ApexPages.StandardSetController(Database.getQueryLocator([
	            Select Id, Name FROM Brand__c WHERE Name LIKE :filter 
	                ORDER BY Name
	            ]
	        ));
	      	
		System.assertequals(testSetCtrlB.getResultSize(), (controller.setCtrlB).getResultSize()+2);
		
		
		controller.avaliableS = '';			
		controller.reloadLists();
		
		ApexPages.StandardSetController testSetCtrlA = new ApexPages.StandardSetController(Database.getQueryLocator([
	            Select Id, Name FROM Brand__c 
	                ORDER BY Name
	            ]
	        ));
				
		System.assertequals(testSetCtrlA.getResultSize(), (controller.setCtrlB).getResultSize()+3);
		
		controller.avaliableS = 'Johnnie';
		controller.reloadListsAfterSearch();		
		controller.brandList[0].selected = true;
		controller.addRelations();
		System.assertequals(4, (controller.setCtrl).getResultSize());
		controller.contentBrandList[0].selected = true;
		controller.deleteRelations();
		System.assertequals(3, (controller.setCtrl).getResultSize());
		
		controller.nextB();
		controller.previousB();
		controller.lastB();
		controller.firstB();
		Integer a = controller.totalPagesB;	
		Integer b = controller.pageNumberB;
		Boolean c = controller.hasPreviousB;
		Boolean d = controller.hasNextB;
		controller.next(); 
		controller.previous();
		controller.last();
		controller.first();
		Integer e = controller.totalPages;
		Integer f = controller.pageNumber;
		Boolean g = controller.hasPrevious;
		Boolean h = controller.hasNext;
		Boolean i = controller.contentDescriptionEditable;
	
		
	 }
}