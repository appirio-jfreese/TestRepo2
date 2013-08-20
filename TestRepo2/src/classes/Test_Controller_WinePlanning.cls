/*****************************************************************************
 * Name           : Test_Controller_WinePlanning
 * Created On     : June 11, 2013
 * Created By     : Parul Gupta(Appirio Offshore)
 * Implementation : Test class for Controller_WinePlanning
******************************************************************************/
@isTest(seeAllData=true)
private class Test_Controller_WinePlanning {

    /* static testMethod void testWinePlanningController() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);

        Test.startTest();
        
        System.runAs(u){
            PageReference pageRef = Page.WinePlanning;
            Test.setCurrentPage(pageRef);
            
            Controller_WinePlanning cw = new Controller_WinePlanning();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cw = new Controller_WinePlanning();
            cw.currentSection = folderParentP.Id;
            string tmp = cw.requestedFolderName;
            tmp = cw.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 

            Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
            Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);            
            
            cw.detailId = cal.Id;
            cw.switchSection();          
        }        
        Test.stopTest();
    } */
    
    static testMethod void testWinePlanningController() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
		
        Test.startTest();
        
        System.runAs(u){
            PageReference pageRef = Page.WinePlanning;
            Test.setCurrentPage(pageRef);
            
            Controller_WinePlanning cw = new Controller_WinePlanning();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            Apexpages.currentPage().getParameters().put('date', String.valueOf(date.today()));
            cw = new Controller_WinePlanning();
            cw.currentSection = folderParentP.Id;
            string tmp = cw.requestedFolderName;
            tmp = cw.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 

            Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
            Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);            
            
            cw.detailId = cal.Id;
            cw.switchSection();          
        }        
        Test.stopTest();
    } 
}