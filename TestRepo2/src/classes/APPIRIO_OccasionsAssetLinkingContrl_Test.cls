/*
	Class : APPIRIO_OccasionsAssetLinkingContrl_Test 
	Description :  Test Class for a APPIRIO_OccasionsAssetLinkingController
	Developed by : Manmeet Manethiya
	CreatedDate : Dec 07, 2012
*/

@isTest(SeeAllData=false)
private class APPIRIO_OccasionsAssetLinkingContrl_Test {
		// initialising static variables
		public static Digital_Published_Asset__c digiTalPublishedAsset;
		public static Published_Occasion__c pubOccasion;
		
		//test method to test assests for system admin functionality
		static testMethod void OccasionsAssetLinkingController_DFT_Test() {
			//creating test data
			createTestData();
			Pagereference curntPage = Page.APPIRIO_OccasionsAssetLinking;
			curntPage.getParameters().put('aId', digiTalPublishedAsset.id);
			curntPage.getParameters().put('aName', digiTalPublishedAsset.id);
			curntPage.getParameters().put('isNavigatingFromDetail', 'false');
			Test.setCurrentPage(curntPage);
			ApexPages.currentPage().getParameters().put('cnt', '1');
			Test.startTest();
			//calling controller
			APPIRIO_OccasionsAssetLinkingController controller = new APPIRIO_OccasionsAssetLinkingController();
			//initialising controller varaibles
			controller.searchTerm = 'Test';
			controller.currentType = 'Test';
			controller.currentMonth = '2';
			controller.currentDay = '2';
			controller.currentLocale = 'EN-US';
			controller.commaSet(new Set<String>{'test1, test 2, test3'});
			controller.genericCounter(new Set<String>{'test1, test 2, test3'});
			controller.typeFilter = new Set<String>{'Test'};
			controller.monthFilter = new Set<String>{'2'};
			controller.dayFilter = new Set<String>{'2'};
			controller.localeFilter = new Set<String>{'EN-US'};
			//fetching occasions and other variables
			//controller.getOccasions();
			controller.getTypes();
			controller.getMonths();
			controller.getDays();
			controller.getLocales();
			controller.getSortOrderTypes();
			controller.getWrapperOccasions();
			controller.filterResults();
			controller.publishAll();
			controller.suppressedAll();
			controller.publishOccasion();
			boolean hasNext = controller.hasNext;
			Integer totalR = controller.totalRecords;
			Integer startRecord = controller.currentStartRecord;
			Integer endRecord = controller.currentEndRecord;
			boolean hasPrevious = controller.hasPrevious;
			Integer pgNumber = controller.pageNumber; 
			//calling page navigator functions for covering data
			controller.first();
			controller.last();
			controller.previous();
			controller.next();
			controller.cancel();
			controller.getUserAgent();
			controller.clearFilters();
			controller.refreshPanel();
			controller.splitString('[test1,test2]', new Set<String>{'test1', 'test2'}, new Set<String>(), 'true');
			//preparing list of page numbers
			list<APPIRIO_OccasionsAssetLinkingController.pageNumberWrapper> pageNumbers = controller.pageNumbers;
			if(pageNumbers != null && pageNumbers.size() > 0)
				pageNumbers[0].pageItems();
			Test.stopTest();
		}
		
		static testMethod void OccasionsAssetLinkingController_DESC_Test() {
			//creating test data
			createTestData();
			Pagereference curntPage = Page.APPIRIO_OccasionsAssetLinking;
			curntPage.getParameters().put('aId', digiTalPublishedAsset.id);
			curntPage.getParameters().put('aName', digiTalPublishedAsset.id);
			curntPage.getParameters().put('isNavigatingFromDetail', 'false');
			curntPage.getParameters().put('sortType', 'DESC');
			Test.setCurrentPage(curntPage);
			ApexPages.currentPage().getParameters().put('cnt', '1');
			Test.startTest();
				//calling controller
				APPIRIO_OccasionsAssetLinkingController controller = new APPIRIO_OccasionsAssetLinkingController();
				controller.getWrapperOccasions();
			Test.stopTest();
		}
		
		static testMethod void OccasionsAssetLinkingController_AVL_Test() {
			//creating test data
			createTestData();
			Pagereference curntPage = Page.APPIRIO_OccasionsAssetLinking;
			curntPage.getParameters().put('aId', digiTalPublishedAsset.id);
			curntPage.getParameters().put('aName', digiTalPublishedAsset.id);
			curntPage.getParameters().put('isNavigatingFromDetail', 'false');
			curntPage.getParameters().put('sortType', 'AVL');
			Test.setCurrentPage(curntPage);
			ApexPages.currentPage().getParameters().put('cnt', '1');
			Test.startTest();
				//calling controller
				APPIRIO_OccasionsAssetLinkingController controller = new APPIRIO_OccasionsAssetLinkingController();
				controller.getWrapperOccasions();
			Test.stopTest();
		}
		
		//method to create test data
		private static void createTestData(){
			//creating digital published asset
			digiTalPublishedAsset = new Digital_Published_Asset__c();
			digiTalPublishedAsset.Name = 'TestAsset';
			insert digiTalPublishedAsset;
			
			//creating occasion
			Occasion__c occasion = new Occasion__c();
			occasion.Name_Of_The_Occasion__c  = 'Test';
			occasion.Occasion_Type__c = 'Test';
			occasion.Start_Month__c = '2';
			occasion.Day_Of_The_Week__c = '2';
			occasion.locale__c = 'EN-US';
			insert occasion;
			
			//creating published occasion
			pubOccasion = new Published_Occasion__c();
			pubOccasion.Digital_Published_Asset__c = digiTalPublishedAsset.id;
			pubOccasion.Status__c = 'Published';
			pubOccasion.Occasion__c = occasion.id;
			insert pubOccasion;
		}
}