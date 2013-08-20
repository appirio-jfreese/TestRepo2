/********************************************************************************************************************
Name        : APPIRIO_RecipeTrigger
Created By  : Appirio Offshore(Rishi Khirbat)   
Date        : 26th Feb, 2013
Modified By : 
Date        : 
Purpose     : This trigger handles all the business logic before/after saving records of Recipe.
********************************************************************************************************************/
trigger APPIRIO_RecipeTrigger on Recipe__c (before insert, before update) {
    //Before trigger
    if(trigger.isBefore) {
        //Recipe is inserting/updating
        if(trigger.isInsert || trigger.isUpdate) {
            APPIRIO_RecipeTriggerHandler.onBeforeInsertUpdateRecipe(Trigger.new);
        }
    }
}