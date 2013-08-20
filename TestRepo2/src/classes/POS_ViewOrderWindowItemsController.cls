/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        07/25/2012
 * @description Controller to list items of a given OrderWindow, support filtering by one or more Brands
 **/
public with sharing class POS_ViewOrderWindowItemsController {
    
    public List<Item__c> filterResult{get; set;}
    public Order_Window__c orderWindow{get; set;}
    String[] selectedBrands = new String[]{};
    List<Item__c> orderwindowItems;
    List<Brand__c> orderwindowBrands;
    
    public POS_ViewOrderWindowItemsController() {
        String owId = ApexPages.currentPage().getParameters().get('owId');

        orderWindow = [SELECT Name, Status__c, Order_Start_Date__c, Order_Close_Date__c  from Order_Window__c where id=:owId];
        orderwindowItems = [SELECT id, Name, Product_Image__c, Packout_Quantity__c, Status__c, On_Allocation__c, Estimated_Price__c, Estimated_Shipping_Tax__c, 
            Current_Price__c, Program__r.Order_Window__r.Name, Program__r.Brand__c, Program__r.Brand__r.name, Program__c, 
            Program__r.Name from Item__c where Program__r.Order_Window__r.Id= :owId order by //Program__r.Brand__r.name, 
            Program__r.Name, Name];
        
        System.debug('orderwindowItems -' + orderwindowItems);
        List<Id> brandIds = new List<Id>();
        for(Item__c i : orderwindowItems) {
            brandIds.add(i.Program__r.Brand__c);
        }   
                    
        orderwindowBrands = [SELECT Id, Name from Brand__c where id in :brandIds];
        //orderwindowBrands.addAll(orderwindowBrands);
        //orderwindowBrands.addAll(orderwindowBrands);
    }
    

    public PageReference filterByBrand() {
        System.debug('selectedBrands -' + selectedBrands);
        filterResult = new List<Item__c>();
        
        if(selectedBrands != null && selectedBrands.size() > 0) {

            for(Item__c a : orderwindowItems) {
                for(String s : selectedBrands) {
                    if(a.Program__r.Brand__c == s) {
                        filterResult.add(a);
                        break;
                    }
                }
            }
        }
        
        return null;
    }

    public List<SelectOption> getApplicableBrands() {
        List<SelectOption> options = new List<SelectOption>();
        for(Brand__c b:orderwindowBrands) {
            options.add(new SelectOption(b.Id, b.Name));
        }

        return options;
    }

    public String[] getSelectedBrands() {
        return selectedBrands;
    }

    public void setSelectedBrands(String[] brands) {
        this.selectedBrands = brands;
    }    
    
    
    @isTest(SeeAllData=true)
    public static void testViewOrderWindowItems () {
        
        Profile p = [select id from profile where name='POS - API User Agency'];
         
        User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id,
        timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
        
        System.runAs(u) {
            //Create Agency
            Account agency = POS_TestDataUtil.createProductionAgency();
        
           
            Program__c program1 = POS_TestDataUtil.createProgram();
            Item__c item11 = POS_TestDataUtil.populateItem(program1, agency);
            insert item11;
            
            
            Test.startTest(); 
            
            Program__c program2 = POS_TestDataUtil.createProgram(program1.Order_Window__c);
            Item__c item21 = POS_TestDataUtil.populateItem(program2, agency);
            insert item21; 
                    
           
            String owId = program1.Order_Window__c;
            Test.setCurrentPageReference(new PageReference('Page.POS_ViewOrderWindowItems'));
            System.currentPagereference().getParameters().put('owId',owId);         
            
            POS_ViewOrderWindowItemsController ctrl = new POS_ViewOrderWindowItemsController(); 
            
            System.debug('ctrl.getApplicableBrands() - ' + ctrl.getApplicableBrands());
            System.assertEquals(2, ctrl.getApplicableBrands().size());
            
            ctrl.setSelectedBrands(new String[]{program1.Brand__c});
            ctrl.filterByBrand();
            System.debug('ctrl.getSelectedBrands() - ' + ctrl.getSelectedBrands());
            System.assertEquals(1, ctrl.filterResult.size());
            
            Test.stopTest();
        }
    }     

    
}