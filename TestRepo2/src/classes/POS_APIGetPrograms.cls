@RestResource(urlMapping='/GetPrograms/*')
global with sharing class POS_APIGetPrograms {
	
	private static String fieldList = 'Brand__c, Calendar__c, Id, Magento_Id__c, '+
	  'Order_Window__c, Order_Window_Close_Date__c, Order_Window_Start_Date__c, '+
	  'Order_Window_Status__c, Name, Sales_Channel_Group__c from Program__c '+
	  'where Order_Window_Status__c != \'New\'';
 	  
 	@HttpGet
    global static APIProgramResponse doGet () {
    	RestRequest req=RestContext.request;
    	RestResponse res=RestContext.response;
    	
        String UpdateTime = req.params.get('UpdateTime');   
    	
    	String soql = 'select '+fieldList;
    	if (UpdateTime!=null) {
    		UpdateTime = String.escapeSingleQuotes(UpdateTime);
    		soql = soql +' and SystemModstamp > '+UpdateTime;
    	}
    	String WindowId = req.params.get('WindowId');
    	if (WindowId != null) {
    		WindowId = String.escapeSingleQuotes(WindowId);
    		soql = soql +' and Order_Window__c = \''+WindowId+'\'';
    	}
    	
    	System.debug('Query: '+soql); 
    	
    	List<Program__c> programs = (List<Program__c>)Database.query(soql);
    	
    	APIProgramResponse response = new APIProgramResponse();
    	response.Programs=programs;
    	return response;
    
    }
    
    global class APIProgramResponse {
    	public List<Program__c> Programs;
    }
    
    @isTest
    public static void testGetPrograms () {
    	
    	POS_TestDataUtil.initializeTestData();
    	
    	RestRequest req = new RestRequest();
    	RestResponse res = new RestResponse();
    	
	    RestContext.request = req;
	    RestContext.response = res;
    	
    	//Try query with no populated data first
    	APIProgramResponse response = POS_APIGetPrograms.doGet();
    	List<Program__c> programs = response.Programs;
    	System.assert(programs.size()==0);
    	
    	//Now add data and test again
    	Order_Window__c window = POS_TestDataUtil.createOrderWindow();
    	window.Status__c='New';
    	update window;
    	
    	
    	
    	Program__c program = POS_TestDataUtil.createProgram();
    	program.Order_Window__c=window.Id;
    	update program;
    	
    	//Check to make sure no results come back with a new window
    	response = POS_APIGetPrograms.doGet();
    	programs = response.Programs;
    	System.assert(programs.size()==0);
    	
    	window.Status__c='In Review';
    	update window;
    	
    	//Now we should get results
    	response = POS_APIGetPrograms.doGet();
    	programs = response.Programs;
    	System.assert(programs.size()==1);
    	
    	//Now try with Window ID
    	req.addParameter('WindowId',window.Id);
    	response = POS_APIGetPrograms.doGet();
    	programs = response.Programs;
    	System.assert(programs.size()==1);
    	
    	//And with a bad Window ID we should get no results
    	req.addParameter('WindowId','000000000000000');
    	response = POS_APIGetPrograms.doGet();
    	programs = response.Programs;
    	System.assert(programs.size()==0);
    	
    	//Now try using a more recent update time and see if we get no results again
    	req=new RestRequest();
    	Datetime now = System.now();
    	now=now.addDays(2);
    	
    	String dateString = now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    	req.addParameter('UpdateTime',dateString);
    	RestContext.request=req;
    	
    	response = POS_APIGetPrograms.doGet();
    	programs = response.Programs;
    	System.assert(programs.size()==0);
    	
    	
    }
   
}