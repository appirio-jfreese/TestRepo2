/********************************************************************************************************************
Name        : APPIRIO_WebServiceCallRecipeClasifi_Test
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 15th Jan, 2013
Purpose     : Test Class for 
				- APPIRIO_WebServiceCallRecipeClasifictins
********************************************************************************************************************/
@isTest
private class APPIRIO_WebServiceCallRecipeClasifi_Test {
	
	//variable declaration
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
	
	static {
		//Creating a bunch of Attribute Records
		attr = TestUtil.createAttribute('Color','TestBlue',null);
		attr1= TestUtil.createAttribute('Language','TestEnglish',null);
		attr2 = TestUtil.createAttribute('Flavor','TestStrawberry',null);
		attr3 = TestUtil.createAttribute('Drink Type','TestCocktails',null);
		attr4 = TestUtil.createAttribute('Glassware','TestGlassware',null);
        attr5 = TestUtil.createAttribute('Effort Level','TestEffortLevel',null);
        attr6 = TestUtil.createAttribute('Serving Style','TestServingStyle',null);
        attr7 = TestUtil.createAttribute('Wine Type','TestWineType',null);
        attr8 = TestUtil.createAttribute('Wine Taste','TestWineTaste',null);
        attr9 = TestUtil.createAttribute('Barware Needed','TestBarwareNeeded',null);
        attr10 = TestUtil.createAttribute('Test Drink Classification','TestDrinkClassification',null);
        attr10.Dynamic__c = true;
        update attr10;
	}
	
	//Test Web Service Call for Recipe Classifications
    static testMethod void WebServiceCallRecipeClasifictinsTest() {
    	String xmlString;
    	Test.startTest();
	    	// set up the request object
	        System.RestContext.request = new RestRequest();
	        RestContext.request.requestURI = '/CallRecipeClassificationDetails/';
	        
	        // Invoke the method directly
	        xmlString = APPIRIO_WebServiceCallRecipeClasifictins.WebServiceCallRecipeClassification();
			System.assert(xmlString.contains('<?xml version="1.0"?>'));
	        System.assert(xmlString.contains('<recipeClassifications>'));
	        System.assert(xmlString.contains('<recipeClassification>Color</recipeClassification>'));
	        System.assert(xmlString.contains('<recipeClassification>Barware Needed</recipeClassification>'));
	        System.assert(!xmlString.contains('<recipeClassification>Test Drink Classification</recipeClassification>'));
	        System.assert(xmlString.contains('<recipeClassification>Brand</recipeClassification>'));
	        System.assert(xmlString.contains('<recipeClassification>Product</recipeClassification>'));
	        System.assert(xmlString.contains('<recipeClassification>Occasion</recipeClassification>'));
	        System.assert(xmlString.contains('</recipeClassifications>'));
	        
	        // Invoke the method directly
	        RestContext.request.addParameter('Key', 'Color');
	        xmlString = APPIRIO_WebServiceCallRecipeClasifictins.WebServiceCallRecipeClassification();
			System.assert(xmlString.contains('<?xml version="1.0"?>'));
	        System.assert(xmlString.contains('<recipeClassifications>'));
	        System.assert(xmlString.contains('<recipeClassification>Color</recipeClassification>'));
	        System.assert(!xmlString.contains('<recipeClassification>Barware Needed</recipeClassification>'));
	        System.assert(!xmlString.contains('<recipeClassification>Test Drink Classification</recipeClassification>'));
	        System.assert(!xmlString.contains('<recipeClassification>Brand</recipeClassification>'));
	        System.assert(!xmlString.contains('<recipeClassification>Product</recipeClassification>'));
	        System.assert(!xmlString.contains('<recipeClassification>Occasion</recipeClassification>'));
	        System.assert(xmlString.contains('</recipeClassifications>'));
	        
	        // Invoke the method directly
	        RestContext.request.addParameter('Key', 'Brand');
	        xmlString = APPIRIO_WebServiceCallRecipeClasifictins.WebServiceCallRecipeClassification();
			System.assert(xmlString.contains('<?xml version="1.0"?>'));
	        System.assert(xmlString.contains('<recipeClassifications>'));
	        System.assert(!xmlString.contains('<recipeClassification>Color</recipeClassification>'));
	        System.assert(!xmlString.contains('<recipeClassification>Barware Needed</recipeClassification>'));
	        System.assert(!xmlString.contains('<recipeClassification>Test Drink Classification</recipeClassification>'));
	        System.assert(xmlString.contains('<recipeClassification>Brand</recipeClassification>'));
	        System.assert(!xmlString.contains('<recipeClassification>Product</recipeClassification>'));
	        System.assert(!xmlString.contains('<recipeClassification>Occasion</recipeClassification>'));
	        System.assert(xmlString.contains('</recipeClassifications>'));
	        
	        // Invoke the method directly
	        RestContext.request.addParameter('Key', 'Product');
	        xmlString = APPIRIO_WebServiceCallRecipeClasifictins.WebServiceCallRecipeClassification();
			System.assert(xmlString.contains('<?xml version="1.0"?>'));
	        System.assert(xmlString.contains('<recipeClassifications>'));
	        System.assert(!xmlString.contains('<recipeClassification>Color</recipeClassification>'));
	        System.assert(!xmlString.contains('<recipeClassification>Barware Needed</recipeClassification>'));
	        System.assert(!xmlString.contains('<recipeClassification>Test Drink Classification</recipeClassification>'));
	        System.assert(!xmlString.contains('<recipeClassification>Brand</recipeClassification>'));
	        System.assert(xmlString.contains('<recipeClassification>Product</recipeClassification>'));
	        System.assert(!xmlString.contains('<recipeClassification>Occasion</recipeClassification>'));
	        System.assert(xmlString.contains('</recipeClassifications>'));
	        
	        // Invoke the method directly
	        RestContext.request.addParameter('Key', 'Occasion');
	        xmlString = APPIRIO_WebServiceCallRecipeClasifictins.WebServiceCallRecipeClassification();
			System.assert(xmlString.contains('<?xml version="1.0"?>'));
	        System.assert(xmlString.contains('<recipeClassifications>'));
	        System.assert(!xmlString.contains('<recipeClassification>Color</recipeClassification>'));
	        System.assert(!xmlString.contains('<recipeClassification>Barware Needed</recipeClassification>'));
	        System.assert(!xmlString.contains('<recipeClassification>Test Drink Classification</recipeClassification>'));
	        System.assert(!xmlString.contains('<recipeClassification>Brand</recipeClassification>'));
	        System.assert(!xmlString.contains('<recipeClassification>Product</recipeClassification>'));
	        System.assert(xmlString.contains('<recipeClassification>Occasion</recipeClassification>'));
	        System.assert(xmlString.contains('</recipeClassifications>'));
        Test.stopTest();
    }
}