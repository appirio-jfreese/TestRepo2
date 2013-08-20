public with sharing class TestUtil {
/**
 * @author      Model Metrics(Raj Avirneni)
 * @date        Created 3/21/2012
 * @NOTE: Test Util Class that can be reused so that multiple items can be created without running into DML Limits
 **/
 
 	/**
     * @description Creates a Master Recipe.  FOR TESTING PURPOSES ONLY.
     * @param       String masterRecipeName - the Name for this Master Recipe.   
     * @return      Master_Recipe__c - the created Master_Recipe__c.
     **/
     
     public static Master_Recipe__c createMasterRecipe(string masterRecipeName){
     	Master_Recipe__c mastRec = new Master_Recipe__c();
     	mastRec.Name = masterRecipeName;
     	insert mastRec;
     	return mastRec;
     }
     
     /**
     * @description Creates a Recipe.  FOR TESTING PURPOSES ONLY.
     * @param       String recipeName - the Name for this Recipe.   
     * @param 		Id masterRecipeId - the Id of the Parent/Master Recipe
     * @param		string currentStatus - the current status of the Recipe
     * @param		boolean saveStaus - the true status of the Recipe(temp/original)
     * @return      Recipe__c - the created Recipe__c.
     **/
     public static Recipe__c createRecipe(string recipeName,Id masterRecipeId,string currentStatus,boolean saveStatus){
     	Recipe__c rec = new Recipe__c();
     	rec.Recipe_Title__c = recipeName;
     	rec.Master_Recipe__c = masterRecipeId;
     	rec.Status__c = currentStatus;
     	rec.recordSaved__c = saveStatus;
     	rec.Locale__c = 'EN-US';
     	insert rec;
     	return rec;	
     }
     
     /**
     * @description Creates a Recipe.  FOR TESTING PURPOSES ONLY.
     * @param       String recipeName - the Name for this Recipe.   
     * @param 		Id masterRecipeId - the Id of the Parent/Master Recipe
     * @param		string currentStatus - the current status of the Recipe
     * @param		boolean saveStaus - the true status of the Recipe(temp/original)
     * @return      Recipe__c - the ref Recipe__c.
     **/
     public static Recipe__c createRecipeRef(string recipeName,Id masterRecipeId,string currentStatus,boolean saveStatus){
     	Recipe__c rec = new Recipe__c();
     	rec.Recipe_Title__c = recipeName;
     	rec.Master_Recipe__c = masterRecipeId;
     	rec.Status__c = currentStatus;
     	rec.recordSaved__c = saveStatus;
     	rec.Locale__c = 'EN-US';
     	return rec;	
     }
     
     /**
     * @description Creates an Attribute.  FOR TESTING PURPOSES ONLY.
     * @param       String attributeType - the Attribute Type for this Attribute.   
     * @param		string attributeValue - the Attribute Value for this Attribute.
     * @return      Attribute__c - the created Attribute__c.
     **/
     public static Attribute__c createAttribute(string attributeType,string attributeValue,Id imageId){
     	Attribute__c attr = new Attribute__c();
     	attr.Attribute_Type__c = attributeType;
     	attr.Attribute_Value__c = attributeValue;
     	attr.Attribute_Value_Image__c = imageId;
     	attr.Locale__c = 'EN-US';
     	insert attr;
     	return attr;	
     }
     
     /**
     * @description Creates a Recipe Attribute(Junction for Recipe and Attribute Objects).  FOR TESTING PURPOSES ONLY.
     * @param 		Id recipeId - the Id of the Associated Recipe
     * @param		Id attributeId - the Id of the Associated Attribute
     * @return      Recipe_Attribute__c - the created Recipe_Attribute__c.
     **/
     public static Recipe_Attribute__c createRecipeAttribute(Id recipeId,Id attributeId){
     	Recipe_Attribute__c recAttr = new Recipe_Attribute__c();
     	recAttr.Recipe__c = recipeId;
     	recAttr.Attribute__c = attributeId;
     	
     	insert recAttr;
     	return recAttr;	
     }
     
     /**
     * @description Creates a Occasion.  FOR TESTING PURPOSES ONLY.
     * @param       String occasionType - the Occasion Type for this Occasion.   
     * @param		string occasionName - the Occasion Name for this Occasion.
     * @return      Occasion__c - the created Occasion__c.
     **/
     public static Occasion__c createOccasion(string occasionType,string occasionName,Id imageId){
     	Occasion__c occ = new Occasion__c();
     	occ.Occasion_Type__c = occasionType;
     	occ.Name_Of_The_Occasion__c = occasionName;
     	occ.Recipe_Occasion_Image__c = imageId;
     	occ.Occasion_Tags__c = 'Test Tag';
     	occ.Locale__c = 'EN-US';
     	
     	insert occ;
     	return occ;
     }
     
     /**
     * @description Creates a Recipe Occasion(Junction for Recipe and Occasion Objects).  FOR TESTING PURPOSES ONLY.
     * @param 		Id recipeId - the Id of the Associated Recipe
     * @param		Id occasionId - the Id of the Associated Occasion
     * @return      Recipe_Occasion__c - the created Recipe_Occasion__c.
     **/
     public static Recipe_Occasion__c createRecipeOccasion(Id recipeId,Id occasionId){
     	Recipe_Occasion__c recOcc = new Recipe_Occasion__c();
     	recOcc.Recipe__c = recipeId;
     	recOcc.Occasion__c = occasionId;
     	
     	insert recOcc;
     	return recOcc;	
     }
     
     /**
     * @description Creates a Diageo Brand.  FOR TESTING PURPOSES ONLY.
     * @param       String diageoBrandName - the Name for this Diageo Main Brand.   
     * @return      Diageo_Brand__c - the created Diageo_Brand__c.
     **/
     
     public static Diageo_Brand__c createDiageoBrand(string diageoBrandName,Id imageId){
     	Diageo_Brand__c diagBrnd = new Diageo_Brand__c();
     	diagBrnd.Name = diageoBrandName;
     	diagBrnd.Brand_Image__c = imageId;
     	diagBrnd.Locale__c = 'EN-US';
     	insert diagBrnd;
     	return diagBrnd;
     }
     
     /**
     * @description Creates a Reicpe Diageo Product.  FOR TESTING PURPOSES ONLY.
     * @param       String diageoProductName - the Name for this Recipe Diagep Product(sub categeory of Diageo Brand).   
     * @param		Id brandId - the Id of its Parent Brand.
     * @return      Diageo_Product__c - the created Diageo_Product__c.
     **/
     public static Diageo_Product__c createDiageoProduct(string diageoProductName,Id brandId,Id imageId){
     	Diageo_Product__c diagPrdct = new Diageo_Product__c();
     	diagPrdct.Name = diageoProductName;
     	diagPrdct.Diageo_Brand_Id__c = brandId;
     	diagPrdct.Diageo_Product_Image__c = imageId;
     	diagPrdct.Locale__c = 'EN-US';
     	insert diagPrdct;
     	return diagPrdct;	
     }
     
     /**
     * @description Creates a Reicpe Non Diageo Product.  FOR TESTING PURPOSES ONLY.
     * @param       String nonDiageoProductName - the Name for this Recipe Non Diageo Product.   
     * @return      Diageo_Product__c - the created Diageo_Product__c.
     **/
     public static Recipe_Non_Diageo_Product__c createNonDiageoProduct(string nonDiageoProductName,id imageId){
     	Recipe_Non_Diageo_Product__c nonDiagPrdct = new Recipe_Non_Diageo_Product__c();
     	nonDiagPrdct.Name = nonDiageoProductName;
     	nonDiagPrdct.Non_Diageo_Ingredient_Image__c = imageId;
     	
     	insert nonDiagPrdct;
     	return nonDiagPrdct;	
     }
     
     
     /**
     * @description Creates a Recipe Ingredient.  FOR TESTING PURPOSES ONLY.
     * @param       boolean featured - tells whether the Ingredient is Featured/Not.   
     * @param		string quantity - the quantity of the selected Ingredient.
     * @param		string units - the units status of the selected Ingredient.
     * @param 		Id diageoBrandId - the Id of the Parent/Main Diageo Brand.
     * @param 		Id diageoProductId - the Id of the Recipe Diageo Product(categeory of Diageo Brand).
     * @param 		Id nonDiageoProductId - the Id of the Recipe Non Diageo Product.
     * @return      Diageo_Ingredient__c - the created Diageo_Ingredient__c.
     **/
     public static Diageo_Ingredient__c createRecipeIngredient(boolean featured,string quantity,string units,Id recipeId,Id diageoBrandId,Id diageoProductId,Id nonDiageoProductId,integer n){
     	Diageo_Ingredient__c diagIng = new Diageo_Ingredient__c();
     	diagIng.Featured_Brand__c = featured;
     	diagIng.Quantity__c = quantity;
     	diagIng.Units__c = units;
     	diagIng.Recipe_Brand__c = diageoBrandId;
     	diagIng.Recipe_Diageo_Product__c  = diageoProductId;
     	diagIng.Recipe_Non_Diageo_Product__c = nonDiageoProductId;
     	diagIng.Recipe__c = recipeId;
     	diagIng.Ingredient_Number__c = n;
     	insert diagIng;
     	return diagIng;	
     }
     
     /**
     * @description Creates a PreparationStep.  FOR TESTING PURPOSES ONLY.
     * @param       String description - the Description for this Preparation Step.   
     * @param		Id RecipeId - the Recipe Associated for this Preparation Step.
     * @return      Preparation_Step__c - the created Preparation_Step__c.
     **/
     public static Preparation_Step__c createPreparationStep(string description,Id recipeId){
     	Preparation_Step__c pStep = new Preparation_Step__c();
     	pStep.Description__c = description;
     	pStep.Recipe__c = recipeId;
     	
     	insert pStep;
     	return pStep;
     }
     
     /**
     * @description Creates a Digital_Published_Asset__c.  FOR TESTING PURPOSES ONLY.
     * @param       String assetName - the name for this Digital_Published_Asset__c.   
     * @return      Digital_Published_Asset__c - the created Digital_Published_Asset__c.
     **/
     public static Digital_Published_Asset__c createDigitalPublishedAsset(string assetName, string typ, string locale){
     	Digital_Published_Asset__c digitalPublishedAsset = new Digital_Published_Asset__c();
     	digitalPublishedAsset.Name = assetName;
     	digitalPublishedAsset.Type__c = typ;
     	digitalPublishedAsset.Default_Locale__c = locale;
    
     	insert digitalPublishedAsset;
     	return digitalPublishedAsset;
     }
     
     /**
     * @description Creates a Published_Recipe__c.  FOR TESTING PURPOSES ONLY.
     * @param       String assetId - the Digital_Published_Asset__c for this Published_Recipe__c. 
     * @param       String recipeId - the Recipe__c for this Published_Recipe__c.  
     * @return      Published_Recipe__c - the created Published_Recipe__c.
     **/
     public static Published_Recipe__c createPublishedRecipe(string assetId, string recipeId, string status){
     	Published_Recipe__c publishedRecipe = new Published_Recipe__c();
     	publishedRecipe.Digital_Published_Asset__c = assetId;
     	publishedRecipe.Recipe__c = recipeId;
     	publishedRecipe.Status__c = status;
    
     	insert publishedRecipe;
     	return publishedRecipe;
     }
     
     /**
     * @author Rishi Khirbat
     * @date 21/01/2013
     * @description Creates a Published_Occasion__c.  FOR TESTING PURPOSES ONLY.
     * @param       String assetId - the Digital_Published_Asset__c for this Published_Occasion__c. 
     * @param       String occasionId - the Occasion__c for this Published_Occasion__c.  
     * @return      Published_Occasion__c - the created Published_Occasion__c.
     **/
     public static Published_Occasion__c createPublishedOccasion(string assetId, string occasionId, string status){
     	Published_Occasion__c publishedOccasion = new Published_Occasion__c();
     	publishedOccasion.Digital_Published_Asset__c = assetId;
     	publishedOccasion.Occasion__c = occasionId;
     	publishedOccasion.Status__c = status;
    
     	insert publishedOccasion;
     	return publishedOccasion;
     }
     
     /**
    * @author Rishi Khirbat
    * @date 01/01/2012
    * @description Insert a test ContentVersion, it is added to the Drink Image Workspace
    * @return A test ContentVersion
    */
    public static ContentVersion testInsertDrinkImageContent(String title){        
        //ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name = 'Drink Image Workspace' limit 1];
        		
		ContentVersion contentVersion = new ContentVersion(); 
		contentVersion.PathOnClient = 'https://www.google.co.in/images/srpr/logo3w.png';
		contentVersion.Title = title; 
		contentVersion.versionData = blob.valueof('1115660548001');
		insert contentVersion; 
		
		ContentVersion testContent = [SELECT Id, VersionData, ContentDocumentId FROM ContentVersion where Id = :contentVersion.Id]; 
		
		//ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc(); 
		//newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id; 
		//newWorkspaceDoc.ContentDocumentId = testContent.ContentDocumentId; 
		//insert newWorkspaceDoc; 
        return testContent;
    }
    
	@future
	public static void createUsers() {
		
     	//creating a new standard User
     /*	User ed = new User(alias = 'standt', email='standarduser@xyz.com', 
            emailencodingkey='UTF-8', lastname='Test', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = testProfiles[0].Id,userRoleId =testRoles[0].Id,
            timezonesidkey='America/Chicago',
            username='abc@xyz.com.test');
     	insert ed;*/
	}
}