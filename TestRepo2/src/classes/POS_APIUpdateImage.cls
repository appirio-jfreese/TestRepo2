@RestResource(urlMapping='/UpdateItemImage/*')
global with sharing class POS_APIUpdateImage {
	
	@HttpPost
    global static Item_Image__c doUpdate (Item_Image__c ItemImage) {
    	
    	POS_Magento_Configuration__c settings = POS_Magento_Configuration__c.getOrgDefaults();
    	String productImageFolderPath = settings.ProductImage_FolderPath__c;
    	
    	RestResponse res = RestContext.response;
    	
    	if (itemImage!=null) {
    		System.debug('itemImage.Id -' + itemImage.Id); 
    	}
    	
    	//Check to make sure Item sku is passed by the caller of the service
    	if (itemImage==null || itemImage.Item__c==null) {
    		res.StatusCode = 400;
    		res.addHeader('Error','Item SKU (SFDC Id) is a required field');
			return null;
			
    	} // Additional check for update to make sure the magento and SFDC unique identifier fo the image is passed by the agency 
    	/*else if (itemImage.Id==null || itemImage.Id == '') {
    		res.StatusCode = 400;
    		res.addHeader('Error','Image SFDC Id is a required field');
			return null;    		
    		
    	}*/ else if (itemImage.Magento_File_Name__c==null || itemImage.Magento_File_Name__c == '') {
    		res.StatusCode = 400;
    		res.addHeader('Error','Image Magento File Name is a required field');
			return null;    		
    		
    	}

 		String API_ARGUMENTS = '&arg2[id]=' + EncodingUtil.urlEncode(itemImage.Item__c+'','UTF-8') +  
 	    	'&arg2[file]=' + EncodingUtil.urlEncode(itemImage.Magento_File_Name__c+'','UTF-8');
 	    		
        if(itemImage.File_Name__c != null && itemImage.File_Name__c != ''){ // Optional for Update allowing the call to only update metadata
        	API_ARGUMENTS = API_ARGUMENTS + '&arg2[Product][file][name]=' + EncodingUtil.urlEncode(itemImage.File_Name__c+'','UTF-8');
        }        	
        if(itemImage.ImgBase64String__c != null && itemImage.ImgBase64String__c != ''){ // Optional for Update allowing the call to only update metadata
        	API_ARGUMENTS = API_ARGUMENTS + '&arg2[Product][file][content]=' + EncodingUtil.urlEncode(itemImage.ImgBase64String__c+'','UTF-8');
        }        	
        if (itemImage.Mime_Type__c == null || itemImage.Mime_Type__c == '') { // set default for mime-type
			itemImage.Mime_Type__c = 'image/jpeg'; 
		} 
        API_ARGUMENTS = API_ARGUMENTS + '&arg2[Product][file][mime]=' + EncodingUtil.urlEncode(itemImage.Mime_Type__c,'UTF-8');
        
        if(itemImage.Label__c != null && itemImage.Label__c != ''){
        	API_ARGUMENTS = API_ARGUMENTS + '&arg2[Product][label]=' + EncodingUtil.urlEncode(itemImage.Label__c,'UTF-8');
        }
        if(itemImage.Position__c != null){
        	API_ARGUMENTS = API_ARGUMENTS + '&arg2[Product][position]=' + EncodingUtil.urlEncode(itemImage.Position__c+'','UTF-8');
        }
		
		if (itemImage.Exclude__c == null) { // set default for this flag as exclude false on creation
			itemImage.Exclude__c = 0; 
		} 
		API_ARGUMENTS = API_ARGUMENTS + '&arg2[Product][exclude]=' + EncodingUtil.urlEncode(itemImage.Exclude__c+'','UTF-8');
    	
    	if(itemImage.Image_Types__c != null) {
    		// read the multi-picklist values into an array
    		string[] types = itemImage.Image_Types__c.split(';',0);
    		
			Integer ct = 0;
			for(String tp : types) {
				ct++;
				API_ARGUMENTS = API_ARGUMENTS + '&arg2[Product][types][' + ct +']=' + tp;
			}
    	}

		System.debug('API_ARGUMENTS -' +API_ARGUMENTS); 
        Dom.Document doc = POS_MagentoIntegrationUtil.getMagentoCallDocument('product_media.update', API_ARGUMENTS);
        String responseId = POS_MagentoIntegrationUtil.getMagentoResponseElement(doc, 'response');
        String status = POS_MagentoIntegrationUtil.getMagentoResponseElement(doc, 'status');

		System.debug('status -' +status + ' responseId -' +responseId);  
		
		if(status == 'success') {
			// update the record with latest info, agencies need to pass the SFDC Id of this Item Image record
			itemImage.ImgBase64String__c = ''; // Imp: empty the content string before return
			update itemImage;
			
			return itemImage;
			
		} else {
			res.StatusCode = 400;
    		res.addHeader('Error','Error during product_media.update callout to Magento');			
			return null;
		}
		
    }
    
    /*
	@HttpDelete
    global static String doDelete () {
    	
    	RestRequest req = RestContext.request;
    	RestResponse res = RestContext.response;
    	
    	String itmImageId = req.params.get('Id');
    	String itmSKU = req.params.get('Item__c');
    	String imgFileName = req.params.get('Magento_File_Name__c');
    	
    	System.debug('itmSKU -' +itmSKU + ' itmImageId -' +itmImageId + ' imgFileName -' +imgFileName); 
    	//Check to make sure Item sku is passed by the caller of the service
    	if (itmSKU==null || itmSKU=='') {
    		res.StatusCode = 400;
    		res.addHeader('Error','Item SKU (SFDC Id) is a required field');
			return null;
			
    	}  else if (itmImageId==null || itmImageId=='') {
    		res.StatusCode = 400;
    		res.addHeader('Error','Item Image SFDC Id is a required field');
			return null;
			
    	} else if (imgFileName==null || imgFileName=='') {
    		res.StatusCode = 400;
    		res.addHeader('Error','Image File Name (as stored on Magento) is a required field');
			return null;
			
    	} 
    	
 		String API_ARGUMENTS = '&arg2[id]=' + EncodingUtil.urlEncode(itmSKU+'','UTF-8') +  
 		'&arg2[file]=' + EncodingUtil.urlEncode(imgFileName+'','UTF-8');
 		
		System.debug('API_ARGUMENTS -' +API_ARGUMENTS); 
        Dom.Document doc = POS_MagentoIntegrationUtil.getMagentoCallDocument('product_media.remove', API_ARGUMENTS);
        String responseId = POS_MagentoIntegrationUtil.getMagentoResponseElement(doc, 'response');
        String status = POS_MagentoIntegrationUtil.getMagentoResponseElement(doc, 'status');

		System.debug('status -' +status + ' responseId -' +responseId);   		    	
    	
		if(status == 'success') {
			// delete Item_Image__c record
			//Item_Image__c itemImage = [Select id from Item_Image__c where Item__c=:itmSKU and Magento_File_Name__c=:imgFileName][0];
			Item_Image__c itemImage = new item_Image__c(id=itmImageId);
			delete itemImage;
		}
		return status;  	
    	
    }  */
    
	@IsTest(SeeAllData=true)
    public static void testUpdateItemImage () {	
    	
    	RestContext.response = new RestResponse(); // Important to set this for testMethod
    	Program__c pg1 = POS_TestDataUtil.createProgram();
    	Item__c itm = POS_TestDataUtil.createItem(pg1);
		
    	Item_Image__c itemImage = new Item_Image__c();
	    itemImage.Item__c = itm.id;
	    insert itemImage;
	        
	    itemImage.File_Name__c = 'CaptainMorgan-Jersey-Sm.jpg';
	    Item_Image__c rtnImage = POS_APIUpdateImage.doUpdate(itemImage);
	    system.assertEquals( null, rtnImage ); 

    	itemImage.Magento_File_Name__c = '/C/a/CaptainMorgan-Jersey-Sm.jpg';
    	itemImage.Image_Types__c='TEST';
    	rtnImage = POS_APIUpdateImage.doUpdate(itemImage);
    	system.assertNotEquals( null, rtnImage );	
    	
    	//Test error scenarios
	    rtnImage = POS_APIUpdateImage.doUpdate(null);
	    System.assert(rtnImage==null);
	    
	    itemImage.Magento_File_Name__c = null;
	    rtnImage = POS_APIUpdateImage.doUpdate(itemImage);
    	System.assert(rtnImage==null);
	    
	    

    }      

}