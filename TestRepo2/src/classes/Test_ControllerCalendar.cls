/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_ControllerCalendar {


    static testMethod void testController() {
    	
    	Calendar__c calendar = Test_Helper.testInsertCalendar('calendar1', 'Distribution', 'GLBT', '1', 'description1', date.valueOf('2011-11-1'), date.valueOf('2011-11-10'), false, true);        		
		calendar.Background_Color2__c = 'ffffff';
		calendar.background_color__c = 'ffffff';
		update calendar;
		Brand__c brand = Test_Helper.testInsertBrand('Test Brand');
		ApexPages.StandardController sc = new ApexPages.standardController(calendar);
		ControllerCalendar controller = new ControllerCalendar(sc);
		controller.switchTheme();
		controller.currentBrandTheme = brand.id;
		controller.switchTheme();
		controller.updateCalendarColors();
		controller.updateCalendarLogos();
		controller.updateCalendar();

		list<SelectOption> listOfThemes = controller.getBrandThemes();
		System.assert(listOfThemes.size() > 0);

    }
}