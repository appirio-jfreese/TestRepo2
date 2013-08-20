/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        05/02/2012
 * @description Class representing Product Object in Magento that maps to Item in SFDC, contains REST call methods supporting sync b/w the these two.
 */

public with sharing class POS_MagentoProduct {
	
	private static Profile apiProfile = [select Id, Name from Profile where Name='POS - API User Agency'];
	//private static RecordType customizableType = [select Id, Name, DeveloperName from RecordType where DeveloperName='Customizable' and sObjectType='Item__c'];
	
	public static void syncMagentoProduct(Item__c itm, String action, Boolean useFutureCall) {
		 syncMagentoProduct(itm, action, useFutureCall, false);
	}
	
    public static void syncMagentoProduct(Item__c itm, String action, Boolean useFutureCall, Boolean changeRollupSelection) { // action could be create or update	
        
        String DEFAULT_TYPE = 'virtual'; //virtual magento product - doesn't require weight attribute
        String DEFAULT_SET = '4'; //magento default attribute set for product
        String ROLLUP_TYPE = 'configurable'; //configurable magento product that allows simple child products as variations
        String SIMPLE_TYPE = 'simple';
        String ROLLUP_SET = '10'; // magento attribute set for product configurable complex product
                
        String DEFAULT_TAX_CLASS = '2'; //0 - None, 2 - taxable Goods, 4 - Shipping
        String DEFAULT_VISIBILITY = '4'; //1. Not Visible Individually, 2. Catalog 3. Search 4. Catalog, Search
        String DEFAULT_STATUS = '1'; // 1 = Enabled, 2 = Disabled
		
		String magentoCategoryAPIString = getProductCategoryAPIString(itm);
		String magentoStatusAPIString = getProductStatusAPIString(itm);
		System.debug('magentoCategoryAPIString -' + magentoCategoryAPIString + ' magentoStatusAPIString -' + magentoStatusAPIString);
		
		String API_CALL = 'product.create';
		String API_ARGUMENTS = '&arg2[type]=' + DEFAULT_TYPE + '&arg2[set]=' + DEFAULT_SET;
		
		Boolean customizable = false;
		if(itm.RecordType.DeveloperName == 'Customizable') { // Magento Customizable Product
			customizable = true;
			
		} else if(itm.RecordType.DeveloperName == 'Roll_Up') { // Magento Configurable Product
			API_ARGUMENTS = '&arg2[type]=' + ROLLUP_TYPE + '&arg2[set]=' + ROLLUP_SET;
			
		} else if(itm.Parent__c != null) { // Magento Simple Product this is associated as a variation of a Configurable Product
			//Note: Rollup Child must be created as SIMPLE_TYPE, Virtual will not work even if the configurable attribute 'diageo_rollup_selection' is applied to Virtual in Magento
			API_ARGUMENTS = '&arg2[type]=' + SIMPLE_TYPE + '&arg2[set]=' + ROLLUP_SET;
			DEFAULT_VISIBILITY = '3'; // ROLLUP_CHILD - Search
			
		} else if(itm.Kit_Only__c == true) { // 
			DEFAULT_VISIBILITY = '1'; // Kit Only CHILD - Not Visible Individually
		}
		
		if(itm.Status__c == 'Development') { // || itm.Status__c == 'Cancelled') {
			DEFAULT_VISIBILITY = '3'; // Search Only (Admins will be able to access this with direct link // Or will be visible in Cart if added already )
		} else if(itm.Status__c == 'Cancelled') {
			DEFAULT_VISIBILITY = '1'; // Not Visible Individually
		}
		
		System.debug('itm.Kit_Only__c ' + itm.Kit_Only__c);
		String isKitOnly='0';
		if(itm.Kit_Only__c){
			isKitOnly='1';
		}		
		
		String sfObjName = 'Item__c';
		if (action == 'update') {
			API_CALL = 'product.update';
			API_ARGUMENTS = ''; // type and set cannot be changed during update
			sfObjName = ''; // will NOT update the Magento_Id back to SFDC
		}	
		system.debug('==============API_ARGUMENT======='+API_ARGUMENTS);
		String primaryBrandMagentoId;
		for(Item_Brand__c ib:itm.Item_Brands__r) {
			if(ib.Primary__c) {
				primaryBrandMagentoId = ib.Brand__r.Magento_Id__c;
				break;
			}
		}

	    System.debug('itm -' + itm + ' itm.Program__r -' + itm.Program__r);
        API_ARGUMENTS = API_ARGUMENTS + 
          '&arg2[id]=' + EncodingUtil.urlEncode(itm.Id+'','UTF-8') +  // adding empty +'' to avoid NullPointer when this data is not passed by Agent API call
          '&arg2[product][name]=' + EncodingUtil.urlEncode(itm.Name+'','UTF-8') +
          '&arg2[product][tax_class_id]=' + DEFAULT_TAX_CLASS +
          '&arg2[product][meta_title]=' + EncodingUtil.urlEncode(itm.Name+'','UTF-8') + 
          '&arg2[product][short_description]=' + EncodingUtil.urlEncode(itm.Description__c+'','UTF-8') +
          '&arg2[product][description]=' + EncodingUtil.urlEncode(itm.Description__c+'','UTF-8') +
          '&arg2[product][price]=' + EncodingUtil.urlEncode(itm.Current_Price__c+'','UTF-8') + // changed from Estimated_Price__c per DE152
          '&arg2[product][diageo_category]=' + EncodingUtil.urlEncode(itm.Category__c+'','UTF-8') +
          '&arg2[product][diageo_minimum_quantity]=' + EncodingUtil.urlEncode(itm.Minimum_Quantity__c+'','UTF-8') +
          '&arg2[product][diageo_packout_quantity]=' + EncodingUtil.urlEncode(itm.Packout_Quantity__c+'','UTF-8') +
          '&arg2[product][diageo_is_customizable]=' + EncodingUtil.urlEncode(customizable+'','UTF-8') +
          '&arg2[product][diageo_item_category]=' + EncodingUtil.urlEncode(itm.Item_Category__r.Friendly_Name__c+'','UTF-8') +
          '&arg2[product][diageo_tax]=' + EncodingUtil.urlEncode(itm.Estimated_Shipping_Tax__c+'','UTF-8') +
          '&arg2[product][diageo_kit_only]=' + EncodingUtil.urlEncode(isKitOnly+'','UTF-8') +
          '&arg2[product][visibility]=' + DEFAULT_VISIBILITY + magentoCategoryAPIString + magentoStatusAPIString;
          
      if(primaryBrandMagentoId != null) {
      	API_ARGUMENTS = API_ARGUMENTS + '&arg2[product][diageo_brand]=' + EncodingUtil.urlEncode(primaryBrandMagentoId+'','UTF-8');
      }
      
      // pass all child variation Items as associated_skus, update on parent will be triggered everytime a Child is either added or Deleted
      if(itm.RecordType.DeveloperName == 'Roll_Up') {
      		useFutureCall = false;
      		if(action == 'update') {
      			API_ARGUMENTS = API_ARGUMENTS + getAssociatedSKUsAPIString(itm);
      		}
      		system.debug('=======API_ARGUMENTS====1111=='+API_ARGUMENTS);
      		
      } else if (itm.Parent__c != null) {
      	
      		// addOption corresponding to the child Item if it doesn't exists already
      		
	      	System.debug('action -' + action);
	      	//addRollupAssociation(itm.Parent__c, itm.Id);
	      	useFutureCall = false;
	      	
	      	if(action == 'create' || changeRollupSelection) { // will involve updating the parent to reflect association, Queue will ensure order of execution
	      		addOptionToRollupSelection(itm); // always routed through Queue to ensure callout order sequence
      		}
      		
      		if(itm.Magento_Option_ID__c != null) { // will be set for rollup child on Update
      			API_ARGUMENTS = API_ARGUMENTS + '&arg2[product][diageo_rollup_selection]=' + itm.Magento_Option_ID__c;
      		}
      }
          
        try { // the callout and post callout processing needs to be handled to avoid rollback from Queue insert in case of error
	        Dom.Document doc = savePostMagento(API_CALL, API_ARGUMENTS, itm.Id, sfObjName, useFutureCall);
	        System.debug('message posted with useFutureCall -' + useFutureCall + ' API_CALL -' + API_CALL);
	        
	       // Dom.XMLNode root = doc.getRootElement();
        } catch(Exception e) {
        	// do nothing
        }
        
      if(itm.RecordType.DeveloperName == 'Roll_Up' || (itm.RecordType.DeveloperName == 'Kit' && action == 'create')) {
      		// will set - Manage stock = Yes, Stock availability = In stock
      		updateParentInvetoryAttributes(itm); // always routed through Queue to ensure callout order sequence
      }        
    }
    
    private static void addOptionToRollupSelection(Item__c chlItem) {

    	// reaches here when there is no option corresponding to this already.
		String API_CALL = 'product_attribute.addOption';
        // Changes done for case 00040529 by Jai Gupta [Appirio Jaipur] on April 1st 2013
        //String API_ARGUMENTS='&arg2[0]=diageo_rollup_selection&arg2[1][is_default]=0&arg2[1][order]=0&arg2[1][label][0][store_id]=0&arg2[1][label][0][value]=';
        String API_ARGUMENTS='&arg2[0]=diageo_rollup_selection&arg2[1][is_default]=0&arg2[1][order]=0&arg2[1][is_percent]=0&arg2[1][pricing_value]='+chlItem.current_price__C+'&arg2[1][label][0][store_id]=0&arg2[1][label][0][value]=';
        // End for case 00040529
        API_ARGUMENTS = API_ARGUMENTS + chlItem.Name;
        
        System.debug('addOptionToRollupSelection -' + chlItem.Id+'-'+chlItem.Name);
        	
    	try { // the callout and post callout processing needs to be handled to avoid rollback from Queue insert in case of error
	        savePostMagento(API_CALL, API_ARGUMENTS, null, null, false);
	        
	       // IMP: Save to Queue is must here even for non Agency Profiles as the Order of Future call execution cannot be controlled
			savePostMagento('product_attribute.options', '&arg2[0]=diageo_rollup_selection', chlItem.Id+'-'+chlItem.Name, 'Item_Category__c', false);	        
	        
        } catch(Exception e) {
        	// do nothing
        	System.debug('addOptionToRollupSelection -' + e.getStackTraceString());
        }

    }    
    
/*    
    private static String addOptionToRollupSelection(Item__c chlItem) {
    	
    	// check if an Optin with this Name already exists, create one if it doesn't
    	String msessionId = POS_MagentoIntegrationUtil.getMagentoSessionId();
    	String existingOptionId = getOptionFromRollupSelection(msessionId, chlItem);
    	
    	System.debug('existingOptionId =' + existingOptionId);
    	if (existingOptionId != null) {
    		return existingOptionId;
    	}
    	
    	// reaches here when there is no option corresponding to this already.
		String API_CALL = 'product_attribute.addOption';
        String API_ARGUMENTS='&arg2[0]=diageo_rollup_selection&arg2[1][is_default]=0&arg2[1][order]=0&arg2[1][label][0][store_id]=0&arg2[1][label][0][value]=';
        
        API_ARGUMENTS = API_ARGUMENTS + chlItem.Name;  
        	
    	try { // the callout and post callout processing needs to be handled to avoid rollback from Queue insert in case of error
	        Dom.Document doc = savePostMagento(API_CALL, API_ARGUMENTS, null, null, true);
	        System.debug('response doc -' + doc.toXmlString());
	        
        } catch(Exception e) {
        	// do nothing
        }
        
        for(Integer i=0; i < 2; i++) { // make 2 attempts to be the Id corresponding to the newly created Option
        	existingOptionId = getOptionFromRollupSelection(msessionId, chlItem);
        	
        	System.debug('existingOptionId =' + existingOptionId);
	    	if (existingOptionId != null) {
	    		return existingOptionId;
	    	}
        }
        
         // TODO - handle this case where the Option is not yet setup.
         return '0';
    } */
    
   /*  private static void addRollupAssociation(Id pItemId, Id cItemId) { 

		String API_CALL='product_link.assign';
        String API_ARGUMENTS='&arg2[linkType]=grouped&arg2[productId]='+pItemId+
          '&arg2[linkedProduct]='+cItemId;
          
        try { // the callout and post callout processing needs to be handled to avoid rollback from Queue insert in case of error
	        Dom.Document doc = savePostMagento(API_CALL, API_ARGUMENTS, null, null, false);
	        System.debug('response doc -' + doc.toXmlString());
	        
	       // Dom.XMLNode root = doc.getRootElement();
        } catch(Exception e) {
        	// do nothing
        }
    }    */
    
    public static void deleteMagentoProduct(String itemId, Boolean useFutureCall) {
    
	    String API_ARGUMENTS = '&arg2[Id]='+ itemId;
	        
	    try { // the whole callout and post processing needs to be handled to avoid rollback from Queue insert in case of error
	        Dom.Document doc = savePostMagento('product.delete', API_ARGUMENTS, itemId, '', useFutureCall);
			System.debug('response doc -' + doc);
			
        } catch(Exception e) {
        	// do nothing
        }
    } 
    
    public static Dom.Document getMagentoProductInfo(String itemId) {
    	
        String API_ARGUMENTS = '&arg2[Id]='+ itemId;
    	Dom.Document doc = POS_MagentoIntegrationUtil.getMagentoCallDocument('product.info', API_ARGUMENTS); // Changes made by Jai Gupta 
    	
    	return doc;
    }   
    
    private static String getProductCategoryAPIString(Item__c itm) {
		// form Magento Categories API String
		Integer ct = 1;
		// add Proram, OrderWindow as Category
		String magentoCategoryAPIString = '&arg2[product][categories][id' + ct.format() + ']=' + itm.Program__r.Magento_Id__c;
		ct++;
		magentoCategoryAPIString = magentoCategoryAPIString + '&arg2[product][categories][id' + ct.format() + ']=' + itm.Program__r.Order_Window__r.Magento_Id__c;
		// add list of Brands as Category
		for(Item_Brand__c ib:itm.Item_Brands__r) {
			ct++;
			magentoCategoryAPIString = magentoCategoryAPIString + '&arg2[product][categories][id' + ct.format() + ']=' + ib.Brand__r.Magento_Id__c;
		}    	
		
		return magentoCategoryAPIString;
    } 
    
    private static String getAssociatedSKUsAPIString(Item__c itm) {

		// form associated_skus API String for a configurable product
		Integer ct = 0;
		String associatedSKUsAPIString = '';

		// add every child as associated variation
		for(Item__c iv:itm.Items__r) {
			ct++;
			associatedSKUsAPIString = associatedSKUsAPIString + '&arg2[product][associated_skus][id' + ct.format() + ']=' + iv.Id;
			// Changes Done for case 00043945 By Jai Gupta [Appirio Jaipur] on April 23,2013
			// Update options field at Magento side
			associatedSKUsAPIString = associatedSKUsAPIString + '&arg2[product][price_changes][diageo_rollup_selection][' + iv.Name +']=' + iv.Current_Price__c;
			system.debug('========associatedSKUsAPIString======'+associatedSKUsAPIString);
			// End for case 00043945
		}    	
		
		return associatedSKUsAPIString;
    }    
    
    

    private static String getProductStatusAPIString(Item__c itm) {
	    String STATE_NORMAL = '0';
	    String STATE_DEVELOPMENT = '100';
	    String STATE_CANCELLED = '200';
	    String STATE_REMOVED = '300';   
	     	
		String status = '1'; //a status of 1 = Enabled 2 = Disabled
		
		if(itm.Status__c=='Removed') {
			status = '2';
		}
		String magentoStatusAPIString = '&arg2[product][status]=' + status;
   		
   		/* commented out this 'diageo_orderable' logic as a new attribute 'diageo_productstate' was introduced on magento to have one on one mapping
   		if(itm.Status__c=='Approved w/Est Price' || itm.Status__c=='Accepted w/Final Price') {
			magentoStatusAPIString = magentoStatusAPIString + '&arg2[product][diageo_orderable]=Yes';
		} else {
			magentoStatusAPIString = magentoStatusAPIString + '&arg2[product][diageo_orderable]=No';
		} */
		
		if(itm.Status__c=='Development') {
			magentoStatusAPIString = magentoStatusAPIString + '&arg2[product][diageo_productstate]=' + STATE_DEVELOPMENT;
		} else if(itm.Status__c=='Cancelled') {
			magentoStatusAPIString = magentoStatusAPIString + '&arg2[product][diageo_productstate]=' + STATE_CANCELLED;
		} else if(itm.Status__c=='Removed') {
			magentoStatusAPIString = magentoStatusAPIString + '&arg2[product][diageo_productstate]=' + STATE_REMOVED;
		} else { // will be 'Approved w/Est Price' , 'Accepted w/Final Price'
			magentoStatusAPIString = magentoStatusAPIString + '&arg2[product][diageo_productstate]=' + STATE_NORMAL;
		}		
		
		
		return magentoStatusAPIString;
    }    
    
    
     public static void syncMagentoKitItem(Kit_Item__c kitItem, String action, Boolean useFutureCall) { // action could be create or update	
        
		
		
		String API_CALL;
		
		
		if (action=='create') {
			API_CALL = 'product_link.assign';
		}
		else {
			API_CALL = 'product_link.remove';
		}
		
		
         
        String API_ARGUMENTS='&arg2[linkType]=up_sell&arg2[productId]='+kitItem.Kit__c+
          '&arg2[linkedProduct]='+kitItem.Item__c;
          
        String sfObjName='Kit_Item__c';
          
        try { // the callout and post callout processing needs to be handled to avoid rollback from Queue insert in case of error
	        Dom.Document doc = savePostMagento(API_CALL, API_ARGUMENTS, kitItem.Id, sfObjName, useFutureCall);
	        System.debug('response doc -' + doc.toXmlString());
	        
	       // Dom.XMLNode root = doc.getRootElement();
        } catch(Exception e) {
        	// do nothing
        }
    }
    
     private static void updateParentInvetoryAttributes(Item__c parent) { // this update is invoked even when Child is added/removed
        
		String API_CALL = 'product_stock.update';
        String API_ARGUMENTS = '&arg2[id]=' + EncodingUtil.urlEncode(parent.Id+'','UTF-8') + '&arg2[product][manage_stock]=1&arg2[product][is_in_stock]=1&arg2[product][qty]=1';
        // &arg2[product][use_config_manage_stock]=0 - is not necessary as the manage_stock is being set as 'Yes'
          
        String sfObjName='Item__c';
        try { // saveMagentoCallToQueue could have been called here EXPLICITLY as sequence of future call execution is not controlled programatically
	        
	        //Dom.Document doc = savePostMagento(API_CALL, API_ARGUMENTS, parent.Id, sfObjName, false);
	        Dom.Document doc = savePostMagento(API_CALL, API_ARGUMENTS, null, null, false);
	        System.debug('response doc -' + doc.toXmlString());
	        
	       // Dom.XMLNode root = doc.getRootElement();
        } catch(Exception e) {
        	// do nothing
        }
    }    
    
    @Future(callout=true)
    private static void postMagentoCallDocument (String apiPath, String optionalArguments, String sObjId, String sObjTypeName) {
    	POS_MagentoIntegrationUtil.postMagentoCallDocument(apiPath, optionalArguments, sObjId, sObjTypeName);
    	
    }
    
    /*private static Dom.Document savePostMagento (String apiPath, String optionalArguments, String sObjId, String sObjTypeName) {
    	//Implementation note: this will route any call not executed by one of the API profiles 
    	//To an @future call to get the updates in more or less real-time.  If there are bulk uploads of
    	//data this could cause issues.  That problem can be avoided by using an API profile when doing
    	//a bulk upload
    	Id currentProfile = UserInfo.getProfileId();
    	System.debug('User: '+UserInfo.getName()+'-'+UserInfo.getProfileId());
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
    }*/
    
    private static Dom.Document savePostMagento (String apiPath, String optionalArguments, String sObjId, String sObjTypeName, Boolean useFutureCall) {
    	//Implementation note: decision of routing through Queue agains @Future will be done by calling Triggers 
    	// based on the # records being handle in that process execution.
		// Also the bulk uploads of made by API Profile are routed through Queue.
		
    	Id currentProfile = UserInfo.getProfileId();
    	System.debug('User: '+UserInfo.getName()+'-'+UserInfo.getProfileId());
    	System.debug('Is it an API Profile: '+(currentProfile == apiProfile.Id));
    	
    	if(useFutureCall && currentProfile != apiProfile.Id) {
    		//Not an API User, so we execute using a @future call
    		postMagentoCallDocument(apiPath, optionalArguments, sObjId, sObjTypeName);
    		return new Dom.Document(); //This is a future call so can't return anything
    		
    	} else {
    		return POS_MagentoIntegrationUtil.saveMagentoCallToQueue(apiPath, optionalArguments, sObjId, sObjTypeName);
    	}
    }    
    
    
    @isTest(SeeAllData=true)
    public static void testMagentoProductSync() {
    	Profile p = [select id from profile where name='POS - API User Agency'];
         
		User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id,
		timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
		
		System.runAs(u) {    	
	    	// test working of POS_Product_Brand Magento Sync part
	    	Test.startTest();
	    	Program__c pg = POS_TestDataUtil.createProgram();
	    	Id brandId = pg.Brand__c;
	    	
	    	Item__c o = POS_TestDataUtil.createItem(pg);
	    	
	    	// no need to create Item Brand as it's created bu the trigger on Item creation
	    	/*Item_Brand__c ib = new Item_Brand__c(Item__c=o.id, Brand__c=brandId);
	    	insert ib;
	    	ib.Primary__c=true;
	    	update ib;
	    	delete ib;*/
	    	o.Current_Price__c=18.99;    	 
	    	o.Estimated_Price__c=18.99;
	    	update o;
	    	Test.stopTest();
	    	
	    	// placing Assert check after Test.stopTest() as triggers here have @future callouts run asynchronously
	    	Dom.Document resp = POS_MagentoProduct.getMagentoProductInfo(o.Id);
	    	String status = POS_MagentoIntegrationUtil.getMagentoResponseElement(resp, 'status');
	    	system.assertEquals( 'success', status );
	    	
	    	// following status change and delete both should cause budget total re-calculation batch to execute
	        Order_Window__c ow = POS_TestDataUtil.createOrderWindow();
	        Cart__c crt = POS_TestDataUtil.createCart(u, ow);	    	
	        Cart_Item__c ci = POS_TestDataUtil.populateCartItem(o, crt);
	        insert ci;	    	
	    	o.Status__c = 'Cancelled';
	    	update o;
	    	
	    	delete o;
		}
    }       
    
    @isTest(SeeAllData=true)
    public static void testItemBrandAssociation() {
    	Profile p = [select id from profile where name='POS - API User Agency'];
         
		User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id,
		timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
		
		System.runAs(u) {    	
	    	// test working of POS_Product_Brand ItemBrand creation part
	    	Program__c pg1 = POS_TestDataUtil.createProgram();
	    	Id brandId1 = pg1.Brand__c;
	    	
	    	
	    	Item__c i1 = POS_TestDataUtil.createItem(pg1);
	    	Item_Brand__c ib1 = [Select id, Brand__c from Item_Brand__c where Item__c = :i1.id][0];
	    	system.assertEquals( brandId1, ib1.Brand__c );
	    	
	    	Test.startTest();
	    	Program__c pg2 = POS_TestDataUtil.createProgram();
	    	Id brandId2 = pg2.Brand__c;
	    	i1.Program__c = pg2.id;
	    	update i1;
	    	
	    	Item_Brand__c ib2 = [Select id, Brand__c from Item_Brand__c where Item__c = :i1.id][0];
	    	system.assertEquals( brandId2, ib2.Brand__c );  
	    	
	    	Test.stopTest(); 
		}   	
    }
    
    @isTest(SeeAllData=true)
    public static void testKitItemTriggerValidations() {
    	
    	Id kitRecTypeId = [select id from RecordType where DeveloperName = 'Kit'].id;
    	Profile p = [select id from profile where name='POS - API User Agency'];
         
		User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id,
		timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
		
		System.runAs(u) {    	
    	
	    	// test working of POS_Product_Brand ItemBrand creation part
	    	Program__c pg1 = POS_TestDataUtil.createProgram();
	    	
	    	Item__c k1 = POS_TestDataUtil.createKit(pg1);
	    	
	    	
	    	Test.startTest();
	    	Item__c i1 = POS_TestDataUtil.createItem(pg1);
	    	
	    	
	    	Kit_Item__c ki1 = new Kit_Item__c(Kit__c=k1.id, Item__c=i1.id, Packout_Quantity__c=5);
	    	insert ki1;
	    	
	    	// 1: move the Kit status to Approved and make sure the validation stops the update as kit has only one Item
	    	k1.Status__c='Approved w/Est Price';
	    	
	        try {
	            update k1;
	        } catch(System.DMLException e) {
	            System.assert(e.getMessage().contains('Kit must contain at least two different items while in status Approved or Accepted'));
	        } 
	        
	        Test.stopTest();
		}
    }
    
    @isTest(SeeAllData=true)
    public static void testKitItemTriggerValidations2() {
    	
    	Id kitRecTypeId = [select id from RecordType where DeveloperName = 'Kit'].id;
    	Profile p = [select id from profile where name='POS - API User Agency'];
         
		User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id,
		timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
		
		System.runAs(u) {    	
    	
	    	// test working of POS_Product_Brand ItemBrand creation part
	    	Program__c pg1 = POS_TestDataUtil.createProgram();
    
	        Test.startTest();
	        
	        Item__c k1 = POS_TestDataUtil.createKit(pg1);
	    	
	    	Item__c i1 = POS_TestDataUtil.createItem(pg1);
	    	
	    	Kit_Item__c ki1 = new Kit_Item__c(Kit__c=k1.id, Item__c=i1.id, Packout_Quantity__c=5);
	    	insert ki1;
	        
	        // 2: add another Kit Item with the same Item reference to the Kit k1, trigger validation should stop this addition    	
			Kit_Item__c ki2 = new Kit_Item__c(Kit__c=k1.id, Item__c=i1.id, Packout_Quantity__c=5);
	        try {
	            insert ki2;
	        } catch(System.DMLException e) {
	            System.assert(e.getMessage().contains('This kit-item already exists on the Kit. Cannot add duplicate.'));
	        } 
	        
		}
    }
    
     @isTest(SeeAllData=true)
    public static void testKitItemTriggerValidations3() {
    	
    	Id kitRecTypeId = [select id from RecordType where DeveloperName = 'Kit'].id;
    	Profile p = [select id from profile where name='POS - API User Agency'];
         
		User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id,
		timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
		
		System.runAs(u) {    	
    	
	    	// test working of POS_Product_Brand ItemBrand creation part
	    	Program__c pg1 = POS_TestDataUtil.createProgram();
    
	        Test.startTest();
	        
	        Item__c k1 = POS_TestDataUtil.createKit(pg1);
	    	
	    	Item__c i1 = POS_TestDataUtil.createItem(pg1);
	    	
	    	Kit_Item__c ki1 = new Kit_Item__c(Kit__c=k1.id, Item__c=i1.id, Packout_Quantity__c=5);
	    	insert ki1;
	        
	        /*
	        // 3: Add a separate Item to the Kit and then it should allow moving the Kit to Aprroved status
	        Item__c i2 = POS_TestDataUtil.createItem(pg1);	
			Kit_Item__c ki2  = new Kit_Item__c(Kit__c=k1.id, Item__c=i2.id, Packout_Quantity__c=5);
	        insert ki2;        	
			update k1;
			
	    	system.assertEquals( 'Approved w/Est Price', k1.Status__c );  
	    	*/  
	    	
	    	// 4: Delete a Kit Item from the already Approved Kit, trigger validation should stop it
	        try {
	            delete ki1;
	        } catch(System.DMLException e) {
	            System.assert(e.getMessage().contains('Kit must contain at least two different items while in status Approved or Accepted'));
	        }    
	        /* 	  	
	    	
	    	// 5: Now add an additional item and see if we can delete it
	    	
	    	Item__c i3 = POS_TestDataUtil.createItem(pg1);	
			Kit_Item__c ki3 = new Kit_Item__c(Kit__c=k1.id, Item__c=i3.id, Packout_Quantity__c=5);
	        insert ki3;        	
			update k1;
			
			try {
				delete ki3;
			}
			catch (System.DMLException e) {
				System.assert(false); //Shouldn't get here
			}*/
			Test.stopTest();
		}
    }    
}