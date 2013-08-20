/**************************************************************************************
Name        : APPIRIO_RecipeTriggerHandler_Test 
Created By  : Appirio Offshore(Rishi Khirbat)   
Date        : 26th Feb, 2013
Purpose     : Test class for 
				- APPIRIO_RecipeTrigger.trigger
				- APPIRIO_RecipeTriggerHandler.cls 
***************************************************************************************/
@isTest
private class APPIRIO_RecipeTriggerHandler_Test {

	//variable declaration
	static Id currentUser = UserInfo.getUserId();
	static Account account;
	static UserRole adminRole = [select Id from UserRole where Name =: MM_RecipeBase.RECIPE_ADMIN];
	static UserRole editorRole = [select Id from UserRole where Name =: MM_RecipeBase.RECIPE_EDITOR ];
	
	static User editor;
    static User admin;
	
	static Master_Recipe__c mastRec;
	static Recipe__c recipe; 
	
	static Attribute__c attr;
	static Recipe_Attribute__c recattr;
	
	static Occasion__c occ;
	static Recipe_Occasion__c recOcc;
	
	static Diageo_Brand__c diagBrnd;
	static Diageo_Product__c diagPrdct;
	static Diageo_Ingredient__c diagIng;
	static Preparation_Step__c prepStep;
	
	static Digital_Published_Asset__c digitalPublishedAsset;
	static Published_Recipe__c publishedRecipe; 
	static Published_Occasion__c publishedOccasion;
	
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
			
			//Creating a bunch of Attribute Records
			attr = TestUtil.createAttribute('Color','TestBlue',null);
			//Mapping Recipes to the Attributes(Creating Junction Object Records)
			recattr = TestUtil.createRecipeAttribute(recipe.Id,attr.Id);
			//Creating a bunch of Occasions
			occ = TestUtil.createOccasion('TestHolidays','TestLaborDay',null);
			//Linking Occasions to Recipes Via Junction Object
			recOcc = TestUtil.createRecipeOccasion(recipe.Id,occ.Id);
			//Creating a Diageo Brand(Parent Product)		
			diagBrnd  = TestUtil.createDiageoBrand('ModelBrand',null);
			//Creating a Recipe Diageo Product(Categeory/Sub Brand of Daigeo Brand)
			diagPrdct = TestUtil.createDiageoProduct('ModelBrandCaramel',diagBrnd.Id,null);
			//Creating Recipe Ingredients
			diagIng = TestUtil.createRecipeIngredient(true,'1.25','Oz.',recipe.Id,diagBrnd.Id,diagPrdct.id,null,1);
			//Creating Preparation Step 
			prepStep = TestUtil.createPreparationStep('Test this Recipe',recipe.Id);		
			//Creating Digital Published Asset 
			digitalPublishedAsset =  TestUtil.createDigitalPublishedAsset('TestDigitalPublishedAsset1', 'Website', 'EN-US');
			digitalPublishedAsset.Publisher__c = currentUser;
			update digitalPublishedAsset;
			//Creating Published Recipe
			publishedRecipe = TestUtil.createPublishedRecipe(digitalPublishedAsset.Id, recipe.Id,'Published');
			//Creating Published Occasion
			publishedOccasion = TestUtil.createPublishedOccasion(digitalPublishedAsset.Id, occ.Id, 'Published');
        }
	} 
	
    //Test Approved Recipe Edit Notification To Publisher - Recipe
    public static TestMethod void RecipeEdit() {
    	system.runas(admin) {
			Test.startTest();
    			recipe.Locale__c = 'EN-US';
				recipe.Status__c = 'Approved';
    			update recipe;
    			system.debug('==============================admin.UserRoleId: '+admin.UserRoleId);
    			system.debug('==============================UserInfo.getUserRoleId(): '+UserInfo.getUserRoleId());
    			recipe = [Select Edit_Notification_To_Publisher_Time__c, LastModifiedDate From Recipe__c Where Id =:recipe.Id];
    			System.assert(recipe.Edit_Notification_To_Publisher_Time__c != null);
    			System.assert(recipe.Edit_Notification_To_Publisher_Time__c > recipe.LastModifiedDate);
			Test.stopTest();
		}
	}
}