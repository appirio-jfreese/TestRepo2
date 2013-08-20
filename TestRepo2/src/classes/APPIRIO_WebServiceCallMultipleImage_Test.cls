/*************************************************************
Name        : APPIRIO_GenerateXMLRecpIinfoDemo_Test
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 27th Dec, 2012
Purpose     : Test Class for 
				- APPIRIO_GenerateXMLRecipeIinfoDemoCon
*************************************************************/
@isTest(SeeAllData = true)
private class APPIRIO_WebServiceCallMultipleImage_Test {

	//variable declaration
	static ContentVersion contentVersion;
	
	static {
		contentVersion = TestUtil.testInsertDrinkImageContent('Google.com'); 
		contentVersion = [Select Id, Title, FileType,  ContentDocumentId, VersionData From ContentVersion Where Id =: contentVersion.Id];
	}
	
	//Test Web Service Call multiple content images
    public static TestMethod void WebServiceCallMultipleImagesTest() {
    	String xmlString;
    	
    	Test.startTest();
	    	// set up the request object
	        System.RestContext.request = new RestRequest();
	        RestContext.request.requestURI = '/CallMultipleContentImages/';	        
	        // Invoke the method directly
	        xmlString = APPIRIO_WebServiceCallMultipleImages.WebServiceCallMultipleImages();
			System.assert(xmlString.contains('ContentDisplayIDs cannot be blank.'));
			//Modified the ContentIds By Rahul Chitkara(Appirio Offshore) on 26th April 2013
	        RestContext.request.addParameter('ContentDisplayIDs', '1;2;3;4;5;6;7;8;9;10;11;12');
	        xmlString = APPIRIO_WebServiceCallMultipleImages.WebServiceCallMultipleImages();
	        // Modified the Assert Condition by Rahul Chitkara(Appirio Jaipur) on 26th April 2013
	        System.assert(xmlString.contains('ContentDisplayIDs cannot be allowed more than 10.'));
	        
	        RestContext.request.addParameter('ContentDisplayIDs',contentVersion.ContentDocumentId);
	    	xmlString = APPIRIO_WebServiceCallMultipleImages.WebServiceCallMultipleImages();
			System.assert(xmlString.contains('<?xml version="1.0"?>'));
			System.assert(xmlString.contains('<images><image ContentDisplayID="'+contentVersion.ContentDocumentId+'" fileName="'+contentVersion.Title+'.'+contentVersion.FileType.toLowerCase()+'"'));
	        System.assert(xmlString.contains(EncodingUtil.base64Encode(contentVersion.VersionData)));    
        Test.stopTest();
	}
}