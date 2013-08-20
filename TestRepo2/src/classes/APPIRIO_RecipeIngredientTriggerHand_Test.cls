/**************************************************************************************
Name        : APPIRIO_RecipeIngredientTriggerHand_Test 
Created By  : Appirio Offshore(Rishi Khirbat)   
Date        : 26th Feb, 2013
Purpose     : Test class for 
                - APPIRIO_RecipeIngredientTrigger.trigger
                - APPIRIO_RecipeIngredientTriggerHandler.cls 
***************************************************************************************/
@isTest(SeeAllData = true)
public with sharing class APPIRIO_RecipeIngredientTriggerHand_Test {
    //variable declaration
    static Id currentUser = UserInfo.getUserId();
    static Account account;
    static UserRole adminRole = [select Id from UserRole where Name =: MM_RecipeBase.RECIPE_ADMIN];
    static UserRole editorRole = [select Id from UserRole where Name =: MM_RecipeBase.RECIPE_EDITOR ];
    
    static User editor;
    static User admin;
    
    static Master_Recipe__c mastRec;
    static Recipe__c recipe; 
    
    static Diageo_Brand__c diagBrnd;
    static Diageo_Product__c diagPrdct;
    static Diageo_Ingredient__c diagIng;
    
    static Digital_Published_Asset__c digitalPublishedAsset;
    
    static {
        editor = new User(alias = 'unittest', email='unittest@diageorecipes.com', 
                emailencodingkey='UTF-8', lastname='Testing', 
                languagelocalekey='en_US', 
                localesidkey='en_US', profileid = UserInfo.getProfileId(), userroleid = editorRole.Id,
                timezonesidkey='America/Los_Angeles', 
                username='unittest@diageorecipes.com');
        
        admin = new User(alias = 'unitadm', email='unitadm@diageorecipes.com', 
                emailencodingkey='UTF-8', lastname='Testing', 
                languagelocalekey='en_US', 
                localesidkey='en_US', profileid = UserInfo.getProfileId(), userroleid = adminRole.Id,
                timezonesidkey='America/Los_Angeles', 
                username='unitadm@diageorecipes.com');
        
        editor.isActive=true;
        admin.isActive=true;
            
        insert editor;
        insert admin;
        
        system.runas(editor) {
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
            
            //Creating a Diageo Brand(Parent Product)       
            diagBrnd  = TestUtil.createDiageoBrand('ModelBrand',null);
            //Creating a Recipe Diageo Product(Categeory/Sub Brand of Daigeo Brand)
            diagPrdct = TestUtil.createDiageoProduct('ModelBrandCaramel',diagBrnd.Id,null);
            
            //Creating Digital Published Asset 
            digitalPublishedAsset =  TestUtil.createDigitalPublishedAsset('TestDigitalPublishedAsset1', 'Website', 'EN-US');
            digitalPublishedAsset.Publisher__c = currentUser;
            update digitalPublishedAsset;
        }
    } 
    
    //Test RecipeIngredientTriggerHandler
    public static TestMethod void TestRecipeIngredientTriggerHandler() {
        
        system.runas(admin) {
        	Test.startTest();
                //Creating Recipe Ingredients
                diagIng = TestUtil.createRecipeIngredient(true,'1.25','Oz.',recipe.Id,diagBrnd.Id,diagPrdct.id,null,1);
                recipe = [Select Edit_Notification_To_Publisher_Time__c, LastModifiedDate From Recipe__c Where Id =:recipe.Id];
                System.assert(recipe.Edit_Notification_To_Publisher_Time__c != null);
                System.assert(recipe.Edit_Notification_To_Publisher_Time__c > recipe.LastModifiedDate);
           	Test.stopTest();
        }
    }
}