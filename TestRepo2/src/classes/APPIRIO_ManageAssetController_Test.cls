/*
	Class : APPIRIO_ManageAssetController_Test 
	Description :  Test Class for a APPIRIO_ManageAssetController
	Developed by : Manmeet Manethiya
	CreatedDate : Dec 07, 2012
*/

@isTest(SeeAllData=false)
private class APPIRIO_ManageAssetController_Test {
	public static Digital_Published_Asset__c digiTalPublishedAsset;
	public static Published_Recipe__c pubRecipe;
	public static Published_Occasion__c pubOccasion;
	
	static testMethod void testManageAssets() {
		createTestData();
		Apexpages.Standardcontroller stController = new Apexpages.Standardcontroller(digiTalPublishedAsset);
		Test.startTest();
		//calling controller
		APPIRIO_ManageAssetController controller = new APPIRIO_ManageAssetController(stController);
		//fetching published asset receipes
		controller.getPublishedRecipes();
		controller.showMoreRecipe();
		controller.showLessRecipe();
		controller.getPublishedOccasions();
		controller.showMoreOccasion();
		controller.showLessOccasion();
		//fetching user agesnts
		controller.getUserAgent();
		Test.stopTest();
		
		//assert to check size of occasion
		System.assertEquals(1, controller.occasionCount);
		//assert to check size of recipe
		System.assertEquals(1, controller.recipeCount);
	}
	
	//method to create test data
	private static void createTestData(){
		//creating digigtal published asset
		digiTalPublishedAsset = new Digital_Published_Asset__c();
		insert digiTalPublishedAsset;
		
		//creating a Master Recipe
		Master_Recipe__c mastRec = TestUtil.createMasterRecipe('MasterRecipe');
		
		//Creates a Recipe
		Recipe__c recipe = TestUtil.createRecipe('TestRecipe1',mastRec.Id,'Draft',true);
		recipe.Locale__c = 'EN-US';
		update recipe;
		
		//creating published recipe
		pubRecipe = new Published_Recipe__c();
		pubRecipe.Digital_Published_Asset__c = digiTalPublishedAsset.id;
		pubRecipe.Status__c = 'Published';
		pubRecipe.Recipe__c = recipe.id;
		insert pubRecipe;
		
		//creating occasion
		Occasion__c occasion = new Occasion__c();
		insert occasion;
		
		
		//creating published occasion
		pubOccasion = new Published_Occasion__c();
		pubOccasion.Digital_Published_Asset__c = digiTalPublishedAsset.id;
		pubOccasion.Status__c = 'Published';
		pubOccasion.Occasion__c = occasion.id;
		insert pubOccasion;
		
	}
}