@isTest
private class Test_Controller_ContentMatrix {
    
     static testMethod void testController() {      
        
        Controller_ContentMatrix controller = new Controller_ContentMatrix();
        controller.cm_type = 'Fact Sheet';
        controller.reloadLists();
        Integer beforeInsertDes = controller.setCtrl.getResultSize();
        
        controller.cm_category = 'Selling Materials';
        controller.cm_type = 'Fact Sheet';
        controller.cm_sub_category = 'Fact Sheet';
        controller.cm_sub_sub_category = '';
        controller.cm_sub_sub_sub_category = '';
        
        controller.saveMatrixItem();
        
        controller.cm_category = 'Selling Materials';
        controller.cm_type = 'Fact Sheet';
        controller.cm_sub_category = 'Fact Sheet';
        controller.cm_sub_sub_category = '';
        controller.cm_sub_sub_sub_category = '';
        
        controller.saveMatrixItem();
        
        System.assertEquals(beforeInsertDes+2, controller.setCtrl.getResultSize());
        
        Integer beforeDeleteDes = controller.setCtrl.getResultSize();
        controller.matrixList[0].selected = TRUE;
        controller.deleteMatrixItem();          
        System.assertEquals(beforeDeleteDes, controller.setCtrl.getResultSize()+1);
        
        controller.cancel();
        controller.getCategories();
        controller.getEmptyCategories();
        controller.getMatrixType();
        Boolean hn = controller.hasNext;
        Boolean hp = controller.hasPrevious;
        Integer pn = controller.pageNumber;
        Integer tp = controller.totalPages;
        controller.first();
        controller.last();
        controller.previous();
        controller.next();  
            
        controller.cm_category = 'Selling Materials';
        controller.cm_type = 'Fact Sheet Test';
        controller.cm_sub_category = 'Fact Sheet';
        controller.cm_sub_sub_category = '';
        controller.cm_sub_sub_sub_category = '';
        
        controller.saveMatrixItem();
        controller.cm_category = 'Selling Materials';
        controller.cm_type = 'Fact Sheet Test';
        controller.cm_sub_category = 'Fact Sheet';
        controller.cm_sub_sub_category = '';
        controller.cm_sub_sub_sub_category = '';
        
        controller.saveMatrixItem();
        
        controller.cm_type = 'Fact Sheet Test';
        
        Integer beforeDeleteDes2 = controller.setCtrl.getResultSize();      
        controller.deleteAll();
        System.assertEquals(beforeDeleteDes2, controller.setCtrl.getResultSize()+2);
        
        controller.switchSection();     
        
     }
}