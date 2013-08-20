/********************************************************************************************************************
Name        : APPIRIO_WebServiceCallBulkRecipe
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 24th Dec, 2012
Purpose     : Create Web Service Call for Bulk Recipe output.
Ref         : T-105830
              input parameters:
                1. Digital_Published_Asset__c.API_External_ID__c
            
              output:
                Query all Published_Recipe__c records where Asset__c = input parameter AND Status = Published.
                Place all Recipe__c objects contained within the result set into the XML template generated in T-104967.
                Return the XML output.
********************************************************************************************************************/
@RestResource(urlMapping='/CallBulkRecipe/*')
global with sharing class APPIRIO_WebServiceCallBulkRecipe {
    //Creating Web Service Call for Bulk Recipe output
    @HttpGet
    webservice static String WebServiceCallBulkRecipe() {
        RestRequest req = RestContext.request;
        map<String,String> paramMap = req.params;
        
        //input parameter
        Integer totalRecords = 0;
        Integer resumePoint = 1;
        Boolean endOfResponse = true;
        String APIExternalID = paramMap.get('APIExternalID');
        
        if(APIExternalID == null || APIExternalID.trim() == '') {
            return 'APIExternalID cannot be blank.';
        }
        
        if(paramMap.get('resumePoint') != null && paramMap.get('resumePoint').trim() != null){
            resumePoint = Integer.valueOf(paramMap.get('resumePoint'));
        } 
        
        if(resumePoint == null || resumePoint == 0) {
            resumePoint = 1;
        }
        
        totalRecords = [Select Count() From Published_Recipe__c 
                                            Where Status__c = 'Published' 
                                            And Recipe__r.recordSaved__c = true
                                            And Digital_Published_Asset__r.API_External_ID__c =:APIExternalID];
        
        Integer offSet = resumePoint -1;
        set<Id> setRcipeIds = new set<Id>();
        List<Id> recipeIds = new List<Id>();
        //Query all Published_Recipe__c records where Asset__c = input parameter AND Status = Published.
        List<Published_Recipe__c> lstPublishedRecipe = [Select Recipe__c From Published_Recipe__c 
                                                            Where Status__c = 'Published' 
                                                            And Recipe__r.recordSaved__c = true
                                                            And Digital_Published_Asset__r.API_External_ID__c =:APIExternalID
                                                            order by Recipe__r.API_External_ID__c limit 400 OFFSET :offSet];
        
        for(Published_Recipe__c publishedRecipe :lstPublishedRecipe) {
            if(!setRcipeIds.contains(publishedRecipe.Recipe__c)) {
                recipeIds.add(publishedRecipe.Recipe__c);
                setRcipeIds.add(publishedRecipe.Recipe__c); 
            }
        }
            
        setRcipeIds = null;
        lstPublishedRecipe = null;
        Integer newResumePoint = 299;
        
        if((resumePoint+newResumePoint) < totalRecords) {
            endOfResponse = false;
        }
        
        return generateXML(APIExternalID, recipeIds, resumePoint, newResumePoint, endOfResponse);
    }
    
    static String generateXML(String APIExternalID, List<Id> recipeIds, Integer resumePoint, Integer newResumePoint, Boolean endOfResponse) {
        List<Id> newRecipeIds;
        APPIRIO_GenerateXMLRecipeIinfo generateXMLRecipeIinfo = new APPIRIO_GenerateXMLRecipeIinfo();
        generateXMLRecipeIinfo.digitalPublishedAssetIds.add(APIExternalID);
        
        newRecipeIds = new List<Id>();
        Integer cnt = 1;
        for(Id recipeId :recipeIds) {
            if(cnt <= (newResumePoint+1)) {
                newRecipeIds.add(recipeId);
            }
            cnt = cnt+1;
        }
        generateXMLRecipeIinfo.recipeIds = newRecipeIds;
        generateXMLRecipeIinfo.endOfResponse = endOfResponse;
        
        generateXMLRecipeIinfo.resumePoint = resumePoint+newResumePoint+1;
        if(endOfResponse)
            generateXMLRecipeIinfo.resumePoint = null;
        
        //Generate the XML output.
        generateXMLRecipeIinfo.generateXMLRecipeIinfo();
        //Return the XML output.
        String xmlString;
        xmlString = generateXMLRecipeIinfo.xmlString;
        generateXMLRecipeIinfo.xmlString = '';
        
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