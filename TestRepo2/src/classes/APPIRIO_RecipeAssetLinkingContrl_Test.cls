/********************************************************************************************************************
Name        : APPIRIO_RecipeAssetLinkingContrl_Test
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 7th Dec, 2012
Purpose     : Test Class for a APPIRIO_RecipeAssetLinkingController
********************************************************************************************************************/
@isTest(SeeAllData=false)
private class APPIRIO_RecipeAssetLinkingContrl_Test {
	
	//variable declaration
	static Attribute__c attr;
	static Attribute__c attr1;
	static Attribute__c attr2;
	static Recipe__c publishedRecipe;
	static Recipe__c suppressedRecipe;
	static Recipe__c readyToPublished;
	static Published_Recipe__c junAssetRecipe_Published;
	static Published_Recipe__c junAssetRecipe_Suppressed;
	static Digital_Published_Asset__c digitalPublishedAsset;
	
	//Initialization function for create test data
	private static void initialization() {
		
		//Creating a bunch of Attribute Records
		attr = TestUtil.createAttribute('Color','TestBlue',null);
		attr1 = TestUtil.createAttribute('Flavor','TestStrawberry',null);
		attr2 = TestUtil.createAttribute('Drink Type','TestCocktails',null);
		
		//Set up the Asset record.
		digitalPublishedAsset = APPIRIO_HelperTestUtility.createDigitalPublishedAsset('Test Digital Published Asset 1');
		insert digitalPublishedAsset;
		
		//Set up the Recipe records.
		publishedRecipe = APPIRIO_HelperTestUtility.createRecipe('Published Recipe', 'Approved', 'EN-US');
		insert publishedRecipe;
		suppressedRecipe = APPIRIO_HelperTestUtility.createRecipe('Suppressed Recipe', 'Approved', 'EN-US');
		insert suppressedRecipe;
		readyToPublished = APPIRIO_HelperTestUtility.createRecipe('Ready To Publish Recipe', 'Approved', 'EN-US');
		insert readyToPublished;
		
		//Set up the Published Recipe records.
		junAssetRecipe_Published = APPIRIO_HelperTestUtility.createPublishedRecipe(digitalPublishedAsset.Id, publishedRecipe.Id, 'Published');
		insert junAssetRecipe_Published;
		junAssetRecipe_Suppressed = APPIRIO_HelperTestUtility.createPublishedRecipe(digitalPublishedAsset.Id, suppressedRecipe.Id, 'Suppressed');
		insert junAssetRecipe_Suppressed;
	}
	
