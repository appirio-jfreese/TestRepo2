/********************************************************************************************************************
Name        : APPIRIO_HelperTestUtility
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 10th Dec, 2012
Purpose     : This is helper class of test classes that contains generic function.
********************************************************************************************************************/
public class APPIRIO_HelperTestUtility {
	
	
	/*
    @Method Name : createDigitalPublishedAsset
    @description : Method to get Digital Published Asset
    @parameters  : String
    @returns     : Sobject(Digital_Published_Asset__c)
    */
    public static Digital_Published_Asset__c createDigitalPublishedAsset(String name) {
    	Digital_Published_Asset__c digitalPublishedAsset = new Digital_Published_Asset__c();
		digitalPublishedAsset.Name = name;
		return digitalPublishedAsset;
    }
	
	/*
    @Method Name : createRecipe
    @description : Method to get Recipe
    @parameters  : String,String,String
    @returns     : Sobject(Recipe__c)
    */
    public static Recipe__c createRecipe(String title, String status, String locale) {
    	Recipe__c recipe = new Recipe__c();
		recipe.Recipe_Title__c  = title;
		recipe.Status__c = status;
		recipe.locale__c = locale;
		recipe.recordSaved__c = true;
		recipe.Language__c = 'English';
		return recipe;
    }
    
    /*
    @Method Name : createPublishedRecipe
    @description : Method to get Published Recipe
    @parameters  : Id,Id,String
    @returns     : Sobject(Published_Recipe__c)
    */
    public static Published_Recipe__c createPublishedRecipe(Id digitalPublishedAssetId, Id recipeId, String status) {
    	Published_Recipe__c publishedRecipe = new Published_Recipe__c();
		publishedRecipe.Digital_Published_Asset__c = digitalPublishedAssetId;
		publishedRecipe.Recipe__c = recipeId;
		publishedRecipe.Status__c = status;
		return publishedRecipe;
    }
	
}