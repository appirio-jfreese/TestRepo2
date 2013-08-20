@isTest
private class Test_Controller_ContentDelete {
    
    static testMethod void testControllerfile() {   
        Test.StartTest();
            Controller_ContentDelete controller =  new Controller_ContentDelete();
            Content_Description__c contentDesc  = Test_Helper.testInsertContentDescription();               
                        
            Calendar__c cal = Test_Helper.testInsertPCalendar('test', 'test', date.valueOf('2011-11-1'), date.valueOf('2011-11-10'));           
            Content_Property__c cp = Test_Helper.testInsertContentProperty('test', cal.Id, contentDesc.Id, 'test', 'test', 'test', 'test');
            
            Brand__c b = Test_Helper.testInsertBrand('testbrand');
            
            ContentBrand__c cb = Test_Helper.testInsertContentBrand(contentDesc.Id, b.Id);
            
            controller.currentSection = 'file';
            controller.switchSection();
        
            Integer beforeFilesInsert = controller.setCtrl.getResultSize();
            File__c fileFirst    = Test_Helper.testInsertFile();   
            File__c fileSecond   = Test_Helper.testInsertFile();            
            
            controller.reloadLists();
            //@todo: needs to change it
            //System.assertEquals(beforeFilesInsert, controller.setCtrl.getResultSize()-2);
            
            Integer beforeDelete = controller.setCtrl.getResultSize();
            controller.contentItemList[0].selected = TRUE;
            controller.deleteContent();
            //@todo: needs to change it         
            //System.assertEquals(beforeDelete, controller.setCtrl.getResultSize()+1);
        Test.StopTest();    
    } 

    static testMethod void testControllerdescr() {   
        Test.StartTest();
            Controller_ContentDelete controller =  new Controller_ContentDelete();
            Content_Description__c contentDesc  = Test_Helper.testInsertContentDescription();               
                        
            Calendar__c cal = Test_Helper.testInsertPCalendar('test', 'test', date.valueOf('2011-11-1'), date.valueOf('2011-11-10'));           
            Content_Property__c cp = Test_Helper.testInsertContentProperty('test', cal.Id, contentDesc.Id, 'test', 'test', 'test', 'test');
            
            Brand__c b = Test_Helper.testInsertBrand('testbrand');
            
            ContentBrand__c cb = Test_Helper.testInsertContentBrand(contentDesc.Id, b.Id);
            
            controller.currentSection = 'desc';
            controller.switchSection();
            
            controller.getOrganizationunits();
            controller.getClassificationRow1();
            controller.getClassificationRow2();
            controller.resetFilters(); 
            controller.getBrands();
        
            Integer beforeDeleteDes = controller.setCtrl.getResultSize();
            controller.contentItemList[0].selected = TRUE;
            controller.deleteContent();
            //@todo: needs to change it
            //System.assertEquals(beforeDeleteDes, controller.setCtrl.getResultSize()+1);         
            controller.cancelDelete();
            List<SelectOption> gPS = controller.getPageSections();
            System.assertEquals(3, gPS.size());
            
        Test.StopTest();    
    } 

    
    static testMethod void testController2() {  
        Test.StartTest();
            Controller_ContentDelete controller =  new Controller_ContentDelete(); 
            controller.next();
            controller.previous();
            controller.last();
            controller.first();
            Integer tp =  controller.totalPages;
            Integer pN = controller.pageNumber;
            Boolean hP = controller.hasPrevious;
            Boolean hN = controller.hasNext;
            
            controller.getDivisions();
            controller.getFolders();
            controller.getCalendars();
            controller.getCategories();
            controller.getSubcategories();
            controller.getSubsubcategories();
            controller.getSubsubsubcategories();
            controller.reloadListsAfterSearch();
            controller.cancelDelete();
        Test.StopTest();
     }
     
   
     
      
    
}