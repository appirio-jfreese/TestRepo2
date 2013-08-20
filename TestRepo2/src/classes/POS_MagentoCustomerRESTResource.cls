/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        05/04/2012
 * @description Class exposing User and User Access details as REST Outbound service.
 */

@RestResource(urlMapping='/getmagentocustomer/*')
global with sharing class POS_MagentoCustomerRESTResource {

  
    @HttpGet
    global static MagentoUserAccess doGet() {
    	
    	Profile magentoProfile = [select Id from Profile where Name='POS - API User Magento'];
    	
    	
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        Map<String, String> pMap = req.params;
        String userSfdcId = pMap.get('sfdcid');
        String userMagentoId = pMap.get('magentoid');
         
        
        if (userSfdcId==null) {
            res.StatusCode = 400;
            res.addHeader('Error','required parameter "sfdcid" is missing');
            
            return null;
        }  
        
        
        if (userMagentoId==null) {
            res.StatusCode = 400;
            res.addHeader('Error','required parameter "magentoid" is missing');
            
            return null;
        }               
        
        
        
        System.debug('userSfdcId ' + userSfdcId + ' userMagentoId ' + userMagentoId);
        User usr = [Select u.UserType, u.Title, u.Street, u.State, u.PostalCode, u.Phone, u.POS_Access__c, u.Name, 
                    u.Magento_Id__c, u.LastName, u.IsActive, u.Id, u.FirstName, u.FederationIdentifier, u.Email, u.Profile.Name,
                    u.Country, u.ContactId, u.CompanyName, u.City, u.AccountId, u.AboutMe From User u where u.id=:userSfdcId];
                
        boolean updateMagentoId=false;  
        if(userMagentoId != null && usr.Magento_Id__c == null) {
            usr.Magento_Id__c = userMagentoId;
            if (UserInfo.getProfileId()==magentoProfile.Id) {
            	//Only allow Diageo Magento to touch this
            	updateMagentoId = true;
            }
        }
        
        Boolean isPortalUser = false;
        if (usr.Profile.Name.indexOf('Portal User')>-1) {
            isPortalUser = true;
        }       
        
        Boolean isAdminUser = false;
        if (usr.Profile.Name == 'POS - CM Administrator' || usr.Profile.Name == 'System Administrator') {
            isAdminUser = true;
        }       
        List <AccountBrand__c> accessibleBrands = [SELECT Brand__r.Magento_Id__c FROM AccountBrand__c where Account__c in 
                                                        (SELECT Account__c FROM Account_Member__c where Active__c=true and User__c = :userSfdcId)];
        
        //Note: Active order windows is ALL order windows for the user.  Then the "no add" windows are sent as a subset of all windows
        List <Order_Window_Customer__c> activeOrderWindows = [Select o.Order_Window__r.Magento_Id__c, o.Order_Window__r.Name, o.Customer__r.Magento_Id__c, o.Magento_Id__c From Order_Window_Customer__c o where o.Customer__c = :userSfdcId];
        List <Order_Window_Customer__c> noaddOrderWindows = [Select o.Order_Window__r.Magento_Id__c, o.Order_Window__r.Name, o.Customer__r.Magento_Id__c, o.Magento_Id__c From Order_Window_Customer__c o where o.Open_For_Shopping__c=false and o.Customer__c = :userSfdcId];
        List <Budget__c> orderWindowBudget = [SELECT Order_Window__c, Order_Window__r.Magento_Id__c, Order_Window__r.Name, Brand__c, Brand__r.Magento_Id__c, Brand__r.Name, Remaining_Amount__c, Unallocated_Amount__c, Item__c, Item__r.Magento_Id__c, Item__r.Name, Remaining_Item_Quantity__c, Unallocated_Item_Quantity__c 
        										FROM Budget__c where Shopper__c=:userSfdcId and Order_Window__c in (Select o.Order_Window__c From Order_Window_Customer__c o where o.Open_For_Shopping__c=true and o.Customer__c = :userSfdcId) order by Order_Window__r.Name, Brand__r.Name ASC];
        
        // aggregate budgets if multiple of them exist for same OW, Brand
        Map<String, Budget> owBudgetAggregatedMap = new Map<String, Budget>(); // key string here will be OWId+BrandId composite key
        for(Budget__c bud :orderWindowBudget) {
        	String budKey = bud.Order_Window__c;
        	// given Budget line item will either have Brand or Item associated.
        	if(bud.Brand__c != null) {
        		budKey = budKey + bud.Brand__c;
        	} else if (bud.Item__c != null) {
        		budKey = budKey + bud.Item__c;
        	}
        	
        	Budget budAggregated = owBudgetAggregatedMap.get(budKey);
        	if(budAggregated == null) {
        		owBudgetAggregatedMap.put(budKey, new Budget(bud));
        		
        	} else {
        		budAggregated.Remaining_Amount = budAggregated.Remaining_Amount + bud.Remaining_Amount__c;
        		budAggregated.Remaining_Item_Quantity = budAggregated.Remaining_Item_Quantity + bud.Remaining_Item_Quantity__c;
        		
        		budAggregated.Unallocated_Amount = budAggregated.Unallocated_Amount + bud.Unallocated_Amount__c;
        		budAggregated.Unallocated_Item_Quantity = budAggregated.Unallocated_Item_Quantity + bud.Unallocated_Item_Quantity__c;
        	}
        }
        
        List <Budget> orderWindowBudgetAggregated = owBudgetAggregatedMap.values();
		// end: Aggregation logic        
        
        String msessionId = POS_MagentoIntegrationUtil.getMagentoSessionId();
        Map<String,String> orderWindowsWithCarts = getOrderWindowsWithCarts(usr, msessionId);
        
        
        // if cart corresponding to a activeOrderWindow of a given user is not created, create it through callout to Magento
        List <Order_Window_Customer__c> uOrderWindows = new List <Order_Window_Customer__c>();
        String API_CALL = 'metrics_carts.create';
        String API_ARGUMENTS = '';
        
        System.debug('ACTIVE WINDOWS: '+activeOrderWindows);
        System.debug('NO ADD WINDOWS: '+noaddOrderWindows);
        System.debug('WINDOW BUDGETS: '+orderWindowBudget);
        
        if (UserInfo.getProfileId()==magentoProfile.Id) {
        	//Only push through updates for Diageo magento server
	        for(Order_Window_Customer__c aOWC :activeOrderWindows) {
	            System.debug('OWC: '+aOWC);
	            if(aOWC.Magento_Id__c == null) {
	                if (aOWC.Customer__r.Magento_Id__c==null) {
	                    aOWC.Customer__r.Magento_Id__c = userMagentoId;
	                }
	                String cartMagentoId = orderWindowsWithCarts.get(aOwc.Order_Window__r.Magento_Id__c);
	                if (cartMagentoId != null && cartMagentoId!='0') {
	                    aOWC.Magento_Id__c = cartMagentoId;
	                    uOrderWindows.add(aOWC);
	                }
	                else {
	                    API_ARGUMENTS = '&arg2[0][customer_id]=' + EncodingUtil.urlEncode(aOWC.Customer__r.Magento_Id__c+'','UTF-8') +
	                     '&arg2[0][cart_name]=' + EncodingUtil.urlEncode('Cart_'+ aOWC.Order_Window__r.Name, 'UTF-8') +
	                     '&arg2[0][order_window_id]='+ aOWC.Order_Window__r.Magento_Id__c;
	                    Dom.Document resp = POS_MagentoIntegrationUtil.getMagentoCallDocument(msessionId, API_CALL, API_ARGUMENTS);
	                    String status = POS_MagentoIntegrationUtil.getMagentoResponseElement(resp, 'status');
	                    System.debug('STATUS: '+status);
	                    if(status == 'success') {
	                        aOWC.Magento_Id__c = POS_MagentoIntegrationUtil.getMagentoResponseElement(resp, 'response');
	                        uOrderWindows.add(aOWC);
	                    }
	                }
	            }
	        }
        }
        
        //ALL DB UPDATES MUST HAPPEN AFTER REQUESTS TO MAGENTO ARE GENERATED
        
        // update User record if the magento customer Id is not yet stored in SFDC
        if(updateMagentoId) {
            usr.Magento_Id__c = userMagentoId;
            update usr;
        }       
        
        // update the OWC with cartId from the newly created carts
        if(uOrderWindows.size() > 0) {
            update(uOrderWindows);
        }
        
                            
        MagentoUserAccess result = new MagentoUserAccess();
        result.diageo_user = usr;
        result.user_brands = accessibleBrands;
        
       // if (UserInfo.getProfileId()==magentoProfile.Id) {
	        result.is_admin_user = isAdminUser;
	        result.is_portal_user = isPortalUser;
	        result.user_active_windows = activeOrderWindows;
	        result.order_window_budget = orderWindowBudgetAggregated;
	        result.user_noadd_windows = noaddOrderWindows;
	        
	        System.debug('User brands: '+result.user_brands);
        
	        String host = System.URL.getSalesforceBaseUrl().getHost();
	        
	        if (isPortalUser) {
	            result.redirect_url = POS_Magento_Configuration__c.getOrgDefaults().Portal_Redirect_URL__c; 
	        }
	        else {
	            result.redirect_url = 'https://'+host;
	        }
	        
        //}
        
        System.debug('RESULT: '+result);
                        
                                                        
        return result;
    }
    
    private static Map<String,String> getOrderWindowsWithCarts (User user, String mSessionId) {
        Map<String,String> windows = new Map<String,String>();
        String API_CALL = 'metrics_carts.list';
        String API_ARGUMENTS = '';
        
        System.debug('Getting order windows on Magento already');
        
        API_ARGUMENTS = '&arg2[0][customer_id]=' + EncodingUtil.urlEncode(user.Magento_Id__c+'','UTF-8');
        Dom.Document resp = POS_MagentoIntegrationUtil.getMagentoCallDocument(mSessionId, API_CALL, API_ARGUMENTS);
        String status = POS_MagentoIntegrationUtil.getMagentoResponseElement(resp, 'status');
        if (status=='success') {
            System.debug('Success');
            //Success, now parse dom to get order window id's
            Dom.XMLNode apiResponse = resp.getRootElement();
            Dom.XMLNode call = apiResponse.getChildElement('call',null);
            Dom.XMLNode carts = call.getChildElement('carts',null);
            if (carts!=null) {
                List<Dom.XMLNode> keys = carts.getChildElements();
                for (Dom.XMLNode key:keys) {
                    String windowId = key.getChildElement('order_window_id',null).getText();
                    String cartMagentoId = key.getChildElement('cart_id',null).getText();
                    System.debug('Order window: '+windowId+'->'+cartMagentoId);
                    windows.put(windowId,cartMagentoId);
                }
            }
        }
        return windows;
    }
    
    global class MagentoUserAccess {
        global String redirect_url {get;set;}
        global Boolean is_portal_user {get;set;}
        global Boolean is_admin_user {get; set;} 
        global User diageo_user { get; set; }
        global List <AccountBrand__c> user_brands { get; set; }
        global List <Order_Window_Customer__c> user_active_windows { get; set; }
        global List <Budget> order_window_budget { get; set; }
        global List <Order_Window_Customer__c> user_noadd_windows { get; set; }

    }    
    
   // SELECT Order_Window__c, Order_Window__r.Magento_Id__c, Order_Window__r.Name, Brand__c, Brand__r.Magento_Id__c, Brand__r.Name, Remaining_Amount__c, Unallocated_Amount__c, Item__c, Item__r.Magento_Id__c, Item__r.Name, Remaining_Item_Quantity__c, Unallocated_Item_Quantity__c 
        										//FROM Budget__c where Shopper__c=:userSfdcId and Order_Window__c in (Select o.Order_Window__c From Order_Window_Customer__c o where o.Open_For_Shopping__c=true and o.Customer__c = :userSfdcId) order by Order_Window__r.Name, Brand__r.Name ASC];
        
    
    public class Budget {
    	
    	Id Order_Window_SfdcId {get;set;}
    	String Order_Window_MagentoId {get;set;}
    	
    	Id Brand_SfdcId {get;set;}
    	String Brand_MagentoId {get;set;}
    	
    	Id Item_SfdcId {get;set;}
    	String Item_MagentoId {get;set;}
    	
    	double Remaining_Amount {get;set;}
    	double Remaining_Item_Quantity {get;set;}
    	
    	double Unallocated_Amount {get;set;}
    	double Unallocated_Item_Quantity {get;set;}
    	
    	public Budget(Budget__c bud) {
    		Order_Window_SfdcId = bud.Order_Window__c;
    		Order_Window_MagentoId = bud.Order_Window__r.Magento_Id__c;
    		
    		Brand_SfdcId = bud.Brand__c;
    		Brand_MagentoId = bud.Brand__r.Magento_Id__c;
    		
    		Item_SfdcId = bud.Item__c;
    		Item_MagentoId = bud.Item__r.Magento_Id__c;
    		
    		Remaining_Amount = bud.Remaining_Amount__c;
    		Remaining_Item_Quantity = bud.Remaining_Item_Quantity__c;
    		Unallocated_Amount = bud.Unallocated_Amount__c;
    		Unallocated_Item_Quantity = bud.Unallocated_Item_Quantity__c;
    	}    	
    }
    
    
    @isTest(SeeAllData=true) // required as the End-Point required for getting Magento session is stored as Custom Setting
    static void testDoGet() {
        
        // setup test data
        User u = POS_TestDataUtil.createStdUser();
        u.Magento_Id__c = '212';
        update u;
        
        Account a =  POS_TestDataUtil.createAccount();
        Account_Member__c am = POS_TestDataUtil.createAccountMember(a, u);
        Brand__c b = POS_TestDataUtil.createBrand();
        AccountBrand__c ab = POS_TestDataUtil.createAccountBrand(a, b);
        System.debug('u.id -' + u.id);
  
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.addParameter('sfdcid', u.id);
        req.addParameter('magentoid', u.Magento_Id__c);
    
        req.requestURI =  POS_Magento_Configuration__c.getOrgDefaults().Salesforce_apexrest_uri__c +'getmagentocustomer';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
    
        MagentoUserAccess result = POS_MagentoCustomerRESTResource.doGet();
        System.debug('results.size() -' + result);
        System.debug('results.size() -' + result.user_brands.size());
        
        System.assertEquals(1, result.user_brands.size());
 
   }
  

}