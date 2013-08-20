/********************************************************************************************************************
Name        : APPIRIO_WebServiceCallMultipleImages
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 31st Dec, 2012
Purpose     : Create Web Service Call for return of multiple content images
Ref         : T-105832
              input parameters:
                1. Media__c.Content_Display_ID__c (up to 5 different IDs)
            
              output:
                return XML with the images requested (up to 5) embedded in the return call.
                Encode images if possible.
********************************************************************************************************************/
@RestResource(urlMapping='/CallMultipleContentImages/*')
global with sharing class APPIRIO_WebServiceCallMultipleImages {
    //Creating Web Service Call for return of multiple content images
    @HttpGet
    webservice static String WebServiceCallMultipleImages(){
        RestRequest req = RestContext.request;
        map<String,String> paramMap = req.params;
        
        //input parameter
        String ContentDisplayIDs = paramMap.get('ContentDisplayIDs');
        if(ContentDisplayIDs == null || ContentDisplayIDs.trim() == '') {
            return 'ContentDisplayIDs cannot be blank.';
        }   
        
        set<String> ContentIDs = new set<String>();
        for(String str :ContentDisplayIDs.split(';')) {
            ContentIDs.add(str.trim());
        }
        
        //Changed Limit to 10 - Case 00004658 - Diana Acker - 4/8/13
        if(ContentIDs.size() > 10) {
            return 'ContentDisplayIDs cannot be allowed more than 10.';
        } 
        
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        //Query all ContentVersion records where ContentDocumentId = input parameter
        for(ContentVersion contentVersion :[Select FileType, VersionData, Title, ContentDocumentId From ContentVersion 
                                                    Where ContentDocumentId IN :ContentIDs]) {
            contentVersions.add(contentVersion);
        }
        
        //return XML with the images requested embedded in the return call.
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartDocument(null,'1.0');
    
        //images
        w.writeStartElement(null,'images',null);
            for(ContentVersion contentVersion :contentVersions) {
                if(contentVersion.ContentDocumentId != null) {
                    //image
                    w.writeStartElement(null,'image',null);
                        w.writeAttribute(null, null, 'ContentDisplayID', contentVersion.ContentDocumentId);
                        if(contentVersion.Title != null)
                            w.writeAttribute(null, null, 'fileName', contentVersion.Title+'.'+contentVersion.FileType.toLowerCase());
                        else
                            w.writeAttribute(null, null, 'FileName', '');
                        if(contentVersion.VersionData != null)
                            w.writeCharacters(EncodingUtil.base64Encode(contentVersion.VersionData));
                    w.writeEndElement();
                    //end of image
                }
            }
        w.writeEndElement();    
        //end of images
        w.writeEndDocument();
        string xmlString = w.getXmlString();
        w.close();
        //Return the XML output.
        return xmlString;
    }
}