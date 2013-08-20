/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        07/12/2012
 * @description Class representing Product Custom Option Object in Magento that maps to ItemCustomization in SFDC, contains REST call methods supporting sync b/w these two.
 */

public with sharing class POS_MagentoProductOption {
	
	private static Profile apiProfile = [select Id, Name from Profile where Name='POS - API User Agency'];
	
	          
          //&apiPath=product_custom_option.add&arg2[id]=a0ZZ0000000VNSFMA4&arg2[1][title]=Test3&arg2[1][type]=field&arg2[1][is_require]=1&agr2[sort_order]=0&arg2[1][additional_fields][0][price]=10&arg2[1][additional_fields][0][price_type]=fixed&arg2[1][additional_fields][0][sku]=custom_text_option_sku&arg2[1][additional_fields][0][max_characters]=255
          // Not applicable for this - &agr2[sort_order]=0&arg2[1][additional_fields][0][price]=10&arg2[1][additional_fields][0][price_type]=fixed&arg2[1][additional_fields][0][sku]=custom_text_option_sku
    public static void syncMagentoProductOption(Item_Customization__c iCust, String action) { // action could be create or update	

		String API_CALL = '';
		String API_ARGUMENTS = '';
		
		if (action == 'update') {
			API_CALL = 'product_custom_option.update';
			API_ARGUMENTS = '&arg2[id]=' + EncodingUtil.urlEncode(iCust.Magento_ID__c+'','UTF-8');
			
		} else { // 
			API_CALL = 'product_custom_option.add';
			API_ARGUMENTS = '&arg2[id]=' + EncodingUtil.urlEncode(iCust.Item__c+'','UTF-8');
		}		

	    System.debug('iCust -' + iCust);
        API_ARGUMENTS = API_ARGUMENTS + 
          '&arg2[1][title]=' + EncodingUtil.urlEncode(iCust.Name+'','UTF-8') + //Custom_Attribute_Label
          '&arg2[1][type]=field&arg2[1][is_require]=1' +
          '&arg2[1][additional_fields][0][max_characters]=' + EncodingUtil.urlEncode(iCust.Custom_Attribute_Length__c+'','UTF-8');
          
        try { // the callout and post callout processing needs to be handled to avoid rollback from Queue insert in case of error
        	
        	// IMP: Standard MagentoId update mechanism will not work for this as product_custom_option.add always returns 1 as magentoId. 
        	// The option_id update back to SFDC is handled separately by retrieving the product_custom_option.list in the POS_MagentoIntegrationUtil
	        
	        savePostMagento(API_CALL, API_ARGUMENTS, '', ''); // call to add/update Option, 3rd, 4th parameter passed '' as to skip updateRecordWithMagentoId call
	        
	       // Call product_custom_option.list by passing Product sku (SFDC Id), this will take care of updateRecordWithMagentoId
	       if (action == 'create') {
		       // IMP: Save to Queue is must here even for non Agency Profiles as the Order of Future call execution cannot be controlled
				POS_MagentoIntegrationUtil.saveMagentoCallToQueue('product_custom_option.list', '&arg2[id]=' + EncodingUtil.urlEncode(iCust.Item__c+'','UTF-8'), iCust.Id, 'Item_Customization__c');
	       }	
	        

        } catch(Exception e) {
        	// do nothing
        }
    }
    
    
    public static void deleteMagentoProductOption(String iCustMagentoId) {
    
	    String API_ARGUMENTS = '&arg2[Id]='+ iCustMagentoId;
	        
	    try { // the whole callout and post processing needs to be handled to avoid rollback from Queue insert in case of error
	        Dom.Document doc = savePostMagento('product_custom_option.remove', API_ARGUMENTS, '', '');
			System.debug('response doc -' + doc);
			
        } catch(Exception e) {
        	// do nothing
        }
    } 

    
    @Future(callout=true)
    private static void postMagentoCallDocument (String apiPath, String optionalArguments, String sObjId, String sObjTypeName) {
    	POS_MagentoIntegrationUtil.postMagentoCallDocument(apiPath, optionalArguments, sObjId, sObjTypeName);
    	
    }
    
    private static Dom.Document savePostMagento (String apiPath, String optionalArguments, String sObjId, String sObjTypeName) {
    	//Implementation note: this will route any call not executed by one of the API profiles 
    	//To an @future call to get the updates in more or less real-time.  If there are bulk uploads of
    	//data this could cause issues.  That problem can be avoided by using an API profile when doing a bulk upload
    	
    	Id currentProfile = UserInfo.getProfileId();
    	System.debug('Is it an API Profile: '+(currentProfile == apiProfile.Id));
    	if (currentProfile == apiProfile.Id) {
    		//It's an API user, so queue it up
    		return POS_MagentoIntegrationUtil.saveMagentoCallToQueue(apiPath, optionalArguments, sObjId, sObjTypeName);
    	
    	}
    	else {
    		//Not an API User, so we execute using a @future call
    		postMagentoCallDocument(apiPath, optionalArguments, sObjId, sObjTypeName);
    		return new Dom.Document(); //This is a future call so can't return anything
    	}
    }
    
    
    
    
    @isTest(SeeAllData=true)
    public static void testMagentoProductOptionSync() {
    	
    	
	    Account agency = POS_TestDataUtil.createProductionAgency();
	   
	    Program__c program1 = POS_TestDataUtil.createProgram();
	    Item__c item11 = POS_TestDataUtil.populateItem(program1, agency);
	    item11.RecordTypeId = [select Id, Name, DeveloperName from RecordType where DeveloperName='Customizable' limit 1].id;
	    insert item11;
    	    	 
		Item_Customization__c iCust = new Item_Customization__c(Name='Personalization Label 1', Custom_Attribute_Length__c=120, Item__c=item11.Id);
		insert iCust;
    	// this being a sync CallOut test UnitTest doesn't support the assertion in a meaningful way.
    	
		Profile p = [select id from profile where name='POS - API User Agency'];
         
		User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id,
		timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
		
		System.runAs(u) {  
			Test.startTest();
		    Account agency2 = POS_TestDataUtil.createProductionAgency();
		    		
		    Program__c program2 = POS_TestDataUtil.createProgram();
		    Item__c item12 = POS_TestDataUtil.populateItem(program2, agency2);
		    item12.RecordTypeId = [select Id, Name, DeveloperName from RecordType where DeveloperName='Customizable' limit 1].id;
		    insert item12;
	    	    	 
			Item_Customization__c iCust2 = new Item_Customization__c(Name='Personalization Label 1', Custom_Attribute_Length__c=120, Item__c=item12.Id);
			insert iCust2;
			
			iCust2.Name = 'Personalization Label 2';
			update iCust2;
			
			delete iCUst2;	
			Test.stopTest();		  
		}	
  	
  		
    }       
    


}