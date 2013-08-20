/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        08/14/2012
 * @description Controller to list items of a given OrderWindow, support filtering by one or more Brands
 **/
public without sharing class POS_DownloadItemCatalogController {
    
    public Order_Window__c orderWindow{get; set;}
    public List<Program__c> orderwindowData{get; set;}
    public Map<Id, Item__c> itemWithImages{get; set;}
    public String disclaimerText {get;set;}
    public String thumbnailUrl {get;set;}
    
    public POS_DownloadItemCatalogController() {
        String owId = ApexPages.currentPage().getParameters().get('owId');
        
        
		POS_Magento_Configuration__c settings = POS_Magento_Configuration__c.getOrgDefaults();
		thumbnailUrl = settings.Thumbnail_Url__c;

        orderWindow = [SELECT Name, Status__c, Order_Start_Date__c, Order_Close_Date__c  from Order_Window__c where Magento_Id__c=:owId];
        orderwindowData = 	[SELECT Order_Window__r.Name, Brand__r.name, Program_ID__c, Id, Name, Sales_Driver__c,
						(select id, Name, Item_ID__c, Description__c, Agency_Item_ID__c, Minimum_Quantity__c, Packout_Quantity__c, Estimated_Price__c, Estimated_Shipping_Tax__c, Current_Price__c, Magento_Id__c 
						from Items__r where Status__c not in ('Development','Removed','Cancelled') and RecordType.DeveloperName!='Roll_Up' and Kit_Only__c!=true order by Name ) 
						FROM Program__c where Order_Window__r.Magento_Id__c= :owId order by Name];
						
		Legal_Disclaimer__c ld = [SELECT ItemsCatalog_Message__c FROM Legal_Disclaimer__c where End_Date__c = null limit 1];
		disclaimerText = ld.ItemsCatalog_Message__c;						
		
		List<Id> itmIds = new List<Id>(); 
		
		List<Program__c> programsWithItems = new List<Program__c>();
		
		
		for(Program__c prg : orderwindowData) {
			if (prg.Items__r.size()>0) {
				programsWithItems.add(prg);
			}
			for(Item__c itm : prg.Items__r) {
				itmIds.add(itm.Id);
			}
		}
		
		System.debug('ORDER WINDOW DATA: '+orderWindowData);
		
		//Now copy back the programs that have items to eliminate blanks
		orderWindowData = programsWithItems;
		
		System.debug('ORDER WINDOW DATA 2: '+orderWindowData);
		
		
		// query list of images corresponding to all the Items of the OW above.
		itemWithImages = new Map<Id, Item__c>([SELECT Id, (SELECT Magento_Image_URL__c,Magento_Image__c FROM Item_Images__r) FROM Item__c where Id in :itmIds]);
        
        System.debug('orderwindowData -' + orderwindowData + ' itemWithImages -' + itemWithImages);

    }
    
    @isTest(SeeAllData=true)
	public static void testDownloadItemCatalog () {
		
		Profile p = [select id from profile where name='POS - CM Administrator'];
         
		User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id,
		timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
		
		System.runAs(u) {
			//Create some test data
			Account account = new Account();
			account.Name='POS Unit Test Account';
			insert account;
			
			Account_Member__c am = new Account_Member__c();
			am.Account__c = account.Id;
			am.User__c = u.Id;
			insert am;
			
		    Account agency = POS_TestDataUtil.createProductionAgency();
		   
		   	Order_Window__c ow = POS_TestDataUtil.createOrderWindow();
		   	ow.Magento_Id__c = '1';
		   	update ow;
		   	
		    Program__c program = POS_TestDataUtil.createProgram(ow.Id);
		    Item__c item = POS_TestDataUtil.populateItem(program, agency);
		    item.Status__c='Approved w/Est Price';
		    insert item;
		   
		    String owId = program.Order_Window__c;
			Test.setCurrentPageReference(new PageReference('Page.POS_DownloadItemCatalog'));
			System.currentPagereference().getParameters().put('owId',ow.Magento_Id__c);		    
		    
		    POS_DownloadItemCatalogController ctrl = new POS_DownloadItemCatalogController();	
		    
		    System.assertEquals(1, ctrl.orderwindowData.size());
		}
	}     
    
}