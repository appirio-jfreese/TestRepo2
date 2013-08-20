public with sharing class ControllerContentBrand {
    private ApexPages.StandardController con;
    

    public ApexPages.StandardSetController setCtrl  {public get; public set;}
    public ApexPages.StandardSetController setCtrlB {public get; public set;}
    public String avaliableS{get;set;}
    public String accountBL{get;set;}
    
    public List<contentBrand> contentBrandList     {
        public get {
            if (contentBrandList == null) {
                contentBrandList = new List<contentBrand>();
                for(sObject o : setCtrl.getRecords()) {
                    contentBrandList.add(new contentBrand((ContentBrand__c) o));
                }
            }
            return contentBrandList;            
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
    public boolean contentDescriptionEditable {
    	public get{
    	   return ((ContentBrand__c)con.getRecord()).Content_Description__c == null;
    	} 
    	public set;
	}	
	public Id ContentDescriptionId {
        public get {
		  return ((ContentBrand__c)con.getRecord()).Content_Description__c;
        }
        private set;
	}
      
    public ControllerContentBrand(ApexPages.StandardController controller) {
        if (!system.Test.isRunningTest()) {
            controller.addFields(new list<String>{'Id', 'Content_Description__c'});
            //controller.reset();
        }        
        con = controller;
        reloadLists();
    }

    public void reloadLists() {    	
    
    	Integer currentPageB = null;
    	if(setCtrlB != null && setCtrlB.getPageNumber() != null){
    		currentPageB = setCtrlB.getPageNumber();
    	}
    	
    	if(accountBL == null){
        	setCtrl = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id, Content_Description__c, Brand__r.Name FROM ContentBrand__c WHERE Content_Description__c=:ContentDescriptionId ORDER BY Brand__r.Name]));
    	}else{
    		String filterSetCtrl = '%'+accountBL+'%';
    		setCtrl = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id, Content_Description__c, Brand__r.Name FROM ContentBrand__c WHERE Content_Description__c=:ContentDescriptionId AND Brand__r.Name LIKE :filterSetCtrl ORDER BY Brand__r.Name]));	
    	}
       
        setCtrl.setPageSize(15);
       
        contentBrandList = null;       
        if(avaliableS == null){        		
	        setCtrlB = new ApexPages.StandardSetController(Database.getQueryLocator([
	            Select Id, Name FROM Brand__c WHERE Id NOT IN 
	                (SELECT Brand__c FROM ContentBrand__c WHERE Content_Description__c=:ContentDescriptionId)
	                ORDER BY Name
	            ]
	        ));
    	}else{
    		 String filter = '%'+avaliableS+'%';
    		 setCtrlB = new ApexPages.StandardSetController(Database.getQueryLocator([
	            Select Id, Name FROM Brand__c WHERE Id NOT IN 
	                (SELECT Brand__c FROM ContentBrand__c WHERE Content_Description__c=:ContentDescriptionId)
	                AND Name LIKE :filter
	                ORDER BY Name
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
        List<ContentBrand__c> selected = new List<ContentBrand__c>();
        for(contentBrand c : contentBrandList) {
            if(c.selected == true) {
                selected.add(c.cb);
            }
        }
        if (selected.size()>0) {
            delete selected;
        }
        reloadLists();
    }

    public void addRelations() {
        List<ContentBrand__c> selected = new List<ContentBrand__c>();
        for(brand b : brandList) {
            if(b.selected == true) {
                selected.add(
                    new ContentBrand__c(
                        Content_Description__c = ContentDescriptionId,
                        Brand__c               = b.b.Id
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
        contentBrandList = null;
    }

    public void last() {
        setCtrl.last();
        contentBrandList = null;
    }

    public void previous() {
        setCtrl.previous();
        contentBrandList = null;
    }

    public void next() {
        setCtrl.next();
        contentBrandList = null;
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
    
    public class contentBrand {
        public ContentBrand__c cb {get; set;}
        public Boolean selected {get; set;}
        
        public contentBrand(ContentBrand__c c) {
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