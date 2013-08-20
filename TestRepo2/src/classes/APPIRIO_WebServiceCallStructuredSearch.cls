/********************************************************************************************************************
Name        : APPIRIO_WebServiceCallStructuredSearch
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 24th Jan, 2013
Purpose     : Create Web Service Call for Structured Search.
Ref         : T-111974
			  INPUT PARAMETERS:
				1. Digital_Published_Asset__c.API_External_ID__c
				2. Any number of key-value pairs (see below)
				
				A Key-Value pair will look like the following: 
				KEY=VALUE,VALUE,VALUE...
				
				There can be any number of key value pairs.
				
				KEYS:
				Keys will be  oneof the following:
				Brand=
				Product=
				Occasion=
				Attribute__c.Attribute_Type__c=
				VALUES:
				Values will look as follows (values in italics):
				Brand=Guinness,Bushmills  OR  Brand=B-0001,B-0002 (Brand__c.API_EXTERNAL_ID__C)
				Product=Guinness Black Lager,Bushmills Irish Whiskey  OR  Product=DP-0001,DP-0002 (Diageo_Product__c.API_EXTERNAL_ID__C)
				Occasion=Fourth of July, Halloween  OR  Occasion=O-0001,O-0002 (Occasion__c.API_EXTERNAL_ID__C)
				Color = Blue,Brown  OR  Color=A-0001,A-0002 (Attribute__c.API_EXTERNAL_ID__C)
				NOTE: #4 above can be ANY Arribute__c.Attribute_Type__c. (Examples: Color=, Barware=, Glassware Needed=, Type=, etc.)
				
				NOTE: A Web Service call will contain either Text in the values, or API EXTERNAL IDS. There will never be a mix of text and IDs. Always one or the other.
				
				OUTPUT:
				
				First check for Published_Recipe__c records for the matching Asset. Only return recipes in which Published_Recipe__c matches the Recipe AND the Digitial Published Asset AND Status = Published.
				
				Check Recipes based on key value pairs (This functions the same way as the sidebar filters on MM_ViewAllRecipes)
				
				Logic is OR when inside of a key, and AND outside of a key. See below:
				EXAMPLE: Select Recipes WHERE (Brand=Guinness OR Bushmills) AND (Color=Brown OR Black) AND (Occasion=Halloween)
				
				Place Result Set into same format as the Bulk Recipe XML (Header format).
********************************************************************************************************************/
@RestResource(urlMapping='/CallStructuredSearch/*')
global with sharing class APPIRIO_WebServiceCallStructuredSearch {
	//Web Service Call for Structured Search.
	@HttpGet
	webservice static String WebServiceCallStructuredSearch() {
		
		RestRequest req = RestContext.request;
		map<String,String> paramMap = req.params;
		
		//input parameter
		Integer totalRecords = 0;
		Integer resumePoint = 1;
		Boolean endOfResponse = true;
		String APIExternalID = paramMap.get('APIExternalID');
		String KeyValues = paramMap.get('KeyValues');
		
        if(APIExternalID == null || APIExternalID.trim() == '') {
            return 'APIExternalID cannot be blank.';
        }
        
        if(paramMap.get('resumePoint') != null && paramMap.get('resumePoint').trim() != null){
			resumePoint = Integer.valueOf(paramMap.get('resumePoint'));
		} 
		
        if(resumePoint == null || resumePoint == 0) {
			resumePoint = 1;
		}
		
		Integer offSet = resumePoint -1;
		List<Published_Recipe__c> lstPublishedRecipe = new List<Published_Recipe__c>();
		
		set<String> searchKeys = new set<String>();
		set<String> searchRecipeIds = new set<String>();
		set<String> searchBrandRecipeIds = new set<String>();
        set<String> searchProductRecipeIds = new set<String>();
        set<String> searchOccasionRecipeIds = new set<String>();
        set<String> searchArributeRecipeIds = new set<String>();
        
        if(KeyValues != null && KeyValues != '') {
	        for(String str :KeyValues.split(':')) {
	        	String key = str.split('=')[0];
	        	
	        	if(str.split('=')[1] == null) {
	        		return 'Values of key "'+key+'" cannot be blank.';
	        	}
	        	
	        	set<String> values = new set<String>();
	        	for(String value :str.split('=')[1].split(';')) {
	        		values.add(value.trim());
	        	}
	        	
	        	if(key.equals('Brand') && values.size() > 0) {
	        		searchKeys.add('Brand');
	            	for(Recipe__c recipe :[select id from Recipe__c where id IN (select Recipe__c FROM Diageo_Ingredient__c Where Recipe_Brand__r.Name IN: values Or Recipe_Brand__r.API_External_ID__c IN: values)]) {
		            	searchBrandRecipeIds.add(recipe.Id);
		            }
	            } else if(key.equals('Product') && values.size() > 0) {
	            	searchKeys.add('Product');
	            	for(Recipe__c recipe :[select id from Recipe__c where id IN (select Recipe__c FROM Diageo_Ingredient__c Where Recipe_Diageo_Product__r.Name IN: values Or Recipe_Diageo_Product__r.API_External_ID__c IN: values)]) {
		            	searchProductRecipeIds.add(recipe.Id);
		            }
	            } else if(key.equals('Occasion') && values.size() > 0) {
	            	searchKeys.add('Occasion');
	            	for(Recipe__c recipe :[select id from Recipe__c where id IN (select Recipe__c from Recipe_Occasion__c where Occasion__r.Name_Of_The_Occasion__c IN: values Or Occasion__r.API_External_ID__c IN: values)]) {
		            	searchOccasionRecipeIds.add(recipe.Id);
		            }
	            } else {
	            	if(values.size() > 0) 
	            		searchKeys.add('Arribute');
	            	for(Recipe__c recipe :[select id from Recipe__c where id IN (select Recipe__c from Recipe_Attribute__c where Attribute__r.Attribute_Type__c =:key And (Attribute__r.Attribute_Value__c IN: values Or Attribute__r.API_External_ID__c IN: values))]) {
		            	searchArributeRecipeIds.add(recipe.Id);
		            }
	            }
	        }
	        
	        searchRecipeIds.add('TempRecipeId');
            if(searchKeys.contains('Brand'))
            	searchRecipeIds = matchRecipeIds(searchRecipeIds, searchBrandRecipeIds);
            if(searchKeys.contains('Product'))
            	searchRecipeIds = matchRecipeIds(searchRecipeIds, searchProductRecipeIds);
            if(searchKeys.contains('Occasion'))
            	searchRecipeIds = matchRecipeIds(searchRecipeIds, searchOccasionRecipeIds);
            if(searchKeys.contains('Arribute'))
            	searchRecipeIds = matchRecipeIds(searchRecipeIds, searchArributeRecipeIds);
	        
	        totalRecords = searchRecipeIds.size();
        
	        //Query all Published_Recipe__c records where Asset__c = input parameter AND Status = Published.
	        lstPublishedRecipe = [Select Recipe__c From Published_Recipe__c 
		                                                        Where Status__c = 'Published' 
		                                                        And Recipe__r.recordSaved__c = true
		                                                        And Recipe__c IN :searchRecipeIds
		                                                        And Digital_Published_Asset__r.API_External_ID__c =:APIExternalID
		                                                        order by Recipe__r.API_External_ID__c limit 500 OFFSET :offSet];
			
        } else {
        	//Query all Published_Recipe__c records where Asset__c = input parameter AND Status = Published.
        	totalRecords = [Select Count() From Published_Recipe__c 
		                                                        Where Status__c = 'Published' 
		                                                        And Recipe__r.recordSaved__c = true
		                                                        And Digital_Published_Asset__r.API_External_ID__c =:APIExternalID];
		                                                        
	        lstPublishedRecipe = [Select Recipe__c From Published_Recipe__c 
		                                                        Where Status__c = 'Published' 
		                                                        And Recipe__r.recordSaved__c = true
		                                                        And Digital_Published_Asset__r.API_External_ID__c =:APIExternalID
		                                                        order by Recipe__r.API_External_ID__c limit 500 OFFSET :offSet];
        }
        
        List<Id> recipeIds = new List<Id>();
		set<Id> setRcipeIds = new set<Id>();
		for(Published_Recipe__c publishedRecipe :lstPublishedRecipe) {
            if(!setRcipeIds.contains(publishedRecipe.Recipe__c)) {
        		recipeIds.add(publishedRecipe.Recipe__c);
        		setRcipeIds.add(publishedRecipe.Recipe__c);
        	}
        }	
        
        setRcipeIds = null;
        lstPublishedRecipe = null;
        Integer newResumePoint = 499;
        
        if((resumePoint+newResumePoint) < totalRecords) {
			endOfResponse = false;
		}
        
        //Return the XML output.
        return generateXML(APIExternalID, recipeIds, resumePoint, newResumePoint, endOfResponse);
	}
	
	static set<String> matchRecipeIds(set<String> recipeIds, set<String> filterIds) {
		if(recipeIds.contains('TempRecipeId')) {
			return filterIds;
		}
		if(recipeIds.size() == 0 || filterIds.size() == 0) {
			return (new set<String>());
		}
		for(String id : recipeIds) {
    		if(!filterIds.contains(id)) {
    			recipeIds.remove(id);
    		}
    	}
    	return recipeIds;
	}
	
	static String generateXML(String APIExternalID, List<Id> recipeIds, Integer resumePoint, Integer newResumePoint, Boolean endOfResponse) {
		List<Id> newRecipeIds;
		
		APPIRIO_GenerateXMLRecipeHeaderInfo generateXMLRecipeHeader = new APPIRIO_GenerateXMLRecipeHeaderInfo();
		
    	newRecipeIds = new List<Id>();
    	Integer cnt = 1;
    	for(Id recipeId :recipeIds) {
    		if(cnt <= (newResumePoint+1)) {
    			newRecipeIds.add(recipeId);
    		}
    		cnt = cnt+1;
    	}
        generateXMLRecipeHeader.recipeIds = newRecipeIds;
        generateXMLRecipeHeader.endOfResponse = endOfResponse;
        generateXMLRecipeHeader.resumePoint = resumePoint+newResumePoint+1;
    	if(endOfResponse)
    		generateXMLRecipeHeader.resumePoint = null;
    	
        //Generate the XML output.
        generateXMLRecipeHeader.generateXMLRecipeIinfo();
        //Return the XML output.
        String xmlString;
        xmlString = generateXMLRecipeHeader.xmlString;
        generateXMLRecipeHeader.xmlString = '';
        
        /*
        Integer maxFileSize = 1000000;
        if(Test.isRunningTest()){
        	maxFileSize = 5000;
        }
        
        if(xmlString.length() > maxFileSize) {
        	
        	if(newRecipeIds.size() == 1) {
        		return 'Single recipe record has contained more than 2.5MB data.';	
        	}
        	
        	Decimal dNum = xmlString.length()/maxFileSize;
        	
        	Integer newPoint;
        	if( (dNum >= 1 && dNum < 2 && newRecipeIds.size() >= 2) || (newRecipeIds.size() > 1 && newRecipeIds.size() < dNum)) {
        		newPoint = newRecipeIds.size()/2;	
        	} else if(newRecipeIds.size() >= dNum ) {
        		newPoint = newRecipeIds.size()/dNum.intValue();
        	}
        	xmlString = generateXML(APIExternalID, recipeIds, resumePoint, newPoint, false);
        }*/
        return xmlString;
	}
}