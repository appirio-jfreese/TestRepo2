/********************************************************************************************************************
Name        : APPIRIO_WebServiceCallRecipeClasifDtl
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 15th Jan, 2013
Purpose     : Create Web Service Call for Recipe Classifications & Values
Ref         : T-109754
			  	Create a web service call which returns the following XML format:

				<recipeClassifications>
				<recipeClassification>
				<key>Attribute__c.Attribute_type__c</key>
				<values>
				<value> Attribute__c.Attribute_Value__c </value>
				</values>
				</recipeClassification>
				</recipeClassifications>
				
				Data to put into the format:
				KEY: Select Attribute_type__c from Attribute__c where Dynamic__c == 0
				
				VALUES: Select Attribute__c.Attribute_value__c where Attribute__c.Attribute_type__c == KEY
				
				I-46016: REST Call should allow for an input parameter
				The user should be able to provide an input parameter: key=XXXX. 
				Key corresponds to the Recipe Classifications, and allows the user to get the related values for just one key. 
				If the parameter is not defined, return all results.
********************************************************************************************************************/
@RestResource(urlMapping='/CallRecipeClassificationDetails/*')
global with sharing class APPIRIO_WebServiceCallRecipeClasifDtl {
	//Web Service Call for Recipe Classifications & Values
	@HttpGet
	webservice static String WebServiceCallRecipeClassificationDetails() {
		
		RestRequest req = RestContext.request;
		map<String,String> paramMap = req.params;
		
		string xmlString;
		String key = paramMap.get('Key');
		map<string,List<Attribute__c>> setAttributeDetails = new map<string,List<Attribute__c>>();
		
		XmlStreamWriter w = new XmlStreamWriter();
		w.writeStartDocument(null,'1.0');
		
		if(key != null && key.trim() != '') {
			for(Attribute__c attribute :[Select Attribute_Type__c, Attribute_value__c, API_External_ID__c, Locale__c From Attribute__c 
													Where Dynamic__c = false 
													And Attribute_Type__c =: key 
													order by Attribute_Type__c, Attribute_value__c]) {
														
				if(attribute.Attribute_Type__c != null) {
					if(!setAttributeDetails.containsKey(attribute.Attribute_Type__c)){
						setAttributeDetails.put(attribute.Attribute_Type__c, new List<Attribute__c>());	
					}
					if(attribute.Attribute_value__c != null) 
						setAttributeDetails.get(attribute.Attribute_Type__c).add(attribute);
				}
			}	
		} else {
			for(Attribute__c attribute :[Select Attribute_Type__c, Attribute_value__c, API_External_ID__c, Locale__c From Attribute__c 
													Where Dynamic__c = false order by Attribute_Type__c, Attribute_value__c]) {
														
				if(attribute.Attribute_Type__c != null) {
					if(!setAttributeDetails.containsKey(attribute.Attribute_Type__c)){
						setAttributeDetails.put(attribute.Attribute_Type__c, new List<Attribute__c>());	
					}
					if(attribute.Attribute_value__c != null) 
						setAttributeDetails.get(attribute.Attribute_Type__c).add(attribute);
				}
			}
		}
		
		//recipeClassifications
		w.writeStartElement(null,'recipeClassifications',null);
			//---Attribute--//
			for(string ky :setAttributeDetails.keySet()) {
				//recipeClassification
				w.writeStartElement(null,'recipeClassification',null);
					//key
					w.writeStartElement(null,'key',null);
						w.writeCharacters(ky);
					w.writeEndElement();
					//end of key
					//values
					w.writeStartElement(null,'values',null);
						for(Attribute__c attribute :setAttributeDetails.get(ky)) {
							//value
							w.writeStartElement(null,'value',null);
								w.writeAttribute(null, null, 'id', ''+attribute.API_External_ID__c);
								w.writeAttribute(null, null, 'Locale', ''+attribute.Locale__c);
				                w.writeCharacters(String.valueOf(attribute.Attribute_value__c));
							w.writeEndElement();
							//end of value
						}
					w.writeEndElement();
					//end of values		
				w.writeEndElement();
				//end of recipeClassification		
			}
			
			Boolean display = true;
			if(key != null && key.trim() != '') {
				display = key.equals('Occasion') ? true : false;	
			} else {
				display = true;
			}
			
			if(display) {
				//---Occasion--//
				//recipeClassification
				w.writeStartElement(null,'recipeClassification',null);
					//key
					w.writeStartElement(null,'key',null);
						w.writeCharacters('Occasion');
					w.writeEndElement();
					//end of key
					//values
					w.writeStartElement(null,'values',null);
						for(Occasion__c occasion :[Select Name_Of_The_Occasion__c, API_External_ID__c, Locale__c, Occasion_Tags__c, Occasion_Type__c From Occasion__c order by Name_Of_The_Occasion__c]) {
							//value
							w.writeStartElement(null,'value',null);
								w.writeAttribute(null, null, 'id', occasion.API_External_ID__c);
				                w.writeAttribute(null, null, 'Locale', ''+occasion.Locale__c);
				                w.writeAttribute(null, null, 'Type', ''+occasion.Occasion_Type__c);
								w.writeCharacters(occasion.Name_Of_The_Occasion__c);
							w.writeEndElement();
							//end of value
							
							//tags
		                    w.writeStartElement(null,'tags',null);
		                        if(occasion.Occasion_Tags__c != null)
		                            w.writeCharacters(occasion.Occasion_Tags__c);
		                    w.writeEndElement();
		                    //end of tags
						}
					w.writeEndElement();
					//end of values
				w.writeEndElement();
				//end of recipeClassification
			}
			
			if(key != null && key.trim() != '') {
				display = key.equals('Brand') ? true : false;	
			} else {
				display = true;
			}
			
			if(display) {
				//---Brand--//
				//recipeClassification
				w.writeStartElement(null,'recipeClassification',null);
					//key
					w.writeStartElement(null,'key',null);
						w.writeCharacters('Brand');
					w.writeEndElement();
					//end of key
					//values
					w.writeStartElement(null,'values',null);
						for(Diageo_Brand__c brand :[Select Name, API_External_ID__c, Locale__c, Category__c From Diageo_Brand__c order by Name]) {
							//value
							w.writeStartElement(null,'value',null);
								w.writeAttribute(null, null, 'id', ''+brand.API_External_ID__c);
								if(brand.Locale__c == null) brand.Locale__c = '';
								w.writeAttribute(null, null, 'Locale', brand.Locale__c +'');
								if(brand.Category__c == null) brand.Category__c = '';
								w.writeAttribute(null, null, 'Category', brand.Category__c +'');
				                w.writeCharacters(brand.Name);
							w.writeEndElement();
							//end of value
						}
					w.writeEndElement();
					//end of values
				w.writeEndElement();
				//end of recipeClassification
			}
			
			if(key != null && key.trim() != '') {
				display = key.equals('Product') ? true : false;	
			} else {
				display = true;
			}
			
			if(display) {
				//---Product--//
				//recipeClassification
				w.writeStartElement(null,'recipeClassification',null);
					//key
					w.writeStartElement(null,'key',null);
						w.writeCharacters('Product');
					w.writeEndElement();
					//end of key
					//values
					w.writeStartElement(null,'values',null);
						for(Diageo_Product__c product :[Select Name, API_External_ID__c, Locale__c, Category__c, Diageo_Brand_Id__r.API_External_ID__c From Diageo_Product__c order by Name]) {
							//value
							w.writeStartElement(null,'value',null);
								w.writeAttribute(null, null, 'id', ''+product.API_External_ID__c);
								if(product.Locale__c == null) product.Locale__c = '';
								w.writeAttribute(null, null, 'Locale', product.Locale__c +'');
								if(product.Category__c == null) product.Category__c = '';
								w.writeAttribute(null, null, 'Category', product.Category__c +'');
								w.writeAttribute(null, null, 'BrandId', product.Diageo_Brand_Id__r.API_External_ID__c +'');
	                            w.writeCharacters(product.Name);
							w.writeEndElement();
							//end of value
						}
					w.writeEndElement();
					//end of values
				w.writeEndElement();
				//end of recipeClassification
			}
			
		w.writeEndElement();
		//end of recipeClassifications
		
		w.writeEndDocument();
		xmlString = w.getXmlString();
		system.debug('===================xmlString: '+ xmlString);
		w.close();
		
		return xmlString;
	}
}