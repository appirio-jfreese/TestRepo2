/********************************************************************************************************************
Name        : APPIRIO_WebServiceCallPubledLastModified
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 28th Dec, 2012
Purpose     : Create Web Service Call for Published Status Last modified Date.
Ref         : T-105833
			  input parameters:
				1. Digital_Published_Asset__c.API_External_ID__c
				2. Date
			
			  output:
				- Query all Published_Recipe__c records where Asset__c = input parameter AND LastModifiedDate >= Date input parameter.
				- Place all Recipe__c objects contained within the result set into the XML template generated in T-104967.
				- Add tag to XML: <publishedStatus>. Value in tag = Published_Recipe__c.Status__c
				- Return the XML output.
********************************************************************************************************************/
@RestResource(urlMapping='/CallPubledLastModified/*')
global with sharing class APPIRIO_WebServiceCallPubledLastModified {
	//Web Service Call for Published Status Last modified Date
	@HttpGet
	webservice static String WebServiceCallPublishedLastModified() {
        
    	RestRequest req = RestContext.request;
		map<String,String> paramMap = req.params;
		
		//input parameter
		Integer totalRecords = 0;
		Boolean endOfResponse = true;
		Integer resumePoint=1;
    	Integer year;
    	Integer month;
    	Integer day;
    	Date lastModified;
    	
    	String APIExternalID = paramMap.get('APIExternalID');
    	if(APIExternalID == null || APIExternalID.trim() == '') {
            return 'APIExternalID cannot be blank.';
        }
        
        if(paramMap.get('year') != null) {
    		year = Integer.valueOf(paramMap.get('year'));
    	}
    	if(paramMap.get('month') != null) {
    		month = Integer.valueOf(paramMap.get('month'));
    	}
    	if(paramMap.get('day') != null) {
    		day = Integer.valueOf(paramMap.get('day'));
    	}
    	
    	if(year == null || month == null || day == null) {
    		return 'Last modified date cannot be invalid or blank.';
    	}
    	
    	lastModified = date.newInstance(year, month, day);
        
        if(lastModified == null) {
            return 'Last modified date is not valid.';
        }   
        
        if(paramMap.get('resumePoint') != null && paramMap.get('resumePoint').trim() != null){
			resumePoint = Integer.valueOf(paramMap.get('resumePoint'));
		} 
        if(resumePoint == null || resumePoint == 0) {
			resumePoint = 1;
		}
        
        totalRecords = [Select Count() From Published_Recipe__c 
	                                    Where Recipe__r.recordSaved__c = true
	                                    And LastModifiedDate >= :lastModified
	                                    And Digital_Published_Asset__r.API_External_ID__c =:APIExternalID];
		
		Integer offSet = resumePoint -1;
        set<Id> setRcipeIds = new set<Id>();
        List<Id> recipeIds = new List<Id>();
        //Query all Published_Recipe__c records where Asset__c = input parameter AND LastModifiedDate >= lastModified.
        List<Published_Recipe__c> lstPublishedRecipe = [Select Recipe__c From Published_Recipe__c 
	                                                        Where Recipe__r.recordSaved__c = true
						                                    And LastModifiedDate >= :lastModified
						                                    And Digital_Published_Asset__r.API_External_ID__c =:APIExternalID
	                                                        order by Recipe__r.API_External_ID__c limit 500 OFFSET :offSet];
		
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
        
        return generateXML(APIExternalID, recipeIds, resumePoint, newResumePoint, endOfResponse);
    }
    
    static String generateXML(String APIExternalID, List<Id> recipeIds, Integer resumePoint, Integer newResumePoint, Boolean endOfResponse) {
		List<Id> newRecipeIds;
		//Place all Recipe__c objects contained within the result set into the XML template generated in T-104967.
		APPIRIO_GenerateXMLRecipeLstModifiedInfo generateXMLRecipeLstModifiedInfo = new APPIRIO_GenerateXMLRecipeLstModifiedInfo();
		generateXMLRecipeLstModifiedInfo.digitalPublishedAssetIds.add(APIExternalID);
		
    	newRecipeIds = new List<Id>();
    	Integer cnt = 1;
    	for(Id recipeId :recipeIds) {
    		if(cnt <= (newResumePoint+1)) {
    			newRecipeIds.add(recipeId);
    		}
    		cnt = cnt+1;
    	}
    	
        generateXMLRecipeLstModifiedInfo.recipeIds = newRecipeIds;
        generateXMLRecipeLstModifiedInfo.endOfResponse = endOfResponse;
        generateXMLRecipeLstModifiedInfo.resumePoint = resumePoint+newResumePoint+1;
    	if(endOfResponse)
    		generateXMLRecipeLstModifiedInfo.resumePoint = null;
    	
        //Generate the XML output.
        generateXMLRecipeLstModifiedInfo.generateXMLRecipeIinfo();
        //Return the XML output.
        String xmlString;
        xmlString = generateXMLRecipeLstModifiedInfo.xmlString;
        generateXMLRecipeLstModifiedInfo.xmlString = '';
        
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