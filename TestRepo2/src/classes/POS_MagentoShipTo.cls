public with sharing class POS_MagentoShipTo {
	
	public static void deleteMagentoShipTo (String magentoShipToId) {
        String API_ARGUMENTS = '&arg2[addressId]='+ magentoShipToId;
        
        Dom.Document doc = POS_MagentoIntegrationUtil.getMagentoCallDocument('metrics_carts.deleteaddress', API_ARGUMENTS);
        String responseId = POS_MagentoIntegrationUtil.getMagentoResponseElement(doc, 'response');

		System.debug('responseId -' +responseId);
    }
    
    
    public static void deleteMagentoShipTos (List<User_Ship_To__c> userShipTos) {
    	
    	
        String API_ARGUMENTS = '&arg2[addressId]=';
        
        List<REST_Queue_Message__c> messages = new List<REST_Queue_Message__c>(); 
        for (User_Ship_To__c userShipTo:userShipTos) {
        	if (userShipTo.Magento_Ship_To_ID__c!=null) { 									
        		REST_Queue_Message__c msg = POS_MagentoIntegrationUtil.createAsyncMagentoCall ('metrics_carts.deleteaddress', API_ARGUMENTS+userShipTo.Magento_Ship_To_ID__c, ''+userShipTo.Id, 'User_Ship_To__c','Magento_Ship_To_ID__c');
        		messages.add(msg);   
        	}
        }
        
        POS_MagentoIntegrationUtil.bulkSaveMagentoCallToQueue(messages);
    }
    
    private static String getUpdateApiArgs (User_Ship_To__c userShipTo) {
    	//Added shipto_id arg for Case 00003923 - Diana - 2/22/2013
    	String apiArguments='&arg2[addressId]=' + userShipTo.Magento_Ship_To_ID__c +
          '&arg2[customer_address][firstname]='+ EncodingUtil.urlEncode(userShipTo.Ship_To__r.Name,'UTF-8') + 
          '&arg2[customer_address][lastname]='+ EncodingUtil.urlEncode(userShipTo.Ship_To__r.Attention__c,'UTF-8') + 
          '&arg2[customer_address][country_id]=US'+
          '&arg2[customer_address][city]='+ EncodingUtil.urlEncode(userShipTo.Ship_To__r.City__c,'UTF-8') +
          '&arg2[customer_address][street]='+ EncodingUtil.urlEncode(userShipTo.Ship_To__r.Street__c,'UTF-8') +
          '&arg2[customer_address][telephone]='+ EncodingUtil.urlEncode(userShipTo.Ship_To__r.Phone__c,'UTF-8') +
          '&arg2[customer_address][postcode]='+ EncodingUtil.urlEncode(userShipTo.Ship_To__r.Zip__c,'UTF-8') +
          '&arg2[customer_address][region]='+ EncodingUtil.urlEncode(userShipTo.Ship_To__r.State__c,'UTF-8') +
          '&arg2[customer_address][mcarts_group]='+EncodingUtil.urlEncode(userShipTo.Ship_to__r.Account__r.Name,'UTF-8') + 
          '&arg2[customer_address][shipto_id]='+EncodingUtil.urlEncode(userShipTo.Ship_To__c,'UTF-8') + 
          '&arg2[customer_address][is_default_shipping]=true';
          
          system.debug('=========apiArguments = ' + apiArguments);
          
          return apiArguments;
         
    }
    
    public static void updateMagentoShipTo (User_Ship_To__c userShipTo) {
    	
    	handleEmptyValues(userShipTo);
    	String apiArguments = getUpdateApiArgs(userShipTo);
    	
    	Dom.Document doc = POS_MagentoIntegrationUtil.getMagentoCallDocument('customer_address.update', apiArguments);
        String responseId = POS_MagentoIntegrationUtil.getMagentoResponseElement(doc, 'response');
    	
    }
    
    private static void handleEmptyValues (User_Ship_To__c userShipTo) {
    	//Need to set some default values since Magento requires them.  Not relevant in final shipping as that's
	  	//all driven from Salesforce
	  	if (userShipTo.Ship_To__r.attention__c==null) {
	  		userShipTo.Ship_To__r.attention__c='Attn: Receiving Department';
	  	}
	  	else {
	  		String temp='Attn: '+userShipTo.Ship_To__r.attention__c;
	  		userShipTo.Ship_To__r.attention__c=temp;
	  	}
	  	
	  	if (userShipTo.Ship_To__r.city__c==null) {
	  		userShipTo.Ship_To__r.city__c='Unknown';
	  	}
	  	if (userShipTo.Ship_To__r.street__c==null) {
	  		userShipTo.Ship_To__r.street__c='Unknown';
	  	}
	  	if (userShipTo.Ship_To__r.phone__c==null) {
	  		userShipTo.Ship_To__r.phone__c='No Phone';
	  	}
	  	if (userShipTo.Ship_To__r.zip__c==null) {
	  		userShipTo.Ship_To__r.zip__c='Unknown';
	  	}
	  	if (userShipTo.Ship_To__r.state__c==null) {
	  		userShipTo.Ship_To__r.state__c='Unknown';
	  	}
		
    	
    }
    
    public static void updateMagentoShipTos (List<User_Ship_To__c> userShipTos) {
        
        List<REST_Queue_Message__c> messages = new List<REST_Queue_Message__c>(); 
        for (User_Ship_To__c userShipTo:userShipTos) {
        	if (userShipTo.Magento_Ship_To_ID__c!=null) { 	
        		handleEmptyValues(userShipTo);
	        	
    			String apiArguments = getUpdateApiArgs(userShipTo);
	          
        										
	    		REST_Queue_Message__c msg = POS_MagentoIntegrationUtil.createAsyncMagentoCall ('customer_address.update', apiArguments, userShipTo.Id, 'User_Ship_To__c','Magento_Ship_To_ID__c');
	    		messages.add(msg);   
        	}
        }
        
        POS_MagentoIntegrationUtil.bulkSaveMagentoCallToQueue(messages);
    }
  
    //Added shipToId for case 00003923 - Diana - 2/22/2013
    public static String insertMagentoShipTo (String magentoCustomerId, String attention, 
	  String phone, String zip, String state, String city, String street, 
	  String name, String accountName, String shipToId) {
	  	
	  	//Need to set some default values since Magento requires them.  Not relevant in final shipping as that's
	  	//all driven from Salesforce
	  	if (attention==null) {
	  		attention='Attn: Receiving Department';
	  	}
	  	else {
	  		String temp='Attn: '+attention;
	  		attention=temp;
	  	}
	  	
	  	if (city==null) {
	  		city='Unknown';
	  	}
	  	if (street==null) {
	  		street='Unknown';
	  	}
	  	if (phone==null) {
	  		phone='No Phone';
	  	}
	  	if (zip==null) {
	  		zip='Unknown';
	  	}
	  	if (state==null) {
	  		state='Unknown';
	  	}
	  	
        //Added shipto_id arg for Case 00003923 - Diana - 2/22/2013
        String API_ARGUMENTS = '&arg2[customerId]=' + EncodingUtil.urlEncode(magentoCustomerId,'UTF-8') + 
          	'&arg2[customer_address][firstname]='+ EncodingUtil.urlEncode(name,'UTF-8') + 
          	'&arg2[customer_address][lastname]='+ EncodingUtil.urlEncode(attention,'UTF-8') + 
          	'&arg2[customer_address][country_id]=US'+
          	'&arg2[customer_address][city]='+ EncodingUtil.urlEncode(city,'UTF-8') +
          	'&arg2[customer_address][street]='+ EncodingUtil.urlEncode(street,'UTF-8') +
          	'&arg2[customer_address][telephone]='+ EncodingUtil.urlEncode(phone,'UTF-8') +
          	'&arg2[customer_address][postcode]='+ EncodingUtil.urlEncode(zip,'UTF-8') +
          	'&arg2[customer_address][region]='+ EncodingUtil.urlEncode(state,'UTF-8') + 
          	'&arg2[customer_address][mcarts_group]='+EncodingUtil.urlEncode(accountName,'UTF-8') + 
          	'&arg2[customer_address][shipto_id]='+EncodingUtil.urlEncode(shipToId,'UTF-8') + 
            '&arg2[customer_address][is_default_shipping]=true';
            
          	
        System.debug('Args for magento insert: '+API_ARGUMENTS);  	 
        Dom.Document doc = POS_MagentoIntegrationUtil.getMagentoCallDocument('customer_address.create', API_ARGUMENTS);
	  	String status = POS_MagentoIntegrationUtil.getMagentoResponseElement(doc, 'status');
    	if (status=='success') {
    		String magentoShipToId = POS_MagentoIntegrationUtil.getMagentoResponseElement(doc, 'response');
    		return magentoShipToId;
    	}
    	return null; //Failed so return null
    	
    }
    
    
  
    
}