	//Test Method
    static testMethod void APPIRIO_RecipeAssetLinkingContrl_DFT_Test() {
    	initialization();
		
		Pagereference curntPage = Page.APPIRIO_RecipeAssetLinking;
		Test.setCurrentPage(curntPage);
		curntPage.getParameters().put('aId', digitalPublishedAsset.Id);
		curntPage.getParameters().put('aName', digitalPublishedAsset.Name);
		curntPage.getParameters().put('isNavigatingFromDetail', 'false');
		ApexPages.currentPage().getParameters().put('cnt', '1');
		curntPage.getParameters().put('sortType', 'DFT');
		
		Test.startTest();
			APPIRIO_RecipeAssetLinkingController controller = new APPIRIO_RecipeAssetLinkingController();
			controller.PAGE_SIZE = 1000;
			
			//Accessing properties
			boolean hasNext = controller.hasNext;
			boolean hasPrevious = controller.hasPrevious;
			Integer pgNumber = controller.pageNumber; 
			Integer totalR = controller.totalRecords;
			Integer startRecord = controller.currentStartRecord;
			Integer endRecord = controller.currentEndRecord;
			Integer colorCounter = controller.colorCounter;
			Integer brandCounter = controller.brandCounter;
			Integer flavorCounter = controller.flavorCounter;
			Integer statusCounter = controller.statusCounter;
			Integer numberCounter = controller.numberCounter;
			Integer localeCounter = controller.localeCounter;
			Integer typeCounter = controller.typeCounter;
			String statusLast = controller.statusLast; 
			String numberLast = controller.numberLast;
			String localeLast = controller.localeLast;
			controller.getBrands();
			controller.getCurrentRole();
			controller.getCurrentUser();
			controller.getIngredientNumbers();
			controller.getIsApprover();
			controller.getIsEditor();
			controller.getIsReviewer();
			controller.getIsSuperAdmin();
			controller.getLocales();
			controller.getRecipeBrands();
			controller.getRecipeColors();
			controller.getRecipeFlavors();
			//controller.getRecipes();
			controller.getSortOrderTypes();
			controller.getStatus();
			controller.getTypes();
			controller.getUserAgent();
			controller.getUserById(UserInfo.getUserId());
			
			//returns a list of wrapper objects for the sObjects in the current page set
			List<recipeWrapper> wrapperRecipes = controller.getWrapperRecipes();
			
			//Verify that the initial results are as expected.
			system.assert(wrapperRecipes.size() >= 3);
			
			/*Case I: Click on "Ready To Publich" button */
			//Click on "Ready To Publich" button of recipe which is nither “Published” or nor “Suppressed” recipe.
			controller.selectedRecipeId = readyToPublished.Id;
			controller.publishRecipe();
			
			//Verify that the results are as expected.
			Published_Recipe__c expectedResult = new Published_Recipe__c();
			for(Published_Recipe__c pr :[Select Status__c From Published_Recipe__c 
											Where Digital_Published_Asset__c =:digitalPublishedAsset.Id
											And Recipe__c =:readyToPublished.Id]) {
				expectedResult = pr;	
			}
			//Verify that the "Ready To Publich" recipe has become "Published" recipe?
			system.assertEquals(expectedResult.Status__c, 'Published');
			
			/*Case II: Click on "Suppressed" button */
			//Click on "Suppressed" button of recipe which is “Suppressed” recipe.
			controller.getWrapperRecipes();
			controller.selectedRecipeId = suppressedRecipe.Id;
			controller.publishRecipe();
			
			//Verify that the results are as expected.
			expectedResult = new Published_Recipe__c();
			for(Published_Recipe__c pr :[Select Status__c From Published_Recipe__c 
											Where Digital_Published_Asset__c =:digitalPublishedAsset.Id
											And Recipe__c =:suppressedRecipe.Id]) {
				expectedResult = pr;	
			}
			//Verify that the "Suppressed" recipe has become "Published" recipe?
			system.assertEquals(expectedResult.Status__c, 'Published');
			
			
			/*Case III: Click on "Publish All" button */
			//Click on "Publish All" button.
			controller.getWrapperRecipes();
			controller.publishAll();
			
			//Verify that the results are as expected.
			for(Published_Recipe__c pr :[Select Status__c, Recipe__r.Recipe_Title__c From Published_Recipe__c 
											Where Digital_Published_Asset__c =:digitalPublishedAsset.Id]) {
												
				//Verify that the "Suppressed or Ready To Publich" recipe has become "Published" recipe?
				system.assertEquals(pr.Status__c, 'Published');
			}
			
			/*Case IV: Click on "Suppressed All" button */
			//Click on "Suppressed All" button.
			controller.getWrapperRecipes();
			controller.suppressedAll();
			
			//Verify that the results are as expected.
			for(Published_Recipe__c pr :[Select Status__c,Recipe__r.Recipe_Title__c From Published_Recipe__c 
											Where Digital_Published_Asset__c =:digitalPublishedAsset.Id]) {
				
				system.debug('=========Suppressed==========Status__c: '+pr.Status__c);
				system.debug('=========Suppressed==========Recipe: '+pr.Recipe__r.Recipe_Title__c);
				//Verify that the "Published" recipe has become "Suppressed" recipe?
				system.assertEquals(pr.Status__c, 'Suppressed');
			}
			
			controller.getWrapperRecipes();
			controller.currentStatus = null;
			controller.getWrapperRecipes();
			controller.currentStatus = 'Suppressed';
			controller.getWrapperRecipes();
			
			controller.currentLocale = 'EN-US';
			controller.searchTerm = 'Test';
			controller.currentType = 'Test';
			controller.genericCounter(new Set<String>{'test1, test 2, test3'});
			controller.typeFilter = new Set<String>{'Test'};
			controller.localeFilter = new Set<String>{'EN-US'};
			controller.currentColor = 'Test Color'; 
			controller.currentFlavor = 'Rose';
			controller.first();
			controller.last();
			controller.previous();
			controller.next();
			controller.cancel();
			controller.refreshPanel();
			
			String currentIngredientNumber = controller.currentIngredientNumber = '1';
			String currentIngredientNumber1 = controller.currentIngredientNumber = '4+';
			//Clears all the Selected or applied Filter Criteria.
    		controller.clearFilters();
    		
    		//Verify that the results are as expected.
			system.assert(wrapperRecipes.size() >= 3);
			
			controller.splitString('[test1,test2]', new Set<String>{'test1', 'test2'}, new Set<String>(), 'true');
			list<APPIRIO_RecipeAssetLinkingController.pageNumberWrapper> pageNumbers = controller.pageNumbers;
			if(pageNumbers != null && pageNumbers.size() > 0)
				pageNumbers[0].pageItems();
			
			
		Test.stopTest();
    }
    
