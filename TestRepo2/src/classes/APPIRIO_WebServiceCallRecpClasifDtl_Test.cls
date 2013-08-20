/********************************************************************************************************************
Name        : APPIRIO_WebServiceCallRecpClasifDtl_Test
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 15th Jan, 2013
Purpose     : Test Class for 
				- APPIRIO_WebServiceCallRecipeClasifDtl
********************************************************************************************************************/
@isTest
private class APPIRIO_WebServiceCallRecpClasifDtl_Test {
	
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
	static Diageo_Brand__c diagBrnd;
    static Diageo_Product__c diagPrdct;
	
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
        
        //Creating a Diageo Brand(Parent Product)       
        diagBrnd  = TestUtil.createDiageoBrand('ModelBrand',null);
        
        //Creating a Recipe Diageo Product(Categeory/Sub Brand of Daigeo Brand)
        diagPrdct = TestUtil.createDiageoProduct('ModelBrandCaramel',diagBrnd.Id,null);
	}
	
	//Test Web Service Call for Recipe Classifications
    static testMethod void WebServiceCallRecipeClasifictinsTest() {
    	String xmlString;
    	attr = [Select API_External_ID__c, Locale__c From Attribute__c Where Id=:attr.id];
    	diagPrdct = [Select Name, Locale__c, API_External_ID__c, Category__c, Diageo_Brand_Id__r.API_External_ID__c From Diageo_Product__c Where Id=:diagPrdct.id];
        diagBrnd = [Select Name, Locale__c, API_External_ID__c, Category__c From Diageo_Brand__c Where Id=:diagBrnd.id];
        
        if(diagPrdct.Category__c == null) diagPrdct.Category__c = '';
        if(diagBrnd.Category__c == null) diagBrnd.Category__c = '';
    	
    	Test.startTest();
	    	// set up the request object
	        System.RestContext.request = new RestRequest();
	        RestContext.request.requestURI = '/CallRecipeClassificationDetails/';
	        
	        // Invoke the method directly
	        xmlString = APPIRIO_WebServiceCallRecipeClasifDtl.WebServiceCallRecipeClassificationDetails();
			System.assert(xmlString.contains('<?xml version="1.0"?>'));
	        System.assert(xmlString.contains('<recipeClassifications>'));
	        System.assert(xmlString.contains('<key>Color</key>'));
	        System.assert(xmlString.contains('<value id="'+attr.API_External_ID__c+'" Locale="'+attr.Locale__c+'">TestBlue</value>'));
	        System.assert(!xmlString.contains('<recipeClassification>Test Drink Classification'));
	        System.assert(xmlString.contains('<key>Occasion</key>'));
	        System.assert(xmlString.contains('<key>Brand</key>'));
	        System.assert(xmlString.contains('<key>Product</key>'));
	        System.assert(xmlString.contains('</recipeClassifications>'));
	        
	        // Invoke the method directly
	        RestContext.request.addParameter('Key', 'Color');
	        xmlString = APPIRIO_WebServiceCallRecipeClasifDtl.WebServiceCallRecipeClassificationDetails();
			System.assert(xmlString.contains('<?xml version="1.0"?>'));
	        System.assert(xmlString.contains('<recipeClassifications>'));
	        System.assert(xmlString.contains('<key>Color</key>'));
	        System.assert(xmlString.contains('<value id="'+attr.API_External_ID__c+'" Locale="'+attr.Locale__c+'">TestBlue</value>'));
	        System.assert(!xmlString.contains('<recipeClassification>Test Drink Classification'));
	        System.assert(!xmlString.contains('<key>Occasion</key>'));
	        System.assert(!xmlString.contains('<key>Brand</key>'));
	        System.assert(!xmlString.contains('<key>Product</key>'));
	        System.assert(xmlString.contains('</recipeClassifications>'));
	        
	        // Invoke the method directly
	        RestContext.request.addParameter('Key', 'Brand');
	        xmlString = APPIRIO_WebServiceCallRecipeClasifDtl.WebServiceCallRecipeClassificationDetails();
			System.assert(xmlString.contains('<?xml version="1.0"?>'));
	        System.assert(xmlString.contains('<recipeClassifications>'));
	        System.assert(!xmlString.contains('<key>Color</key>'));
	        System.assert(!xmlString.contains('<value id="'+attr.API_External_ID__c+'" Locale="'+attr.Locale__c+'">TestBlue</value>'));
	        System.assert(!xmlString.contains('<recipeClassification>Test Drink Classification'));
	        System.assert(!xmlString.contains('<key>Occasion</key>'));
	        System.assert(xmlString.contains('<key>Brand</key>'));
	        System.assert(xmlString.contains('<value id="'+diagBrnd.API_External_ID__c+'" Locale="'+diagBrnd.Locale__c+'" Category="'+diagBrnd.Category__c+'">'+diagBrnd.Name+'</value>'));
	        System.assert(!xmlString.contains('<key>Product</key>'));
	        System.assert(xmlString.contains('</recipeClassifications>'));
	        
	        // Invoke the method directly
	        RestContext.request.addParameter('Key', 'Product');
	        xmlString = APPIRIO_WebServiceCallRecipeClasifDtl.WebServiceCallRecipeClassificationDetails();
			System.assert(xmlString.contains('<?xml version="1.0"?>'));
	        System.assert(xmlString.contains('<recipeClassifications>'));
	        System.assert(!xmlString.contains('<key>Color</key>'));
	        System.assert(!xmlString.contains('<value id="'+attr.API_External_ID__c+'" Locale="'+attr.Locale__c+'">TestBlue</value>'));
	        System.assert(!xmlString.contains('<recipeClassification>Test Drink Classification'));
	        System.assert(!xmlString.contains('<key>Occasion</key>'));
	        System.assert(!xmlString.contains('<key>Brand</key>'));
	        System.assert(xmlString.contains('<key>Product</key>'));
	        System.assert(xmlString.contains('<value id="'+diagPrdct.API_External_ID__c+'" Locale="'+diagPrdct.Locale__c+'" Category="'+diagPrdct.Category__c+'" BrandId="'+diagPrdct.Diageo_Brand_Id__r.API_External_ID__c+'">'+diagPrdct.Name+'</value>'));
	        System.assert(xmlString.contains('</recipeClassifications>'));
	        
	        // Invoke the method directly
	        RestContext.request.addParameter('Key', 'Occasion');
	        xmlString = APPIRIO_WebServiceCallRecipeClasifDtl.WebServiceCallRecipeClassificationDetails();
			System.assert(xmlString.contains('<?xml version="1.0"?>'));
	        System.assert(xmlString.contains('<recipeClassifications>'));
	        System.assert(!xmlString.contains('<key>Color</key>'));
	        System.assert(!xmlString.contains('<value id="'+attr.API_External_ID__c+'" Locale="'+attr.Locale__c+'">TestBlue</value>'));
	        System.assert(!xmlString.contains('<recipeClassification>Test Drink Classification'));
	        System.assert(xmlString.contains('<key>Occasion</key>'));
	        System.assert(!xmlString.contains('<key>Brand</key>'));
	        System.assert(!xmlString.contains('<key>Product</key>'));
	        System.assert(xmlString.contains('</recipeClassifications>'));
        Test.stopTest();
    }
}