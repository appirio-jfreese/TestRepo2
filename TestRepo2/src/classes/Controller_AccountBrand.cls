public with sharing class Controller_AccountBrand {
    
	private set<Id> accountRecordTypesIds {private get; private set;}
    
    public list<SelectOption> possibleAccounts {public get; public set;}
    public accountBrand__c accountbrand {get;set;}
    public ApexPages.StandardSetController setCtrl  {public get; public set;}
    public ApexPages.StandardSetController setCtrlB {public get; public set;}
    public String avaliableS{get;set;}
    public String accountBL{get;set;}
    public List<accountBrand> accountBrandList     {
        public get {
            if (accountBrandList == null) {
                accountBrandList = new List<accountBrand>();
                for(sObject o : setCtrl.getRecords()) {
                    accountBrandList.add(new accountBrand((AccountBrand__c) o));
                }
            }
            return accountBrandList;            
        }
        public set;
    }    
    public List<brand> brandList     {
        public get {
            if (brandList == null) {
                brandList = new List<brand>();
                for(sObject o : setCtrlB.getRecords()) {
                    brandList.add(new brand((Brand__c) o));
                }
            }
            return brandList;            
        }
        public set;
    }    
    public boolean accountEditable {
        public get{
           return accountbrand.Account__c == null;
        } 
        public set;
    }   
    public Id AccountId {
        public get {
          return accountbrand.Account__c;
        }
        private set;
    }
    
    public Id cloneAccount {public get; public set;}
      
    public Controller_AccountBrand(ApexPages.StandardSetController controller) {
       	List<RecordType> accountRecordTypes =[Select r.Name, r.Id From RecordType r WHERE r.SobjectType = 'Account' AND r.Name = 'Distributor'];
       	accountRecordTypesIds = new set<id>();
       	for(RecordType r : accountRecordTypes ){
       		accountRecordTypesIds.add(r.Id);
       	}  	
    	
        string accountbrandId = apexpages.currentpage().getparameters().get('Id');
        if(accountbrandId==null || accountbrandId=='') {
            accountbrand = new Accountbrand__c();
        } else {
            accountbrand = new Accountbrand__c(account__c=accountbrandId);
        }
        reloadLists();
        possibleAccounts = new list<SelectOption>();
        possibleAccounts.add(new SelectOption('', 'Select Distributor'));
        list<Account> accountsDistr = [select id, name from Account where id != :AccountId and Account.RecordTypeId in :accountRecordTypesIds ORDER BY name];
        for(Account distr : accountsDistr){
            possibleAccounts.add(new SelectOption(distr.Id, distr.Name));
        }
    }

    public void reloadLists() {     
    
        Integer currentPageB = null;
        if(setCtrlB != null && setCtrlB.getPageNumber() != null){
            currentPageB = setCtrlB.getPageNumber();
        }
        
        if(accountBL == null){
            setCtrl = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id, Account__c, Brand__r.Name, Brand__r.Parent_Brand__r.Name, Brand__r.Brand_Variant_Grouping__c FROM AccountBrand__c WHERE Account__c=: AccountId and Account__r.RecordTypeId in :accountRecordTypesIds and brand__r.diageo_direct_visible__c = true ORDER BY Brand__r.Name  LIMIT 9000]));
        }else{
            String filterSetCtrl = '%'+accountBL+'%';
            setCtrl = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id, Account__c, Brand__r.Name, Brand__r.Parent_Brand__r.Name, Brand__r.Brand_Variant_Grouping__c FROM AccountBrand__c WHERE Account__c=: AccountId and Account__r.RecordTypeId in :accountRecordTypesIds and brand__r.diageo_direct_visible__c = true AND Brand__r.Name LIKE :filterSetCtrl ORDER BY Brand__r.Name LIMIT 9000]));
        }
        
        setCtrl.setPageSize(15);
       
        accountBrandList = null;       
        if(avaliableS == null){             
            setCtrlB = new ApexPages.StandardSetController(Database.getQueryLocator([
                Select Id, Name, Parent_Brand__r.Name, Brand_Variant_Grouping__c FROM Brand__c WHERE diageo_direct_visible__c = true and Id NOT IN 
                    (SELECT Brand__c FROM AccountBrand__c WHERE Account__c=:AccountId and Account__r.RecordTypeId in :accountRecordTypesIds)
                    ORDER BY Name LIMIT 9000
                ]
            ));
        } else {
             String filter = '%'+avaliableS+'%';
             setCtrlB = new ApexPages.StandardSetController(Database.getQueryLocator([
                Select Id, Name, Parent_Brand__r.Name, Brand_Variant_Grouping__c FROM Brand__c WHERE diageo_direct_visible__c = true and Id NOT IN 
                    (SELECT Brand__c FROM AccountBrand__c WHERE Account__c=:AccountId and Account__r.RecordTypeId in :accountRecordTypesIds)
                    AND Name LIKE :filter
                    ORDER BY Name  LIMIT 9000
                ]
            ));         
        }
        setCtrlB.setPageSize(15);
        if(currentPageB != null){
            setCtrlB.setPageNumber(currentPageB);
        }
        
        brandList = null;
    }  
    
     public void reloadListsAfterSearch() {     
        
        if(setCtrlB != null ){
            setCtrlB.setPageNumber(1);
        }
        reloadLists();     
    } 
     
    public void deleteRelations() {
        List<AccountBrand__c> selected = new List<AccountBrand__c>();
        for(accountBrand c : accountBrandList) {
            if(c.selected == true) {
                selected.add(c.cb);
            }
        }
        if (selected.size()>0) {
            delete selected;
        }
        reloadLists();
    }

    public void deleteAll() {
        List<AccountBrand__c> selected = [SELECT id FROM AccountBrand__c WHERE Account__c=:AccountId and Account__r.RecordTypeId in :accountRecordTypesIds and brand__r.diageo_direct_visible__c = true];

        if (selected.size()>0) {
            delete selected;
        }
        
        reloadLists();
    }

    public void addAll() {
        List<AccountBrand__c> selected = new List<AccountBrand__c>();
        list<brand__c> allBrands = new list<brand__c>();
        
        if(avaliableS == null){             
            allBrands = 
                [ Select Id FROM Brand__c WHERE diageo_direct_visible__c = true and Id NOT IN 
                    (SELECT Brand__c FROM AccountBrand__c WHERE Account__c=:AccountId and Account__r.RecordTypeId in :accountRecordTypesIds)
                ];
        } else {
             String filter = '%'+avaliableS+'%';
             allBrands =
                [ Select Id FROM Brand__c WHERE diageo_direct_visible__c = true and Id NOT IN 
                    (SELECT Brand__c FROM AccountBrand__c WHERE Account__c=:AccountId and Account__r.RecordTypeId in :accountRecordTypesIds)
                    AND Name LIKE :filter
                ];
        }
        
        for(Brand__c brand : allBrands){
            selected.add(new AccountBrand__c(Account__c = AccountId, Brand__c = brand.id));
        }
        
        if (selected.size()>0) {
            insert selected;
        }
        reloadLists();
    }
    
    public PageReference cloneRelationsTo() {
        if(cloneAccount != null){
            list<AccountBrand__c> currentRelToDelete = [select id from AccountBrand__c where Account__c = :cloneAccount and Account__r.RecordTypeId in :accountRecordTypesIds];
            delete currentRelToDelete;
            list<AccountBrand__c> newRelToCopy = [select id, brand__r.id from AccountBrand__c where Account__c = :accountId and Account__r.RecordTypeId in :accountRecordTypesIds and brand__r.diageo_direct_visible__c = true];
            list<AccountBrand__c> relToInsert = new list<AccountBrand__c>();
            for(AccountBrand__c rel : newRelToCopy){
                relToInsert.add(new AccountBrand__c(Account__c = cloneAccount, Brand__c = rel.brand__r.id));
            }
            insert relToInsert;
            return new PageReference('/'+cloneAccount);
        }
        
        return null;
    }
    
    public PageReference cloneRelationsFrom() {
        if(cloneAccount != null){
            list<AccountBrand__c> currentRelToDelete = [select id from AccountBrand__c where Account__c = :accountId and Account__r.RecordTypeId in :accountRecordTypesIds];
            delete currentRelToDelete;
            list<AccountBrand__c> newRelToCopy = [select id, brand__r.id from AccountBrand__c where Account__c = :cloneAccount and Account__r.RecordTypeId in :accountRecordTypesIds and brand__r.diageo_direct_visible__c = true];
            list<AccountBrand__c> relToInsert = new list<AccountBrand__c>();
            for(AccountBrand__c rel : newRelToCopy){
                relToInsert.add(new AccountBrand__c(Account__c = accountId, Brand__c = rel.brand__r.id));
            }
            insert relToInsert;
            reloadLists();
            return null;
        }
        
        return null;
    }    
    
    public void addRelations() {
        List<AccountBrand__c> selected = new List<AccountBrand__c>();
        for(brand b : brandList) {
            if(b.selected == true) {
               selected.add(
                    new AccountBrand__c(
                        Account__c = AccountId,
                        Brand__c   = b.b.Id
                    )
                );
            }
        }
        if (selected.size()>0) {
            insert selected;
        }
        reloadLists();
    }
        
    public Boolean hasNext {
        get {
            return setCtrl.getHasNext();
        }
    }
    
    public Boolean hasPrevious {
        get {
            return setCtrl.getHasPrevious();
        }
        set;
    }
    
    public Integer pageNumber {
        get {
            return setCtrl.getPageNumber();
        }
        set;
    }
    
    public Integer totalPages {
        get {
            totalPages = setCtrl.getResultSize() / setCtrl.getPageSize();
            return totalPages;
        }
        set;
    }
    
    public void first() {
        setCtrl.first();
        accountBrandList = null;
    }

    public void last() {
        setCtrl.last();
        accountBrandList = null;
    }

    public void previous() {
        setCtrl.previous();
        accountBrandList = null;
    }

    public void next() {
        setCtrl.next();
        accountBrandList = null;
    }

    public Boolean hasNextB {
        get {
            return setCtrlB.getHasNext();
        }
    }
    
    public Boolean hasPreviousB {
        get {
            return setCtrlB.getHasPrevious();
        }
        set;
    }
    
    public Integer pageNumberB {
        get {
            return setCtrlB.getPageNumber();
        }
        set;
    }
    
    public Integer totalPagesB {
        get {
            totalPagesB = setCtrlB.getResultSize() / setCtrlB.getPageSize();
            return totalPagesB;
        }
        set;
    }
    
    public void firstB() {
        setCtrlB.first();
        brandList = null;
    }

    public void lastB() {
        setCtrlB.last();
        brandList = null;
    }

    public void previousB() {
        setCtrlB.previous();
        brandList = null;
    }

    public void nextB() {
        setCtrlB.next();
        brandList = null;
    }
    
    public class accountBrand {
        public AccountBrand__c cb {get; set;}
        public Boolean selected {get; set;}
        
        public accountBrand(AccountBrand__c c) {
            cb = c;
            selected = false;
        }
    }    

    public class brand {
        public Brand__c b {get; set;}
        public Boolean selected {get; set;}
        
        public brand(Brand__c bc) {
            b = bc;
            selected = false;
        }
    }    
}