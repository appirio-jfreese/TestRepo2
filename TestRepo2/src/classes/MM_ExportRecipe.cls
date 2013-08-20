public with sharing class MM_ExportRecipe extends MM_RecipeBase {
    public Master_Recipe__c masterRecipe {get; set;}
    public List<Recipe__c> recipes {get;set;}
    public String redirectBack {get; set;}
    
    public MM_ExportRecipe (String masterRecipeId, String recipeId, String recipeList) {
        masterRecipeId = masterRecipeId;
        recipeId = recipeId;
        recipeList = recipeList;
        exportRecipe(masterRecipeId, recipeId, recipeList);
    }
    
    public MM_ExportRecipe () {
        
        String masterRecipeId = ApexPages.currentPage().getParameters().get('masterRecipeId');
        String recipeId = ApexPages.currentPage().getParameters().get('recipeId');
        String recipeList = ApexPages.currentPage().getParameters().get('recipeList');
        exportRecipe(masterRecipeId, recipeId, recipeList);
    }
    
    private void exportRecipe (String masterRecipeId, String recipeId, String recipeList) {
        redirectBack = ApexPages.currentPage().getParameters().get('redirectBack');
        
        System.debug('redirectBack: '+ redirectBack);
        List<Id> recipeIds = new List<Id>();
        if (recipeList != null){
            String[] tmpIds = recipeList.split(',');
            for (String s: tmpIds){
                if (s.length() >= 15)
                    recipeIds.add(s);
            }   
        }

        System.debug('recipeIds' + recipeIds);
        if (recipeIds != null && recipeIds.size() > 0){
            recipes = [SELECT Comments__c, CreatedById, CreatedDate, IsDeleted, Language__c, LastActivityDate, LastModifiedById, 
                LastModifiedDate, Main_Drink_Image__r.Content_Id__c, Main_Drink_Image_URL__c, Main_Ingredient_Image__c,Main_Ingredient_Image__r.Content_Id__c,
                Background_Image__c,Background_Image__r.Content_Id__c,Brand_Recipe_Image__c,Brand_Recipe_Image__r.Content_Id__c,Search_Recipe_Image__c,Search_Recipe_Image__r.Content_Id__c,
                Master_Recipe__c, Menu_Description__c, Mobile_Drink_Image__r.Content_Id__c, Mobile_Drink_Image_URL__c, 
                Mobile_Selected_Image__r.Content_Id__c,Mobile_Selected_Image_URL__c, Mobile_Unselected_Image__r.Content_Id__c, 
                Mobile_Unselected_Image_URL__c,Recipe_Title__c,NEO_Recipe_Id__c,Recipe_Tag__c, Name, Recipe_Type_del__c, 
                Recipe_Version__c, Id, Short_Description__c, Status__c, SystemModstamp, 
                Thumbnail_Drink_Image__r.Content_Id__c, Thumbnail_Drink_Image_URL__c, 
                (Select Id,Units__c, Recipe_Diageo_Product__r.Name,Recipe_Non_Diageo_Product__r.Name, Quantity__c, Featured_Brand__c from Diageo_Ingredients__r ),
                (select id,Attribute__r.Attribute_Type__c,Attribute__r.Attribute_Value__c,Attribute__r.Attribute_External_Id__c,
				Attribute__r.Attribute_Value_Image__r.Content_id__c from Recipe_Attributes__r),
                (Select id,Occasion__r.Name_Of_The_Occasion__c,Occasion__r.Occasion_Type__c,Occasion__r.Occasion_Tag__c,
				Occasion__r.Start_Date__c,Occasion__r.Start_Month__c,Occasion__r.End_Date__c,Occasion__r.End_Month__c,
				Occasion__r.Day_Of_The_Week__c,Occasion__r.Recipe_Occasion_Image__r.Content_id__c,Occasion__r.Short_Description__c,Occasion__r.Long_Description__c,Occasion__r.Occasion_External_Id__c  from Recipe_Occasions__r),
                (Select Description__c, Step_Number__c from Preparation_Steps__r where Description__c != null order by Step_Number__c asc),
                
                Additional_Image_5__r.Content_Id__c, Additional_Image_4__r.Content_Id__c, 
                Additional_Image_3__r.Content_Id__c, Additional_Image_2__r.Content_Id__c, Additional_Image_1__r.Content_Id__c 
           FROM Recipe__c
          WHERE Id IN :recipeIds
          and recordSaved__c = true];          
        }
         else if(recipeId != null){
            
            recipes = [SELECT Comments__c, CreatedById, CreatedDate, IsDeleted, Language__c, LastActivityDate, LastModifiedById, 
                LastModifiedDate, Main_Drink_Image__r.Content_Id__c, Main_Drink_Image_URL__c, Main_Ingredient_Image__c,Main_Ingredient_Image__r.Content_Id__c,
                Background_Image__c,Background_Image__r.Content_Id__c,Brand_Recipe_Image__c,Brand_Recipe_Image__r.Content_Id__c,Search_Recipe_Image__c,Search_Recipe_Image__r.Content_Id__c,
                Master_Recipe__c, Menu_Description__c, Mobile_Drink_Image__r.Content_Id__c, Mobile_Drink_Image_URL__c, 
                Mobile_Selected_Image__r.Content_Id__c,Mobile_Selected_Image_URL__c, Mobile_Unselected_Image__r.Content_Id__c, 
                Mobile_Unselected_Image_URL__c,Recipe_Title__c,NEO_Recipe_Id__c,Recipe_Tag__c, Name, Recipe_Type_del__c, 
                Recipe_Version__c, Id, Short_Description__c, Status__c, SystemModstamp, Thumbnail_Drink_Image__r.Content_Id__c, Thumbnail_Drink_Image_URL__c, 
                (Select Id,Units__c, Recipe_Diageo_Product__r.Name,Recipe_Non_Diageo_Product__r.Name, Quantity__c, Featured_Brand__c from Diageo_Ingredients__r ),
                (select id,Attribute__r.Attribute_Type__c,Attribute__r.Attribute_Value__c,Attribute__r.Attribute_External_Id__c,
				Attribute__r.Attribute_Value_Image__r.Content_id__c from Recipe_Attributes__r),
                (Select id,Occasion__r.Name_Of_The_Occasion__c,Occasion__r.Occasion_Type__c,Occasion__r.Occasion_Tag__c,
				Occasion__r.Start_Date__c,Occasion__r.Start_Month__c,Occasion__r.End_Date__c,Occasion__r.End_Month__c,
				Occasion__r.Day_Of_The_Week__c,Occasion__r.Recipe_Occasion_Image__r.Content_id__c,Occasion__r.Short_Description__c,Occasion__r.Long_Description__c,Occasion__r.Occasion_External_Id__c  from Recipe_Occasions__r),
                (Select Description__c, Step_Number__c from Preparation_Steps__r where Description__c != null order by Step_Number__c asc),
               
                Additional_Image_5__r.Content_Id__c, Additional_Image_4__r.Content_Id__c, 
                Additional_Image_3__r.Content_Id__c, Additional_Image_2__r.Content_Id__c, Additional_Image_1__r.Content_Id__c 
           FROM Recipe__c
          WHERE Id = :recipeId
          and recordSaved__c = true];
        }
        
        else if (masterRecipeId != null) {
            recipes = [SELECT Comments__c, CreatedById, CreatedDate, IsDeleted, Language__c, LastActivityDate, LastModifiedById, 
                LastModifiedDate, Main_Drink_Image__r.Content_Id__c, Main_Drink_Image_URL__c, Main_Ingredient_Image__c,Main_Ingredient_Image__r.Content_Id__c,
                Background_Image__c,Background_Image__r.Content_Id__c,Brand_Recipe_Image__c,Brand_Recipe_Image__r.Content_Id__c,Search_Recipe_Image__c,Search_Recipe_Image__r.Content_Id__c,
                Master_Recipe__c, Menu_Description__c, Mobile_Drink_Image__r.Content_Id__c, Mobile_Drink_Image_URL__c, 
                Mobile_Selected_Image__r.Content_Id__c,Mobile_Selected_Image_URL__c, Mobile_Unselected_Image__r.Content_Id__c, 
                Mobile_Unselected_Image_URL__c,Recipe_Title__c,NEO_Recipe_Id__c,Recipe_Tag__c, Name, Recipe_Type_del__c, 
                Recipe_Version__c, Id, Short_Description__c, Status__c, SystemModstamp, Thumbnail_Drink_Image__r.Content_Id__c, Thumbnail_Drink_Image_URL__c, 
                (Select Id,Units__c, Recipe_Diageo_Product__r.Name,Recipe_Non_Diageo_Product__r.Name, Quantity__c, Featured_Brand__c from Diageo_Ingredients__r ),
                (select id,Attribute__r.Attribute_Type__c,Attribute__r.Attribute_Value__c,Attribute__r.Attribute_External_Id__c,
				Attribute__r.Attribute_Value_Image__r.Content_id__c from Recipe_Attributes__r),
                (Select id,Occasion__r.Name_Of_The_Occasion__c,Occasion__r.Occasion_Type__c,Occasion__r.Occasion_Tag__c,
				Occasion__r.Start_Date__c,Occasion__r.Start_Month__c,Occasion__r.End_Date__c,Occasion__r.End_Month__c,
				Occasion__r.Day_Of_The_Week__c,Occasion__r.Recipe_Occasion_Image__r.Content_id__c,Occasion__r.Short_Description__c,Occasion__r.Long_Description__c,Occasion__r.Occasion_External_Id__c  from Recipe_Occasions__r),
                (Select Description__c, Step_Number__c from Preparation_Steps__r where Description__c != null order by Step_Number__c asc),
                
                Additional_Image_5__r.Content_Id__c, Additional_Image_4__r.Content_Id__c, 
                Additional_Image_3__r.Content_Id__c, Additional_Image_2__r.Content_Id__c, Additional_Image_1__r.Content_Id__c 
           FROM Recipe__c
          WHERE Master_Recipe__c = :masterRecipeId
          and recordSaved__c = true];
        }
       
        if (redirectBack != null)
            sendBack();
        
    }
    
    public PageReference sendBack(){
        PageReference pageRef = new PageReference(redirectBack);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    

}