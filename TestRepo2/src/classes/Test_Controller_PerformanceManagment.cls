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
private class Test_Controller_PerformanceManagment {

    private static Organizational_Unit__c division {private get; private set;}
    private static Organizational_Unit__c region {private get; private set;}
    private static Organizational_Unit__c district {private get; private set;}
    private static Organizational_Unit__c market {private get; private set;}
    private static String distributorName {private get; private set;}
    private static String distributorId {private get; private set;}
    private static String section {private get; private set;}
    private static String subSection {private get; private set;}
        
    static private void setup(){
        division = new Organizational_Unit__c(Label__c = 'Division', Name = 'divisionName', Type__c='Spirits');
        insert division;
        region = new Organizational_Unit__c(Label__c = 'Region', Name = 'regionName', Parent__c=division.Id, Type__c='Spirits');
        insert region;
        district = new Organizational_Unit__c(Label__c = 'State District', Name = 'regionName', Parent__c=region.Id, Type__c='Spirits');
        insert district;
        market = new Organizational_Unit__c(Label__c = 'Market', Name = 'regionName', Parent__c=district.Id, Type__c='Spirits');
        insert market;
    }

    static testmethod void testAsDistributorPortalUser(){
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Test.StartTest();
        
        PageReference pageRef = Page.PerformanceManagment;
        Test.setCurrentPage(pageRef);

        setup();  
        User u;
        Account a = Test_Helper.testInsertAccount('Test Account', division.Id);
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];     
    
        System.runAs (thisUser) {
        	u = Test_Helper.testInsertDistributorPortalUser(c.ID);	
        }     
        
        distributorName = a.Name;
        distributorId = a.ID;

        Folder__c folderParent = Test_Helper.testInsertFolder(false, false, market.Id, false, false, CONSTANT.PERFORMANCE_MANAGMENT, null, a.Id);
        Folder__c folderChild = Test_Helper.testInsertFolder(false, false, market.Id, false, false, CONSTANT.PERFORMANCE_MANAGMENT, folderParent.ID, a.Id);
        File__c fileContent = Test_Helper.testInsertFile(folderChild.ID, Constant.PERFORMANCE_MANAGMENT, division.Name, market.Id, a.ID);
        section = folderParent.ID;
        subSection = folderChild.ID;

        System.runAs(u){

            Controller_PerformanceManagment controller = new Controller_PerformanceManagment();
			  
            controller.currentDistributorId = a.Id;
            controller.currentDivision = division.Name;
            controller.currentOrganizationalUnit = market.Id;
            controller.distributorsContent();
            controller.showContent();
        }       
            

        Test.StopTest();    
    }

    static testmethod void testAsDiageoPortalUser(){
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Test.StartTest();
        
        PageReference pageRef = Page.PerformanceManagment;
        Test.setCurrentPage(pageRef);
        
        setup();
        Account a2 = Test_Helper.testInsertAccount('Test Account', market.Id);
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
        distributorName = a.Name;
        distributorId = a.ID;

        Folder__c folderParent = Test_Helper.testInsertFolder(false, false, market.Id, false, false, CONSTANT.PERFORMANCE_MANAGMENT, null, a2.Id);
        Folder__c folderChild = Test_Helper.testInsertFolder(false, false, market.Id, false, false, CONSTANT.PERFORMANCE_MANAGMENT, folderParent.ID, a2.Id);
        File__c fileContent = Test_Helper.testInsertFile(folderChild.ID, Constant.PERFORMANCE_MANAGMENT, division.Name, market.Id, a2.ID);
        section = folderParent.ID;
        subSection = folderChild.ID;

        Folder__c simplefolderParent = Test_Helper.testInsertFolder(false, false, market.Id, false, false, CONSTANT.PERFORMANCE_MANAGMENT, null, a.Id);

        
        System.runAs(u){
            ApexPages.currentPage().getParameters().put('displayas', 'box');

            Controller_PerformanceManagment controller = new Controller_PerformanceManagment();
            controller.refreshPageContent();

            controller.currentDistributorId = a2.Id;
            controller.currentDivision = division.Name;
            controller.currentOrganizationalUnit = market.Id;
            controller.nextOrganizationalUnit();
            controller.downloadFromFolderId = folderParent.Id;
            controller.currentDistributorId = a2.Id;
            controller.currentDivision = division.Name;
            controller.downloadFromFolder();
        }
        
        Test.StopTest();    
    }
    
}