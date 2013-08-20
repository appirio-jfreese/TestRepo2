@isTest
private class Test_Controller_CloneCalendar {

     static testMethod void testController() {      
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'divisionName', Type__c = 'Spirits');
        insert division;
        
        Calendar__c calendarMep = Test_Helper.testInsertCalendar('calendarMep', 'Distribution', 'GLBT', '1', 'description1', date.valueOf('2011-11-1'), date.valueOf('2011-11-10'), false, true);               
        
        Brand__c brand = Test_Helper.testInsertBrand('Test Brand 1');       
        CalendarBrand__c CalBrand  = Test_Helper.testInsertCalendarBrand(calendarMep.Id, brand.Id);
        
        Brand__c brand2 = Test_Helper.testInsertBrand('Test Brand 2');
        CalendarBrand__c CalBrand2 = Test_Helper.testInsertCalendarBrand(calendarMep.Id, brand2.Id);
                            
        Content_Description__c contentDescription = Test_Helper.testInsertContentDescription();                     
        Content_Property__c contentProperty = Test_Helper.testInsertContentProperty('Test 1', calendarMep.Id, contentDescription.id, 'Selling materials', 'Final Launch Deck' , '', '');
        
        ApexPages.StandardController sc = new ApexPages.standardController(calendarMep);            
        Controller_CloneCalendar controller =  new Controller_CloneCalendar(sc);
                
        controller.selectedRecordType = 'Multicultural';
        controller.salesToRecordType();
        
        
        controller.selectedRecordType = 'Planning';
        controller.salesToRecordType();
       
        
        controller.selectedRecordType = 'Innovation, Sustainovation & VAP';
        controller.salesToRecordType();
      
        
        controller.selectedRecordType = 'Monthly Execution Plan';
        controller.salesToRecordType();
         
        
        
        controller.calendarName = 'Coloned';
        controller.selectedChanell = 'Innovation';
        controller.selectedRecordType = 'Monthly Execution Plan'; 
        
        String recordTypeId = [Select r.Id, r.name From RecordType r WHERE r.Name= :controller.selectedRecordType AND r.SobjectType = 'Calendar__c' LIMIT 1].id;
                
        PageReference pr = controller.saveCloneCalendar();
        String url = pr.getUrl();
        String colonedId = url.substring(1, url.length());
        
        Calendar__c clonedCalendar = [Select c.background_color__c, c.Type__c, c.Theme__c, c.Text_Color__c, c.SystemModstamp, c.Start_Date__c, c.Specification_Text__c, c.Specification_Content_Description__c, c.Situation_Text__c, c.Situation_Content_Description__c, c.Ship_Date__c, c.Segment__c, c.Sales_Channel__c, c.RecordTypeId, c.Programs__c, c.Priority__c, c.Name, c.Logo_Image_Small__c, c.Logo_Image_Large__c, c.Launch_Date__c, c.LastModifiedDate, c.LastModifiedById, c.LastActivityDate, c.IsDeleted, c.Idea_Text__c, c.Idea_Content_Description__c, c.Id, c.How_it_Works_Text__c, c.How_it_Works_Content_Description__c, c.Folder__c, c.End_Date__c, c.Description__c, c.Description_Content_Description__c, c.CreatedDate, c.CreatedById, c.Consumer_Target_Text__c, c.Consumer_Target_Content_Description__c, c.Background_Color2__c, c.Archive__c From Calendar__c c Where c.Id = :colonedId];
                
        Content_Property__c clonedCalendarConProperty = [Select c.SystemModstamp, c.Sub_Sub_Sub_Category__c, c.Sub_Sub_Category__c, c.Sub_Category__c, c.Start_Date__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.End_Date__c, c.CreatedDate, c.CreatedById, c.Content_Description__c, c.Selling_Materials_Classification_Row_1__c, c.Selling_Materials_Classification_Row_2__c, c.Category__c, c.Calendar__c From Content_Property__c c Where c.Calendar__c = :colonedId LIMIT 1];
        
        System.assertequals(contentProperty.Content_Description__c, clonedCalendarConProperty.Content_Description__c);
        
