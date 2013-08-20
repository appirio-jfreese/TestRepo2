/*****************************************************************************************
Name        		: RecipeManagement
Last Modified By  	: Appirio Offshore(Manmeet Manethiya); Appirio Offshore(Rishi Khirbat)   
Date        		: 5th Dec, 2012; 26th Feb, 2013
Purpose     		: This class handles all the logic related to Recipe triggers 
******************************************************************************************/
public without sharing class RecipeManagement {
	
	//The logic of this class is moved to APPIRIO_RecipeTriggerHandler
	
	/*
    @Method Name : onBeforeInsertUpdateRecipe
	@description : Static method called on Before Insert/Update event of trigger RecipeBeforeInsertUpdate.  
	@parameters  : List<Recipe__c>
	@returns	 : Nothing
    */
    /*
	public static void onBeforeInsertUpdateRecipe(List<Recipe__c> newList){
        addValidationForSameNameAndLanguageLocale(newList);
        
        set<Id> recipeIds = new set<Id>();
        for(Recipe__c recipe :newList) {
        	if(recipe.Edit_Notification_To_Publisher__c)
        		recipeIds.add(recipe.Id);
        		
        	recipe.Edit_Notification_To_Publisher__c = false;
        }
        if(recipeIds.size() > 0) {
        	APPIRIO_FutureClass.RecipeEditNotificationToPublisher(recipeIds);
        }
    }*/
    
    /*
    validation/error message (apex trigger) for user when a recipe is created with the same NAME and Language-Locale as an existing recipe record.
    */
    /*
    private static void addValidationForSameNameAndLanguageLocale(List<Recipe__c> listRecipe){
        Map<String, Recipe__c> mapRecipes = new Map<String, Recipe__c>([select recipe_title__c , Locale__c 
        																				from Recipe__c where id not in : listRecipe]);
        for(Recipe__c recipe : listRecipe){
            for(Recipe__c existingRecipe : mapRecipes.values()) {
                if(recipe.recipe_title__c == existingRecipe.Recipe_title__c && 
					recipe.locale__c == existingRecipe.Locale__c){
                    recipe.addError('This recipe name and language-Locale already exist.  Please create a unique recipe name.');            
                }
            }
        }
    }*/
}