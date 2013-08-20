/********************************************************************************************************************
Name        : APPIRIO_RecipeIngredientTriggerHandler
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 26th Feb, 2013
Purpose     : This class handles the business logic of Recipe Ingredient's trigger
              Triggers:
                - APPIRIO_RecipeIngredientTrigger
              
              -In this trigger Recipe's field "Edit Notification To Publisher?" will be updated 
               when "Recipe-Admin" update "Recipe Ingredient" of Approved Recipe.
********************************************************************************************************************/
public with sharing class APPIRIO_RecipeIngredientTriggerHandler {

	//The following variable has the Id of "Recipe - Admin" role.
	static Id roleRecipeAdminId = [Select Id From UserRole Where Name = 'Recipe - Admin' limit 1].Id;
	
	/*
    @Method Name : onAfterInsertUpdateRecipeIngredient
	@description : Static method called on After Insert/Update event of trigger APPIRIO_RecipeIngredientTrigger  
	@parameters  : List<Diageo_Ingredient__c>
	@returns	 : Nothing
    */
    //In this trigger Recipe's field "Edit Notification To Publisher?" will be updated 
    //when "Recipe-Admin" update "Recipe Ingredient" of Approved Recipe.
	public static void onAfterInsertUpdateRecipeIngredient(List<Diageo_Ingredient__c> newRecipeIngredients) {
		//Verify that the current user’s role is “Recipe - Admin”.
		system.debug('==============================UserInfo.getUserRoleId(): '+UserInfo.getUserRoleId());
		system.debug('==============================roleRecipeAdminId: '+roleRecipeAdminId);
		if(UserInfo.getUserRoleId() == roleRecipeAdminId) {
			set<Id> recipeIds = new set<Id>();
			for(Diageo_Ingredient__c recipeIngredient :newRecipeIngredients) {
				recipeIds.add(recipeIngredient.Recipe__c);
			}
			
			//Create a list of Recipe to update
			List<Recipe__c> lstRecipe = new List<Recipe__c>();
			//For loop to iterate through all the approved recipe records
			for(Recipe__c recipe : [Select Edit_Notification_To_Publisher__c From Recipe__c 
																			 Where Status__c = 'Approved' 
																			 And Edit_Notification_To_Publisher__c = false
																			 And Id IN :recipeIds]) {
				recipe.Edit_Notification_To_Publisher__c = true;
				lstRecipe.add(recipe);
			}
			
			if(lstRecipe.size() > 0) {
				update lstRecipe;
			}
		}
	}
}