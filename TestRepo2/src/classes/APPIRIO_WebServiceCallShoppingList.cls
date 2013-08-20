/********************************************************************************************************************
Name        : APPIRIO_WebServiceCallShoppingList
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 7th Jan, 2013
Purpose     : Create web service call which returns a rolled-up list of ingredients for multiple recipes.
Ref         : T-107733
			  input parameters:
				1. Recipe API External ID
				2. Servings for Recipe
				3. ** There can be more than one recipe included, in that case it would be: param1 = R-00001, param2 = 2, param3= R-00002, param4 = 4 ...
			
			  output:
				- Query SFDC for matching recipes and the associated Diageo_Ingredient__c records for the recipes
				- For each recipe: multiply the quantity of the ingredients by the # of servings
				- If multiple recipes share the same ingredients, add the quantities together (EX: Recipe 1 = 1oz voka, Recipe 2=4oz vodka, Resultset = 5oz vodka)
				- **For now, only perform the addition of quanities when the unit matches, do not perform any conversions (EX: Recipe 1 = 1oz voka, Recipe 2=1 bottle vodka, Resultset = 1oz vodka, 1 bottle vodka)
				- Return resultset in an XML format (**XML Template to come, will be added to this story at a later date)
				
			  I-46017: Servings Parameter should be for each Recipe
			  Each recipes ingredients are multiplied by the corresponding servings value. 
			  (EX: Recipe 1 = 1oz. vodka. 2 Servings. REST output has 2 oz. vodka. Recipe 2 = 2oz. whiskey. 5 Servings. REST Output includes 10oz. whiskey)
********************************************************************************************************************/
@RestResource(urlMapping='/CallShoppingList/*')
global with sharing class APPIRIO_WebServiceCallShoppingList {
	//Web Service Call for Shopping List
	@HttpGet
	webservice static String WebServiceCallShoppingList() {
        RestRequest req = RestContext.request;
		map<String,String> paramMap = req.params;
		
    	//input parameter
    	String RecipeAPIExternalIDs = paramMap.get('RecipeAPIExternalIDs');
    	
    	if(RecipeAPIExternalIDs == null || RecipeAPIExternalIDs.trim() == '') {
            return 'Recipe APIExternalIDs cannot be blank.';
        }
        
        //input parameter
        map<String,Integer> recipeAPIExternalIDServings = new map<String,Integer>();
        for(String str :RecipeAPIExternalIDs.split(';')) {
        	if(str.split('=').size() == 2 && 
        							str.split('=')[0] != null && str.split('=')[0].trim() != '' && 
        							str.split('=')[1] != null && str.split('=')[1].trim() != '') {
        		recipeAPIExternalIDServings.put(str.split('=')[0].trim(),Integer.valueOf(str.split('=')[1].trim()));
        	}
    	}
    	
        //Place all Recipe__c objects contained within the result set into the XML template generated in APPIRIO_GenerateXMLShoppingList.
		APPIRIO_GenerateXMLShoppingList generateXMLShoppingList = new APPIRIO_GenerateXMLShoppingList();
        generateXMLShoppingList.recipeAPIExternalIDServings = recipeAPIExternalIDServings;
        generateXMLShoppingList.generateXMLRecipeIinfo();
        //Return the XML output.
        return generateXMLShoppingList.xmlString;
    }
    
    //Create a new class which will generate an XML with Shopping List.
    public class APPIRIO_GenerateXMLShoppingList {
	
		string xmlString;
		map<String,Integer> recipeAPIExternalIDServings;
		
		//private variable declaration
		private transient map<String, Convert_Measurements__c> mapConvertMeasurements;
		private map<String, String> mapOZTo5Mils;
		private map<String, String> mapMLToOZ;
			
	    //Constructor of calss APPIRIO_GenerateXMLRecipeIinfo
		public APPIRIO_GenerateXMLShoppingList() {
			xmlString = '';
			recipeAPIExternalIDServings = new map<String,Integer>();
			
			mapOZTo5Mils = new map<String, String>();
			mapMLToOZ = new map<String, String>();
			mapConvertMeasurements = Convert_Measurements__c.getAll();
			
			//getting Convert Measurements values.
			for(String name :mapConvertMeasurements.keySet()) {
	      		Convert_Measurements__c convertMeasurements = mapConvertMeasurements.get(name);
	      		if(convertMeasurements != null) {
	      			mapOZTo5Mils.put(convertMeasurements.fl_Oz__c.trim(),convertMeasurements.X5Mils__c.trim());
					mapMLToOZ.put(convertMeasurements.mL__c.trim(),convertMeasurements.fl_Oz__c.trim());
	      		}
	      	}
		}
		
		//Generating an XML with Recipe info.
		public void generateXMLRecipeIinfo() {
			
			map<String, String> mapDiageoIngredient_APIExternalID = new map<String, String>();
			map<String, String> mapDiageoIngredient_Locale = new map<String, String>();
			map<String, Decimal> mapDiageoIngredient_Unit_Quantity = new map<String, Decimal>();
			map<String, Decimal> mapNonDiageoIngredient_Unit_Quantity = new map<String, Decimal>();
			
			XmlStreamWriter w = new XmlStreamWriter();
			w.writeStartDocument(null,'1.0');
			
			//Grabbing/getting all the details of the recipes that is already created.
			for(Recipe__c recipe :[SELECT API_External_ID__c, (select id, API_External_ID__c,Ingredient_Number__c, Quantity__c,Ingredient_Unit__c,Featured_Brand__c,
											Recipe_Diageo_Product__r.Name, Recipe_Diageo_Product__r.API_External_ID__c, Recipe_Diageo_Product__r.Locale__c,
	                                      	Recipe_Non_Diageo_Product__r.Name, Recipe_Non_Diageo_Product__r.API_External_ID__c, Recipe_Non_Diageo_Product__r.Locale__c 
	                                      	from Diageo_Ingredients__r order by Ingredient_Number__c)
	                                      FROM Recipe__c WHERE API_External_ID__c IN :recipeAPIExternalIDServings.keySet() order by API_External_ID__c]) {
				
				string str;
				for(Diageo_Ingredient__c diageoIngredient: recipe.Diageo_Ingredients__r) {
		  			
		  			string diageoProduct;
		  			string diageoProductUnit;
		  			string unit = diageoIngredient.Ingredient_Unit__c;
		  			decimal quantity = decimal.valueOf(diageoIngredient.Quantity__c) * recipeAPIExternalIDServings.get(recipe.API_External_ID__c);
		  			
		  			if(diageoIngredient.Recipe_Diageo_Product__r.Name != null) 
		  			 	diageoProduct = diageoIngredient.Recipe_Diageo_Product__r.Name;
		  			else if(diageoIngredient.Recipe_Non_Diageo_Product__r.Name != null) 
		  			 	diageoProduct = diageoIngredient.Recipe_Non_Diageo_Product__r.Name;
		  			 	
		  			diageoProductUnit = diageoProduct.trim()+'__'+unit.trim();
		  			
		  			if(diageoIngredient.Recipe_Diageo_Product__r.Name != null) {
		  				
		  				mapDiageoIngredient_APIExternalID.put(diageoProductUnit, diageoIngredient.Recipe_Diageo_Product__r.API_External_ID__c);
		  				mapDiageoIngredient_Locale.put(diageoIngredient.Recipe_Diageo_Product__r.API_External_ID__c,diageoIngredient.Recipe_Diageo_Product__r.Locale__c+'');
		  				
		  			 	if(!mapDiageoIngredient_Unit_Quantity.containsKey(diageoProductUnit)) {
			  				mapDiageoIngredient_Unit_Quantity.put(diageoProductUnit, 0);
			  			}
			  			mapDiageoIngredient_Unit_Quantity.put(diageoProductUnit, mapDiageoIngredient_Unit_Quantity.get(diageoProductUnit) + quantity);
			  			
		  			} else if(diageoIngredient.Recipe_Non_Diageo_Product__r.Name != null) {
		  				
		  				mapDiageoIngredient_APIExternalID.put(diageoProductUnit, diageoIngredient.Recipe_Non_Diageo_Product__r.API_External_ID__c);
		  				mapDiageoIngredient_Locale.put(diageoIngredient.Recipe_Non_Diageo_Product__r.API_External_ID__c,diageoIngredient.Recipe_Non_Diageo_Product__r.Locale__c+'');
		  				
		  			 	if(!mapNonDiageoIngredient_Unit_Quantity.containsKey(diageoProductUnit)) {
			  				mapNonDiageoIngredient_Unit_Quantity.put(diageoProductUnit, 0);
			  			}
			  			mapNonDiageoIngredient_Unit_Quantity.put(diageoProductUnit, mapNonDiageoIngredient_Unit_Quantity.get(diageoProductUnit) + quantity);
		  			}
				}
			}
			
			string unit;
			string productName;
			
			//ShoppingList
			w.writeStartElement(null,'shoppingList',null);
				//diageoIngredients
				w.writeStartElement(null,'diageoIngredients',null);
					if(mapDiageoIngredient_Unit_Quantity.size() > 0) {
						for(string str :mapDiageoIngredient_Unit_Quantity.keySet()){
							productName = str.left(str.indexOf('__', 0));
							unit = str.replace(productName+'__','');
							//diageoIngredient
							w.writeStartElement(null,'diageoIngredient',null);
								w.writeAttribute(null, null, 'id', ''+mapDiageoIngredient_APIExternalID.get(str));
								w.writeAttribute(null, null, 'Locale', ''+mapDiageoIngredient_Locale.get(mapDiageoIngredient_APIExternalID.get(str)));
								//name
								w.writeStartElement(null,'name',null);
									w.writeCharacters(productName);
								w.writeEndElement();
								//end of name
								//quantity
								w.writeStartElement(null,'quantity',null);
									w.writeCharacters(mapDiageoIngredient_Unit_Quantity.get(str)+'');
								w.writeEndElement();
								//end of quantity
								//unit
								w.writeStartElement(null,'unit',null);
									w.writeCharacters(unit);
								w.writeEndElement();
								//end of unit
							w.writeEndElement();
							//end of diageoIngredients
						}
					}
				w.writeEndElement();
				//end of DiageoIngredients
				
				//otherIngredients
				w.writeStartElement(null,'otherIngredients',null);
					if(mapNonDiageoIngredient_Unit_Quantity.size() > 0) {
						for(string str :mapNonDiageoIngredient_Unit_Quantity.keySet()){
							productName = str.left(str.indexOf('__', 0));
							unit = str.replace(productName+'__','');
							//otherIngredient
							w.writeStartElement(null,'otherIngredient',null);
								w.writeAttribute(null, null, 'id', ''+mapDiageoIngredient_APIExternalID.get(str));
								w.writeAttribute(null, null, 'Locale', ''+mapDiageoIngredient_Locale.get(mapDiageoIngredient_APIExternalID.get(str)));
								//name
								w.writeStartElement(null,'name',null);
									w.writeCharacters(productName);
								w.writeEndElement();
								//end of name
								//quantity
								w.writeStartElement(null,'quantity',null);
									w.writeCharacters(mapNonDiageoIngredient_Unit_Quantity.get(str)+'');
								w.writeEndElement();
								//end of quantity
								//unit
								w.writeStartElement(null,'unit',null);
									w.writeCharacters(unit);
								w.writeEndElement();
								//end of unit
							w.writeEndElement();
							//end of otherIngredient
						}
					}
				w.writeEndElement();
				//end of otherIngredients
			w.writeEndElement();
			//end of shoppingList

			w.writeEndDocument();
			xmlString = w.getXmlString();
			system.debug('===================xmlString: '+ xmlString);
			w.close();
		}
	}
}