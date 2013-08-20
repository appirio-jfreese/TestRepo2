/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * Created by Akanksha(offshore) for case  00003540
 */
@isTest
private class Test_Controller_Login {

    static testMethod void myUnitTest() {
    	ApexPages.currentPage().getHeaders().put('USER-AGENT','Samsung iPad');
    	Controller_Login contoller = new Controller_Login();
    	contoller.redirect();
    	
    	ApexPages.currentPage().getHeaders().put('USER-AGENT','Samsung BlackBerry');
    	Controller_Login contoller1 = new Controller_Login();
    	contoller.redirect();
    	
    	ApexPages.currentPage().getHeaders().put('USER-AGENT','Samsung iPhone');
    	Controller_Login contoller2 = new Controller_Login();
    	contoller.redirect();
    	
    	ApexPages.currentPage().getHeaders().put('USER-AGENT','Samsung Other Type of device');
    	Controller_Login contoller3 = new Controller_Login();
    	contoller.redirect();
    	}
}