        System.assertequals(calendarMep.How_it_Works_Content_Description__c, clonedCalendar.How_it_Works_Content_Description__c);
        System.assertequals(calendarMep.Description__c, clonedCalendar.Description__c);
        System.assertequals(calendarMep.Start_Date__c, clonedCalendar.Start_Date__c);
        System.assertequals('Coloned', clonedCalendar.name);
        System.assertequals('Innovation', clonedCalendar.Sales_Channel__c);
        System.assertequals(recordTypeId, clonedCalendar.RecordTypeId);
            
        List<CalendarBrand__c> listCalendarBrand = [Select c.SystemModstamp, c.Name, c.LastModifiedDate, c.LastModifiedById, c.LastActivityDate, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Calendar__c, c.Brand__c From CalendarBrand__c c WHERE c.Calendar__c = :colonedId];
        System.assertequals(2, listCalendarBrand.size());
                    
            
        Calendar__c calendarPlanning = Test_Helper.testInsertPCalendar('Test planning calendar', 'Test description', date.valueOf('2011-11-1'), date.valueOf('2011-11-10'));
              
        ///Folder__c folder = Test_Helper.testInsertFolder('Test folder', TRUE, TRUE, 'Test', TRUE, TRUE, 'Test section', 'Test parent folder');        
        File__c file = Test_Helper.testInsertFile('a06K0000000FbrVIAS', 'Planning', calendarPlanning, division);
        File__c file2 = Test_Helper.testInsertFile('a06K0000000FbrVIAS', 'Planning', calendarPlanning, division);
        
        ApexPages.StandardController st = new ApexPages.standardController(calendarPlanning);           
        Controller_CloneCalendar controllerTwo =  new Controller_CloneCalendar(st);
        
        controllerTwo.calendarName = 'Coloned planning';
        controllerTwo.selectedChanell = 'Planning';
        controllerTwo.selectedRecordType = 'Planning';
                        
        PageReference pr2 = controllerTwo.saveCloneCalendar();
        String url2 = pr2.getUrl();
        String colonedTwoId = url2.substring(1, url2.length());
        
        Calendar__c clonedCalendarTwo = [Select c.background_color__c, c.Type__c, c.Theme__c, c.Text_Color__c, c.SystemModstamp, c.Start_Date__c, c.Specification_Text__c, c.Specification_Content_Description__c, c.Situation_Text__c, c.Situation_Content_Description__c, c.Ship_Date__c, c.Segment__c, c.Sales_Channel__c, c.RecordTypeId, c.Programs__c, c.Priority__c, c.Name, c.Logo_Image_Small__c, c.Logo_Image_Large__c, c.Launch_Date__c, c.LastModifiedDate, c.LastModifiedById, c.LastActivityDate, c.IsDeleted, c.Idea_Text__c, c.Idea_Content_Description__c, c.Id, c.How_it_Works_Text__c, c.How_it_Works_Content_Description__c, c.Folder__c, c.End_Date__c, c.Description__c, c.Description_Content_Description__c, c.CreatedDate, c.CreatedById, c.Consumer_Target_Text__c, c.Consumer_Target_Content_Description__c, c.Background_Color2__c, c.Archive__c From Calendar__c c Where c.Id = :colonedTwoId];
        System.assertequals(calendarPlanning.Start_Date__c, clonedCalendarTwo.Start_Date__c);       
        
        List<File__c> filesList = [Select f.share_link__c, f.filetype__c, f.filesize__c, f.Video_Id__c, f.Title__c, f.Tags__c, f.SystemModstamp, f.Start_Date__c, f.RTS__c, f.Preview_Id__c, f.Preview_Available__c, f.Portfolio__c, f.Page_Section__c, f.Only_For_Internal_User__c, f.Name, f.LastModifiedDate, f.LastModifiedById, f.Is_Video__c, f.IsDeleted, f.Image_Resolution__c, f.Id, f.Folders__c, f.Folder_Names__c, f.End_Date__c, f.OrgUnits__c, f.Division_Access__c, f.Distributors__c, f.Distributor_Names__c, f.Description__c, f.CreatedDate, f.CreatedById, f.Content_Version_Id__c, f.Content_ID__c, f.Calendar__c, f.Brands__c, f.Brand_Names__c, f.Available_Until__c From File__c f Where f.Calendar__c = :colonedTwoId];
        System.assertequals(2, filesList.size());       
        
     }
}