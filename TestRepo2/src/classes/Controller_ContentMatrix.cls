public with sharing class Controller_ContentMatrix {

    public ApexPages.StandardSetController setCtrl  {public get; public set;}
    
	private Content_Matrix__c matrixRecord;

	public string cm_type {get; set;}
	public string cm_category {get; set;}
	public string cm_sub_category {get; set;}
	public string cm_sub_sub_category {get; set;}
	public string cm_sub_sub_sub_category {get; set;}
	
    public List<matrix> matrixList     {
        public get {
            if (matrixList == null) {
                matrixList = new List<matrix>();
                for(sObject o : setCtrl.getRecords()) {
                    matrixList.add(new matrix((Content_Matrix__c) o));
                }
            }
            return matrixList;            
        }
        public set;
    }  	
	
	public Controller_ContentMatrix() {

    	reloadLists();        
    }
  
   	
    public void reloadLists() {
        setCtrl = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id, Name, Category__c, Sub_Category__c, Sub_Sub_Category__c, Sub_Sub_Sub_Category__c,Matrix_Type__c FROM Content_Matrix__c where Matrix_Type__c = :cm_type]));
        setCtrl.setPageSize(15);
		matrixList = null;     	
    }  
  
    public void switchSection() {
    	reloadLists();
    }
    
    public void deleteMatrixItem() {
        List<Content_Matrix__c> selected = new List<Content_Matrix__c>();
        for(matrix c : matrixList) {
            if(c.selected == true) {
                selected.add(c.m);
            }
        }
        if (selected.size()>0) {
            delete selected;
        }
        reloadLists();
    }

    public void deleteAll() {
        List<Content_Matrix__c> selected = [Select Id, Name, Category__c, Sub_Category__c, Sub_Sub_Category__c, Sub_Sub_Sub_Category__c FROM Content_Matrix__c WHERE Matrix_Type__c = :cm_type];

        if (selected.size()>0) {
            delete selected;
        }
        
        reloadLists();
    }    
    
    public void cancel() {
    	cm_type = null;
    }
    
    public void saveMatrixItem() {
    	if(cm_category == null || cm_category == ''){
    		return;
    	}
    	Content_Matrix__c matrixRecord = new Content_Matrix__c();    	
      	matrixRecord.Category__c = cm_category;
      	matrixRecord.Sub_Category__c = cm_sub_category;
      	matrixRecord.Sub_Sub_Category__c = cm_sub_sub_category;
      	matrixRecord.Sub_Sub_Sub_Category__c = cm_sub_sub_sub_category;
      	matrixRecord.Matrix_type__c = cm_type;
      	insert matrixRecord;

		cm_category = null;
		cm_sub_category = null;
		cm_sub_sub_category = null;
		cm_sub_sub_sub_category = null;
		
        reloadLists();
    }
    
    public List<SelectOption> getCategories() {
        List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', 'Select'));
        Schema.DescribeFieldResult fieldResult = Content_Property__c.Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        return options;
    }
    
    public List<SelectOption> getEmptyCategories(){
    	List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', 'Select'));
        return options;
    }    
    
    public List<SelectOption> getMatrixType(){
    	List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', 'Select Type'));
        Schema.DescribeFieldResult fieldResult = ContentVersion.Matrix_type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        return options;
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
        matrixList = null;
    }

    public void last() {
        setCtrl.last();
        matrixList = null;
    }

    public void previous() {
        setCtrl.previous();
        matrixList = null;
    }

    public void next() {
        setCtrl.next();
        matrixList = null;
    }
    
    
    public class matrix {
        public Content_Matrix__c m {get; set;}
        public Boolean selected {get; set;}
        
        public matrix(Content_Matrix__c mm) {
            m = mm;
            selected = false;
        }
    }      
}