/********************************************************************************************************************
Name        : APPIRIO_WebServiceCallStructuredSrh_Test
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 29th Jan, 2013
Purpose     : Test Class for 
				- APPIRIO_WebServiceCallStructuredSearch
********************************************************************************************************************/
@isTest(SeeAllData = true)
public with sharing class APPIRIO_WebServiceCallStructuredSrh_Test {
	//variable declaration
	static	Master_Recipe__c mastRec;
	static Recipe__c recipe; 
	
	static Attribute__c attr;
	static Attribute__c attr1;
	static Attribute__c attr2;
	
	static Recipe_Attribute__c recattr;
	static Recipe_Attribute__c recattr1;
	static Recipe_Attribute__c recattr2;
	
	static Occasion__c occ;
	static Recipe_Occasion__c recOcc;
	
	static Diageo_Brand__c diagBrnd;
	static Diageo_Product__c diagPrdct;
	static Recipe_Non_Diageo_Product__c nonDiagPrdct;
	static Diageo_Ingredient__c diagIng;
	static Diageo_Ingredient__c diagIng1;
	static Diageo_Ingredient__c nonDiagIng;
	static Preparation_Step__c prepStep;
	
	static Digital_Published_Asset__c digitalPublishedAsset;
	static Published_Recipe__c publishedRecipe;
	
	static {
		//creating a Master Recipe
		mastRec = TestUtil.createMasterRecipe('MasterRecipe');
		
		//Creates a Recipe
		recipe = TestUtil.createRecipe('TestRecipe1',mastRec.Id,'Draft',true);
		
		//Creating a bunch of Attribute Records
		attr = TestUtil.createAttribute('Color','TestBlue',null);
		attr1 = TestUtil.createAttribute('Flavor','TestStrawberry',null);
		attr2 = TestUtil.createAttribute('Flavor','TestBanana',null);
		 
		//Mapping Recipes to the Attributes(Creating Junction Object Records)
		recattr = TestUtil.createRecipeAttribute(recipe.Id,attr.Id);
		recattr1 = TestUtil.createRecipeAttribute(recipe.Id,attr1.Id);
		recattr2 = TestUtil.createRecipeAttribute(recipe.Id,attr2.Id);
		 
		 //Creating a bunch of Occasions
		occ = TestUtil.createOccasion('TestHolidays','TestLaborDay',null);
		
		//Linking Occasions to Recipes Via Junction Object
		recOcc = TestUtil.createRecipeOccasion(recipe.Id,occ.Id);
		
		//Creating a Diageo Brand(Parent Product)		
		diagBrnd  = TestUtil.createDiageoBrand('ModelBrand',null);
		
		//Creating a Recipe Diageo Product(Categeory/Sub Brand of Daigeo Brand)
		diagPrdct = TestUtil.createDiageoProduct('ModelBrandCaramel',diagBrnd.Id,null);
		
		//Creating a Recipe Non Diageo Product	
		nonDiagPrdct = TestUtil.createNonDiageoProduct('Big Banana',null);
		
		//Creating Recipe Ingredients
		diagIng = TestUtil.createRecipeIngredient(true,'1.25','oz.',recipe.Id,diagBrnd.Id,diagPrdct.id,null,1);
		diagIng1 = TestUtil.createRecipeIngredient(true,'2','oz.',recipe.Id,diagBrnd.Id,diagPrdct.id,null,1);
		nonDiagIng = TestUtil.createRecipeIngredient(true,'118.294','ml.',recipe.Id,null,null,nonDiagPrdct.id,2);
		
		//Creating Preparation Step 
		prepStep = TestUtil.createPreparationStep('Test this Recipe',recipe.Id);		
		
		//Creating Digital Published Asset 
		digitalPublishedAsset =  TestUtil.createDigitalPublishedAsset('TestDigitalPublishedAsset1', 'Website', 'EN-US');
		
		//Creating Published Recipe
		publishedRecipe = TestUtil.createPublishedRecipe(digitalPublishedAsset.Id, recipe.Id,'Published');
	}

    static testMethod void WebServiceCallStructuredSearchTest() {
    	String xmlString;
    	String KeyValues = 'Color=TestBlue:Flavor=TestStrawberry;TestBanana:Occasion=TestLaborDay:Brand=ModelBrand:Product=ModelBrandCaramel';
    	
    	digitalPublishedAsset = [Select API_External_ID__c From Digital_Published_Asset__c Where Id =: digitalPublishedAsset.Id];
    	
    	Test.startTest();
	    	// set up the request object
	        System.RestContext.request = new RestRequest();
	        RestContext.request.requestURI = '/CallStructuredSearch/';
	        
	        // Invoke the method directly
	        xmlString = APPIRIO_WebServiceCallStructuredSearch.WebServiceCallStructuredSearch();
			System.assert(xmlString.contains('APIExternalID cannot be blank.'));
	        
	        RestContext.request.addParameter('resumePoint', '1');
	        RestContext.request.addParameter('APIExternalID', digitalPublishedAsset.API_External_ID__c);
	        // Invoke the method directly
	        xmlString = APPIRIO_WebServiceCallStructuredSearch.WebServiceCallStructuredSearch();
	        System.assert(xmlString.contains('<?xml version="1.0"?>'));
	        System.assert(xmlString.contains('TestRecipe1'));
	        
	        RestContext.request.addParameter('KeyValues', KeyValues);
	        // Invoke the method directly
	        xmlString = APPIRIO_WebServiceCallStructuredSearch.WebServiceCallStructuredSearch();
			System.assert(xmlString.contains('<?xml version="1.0"?>'));
	        System.assert(xmlString.contains('TestRecipe1'));
        Test.stopTest();
    }
}