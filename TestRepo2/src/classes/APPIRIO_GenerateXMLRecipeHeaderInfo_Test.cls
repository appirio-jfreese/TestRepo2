/********************************************************************************************************************
Name        : APPIRIO_GenerateXMLRecipeHeaderInfo_Test
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 27th Dec, 2012
Purpose     : Test Class for 
				- APPIRIO_GenerateXMLRecipeHeaderInfo
********************************************************************************************************************/
@isTest(SeeAllData = true)
private class APPIRIO_GenerateXMLRecipeHeaderInfo_Test {

   //variable declaration
	static	Master_Recipe__c mastRec;
	static Recipe__c recipe; 
	static Recipe__c recipe1; 
	
	static Attribute__c attr;
	static Attribute__c attr1;
	static Attribute__c attr2;
	static Attribute__c attr3;
	static Attribute__c attr4;
	static Attribute__c attr5;
	static Attribute__c attr6;
	static Attribute__c attr7;
	static Attribute__c attr8;
	static Attribute__c attr9;
	static Attribute__c attr10;
	static Attribute__c attr11;
	static Attribute__c attr12;
	
	static Recipe_Attribute__c recattr;
	static Recipe_Attribute__c recattr1;
	static Recipe_Attribute__c recattr2;
	static Recipe_Attribute__c recattr3;
	static Recipe_Attribute__c recattr4;
	static Recipe_Attribute__c recattr5;
	static Recipe_Attribute__c recattr6;
	static Recipe_Attribute__c recattr7;
	static Recipe_Attribute__c recattr8;
	static Recipe_Attribute__c recattr9;
	static Recipe_Attribute__c recattr10;
	static Recipe_Attribute__c recattr11;
	static Recipe_Attribute__c recattr12;
	
	static Occasion__c occ;
	static Occasion__c occ1;
	static Recipe_Occasion__c recOcc;
	static Recipe_Occasion__c recOcc1;
	static Diageo_Brand__c diagBrnd;
	static Diageo_Product__c diagPrdct;
	static Recipe_Non_Diageo_Product__c nonDiagPrdct;
	static Diageo_Ingredient__c diagIng;
	static Diageo_Ingredient__c diagIng1;
	static Diageo_Ingredient__c nonDiagIng;
	static Preparation_Step__c prepStep;
		
	static ContentVersion contentVersion;
	static Recipe_Media__c media;
		
	static {
		//creating a Content Version
		contentVersion = TestUtil.testInsertDrinkImageContent('Google.com'); 
		contentVersion = [Select Id, FileType, Title, ContentDocumentId From ContentVersion Where Id =: contentVersion.Id];
		media = new Recipe_Media__c();
        media.Content_Display_ID__c=contentVersion.ContentDocumentId;
        insert media;
		
		//creating a Master Recipe
		mastRec = TestUtil.createMasterRecipe('MasterRecipe');
		
		//Creates a Recipe
		recipe = TestUtil.createRecipe('TestRecipe1',mastRec.Id,'Draft',true);
		recipe.Locale__c = 'EN-US';
		recipe.Additional_Image_1__c = media.Id;
        recipe.Additional_Image_2__c = media.Id;
        recipe.Additional_Image_3__c = media.Id; 
        recipe.Additional_Image_4__c = media.Id; 
        recipe.Additional_Image_5__c = media.Id;
        recipe.Background_Image__c = media.Id;
        recipe.Brand_Recipe_Image__c = media.Id;
		recipe.Main_Drink_Image__c = media.Id;   
		recipe.Main_Ingredient_Image__c = media.Id;     
        recipe.Mobile_Selected_Image__c = media.Id;
        recipe.Mobile_Unselected_Image__c = media.Id;
        recipe.Mobile_Drink_Image__c = media.Id;
        recipe.Search_Recipe_Image__c = media.Id;
        recipe.Thumbnail_Drink_Image__c = media.Id;
        update recipe;
        
		//Creates a Recipe
		recipe1 = TestUtil.createRecipe('TestRecipe2',mastRec.Id,'Draft',true);
		 
		//Creating a Diageo Brand(Parent Product)		
		diagBrnd  = TestUtil.createDiageoBrand('ModelBrand',null);
		
		//Creating a Recipe Diageo Product(Categeory/Sub Brand of Daigeo Brand)
		diagPrdct = TestUtil.createDiageoProduct('ModelBrandCaramel',diagBrnd.Id,null);
		
		//Creating a Recipe Non Diageo Product	
		nonDiagPrdct = TestUtil.createNonDiageoProduct('Big Banana',null);
		
		//Creating Recipe Ingredients
		diagIng = TestUtil.createRecipeIngredient(true,'1.25','oz.',recipe.Id,diagBrnd.Id,diagPrdct.id,null,1);
		diagIng1 = TestUtil.createRecipeIngredient(true,'118.294','ml.',recipe.Id,diagBrnd.Id,diagPrdct.id,null,1);
		nonDiagIng = TestUtil.createRecipeIngredient(true,'118.294','ml.',recipe.Id,null,null,nonDiagPrdct.id,2);
	}
    
