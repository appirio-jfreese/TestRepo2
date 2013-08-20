/*****************************************************************************
Name        : APPIRIO_GenerateXMLRecipeHeaderInfo
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 27th dec, 2012
Purpose     : 
******************************************************************************/
public with sharing class APPIRIO_GenerateXMLRecipeHeaderInfo {
	
	//public variable declaration
	public transient Boolean endOfResponse;
    public transient Integer resumePoint;
	public List<Id> recipeIds{get;set;}
	public string xmlString {get;set;}
	
	//private variable declaration
	private transient Integer RecipesReturned;
	private map<String, String> mapOZTo5Mils;
	private map<String, String> mapMLToOZ;
	private transient map<String, Convert_Measurements__c> mapConvertMeasurements;
	private transient map<String, ContentVersion> mapContentDisplayIDContentVersion;
		
    //Constructor of calss APPIRIO_GenerateXMLRecipeHeaderInfo
	public APPIRIO_GenerateXMLRecipeHeaderInfo() {
		xmlString = '';
		RecipesReturned = 0;
		recipeIds = new List<Id>();
		
		mapContentDisplayIDContentVersion = new map<String, ContentVersion>();
        //Query all ContentVersion records where ContentDocumentId = input parameter
        for(ContentVersion contentVersion :[Select FileType, Title, ContentDocumentId From ContentVersion]) {
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
	}
	
	//Generating an XML with Recipe info.
	public void generateXMLRecipeIinfo() {
		
		system.debug('========================recipeIds==: '+recipeIds.size());
		
		XmlStreamWriter w = new XmlStreamWriter();
		w.writeStartDocument(null,'1.0');
		
		//recipes
		w.writeStartElement(null,'recipes',null);
		
		//Grabbing/getting all the details of the recipes that is already created.
		for(Recipe__c recipe :[SELECT API_External_ID__c, LastModifiedDate, NEO_Recipe_Id__c, Recipe_Tag__c, Name, Id, Recipe_Title__c, Locale__c, 
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
                                      ,(select id, API_External_ID__c,Ingredient_Number__c, Quantity__c,Ingredient_Unit__c,Featured_Brand__c,
                                      Recipe_Brand__c,Recipe_Brand__r.Name,Recipe_Brand__r.API_External_ID__c,Recipe_Brand__r.Locale__c, 
                                      Recipe_Diageo_Product__r.Name, Recipe_Diageo_Product__r.API_External_ID__c,Recipe_Diageo_Product__r.Locale__c 
                                      from Diageo_Ingredients__r order by Ingredient_Number__c)
                                      FROM Recipe__c WHERE Id IN :recipeIds  And recordSaved__c = true order by API_External_ID__c]) {
			
			RecipesReturned +=1;
			string str;
			
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
			  	
			  	//Recipe Main Drink Image
			  	w.writeStartElement(null,'RecipeMainDrinkImage',null);
			  	
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
			  	//end of Recipe Main Drink Image
			  	
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