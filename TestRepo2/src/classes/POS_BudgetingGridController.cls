/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        08/20/2012
 * @description Controller that makes Brand data for a given OrderWindow available and supports Budgeting Grid Actions
 **/
public without sharing class POS_BudgetingGridController extends Controller_Base {
    
    public List<POS_BreadCrumb> breadcrumbs {get;set;} 
    
    private static List<Profile> budgetAdminProfiles = [select Id, Name from Profile where Name 
                                        in ('System Administrator','Diageo Employee','Diageo Portal User', 'POS - CM Administrator')];
    
    public Order_Window__c orderWindow{get; set;}
    public List<Program__c> orderwindowData{get; set;}
    public List<Program__c> orderWindowPrograms{get; set;}
    public List<Budget__c> orderwindowBudgets{get; set;}
    public List<Budget__c> orderwindowBudgetsIA{get; set;}
    
    private Map<Id, Budget__c> orderwindowBudgetsMap{get; set;}
    
    public String shopperName{get;set;}
    public String budgetValue{get;set;}
    public Boolean allowNewBudgetCreation{get;set;}
    public Boolean orgHierarchyFilterNotApplicable{get;set;}
    public String selectedTab{get;set;}
    
    public List<User> shoppersFromOrgHierarchy {get; private set;}
   
    public POS_BudgetingGridController() {
        String owId = ApexPages.currentPage().getParameters().get('owId');
        
		allowNewBudgetCreation = false;
		orgHierarchyFilterNotApplicable = false;
		
		for(Profile pf : budgetAdminProfiles) {
			if(UserInfo.getProfileId() == pf.Id) {
	        	allowNewBudgetCreation = true;
	        	orgHierarchyFilterNotApplicable = true;
	        	break;
	        }
		}
        
        
        orderWindow = [SELECT Id, Name, Status__c, Order_Start_Date__c, Order_Close_Date__c  from Order_Window__c where Id=:owId];
        orderWindowPrograms = [SELECT Id, Name FROM Program__c where Order_Window__r.Id= :owId];
        
	    loadOrderWindowBudget(owId); 
	    loadOrderWindowBudgetIA(owId);       
        
        if (orgHierarchyFilterNotApplicable) { // get allShoppers, allDistributors
        	
        	 // Note: making all Account and Geographies available to Diageo Shopper
       		 shoppersFromOrgHierarchy = [Select Id, Name from User where POS_Access__c=true and IsActive=true]; 
        					 		
        } else { // get shoppers From Both SpiritsHierarchy, WineHierarchy
            List<Id> userSpiritsOrgIds = new List<Id>();
            List<Id> userWineOrgIds = new List<Id>();
            for(Account_Member__c am : [SELECT Account__r.Spirits_Hierarchy__c, Account__r.Wine_Hierarchy__c from Account_Member__c where User__c=:UserInfo.getUserId() and Active__c=true]) {
                if(am.Account__r.Spirits_Hierarchy__c != null) {
                    userSpiritsOrgIds.add(am.Account__r.Spirits_Hierarchy__c);
                }
                
                if(am.Account__r.Wine_Hierarchy__c != null) {
                    userWineOrgIds.add(am.Account__r.Wine_Hierarchy__c);
                }               
            }
            System.debug('userSpiritsOrgIds -' + userSpiritsOrgIds + ' userWineOrgIds -' + userWineOrgIds);
            
            Set<Id> userSpiritsOrgIdTree = Service_API.getAllChildOU(userSpiritsOrgIds);
            Set<Id> userWineOrgIdTree = Service_API.getAllChildOU(userWineOrgIds);
            
            List<Account_Member__c> membersFromSpiritsOrgAccts = [SELECT User__c, Account__c FROM Account_Member__c where Active__c=true 
                                                                    and Account__r.Spirits_Hierarchy__c in :userSpiritsOrgIdTree];
            List<Account_Member__c> membersFromWineOrgAccts = [SELECT User__c, Account__c FROM Account_Member__c where Active__c=true 
                                                                    and Account__r.Wine_Hierarchy__c in :userWineOrgIdTree];                                                                    
            List<Id> userIdsFromSpiritsOrgAccts = new List<Id>();
            for(Account_Member__c am : membersFromSpiritsOrgAccts) {
                userIdsFromSpiritsOrgAccts.add(am.User__c);
            }        
            
            List<Id> userIdsFromWineOrgAccts = new List<Id>();
            for(Account_Member__c am : membersFromWineOrgAccts) {
                userIdsFromWineOrgAccts.add(am.User__c);
            } 
            
            // make users from Both Spirit and Wine Hierarchy available for selection type-ahead       
            shoppersFromOrgHierarchy = [SELECT Id, Name from User where POS_Access__c=true and IsActive=true and 
                                          (Id in :userIdsFromSpiritsOrgAccts or Id in :userIdsFromWineOrgAccts)];
        }							
		
		System.debug('shoppersFromOrgHierarchy -' + shoppersFromOrgHierarchy);   
        System.debug('selectedTab ' + selectedTab);
                                                    
        // set right values for the ControllerBase
        breadCrumbs = new List<POS_BreadCrumb>();
        breadCrumbs.add(new POS_BreadCrumb('POS','POS_OrderWindowView'));
        breadCrumbs.add(new POS_BreadCrumb('Ordering Timeline','POS_OrderTimeline'));
        breadCrumbs.add(new POS_BreadCrumb('Budgeting - ' + orderWindow.Name,'/apex/POS_BudgetingGrid?owId=' + orderWindow.Id));        
    }


    public PageReference saveGrid() {
        //System.debug( 'shopperName - '+ shopperName  + ' gridDataBrand -'+ gridDataBrand);
        String gridDataJSON = ApexPages.currentPage().getParameters().get('gridData');
        String deletedBudgetIds = ApexPages.currentPage().getParameters().get('deletedBudgetIds');
        selectedTab = ApexPages.currentPage().getParameters().get('selectedTab');
       
        System.debug( 'gridDataJSON ' + gridDataJSON);
        System.debug( 'deletedBudgetIds ' + deletedBudgetIds);
        System.debug( 'selectedTab ' + selectedTab);

        List<SlickGridRow> slickGridRows = (List<SlickGridRow>) JSON.deserialize(gridDataJSON, List<SlickGridRow>.class);
        System.debug( 'slickGridRows.size() ' + slickGridRows.size());
        
        List<Budget__c> budgetRecs = getBudgetObjectRecords(slickGridRows);
        List<Budget__c> budgetRecsForDelete = getBudgetObjectRecordsForDelete(deletedBudgetIds);
        
        try {
            upsert(budgetRecs);
            delete(budgetRecsForDelete);
        
        } catch(System.DMLException e) { // handle FIELD_CUSTOM_VALIDATION_EXCEPTION
            ApexPages.addMessages(e);
            return null;
        }
        
        loadOrderWindowBudget(orderWindow.Id);
        loadOrderWindowBudgetIA(orderWindow.Id);
        return new PageReference('/apex/POS_BudgetingGrid?owId=' + orderWindow.Id);
    }     
    
    public PageReference resetGrid() {
        return new PageReference('/apex/POS_BudgetingGrid?owId=' + orderWindow.Id);
    } 
    
    public PageReference recordTabSelection() {
    	
    	System.debug( 'selectedTab ' + selectedTab);
        return null;
    }    
    
    private void loadOrderWindowBudget(String owId) {
        
        orderwindowBudgetsMap = new Map<Id, Budget__c>([SELECT Id FROM Budget__c where Order_Window__c=:owId and 
                                            (Shopper__c=:UserInfo.getUserId() or 
                                             Budgeter__c=:UserInfo.getUserId() or Budget_Creator__c=:UserInfo.getUserId())]);
        
        // Map.values doesn't retain the sort, so querying again.   
        //orderwindowBudgets = orderwindowBudgetsMap.values();    
        orderwindowBudgets  = [SELECT Id, Account__c, Account__r.Name, Amount__c, Brand__c, Brand__r.Name, Budgeter__c, Budgeter__r.Name, Channel__c, 
            Item__c, Item_Allocation_Quantity__c, Sub_Allocated_Amount__c, Sub_Allocated_Item_Quantity__c,
            LastModifiedById, LastModifiedDate, Organizational_Unit__r.Name, Organizational_Unit__r.Hierarchy_Location__c, Organizational_Unit__c, Parent__c, Program__c, Program__r.Name,
            Shopper__c, Shopper__r.Name, 
                    (SELECT Id, Account__c, Account__r.Name, Amount__c, Brand__c, Brand__r.Name, Budgeter__c, Budgeter__r.Name, 
                    Channel__c, Item__c, Item_Allocation_Quantity__c, Sub_Allocated_Amount__c, Sub_Allocated_Item_Quantity__c, LastModifiedById, LastModifiedDate, 
                    Organizational_Unit__r.Name, Organizational_Unit__r.Hierarchy_Location__c, Organizational_Unit__c, Parent__c, Program__c, Program__r.Name,
                    Shopper__c, Shopper__r.Name FROM Budgets__r where  Brand__c != null order by Shopper__r.Name) 
               FROM Budget__c where Order_Window__c=:owId and Brand__c != null and
                                        Parent__r.Shopper__c != :UserInfo.getUserId() and
                                            (Shopper__c=:UserInfo.getUserId() or 
                                             Budgeter__c=:UserInfo.getUserId() or Budget_Creator__c=:UserInfo.getUserId()) and
                                            (Parent__r.Shopper__c != :UserInfo.getUserId() and Parent__r.Budgeter__c != :UserInfo.getUserId() and
                                             Parent__r.Budget_Creator__c != :UserInfo.getUserId())
                                            order by Shopper__r.Name];
                                            
        //myBudgets =   [SELECT Id, Amount__c FROM Budget__c where Order_Window__c=:owId and Shopper__c=:UserInfo.getUserId() ] ;                           

        System.debug('orderwindowBudgets = ' + orderwindowBudgets );
    }
    
    private void loadOrderWindowBudgetIA(String owId) {
        
        // no need to populate 'orderwindowBudgetsMap' as that would have been taken care by 'loadOrderWindowBudget' call prior to this.
        orderwindowBudgetsIA  = [SELECT Id, Account__c, Account__r.Name, Budgeter__c, Budgeter__r.Name, Channel__c, Item__r.Name,
            Item__c, Item_Allocation_Quantity__c, Sub_Allocated_Item_Quantity__c, Organizational_Unit__r.Name, Organizational_Unit__r.Hierarchy_Location__c, Organizational_Unit__c,
            LastModifiedById, LastModifiedDate, Parent__c, Program__c, Program__r.Name,
            Shopper__c, Shopper__r.Name, 
                    (SELECT Id, Account__c, Account__r.Name, Budgeter__c, Budgeter__r.Name, Channel__c, Item__r.Name, 
                    Item__c, Item_Allocation_Quantity__c, Sub_Allocated_Item_Quantity__c, Organizational_Unit__r.Name, Organizational_Unit__r.Hierarchy_Location__c, Organizational_Unit__c,
                    LastModifiedById, LastModifiedDate, Parent__c, Program__c, Program__r.Name,
                    Shopper__c, Shopper__r.Name FROM Budgets__r where Item__c != null order by Shopper__r.Name) 
               FROM Budget__c where Order_Window__c=:owId and Item__c != null and
                                        Parent__r.Shopper__c != :UserInfo.getUserId() and
                                            (Shopper__c=:UserInfo.getUserId() or 
                                             Budgeter__c=:UserInfo.getUserId() or Budget_Creator__c=:UserInfo.getUserId()) and
                                            (Parent__r.Shopper__c != :UserInfo.getUserId() and Parent__r.Budgeter__c != :UserInfo.getUserId() and
                                             Parent__r.Budget_Creator__c != :UserInfo.getUserId())
                                            order by Shopper__r.Name];
                                            
        System.debug('orderwindowBudgetsIA = ' + orderwindowBudgetsIA );
    }    
    
    public class SlickGridRow {

        public String indent;
        public String parent;
        public Boolean updated;
        
        public String Id;
        public String parentId;
        public Double Budget;
        public String Channel;
        public String Shopper;
        public String ShopperId;
        public String Distributor;
        public String DistributorId;
        public String Geography;
        public String GeographyId;
        public String Brand;
        public String BrandId;
        public String Item;
        public String ItemId;        
        public String Budgeter;
        public String BudgeterId;
        public String Program;
        public String ProgramId;
        public String Suballocated;
        public String Unallocated;
        
        public Budget__c populateBudgetObjectRecord(Budget__c bud) {
            
            /* required field, frontend should validate before post */
            bud.Shopper__c = ShopperId;
            
            /* only one of BrandId or ItemId should be not null based on Allocation Type - Brand/Item */
            if(BrandId != null && BrandId != '') {
                bud.Brand__c = BrandId;
                bud.Amount__c = Budget; // Budget field will contain Dollar Amt. in this case
            } else if(ItemId != null && ItemId != '') {
                bud.Item__c = ItemId;
                bud.Item_Allocation_Quantity__c = Budget; // Budget field will contain Item Qty. in this case
            }          
            
            if(parentId != null && parentId != '') {
                bud.Parent__c = parentId;
            }
            
            if(ProgramId != null && ProgramId != '') {
                bud.Program__c = ProgramId;
            } else {
                bud.Program__c = null;
            }
            
            if(DistributorId != null && DistributorId != '') {
                bud.Account__c = DistributorId;
            } else {
                bud.Account__c = null;
            }
                
            if(GeographyId != null && GeographyId != '') {
                bud.Organizational_Unit__c = GeographyId;
            } else {
                bud.Organizational_Unit__c = null;
            }
                                
            if(Channel != null && Channel != '' && Channel != '- Select -') {
                bud.Channel__c = Channel;
            } else {
                bud.Channel__c = null;
            }
            
            return bud;
        }
        
    }
    
    public List<Budget__c> getBudgetObjectRecordsForDelete(String deletedBudgetIdsBrandStr) {
        List<Budget__c> budgetForDelete = new List<Budget__c>();
        
        if(deletedBudgetIdsBrandStr != null && deletedBudgetIdsBrandStr != '') {
            String[] deletedBudgetIdsBrandAll = deletedBudgetIdsBrandStr.split(',');
            System.debug( 'deletedBudgetIdsBrandAll ' + deletedBudgetIdsBrandAll);
            
            List<Id> deletedBudgetIdsBrand = new List<Id>();
            
            for(String budId : deletedBudgetIdsBrandAll) {
                if(budId!='' && !budId.startsWith('new')) {
                    deletedBudgetIdsBrand.add(budId);
                }
            }
            System.debug( 'deletedBudgetIdsBrand ' + deletedBudgetIdsBrand);
            
            budgetForDelete = [Select Id from Budget__c where Id in :deletedBudgetIdsBrand];
        }
        
        return budgetForDelete;
    }
    
    public List<Budget__c> getBudgetObjectRecords(List<SlickGridRow> gridRows) {
        
        List<Budget__c> budgetRecs = new List<Budget__c>();
        
        Budget__c bud;
        for(SlickGridRow sgr : gridRows) {
            System.debug( 'slickGridRow.id ' + sgr.Id + ' updated ' + sgr.updated + ' Budget ' + sgr.Budget);
            
            if(!sgr.updated) {
                continue;
            }
            
            if(sgr.Id.startsWith('new')) {
                bud = new Budget__c();
                bud.Order_Window__c = orderWindow.Id;
                bud.Budgeter__c = UserInfo.getUserId();
            } else {
                bud = orderwindowBudgetsMap.get(sgr.Id);
                System.debug( 'slickGridRow existing row' + bud);
            }
            
            budgetRecs.add(sgr.populateBudgetObjectRecord(bud));
        }   
        
        return budgetRecs;  
    }
    
    /*testMethod for this class are in POS_TestBudgetingGrid */

}