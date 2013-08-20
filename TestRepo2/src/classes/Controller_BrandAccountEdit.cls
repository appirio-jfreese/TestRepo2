public with sharing class Controller_BrandAccountEdit {
    
	private set<Id> accountRecordTypesIds {private get; private set;}
	
    public list<SelectOption> possibleBrands {public get; public set;}

    public ApexPages.StandardSetController setCtrl  {public get; public set;}
    public ApexPages.StandardSetController setCtrlB {public get; public set;}
    public String avaliableS{get;set;}
    public String accountBL{get;set;}
    
    public accountBrand__c accountbrand {get;set;}
    
    public List<brandAccount> brandAccountList     {
        public get {
            if (brandAccountList == null) {
                brandAccountList = new List<brandAccount>();
                for(sObject o : setCtrl.getRecords()) {
                    brandAccountList.add(new brandAccount((AccountBrand__c) o));
                }
            }
            return brandAccountList;            
        }
        public set;
    }    
    
    public List<distributor> distribList     {
        public get {
            if (distribList == null) {
                distribList = new List<distributor>();
                for(sObject o : setCtrlB.getRecords()) {
                    distribList.add(new distributor((Account) o));
                }
            }
            return distribList;            
        }
        public set;
    }    
    public boolean accountEditable {
    	public get{
    	   return (accountbrand.brand__c == null);
    	} 
    	public set;
	}	
	public Id BrandId {
        public get {
		  return accountbrand.brand__c;
        }
        private set;
	}
	
	public Id cloneId {public get; public set;}
      
    public Controller_BrandAccountEdit(ApexPages.StandardController controller) {
        if (!system.Test.isRunningTest()) {
            controller.addFields(new list<String>{'Id', 'Account__c'});
        }    
        
       	List<RecordType> accountRecordTypes =[Select r.Name, r.Id From RecordType r WHERE r.SobjectType = 'Account' AND r.Name = 'Distributor'];
       	accountRecordTypesIds = new set<id>();
       	for(RecordType r : accountRecordTypes ){
       		accountRecordTypesIds.add(r.Id);
       	}
       	
        accountbrand = (AccountBrand__c)controller.getrecord();
        accountbrand = [select Brand__c, Id from AccountBrand__c where id = :accountbrand.id];
        
        reloadLists();
        possibleBrands = new list<SelectOption>();
		possibleBrands.add(new SelectOption('', 'Select Brand'));
        list<Brand__c> brands = [select id, name from Brand__c where id != :BrandId and diageo_direct_visible__c = true ORDER BY name];
        for(Brand__c brand : brands){
        	possibleBrands.add(new SelectOption(brand.Id, brand.Name));
        }
    }

     public void reloadLists() {    	
    
    	Integer currentPageB = null;
    	if(setCtrlB != null && setCtrlB.getPageNumber() != null){
    		currentPageB = setCtrlB.getPageNumber();
    	}
 		
 		if(accountBL == null){
        	setCtrl = new ApexPages.StandardSetController(Database.getQueryLocator(
        		[
        			Select Id, Account__r.Name, 
	        			Account__r.Spirits_Hierarchy__r.Id, Account__r.Spirits_Hierarchy__r.Label__c, Account__r.Spirits_Hierarchy__r.Name, Account__r.Spirits_Hierarchy__r.Type__c,
	        			Account__r.Spirits_Hierarchy__r.Parent__r.Id, Account__r.Spirits_Hierarchy__r.Parent__r.Label__c, Account__r.Spirits_Hierarchy__r.Parent__r.Name, Account__r.Spirits_Hierarchy__r.Parent__r.Type__c,
				        Account__r.Spirits_Hierarchy__r.Parent__r.Parent__r.Id, Account__r.Spirits_Hierarchy__r.Parent__r.Parent__r.Label__c, Account__r.Spirits_Hierarchy__r.Parent__r.Parent__r.Name, Account__r.Spirits_Hierarchy__r.Parent__r.Parent__r.Type__c,
				        Account__r.Spirits_Hierarchy__r.Parent__r.Parent__r.Parent__r.Id, Account__r.Spirits_Hierarchy__r.Parent__r.Parent__r.Parent__r.Label__c, Account__r.Spirits_Hierarchy__r.Parent__r.Parent__r.Parent__r.Name,Account__r.Spirits_Hierarchy__r.Parent__r.Parent__r.Parent__r.Type__c,        			
	        			Account__r.Parent.name  
        			FROM AccountBrand__c WHERE Brand__c = :BrandId and Account__r.RecordTypeId in :accountRecordTypesIds and brand__r.diageo_direct_visible__c = true ORDER BY Account__r.Name LIMIT 9000
        		]
        	)); 
 		}else{
 			String filterSetCtrl = '%'+accountBL+'%';
 			setCtrl = new ApexPages.StandardSetController(Database.getQueryLocator(
 				[
 					Select Id, Account__r.Name, 
 						Account__r.Spirits_Hierarchy__r.Id, Account__r.Spirits_Hierarchy__r.Label__c, Account__r.Spirits_Hierarchy__r.Name, Account__r.Spirits_Hierarchy__r.Type__c,
	        			Account__r.Spirits_Hierarchy__r.Parent__r.Id, Account__r.Spirits_Hierarchy__r.Parent__r.Label__c, Account__r.Spirits_Hierarchy__r.Parent__r.Name, Account__r.Spirits_Hierarchy__r.Parent__r.Type__c,
				        Account__r.Spirits_Hierarchy__r.Parent__r.Parent__r.Id, Account__r.Spirits_Hierarchy__r.Parent__r.Parent__r.Label__c, Account__r.Spirits_Hierarchy__r.Parent__r.Parent__r.Name, Account__r.Spirits_Hierarchy__r.Parent__r.Parent__r.Type__c,
				        Account__r.Spirits_Hierarchy__r.Parent__r.Parent__r.Parent__r.Id, Account__r.Spirits_Hierarchy__r.Parent__r.Parent__r.Parent__r.Label__c, Account__r.Spirits_Hierarchy__r.Parent__r.Parent__r.Parent__r.Name,Account__r.Spirits_Hierarchy__r.Parent__r.Parent__r.Parent__r.Type__c,        			
	        			Account__r.Parent.name  
	        		FROM AccountBrand__c WHERE Brand__c = : BrandId and Account__r.RecordTypeId in :accountRecordTypesIds and brand__r.diageo_direct_visible__c = true AND Account__r.Name LIKE :filterSetCtrl ORDER BY Account__r.Name LIMIT 9000
	        	]
	        ));
 		}
        
        setCtrl.setPageSize(15);
       
        brandAccountList = null;       
        if(avaliableS == null){        		
	        setCtrlB = new ApexPages.StandardSetController(Database.getQueryLocator(
	        	 [
		        	 Select Id, Name, 
			        	 Spirits_Hierarchy__r.Id, Spirits_Hierarchy__r.Label__c, Spirits_Hierarchy__r.Name, Spirits_Hierarchy__r.Type__c,
			        	 Spirits_Hierarchy__r.Parent__r.Id,Spirits_Hierarchy__r.Parent__r.Label__c, Spirits_Hierarchy__r.Parent__r.Name,Spirits_Hierarchy__r.Parent__r.Type__c,
			        	 Spirits_Hierarchy__r.Parent__r.Parent__r.Id, Spirits_Hierarchy__r.Parent__r.Parent__r.Label__c, Spirits_Hierarchy__r.Parent__r.Parent__r.Name, Spirits_Hierarchy__r.Parent__r.Parent__r.Type__c,
			        	 Spirits_Hierarchy__r.Parent__r.Parent__r.Parent__r.Id, Spirits_Hierarchy__r.Parent__r.Parent__r.Parent__r.Label__c, Spirits_Hierarchy__r.Parent__r.Parent__r.Parent__r.Name,Spirits_Hierarchy__r.Parent__r.Parent__r.Parent__r.Type__c,
			             Parent.name 
		             FROM Account WHERE Account.RecordTypeId in :accountRecordTypesIds and Id NOT IN 
		                (SELECT Account__c FROM AccountBrand__c WHERE Brand__c=:BrandId and Account__r.RecordTypeId in :accountRecordTypesIds and brand__r.diageo_direct_visible__c = true) 
		            ORDER BY Name LIMIT 9000
	            ]
	        ));
    	} else {
    		 String filter = '%'+avaliableS+'%';
    		 setCtrlB = new ApexPages.StandardSetController(Database.getQueryLocator(
    		 	[
	           		Select Id, Name, 
			            Spirits_Hierarchy__r.Id, Spirits_Hierarchy__r.Label__c, Spirits_Hierarchy__r.Name, Spirits_Hierarchy__r.Type__c,
					    Spirits_Hierarchy__r.Parent__r.Id,Spirits_Hierarchy__r.Parent__r.Label__c, Spirits_Hierarchy__r.Parent__r.Name,Spirits_Hierarchy__r.Parent__r.Type__c,
					    Spirits_Hierarchy__r.Parent__r.Parent__r.Id, Spirits_Hierarchy__r.Parent__r.Parent__r.Label__c, Spirits_Hierarchy__r.Parent__r.Parent__r.Name, Spirits_Hierarchy__r.Parent__r.Parent__r.Type__c,
					    Spirits_Hierarchy__r.Parent__r.Parent__r.Parent__r.Id, Spirits_Hierarchy__r.Parent__r.Parent__r.Parent__r.Label__c, Spirits_Hierarchy__r.Parent__r.Parent__r.Parent__r.Name,Spirits_Hierarchy__r.Parent__r.Parent__r.Parent__r.Type__c,
					    Parent.name 
	           		FROM Account WHERE Account.RecordTypeId in :accountRecordTypesIds and Id NOT IN 
	                	(SELECT Account__c FROM AccountBrand__c WHERE Brand__c=:BrandId and Account__r.RecordTypeId in :accountRecordTypesIds and brand__r.diageo_direct_visible__c = true)
	           		AND Name LIKE :filter
	             		ORDER BY Name LIMIT 9000
	            ]
	        ));    		
    	}
        setCtrlB.setPageSize(15);
        if(currentPageB != null){
        	setCtrlB.setPageNumber(currentPageB);
        }
        
        distribList = null;
    }  
    
     public void reloadListsAfterSearch() {    	
        
        if(setCtrlB != null ){
        	setCtrlB.setPageNumber(1);
        }
        reloadLists();     
    } 
     
    public void deleteRelations() {
        List<AccountBrand__c> selected = new List<AccountBrand__c>();
        for(brandAccount c : brandAccountList) {
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
        List<AccountBrand__c> selected = [SELECT id FROM AccountBrand__c WHERE Brand__c = : BrandId and Account__r.RecordTypeId in :accountRecordTypesIds and brand__r.diageo_direct_visible__c = true];

        if (selected.size()>0) {
            delete selected;
        }
        
        reloadLists();
    }

    public void addAll() {
        List<AccountBrand__c> selected = new List<AccountBrand__c>();
        list<Account> allAccounts = new list<Account>();
        
        if(avaliableS == null){        		
	        allAccounts = 
	            [
	            	Select Id, Name FROM Account WHERE Account.RecordTypeId in :accountRecordTypesIds and Id NOT IN 
	                (SELECT Account__c FROM AccountBrand__c WHERE Brand__c=:BrandId and Account__r.RecordTypeId in :accountRecordTypesIds and brand__r.diageo_direct_visible__c = true)
	            ];
    	} else {
    		 String filter = '%'+avaliableS+'%';
    		 allAccounts =
    		 	[ 	
    		 		Select Id, Name FROM Account WHERE Account.RecordTypeId in :accountRecordTypesIds and Id NOT IN 
	                (SELECT Account__c FROM AccountBrand__c WHERE Brand__c=:BrandId and Account__r.RecordTypeId in :accountRecordTypesIds and brand__r.diageo_direct_visible__c = true)
	                AND Name LIKE :filter 
	            ];
    	}
    	
    	for(Account distrib : allAccounts){
    		selected.add(new AccountBrand__c(Account__c = distrib.id, Brand__c = BrandId));
    	}
    	
        if (selected.size()>0) {
            insert selected;
        }
        
        reloadLists();
    }
    
	public PageReference cloneRelationsTo() {
       	if(cloneId != null){
       		list<AccountBrand__c> currentRelToDelete = [select id from AccountBrand__c where Brand__c = :cloneId and Account__r.RecordTypeId in :accountRecordTypesIds ];
       		delete currentRelToDelete;
       		list<AccountBrand__c> newRelToCopy = [select id, account__r.id from AccountBrand__c where Brand__c = :BrandId and Account__r.RecordTypeId in :accountRecordTypesIds and brand__r.diageo_direct_visible__c = true ];
       		list<AccountBrand__c> relToInsert = new list<AccountBrand__c>();
       		for(AccountBrand__c rel : newRelToCopy){
       			relToInsert.add(new AccountBrand__c(Account__c = rel.account__r.id, Brand__c = cloneId));
       		}
       		insert relToInsert;
       		return new PageReference('/'+cloneId);
       	}
       	
      	return null;
    }
    
	public PageReference cloneRelationsFrom() {
       	if(cloneId != null){
       		list<AccountBrand__c> currentRelToDelete = [select id from AccountBrand__c where Brand__c = :BrandId and Account__r.RecordTypeId in :accountRecordTypesIds ];
       		delete currentRelToDelete;
       		list<AccountBrand__c> newRelToCopy = [select id, account__r.id from AccountBrand__c where Brand__c = :cloneId and Account__r.RecordTypeId in :accountRecordTypesIds and brand__r.diageo_direct_visible__c = true];
       		list<AccountBrand__c> relToInsert = new list<AccountBrand__c>();
       		for(AccountBrand__c rel : newRelToCopy){
       			relToInsert.add(new AccountBrand__c(Account__c = rel.account__r.id, Brand__c = BrandId));
       		}
       		insert relToInsert;
			reloadLists();
       		return null;
       	}
       	
       	
       	return null;
    }    
    
    public void addRelations() {
        List<AccountBrand__c> selected = new List<AccountBrand__c>();
        for(distributor d : distribList) {
        	if(d.selected == true) {
               selected.add(
                    new AccountBrand__c(
                        Account__c = d.a.id,
                        Brand__c   = BrandId
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
        brandAccountList = null;
    }

    public void last() {
        setCtrl.last();
        brandAccountList = null;
    }

    public void previous() {
        setCtrl.previous();
        brandAccountList = null;
    }

    public void next() {
        setCtrl.next();
        brandAccountList = null;
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
        distribList = null;
    }

    public void lastB() {
        setCtrlB.last();
        distribList = null;
    }

    public void previousB() {
        setCtrlB.previous();
        distribList = null;
    }

    public void nextB() {
        setCtrlB.next();
        distribList = null;
    }
    
    public class brandAccount {
        public AccountBrand__c cb {get; set;}
        public Boolean selected {get; set;}
        
        public brandAccount(AccountBrand__c c) {
            cb = c;
            selected = false;
        }
    }    

    public class distributor {
        public Account a {get; set;}
        public Boolean selected {get; set;}
        
        public distributor(Account aa) {
            a = aa;
            selected = false;
        }
    }    
}