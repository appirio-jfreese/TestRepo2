@RestResource(urlMapping='/GetItemCategories/*')
global with sharing class POS_APIGetItemCategories {

	
	private static String fieldList = ' Name, Customer_Marketing_Category__c, Friendly_Name__c, Material_Code__c, '+ 
	 'Primary_Group__c, Primary_Type__c, IMS_Specification_Id__c from Item_Category__c';
 	  
 	@HttpGet
    global static APICategoryResponse doGet () {
    	RestRequest req=RestContext.request;
    	RestResponse res=RestContext.response;
    	
        String UpdateTime = req.params.get('UpdateTime');   
    	
    	String soql = 'select '+fieldList;
    	if (UpdateTime!=null) {
    		UpdateTime = String.escapeSingleQuotes(UpdateTime);
    		soql = soql +' where SystemModstamp > '+UpdateTime;
    	}
    	
    	System.debug('Query: '+soql); 
    	
    	List<Item_Category__c> categories = (List<Item_Category__c>)Database.query(soql);
    	
    	APICategoryResponse response = new APICategoryResponse();
    	response.categories = categories;
    	return response;
    
    }
    
    global class APICategoryResponse {
    	public List<Item_Category__c> Categories;
    }
    
    @isTest
    public static void testGetItemCategories () {
    	POS_TestDataUtil.initializeTestData();
    	RestRequest req = new RestRequest();
    	RestResponse res = new RestResponse();
    	
	    RestContext.request = req;
	    RestContext.response = res;
    	
    	//Try query with no populated data first
    	APICategoryResponse response = POS_APIGetItemCategories.doGet();
    	List<Item_Category__c> categories = response.Categories;
    	System.assert(categories.size()==0); 
    	
    	//Now add data and test again
    	Item_Category__c category = new Item_Category__c();
    	insert category;
    	
    	response = POS_APIGetItemCategories.doGet();
    	categories = response.Categories;
    	System.assert(categories.size()==1);
    	
    	//Now try using a more recent update time and see if we get no results again
    	req=new RestRequest();
    	Datetime now = System.now();
    	now=now.addDays(2);
    	
    	String dateString = now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    	req.addParameter('UpdateTime',dateString);
    	RestContext.request=req;
    	
    	response = POS_APIGetItemCategories.doGet();
    	categories = response.Categories;
    	System.assert(categories.size()==0);
    	
    	
    }
   
}