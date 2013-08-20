@RestResource(urlMapping='/GetUser/*')
global with sharing class POS_APIGetUser {

	
 	@HttpGet
    global static User doGet () { 
    	RestRequest req = RestContext.request; 
        RestResponse res = RestContext.response;	

		String SFDCId = req.params.get('UserId');

    	User user = [select Id, FirstName, LastName, Email, Contact.Account.Name, Phone from User where Id = :SFDCId];
    
    	return user;

    }
    
    
     @isTest
   	 public static void testGetUser () {
   	 	//Get the current time
    	Datetime now = System.now();
    	
    	Profile p = [select id from profile where name='System Administrator'];
         
		User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id,
		timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
		
		insert u;
		
		RestRequest req = new RestRequest();
    	RestResponse res = new RestResponse();
    	
    	req.addParameter('UserId',u.Id);
    	
    	RestContext.request=req;
		
		User returnedUser = POS_APIGetUser.doGet();
		System.assert(returnedUser!=null);
		
		
   	 }
}