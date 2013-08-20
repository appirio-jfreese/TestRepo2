/*****************************************************************************
Name        : APPIRIO_GenerateXMLKeywordSearch
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 21th Jan, 2013
Purpose     : 
******************************************************************************/

public with sharing class APPIRIO_GenerateXMLKeywordSearch   {
    //public variable declaration
    public transient Boolean endOfResponse;
    public transient Integer resumePoint;
    public transient List<Id> recipeIds;
    public transient string xmlString;
    
    //private variable declaration
    private transient Integer RecipesReturned;
    private transient map<String, String> mapOZTo5Mils;
    private transient map<String, String> mapMLToOZ;
    private transient map<String, Convert_Measurements__c> mapConvertMeasurements;
    private transient map<String, ContentVersion> mapContentDisplayIDContentVersion;
    
    //Constructor of calss APPIRIO_GenerateXMLRecipeHeaderInfo
    public APPIRIO_GenerateXMLKeywordSearch() {
        xmlString = '';
        RecipesReturned = 0;
        recipeIds = new List<Id>();
    }
    
    //Grabbing/getting all the details of the recipes that is already created.
    private void grabbingRecipesInfo() {
    	set<Id> contentIds = new set<Id>(); 
	//3.26.2012-LSLEVIN-Case4405-START//
	 
	/*
        //Grabbing/getting all the details of the recipes that is already created.
        for(Recipe__c recipe :[SELECT Thumbnail_Drink_Image__r.Content_Display_ID__c 
                                      FROM Recipe__c WHERE Id IN :recipeIds And recordSaved__c = true 
                                      order by API_External_ID__c]) {
            contentIds.add(recipe.Thumbnail_Drink_Image__r.Content_Display_ID__c);
        }
        
        mapContentDisplayIDContentVersion = new map<String, ContentVersion>();
        //Query all ContentVersion records where ContentDocumentId = input parameter
        for(ContentVersion contentVersion :[Select FileType, VersionData, Title, ContentDocumentId 
        											From ContentVersion
        											Where contentVersion.ContentDocumentId IN :contentIds]) {
            mapContentDisplayIDContentVersion.put(contentVersion.ContentDocumentId, contentVersion);
        }
       */
        //Added Main_Drink__Image__r.Content_Display_ID__c to query below 
        //Grabbing/getting all the details of the recipes that is already created.
        for(Recipe__c recipe :[SELECT Main_Drink_Image__r.Content_Display_ID__c 
                                      FROM Recipe__c WHERE Id IN :recipeIds And recordSaved__c = true 
                                      order by API_External_ID__c]) {
            contentIds.add(recipe.Main_Drink_Image__r.Content_Display_ID__c);
        }
        
        mapContentDisplayIDContentVersion = new map<String, ContentVersion>();
        //Query all ContentVersion records where ContentDocumentId = input parameter
        for(ContentVersion contentVersion :[Select FileType, VersionData, Title, ContentDocumentId 
        											From ContentVersion
        											Where contentVersion.ContentDocumentId IN :contentIds]) {
            mapContentDisplayIDContentVersion.put(contentVersion.ContentDocumentId, contentVersion);
        }
        contentIds = null;
        
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
    
	// Pass in the endpoint to be used using the string url
  	public String getContent(String url) {
	
		// Instantiate a new http object
   		Http h = new Http();

		// Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    	HttpRequest req = new HttpRequest();
    	req.setEndpoint(url);
    	req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
   		req.setMethod('GET');

		// Send the request, and return a response
   		HttpResponse res = h.send(req);
    	return res.getBody();
	}
    
    //Generating an XML with Recipe info.
    public void generateXMLRecipeIinfo() {
    	
    	grabbingRecipesInfo();
    	
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartDocument(null,'1.0');
        
        //recipes
        w.writeStartElement(null,'recipes',null);
		//Added Main_Drink__Image__r.Content_Display_ID__c and Main_Drink_Image__c to query below
		//Removed Thumbnail_Drink_Image__c, Thumbnail_Drink_Image__r.Content_Display_ID__c
		//Limit the Recipe query to only return 10 recipes so that we do not hit the Call Out Limit
        for(Recipe__c recipe :[SELECT API_External_ID__c, LastModifiedDate, NEO_Recipe_Id__c, Name, Id, Recipe_Title__c, Locale__c, 
                                      Main_Drink_Image__c,Main_Drink_Image__r.Content_Display_ID__c
                                      ,(select id, API_External_ID__c,Ingredient_Number__c, Quantity__c,Ingredient_Unit__c,Featured_Brand__c,
                                      Recipe_Brand__c,Recipe_Brand__r.Name,Recipe_Brand__r.API_External_ID__c,Recipe_Brand__r.Locale__c, 
                                      Recipe_Diageo_Product__r.Name,Recipe_Diageo_Product__r.API_External_ID__c,Recipe_Diageo_Product__r.Locale__c 
                                      from Diageo_Ingredients__r order by Ingredient_Number__c)
                                      FROM Recipe__c WHERE Id IN :recipeIds And recordSaved__c = true order by API_External_ID__c limit 10]) {
            
            RecipesReturned +=1;
            string str;
            
            //recipes
            w.writeStartElement(null,'recipe',null);
                if(recipe.API_External_ID__c != null)   
                    w.writeAttribute(null, null, 'sfRecipeId', recipe.API_External_ID__c);
                else
                    w.writeAttribute(null, null, 'sfRecipeId', '');
                
                if(recipe.NEO_Recipe_Id__c != null)
                    w.writeAttribute(null, null, 'neoRecipeId', recipe.NEO_Recipe_Id__c+'');
                else
                    w.writeAttribute(null, null, 'neoRecipeId', '');
                    
                if(recipe.Locale__c != null)
                    w.writeAttribute(null, null, 'Locale', recipe.Locale__c);
                else
                    w.writeAttribute(null, null, 'Locale', '');
                    
                //lastModified
                w.writeStartElement(null,'lastModified',null);
                    w.writeCharacters(String.valueOf(recipe.LastModifiedDate));
                w.writeEndElement();
                //end of lastModified
                
                //recipeTitle
                w.writeStartElement(null,'recipeTitle',null);
                    w.writeCharacters(recipe.Recipe_Title__c);
                w.writeEndElement();
                //end of recipeTitle
                
                //featuredIngredient
                w.writeStartElement(null,'featuredIngredient',null);
                    for(Diageo_Ingredient__c diageoIngredient: recipe.Diageo_Ingredients__r){
                        if(diageoIngredient.Featured_Brand__c) {
                            w.writeStartElement(null,'featuredBrand',null);
                                
                                if(diageoIngredient.Recipe_Brand__r.API_External_ID__c != null)
                                    w.writeAttribute(null, null, 'id', diageoIngredient.Recipe_Brand__r.API_External_ID__c);
                                else
                                    w.writeAttribute(null, null, 'id', '');
                                
                                system.debug('===================Recipe Brand Locale: '+ diageoIngredient.Recipe_Brand__r.Locale__c);    
                                if(diageoIngredient.Recipe_Brand__r.Locale__c != null)
                                    w.writeAttribute(null, null, 'Locale', diageoIngredient.Recipe_Brand__r.Locale__c);
                                else
                                    w.writeAttribute(null, null, 'Locale', '');
                                
                                if(diageoIngredient.Recipe_Brand__r.Name != null)
                                    w.writeCharacters(diageoIngredient.Recipe_Brand__r.Name);
                                    
                            w.writeEndElement();
                            w.writeStartElement(null,'featuredProduct',null);
                                if(diageoIngredient.Recipe_Diageo_Product__r.API_External_ID__c != null)
                                    w.writeAttribute(null, null, 'id', diageoIngredient.Recipe_Diageo_Product__r.API_External_ID__c);
                                else
                                    w.writeAttribute(null, null, 'id', '');
                                    
                                system.debug('===================Recipe Brand Locale: '+ diageoIngredient.Recipe_Diageo_Product__r.Locale__c);    
                                if(diageoIngredient.Recipe_Diageo_Product__r.Locale__c != null)
                                    w.writeAttribute(null, null, 'Locale', diageoIngredient.Recipe_Diageo_Product__r.Locale__c);
                                else
                                    w.writeAttribute(null, null, 'Locale', '');
                                    
                                if(diageoIngredient.Recipe_Diageo_Product__r.Name != null)
                                    w.writeCharacters(diageoIngredient.Recipe_Diageo_Product__r.Name);
                            w.writeEndElement();
                        }
                    }
                w.writeEndElement();
                //end of featuredIngredient
                
                //Recipe Thumbnail Drink Image
                w.writeStartElement(null,'RecipeThumbnailDrinkImage',null);
                
                    //image-ThumbnailDrink
                   // if(recipe.Thumbnail_Drink_Image__c != null && recipe.Thumbnail_Drink_Image__r.Content_Display_ID__c != null) {
                    if(recipe.Main_Drink_Image__c != null && recipe.Main_Drink_Image__r.Content_Display_ID__c != null) {
                    		
                       // ContentVersion contentVersion = mapContentDisplayIDContentVersion.get(recipe.Thumbnail_Drink_Image__r.Content_Display_ID__c);
                      	ContentVersion contentVersion = mapContentDisplayIDContentVersion.get(recipe.Main_Drink_Image__r.Content_Display_ID__c);
                        //Added by LSLEVIN
                        if(URL.getSalesforceBaseUrl().toExternalForm()!=null && contentVersion!=null){ // Added by Rahul on 11th April
                        String thumbNailUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v24.0/chatter/files/'+ contentVersion.ContentDocumentId + '/rendition?type=THUMB120BY90';
                		String renditionUrl = '';
   						renditionUrl = getContent(thumbNailUrl);						
                		Blob thumbNailRendition = blob.valueOf(renditionUrl);
                        if(contentVersion != null) {
                            //image
                            w.writeStartElement(null,'image',null);
                                w.writeAttribute(null, null, 'ContentDisplayID', contentVersion.ContentDocumentId);
                                if(contentVersion.Title != null)
                                    w.writeAttribute(null, null, 'fileName', contentVersion.Title+'.'+contentVersion.FileType.toLowerCase());
                                else
                                    w.writeAttribute(null, null, 'fileName', '');
                                if(contentVersion.VersionData != null)
                                    //w.writeCharacters(EncodingUtil.base64Encode(contentVersion.VersionData));
                                    w.writeCharacters(EncodingUtil.base64Encode(thumbNailRendition));
		//Case - 4405-END                                    
                            w.writeEndElement();
                            //end of image
                        }
                        }
                    }
                    //end of image-ThumbnailDrink
                    
                w.writeEndElement();
                //end of Recipe Thumbnail Drink Image
                
                //diageoIngredients
                w.writeStartElement(null,'diageoIngredients',null);
                    for(Diageo_Ingredient__c diageoIngredient: recipe.Diageo_Ingredients__r){
                        if(diageoIngredient.Recipe_Diageo_Product__r.Name != null) {
                            //diageoIngredient
                            w.writeStartElement(null,'diageoIngredient',null);
                                w.writeAttribute(null, null, 'id', ''+diageoIngredient.Recipe_Diageo_Product__r.API_External_ID__c);
                                
                                system.debug('===================Recipe Brand Locale 1: '+ diageoIngredient.Recipe_Diageo_Product__r.Locale__c);    
                                if(diageoIngredient.Recipe_Diageo_Product__r.Locale__c != null)
                                    w.writeAttribute(null, null, 'Locale', diageoIngredient.Recipe_Diageo_Product__r.Locale__c);
                                else
                                    w.writeAttribute(null, null, 'Locale', '');
                                    
                                //name
                                w.writeStartElement(null,'name',null);
                                    w.writeCharacters(diageoIngredient.Recipe_Diageo_Product__r.Name);
                                w.writeEndElement();
                                //end of name
                                
                                //quantity
                                w.writeStartElement(null,'quantity',null);
                                    if(diageoIngredient.Quantity__c != null)
                                        w.writeCharacters(diageoIngredient.Quantity__c);
                                w.writeEndElement();
                                //end of quantity
                                
                                //units
                                w.writeStartElement(null,'units',null);
                                    if(diageoIngredient.Ingredient_Unit__c != null)
                                        w.writeCharacters(diageoIngredient.Ingredient_Unit__c);
                                w.writeEndElement();
                                //end of units
                                
                                if(diageoIngredient.Ingredient_Unit__c != null && diageoIngredient.Ingredient_Unit__c.equals('oz.')) {
                                    //ozquantity
                                    w.writeStartElement(null,'ozquantity',null);
                                        if(diageoIngredient.Quantity__c != null)
                                            w.writeCharacters(diageoIngredient.Quantity__c);
                                    w.writeEndElement();
                                    //end of ozquantity
                                    
                                    //mlquantity
                                    w.writeStartElement(null,'mlquantity',null);
                                        if(mapOZTo5Mils.get(diageoIngredient.Quantity__c) != null)
                                            w.writeCharacters(mapOZTo5Mils.get(diageoIngredient.Quantity__c));
                                    w.writeEndElement();
                                    //end of mlquantity
                                } else if(diageoIngredient.Ingredient_Unit__c != null && diageoIngredient.Ingredient_Unit__c.equals('ml.')) {
                                    //mlquantity
                                    w.writeStartElement(null,'mlquantity',null);
                                        if(diageoIngredient.Quantity__c != null)
                                            w.writeCharacters(diageoIngredient.Quantity__c);
                                    w.writeEndElement();
                                    //end of mlquantity
                                    
                                    //ozquantity
                                    w.writeStartElement(null,'ozquantity',null);
                                        if(mapMLToOZ.get(diageoIngredient.Quantity__c) != null)
                                            w.writeCharacters(mapMLToOZ.get(diageoIngredient.Quantity__c));
                                    w.writeEndElement();
                                    //end of ozquantity
                                } else {
                                    //ozquantity
                                    w.writeStartElement(null,'ozquantity',null);
                                    w.writeEndElement();
                                    //end of ozquantity
                                    
                                    //mlquantity
                                    w.writeStartElement(null,'mlquantity',null);
                                    w.writeEndElement();
                                    //end of mlquantity
                                }
                                
                                //featured
                                w.writeStartElement(null,'featured',null);
                                    if(diageoIngredient.Featured_Brand__c != null)
                                        w.writeCharacters(diageoIngredient.Featured_Brand__c+'');
                                w.writeEndElement();
                                //end of featured
                                
                                //brand
                                w.writeStartElement(null,'brand',null);
                                    if(diageoIngredient.Recipe_Brand__r.API_External_ID__c != null)
                                        w.writeAttribute(null, null, 'id', diageoIngredient.Recipe_Brand__r.API_External_ID__c);
                                    else
                                        w.writeAttribute(null, null, 'id', '');
                                    
                                    system.debug('===================Recipe Brand Locale 1: '+ diageoIngredient.Recipe_Brand__r.Locale__c);
                                    if(diageoIngredient.Recipe_Brand__r.Locale__c != null)
	                                    w.writeAttribute(null, null, 'Locale', diageoIngredient.Recipe_Brand__r.Locale__c);
	                                else
	                                    w.writeAttribute(null, null, 'Locale', '');
	                                        
                                    if(diageoIngredient.Recipe_Brand__r.Name != null)
                                        w.writeCharacters(diageoIngredient.Recipe_Brand__r.Name);
                                        
                                w.writeEndElement();
                                //end of brand
                                
                            w.writeEndElement();
                            //end of diageoIngredient
                        }
                    }
                w.writeEndElement();
                //end of diageoIngredients
                
            w.writeEndElement();    
            //end of recipe
        }
        
        //endOfResponse
        w.writeStartElement(null,'endOfResponse',null);
        	if (endOfResponse != null && endOfResponse)
        		w.writeCharacters('TRUE');
        	else
        		w.writeCharacters('FALSE');
        w.writeEndElement();
		//end of endOfResponse
		
		//RecipesReturned
        w.writeStartElement(null,'RecipesReturned',null);
        	w.writeCharacters(RecipesReturned +'');
        w.writeEndElement();
		//end of RecipesReturned
		
		//resumePoint
        w.writeStartElement(null,'resumePoint',null);
        	if(resumePoint != null)
        		w.writeCharacters(resumePoint + '');
        	else
        		w.writeCharacters('False');
        w.writeEndElement();
		//end of resumePoint
			
        w.writeEndElement();    
        //end of recipes
        w.writeEndDocument();
        xmlString = w.getXmlString();
        system.debug('===================xmlString: '+ xmlString);
        w.close();
        
        mapContentDisplayIDContentVersion = null;
        mapOZTo5Mils = null;
        mapMLToOZ = null;
    }
}