/********************************************************************************************************************
Name        : APPIRIO_WebServiceCallBulkRecipeHeader
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 27th Dec, 2012
Purpose     : Create Web Service Call for Bulk Recipe header output.
Ref         : T-105831
			  input parameters:
				1. Digital_Published_Asset__c.API_External_ID__c
				2. string of brand names (optional) - maps to Featured Brand information
			
			  output:
				- Query all Published_Recipe__c records where Asset__c = input parameter AND Status = Published.
				- IF the brand parameter is provided, filter the result set down to only Recipe__c where Featured brand contains the query string.
				- IF brand parameter = null perform no additonal fitlering.
				- Place all Recipe__c objects contained within the result set into the XML template generated in T-104967.
				- Remove the following sections from the XML output: attributes, occasions, prepsteps, ingredients
				- Return the XML output.
********************************************************************************************************************/
@RestResource(urlMapping='/CallBulkRecipeHeader/*')
global with sharing class APPIRIO_WebServiceCallBulkRecipeHeader {
	
	//Web Service Call for Bulk Recipe header output
	@HttpGet
	webservice static String WebServiceCallBulkRecipeHeader() {
        
    	RestRequest req = RestContext.request;
		map<String,String> paramMap = req.params;
		
		//input parameter
		Integer resumePoint=1;
		Boolean endOfResponse = true;
		String APIExternalID = paramMap.get('APIExternalID');
		String brandNames =  paramMap.get('brandNames');
		
		if(paramMap.get('resumePoint') != null && paramMap.get('resumePoint').trim() != ''){
			resumePoint = Integer.valueOf(paramMap.get('resumePoint'));
		}
		
		if(APIExternalID == null || APIExternalID.trim() == '') {
            return 'APIExternalID cannot be blank.';
        }
        
		if(resumePoint == null || resumePoint == 0) {
			resumePoint = 1;
		}   
        
        set<Id> setRcipeIds = new set<Id>();
        List<Id> recipeIds = new List<Id>();
        //String userRole = [SELECT UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()].UserRole.Name;
        //Query all Published_Recipe__c records where Asset__c = input parameter AND Status = Published.
        for(Published_Recipe__c publishedRecipe :[Select Recipe__c From Published_Recipe__c 
        											Where Status__c = 'Published' 
        											And Recipe__r.recordSaved__c = true
        											And Digital_Published_Asset__r.API_External_ID__c =:APIExternalID
        											order by Recipe__r.API_External_ID__c]) {
        												
        	if(!setRcipeIds.contains(publishedRecipe.Recipe__c)) {
        		//Only Admins can see Archived Recipes			
				//if (!userRole.equals('Recipe - Admin') && publishedRecipe.Recipe__r.Status__c.equals('Archive')) {
				//} else {
					recipeIds.add(publishedRecipe.Recipe__c);	
				//}
        		setRcipeIds.add(publishedRecipe.Recipe__c);	
        	}	
        }
        
        set<String> bNames = new set<String>();
        if(brandNames != null && brandNames.trim() != '') {
        	for(String str :brandNames.split(';')) {
        		bNames.add(str.trim());
        	}
        }
        
        List<Id> featuredBrandRcipeIds;
        //IF the brand parameter is provided, filter the result set down to only Recipe__c where Featured brand contains the query string.
        if(bNames != null && bNames.size() > 0) {
        	featuredBrandRcipeIds = new List<Id>();
        	setRcipeIds = new set<Id>();
        	for(Diageo_Ingredient__c featuredBrandRcipe :[Select Recipe__c From Diageo_Ingredient__c
        													Where Featured_Brand__c = true
        													And Recipe__r.recordSaved__c = true
        													And Recipe_Brand__r.Name IN :bNames
        													And Recipe__c IN :recipeIds
        													order by Recipe__r.API_External_ID__c]) {
        		
        		if(!setRcipeIds.contains(featuredBrandRcipe.Recipe__c)) {
            		featuredBrandRcipeIds.add(featuredBrandRcipe.Recipe__c);
            		setRcipeIds.add(featuredBrandRcipe.Recipe__c);	
            	}
        	}
        }
        
        recipeIds = featuredBrandRcipeIds != null ? featuredBrandRcipeIds : recipeIds;
        
        setRcipeIds = null;
        featuredBrandRcipeIds = null; 
        
        Integer newResumePoint = 499;
        
        if((resumePoint+newResumePoint) < recipeIds.size()) {
			endOfResponse = false;
		}
        return generateXML(APIExternalID, recipeIds, resumePoint, newResumePoint, endOfResponse);
	}
	
	static String generateXML(String APIExternalID, List<Id> recipeIds, Integer resumePoint, Integer newResumePoint, Boolean endOfResponse) {
		List<Id> newRecipeIds;
		//Place all Recipe__c objects contained within the result set into the XML template generated in T-104967.
		APPIRIO_GenerateXMLRecipeHeaderInfo generateXMLRecipeHeaderInfo = new APPIRIO_GenerateXMLRecipeHeaderInfo();
		
    	newRecipeIds = new List<Id>();
    	Integer cnt = 1;
    	for(Id recipeId :recipeIds) {
    		if(resumePoint <= cnt && cnt <= (resumePoint+newResumePoint)) {
    			newRecipeIds.add(recipeId);
    		}
    		cnt = cnt+1;
    	}
    	
        generateXMLRecipeHeaderInfo.recipeIds = newRecipeIds;
        generateXMLRecipeHeaderInfo.endOfResponse = endOfResponse;
        generateXMLRecipeHeaderInfo.resumePoint = resumePoint+newResumePoint+1;
    	if(endOfResponse)
    		generateXMLRecipeHeaderInfo.resumePoint = null;
    	
        //Generate the XML output.
        generateXMLRecipeHeaderInfo.generateXMLRecipeIinfo();
        //Return the XML output.
        String xmlString;
        xmlString = generateXMLRecipeHeaderInfo.xmlString;
        generateXMLRecipeHeaderInfo.xmlString = '';
        
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