    //
    public static TestMethod void GenerateXMLRecipeHeaderInfoTest() {
		
		recipe = [Select API_External_ID__c, NEO_Recipe_Id__c, Locale__c From Recipe__c Where Id=:recipe.Id];
		diagPrdct = [Select Name, Locale__c, API_External_ID__c From Diageo_Product__c Where Id=:diagPrdct.id];
        diagBrnd = [Select Name, Locale__c, API_External_ID__c From Diageo_Brand__c Where Id=:diagBrnd.id];
        
        if(recipe.NEO_Recipe_Id__c == null) recipe.NEO_Recipe_Id__c='';
		
		APPIRIO_GenerateXMLRecipeHeaderInfo xmlRecipeIinfo = new APPIRIO_GenerateXMLRecipeHeaderInfo();
		xmlRecipeIinfo.recipeIds = new List<Id>();
		xmlRecipeIinfo.recipeIds.add(recipe.Id);
		xmlRecipeIinfo.recipeIds.add(recipe1.Id);
        xmlRecipeIinfo.generateXMLRecipeIinfo();
        System.assert(xmlRecipeIinfo.xmlString.contains('<?xml version="1.0"?>'));
        
        System.assert(xmlRecipeIinfo.xmlString.contains('<recipes><recipe sfRecipeId="'+recipe.API_External_ID__c+'" neoRecipeId="'+recipe.NEO_Recipe_Id__c+'" Locale="'+recipe.Locale__c+'">'));
        System.assert(xmlRecipeIinfo.xmlString.contains('TestRecipe1'));
        System.assert(xmlRecipeIinfo.xmlString.contains('TestRecipe2'));
        
        System.assert(xmlRecipeIinfo.xmlString.contains('<featuredBrand id="'+diagBrnd.API_External_ID__c+'" Locale="'+diagBrnd.Locale__c+'">'+diagBrnd.Name+'</featuredBrand>'));
        System.assert(xmlRecipeIinfo.xmlString.contains('<brand id="'+diagBrnd.API_External_ID__c+'" Locale="'+diagBrnd.Locale__c+'">'+diagBrnd.Name+'</brand>'));
        System.assert(xmlRecipeIinfo.xmlString.contains('<featuredProduct id="'+diagPrdct.API_External_ID__c+'" Locale="'+diagPrdct.Locale__c+'">'+diagPrdct.Name+'</featuredProduct>'));
        System.assert(xmlRecipeIinfo.xmlString.contains('<diageoIngredient id="'+diagPrdct.API_External_ID__c+'" Locale="'+diagPrdct.Locale__c+'"><name>'+diagPrdct.Name+'</name>'));
        
        System.assert(xmlRecipeIinfo.xmlString.contains('<image imageType="MainDrink" sfImageAssetId="'+contentVersion.ContentDocumentId+'" fileName="'+contentVersion.Title+'.'+contentVersion.FileType.toLowerCase()+'">'));
        System.assert(xmlRecipeIinfo.xmlString.contains('<image imageType="Thumbnail" sfImageAssetId="'+contentVersion.ContentDocumentId+'" fileName="'+contentVersion.Title+'.'+contentVersion.FileType.toLowerCase()+'">'));
	}
}