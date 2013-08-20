@isTest
private class Test_ControllerFile {

    class TestSettings {
        File__c file;
        File__c file2;
        Folder__c parentFolder;
        Folder__c parentFolder2;
        Folder__c child1;
        Folder__c child2;
        Folder__c child12;
        Folder__c child22;
        Organizational_Unit__c division;
        
        Account[] accounts;
        
        public TestSettings(){
            division = new Organizational_Unit__c(Label__c = 'Division', Name = 'Control', Type__c = 'Spirits');
            insert division;
            
            Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
            Folder__c[] f = [select Id from Folder__c];
            delete f;
            file = Test_Helper.testInsertFile(null, 'Planning', division.Id, null, null);
            file2 = Test_Helper.testInsertFile(null, 'Collaboration', division.Id, null, null);
            
            parentFolder = Test_Helper.testInsertFolder('parent', false, false,  division.Id, false, false, 'Planning', null, null);
            child1 = Test_Helper.testInsertFolder('child1', false, false,  division.Id, false, false, 'Planning', parentFolder.Id, null);
            child2 = Test_Helper.testInsertFolder('child2', false, false,  division.Id, false, false, 'Planning', parentFolder.Id, null);
            
            parentFolder2 = Test_Helper.testInsertFolder('parent', false, false,  division.Id, false, false, 'Collaboration', null, null);
            child12 = Test_Helper.testInsertFolder('child1', false, false,  division.Id, false, false, 'Collaboration', parentFolder2.Id, null);
            child22 = Test_Helper.testInsertFolder('child2', false, false,  division.Id, false, false, 'Collaboration', parentFolder2.Id, null);
        
            accounts = new Account[]{
                Test_Helper.testInsertAccount('account1',  division.Id),
                Test_Helper.testInsertAccount('account2',  division.Id),
                Test_Helper.testInsertAccount('account3',  division.Id)
            };
        }
        
    }
    
    static testmethod void testControllerFile(){
        TestSettings ts = new  TestSettings();
        
        ApexPages.StandardController sc = new ApexPages.standardController(ts.file);
        ControllerFile c = new ControllerFile(sc);
        
        system.assertEquals(3, c.folders.size());
        system.assertEquals(0, c.folderDeepth.get(c.folders[0].getValue()));
        system.assertEquals(1, c.folderDeepth.get(c.folders[1].getValue()));
        
        system.assertEquals(0, c.foldersSelected.size());
        
        system.assertEquals(0, c.Distributors.size());
        system.assertEquals(0, c.DistributorsSelected.size());
        
        system.assertEquals(3, ts.accounts.size());     
                
        ts.file.Distributors__c = ts.accounts[0].Id+';'+ts.accounts[2].Id;      
        ts.file.Folders__c = ts.parentFolder.id+';'+ts.child2.id;       
        c.save();

        File__c testFile = [select id, name, Folder_Names__c, Distributor_Names__c, OrgUnits__c, Folders__c, Page_Section__c, Distributors__c, Classification__c from file__c where id =: ts.file.id limit 1];
                
        system.assertEquals('parent; child2', testFile.Folder_Names__c);
        
        ApexPages.StandardController sc2 = new ApexPages.standardController(testFile);
        ControllerFile d = new ControllerFile(sc2);
        system.assertEquals(0, d.Distributors.size());
        system.assertEquals(0, d.DistributorsSelected.size());
        d.SelectedOrganizationUnitsIds = d.SelectedOrganizationUnits = ts.division.id;
        d.setOrganizationUnits();
        d.updateOrganizationUnits();
        d.fileRecord.Page_Section__c = Constant.MULTICULTURAL;
        d.refreshFolderList();
        d.fileRecord.Page_Section__c = Constant.PERFORMANCE_MANAGMENT;
        d.refreshFolderList();
        d.setOnlyForInternalUser();
        
    }
    
    static testmethod void testControllerFile2(){
        TestSettings ts = new  TestSettings();
        
        ApexPages.StandardController sc = new ApexPages.standardController(ts.file2);
        ControllerFile c = new ControllerFile(sc);
        
        ts.file2.Distributors__c = ts.accounts[0].Id+';'+ts.accounts[2].Id;     
        ts.file2.Folders__c = ts.parentFolder2.id+';'+ts.child22.id;        
        c.save();

    }
    
}