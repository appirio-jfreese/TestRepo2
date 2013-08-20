/********************************************************************************************************************
Name        : APPIRIO_RecipeIngredientTrigger
Created By  : Appirio Offshore(Rishi Khirbat)   
Date        : 26th Feb, 2013
Purpose     : This trigger handles all the business logic before/after saving records of Recipe Ingredient.
********************************************************************************************************************/
trigger APPIRIO_RecipeIngredientTrigger on Diageo_Ingredient__c (after insert, after update) {
	//After trigger
    if(trigger.isAfter) {
        //Recipe Ingredient is inserting/updating
        if(trigger.isInsert || trigger.isUpdate) {
            APPIRIO_RecipeIngredientTriggerHandler.onAfterInsertUpdateRecipeIngredient(trigger.new);
        }
    }
}