    //Test Method
    static testMethod void APPIRIO_RecipeAssetLinkingContrl_ASC_Test() {
    	initialization();
		
		Pagereference curntPage = Page.APPIRIO_RecipeAssetLinking;
		Test.setCurrentPage(curntPage);
		curntPage.getParameters().put('aId', digitalPublishedAsset.Id);
		curntPage.getParameters().put('aName', digitalPublishedAsset.Name);
		curntPage.getParameters().put('isNavigatingFromDetail', 'false');
		ApexPages.currentPage().getParameters().put('cnt', '1');
		curntPage.getParameters().put('sortType', 'ASC');
		
		Test.startTest();
			APPIRIO_RecipeAssetLinkingController controller = new APPIRIO_RecipeAssetLinkingController();
			//returns a list of wrapper objects for the sObjects in the current page set
			List<recipeWrapper> wrapperRecipes = controller.getWrapperRecipes();
		Test.stopTest();
    }
    
    //Test Method
    static testMethod void APPIRIO_RecipeAssetLinkingContrl_DESC_Test() {
    	initialization();
		
		Pagereference curntPage = Page.APPIRIO_RecipeAssetLinking;
		Test.setCurrentPage(curntPage);
		curntPage.getParameters().put('aId', digitalPublishedAsset.Id);
		curntPage.getParameters().put('aName', digitalPublishedAsset.Name);
		curntPage.getParameters().put('isNavigatingFromDetail', 'false');
		ApexPages.currentPage().getParameters().put('cnt', '1');
		curntPage.getParameters().put('sortType', 'DESC');
		
		Test.startTest();
			APPIRIO_RecipeAssetLinkingController controller = new APPIRIO_RecipeAssetLinkingController();
			//returns a list of wrapper objects for the sObjects in the current page set
			List<recipeWrapper> wrapperRecipes = controller.getWrapperRecipes();
		Test.stopTest();
    }
    
    //Test Method
    static testMethod void APPIRIO_RecipeAssetLinkingContrl_RPF_Test() {
    	initialization();
		
		Pagereference curntPage = Page.APPIRIO_RecipeAssetLinking;
		Test.setCurrentPage(curntPage);
		curntPage.getParameters().put('aId', digitalPublishedAsset.Id);
		curntPage.getParameters().put('aName', digitalPublishedAsset.Name);
		curntPage.getParameters().put('isNavigatingFromDetail', 'false');
		ApexPages.currentPage().getParameters().put('cnt', '1');
		curntPage.getParameters().put('sortType', 'RPF');
		
		Test.startTest();
			APPIRIO_RecipeAssetLinkingController controller = new APPIRIO_RecipeAssetLinkingController();
			//returns a list of wrapper objects for the sObjects in the current page set
			List<recipeWrapper> wrapperRecipes = controller.getWrapperRecipes();
		Test.stopTest();
    }
}