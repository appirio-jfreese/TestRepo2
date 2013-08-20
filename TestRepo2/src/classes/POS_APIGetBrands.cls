@RestResource(urlMapping='/GetBrands/*')
global with sharing class POS_APIGetBrands {
	
	private static String fieldList = 'Name, Brand_Type__c, Generic_Brand__c, Id, '+
	  'Magento_Id__c, Parent_Brand__c,Portfolio_Brand__c, WBS_Level_3__c, '+
	  'WBS_Level_5__c, Classification__c from Brand__c';
 	  
 	@HttpGet
    global static APIBrandResponse doGet () {
    	RestRequest req=RestContext.request;
    	RestResponse res=RestContext.response;
    	
        String UpdateTime = req.params.get('UpdateTime');   
    	
    	String soql = 'select '+fieldList;
    	if (UpdateTime!=null) {
    		UpdateTime = String.escapeSingleQuotes(UpdateTime);
    		soql = soql +' where SystemModstamp > '+UpdateTime;
    	}
    	
    	System.debug('Query: '+soql); 
    	
    	List<Brand__c> brands = (List<Brand__c>)Database.query(soql);
    	
    	APIBrandResponse response = new APIBrandResponse();
    	response.Brands=brands;
    	return response;
    
    }
    
    global class APIBrandResponse {
    	public List<Brand__c> Brands;
    }
    
    @isTest
    public static void testGetBrands () {
    	POS_TestDataUtil.initializeTestData();
    	RestRequest req = new RestRequest();
    	RestResponse res = new RestResponse();
    	
	    RestContext.request = req;
	    RestContext.response = res;
    	
    	//Try query with no populated data first
    	APIBrandResponse response = POS_APIGetBrands.doGet();
    	List<Brand__c> brands = response.Brands;
    	System.assert(brands.size()==1); //Should have Portfolio default and that's it
    	
    	//Now add data and test again
    	Brand__c brand = POS_TestDataUtil.createBrand();
    	
    	response = POS_APIGetBrands.doGet();
    	brands = response.Brands;
    	System.assert(brands.size()==2);
    	
    	//Now try using a more recent update time and see if we get no results again
    	req=new RestRequest();
    	Datetime now = System.now();
    	now=now.addDays(2);
    	
    	String dateString = now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    	req.addParameter('UpdateTime',dateString);
    	RestContext.request=req;
    	
    	response = POS_APIGetBrands.doGet();
    	brands = response.Brands;
    	System.assert(brands.size()==0);
    	
    	
    }
   
}