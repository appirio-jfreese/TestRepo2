/********************************************************************************************************************
Name        : APPIRIO_GenerateXMLRecipeIinfo
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 18th dec, 2012
Purpose     : 
Ref         : T-104967
              Create a new class which will generate an XML with Recipe info.
              
              T-110317
              Update All Web Services Calls which return Occasions to filter based on Published_Occasion__c
********************************************************************************************************************/
public with sharing class APPIRIO_GenerateXMLRecipeIinfo {
    
    //public variable declaration
    public transient Boolean endOfResponse;
    public transient Integer resumePoint;
    public transient List<Id> recipeIds;
    public transient set<String> digitalPublishedAssetIds;
    public transient string xmlString;
    
    //private variable declaration
    private transient Integer RecipesReturned;
    private transient set<string> setAttributes;
    private transient set<string> setDynamicAttributes;
    private transient map<String, String> mapOZTo5Mils;
    private transient map<String, String> mapMLToOZ;
    private transient map<String, Convert_Measurements__c> mapConvertMeasurements;
    private transient map<String, ContentVersion> mapContentDisplayIDContentVersion;
        
    //Constructor of calss APPIRIO_GenerateXMLRecipeIinfo
    public APPIRIO_GenerateXMLRecipeIinfo() {
        xmlString = '';
        RecipesReturned = 0;
        recipeIds = new List<Id>();
        digitalPublishedAssetIds = new set<String>();
        
        mapContentDisplayIDContentVersion = new map<String, ContentVersion>();
        //Query all ContentVersion records where ContentDocumentId = input parameter
        for(ContentVersion contentVersion :[Select FileType, Title, ContentDocumentId 
        											From ContentVersion]) {
            mapContentDisplayIDContentVersion.put(contentVersion.ContentDocumentId, contentVersion);
        }
        
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
        
        setAttributes = new set<string>();
        setDynamicAttributes = new set<string>();
        for(Attribute__c attribute :[Select Attribute_Type__c, Dynamic__c From Attribute__c]){
            if(attribute.Dynamic__c) 
                setDynamicAttributes.add(attribute.Attribute_Type__c);
            else
                setAttributes.add(attribute.Attribute_Type__c);
        }
    }
    
    //Generating an XML with Recipe info.
    public void generateXMLRecipeIinfo() {
    	
        set<Id> occasionIds = new set<Id>();
        
        if(digitalPublishedAssetIds.size() > 0){
        	for(Published_Occasion__c publishedOccasion :[Select Occasion__c From Published_Occasion__c 
        													  Where Status__c='Published' And Digital_Published_Asset__r.API_External_ID__c IN :digitalPublishedAssetIds]){
				occasionIds.add(publishedOccasion.Occasion__c);
			}	
        } else {
        	for(Occasion__c occasion :[Select Id From Occasion__c]){
				occasionIds.add(occasion.Id);
			}
        }
        
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartDocument(null,'1.0');
        
        //recipes
        w.writeStartElement(null,'recipes',null);
        
        for(Recipe__c recipe : [SELECT API_External_ID__c, LastModifiedDate, NEO_Recipe_Id__c, Recipe_Tag__c, Name, Id, Recipe_Title__c, Locale__c, 
                                      Additional_Image_1__c, Additional_Image_1__r.Content_Display_ID__c, 
                                      Additional_Image_2__c, Additional_Image_2__r.Content_Display_ID__c,
                                      Additional_Image_3__c, Additional_Image_3__r.Content_Display_ID__c,
                                      Additional_Image_4__c, Additional_Image_4__r.Content_Display_ID__c,
                                      Additional_Image_5__c, Additional_Image_5__r.Content_Display_ID__c,
                                      Background_Image__c, Background_Image__r.Content_Display_ID__c,
                                      Brand_Recipe_Image__c, Brand_Recipe_Image__r.Content_Display_ID__c,
                                      Main_Drink_Image__c, Main_Drink_Image__r.Content_Display_ID__c,  
                                      Main_Ingredient_Image__c, Main_Ingredient_Image__r.Content_Display_ID__c,
                                      Mobile_Selected_Image__c, Mobile_Selected_Image__r.Content_Display_ID__c,
                                      Mobile_Unselected_Image__c, Mobile_Unselected_Image__r.Content_Display_ID__c,
                                      Mobile_Drink_Image__c, Mobile_Drink_Image__r.Content_Display_ID__c,
                                      Search_Recipe_Image__c, Search_Recipe_Image__r.Content_Display_ID__c,
                                      Thumbnail_Drink_Image__c, Thumbnail_Drink_Image__r.Content_Display_ID__c
                                      ,(select id, Attribute__r.Attribute_Type__c,Attribute__r.Attribute_Value__c, Dynamic_Value__c, Attribute__r.Locale__c, Attribute__r.API_External_ID__c from Recipe_Attributes__r) 
                                      ,(select id, Occasion__r.API_External_ID__c,Occasion__r.Name_Of_The_Occasion__c, Occasion__r.Locale__c, Occasion__r.Occasion_Tags__c from Recipe_Occasions__r where Occasion__c IN:occasionIds)
                                      ,(select id, API_External_ID__c,Ingredient_Number__c, Quantity__c,Ingredient_Unit__c,Featured_Brand__c,
                                      	Recipe_Brand__c,Recipe_Brand__r.Name,Recipe_Brand__r.API_External_ID__c,Recipe_Brand__r.Locale__c, 
                                      	Recipe_Diageo_Product__r.Name, Recipe_Diageo_Product__r.API_External_ID__c, Recipe_Diageo_Product__r.Locale__c, 
                                      	Recipe_Non_Diageo_Product__r.Name, Recipe_Non_Diageo_Product__r.Locale__c, Recipe_Non_Diageo_Product__r.API_External_ID__c 
                                      	from Diageo_Ingredients__r order by Ingredient_Number__c)
                                      ,(select Step_Number__c,Description__c from Preparation_Steps__r order by Step_Number__c)
                                      FROM Recipe__c WHERE Id IN :recipeIds  And recordSaved__c = true order by API_External_ID__c]) {
        	
        	
        	RecipesReturned +=1;
        	string str;
            map<string,List<string>> mapAttributeTypeValues = new map<string,List<string>>();
            map<string,string> mapAttributeTypeDynamicValues = new map<string,string>();
            map<string,Recipe_Attribute__c> mapAttributeTypeValueRecipeAttribute = new map<string,Recipe_Attribute__c>();
            
            for(Recipe_Attribute__c recipeAttribute :recipe.Recipe_Attributes__r) {
                if(!mapAttributeTypeValues.containsKey(recipeAttribute.Attribute__r.Attribute_Type__c)) {
                    mapAttributeTypeValues.put(recipeAttribute.Attribute__r.Attribute_Type__c, new List<string>());
                }
                mapAttributeTypeValues.get(recipeAttribute.Attribute__r.Attribute_Type__c).add(recipeAttribute.Attribute__r.Attribute_Value__c);
                
                String key = recipeAttribute.Attribute__r.Attribute_Type__c.trim();
                key += recipeAttribute.Attribute__r.Attribute_Value__c != null ? recipeAttribute.Attribute__r.Attribute_Value__c.trim() : '';
                mapAttributeTypeValueRecipeAttribute.put(key,recipeAttribute);
                
                if(recipeAttribute.Dynamic_Value__c != null && recipeAttribute.Attribute__r.Attribute_Type__c != null)
                    mapAttributeTypeDynamicValues.put(recipeAttribute.Attribute__r.Attribute_Type__c, recipeAttribute.Dynamic_Value__c);
            }
            
            //recipe
            w.writeStartElement(null,'recipe',null);
                if(recipe.API_External_ID__c != null)   
                    w.writeAttribute(null, null, 'sfRecipeId', recipe.API_External_ID__c);
                else
                    w.writeAttribute(null, null, 'sfRecipeId', '');
                
                if(recipe.NEO_Recipe_Id__c != null)
                    w.writeAttribute(null, null, 'neoRecipeId', recipe.NEO_Recipe_Id__c);
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
                    for(Diageo_Ingredient__c diageoIngredient: recipe.Diageo_Ingredients__r) {
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
                
                //attributes
                w.writeStartElement(null,'attributes',null);
                    
                    for(string attribute :setAttributes) {
                        //Attribute Types
                        str = attribute.replaceAll(' ', '');
                        str = str.replaceAll('/', '');
                        w.writeStartElement(null,str+'s',null);
                            if(mapAttributeTypeValues.get(attribute) != null) {
                            	for(string dc: mapAttributeTypeValues.get(attribute)) {
                            		Recipe_Attribute__c recipeAttribute = mapAttributeTypeValueRecipeAttribute.get(attribute.trim()+dc.trim());
                                    //attribute
                                    w.writeStartElement(null,str,null);
                                    	if(recipeAttribute != null) {
                                    		w.writeAttribute(null, null, 'id', recipeAttribute.Attribute__r.API_External_ID__c);
                                    		w.writeAttribute(null, null, 'Locale', recipeAttribute.Attribute__r.Locale__c);
                                    	} else {
                                    		w.writeAttribute(null, null, 'id', '');
                                			w.writeAttribute(null, null, 'Locale', '');
                                    	}
                                        w.writeCharacters(dc);
                                    w.writeEndElement();
                                    //end of attribute          
                                }
                            } else {
                                //attribute
                                w.writeStartElement(null,str,null);
                                w.writeAttribute(null, null, 'id', '');
                                w.writeAttribute(null, null, 'Locale', '');
                                w.writeEndElement();
                                //end of attribute
                            }
                        w.writeEndElement();
                        //end of Attribute Types
                    }
                    
                    for(string dynamicAttribute :setDynamicAttributes) {
                        //dynamicAttribute
                        str = dynamicAttribute.replaceAll(' ', '');
                        str = str.replaceAll('/', '');
                        w.writeStartElement(null,str,null);
                        	Recipe_Attribute__c recipeAttribute = mapAttributeTypeValueRecipeAttribute.get(str.trim());
	                        	if(recipeAttribute != null) {
	                        		w.writeAttribute(null, null, 'id', recipeAttribute.Attribute__r.API_External_ID__c);
	                        		w.writeAttribute(null, null, 'Locale', recipeAttribute.Attribute__r.Locale__c);
	                        	} else {
	                        		w.writeAttribute(null, null, 'id', '');
	                    			w.writeAttribute(null, null, 'Locale', '');
	                        	}
	                        if(mapAttributeTypeDynamicValues.get(dynamicAttribute) != null)
                                w.writeCharacters(mapAttributeTypeDynamicValues.get(dynamicAttribute));
                        w.writeEndElement();
                        //end of dynamicAttribute
                    }
                    
                    //tags
                    w.writeStartElement(null,'RecipeTags',null);
                        if(recipe.Recipe_Tag__c != null)
                            w.writeCharacters(recipe.Recipe_Tag__c);
                    w.writeEndElement();
                    //end of tags
                
                w.writeEndElement();
                //end of attributes
                
                //occasions
                w.writeStartElement(null,'occasions',null);
                    for(Recipe_Occasion__c recipeOccasion: recipe.Recipe_Occasions__r){
                        //occasion
                        w.writeStartElement(null,'occasion',null);
                        	w.writeAttribute(null, null, 'id', ''+recipeOccasion.Occasion__r.API_External_ID__c);
                        	w.writeAttribute(null, null, 'Locale', ''+recipeOccasion.Occasion__r.Locale__c);	
                            w.writeCharacters(recipeOccasion.Occasion__r.Name_Of_The_Occasion__c);
                        w.writeEndElement();
                        //end of occasion
                        
                        //tags
	                    w.writeStartElement(null,'tags',null);
	                        if(recipeOccasion.Occasion__r.Occasion_Tags__c != null)
	                            w.writeCharacters(recipeOccasion.Occasion__r.Occasion_Tags__c);
	                    w.writeEndElement();
	                    //end of tags
                    }
                w.writeEndElement();
                //end of occasions
                
                //images
                w.writeStartElement(null,'images',null);
                	ContentVersion contentVersion;
                    //image-MainDrink
                    if(recipe.Main_Drink_Image__c != null && recipe.Main_Drink_Image__r.Content_Display_ID__c != null) {
                    	contentVersion = mapContentDisplayIDContentVersion.get(recipe.Main_Drink_Image__r.Content_Display_ID__c);
	                    w.writeStartElement(null,'image',null);
	                        w.writeAttribute(null, null, 'imageType', 'MainDrink');
	                        w.writeAttribute(null, null, 'sfImageAssetId', recipe.Main_Drink_Image__r.Content_Display_ID__c);
	                        if(contentVersion != null && contentVersion.Title != null)
		                    	w.writeAttribute(null, null, 'fileName', contentVersion.Title+'.'+contentVersion.FileType.toLowerCase());
		                    else
		                    	w.writeAttribute(null, null, 'fileName', '');
	                    w.writeEndElement();
                    }
                    //end of image-MainDrink
                    
                    //image-Thumbnail
                    if(recipe.Thumbnail_Drink_Image__c != null && recipe.Thumbnail_Drink_Image__r.Content_Display_ID__c != null) {
                    	contentVersion = mapContentDisplayIDContentVersion.get(recipe.Thumbnail_Drink_Image__r.Content_Display_ID__c);
	                    w.writeStartElement(null,'image',null);
	                        w.writeAttribute(null, null, 'imageType', 'Thumbnail');
	                        w.writeAttribute(null, null, 'sfImageAssetId', recipe.Thumbnail_Drink_Image__r.Content_Display_ID__c);
	                        if(contentVersion != null && contentVersion.Title != null)
		                    	w.writeAttribute(null, null, 'fileName', contentVersion.Title+'.'+contentVersion.FileType.toLowerCase());
		                    else
		                    	w.writeAttribute(null, null, 'fileName', '');
	                    w.writeEndElement();
                    }
                    //end of image-Thumbnail
                    
                    //image-SearchImage
                    if(recipe.Search_Recipe_Image__c != null && recipe.Search_Recipe_Image__r.Content_Display_ID__c != null) {
                    	contentVersion = mapContentDisplayIDContentVersion.get(recipe.Search_Recipe_Image__r.Content_Display_ID__c);
	                    w.writeStartElement(null,'image',null);
	                        w.writeAttribute(null, null, 'imageType', 'SearchImage');
	                        w.writeAttribute(null, null, 'sfImageAssetId', recipe.Search_Recipe_Image__r.Content_Display_ID__c);
	                        if(contentVersion != null && contentVersion.Title != null)
		                    	w.writeAttribute(null, null, 'fileName', contentVersion.Title+'.'+contentVersion.FileType.toLowerCase());
		                    else
		                    	w.writeAttribute(null, null, 'fileName', '');
	                    w.writeEndElement();
                    }
                    //end of image-SearchImage
                    
                    //image-MobileDrink
                    if(recipe.Mobile_Drink_Image__c != null && recipe.Mobile_Drink_Image__r.Content_Display_ID__c != null) {
                    	contentVersion = mapContentDisplayIDContentVersion.get(recipe.Mobile_Drink_Image__r.Content_Display_ID__c);
	                    w.writeStartElement(null,'image',null);
	                        w.writeAttribute(null, null, 'imageType', 'MobileDrink');
	                        w.writeAttribute(null, null, 'sfImageAssetId', recipe.Mobile_Drink_Image__r.Content_Display_ID__c);
	                        if(contentVersion != null && contentVersion.Title != null)
		                    	w.writeAttribute(null, null, 'fileName', contentVersion.Title+'.'+contentVersion.FileType.toLowerCase());
		                    else
		                    	w.writeAttribute(null, null, 'fileName', '');
	                    w.writeEndElement();
                    }
                    //end of image-MobileDrink
                    
                    //image-MobileSelected
                    if(recipe.Mobile_Selected_Image__c != null && recipe.Mobile_Selected_Image__r.Content_Display_ID__c != null) {
                    	contentVersion = mapContentDisplayIDContentVersion.get(recipe.Mobile_Selected_Image__r.Content_Display_ID__c);
	                    w.writeStartElement(null,'image',null);
	                        w.writeAttribute(null, null, 'imageType', 'MobileSelected');
	                        w.writeAttribute(null, null, 'sfImageAssetId', recipe.Mobile_Selected_Image__r.Content_Display_ID__c);
	                        if(contentVersion != null && contentVersion.Title != null)
		                    	w.writeAttribute(null, null, 'fileName', contentVersion.Title+'.'+contentVersion.FileType.toLowerCase());
		                    else
		                    	w.writeAttribute(null, null, 'fileName', '');
	                    w.writeEndElement();
                    }
                    //end of image-MobileSelected
                    
                    //image-MobileUnselected
                    if(recipe.Mobile_Unselected_Image__c != null && recipe.Mobile_Unselected_Image__r.Content_Display_ID__c != null) {
                    	contentVersion = mapContentDisplayIDContentVersion.get(recipe.Mobile_Unselected_Image__r.Content_Display_ID__c);
	                    w.writeStartElement(null,'image',null);
	                        w.writeAttribute(null, null, 'imageType', 'MobileUnselected');
	                        w.writeAttribute(null, null, 'sfImageAssetId', recipe.Mobile_Unselected_Image__r.Content_Display_ID__c);
	                        if(contentVersion != null && contentVersion.Title != null)
		                    	w.writeAttribute(null, null, 'fileName', contentVersion.Title+'.'+contentVersion.FileType.toLowerCase());
		                    else
		                    	w.writeAttribute(null, null, 'fileName', '');
	                    w.writeEndElement();
                    }
                    //end of image-MobileUnselected
                    
                    //image-MainIngredient
                    if(recipe.Main_Ingredient_Image__c != null && recipe.Main_Ingredient_Image__r.Content_Display_ID__c != null) {
                    	contentVersion = mapContentDisplayIDContentVersion.get(recipe.Main_Ingredient_Image__r.Content_Display_ID__c);
	                    w.writeStartElement(null,'image',null);
	                        w.writeAttribute(null, null, 'imageType', 'MainIngredient');
	                        w.writeAttribute(null, null, 'sfImageAssetId', recipe.Main_Ingredient_Image__r.Content_Display_ID__c);
	                        if(contentVersion != null && contentVersion.Title != null)
		                    	w.writeAttribute(null, null, 'fileName', contentVersion.Title+'.'+contentVersion.FileType.toLowerCase());
		                    else
		                    	w.writeAttribute(null, null, 'fileName', '');
	                    w.writeEndElement();
                    }
                    //end of image-MainIngredient
                    
                    //image-BrandRecipe
                    if(recipe.Brand_Recipe_Image__c != null && recipe.Brand_Recipe_Image__r.Content_Display_ID__c != null) {
                    	contentVersion = mapContentDisplayIDContentVersion.get(recipe.Brand_Recipe_Image__r.Content_Display_ID__c);
	                    w.writeStartElement(null,'image',null);
	                        w.writeAttribute(null, null, 'imageType', 'BrandRecipe');
	                        w.writeAttribute(null, null, 'sfImageAssetId', recipe.Brand_Recipe_Image__r.Content_Display_ID__c);
	                        if(contentVersion != null && contentVersion.Title != null)
		                    	w.writeAttribute(null, null, 'fileName', contentVersion.Title+'.'+contentVersion.FileType.toLowerCase());
		                    else
		                    	w.writeAttribute(null, null, 'fileName', '');
	                    w.writeEndElement();
                    }
                    //end of image-BrandRecipe
                    
                    //image-BackgroundImage
                    if(recipe.Background_Image__c != null && recipe.Background_Image__r.Content_Display_ID__c != null) {
                    	contentVersion = mapContentDisplayIDContentVersion.get(recipe.Background_Image__r.Content_Display_ID__c);
	                    w.writeStartElement(null,'image',null);
	                        w.writeAttribute(null, null, 'imageType', 'BackgroundImage');
	                        w.writeAttribute(null, null, 'sfImageAssetId', recipe.Background_Image__r.Content_Display_ID__c);
	                        if(contentVersion != null && contentVersion.Title != null)
		                    	w.writeAttribute(null, null, 'fileName', contentVersion.Title+'.'+contentVersion.FileType.toLowerCase());
		                    else
		                    	w.writeAttribute(null, null, 'fileName', '');
	                    w.writeEndElement();
                    }
                    //end of image-BackgroundImage
                    
                    //image-Additional1
                    if(recipe.Additional_Image_1__c != null && recipe.Additional_Image_1__r.Content_Display_ID__c != null) {
                    	contentVersion = mapContentDisplayIDContentVersion.get(recipe.Additional_Image_1__r.Content_Display_ID__c);
	                    w.writeStartElement(null,'image',null);
	                        w.writeAttribute(null, null, 'imageType', 'Additional1');
	                        w.writeAttribute(null, null, 'sfImageAssetId', recipe.Additional_Image_1__r.Content_Display_ID__c);
	                        if(contentVersion != null && contentVersion.Title != null)
		                    	w.writeAttribute(null, null, 'fileName', contentVersion.Title+'.'+contentVersion.FileType.toLowerCase());
		                    else
		                    	w.writeAttribute(null, null, 'fileName', '');
	                    w.writeEndElement();
                    }
                    //end of image-Additional1
                    
                    //image-Additional2
                    if(recipe.Additional_Image_2__c != null && recipe.Additional_Image_2__r.Content_Display_ID__c != null) {
                    	contentVersion = mapContentDisplayIDContentVersion.get(recipe.Additional_Image_2__r.Content_Display_ID__c);
	                    w.writeStartElement(null,'image',null);
	                        w.writeAttribute(null, null, 'imageType', 'Additional2');
	                        w.writeAttribute(null, null, 'sfImageAssetId', recipe.Additional_Image_2__r.Content_Display_ID__c);
	                        if(contentVersion != null && contentVersion.Title != null)
		                    	w.writeAttribute(null, null, 'fileName', contentVersion.Title+'.'+contentVersion.FileType.toLowerCase());
		                    else
		                    	w.writeAttribute(null, null, 'fileName', '');
	                    w.writeEndElement();
                    }
                    //end of image-Additional2
                    
                    //image-Additional3
                    if(recipe.Additional_Image_3__c != null && recipe.Additional_Image_3__r.Content_Display_ID__c != null) {
                    	contentVersion = mapContentDisplayIDContentVersion.get(recipe.Additional_Image_3__r.Content_Display_ID__c);
	                    w.writeStartElement(null,'image',null);
	                        w.writeAttribute(null, null, 'imageType', 'Additional3');
	                        w.writeAttribute(null, null, 'sfImageAssetId', recipe.Additional_Image_3__r.Content_Display_ID__c);
	                        if(contentVersion != null && contentVersion.Title != null)
		                    	w.writeAttribute(null, null, 'fileName', contentVersion.Title+'.'+contentVersion.FileType.toLowerCase());
		                    else
		                    	w.writeAttribute(null, null, 'fileName', '');
	                    w.writeEndElement();
                    }
                    //end of image-Additional3
                    
                    //image-Additional4
                    if(recipe.Additional_Image_4__c != null && recipe.Additional_Image_4__r.Content_Display_ID__c != null) {
                    	contentVersion = mapContentDisplayIDContentVersion.get(recipe.Additional_Image_4__r.Content_Display_ID__c);
	                    w.writeStartElement(null,'image',null);
	                        w.writeAttribute(null, null, 'imageType', 'Additional4');
	                        w.writeAttribute(null, null, 'sfImageAssetId', recipe.Additional_Image_4__r.Content_Display_ID__c);
	                        if(contentVersion != null && contentVersion.Title != null)
		                    	w.writeAttribute(null, null, 'fileName', contentVersion.Title+'.'+contentVersion.FileType.toLowerCase());
		                    else
		                    	w.writeAttribute(null, null, 'fileName', '');
	                    w.writeEndElement();
                    }
                    //end of image-Additional4
                    
                    //image-Additional5
                    if(recipe.Additional_Image_5__c != null && recipe.Additional_Image_5__r.Content_Display_ID__c != null) {
                    	contentVersion = mapContentDisplayIDContentVersion.get(recipe.Additional_Image_5__r.Content_Display_ID__c);
	                    w.writeStartElement(null,'image',null);
	                        w.writeAttribute(null, null, 'imageType', 'Additional5');
	                        w.writeAttribute(null, null, 'sfImageAssetId', recipe.Additional_Image_5__r.Content_Display_ID__c);
	                        if(contentVersion != null && contentVersion.Title != null)
		                    	w.writeAttribute(null, null, 'fileName', contentVersion.Title+'.'+contentVersion.FileType.toLowerCase());
		                    else
		                    	w.writeAttribute(null, null, 'fileName', '');
	                    w.writeEndElement();
                    }
                    //end of image-Additional5
                    
                w.writeEndElement();
                //end of images
                
                //diageoIngredients
                w.writeStartElement(null,'diageoIngredients',null);
                    for(Diageo_Ingredient__c diageoIngredient: recipe.Diageo_Ingredients__r){
                        if(diageoIngredient.Recipe_Diageo_Product__r.Name != null) {
                            //diageoIngredient
                            w.writeStartElement(null,'diageoIngredient',null);
                                w.writeAttribute(null, null, 'id', ''+diageoIngredient.Recipe_Diageo_Product__r.API_External_ID__c);
                                
                                system.debug('===================Recipe Brand Locale: '+ diageoIngredient.Recipe_Diageo_Product__r.Locale__c);    
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
                                    
                                    system.debug('===================Recipe Brand Locale: '+ diageoIngredient.Recipe_Brand__r.Locale__c);    
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
                
                //ingredients
                w.writeStartElement(null,'ingredients',null);
                    for(Diageo_Ingredient__c diageoIngredient: recipe.Diageo_Ingredients__r) {
                        if(diageoIngredient.Recipe_Non_Diageo_Product__r.Name != null) {
                            //ingredient
                            w.writeStartElement(null,'ingredient',null);
                                w.writeAttribute(null, null, 'id', ''+diageoIngredient.Recipe_Non_Diageo_Product__r.API_External_ID__c);
                                w.writeAttribute(null, null, 'Locale', ''+diageoIngredient.Recipe_Non_Diageo_Product__r.Locale__c);
                                //name
                                w.writeStartElement(null,'name',null);
                                    w.writeCharacters(diageoIngredient.Recipe_Non_Diageo_Product__r.Name);
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
                                
                            w.writeEndElement();
                            //end of ingredient
                        }
                    }
                w.writeEndElement();
                //end of ingredients
                 
                //prepSteps
                w.writeStartElement(null,'prepSteps',null);
                    for(Preparation_Step__c preparationStep: recipe.Preparation_Steps__r) {
                        //prepStep
                        w.writeStartElement(null,'prepStep',null);
                            w.writeAttribute(null, null, 'stepNo', ''+preparationStep.Step_Number__c);
                            //instruction
                            w.writeStartElement(null,'instruction',null);
                                if(preparationStep.Description__c != null)
                                    w.writeCharacters(preparationStep.Description__c);
                            w.writeEndElement();
                            //end of instruction
                        w.writeEndElement();
                        //end of prepStep
                    }
                w.writeEndElement();
                //end of prepSteps
                
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
    }
}