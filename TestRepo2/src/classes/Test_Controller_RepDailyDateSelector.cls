/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * Created by Akanksha(offshore) for case  00003540
 **/
@isTest
private class  Test_Controller_RepDailyDateSelector {
	    static testMethod void myUnitTest() {
	    	
	    	 Account accountData = Test_Helper.testInsertAccount('accountNemaws');
	    	 Event e= new Event(Whatid=accountData.id,EndDateTime=system.today(), DurationInMinutes=0, ActivityDateTime=system.today(), ActivityDate =system.today() );
       		 insert e;  
       		 
	    	 ApexPages.StandardController sc = new ApexPages.StandardController(e);
	   		 Controller_RepDailyDateSelector controller = new Controller_RepDailyDateSelector(sc);
	   		 controller.eventRecord = e;
	   		 controller.GeneratePDF();
	    }

}