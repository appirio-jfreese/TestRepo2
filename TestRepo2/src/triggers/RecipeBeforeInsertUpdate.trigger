/********************************************************************************************************************
Name        : RecipeAfterInsertUpdate
Created By  : Appirio Offshore(Manmeet Manethiya)   
Date        : 5th Dec, 2012
Purpose     : This trigger handles all the business logic before insert/update of Recipe__c.
********************************************************************************************************************/
//Logic of this trigger moved to APPIRIO_RecipeTrigger.trigger
trigger RecipeBeforeInsertUpdate on Recipe__c (before insert, before update) {
		//RecipeManagement.onBeforeInsertUpdateRecipe(Trigger.new);
}