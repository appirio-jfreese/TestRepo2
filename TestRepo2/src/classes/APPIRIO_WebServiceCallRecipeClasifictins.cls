/********************************************************************************************************************
Name        : APPIRIO_WebServiceCallRecipeClasifictins
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 15th Jan, 2013
Purpose     : Write Web Service Call for Recipe Classifications
Ref         : T-109753
                Create a web service call which returns the following XML format:

                <recipeClassifications>
                <recipeClassification> Attribute__c.Attribute_type__c </recipeClassification>
                </recipeClassifications>
                
                Data to put into the format:
                Select Attribute_type__c from Attribute__c where Dynamic__c == 0
                
                I-46016: REST Call should allow for an input parameter
                The user should be able to provide an input parameter: key=XXXX. 
                Key corresponds to the Recipe Classifications, and allows the user to get the related values for just one key. 
                If the parameter is not defined, return all results.
********************************************************************************************************************/
@RestResource(urlMapping='/CallRecipeClassifications/*')
global with sharing class APPIRIO_WebServiceCallRecipeClasifictins {
    //Web Service Call for Recipe Classifications
    @HttpGet
    webservice static String WebServiceCallRecipeClassification() {
        RestRequest req = RestContext.request;
        map<String,String> paramMap = req.params;
        
        string xmlString;
        String key = paramMap.get('Key');
        set<string> setAttributeType = new set<string>();
        
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartDocument(null,'1.0');
        
        //recipeClassifications
        w.writeStartElement(null,'recipeClassifications',null);
        if(key != null && key.trim() != '') {
            for(Attribute__c attribute :[Select Attribute_Type__c From Attribute__c 
                                                                  Where Dynamic__c = false 
                                                                  And Attribute_Type__c =: key 
                                                                  order by Attribute_Type__c]) {
                if(attribute.Attribute_Type__c != null && !setAttributeType.contains(attribute.Attribute_Type__c))  {
                    setAttributeType.add(attribute.Attribute_Type__c);
                    //recipeClassification
                    w.writeStartElement(null,'recipeClassification',null);
                        w.writeCharacters(String.valueOf(attribute.Attribute_Type__c));
                    w.writeEndElement();
                    //end of recipeClassification
                }
            }
            
            if(key.equals('Brand')) {
                //recipeClassification
                w.writeStartElement(null,'recipeClassification',null);
                    w.writeCharacters('Brand');
                w.writeEndElement();
                //end of recipeClassification
            }
            
            if(key.equals('Product')) {
                //recipeClassification
                w.writeStartElement(null,'recipeClassification',null);
                    w.writeCharacters('Product');
                w.writeEndElement();
                //end of recipeClassification
            }
            
            if(key.equals('Occasion')) {
                //recipeClassification
                w.writeStartElement(null,'recipeClassification',null);
                    w.writeCharacters('Occasion');
                w.writeEndElement();
                //end of recipeClassification
            }
                
        } else {
            for(Attribute__c attribute :[Select Attribute_Type__c From Attribute__c 
                                                                  Where Dynamic__c = false 
                                                                  order by Attribute_Type__c]) {
                if(attribute.Attribute_Type__c != null && !setAttributeType.contains(attribute.Attribute_Type__c))  {
                    setAttributeType.add(attribute.Attribute_Type__c);
                    //recipeClassification
                    w.writeStartElement(null,'recipeClassification',null);
                        w.writeCharacters(String.valueOf(attribute.Attribute_Type__c));
                    w.writeEndElement();
                    //end of recipeClassification
                }
            }
            //recipeClassification
            w.writeStartElement(null,'recipeClassification',null);
                w.writeCharacters('Brand');
            w.writeEndElement();
            //end of recipeClassification
            
            //recipeClassification
            w.writeStartElement(null,'recipeClassification',null);
                w.writeCharacters('Product');
            w.writeEndElement();
            //end of recipeClassification
            
            //recipeClassification
            w.writeStartElement(null,'recipeClassification',null);
                w.writeCharacters('Occasion');
            w.writeEndElement();
            //end of recipeClassification
        }
        
        w.writeEndElement();
        //end of recipeClassifications
        
        w.writeEndDocument();
        xmlString = w.getXmlString();
        w.close();
        
        return xmlString;
    }
}