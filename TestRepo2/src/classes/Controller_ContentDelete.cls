public with sharing class Controller_ContentDelete {
     
    public ApexPages.StandardSetController setCtrl  {public get; public set;}

	public String section {get; set;}
	public String currentSection {get; set;}
	public Boolean isFile {get; set;}

	public Boolean selectedRTS {get; set;}
	public Boolean selectedPortfolio {get; set;}
	public Boolean selectedTBA {get; set;}
	public Boolean selectedVideo {get; set;}
    public String searchClause {get;set;}
    public String divisionName {get;set;}
    public String organizationalUnitName {get;set;}
    
    public String selectedMainCategory{get;set;}
    public String selectedSubCategory{get;set;}
    public String selectedSubSubCategory{get;set;}
    public String selectedClassificationRow1{get;set;}
    public String selectedClassificationRow2{get;set;}
    public String selectedSubSubSubCategory{get;set;}
    public String selectedCalendar{get;set;}
    public String selectedBrand{get;set;}
    public String selectedFolder{get;set;}
    public String baseUrl{get;set;}
    public Map<Id, String> ouDistributorsMap{get;set;}
           		
    public List<contentItem> contentItemList {
        public get { 
            if (contentItemList == null) {
                contentItemList = new List<contentItem>();
                               
                Set<Id> idS = new Set<Id>();
                for(sObject o : setCtrl.getRecords()){
                	if(isFile){
                		idS.add(o.Id);
                	}
              	}  
              	List<ContentVersion> listContVer = [select file__c, recordType.Name from ContentVersion where IsLatest=true and file__c in: idS];
              	Map<Id, String> recTypeName = new Map<Id, String>();
              	for(ContentVersion c : listContVer){
              		recTypeName.put(c.file__c, c.recordType.Name);
              	}            	
              	              
                for(sObject o : setCtrl.getRecords()) {
                	if(isFile){
                		contentItemList.add(new contentItem((File__c) o, recTypeName.get(o.Id)));	
                	} else{
                		contentItemList.add(new contentItem((Content_Description__c) o));	
                	}
                }
            }
            return contentItemList;            
        }
        public set;
    }    
    
    public Controller_ContentDelete() {
    	isFile = false;

    	searchClause = null;
    	selectedRTS = false;
    	selectedPortfolio = false;
    	selectedTBA = false;
    	selectedVideo = false;
    	
    	baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        reloadLists();
    }    
    
    public void switchSection() {
    	if(currentSection == 'file'){
    		isFile = true;
    	} else {
    		isFile = false;    	
    	}
    	reloadLists();
    }
    
    public List<SelectOption> getPageSections() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Select Library'));        
        options.add(new SelectOption('file', 'Planning, Collaboration, Performance Managment'));
        options.add(new SelectOption('desc', 'Distributor Portal'));
        return options;
    }

    public List<SelectOption> getDivisions() {
        List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', 'Select Division'));
        Schema.DescribeFieldResult fieldResult = File__c.Division__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        return options;
    }
    
    private void getRefOrgUnits(List<Organizational_Unit__c> childrenOrgUnit, String prevname, Map<Id, List<Organizational_Unit__c>> childrenOrgUnitMap){		
		childrenOrgUnit.sort();
		for(Organizational_Unit__c tmpOu : childrenOrgUnit){
			String prevnameNew;
			if(prevname == null || prevname == ''){
				prevnameNew = + tmpOu.Name;				
			}else{
				prevnameNew = prevname  + ' - ' + tmpOu.Name;
			}
			ouDistributorsMap.put(tmpOu.Id, prevnameNew);			
			List<Organizational_Unit__c> childrenOrgUnitNew = childrenOrgUnitMap.get(tmpOu.Id);
			if(childrenOrgUnitMap.get(tmpOu.Id) != null && childrenOrgUnitNew.size() > 0 ){
				getRefOrgUnits(childrenOrgUnitNew, prevnameNew, childrenOrgUnitMap);	
			}
		}				
	}
    
    public List<SelectOption> getOrganizationunits(){
    	List<Organizational_Unit__c> divis = Service_Api.getOrgUnitByParentForAdmin(null);
		List<String> orgDivisions = new List<String>();
			
		for(Organizational_Unit__c tmp : divis){
			orgDivisions.add(tmp.Name);	
		}
		
		List<SelectOption> OrganizationUnits = new List<SelectOption>(); 
	    OrganizationUnits.add(new SelectOption('', 'Select Organizational Unit'));	   
	       
		if(orgDivisions.size() != 0){	            		    		
	        ouDistributorsMap = new  Map<Id, String>();	        	
	        	
	        List<Organizational_Unit__c> masterOrgUnit = [SELECT Id, Name, Label__c, Parent__r.Id FROM Organizational_Unit__c];
	        Map<Id, List<Organizational_Unit__c>> mapTmp = new Map<Id, List<Organizational_Unit__c>>();
	        	
	        /* generate whole ou map */	        		        	
	        for(Organizational_Unit__c orgU : masterOrgUnit){
	        	if (mapTmp.containsKey(orgU.Parent__r.Id)){
	        		List<Organizational_Unit__c> tmp = mapTmp.get(orgU.Parent__r.Id);
	        		tmp.add(orgU);
	        		mapTmp.put(orgU.Parent__r.Id, tmp);
	        	} else {
	        		List<Organizational_Unit__c> tmp = new List<Organizational_Unit__c>();
	        		tmp.add(orgU);
	        		mapTmp.put(orgU.Parent__r.Id, tmp);
	        	} 	        					        		
	        }
	        	
	        List<Organizational_Unit__c> masterOrgUnitDivi = [SELECT Id, Name, Label__c FROM Organizational_Unit__c WHERE Label__c = 'Division' AND Name In :orgDivisions];	        	
	        getRefOrgUnits(masterOrgUnitDivi, '', mapTmp);	
	        	
	        Map<Id, String> ouDistributorsMapSorted = new Map<Id, String>();
	        	 
	        List<String> valuesTmp = new List<String>();    		
	        for(String k : ouDistributorsMap.keySet()) {
	        	valuesTmp.add(ouDistributorsMap.get(k));	        				        		
	        } 
	        	
	        valuesTmp.sort();
	        	
	       	for(String v: valuesTmp){
	        	for(String key : ouDistributorsMap.keySet()) {
	        		if( ouDistributorsMap.get(key) == v){
	        			ouDistributorsMapSorted.put(key, ouDistributorsMap.get(key));		
	        		}
	        	}
	       	}   		
					
			for(Id idk : ouDistributorsMapSorted.keySet()){
				OrganizationUnits.add(new Selectoption(idk,ouDistributorsMap.get(idk))); 
		   	}        	
		            
		    OrganizationUnits.sort();            
		} 
		return 	OrganizationUnits;	
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
    
    public List<SelectOption> getSubcategories(){
    	List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', 'Select'));
        Schema.DescribeFieldResult fieldResult = Content_Property__c.Sub_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        return options;
    }  
    
    public List<SelectOption> getSubsubcategories(){
    	List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', 'Select'));
        Schema.DescribeFieldResult fieldResult = Content_Property__c.Sub_Sub_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        return options;
    }  
    
    public List<SelectOption> getSubsubsubcategories(){
    	List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', 'Select'));
        Schema.DescribeFieldResult fieldResult = Content_Property__c.Sub_Sub_Sub_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        return options;
    }  
    
    public List<SelectOption> getClassificationRow1(){
    	List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', 'Select Classification Row 1'));
        Schema.DescribeFieldResult fieldResult = Content_Property__c.Selling_Materials_Classification_Row_1__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        return options;
    } 
    
    public List<SelectOption> getClassificationRow2(){
    	List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', 'Select Classification Row 2'));
        Schema.DescribeFieldResult fieldResult = Content_Property__c.Selling_Materials_Classification_Row_2__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        return options;
    } 
    
    public List<SelectOption> getFolders(){
    	List<SelectOption> options = new List<SelectOption>();          
        List<Folder__c> folders = [Select Name, Id From Folder__c Order By Name ASC];
        options.add(new SelectOption('', 'Select Folder'));
        for(Folder__c f: folders){
            options.add(new SelectOption(f.Id, f.Name));
        }
        return options;
    } 
    
    public List<SelectOption> getCalendars(){
    	List<SelectOption> options = new List<SelectOption>(); 
    	List<AggregateResult> calendars = new List<AggregateResult>();
    	if(isFile){  	 
       		 calendars = [Select Name, Id From Calendar__c Where Id In(Select Calendar__c FROM File__c) GROUP BY Name, Id Order By Name ASC];
    	}else{
    		 calendars = [Select Name, Id From Calendar__c Where Id In(Select Calendar__c FROM Content_Property__c) GROUP BY Name, Id Order By Name ASC];
    	}
        options.add(new SelectOption('', 'Select Calendar'));
        for(AggregateResult c: calendars){
            options.add(new SelectOption((String)c.get('Id'), (String)c.get('Name')));
        }
        return options;
    } 
    
    public List<SelectOption> getBrands(){
    	List<SelectOption> options = new List<SelectOption>();
    	List<AggregateResult> cBrds = new List<AggregateResult>();
    	cBrds = [Select Brand__c, Brand__r.Name From ContentBrand__c Where brand__c!=null AND Content_Description__c In (Select Id FROM Content_Description__c) GROUP BY Brand__c, Brand__r.Name Order By Brand__r.Name ASC];
    	
    	options.add(new SelectOption('', 'Select Brand'));
    	for(AggregateResult b: cBrds){
    		options.add(new SelectOption((String)b.get('Brand__c'), (String)b.get('Name')));
    	}
    	
    	return options;    	
    }
    
    public void resetFilters(){
    	
    	if(isFile){
	    	selectedRTS = false;
	    	selectedPortfolio = false;
	    	selectedVideo = false;	
	    	searchClause = null;
	    	divisionName = null;
	    	organizationalUnitName = null;
	    	selectedFolder = null;
	    	selectedCalendar = null;	    	
	    	selectedClassificationRow1 = '';
	    	selectedClassificationRow2 = '';
    	}else{
    		selectedRTS = false;
	    	selectedPortfolio = false;
    		selectedTBA = false;
    		selectedVideo = false;
    		searchClause = null;
    		selectedMainCategory = null;
    		selectedSubCategory = null;
    		selectedSubSubCategory = null;
    		selectedSubSubSubCategory = null;
    		selectedCalendar = null;
    		selectedClassificationRow1 = '';
	    	selectedClassificationRow2 = '';    		
    	}
    	
    	reloadLists();
    }  

    public void reloadLists() {
		String query = '';
		String subquery ='';
		String filterType = '';
		String filterName = '';
		String filterDivision = '';
		List<String> clauses = new list<String>();
		List<String> subclauses = new list<String>();
		try {
	    	if(isFile){
	    		if(selectedRTS){
	    			if(filterType == ''){
						filterType = ' RTS__c = true '; 
	    			} else {
	    				filterType += ' OR RTS__c = true ';
	    			}
	    		}
	    		if(selectedPortfolio){
	    			if(filterType == ''){
						filterType = ' Portfolio__c = true '; 
	    			} else {
	    				filterType += ' OR Portfolio__c = true ';
	    			}
	    		}
	    		if(selectedVideo){
	    			if(filterType == ''){
						filterType = ' Is_Video__c = true '; 
	    			} else {
	    				filterType += ' OR Is_Video__c = true ';
	    			}    			
	    		} 
	    		if(filterType != '' && filterType != ''){
	    			clauses.add(' ( '+filterType+' ) ');
	    		}

	    		if(searchClause != '' && searchClause != null){
	    			clauses.add(' ( Title__c like \'%'+searchClause+'%\' OR Description__c like \'%'+searchClause+'%\' OR Tags__c like \'%'+searchClause+'%\' ) ');
	    		}
	    			    		
	    		if(organizationalUnitName != '' && organizationalUnitName != null){
					clauses.add(' OrgUnits__c Includes (\''+organizationalUnitName+'\') ');
	    		}
	    				
	    		if(selectedFolder != '' && selectedFolder != null){
					clauses.add(' Folders__c Includes (\''+selectedFolder+'\') ');
	    		}
    		
	    		if(selectedCalendar != '' && selectedCalendar!= null){
	    			clauses.add(' Calendar__c = \''+ selectedCalendar +'\' ');
	    		}
	    		
				query = 'Select Id, Name, Title__c, Content_ID__c, Description__c,filesize__c,filetype__c,Is_Video__c,Video_Id__c, 	Distributor_Names__c, Page_Section__c, OrgUnits__c, OrgUnitsNames__c, Folder_Names__c, Content_Version_Id__c FROM File__c ';
						
				if( clauses.size() != 0  ){
					query += ' WHERE ';
				}
				String glue = '';
				for(String cl : clauses){
					query += ' ' + glue + cl;
					glue = ' AND ';
				}
	    		query += ' ORDER BY Description__c LIMIT 750';           			    		
	        	setCtrl = new ApexPages.StandardSetController(Database.query(query));    		
	    	} else {
	    		if(selectedRTS){
	    			if(filterType == ''){
						filterType = ' RTS__c = true '; 
	    			} else {
	    				filterType += ' OR RTS__c = true ';
	    			}
	    		}
	    		if(selectedPortfolio){
	    			if(filterType == ''){
						filterType = ' Portfolio__c = true '; 
	    			} else {
	    				filterType += ' OR Portfolio__c = true ';
	    			}
	    		}
	    		if(selectedTBA){
	    			if(filterType == ''){
						filterType = ' TBA__c = true '; 
	    			} else {
	    				filterType += ' OR TBA__c = true ';
	    			}      			
	    		}
	    		if(selectedVideo){
	    			if(filterType == ''){
						filterType = ' Is_Video__c = true '; 
	    			} else {
	    				filterType += ' OR Is_Video__c = true ';
	    			}    			
	    		}   
	
	    		if(filterType != '' && filterType != ''){
	    			clauses.add(' ( '+filterType+' ) ');
	    		}

	    		if(searchClause != '' && searchClause != null){
	    			clauses.add(' ( Title__c like \'%'+searchClause+'%\' OR Description__c like \'%'+searchClause+'%\' OR Tags__c like \'%'+searchClause+'%\' ) ');
	    		}
	    		
	    		if(selectedMainCategory != '' && selectedMainCategory != null){
	    			subclauses.add(' Category__c like \'%'+selectedMainCategory+'%\' ');
	    		}
	    		
	    		if(selectedSubCategory != '' && selectedSubCategory != null){
	    			subclauses.add(' Sub_Category__c like \'%'+selectedSubCategory+'%\' ');
	    		}
	    		
	    		if(selectedSubSubCategory != '' && selectedSubSubCategory != null){
	    			subclauses.add(' Sub_Sub_Category__c like \'%'+selectedSubSubCategory+'%\' ');
	    		}
	    		
	    		if(selectedSubSubSubCategory != '' && selectedSubSubSubCategory != null){
	    			subclauses.add(' Sub_Sub_Sub_Category__c like \'%'+selectedSubSubSubCategory+'%\' ');
	    		}
	    		
	    		if(selectedClassificationRow1 != '' && selectedClassificationRow1 != null){
	    			subclauses.add(' Selling_Materials_Classification_Row_1__c IN (\''+selectedClassificationRow1+'\') ');
	    		}
	    		
	    		if(selectedClassificationRow2 != '' && selectedClassificationRow2 != null){
	    			subclauses.add(' Selling_Materials_Classification_Row_2__c IN (\''+selectedClassificationRow2+'\') ');
	    		}
	    		
	    		if(selectedCalendar != '' && selectedCalendar!= null){
	    			subclauses.add(' Calendar__c = \''+ selectedCalendar +'\' ');
	    		}
	    			    		
	    		
	    		if( subclauses.size() != 0  ){
	    			subquery += ' WHERE ';
	    		}
	    		
	    		String sglue = '';
				for(String cl : subclauses){
					subquery += ' ' + sglue + cl;
					sglue = ' AND ';
				}
				
				if(selectedBrand != '' && selectedBrand != null){
					if( subclauses.size() != 0  ){
						query = 'Select Id, Name, Title__c,  Content_ID__c, Description__c,filesize__c,filetype__c,Is_Video__c,Video_Id__c, (Select Category__c, Sub_Category__c, Sub_Sub_Category__c, Sub_Sub_Sub_Category__c, Start_Date__c, End_Date__c, Selling_Materials_Classification_Row_1__c, Selling_Materials_Classification_Row_2__c, Calendar__r.name FROM Content_Properties__r) FROM Content_Description__c Where Id In (Select Content_Description__c FROM Content_Property__c '+ subquery+' ) AND Id In (Select Content_Description__c From ContentBrand__c Where Brand__c = :selectedBrand)';	
					}else{
						query = 'Select Id, Name, Title__c,  Content_ID__c, Description__c,filesize__c,filetype__c,Is_Video__c,Video_Id__c, (Select Category__c, Sub_Category__c, Sub_Sub_Category__c, Sub_Sub_Sub_Category__c, Start_Date__c, End_Date__c, Selling_Materials_Classification_Row_1__c, Selling_Materials_Classification_Row_2__c, Calendar__r.name FROM Content_Properties__r) FROM Content_Description__c Where Id In (Select Content_Description__c From ContentBrand__c Where Brand__c = :selectedBrand)';
					}
				}else{				
					if( subclauses.size() != 0  ){
						query = 'Select Id, Name, Title__c,  Content_ID__c, Description__c,filesize__c,filetype__c,Is_Video__c,Video_Id__c, (Select Category__c, Sub_Category__c, Sub_Sub_Category__c, Sub_Sub_Sub_Category__c, Start_Date__c, End_Date__c, Selling_Materials_Classification_Row_1__c, Selling_Materials_Classification_Row_2__c, Calendar__r.name FROM Content_Properties__r) FROM Content_Description__c Where Id In (Select Content_Description__c FROM Content_Property__c '+ subquery+' ) ';	
					}else{
						query = 'Select Id, Name, Title__c,  Content_ID__c, Description__c,filesize__c,filetype__c,Is_Video__c,Video_Id__c, (Select Category__c, Sub_Category__c, Sub_Sub_Category__c, Sub_Sub_Sub_Category__c, Start_Date__c, End_Date__c, Selling_Materials_Classification_Row_1__c, Selling_Materials_Classification_Row_2__c, Calendar__r.name FROM Content_Properties__r) FROM Content_Description__c ';
					}				
				}
								 
				if( subclauses.size() != 0  ){
					if( clauses.size() != 0  ){
						query += ' AND ';
					}					
				}else{
					if( clauses.size() != 0  ){
						query += ' WHERE ';
					}
				}
				
				String glue = '';
				for(String cl : clauses){
					query += ' ' + glue + cl;
					glue = ' AND ';
				}		
	
	    		query += ' ORDER BY Description__c limit 750';
	        	setCtrl = new ApexPages.StandardSetController(Database.query(query));
	    	}
	        setCtrl.setPageSize(30);
	        contentItemList = null;

    		selectedMainCategory = null;
    		selectedSubCategory = null;
    		selectedSubSubCategory = null;
    		selectedSubSubSubCategory = null;

	        
		} catch(Exception e){
           	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load data.'));
           	return;			
		}
    }   
         
    
    public void reloadListsAfterSearch() {    	
        
        if(setCtrl != null ){
        	setCtrl.setPageNumber(1);
        }
        reloadLists();     
    }     
    
    public void deleteContent() {
		if(isFile){
	        List<File__c> selected = new List<File__c>();
	        for(contentItem c : contentItemList) {
	            if(c.selected == true) {
	                selected.add(c.itemF);
	            }
	        }
	        if (selected.size()>0) {
	        	Savepoint sp = Database.setSavepoint();	
	        	try{    		
		        	for(File__c s : selected){	        		
		        		Id idC = s.Content_ID__c;	        		
		        	    
		        		List<File__c> fs =[Select Content_ID__c From File__c Where Content_ID__c = :idC];
		        		delete(fs);	        		
		        			   		
		        		List<ContentDocument> cd = [Select Id From ContentDocument Where Id = :idC];
		        	    delete(cd);	
		        	}
	        	}catch(Exception e){	
	        		Database.rollback(sp);	        		
	        		ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to delete data. '));
	        			            
					return;        
		        }		        
	        }
		} else {
	        List<Content_Description__c> selected = new List<Content_Description__c>();
	        for(contentItem c : contentItemList) {
	            if(c.selected == true) {
	                selected.add(c.itemD);
	            }
	        }
	        if (selected.size()>0) {
	            Savepoint sp = Database.setSavepoint();	        	
	        	try{
		        	for(Content_Description__c s : selected){	        			
		        		List<Content_Property__c> cp = [Select Content_Description__c From Content_Property__c Where Content_Description__c = :s.Id];
		        		delete(cp);
		        		List<ContentBrand__c> cb = [Select Content_Description__c From ContentBrand__c Where Content_Description__c = :s.Id];
		        		delete(cb);
		        		List<ContentDocument> cd = [Select Id From ContentDocument Where Id = :s.Content_ID__c];
		        		delete(cd);
		        		
		        		delete(s);		        		
		        	}
	        	}catch(Exception e){
	        		Database.rollback(sp);
	        		ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to delete data. '));
	        	   				            
					return;        
		        }	
	        		
	        }
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
        contentItemList = null;
    }

    public void last() {
        setCtrl.last();
        contentItemList = null;
    }

    public void previous() {
        setCtrl.previous();
        contentItemList = null;
    }

    public void next() {
        setCtrl.next();
        contentItemList = null;
    }
    
    public class contentItem {
        public Content_Description__c itemD {get; set;}
        public File__c itemF {get; set;}
        public Boolean selected {get; set;}
     	public String recNa {get;set;}
     
        public contentItem(Content_Description__c citem) {
            itemD = citem;
            selected = false;
        }
        public contentItem(File__c citem, String recName) {
            itemF = citem;
            recNa = recName;
            selected = false;
        }

    }
    
    public void cancelDelete(){
    	currentSection = null;
    	isFile = false;
    	searchClause = null;
    	selectedRTS = false;
    	selectedPortfolio = false;
    	selectedTBA = false;
    	selectedVideo = false;

        reloadLists();
    }
}