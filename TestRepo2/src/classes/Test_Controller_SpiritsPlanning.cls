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
private class Test_Controller_SpiritsPlanning {

    static testMethod void testAsDiageoPortalUser() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'divisionName');
        insert division;
        
    	PageReference pageRef = Page.SpiritsPlanning;
        Test.setCurrentPage(pageRef);
    	
 		Test.StartTest();

        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
         		
		Folder__c folderParent = Test_Helper.testInsertFolder(false, false, null, true, true, CONSTANT.PLANNING, null, null);
		Folder__c folderChild = Test_Helper.testInsertFolder(false, false, null, true, true, CONSTANT.PLANNING, folderParent.ID, null);
		File__c fileContent = Test_Helper.testInsertFile(folderChild.ID, Constant.PLANNING, division.name, division.Id, null);
		
		String section = folderParent.ID;
		String subSection = folderChild.ID;
		
		ApexPages.currentPage().getParameters().put('section', section);
		ApexPages.currentPage().getParameters().put('subsection', subSection);
		ApexPages.currentPage().getParameters().put('displayas', 'box');

	    System.runAs(u){
			Controller_SpiritsPlanning controller = new Controller_SpiritsPlanning();
			System.assertEquals(controller.currentSection, section);
			System.assertEquals(controller.currentSubSection, subSection);
			System.assertEquals(controller.requestedFolder, folderChild.ID);
			controller.showDetails();
	    }				
 		Test.StopTest();   	
    }
    
	static testmethod void testRenderType(){
		PageReference pageRef = Page.SpiritsPlanning;
        Test.setCurrentPage(pageRef);
        
 		Test.StartTest();
 		
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
        
	    System.runAs(u){
			Controller_SpiritsPlanning controller = new Controller_SpiritsPlanning();
			controller.renderAsList();
			System.assertEquals(controller.displayAsList , true);
	
			controller.renderAsBox();
			System.assertEquals(controller.displayAsList , false);
	    }
 		Test.StopTest();
	}

	static testmethod void testSwitchSections(){
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
		PageReference pageRef = Page.SpiritsPlanning;
        Test.setCurrentPage(pageRef);
        
 		Test.StartTest();
 		
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
        
		Folder__c folderParent = Test_Helper.testInsertFolder(false, false, null, true, true, CONSTANT.PLANNING, null, null);

	    System.runAs(u){
			Controller_SpiritsPlanning controller = new Controller_SpiritsPlanning();
			controller.currentSection = folderParent.ID;
			controller.switchSection();
			System.assertEquals(controller.currentSubSection  , '');
	    }
 		Test.StopTest();
	}
}