/********************************************************************************************************************
Name        : APPIRIO_RecipeTriggerHandler
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 26th Feb, 2013
Purpose     : This class handles the business logic of Recipe's trigger
              Triggers:
                - APPIRIO_RecipeTrigger
              
              
********************************************************************************************************************/
public with sharing class APPIRIO_RecipeTriggerHandler {
	
	/*
    @Method Name : onBeforeInsertUpdateRecipe
	@description : Static method called on Before Insert/Update event of trigger RecipeBeforeInsertUpdate.  
	@parameters  : List<Recipe__c>
	@returns	 : Nothing
    */
	public static void onBeforeInsertUpdateRecipe(List<Recipe__c> newList) {
		//Start Case 00004942 - Diana Acker - 4/24/13
		//map<String,String> mapNameLocal = new map<String,String>();
		Set<String> setTitleLocale = new Set<String>();
		//End Case 00004942 - Diana Acker - 4/24/13
		for(Recipe__c recipe :[Select recipe_title__c, Locale__c From Recipe__c Where recordSaved__c = true And Id Not IN: newList]) {
			//Start Case 00004942 - Diana Acker - 4/24/13
			setTitleLocale.add(recipe.recipe_title__c.trim()+':'+recipe.Locale__c);
			//mapNameLocal.put(recipe.recipe_title__c.trim(),recipe.Locale__c);
			//End Case 00004942 - Diana Acker - 4/24/13
		}
		system.debug(setTitleLocale.size());
		//validation/error message (apex trigger) for user when a recipe is created with the same NAME and Language-Locale as an existing recipe record.
        //addValidationForSameNameAndLanguageLocale(newList);
        
        set<Id> idRecipeEditNotificationToPublisher = new set<Id>();
        for(Recipe__c recipe :newList) {
        	//Appirio Offshore(Rishi Khirbat) on 4th March, 2013
    		//validation/error message (apex trigger) for user when a recipe is created with the same NAME and Language-Locale as an existing recipe record.
        	//START CASE 00004942 - Diana Acker - 4/24/13
        	/*if(mapNameLocal.containsKey(recipe.recipe_title__c.trim()) != null) {
        		if(recipe.Locale__c == mapNameLocal.get(recipe.recipe_title__c.trim())) {
					recipe.addError('This recipe name and language-Locale already exist.  Please create a unique recipe name.');
        		}
        	}*/
        	if(setTitleLocale.contains(recipe.recipe_title__c.trim()+':'+recipe.Locale__c)){
        		recipe.addError('This recipe name and language-Locale already exist.  Please create a unique recipe name.');
        	}
        	//mapNameLocal.put(recipe.recipe_title__c.trim(),recipe.Locale__c);
        	setTitleLocale.add(recipe.recipe_title__c.trim()+':'+recipe.Locale__c);
        	//END CASE 00004942 - Diana Acker - 4/24/13
        	
        	if(recipe.Edit_Notification_To_Publisher__c) {
        		if(recipe.Edit_Notification_To_Publisher_Time__c == null || recipe.Edit_Notification_To_Publisher_Time__c < recipe.LastModifiedDate) {
        			idRecipeEditNotificationToPublisher.add(recipe.Id);
        			recipe.Edit_Notification_To_Publisher_Time__c = recipe.LastModifiedDate.addMinutes(1);
        		}
        	}
        	recipe.Edit_Notification_To_Publisher__c = false;
        }
        if(idRecipeEditNotificationToPublisher.size() > 0) {
        	//Method to send email notification to the Publishers when Approved Recipe gets updated by Recipe-Admin (Ref: T-120059). 
        	APPIRIO_FutureClass.RecipeEditNotificationToPublisher(idRecipeEditNotificationToPublisher);
        }
    }
    
    /*
    Appirio Offshore(Manmeet Manethiya) on 5th Dec, 2012
    validation/error message (apex trigger) for user when a recipe is created with the same NAME and Language-Locale as an existing recipe record.
    */
    /*
    private static void addValidationForSameNameAndLanguageLocale(List<Recipe__c> listRecipe) {
    	
    	
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