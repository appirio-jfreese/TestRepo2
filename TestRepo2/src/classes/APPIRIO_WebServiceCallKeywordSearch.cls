/********************************************************************************************************************
Name        : APPIRIO_WebServiceCallKeywordSearch
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 21th Jan, 2013
Purpose     : Create Web Service Call for Keyword Search.
Ref         : T-111298
			  INPUT PARAMETERS:
				Digital Published Asset API External ID
				Search string
			  OUTPUT:
				Recipes matching search terms in HEADER XML format (T-105831)
				Include the Main Drink image for each recipe in an encoded format (w/ filename & ContentDisplayID)
				
				SEARCH DETAILS:
				For search logic, use the same query that is used in MM_RecipeView when performing a search on those pages. 
				The exact same search logic is what should be executed using the Search String input parameter.
********************************************************************************************************************/
@RestResource(urlMapping='/CallKeywordSearch/*')
global with sharing class APPIRIO_WebServiceCallKeywordSearch {
	//Web Service Call for Keyword Search.
	@HttpGet
	webservice static String WebServiceCallKeywordSearch() {
		
		RestRequest req = RestContext.request;
		map<String,String> paramMap = req.params;
		
		//input parameter
		Integer resumePoint;
		Boolean endOfResponse = true;
		String APIExternalID = paramMap.get('APIExternalID');
		String searchKeyword = paramMap.get('searchKeyword');
		
		if(searchKeyword == null || searchKeyword.trim() == '') {
        	return 'Keyword Search cannot be blank.';
        }
        
		if(paramMap.get('resumePoint') != null){
			resumePoint = Integer.valueOf(paramMap.get('resumePoint'));
		} 
		
		if(ResumePoint == null || ResumePoint == 0) {
			resumePoint = 1;
		}
		
        searchKeyword = String.escapeSingleQuotes(searchKeyword);
        String brandSearchTerm = searchKeyword.replace(' ','%');
	    searchKeyword = searchKeyword.replace('*','\\*');
	    
	    String sa ='%'+brandSearchTerm+'%';
	    String st = '%'+searchKeyword+'%';
        
        List<String> temp = new List<String>();
        map<String,Id> searchKeywordRecipeIds = new map<String,Id>();
        
        String query = 'select Id, API_External_ID__c from Recipe__c where recordSaved__c=true And (Recipe_Title__c like \'%'+searchKeyword+'%\' or Status__c like \'%'+searchKeyword+'%\' or Recipe_Tag__c like \'%'+searchKeyword+'%\') order by API_External_ID__c';
        //for(Recipe__c recipe :[select id from Recipe__c where Recipe_Title__c like :st or Status__c like :st or Recipe_Tag__c like :st]) {
        for(Recipe__c recipe :(List<Recipe__c>)Database.query(query)) {
        	searchKeywordRecipeIds.put(recipe.API_External_ID__c, recipe.Id);
        	temp.add(recipe.API_External_ID__c);
        }
        
        query = 'select Id, API_External_ID__c from Recipe__c where id IN (select Recipe__c from Recipe_Attribute__c where Recipe__r.recordSaved__c = true And Attribute__r.Attribute_Value__c like \'%'+searchKeyword+'%\') order by API_External_ID__c';
        //for(Recipe__c recipe :[select id from Recipe__c where id IN (select Recipe__c from Recipe_Attribute__c where Attribute__r.Attribute_Value__c like:st)]) {
        for(Recipe__c recipe :(List<Recipe__c>)Database.query(query)) {
        	searchKeywordRecipeIds.put(recipe.API_External_ID__c, recipe.Id);
        	temp.add(recipe.API_External_ID__c);
        }
        
        query = 'select Id, API_External_ID__c from Recipe__c where id IN (select Recipe__c from Recipe_Occasion__c where Recipe__r.recordSaved__c = true And (Occasion__r.Name_Of_The_Occasion__c like \'%'+searchKeyword+'%\' or Occasion__r.Occasion_Type__c like \'%'+searchKeyword+'%\'))  order by API_External_ID__c';
        //for(Recipe__c recipe :[select id from Recipe__c where id IN (select Recipe__c from Recipe_Occasion__c where Occasion__r.Name_Of_The_Occasion__c like:st or Occasion__r.Occasion_Type__c like:st)]) {
        for(Recipe__c recipe :(List<Recipe__c>)Database.query(query)) {
        	searchKeywordRecipeIds.put(recipe.API_External_ID__c, recipe.Id);
        	temp.add(recipe.API_External_ID__c);
        }
        
        query = 'select Id, API_External_ID__c from Recipe__c where id IN (Select Recipe__c from Preparation_Step__c where Recipe__r.recordSaved__c = true And Description__c like \'%'+searchKeyword+'%\')  order by API_External_ID__c';
        //for(Recipe__c recipe :[select id from Recipe__c where id IN (Select Recipe__c from Preparation_Step__c where Description__c like :st)]) {
        for(Recipe__c recipe :(List<Recipe__c>)Database.query(query)) {
        	searchKeywordRecipeIds.put(recipe.API_External_ID__c, recipe.Id);
        	temp.add(recipe.API_External_ID__c);
        }
        
        query = 'select Id, API_External_ID__c from Recipe__c where id IN (select Recipe__c FROM Diageo_Ingredient__c Where Recipe__r.recordSaved__c = true And (Recipe_Diageo_Product__r.Name like \'%'+searchKeyword+'%\' or Recipe_Non_Diageo_Product__r.Name like \'%'+searchKeyword+'%\' or Recipe_Diageo_Product__r.Short_Description__c like \'%'+searchKeyword+'%\' or Recipe_Brand__r.Short_Description__c like \'%'+searchKeyword+'%\'))  order by API_External_ID__c';
        //for(Recipe__c recipe :[select id from Recipe__c where id IN (select Recipe__c FROM Diageo_Ingredient__c Where Recipe_Diageo_Product__r.Name like :sa or Recipe_Non_Diageo_Product__r.Name like :sa or Recipe_Diageo_Product__r.Short_Description__c like :st or Recipe_Brand__r.Short_Description__c like :st)]) {
        for(Recipe__c recipe :(List<Recipe__c>)Database.query(query)) {
        	searchKeywordRecipeIds.put(recipe.API_External_ID__c, recipe.Id);
        	temp.add(recipe.API_External_ID__c);
        }
        
        set<Id> setRcipeIds = new set<Id>();
        List<Id> recipeIds = new List<Id>();
        
        if(APIExternalID == null || APIExternalID.trim() == '') {
        	temp.sort();
        	setRcipeIds = new set<Id>();
        	for(String str :temp) {
        		if(!setRcipeIds.contains(searchKeywordRecipeIds.get(str))) {
	        		recipeIds.add(searchKeywordRecipeIds.get(str));
	        		setRcipeIds.add(searchKeywordRecipeIds.get(str));	
	        	}
            }
        } else {
        	setRcipeIds = new set<Id>();
        	//Query all Published_Recipe__c records where Asset__c = input parameter with Search Keyword.
        	for(Published_Recipe__c publishedRecipe :[Select Recipe__c From Published_Recipe__c 
                                                        Where Digital_Published_Asset__r.API_External_ID__c =:APIExternalID 
                                                        And Recipe__c IN :searchKeywordRecipeIds.values()
                                                        And Recipe__r.recordSaved__c = true
                                                        order by Recipe__r.API_External_ID__c]) {
				if(!setRcipeIds.contains(publishedRecipe.Recipe__c)) {
	        		recipeIds.add(publishedRecipe.Recipe__c);
	        		setRcipeIds.add(publishedRecipe.Recipe__c);	
	        	}
            }	
        }
        
        temp = null;
        setRcipeIds = null;
        searchKeywordRecipeIds = null;
     //4.3.2012-LSLEVIN-Case4405-START//   
       // Integer newResumePoint = 199;
       Integer newResumePoint = 9;
    //Case4405-END//   
        if((resumePoint+newResumePoint) < recipeIds.size()) {
			endOfResponse = false;
		}
        return generateXML(APIExternalID, recipeIds, resumePoint, newResumePoint, endOfResponse);
	}
	
	static String generateXML(String APIExternalID, List<Id> recipeIds, Integer resumePoint, Integer newResumePoint, Boolean endOfResponse) {
		List<Id> newRecipeIds;
		//Place all Recipe__c objects contained within the result set into the XML template generated in T-104967.
		APPIRIO_GenerateXMLKeywordSearch generateXMLKeywordSearch = new APPIRIO_GenerateXMLKeywordSearch();
		
    	newRecipeIds = new List<Id>();
    	Integer cnt = 1;
    	for(Id recipeId :recipeIds) {
    		if(resumePoint <= cnt && cnt <= (resumePoint+newResumePoint)) {
    			newRecipeIds.add(recipeId);
    		}
    		cnt = cnt+1;
    	}
    	
        generateXMLKeywordSearch.recipeIds = newRecipeIds;
        generateXMLKeywordSearch.endOfResponse = endOfResponse;
        generateXMLKeywordSearch.resumePoint = resumePoint+newResumePoint+1;
    	if(endOfResponse)
    		generateXMLKeywordSearch.resumePoint = null;
    	
        //Generate the XML output.
        generateXMLKeywordSearch.generateXMLRecipeIinfo();
        //Return the XML output.
        String xmlString;
        xmlString = generateXMLKeywordSearch.xmlString;
        generateXMLKeywordSearch.xmlString = '';
        
        /*
        if(xmlString.length() > 2500000) {
        	
        	if(newRecipeIds.size() == 1) {
        		return 'Single recipe record has contained more than 2.5MB data.';	
        	}
        	
        	Decimal dNum = xmlString.length()/2500000;
        	
        	Integer newPoint;
        	if(dNum >= 1 && dNum < 2 && newRecipeIds.size() >=2 ) {
        		newPoint = newRecipeIds.size()/2;	
        	} else if(newRecipeIds.size() > 1 && newRecipeIds.size() < dNum ) {
        		newPoint = newRecipeIds.size()/2;	
        	} else if(newRecipeIds.size() >= dNum ) {
        		newPoint = newRecipeIds.size()/dNum.intValue();
        	}
        	xmlString = generateXML(APIExternalID, recipeIds, resumePoint, newPoint, false);
        }*/
        return xmlString;
	}
}