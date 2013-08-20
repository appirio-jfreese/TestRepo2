/*******************************************************************************
Name 				: Controller_Init.cls

Updated By  : Basant Verma (Appirio Offshore)   
Date 				: 6/25/13
Story/Task	: US615/TA1067
*******************************************************************************/
public with sharing class Controller_Init {

	public User u {public get; private set;}
	public String startUrlPage {public get; private set;}
	
    public Controller_Init() {
    	try {
	    	u = [SELECT Id FROM User WHERE id = :Service_API.getUID()];
	    	// Start : Changes for US615/TA1067 - Basant Verma (Appirio OffShore)
	    	if(Service_API.isResponsive())
	    		startUrlPage = Label.ResponsiveHomePage;
	    	else
	    		startUrlPage = Page.HomePage.getUrl();
	    	// End : Changes for US615/TA1067 - Basant Verma (Appirio OffShore)
		} catch (Exception e){
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to login.' ));
		}    	    	
    }
    
    public PageReference initEnvironment(){
		try {
	    	// set last login date
	        u.loginDate__c = dateTime.now();
	        update u; 
	                       
			// prepare site theme after login
	       	Service_API.prepareSiteThemeAfterLogin(u.id);
				
	    	PageReference pr = new Pagereference(startUrlPage);
	    	return pr;
		} catch (Exception e){
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to login.' ));
			return null;
		}    	    	

    }
}