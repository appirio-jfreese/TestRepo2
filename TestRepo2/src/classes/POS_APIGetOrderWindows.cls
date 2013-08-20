@RestResource(urlMapping='/GetWindows/*')
global with sharing class POS_APIGetOrderWindows {
	
	private static String fieldList = 'Order_Close_Date__c, Order_Delivery_Date__c, Order_Start_Date__c, '+
      'Name, Status__c, Type__c, Fiscal_Year__c from Order_Window__c where Status__c!=\'New\'';
 	  
 	@HttpGet
    global static APIWindowResponse doGet () {
    	RestRequest req=RestContext.request;
    	RestResponse res=RestContext.response;
    	
        String UpdateTime = req.params.get('UpdateTime');   
    	
    	String soql = 'select '+fieldList;
    	if (UpdateTime!=null) {
    		UpdateTime = String.escapeSingleQuotes(UpdateTime);
    		soql = soql +' and SystemModstamp > '+UpdateTime;
    	}
    	
    	System.debug('Query: '+soql);
    	
    	List<Order_Window__c> windows = (List<Order_Window__c>)Database.query(soql);
    	
    	APIWindowResponse response = new APIWindowResponse();
    	response.Windows=windows;
    	return response;
    
    }
    
    global class APIWindowResponse {
    	public List<Order_Window__c> Windows;
    }
    
    @isTest
    public static void testGetWindows () {
    	RestRequest req = new RestRequest();
    	RestResponse res = new RestResponse();
    	
	    RestContext.request = req;
	    RestContext.response = res;
    	
    	//Try query with no populated data first
    	APIWindowResponse response = POS_APIGetOrderWindows.doGet();
    	List<Order_Window__c> windows = response.Windows;
    	System.assert(windows.size()==0);
    	
    	//Now add data and test again
    	Order_Window__c window = POS_TestDataUtil.createOrderWindow();
    	window.Status__c='New';
    	update window;
    	
    	response = POS_APIGetOrderWindows.doGet();
    	windows = response.Windows;
    	
    	//Should have no records because it's a new window
    	System.assert(windows.size()==0);
    	
    	window.Status__c = 'In Review';
    	update window;
    	
    	//Now should get one since it's not "new"
    	response = POS_APIGetOrderWindows.doGet();
    	windows = response.Windows;
    	System.assert(windows.size()==1);
    	
    	//Now try using a more recent update time and see if we get no results again
    	req=new RestRequest();
    	Datetime now = System.now();
    	now=now.addDays(2);
    	
    	String dateString = now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    	req.addParameter('UpdateTime',dateString);
    	RestContext.request=req;
    	
    	response = POS_APIGetOrderWindows.doGet();
    	windows = response.Windows;
    	System.assert(windows.size()==0);
    	
    	
    }
   
}