@RestResource(urlMapping='/UploadItemImage/*')
global with sharing class POS_APIUploadImage {
	
	@HttpPost
    global static Item_Image__c doPost (Item_Image__c ItemImage) {
    	
    	POS_Magento_Configuration__c settings = POS_Magento_Configuration__c.getOrgDefaults();
    	String productImageFolderPath = settings.ProductImage_FolderPath__c;
    	
    	RestResponse res = RestContext.response;
    	//Check to make sure Item sku is passed by the caller of the service
    	if (itemImage==null || itemImage.Item__c==null) {
    		res.StatusCode = 400;
    		res.addHeader('Error','Item SKU (SFDC Id) is a required field');
			return null;
			
    	} else if (itemImage.File_Name__c==null || itemImage.File_Name__c == '') {
    		res.StatusCode = 400;
    		res.addHeader('Error','Image File Name is a required field');
			return null;    		
    		
    	} else if (itemImage.ImgBase64String__c==null || itemImage.ImgBase64String__c == '') { // required for Create
    		res.StatusCode = 400;
    		res.addHeader('Error','Image Content Base64String is a required field');
			return null;    		
    		
    	}
    	
 		String API_ARGUMENTS = '&arg2[id]=' + EncodingUtil.urlEncode(itemImage.Item__c+'','UTF-8') +  
 	    	'&arg2[Product][file][name]=' + EncodingUtil.urlEncode(itemImage.File_Name__c+'','UTF-8')  +	
        	'&arg2[Product][file][content]=' + EncodingUtil.urlEncode(itemImage.ImgBase64String__c+'','UTF-8');
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

		//System.debug('API_ARGUMENTS -' +API_ARGUMENTS); 
        Dom.Document doc = POS_MagentoIntegrationUtil.getMagentoCallDocument('product_media.create', API_ARGUMENTS);
        String responseId = POS_MagentoIntegrationUtil.getMagentoResponseElement(doc, 'response');
        String status = POS_MagentoIntegrationUtil.getMagentoResponseElement(doc, 'status');

		System.debug('status -' +status + ' responseId -' +responseId);  
		
		if(status == 'success') {
			// update the Item_Image__c with fileName returned from Magento and save.
			itemImage.Magento_File_Name__c = responseId;
			itemImage.Magento_Image_URL__c = productImageFolderPath+responseId;
			itemImage.ImgBase64String__c = ''; // Imp: empty the content string before return
			insert itemImage;
			
			return itemImage;
			
		} else {
			res.StatusCode = 400;
    		res.addHeader('Error','Error during product_media.create callout to Magento');			
			return null;
		}
    }	


	@IsTest(SeeAllData=true)
    public static void testUploadItemImage () {	
    	
    	RestContext.response = new RestResponse(); // Important to set this for testMethod
    	Program__c pg1 = POS_TestDataUtil.createProgram();
    	Item__c itm = POS_TestDataUtil.createItem(pg1);
		
    	Item_Image__c itemImage = new Item_Image__c();
    	//System.debug('********** testUploadItemImage - itemImage.Item__c ' + itemImage.Item__c);
	    Item_Image__c rtnImage = POS_APIUploadImage.doPost(itemImage);
	    system.assertEquals( null, rtnImage );     	

	    itemImage.Item__c = itm.id;
	    rtnImage = POS_APIUploadImage.doPost(itemImage);
	    system.assertEquals( null, rtnImage ); 
	        
	    itemImage.File_Name__c = 'CaptainMorgan-Jersey-Sm.jpg';
	    rtnImage = POS_APIUploadImage.doPost(itemImage);
	    system.assertEquals( null, rtnImage ); 

    	itemImage.Mime_Type__c = 'image/jpeg';
    	itemImage.ImgBase64String__c = '/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBhISERUSExIUEBUUFBAUFBUVEBQUEBUUFBQVFBUU'; // dummy base64 string
    	itemImage.Label__c = 'Captain Morgan Basketball Jersey';
    	itemImage.Position__c = 1;
    	itemImage.Exclude__c = 0;
    	itemImage.Image_Types__c = 'image;thumbnail;small_image';	
    	
    	rtnImage = POS_APIUploadImage.doPost(itemImage);
    	system.assertNotEquals( null, rtnImage );	

    }

}