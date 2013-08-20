@isTest
private class Test_codecoverage {
    

    
    static testMethod void controllerVideoDownload(){
        ApexPages.currentPage().getHeaders().put('USER-AGENT', 'ie');       
        Controller_VideoDownload ex = new Controller_VideoDownload();
        System.assertequals('ie', ex.browser);
    }
    
    static testMethod void controllerFolder() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);

        Folder__c folderParentPM = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PERFORMANCE_MANAGMENT, null, null);
        Folder__c folderChildPM = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PERFORMANCE_MANAGMENT, folderParentPM.ID, null);

        Folder__c folderParentC = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.COLLABORATION, null, null);
        Folder__c folderChildC = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.COLLABORATION, folderParentC.ID, null);

        System.runAs(u){
            ApexPages.StandardController sc = new ApexPages.standardController(folderParentP);
            Controller_Folder cf= new Controller_Folder(sc);
            
            sc = new ApexPages.standardController(folderParentPM);
            cf= new Controller_Folder(sc);
            cf.SelectedDivisions = division.Id;
            cf.SelectedDistributorIds = a.id;
            cf.updateDistributors();
            cf.updateOrganizationUnits();

            sc = new ApexPages.standardController(folderParentC);
            cf= new Controller_Folder(sc);
            cf.SelectedDivisions = division.Id;
            cf.SelectedDistributorIds = a.id;
            cf.SelectedOrganizationUnits = division.id;
            cf.updateDistributors();
            cf.updateOrganizationUnits();
            cf.save();
        }
    }
   
   static testMethod void controllerMulticultural1() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        // insert test brands
        Brand__c brandA = Test_Helper.testInsertBrand('Test Brand A');
        
        // hook one of the parent brands too the user's account
        AccountBrand__c accBrand = Test_Helper.testInsertAccountBrand(a.ID, brandA.ID);
        
        // insert test content that looks up to the previoulsy inserted brands
        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        Content_Description__c contentC = Test_Helper.testInsertContentDescriptionExtended('tulip');
        
        contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
        contentA.Content_Version_Id__c = null;
        update contentA;

        Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
        Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);
        Calendar__c cal = Test_Helper.testInsertMCalendar('test1','test1 desc', date.today(), date.today().addDays(10));

        String baseDate = date.today().year()+'-'+date.today().month();
        list<Content_Property__c> contentPropertyList = new Content_Property__c[]{
            Test_Helper.testCreateContentProperty('property6', cal.Id, contentA.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property7', cal.Id, contentB.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property8', cal.Id, contentC.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'))
        };
               
        insert contentPropertyList;
                                            
        Test.StartTest();
        System.runAs(u){
            PageReference pageRef = Page.Multicultural;
            Test.setCurrentPage(pageRef);
            
            Controller_Multicultural cm = new Controller_Multicultural();
            Apexpages.currentPage().getParameters().put('section', CONSTANT.MULTICULTURAL_PROGRAMS);
            cm = new Controller_Multicultural();
            cm.currentSection = CONSTANT.MULTICULTURAL_PROGRAMS;
            system.assert(cm.contentHolder  != null);
            
            
            cm.detailId = cal.Id;
            cm.showDetails();
            
            system.assert(cm.contentHolderMap  != null);
            
            cm.clearDetailsCalendar();           
        }
        Test.StopTest();   
    }
    
   static testMethod void controllerMulticultural2() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        // insert test brands
        Brand__c brandA = Test_Helper.testInsertBrand('Test Brand A');
        
        // hook one of the parent brands too the user's account
        AccountBrand__c accBrand = Test_Helper.testInsertAccountBrand(a.ID, brandA.ID);
        
        // insert test content that looks up to the previoulsy inserted brands
        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        Content_Description__c contentC = Test_Helper.testInsertContentDescriptionExtended('tulip');
        
        contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
        contentA.Content_Version_Id__c = null;
        update contentA;

        String baseDate = date.today().year()+'-'+date.today().month();
        list<Content_Property__c> contentPropertyList = new Content_Property__c[]{
            Test_Helper.testCreateContentProperty('property6', null, contentA.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property7', null, contentB.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property8', null, contentC.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'))
        };
               
        insert contentPropertyList;
                
        Test.StartTest();
        
        System.runAs(u){
            PageReference pageRef = Page.Multicultural;
            Test.setCurrentPage(pageRef);
            
            Controller_Multicultural cm = new Controller_Multicultural();
            Apexpages.currentPage().getParameters().put('section', CONSTANT.MULTICULTURAL_PROGRAMS);
            cm = new Controller_Multicultural();
            cm.currentSection = CONSTANT.TOOLS;

            Calendar__c cal = Test_Helper.testInsertMCalendar('test1','test1 desc', date.today(), date.today().addDays(10));

            Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
            Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);
            cm.detailId = cal.Id;
                       
            cm.switchSection();            
        }
        Test.StopTest();   
    }
    
    static testMethod void controllerMulticultural3() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        // insert test brands
        Brand__c brandA = Test_Helper.testInsertBrand('Test Brand A');
        
        // hook one of the parent brands too the user's account
        AccountBrand__c accBrand = Test_Helper.testInsertAccountBrand(a.ID, brandA.ID);
        
        // insert test content that looks up to the previoulsy inserted brands
        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        Content_Description__c contentC = Test_Helper.testInsertContentDescriptionExtended('tulip');
        
        contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
        contentA.Content_Version_Id__c = null;
        update contentA;

            Calendar__c cal = Test_Helper.testInsertMCalendar('test1','test1 desc', date.today(), date.today().addDays(10));

            Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
            Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);

        String baseDate = date.today().year()+'-'+date.today().month();
        list<Content_Property__c> contentPropertyList = new Content_Property__c[]{
            Test_Helper.testCreateContentProperty('property6', cal.Id, contentA.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property7', cal.Id, contentB.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property8', cal.Id, contentC.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'))
        };
               
        insert contentPropertyList;
        
        Test.StartTest();
        
        System.runAs(u){
            PageReference pageRef = Page.Multicultural;
            Test.setCurrentPage(pageRef);
            
            Controller_Multicultural cm = new Controller_Multicultural();
            Apexpages.currentPage().getParameters().put('section', CONSTANT.TOOLS);
            cm = new Controller_Multicultural();
            cm.currentSection = CONSTANT.TOOLS;
            cm.detailId = cal.Id;
            cm.switchSubSection();
            system.assert(cm.contentHolderMap  != null);    
        }
        
        Test.StopTest();   
    }
    
    static testMethod void controllerMulticultural4() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        // insert test brands
        Brand__c brandA = Test_Helper.testInsertBrand('Test Brand A');
        
        // hook one of the parent brands too the user's account
        AccountBrand__c accBrand = Test_Helper.testInsertAccountBrand(a.ID, brandA.ID);
        
        // insert test content that looks up to the previoulsy inserted brands
        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        Content_Description__c contentC = Test_Helper.testInsertContentDescriptionExtended('tulip');
        
        contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
        contentA.Content_Version_Id__c = null;
        update contentA;

        String baseDate = date.today().year()+'-'+date.today().month();
        
        list<Content_Property__c> contentPropertyList = new Content_Property__c[]{
            Test_Helper.testCreateContentProperty('property6', null, contentA.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property7', null, contentB.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property8', null, contentC.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'))
        };
               
        insert contentPropertyList;
        
        Test.StartTest();
        
        System.runAs(u){
            PageReference pageRef = Page.Multicultural;
            
            Apexpages.currentPage().getParameters().put('section', CONSTANT.TOOLS);
            Apexpages.currentPage().getParameters().put('subsection', CONSTANT.TOOLS);
            Apexpages.currentPage().getParameters().put('time', '1');
            Apexpages.currentPage().getParameters().put('date', '01-01-2011');
                        
            Test.setCurrentPage(pageRef);
            
            Controller_Multicultural cm = new Controller_Multicultural();
            
            cm = new Controller_Multicultural();
            cm.currentSection = CONSTANT.TOOLS;

            Calendar__c cal = Test_Helper.testInsertMCalendar('test1','test1 desc', date.today(), date.today().addDays(10));

            Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
            Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);
            cm.detailId = cal.Id;
            cm.showDetails();                       
        }
        
        Test.StopTest();   
    } 
   
    static testMethod void controllerMulticultural5() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        // insert test brands
        Brand__c brandA = Test_Helper.testInsertBrand('Test Brand A');
        
        // hook one of the parent brands too the user's account
        AccountBrand__c accBrand = Test_Helper.testInsertAccountBrand(a.ID, brandA.ID);
        
        // insert test content that looks up to the previoulsy inserted brands
        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        Content_Description__c contentC = Test_Helper.testInsertContentDescriptionExtended('tulip');
        
        contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
        contentA.Content_Version_Id__c = null;
        update contentA;
        
        String baseDate = date.today().year()+'-'+date.today().month();
        list<Content_Property__c> contentPropertyList = new Content_Property__c[]{
            Test_Helper.testCreateContentProperty('property6', null, contentA.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property7', null, contentB.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property8', null, contentC.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'))
        };
               
        insert contentPropertyList;
        
        Test.StartTest();
        
        System.runAs(u){
            PageReference pageRef = Page.Multicultural;
            Test.setCurrentPage(pageRef);
            
            Controller_Multicultural cm = new Controller_Multicultural();
            Apexpages.currentPage().getParameters().put('section', CONSTANT.TOOLS);
            cm = new Controller_Multicultural();
            cm.currentSection = CONSTANT.TOOLS;

            Calendar__c cal = Test_Helper.testInsertMCalendar('test1','test1 desc', date.today(), date.today().addDays(10));

            Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
            Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);
            cm.detailId = cal.Id;
           
            cm.previousPeriod(); 
            cm.monthOrQuarterRender = false;
            cm.nextPeriod();
            cm.switchSection();                       
            cm.renderAsList();
            cm.renderAsBox();  
        }   
        
        Test.StopTest();
    }
    
   static testMethod void controllerMulticultural6() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        // insert test brands
        Brand__c brandA = Test_Helper.testInsertBrand('Test Brand A');
        
        // hook one of the parent brands too the user's account
        AccountBrand__c accBrand = Test_Helper.testInsertAccountBrand(a.ID, brandA.ID);
        
        // insert test content that looks up to the previoulsy inserted brands
        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        Content_Description__c contentC = Test_Helper.testInsertContentDescriptionExtended('tulip');
        
        contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
        contentA.Content_Version_Id__c = null;
        update contentA;
        String baseDate = date.today().year()+'-'+date.today().month();
        
        list<Content_Property__c> contentPropertyList = new Content_Property__c[]{
            Test_Helper.testCreateContentProperty('property6', null, contentA.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property7', null, contentB.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property8', null, contentC.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'))
        };
               
        insert contentPropertyList;
        
        Test.StartTest();
        
        System.runAs(u){
            PageReference pageRef = Page.Multicultural;
            Test.setCurrentPage(pageRef);
            
            Controller_Multicultural cm = new Controller_Multicultural();
            Apexpages.currentPage().getParameters().put('section', CONSTANT.TOOLS);
            cm = new Controller_Multicultural();
            cm.currentSection = CONSTANT.TOOLS;

            Calendar__c cal = Test_Helper.testInsertMCalendar('test1','test1 desc', date.today(), date.today().addDays(10));

            Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
            Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);
            cm.detailId = cal.Id;
            cm.resetFilter();             
        }
        
        Test.StopTest();
   } 
       
   static testMethod void controllerMulticultural7() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        // insert test brands
        Brand__c brandA = Test_Helper.testInsertBrand('Test Brand A');
        
        // hook one of the parent brands too the user's account
        AccountBrand__c accBrand = Test_Helper.testInsertAccountBrand(a.ID, brandA.ID);
        
        // insert test content that looks up to the previoulsy inserted brands
        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        Content_Description__c contentC = Test_Helper.testInsertContentDescriptionExtended('tulip');
        
        contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
        contentA.Content_Version_Id__c = null;
        update contentA;
        
        String baseDate = date.today().year()+'-'+date.today().month();
        list<Content_Property__c> contentPropertyList = new Content_Property__c[]{
            Test_Helper.testCreateContentProperty('property6', null, contentA.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property7', null, contentB.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property8', null, contentC.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'))
        };
               
        insert contentPropertyList;
        
        Test.StartTest();
        
        System.runAs(u){
            PageReference pageRef = Page.Multicultural;
            Test.setCurrentPage(pageRef);
            
            Controller_Multicultural cm = new Controller_Multicultural();
            Apexpages.currentPage().getParameters().put('section', CONSTANT.TOOLS);
            cm = new Controller_Multicultural();
            cm.currentSection = CONSTANT.TOOLS;

            Calendar__c cal = Test_Helper.testInsertMCalendar('test1','test1 desc', date.today(), date.today().addDays(10));

            Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
            Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);
            cm.detailId = cal.Id;          
            
            cm.selectedTimePeriods = '1';            
            cm.selectedBrandIds = brand.id;
            cm.parentId = brand.id;
            cm.updateVariantBrands();
        }   
        
        Test.StopTest();
    }   
    
    static testMethod void controllerMulticultural8() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        // insert test brands
        Brand__c brandA = Test_Helper.testInsertBrand('Test Brand A');
        
        // hook one of the parent brands too the user's account
        AccountBrand__c accBrand = Test_Helper.testInsertAccountBrand(a.ID, brandA.ID);
        
        // insert test content that looks up to the previoulsy inserted brands
        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        Content_Description__c contentC = Test_Helper.testInsertContentDescriptionExtended('tulip');
        
        contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
        contentA.Content_Version_Id__c = null;
        update contentA;
        String baseDate = date.today().year()+'-'+date.today().month();
        
        list<Content_Property__c> contentPropertyList = new Content_Property__c[]{
            Test_Helper.testCreateContentProperty('property6', null, contentA.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property7', null, contentB.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property8', null, contentC.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'))
        };
               
        insert contentPropertyList;
        
        Test.StartTest();
        
        System.runAs(u){
            PageReference pageRef = Page.Multicultural;
            Test.setCurrentPage(pageRef);
            
            Controller_Multicultural cm = new Controller_Multicultural();
            Apexpages.currentPage().getParameters().put('section', CONSTANT.TOOLS);
            cm = new Controller_Multicultural();
            cm.currentSection = CONSTANT.TOOLS;

            Calendar__c cal = Test_Helper.testInsertMCalendar('test1','test1 desc', date.today(), date.today().addDays(10));

            Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
            Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);
            cm.detailId = cal.Id;          
            
            cm.selectedTimePeriods = '1';            
            cm.selectedBrandIds = brand.id;
            cm.updateVariantBrands();
            cm.clearVariantBrands();
            cm.clearVariantBrandsSelected();
            cm.selectedBrandIds = brand.id;
            cm.parentId = brand.id;
            cm.selectedChildBrandIds = childBrand.id;
        }
        
        Test.StopTest();
    }
    
    static testMethod void controllerMulticultural9() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        // insert test brands
        Brand__c brandA = Test_Helper.testInsertBrand('Test Brand A');
        
        // hook one of the parent brands too the user's account
        AccountBrand__c accBrand = Test_Helper.testInsertAccountBrand(a.ID, brandA.ID);
        
        // insert test content that looks up to the previoulsy inserted brands
        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        Content_Description__c contentC = Test_Helper.testInsertContentDescriptionExtended('tulip');
        
        contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
        contentA.Content_Version_Id__c = null;
        update contentA;
        String baseDate = date.today().year()+'-'+date.today().month();
        
        list<Content_Property__c> contentPropertyList = new Content_Property__c[]{
            Test_Helper.testCreateContentProperty('property6', null, contentA.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property7', null, contentB.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property8', null, contentC.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'))
        };
               
        insert contentPropertyList;
        
        Test.StartTest();
        
        System.runAs(u){
            PageReference pageRef = Page.Multicultural;
            Test.setCurrentPage(pageRef);
            
            Controller_Multicultural cm = new Controller_Multicultural();
            Apexpages.currentPage().getParameters().put('section', CONSTANT.TOOLS);
            cm = new Controller_Multicultural();
            cm.currentSection = CONSTANT.TOOLS;

            Calendar__c cal = Test_Helper.testInsertMCalendar('test1','test1 desc', date.today(), date.today().addDays(10));

            Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
            Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);
            cm.detailId = cal.Id;          
            
            list<SelectOption> timePeriods = cm.getTimePeriods();
            System.assert(timePeriods.size() > 0);
            list<SelectOption> salesDrivers = cm.getSalesDrivers(); 
        }   
        
        Test.StopTest();
    }    

   static testMethod void controllerMulticultural10() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        // insert test brands
        Brand__c brandA = Test_Helper.testInsertBrand('Test Brand A');
        
        // hook one of the parent brands too the user's account
        AccountBrand__c accBrand = Test_Helper.testInsertAccountBrand(a.ID, brandA.ID);
        
        // insert test content that looks up to the previoulsy inserted brands
        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        Content_Description__c contentC = Test_Helper.testInsertContentDescriptionExtended('tulip');
        
        contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
        contentA.Content_Version_Id__c = null;
        update contentA;
        String baseDate = date.today().year()+'-'+date.today().month();
        
        list<Content_Property__c> contentPropertyList = new Content_Property__c[]{
            Test_Helper.testCreateContentProperty('property6', null, contentA.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property7', null, contentB.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property8', null, contentC.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'))
        };
               
        insert contentPropertyList;
        
        Test.StartTest();
        
        System.runAs(u){
            PageReference pageRef = Page.Multicultural;
            Test.setCurrentPage(pageRef);
            
            Controller_Multicultural cm = new Controller_Multicultural();
            Apexpages.currentPage().getParameters().put('section', CONSTANT.TOOLS);
            cm = new Controller_Multicultural();
            cm.currentSection = CONSTANT.TOOLS;

            Calendar__c cal = Test_Helper.testInsertMCalendar('test1','test1 desc', date.today(), date.today().addDays(10));

            Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
            Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);
             
            cm.switchToMonthView();
            cm.switchToQuarterView();
            cm.renderAsListSlider();
            cm.renderAsBoxSlider();
            
            list<SelectOption> timePeriods = cm.getTimePeriods();
            System.assert(timePeriods.size() > 0);
            list<SelectOption> salesDrivers = cm.getSalesDrivers();

        }   
        
        Test.StopTest();
    }
    
    static testMethod void controllerMulticultural11() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        // insert test brands
        Brand__c brandA = Test_Helper.testInsertBrand('Test Brand A');
        
        // hook one of the parent brands too the user's account
        AccountBrand__c accBrand = Test_Helper.testInsertAccountBrand(a.ID, brandA.ID);
        
        // insert test content that looks up to the previoulsy inserted brands
        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        Content_Description__c contentC = Test_Helper.testInsertContentDescriptionExtended('tulip');
        
        contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
        contentA.Content_Version_Id__c = null;
        update contentA;
        String baseDate = date.today().year()+'-'+date.today().month();
        
        list<Content_Property__c> contentPropertyList = new Content_Property__c[]{
            Test_Helper.testCreateContentProperty('property6', null, contentA.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property7', null, contentB.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property8', null, contentC.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'))
        };
               
        insert contentPropertyList;
        
        Test.StartTest();
        
        System.runAs(u){
            PageReference pageRef = Page.Multicultural;
            Test.setCurrentPage(pageRef);
            
            Controller_Multicultural cm = new Controller_Multicultural();
            Apexpages.currentPage().getParameters().put('section', CONSTANT.TOOLS);
            cm = new Controller_Multicultural();
            cm.currentSection = CONSTANT.TOOLS;

            Calendar__c cal = Test_Helper.testInsertMCalendar('test1','test1 desc', date.today(), date.today().addDays(10));

            Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
            Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);
            cm.detailId = cal.Id;  
            cm.switchToMonthView();
            
        }   
        
        Test.StopTest();
    }
    
    static testMethod void controllerMulticultural12() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        // insert test brands
        Brand__c brandA = Test_Helper.testInsertBrand('Test Brand A');
        
        // hook one of the parent brands too the user's account
        AccountBrand__c accBrand = Test_Helper.testInsertAccountBrand(a.ID, brandA.ID);
        
        // insert test content that looks up to the previoulsy inserted brands
        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        Content_Description__c contentC = Test_Helper.testInsertContentDescriptionExtended('tulip');
        
        contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
        contentA.Content_Version_Id__c = null;
        update contentA;
        String baseDate = date.today().year()+'-'+date.today().month();
        
        list<Content_Property__c> contentPropertyList = new Content_Property__c[]{
            Test_Helper.testCreateContentProperty('property6', null, contentA.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property7', null, contentB.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property8', null, contentC.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'))
        };
               
        insert contentPropertyList;
        
        Test.StartTest();
        
        System.runAs(u){
            PageReference pageRef = Page.Multicultural;
            Test.setCurrentPage(pageRef);
            
            Controller_Multicultural cm = new Controller_Multicultural();
            Apexpages.currentPage().getParameters().put('section', CONSTANT.TOOLS);
            cm = new Controller_Multicultural();
            cm.currentSection = CONSTANT.TOOLS;

            Calendar__c cal = Test_Helper.testInsertMCalendar('test1','test1 desc', date.today(), date.today().addDays(10));

            Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
            Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);
            cm.detailId = cal.Id;  
            cm.switchToQuarterView();
            
        }   
        
        Test.StopTest();
    }
    
    static testMethod void controllerMulticultural13() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        // insert test brands
        Brand__c brandA = Test_Helper.testInsertBrand('Test Brand A');
        
        // hook one of the parent brands too the user's account
        AccountBrand__c accBrand = Test_Helper.testInsertAccountBrand(a.ID, brandA.ID);
        
        // insert test content that looks up to the previoulsy inserted brands
        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        Content_Description__c contentC = Test_Helper.testInsertContentDescriptionExtended('tulip');
        
        contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
        contentA.Content_Version_Id__c = null;
        update contentA;
        String baseDate = date.today().year()+'-'+date.today().month();
        
        list<Content_Property__c> contentPropertyList = new Content_Property__c[]{
            Test_Helper.testCreateContentProperty('property6', null, contentA.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property7', null, contentB.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property8', null, contentC.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'))
        };
               
        insert contentPropertyList;
        
        Test.StartTest();
        
        System.runAs(u){
            PageReference pageRef = Page.Multicultural;
            Test.setCurrentPage(pageRef);
            
            Controller_Multicultural cm = new Controller_Multicultural();
            Apexpages.currentPage().getParameters().put('section', CONSTANT.TOOLS);
            cm = new Controller_Multicultural();
            cm.currentSection = CONSTANT.TOOLS;

            Calendar__c cal = Test_Helper.testInsertMCalendar('test1','test1 desc', date.today(), date.today().addDays(10));

            Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
            Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);
              
            cm.switchToQuarterView();
            cm.renderAsListSlider();
            cm.renderAsBoxSlider();
            
        }   
        
        Test.StopTest();
    }
    
    static testMethod void controllerMulticultural14() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        // insert test brands
        Brand__c brandA = Test_Helper.testInsertBrand('Test Brand A');
        
        // hook one of the parent brands too the user's account
        AccountBrand__c accBrand = Test_Helper.testInsertAccountBrand(a.ID, brandA.ID);
        
        // insert test content that looks up to the previoulsy inserted brands
        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        Content_Description__c contentC = Test_Helper.testInsertContentDescriptionExtended('tulip');
        
        contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
        contentA.Content_Version_Id__c = null;
        update contentA;
        String baseDate = date.today().year()+'-'+date.today().month();
        
        list<Content_Property__c> contentPropertyList = new Content_Property__c[]{
            Test_Helper.testCreateContentProperty('property6', null, contentA.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property7', null, contentB.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property8', null, contentC.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'))
        };
               
        insert contentPropertyList;

        Test.StartTest();
        
        System.runAs(u){
            PageReference pageRef = Page.Multicultural;
            Test.setCurrentPage(pageRef);
            
            Controller_Multicultural cm = new Controller_Multicultural();
            Apexpages.currentPage().getParameters().put('section', CONSTANT.TOOLS);
            cm = new Controller_Multicultural();
            cm.currentSection = CONSTANT.TOOLS;

            Calendar__c cal = Test_Helper.testInsertMCalendar('test1','test1 desc', date.today(), date.today().addDays(10));

            Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
            Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);
            cm.detailId = cal.Id;  
            
            list<SelectOption> timePeriods = cm.getTimePeriods();
            System.assert(timePeriods.size() > 0);
            list<SelectOption> salesDrivers = cm.getSalesDrivers();     
        }
        
        Test.StopTest();   
    }
    
    static testMethod void controllerMulticultural15() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        // insert test brands
        Brand__c brandA = Test_Helper.testInsertBrand('Test Brand A');
        
        // hook one of the parent brands too the user's account
        AccountBrand__c accBrand = Test_Helper.testInsertAccountBrand(a.ID, brandA.ID);
        
        // insert test content that looks up to the previoulsy inserted brands
        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        Content_Description__c contentC = Test_Helper.testInsertContentDescriptionExtended('tulip');
        
        contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
        contentA.Content_Version_Id__c = null;
        update contentA;
        
        String baseDate = date.today().year()+'-'+date.today().month();
        list<Content_Property__c> contentPropertyList = new Content_Property__c[]{
            Test_Helper.testCreateContentProperty('property6', null, contentA.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property7', null, contentB.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property8', null, contentC.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'))
        };
               
        insert contentPropertyList;
        
        Test.StartTest();
        
        System.runAs(u){
            PageReference pageRef = Page.Multicultural;
            Test.setCurrentPage(pageRef);
            
            Controller_Multicultural cm = new Controller_Multicultural();
            Apexpages.currentPage().getParameters().put('section', CONSTANT.TOOLS);
            cm = new Controller_Multicultural();
            cm.currentSection = CONSTANT.TOOLS;

            Calendar__c cal = Test_Helper.testInsertMCalendar('test1','test1 desc', date.today(), date.today().addDays(10));

            Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
            Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);
            cm.selectedBrandIds = brand.id;
            cm.selectedChildBrandIds = brand.id;
            cm.selectedTimePeriods = '1';
            cm.selectedRTS = true;
            cm.changeFilter();  
            cm.monthOrQuarterRender = false;
            cm.selectedTimePeriods = '1';
            cm.changeFilter();  
        }
        
        Test.StopTest();   
    }  
    
    static testMethod void controllerMulticultural16() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        // insert test brands
        Brand__c brandA = Test_Helper.testInsertBrand('Test Brand A');
        
        // hook one of the parent brands too the user's account
        AccountBrand__c accBrand = Test_Helper.testInsertAccountBrand(a.ID, brandA.ID);
        
        // insert test content that looks up to the previoulsy inserted brands
        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        Content_Description__c contentC = Test_Helper.testInsertContentDescriptionExtended('tulip');
        
        contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
        contentA.Content_Version_Id__c = null;
        update contentA;
        
        String baseDate = date.today().year()+'-'+date.today().month();

        Calendar__c cal = Test_Helper.testInsertMCalendar('test1','test1 desc', date.today(), date.today().addDays(10));

        Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
        Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);

        list<Content_Property__c> contentPropertyList = new Content_Property__c[]{
            Test_Helper.testCreateContentProperty('property6', cal.id, contentA.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property7', cal.id, contentB.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10')),
            Test_Helper.testCreateContentProperty('property8', cal.id, contentC.Id, Constant.MULTICULTURAL, Constant.TOOLS, null, null, date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'))
        };
               
        insert contentPropertyList;
        
        Test.StartTest();
        
        System.runAs(u){
            PageReference pageRef = Page.Multicultural;
            Test.setCurrentPage(pageRef);
            
            Controller_Multicultural cm = new Controller_Multicultural();
            Apexpages.currentPage().getParameters().put('section', CONSTANT.TOOLS);
            cm = new Controller_Multicultural();
            cm.currentSection = CONSTANT.TOOLS;

            cm.detailId = cal.Id;  
            cm.selectSalesDriver();
            cm.setStartDateValue();
        }
        
        Test.StopTest();   
    }  
    
     
    
    static testMethod void controllerWinePlanning1() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
    
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        
        Test.StartTest();
        
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
            cw.showDetails();
            system.assert(cw.contentHolderMap  != null);
            cw.clearDetailsCalendar();           
        }        
        Test.stopTest();
    }
    
    static testMethod void controllerWinePlanning2() {
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
    } 
    
    static testMethod void controllerWinePlanning3() {
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
            cw.switchSubSection();         
        }        
        Test.stopTest();
    }    
    
    static testMethod void controllerWinePlanning4() {
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
            cw.nextPeriod();        
        }        
        Test.stopTest();
    }   
    
    static testMethod void controllerWinePlanning5() {
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
            cw.previousPeriod();       
        }        
        Test.stopTest();
    }
    
    static testMethod void controllerWinePlanning6() {
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
            cw.renderAsList();
            cw.renderAsBox();
                   
        }        
        Test.stopTest();
    }
    
    static testMethod void controllerWinePlanning7() {
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
            cw.resetFilter();
                   
        }        
        Test.stopTest();
    }
    
    static testMethod void controllerWinePlanning8() {
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
            File__c file1 = Test_Helper.testInsertFile(folderChildP.Id, Constant.PLANNING, cal, division);
            
            Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
            Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);            
            
            cw.detailId = cal.Id;
            cw.updateVariantBrands();
            cw.parentId = brand.id;
            cw.updateVariantBrands();
            cw.clearVariantBrands();
            cw.clearVariantBrandsSelected();
            cw.changeFilter();
            cw.selectedPortfolio = true;
            cw.selectedRTS = true;
            cw.selectedBrandIds = brand.id;
            cw.selectedChildBrandIds = brand.id;
            cw.selectedTimePeriods = '1';
            cw.changeFilter();
            cw.selectedTimePeriods = '1';
            cw.monthOrQuarterRender = false;
            cw.changeFilter();
            cw.setStartDateValue();
                   
        }        
        Test.stopTest();
    }
    
    static testMethod void controllerWinePlanning9() {
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
             
            List<AggregateResult> x = cw.contentList;
            Integer size = cw.contentSize;
            
            list<SelectOption> timePeriods = cw.getTimePeriods();
            System.assert(timePeriods.size() > 0);
            list<SelectOption> salesDrivers = cw.getSalesDrivers();                   
        }        
        Test.stopTest();
    }
    
    static testMethod void controllerWinePlanning10() {
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
            
           
            Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
            Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);            
            
            cw.selectedTimePeriods = '1';
            cw.selectedBrandIds = brand.id;
            cw.parentId = brand.id;
            cw.selectedChildBrandIds = childBrand.id;
            cw.updateVariantBrands();
            
            cw.switchToMonthView();
            cw.switchSection();
                            
        }        
        Test.stopTest();
    }
    
    static testMethod void controllerWinePlanning11() {
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
            
            cw.switchToQuarterView();
           
                            
        }        
        Test.stopTest();
    }
    
    static testMethod void controllerWinePlanning12() {
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
                                       
        }    
            
        folderParentP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        folderChildP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        update folderParentP;
        update folderChildP;
        System.runAs(u){
            Controller_WinePlanning cn = new Controller_WinePlanning();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            //cn = new Controller_WinePlanning();
            cn.nextMonth();
            cn.previousMonth();
            cn.selectSalesDriver();
        }           
        Test.stopTest();
    }
             
    static testMethod void controllerWinePlanning13() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        
        folderParentP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        folderChildP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        update folderParentP;
        update folderChildP;
        
        Test.startTest();

        System.runAs(u){
            PageReference pageRef = Page.WinePlanning;
            Test.setCurrentPage(pageRef);
            Controller_WinePlanning cn = new Controller_WinePlanning();
            cn.selectedTimePeriods = '1';
            cn.refreshPageContent();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_WinePlanning();
            cn.nextMonth();     
        }           
        Test.stopTest();
    } 
    
    static testMethod void controllerWinePlanning14() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        
        folderParentP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        folderChildP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        update folderParentP;
        update folderChildP;
        
        Test.startTest();

        System.runAs(u){
            PageReference pageRef = Page.WinePlanning;
            Test.setCurrentPage(pageRef);
            Controller_WinePlanning cn = new Controller_WinePlanning();
            cn.selectedTimePeriods = '1';
            cn.refreshPageContent();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_WinePlanning();
            cn.previousMonth();           
        }           
        Test.stopTest();
    }
    
    static testMethod void controllerWinePlanning15() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        
        folderParentP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        folderChildP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        update folderParentP;
        update folderChildP;
        
        Test.startTest();
        
        System.runAs(u){
            PageReference pageRef = Page.WinePlanning;
            Test.setCurrentPage(pageRef);
            Controller_WinePlanning cn = new Controller_WinePlanning();
            cn.selectedTimePeriods = '1';
            cn.refreshPageContent();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_WinePlanning();
            cn.selectSalesDriver();           
        }           
        Test.stopTest();
    }
    
    static testMethod void controllerWinePlanning16() {
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
            cw.renderAsListSlider();
            cw.renderAsBoxSlider();       
                            
        }        
        Test.stopTest();
    }
    
    static testMethod void controllerNationalAccounts1() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        folderChildP.is_header__c = true;
        update folderChildP;

        Test.startTest();
        
        System.runAs(u){
            PageReference pageRef = Page.NationalAccounts;
            Test.setCurrentPage(pageRef);
            
            Controller_NationalAccounts cn = new Controller_NationalAccounts();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_NationalAccounts();
            cn.currentSection = folderParentP.Id;
            MAP<string, List<AggregateResultHolder>> contentHolderMap = cn.contentHolderMap;
            contentHolderMap = cn.detailsHolderMap;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
            cn.showDetails();
            cn.clearDetailsCalendar();       
                        
        }
         
        Test.stopTest();    
    }
    
    static testMethod void controllerNationalAccounts2() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        folderChildP.is_header__c = true;
        update folderChildP;

        Test.startTest();
        
        System.runAs(u){
            PageReference pageRef = Page.NationalAccounts;
            Test.setCurrentPage(pageRef);
            
            Controller_NationalAccounts cn = new Controller_NationalAccounts();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_NationalAccounts();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
             
            cn.switchSection();         
        }
         
        Test.stopTest();    
    }
    
    static testMethod void controllerNationalAccounts3() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        folderChildP.is_header__c = true;
        update folderChildP;

        Test.startTest();
        
        System.runAs(u){
            PageReference pageRef = Page.NationalAccounts;
            Test.setCurrentPage(pageRef);
            
            Controller_NationalAccounts cn = new Controller_NationalAccounts();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_NationalAccounts();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
           
            cn.switchSubSection();
                    
        }
         
        Test.stopTest();    
    }  
    
     static testMethod void controllerNationalAccounts4() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        folderChildP.is_header__c = true;
        update folderChildP;
        
        Test.startTest();

        System.runAs(u){
            PageReference pageRef = Page.NationalAccounts;
            Test.setCurrentPage(pageRef);
            
            Controller_NationalAccounts cn = new Controller_NationalAccounts();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_NationalAccounts();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
           
            cn.nextPeriod(); 
                        
        }
         
        Test.stopTest();    
    }
    
    static testMethod void controllerNationalAccounts5() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        folderChildP.is_header__c = true;
        update folderChildP;

        Test.startTest();
        
        System.runAs(u){
            PageReference pageRef = Page.NationalAccounts;
            Test.setCurrentPage(pageRef);
            
            Controller_NationalAccounts cn = new Controller_NationalAccounts();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_NationalAccounts();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
          
            cn.previousPeriod();           
            
        }
         
        Test.stopTest();    
    }
    
     static testMethod void controllerNationalAccounts6() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        folderChildP.is_header__c = true;
        update folderChildP;
        
        Test.startTest();

        Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
        Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);
           
        System.runAs(u){
            PageReference pageRef = Page.NationalAccounts;
            Test.setCurrentPage(pageRef);
            
            Controller_NationalAccounts cn = new Controller_NationalAccounts();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_NationalAccounts();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
                
            cn.switchSection();           
            cn.renderAsList();
            cn.renderAsBox();
            cn.selectedPortfolio = true;
            cn.selectedRTS = true;
            cn.selectedBrandIds = brand.id;
            cn.selectedChildBrandIds = brand.id;
            cn.selectedTimePeriods = '1';
            cn.changeFilter();
            cn.selectedTimePeriods = '1';
            cn.monthOrQuarterRender = false;
            cn.changeFilter();
            cn.setStartDateValue();
        }
         
        Test.stopTest();    
    }              
    
    static testMethod void controllerNationalAccounts6a() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        folderChildP.is_header__c = true;
        update folderChildP;
        
        Test.startTest();

        Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
        Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);
           
        System.runAs(u){
            PageReference pageRef = Page.NationalAccounts;
            Test.setCurrentPage(pageRef);
            
            Controller_NationalAccounts cn = new Controller_NationalAccounts();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_NationalAccounts();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
             
            cn.monthOrQuarterRender = false;          
            cn.selectedPortfolio = true;
            cn.selectedRTS = true;
            cn.selectedBrandIds = brand.id;
            cn.selectedChildBrandIds = brand.id;
            cn.selectedTimePeriods = '1';
            cn.selectedTimePeriods = '1';
            cn.nextPeriod();
            cn.previousPeriod();
            cn.setStartDateValue();
        }
         
        Test.stopTest();    
    }     
    
     static testMethod void controllerNationalAccounts7() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        folderChildP.is_header__c = true;
        update folderChildP;
        
        Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
        Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);
           
        Test.startTest();

        System.runAs(u){
            PageReference pageRef = Page.NationalAccounts;
            Test.setCurrentPage(pageRef);
            
            Controller_NationalAccounts cn = new Controller_NationalAccounts();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_NationalAccounts();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
            
            cn.resetFilter();
            cn.parentId = null;
            cn.updateVariantBrands();
            cn.parentId = brand.id;
            cn.clearVariantBrands();
            cn.clearVariantBrandsSelected();
        }
         
        Test.stopTest();    
    } 
    
     static testMethod void controllerNationalAccounts8() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        folderChildP.is_header__c = true;
        update folderChildP;
        
        Test.startTest();

        System.runAs(u){
            PageReference pageRef = Page.NationalAccounts;
            Test.setCurrentPage(pageRef);
            
            Controller_NationalAccounts cn = new Controller_NationalAccounts();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_NationalAccounts();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
           
            cn.changeFilter(); 
            List<AggregateResult> x = cn.contentList;
            Integer size = cn.contentSize;
            
            cn.selectedTimePeriods = '1';

            cn.switchToMonthView();         
        }
         
        Test.stopTest();    
    }  
    
    static testMethod void controllerNationalAccounts9() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        folderChildP.is_header__c = true;
        update folderChildP;
        
        Test.startTest();

        System.runAs(u){
            PageReference pageRef = Page.NationalAccounts;
            Test.setCurrentPage(pageRef);
            
            Controller_NationalAccounts cn = new Controller_NationalAccounts();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_NationalAccounts();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;          
            cn.switchToQuarterView();
                        
        }
         
        Test.stopTest();    
    }     
    
    static testMethod void controllerNationalAccounts10() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        folderChildP.is_header__c = true;
        update folderChildP;
        
        Test.startTest();

        System.runAs(u){
            PageReference pageRef = Page.NationalAccounts;
            Test.setCurrentPage(pageRef);
            
            Controller_NationalAccounts cn = new Controller_NationalAccounts();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_NationalAccounts();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;          
            cn.switchSection();  
            cn.renderAsListSlider();
            cn.renderAsBoxSlider();
            
        }
         
        Test.stopTest();    
    }     
    
    static testMethod void controllerNationalAccounts11() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        folderChildP.is_header__c = true;
        update folderChildP;
        
        Test.startTest();

        System.runAs(u){
            PageReference pageRef = Page.NationalAccounts;
            Test.setCurrentPage(pageRef);
            
            Controller_NationalAccounts cn = new Controller_NationalAccounts();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_NationalAccounts();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;          
            
            list<SelectOption> timePeriods = cn.getTimePeriods();
            System.assert(timePeriods.size() > 0);
            list<SelectOption> salesDrivers = cn.getSalesDrivers();
            
        }
         
        Test.stopTest();    
    }           
    
    static testmethod void controllerNationalAccounts12(){
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        
        folderParentP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        folderChildP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        update folderParentP;
        update folderChildP;

        Test.startTest();

        System.runAs(u){
            PageReference pageRef = Page.NationalAccounts;
            Test.setCurrentPage(pageRef);
            Controller_NationalAccounts cn = new Controller_NationalAccounts();
            cn.selectedTimePeriods = '1';
            cn.refreshPageContent();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_NationalAccounts();
            cn.nextMonth();          
        }     
        Test.stopTest();   
    }
    
    static testmethod void controllerNationalAccounts13(){
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        
        folderParentP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        folderChildP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        update folderParentP;
        update folderChildP;

        Test.startTest();

        System.runAs(u){
            PageReference pageRef = Page.NationalAccounts;
            Test.setCurrentPage(pageRef);
            Controller_NationalAccounts cn = new Controller_NationalAccounts();
            cn.selectedTimePeriods = '1';
            cn.refreshPageContent();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_NationalAccounts();
            cn.previousMonth();
        }     
        Test.stopTest();   
    }
    
    static testmethod void controllerNationalAccounts14(){
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        
        folderParentP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        folderChildP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        update folderParentP;
        update folderChildP;

        Test.startTest();

        System.runAs(u){
            PageReference pageRef = Page.NationalAccounts;
            Test.setCurrentPage(pageRef);
            Controller_NationalAccounts cn = new Controller_NationalAccounts();
            cn.selectedTimePeriods = '1';
            cn.refreshPageContent();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_NationalAccounts();           
            cn.selectSalesDriver();
        }     
        Test.stopTest();   
    }

    static testMethod void controllerSpiritPlanning1() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        Folder__c foldertmp = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        
        Test.startTest();

        System.runAs(u){
            PageReference pageRef = Page.SpiritsPlanning;
            Test.setCurrentPage(pageRef);
            
            Controller_SpiritsPlanning cn = new Controller_SpiritsPlanning();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_SpiritsPlanning();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
            cn.showContent();
            cn.showDetails();   
            cn.currentSection = 'x';//folderParentP.id;
            cn.currentSubSection = '';
            cn.showContent();        
        }

        Test.stopTest();
    }
    
     static testMethod void controllerSpiritPlanning2() {
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
            PageReference pageRef = Page.SpiritsPlanning;
            Test.setCurrentPage(pageRef);
            
            Controller_SpiritsPlanning cn = new Controller_SpiritsPlanning();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_SpiritsPlanning();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
            
            cn.selectSalesDriver();
            cn.clearDetailsCalendar();       
           
        }

        Test.stopTest();
    }
    
     static testMethod void controllerSpiritPlanning3() {
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
            PageReference pageRef = Page.SpiritsPlanning;
            Test.setCurrentPage(pageRef);
            
            Controller_SpiritsPlanning cn = new Controller_SpiritsPlanning();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_SpiritsPlanning();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
               
            cn.switchSection();           
        }

        Test.stopTest();
    }
    
     static testMethod void controllerSpiritPlanning4() {
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
            PageReference pageRef = Page.SpiritsPlanning;
            Test.setCurrentPage(pageRef);
            
            Controller_SpiritsPlanning cn = new Controller_SpiritsPlanning();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_SpiritsPlanning();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
          
            cn.switchSubSection();
            
        }

        Test.stopTest();
    }
    
     static testMethod void controllerSpiritPlanning5() {
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
            PageReference pageRef = Page.SpiritsPlanning;
            Test.setCurrentPage(pageRef);
            
            Controller_SpiritsPlanning cn = new Controller_SpiritsPlanning();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_SpiritsPlanning();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
          
            cn.nextPeriod(); 
           
        }

        Test.stopTest();
    }
    
     static testMethod void controllerSpiritPlanning6() {
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
            PageReference pageRef = Page.SpiritsPlanning;
            Test.setCurrentPage(pageRef);
            
            Controller_SpiritsPlanning cn = new Controller_SpiritsPlanning();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_SpiritsPlanning();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
           
            cn.previousPeriod();          
        }

        Test.stopTest();
    }
    
     static testMethod void controllerSpiritPlanning7() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);

        Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
        Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);   

        Test.startTest();
        
        System.runAs(u){
            PageReference pageRef = Page.SpiritsPlanning;
            Test.setCurrentPage(pageRef);
            
            Controller_SpiritsPlanning cn = new Controller_SpiritsPlanning();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_SpiritsPlanning();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
              
            cn.switchSection();           
            cn.renderAsList();
            cn.renderAsBox();
          
            cn.selectedPortfolio = true;
            cn.selectedRTS = true;
            cn.selectedBrandIds = brand.id;
            cn.selectedChildBrandIds = brand.id;
            cn.selectedTimePeriods = '1';
            cn.changeFilter();
            cn.selectedTimePeriods = '1';
            cn.monthOrQuarterRender = false;
            cn.changeFilter();
            cn.setStartDateValue();
          
        }

        Test.stopTest();
    }
    
     static testMethod void controllerSpiritPlanning8() {
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);

        Test.startTest();
        Brand__c brand = Test_Helper.testCreateBrand('test brand', null, null);
        Brand__c childBrand = Test_Helper.testCreateBrand('test child brand', brand.id, null);   

        
        System.runAs(u){
            PageReference pageRef = Page.SpiritsPlanning;
            Test.setCurrentPage(pageRef);
            
            Controller_SpiritsPlanning cn = new Controller_SpiritsPlanning();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_SpiritsPlanning();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
            
            cn.resetFilter();
            cn.parentId = brand.id;
            cn.updateVariantBrands();
            cn.parentId = null;
            cn.updateVariantBrands();
            cn.clearVariantBrands();
            cn.clearVariantBrandsSelected();          
        }

        Test.stopTest();
    }
    
     static testMethod void controllerSpiritPlanning9() {
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
            PageReference pageRef = Page.SpiritsPlanning;
            Test.setCurrentPage(pageRef);
            
            Controller_SpiritsPlanning cn = new Controller_SpiritsPlanning();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_SpiritsPlanning();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
           
            cn.changeFilter();
            List<AggregateResult> x = cn.contentList;
            Integer size = cn.contentSize;      
        }

        Test.stopTest();
    }
    
    static testMethod void controllerSpiritPlanning10() {
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
            PageReference pageRef = Page.SpiritsPlanning;
            Test.setCurrentPage(pageRef);
            
            Controller_SpiritsPlanning cn = new Controller_SpiritsPlanning();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_SpiritsPlanning();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
           
            cn.switchToMonthView();         
        }

        Test.stopTest();
    }
    
    static testMethod void controllerSpiritPlanning11() {
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
            PageReference pageRef = Page.SpiritsPlanning;
            Test.setCurrentPage(pageRef);
            
            Controller_SpiritsPlanning cn = new Controller_SpiritsPlanning();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_SpiritsPlanning();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
          
            cn.switchToQuarterView();            
          
        }

        Test.stopTest();
    }
    
    static testMethod void controllerSpiritPlanning12() {
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
            PageReference pageRef = Page.SpiritsPlanning;
            Test.setCurrentPage(pageRef);
            
            Controller_SpiritsPlanning cn = new Controller_SpiritsPlanning();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_SpiritsPlanning();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
                  
            cn.switchSection();
           
            cn.renderAsListSlider();
            cn.renderAsBoxSlider();          
        }

        Test.stopTest();
    }
    
    static testMethod void controllerSpiritPlanning13() {
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
            PageReference pageRef = Page.SpiritsPlanning;
            Test.setCurrentPage(pageRef);
            
            Controller_SpiritsPlanning cn = new Controller_SpiritsPlanning();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_SpiritsPlanning();
            cn.currentSection = folderParentP.Id;
            string tmp = cn.requestedFolderName;
            tmp = cn.requestedFolder;
            
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            cn.detailId = cal.Id;
                      
            list<SelectOption> timePeriods = cn.getTimePeriods();
            System.assert(timePeriods.size() > 0);
            list<SelectOption> salesDrivers = cn.getSalesDrivers();     
            
        }

        Test.stopTest();
    }
        
    static testMethod void controllerSpiritPlanning14(){
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        
        folderParentP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        folderChildP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        update folderParentP;
        update folderChildP;
        
        Test.startTest();

        System.runAs(u){
            PageReference pageRef = Page.SpiritsPlanning;
            Test.setCurrentPage(pageRef);
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            Controller_SpiritsPlanning cn = new Controller_SpiritsPlanning();
            cn.selectedTimePeriods = '1';
            cn.refreshPageContent();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_SpiritsPlanning();
            cn.showDetails();           
        } 
        
        Test.stopTest();
    }
    
    static testMethod void controllerSpiritPlanning15(){
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        
        folderParentP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        folderChildP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        update folderParentP;
        update folderChildP;
        
        Test.startTest();

        System.runAs(u){
            PageReference pageRef = Page.SpiritsPlanning;
            Test.setCurrentPage(pageRef);
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            Controller_SpiritsPlanning cn = new Controller_SpiritsPlanning();
            cn.selectedTimePeriods = '1';
            cn.refreshPageContent();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_SpiritsPlanning();
           
            cn.nextMonth();
          
        } 
        
        Test.stopTest();
    }
    
    static testMethod void controllerSpiritPlanning16(){
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        
        folderParentP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        folderChildP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        update folderParentP;
        update folderChildP;
        
        Test.startTest();

        System.runAs(u){
            PageReference pageRef = Page.SpiritsPlanning;
            Test.setCurrentPage(pageRef);
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            Controller_SpiritsPlanning cn = new Controller_SpiritsPlanning();
            cn.selectedTimePeriods = '1';
            cn.refreshPageContent();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_SpiritsPlanning();          
            cn.previousMonth();
        
        } 
        
        Test.stopTest();
    }
    
    static testMethod void controllerSpiritPlanning17(){
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'SWS');
        insert division;        
        Account a = Test_Helper.testGetDiageoAccount();
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User u = Test_Helper.testInsertDiageoPortalUser(c.ID);
                
        Folder__c folderParentP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, null, null);
        Folder__c folderChildP = Test_Helper.testInsertFolder(false, false, division.Id, false, false, CONSTANT.PLANNING, folderParentP.ID, null);
        
        folderParentP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        folderChildP.Layout_Type__c = Constant.PLANNING_SIMPLE_CALENDAR;
        update folderParentP;
        update folderChildP;
        
        Test.startTest();

        System.runAs(u){
            PageReference pageRef = Page.SpiritsPlanning;
            Test.setCurrentPage(pageRef);
            Calendar__c cal = Test_Helper.testInsertPCalendar('test1','test1 desc', date.today(), date.today().addDays(10));
            File__c file = Test_Helper.testInsertFile(folderParentP.Id, Constant.PLANNING, cal, division); 
            Controller_SpiritsPlanning cn = new Controller_SpiritsPlanning();
            cn.selectedTimePeriods = '1';
            cn.refreshPageContent();
            Apexpages.currentPage().getParameters().put('section', folderParentP.Id);
            cn = new Controller_SpiritsPlanning();
            
            cn.selectSalesDriver();
        } 
        
        Test.stopTest();
    }
    
    static testMethod void controllerPreview() {
        PageReference pageRef = Page.HomePage;
        Test.setCurrentPage(pageRef);
        Controller_Preview c = new Controller_Preview();
    }
     
    static testMethod void controllerPos() {
        PageReference pageRef = Page.POS;
        Test.setCurrentPage(pageRef);
        
        Controller_POS c = new Controller_POS();
        string tmp = c.posToolFolderId;
        tmp = c.posAdHocFolderId;
    } 
    
    static testMethod void classFile() {
        File f = new File('a','b','c','d');
        String tmp = f.cvid;
    } 
    
}