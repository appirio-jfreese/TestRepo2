/***************************************************************
Name        : APPIRIO_GenerateXMLRecipeLstModifed_Test
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 28th Dec, 2012
Purpose     : Test Class for 
				- APPIRIO_GenerateXMLRecipeLstModifiedInfo
****************************************************************/
@isTest(SeeAllData = true)
private class APPIRIO_GenerateXMLRecipeLstModifed_Test {

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
	
	static Digital_Published_Asset__c digitalPublishedAsset;
	static Published_Recipe__c publishedRecipe; 
	static Published_Recipe__c publishedRecipe1; 
	static Published_Occasion__c publishedOccasion;
	
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
		
		//Creating a bunch of Attribute Records
		attr = TestUtil.createAttribute('Color','TestBlue',null);
		attr1= TestUtil.createAttribute('Language','TestEnglish',null);
		attr2 = TestUtil.createAttribute('Flavor','TestStrawberry',null);
		attr3 = TestUtil.createAttribute('Flavor','TestBanana',null);
		attr4 = TestUtil.createAttribute('Drink Type','TestCocktails',null);
		attr5 = TestUtil.createAttribute('Drink Type','TestBloody-Marys',null);
		attr6 = TestUtil.createAttribute('Glassware','TestGlassware',null);
        attr7 = TestUtil.createAttribute('Effort Level','TestEffortLevel',null);
        attr8 = TestUtil.createAttribute('Serving Style','TestServingStyle',null);
        attr9 = TestUtil.createAttribute('Wine Type','TestWineType',null);
        attr10 = TestUtil.createAttribute('Wine Taste','TestWineTaste',null);
        attr11 = TestUtil.createAttribute('Barware Needed','TestBarwareNeeded',null);
        attr12 = TestUtil.createAttribute('Drink Classification','TestDrinkClassification',null);
		 
		//Mapping Recipes to the Attributes(Creating Junction Object Records)
		recattr = TestUtil.createRecipeAttribute(recipe.Id,attr.Id);
		recattr1 = TestUtil.createRecipeAttribute(recipe.Id,attr1.Id);
		recattr2 = TestUtil.createRecipeAttribute(recipe.Id,attr2.Id);
		recattr3 = TestUtil.createRecipeAttribute(recipe.Id,attr3.Id);
		recattr4 = TestUtil.createRecipeAttribute(recipe.Id,attr4.Id);
		recattr5 = TestUtil.createRecipeAttribute(recipe.Id,attr5.Id);
		recattr6 = TestUtil.createRecipeAttribute(recipe.Id,attr6.Id);
		recattr7 = TestUtil.createRecipeAttribute(recipe.Id,attr7.Id);
		recattr8 = TestUtil.createRecipeAttribute(recipe.Id,attr8.Id);
		recattr9 = TestUtil.createRecipeAttribute(recipe.Id,attr9.Id);
		recattr10 = TestUtil.createRecipeAttribute(recipe.Id,attr10.Id);
		recattr11 = TestUtil.createRecipeAttribute(recipe.Id,attr11.Id);
		recattr12 = TestUtil.createRecipeAttribute(recipe.Id,attr12.Id);
		 
		 //Creating a bunch of Occasions
		occ = TestUtil.createOccasion('TestHolidays','TestLaborDay',null);
		occ1 = TestUtil.createOccasion('TestCelebrations','TestThanksgivingDay',null);
		
		//Linking Occasions to Recipes Via Junction Object
		recOcc = TestUtil.createRecipeOccasion(recipe.Id,occ.Id);
		recOcc1 = TestUtil.createRecipeOccasion(recipe.Id,occ1.Id);
		
		//Creating a Diageo Brand(Parent Product)		
		diagBrnd  = TestUtil.createDiageoBrand('ModelBrand',null);
		
		//Creating a Recipe Diageo Product(Categeory/Sub Brand of Daigeo Brand)
		diagPrdct = TestUtil.createDiageoProduct('ModelBrandCaramel',diagBrnd.Id,null);
		
		//Creating a Recipe Non Diageo Product	
		nonDiagPrdct = TestUtil.createNonDiageoProduct('Big Banana',null);
		
		//Creating Recipe Ingredients
		diagIng = TestUtil.createRecipeIngredient(true,'1.25','Oz.',recipe.Id,diagBrnd.Id,diagPrdct.id,null,1);
		nonDiagIng = TestUtil.createRecipeIngredient(true,'118.294','ml.',recipe.Id,null,null,nonDiagPrdct.id,2);
		
		//Creating Preparation Step 
		prepStep = TestUtil.createPreparationStep('Test this Recipe',recipe.Id);		
		
		//Creating Digital Published Asset 
		digitalPublishedAsset =  TestUtil.createDigitalPublishedAsset('TestDigitalPublishedAsset1', 'Website', 'EN-US');
		
