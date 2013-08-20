/********************************************************************************************************************
Name        : APPIRIO_WebServiceCallIndividualRecipe
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 26th Dec, 2012
Purpose     : Create Web Service Call for Individual Recipe output.
Ref         : T-105834
			  input parameters:
				1. Digital_Published_Asset__c.API_External_ID__c
				2. Recipe__c.API_External_ID__c   -OR-    Recipe__c Salesforce ID
			
			  output:
				Query all Published_Recipe__c records where Asset__c = input parameter AND Status = Published AND Recipe__c = Recipe input parameter.
				Place all Recipe__c objects contained within the result set into the XML template generated in T-104967.
				Return the XML output.
				
			 Note: (Ref:S-81938) By "Will Price on 2nd Jan 2013"
			 "Please remove the check for whether the recipe is published for an Asset. 
			 The single input parameter will be the Recipe API External ID, and the matching recipe will always be returned."
			 
			 Note: (Ref:T-110317) By "Will Price on 22nd Jan 2013"
			 "The status on the Published_Occasion__c should = Published. Also, please add this logic onto the Individual Recipe Web Service Call, 
			 and add Asset ID as the first input parameter."
			 
			 Note: (Ref:T-105834) By "Will Price on 22nd Jan 2013"
			 "All Recipe__c records where API_External_ID = input parameter. Do NOT check Published_Recipe__c. 
			  When filling in the <occasion> tags on the return XML, query Published_Occasion__c for the Asset ID parameter, 
			  and only include the occasions found in that junction object."
********************************************************************************************************************/
@RestResource(urlMapping='/CallIndividualRecipe/*')
global with sharing class APPIRIO_WebServiceCallIndividualRecipe {
	//Creating Web Service Call for Individual Recipe output.
	@HttpGet
	webservice static String WebServiceCallIndividualRecipe(){
	//webservice static String WebServiceCallIndividualRecipe(String RecipeAPIExternalID){
        try{
        	RestRequest req = RestContext.request;
			map<String,String> paramMap = req.params;
        	
        	//input parameter
			String APIExternalID = paramMap.get('APIExternalID');
			String RecipeAPIExternalID = paramMap.get('RecipeAPIExternalID');
			
            if(APIExternalID == null || APIExternalID.trim() == '') {
                return 'APIExternalID cannot be blank.';
            }
            if(RecipeAPIExternalID == null || RecipeAPIExternalID.trim() == '') {
                return 'Recipe APIExternalID cannot be blank.';
            }   
            
            List<Id> recipeIds = new List<Id>();
            //Query all Published_Recipe__c records where Asset__c = input parameter AND Status = Published 
            //AND Recipe__c.API_External_ID__c = RecipeAPIExternalID input parameter.
            /*
            for(Published_Recipe__c publishedRecipe :[Select Recipe__c From Published_Recipe__c 
            											Where Status__c = 'Published'
            											And Digital_Published_Asset__c =:APIExternalID
            											And Recipe__r.API_External_ID__c =:RecipeAPIExternalID]) {
            	recipeIds.add(publishedRecipe.Recipe__c);
            }*/
            
            //Note: (Ref:S-81938) By "Will Price on 2nd Jan 2013"
			//"Please remove the check for whether the recipe is published for an Asset. 
			//The single input parameter will be the Recipe API External ID, and the matching recipe will always be returned."
            //Query Recipe__c record where API_External_ID__c = input parameter.
            for(Recipe__c recipe :[Select Id From Recipe__c Where API_External_ID__c =:RecipeAPIExternalID order by API_External_ID__c]) {
            	recipeIds.add(recipe.Id);
            }
            
            //Place all Recipe__c objects contained within the result set into the XML template generated in T-104967.
			APPIRIO_GenerateXMLRecipeIinfo generateXMLRecipeIinfo = new APPIRIO_GenerateXMLRecipeIinfo();
			generateXMLRecipeIinfo.digitalPublishedAssetIds.add(APIExternalID);
            generateXMLRecipeIinfo.recipeIds = recipeIds;
            generateXMLRecipeIinfo.endOfResponse = true;
            generateXMLRecipeIinfo.generateXMLRecipeIinfo();
            //Return the XML output.
            return generateXMLRecipeIinfo.xmlString;
            
        }catch(Exception ex){
            return ex.getMessage(); 
        }
    }
}