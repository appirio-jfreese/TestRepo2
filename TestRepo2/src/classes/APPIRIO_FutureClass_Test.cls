/**************************************************************************************
Name        : APPIRIO_FutureClass_Test 
Created By  : Appirio Offshore(Rishi Khirbat)   
Date        : 26th Feb, 2013
Purpose     : Test class for 
				- APPIRIO_FutureClass.cls
***************************************************************************************/
@isTest
private class APPIRIO_FutureClass_Test {

    //variable declaration
	static Id currentUser = UserInfo.getUserId();
	static Account account;
	static Master_Recipe__c mastRec;
	static Recipe__c recipe; 
	static Digital_Published_Asset__c digitalPublishedAsset;
	
	static {
		//creating a account
		account = new Account(Name='Test Account');
		insert account;
		
    	//creating a Master Recipe
		mastRec = TestUtil.createMasterRecipe('MasterRecipe');
		
		//Creates a Recipe
		recipe = TestUtil.createRecipe('TestRecipe1',mastRec.Id,'Draft',true);
		recipe.Locale__c = 'EN-US';
		recipe.Status__c = 'Approved';
		update recipe;
        
		//Creating Digital Published Asset 
		digitalPublishedAsset =  TestUtil.createDigitalPublishedAsset('TestDigitalPublishedAsset1', 'Website', 'EN-US');
		digitalPublishedAsset.Publisher__c = currentUser;
		update digitalPublishedAsset;
	} 
	
    //Test function "RecipeEditNotificationToPublisher" of FutureClass
    public static TestMethod void TestFutureClass() {
    	Test.startTest();
    		set<Id> recipeIds = new set<Id>();
    		recipeIds.add(recipe.Id);
    		APPIRIO_FutureClass.RecipeEditNotificationToPublisher(recipeIds);
        Test.stopTest();
	}
}