		//Creating Published Recipe
		publishedRecipe = TestUtil.createPublishedRecipe(digitalPublishedAsset.Id, recipe.Id,'Published');
		diagIng1 = TestUtil.createRecipeIngredient(true,'118.294','ml.',recipe.Id,diagBrnd.Id,diagPrdct.id,null,1);
		publishedRecipe1 = TestUtil.createPublishedRecipe(digitalPublishedAsset.Id, recipe1.Id,'Suppressed');
		//Creating Published Occasion
		publishedOccasion = TestUtil.createPublishedOccasion(digitalPublishedAsset.Id, occ.Id,'Published');
	}
    
    //Test Web Service Call Bulk Recipe
    public static TestMethod void WebServiceCallPubledLastModifiedTest() {
    	
    	String xmlString;
    	Date lastModified = Date.today().addDays(-1);
    	
    	List<Id> recipeIds = new List<Id>();
    	map<Id,string> mapRecipeIdPublishedStatus = new map<Id,string>();
    	
    	digitalPublishedAsset = [Select API_External_ID__c From Digital_Published_Asset__c Where Id =: digitalPublishedAsset.Id];
    	
        //Query all Published_Recipe__c records where Asset__c = input parameter AND LastModifiedDate >= lastModified.
        for(Published_Recipe__c pubRecipe :[Select Recipe__c, Status__c From Published_Recipe__c 
        											Where Digital_Published_Asset__c =:digitalPublishedAsset.Id 
        											And LastModifiedDate >= :lastModified]) {
        	recipeIds.add(pubRecipe.Recipe__c);
        	mapRecipeIdPublishedStatus.put(pubRecipe.Recipe__c,pubRecipe.Status__c);
        }
        
        recipe = [Select API_External_ID__c, NEO_Recipe_Id__c, Locale__c From Recipe__c Where Id=:recipe.Id];
        diagPrdct = [Select Name, Locale__c, API_External_ID__c From Diageo_Product__c Where Id=:diagPrdct.id];
        diagBrnd = [Select Name, Locale__c, API_External_ID__c From Diageo_Brand__c Where Id=:diagBrnd.id];
        
        if(recipe.NEO_Recipe_Id__c == null) recipe.NEO_Recipe_Id__c='';
    	
    	APPIRIO_GenerateXMLRecipeLstModifiedInfo xmlRecipeIinfo = new APPIRIO_GenerateXMLRecipeLstModifiedInfo();
		xmlRecipeIinfo.recipeIds = recipeIds;
		xmlRecipeIinfo.digitalPublishedAssetIds.add(digitalPublishedAsset.API_External_ID__c);
		xmlRecipeIinfo.generateXMLRecipeIinfo();
    	System.assert(xmlRecipeIinfo.xmlString.contains('<?xml version="1.0"?>'));
    	
    	System.assert(xmlRecipeIinfo.xmlString.contains('<recipes><recipe sfRecipeId="'+recipe.API_External_ID__c+'" neoRecipeId="'+recipe.NEO_Recipe_Id__c+'" Locale="'+recipe.Locale__c+'">'));
    	System.assert(xmlRecipeIinfo.xmlString.contains('TestRecipe1'));
        System.assert(xmlRecipeIinfo.xmlString.contains('<publishedStatus>Published</publishedStatus>'));
        System.assert(xmlRecipeIinfo.xmlString.contains('TestRecipe2'));
        System.assert(xmlRecipeIinfo.xmlString.contains('<publishedStatus>Suppressed</publishedStatus>'));
        
        System.assert(xmlRecipeIinfo.xmlString.contains('<featuredBrand id="'+diagBrnd.API_External_ID__c+'" Locale="'+diagBrnd.Locale__c+'">'+diagBrnd.Name+'</featuredBrand>'));
        System.assert(xmlRecipeIinfo.xmlString.contains('<brand id="'+diagBrnd.API_External_ID__c+'" Locale="'+diagBrnd.Locale__c+'">'+diagBrnd.Name+'</brand>'));
        System.assert(xmlRecipeIinfo.xmlString.contains('<featuredProduct id="'+diagPrdct.API_External_ID__c+'" Locale="'+diagPrdct.Locale__c+'">'+diagPrdct.Name+'</featuredProduct>'));
        System.assert(xmlRecipeIinfo.xmlString.contains('<diageoIngredient id="'+diagPrdct.API_External_ID__c+'" Locale="'+diagPrdct.Locale__c+'"><name>'+diagPrdct.Name+'</name>'));
                
        System.assert(xmlRecipeIinfo.xmlString.contains('<image imageType="MainDrink" sfImageAssetId="'+contentVersion.ContentDocumentId+'" fileName="'+contentVersion.Title+'.'+contentVersion.FileType.toLowerCase()+'"></image>'));
        System.assert(xmlRecipeIinfo.xmlString.contains('<image imageType="Thumbnail" sfImageAssetId="'+contentVersion.ContentDocumentId+'" fileName="'+contentVersion.Title+'.'+contentVersion.FileType.toLowerCase()+'"></image>'));
        
        occ = [Select Name_Of_The_Occasion__c, API_External_ID__c, Locale__c, Occasion_Tags__c From Occasion__c Where Id =:occ.id];
		occ1 = [Select Name_Of_The_Occasion__c, API_External_ID__c, Locale__c From Occasion__c Where Id =:occ1.id]; 
        
        System.assert(xmlRecipeIinfo.xmlString.contains('<occasion id="'+occ.API_External_ID__c+'" Locale="'+occ.Locale__c+'">'+occ.Name_Of_The_Occasion__c+'</occasion><tags>'+occ.Occasion_Tags__c+'</tags>'));
        System.assert(!xmlRecipeIinfo.xmlString.contains('<occasion id="'+occ1.API_External_ID__c+'" Locale="'+occ1.Locale__c+'">'+occ1.Name_Of_The_Occasion__c+'</occasion>'));
	}
}