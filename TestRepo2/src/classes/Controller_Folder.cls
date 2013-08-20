public with sharing class Controller_Folder {
	private ApexPages.StandardController con;
	private Folder__c folderRecord;
	
	public Boolean showAllowFileUpload {get; set;}
	public Boolean showAllowAddComment {get; set;}	
	public Boolean showOnlyForInternal {get; set;}
	public Boolean showFilterByBrand {get; set;}
	public Boolean showFilterByTime {get; set;}
	public Boolean showLayoutType {get; set;}
	public Boolean showDistributors {get; set;}	
	public Boolean showOrganizationUnits {get; set;}	
	public Boolean showHeaderChckbx {get; set;}	
	public Boolean showOrder{get;set;}
	public Boolean showParentFolder{get;set;}
	public Boolean showFolderName{get;set;}
	 
	public Map<Id, String> ouDistributorsMap{get;set;}
	public map<Id, String> distributorsMap{get;set;}
	
    public List<SelectOption> Distributors {get;set;}
    public List<SelectOption> DistributorsSelected {get;set;}	
    public String SelectedDistributorIds {get;set;}
    public String SelectedDivisions {get;set;}
    
    public List<SelectOption> OrganizationUnits {get;set;}
    public List<SelectOption> OrganizationUnitsSelected {get;set;}	
    public String SelectedOrganizationUnitsIds {get;set;}
    public String SelectedOrganizationUnits {get;set;} 
	public String selectedOus {get;set;}
	
	public List<Id> distributorsNewList {set;get;}

	public String manageTheme {get;set;}
	public Boolean isMulticlassificationAllowed {get;set;}
	private Boolean populateOUData;

	public Controller_Folder(ApexPages.StandardController controller) {
        con = controller; 
        folderRecord = (Folder__c)controller.getRecord();
        populateOUData = true;
        setDisplaySettings();      
    }
    
    public List<SelectOption> getThemes() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Folder__c.Classification__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {	
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }   
        return options;
    } 
    
    
    public void changeTheme(){
        populateOUData = false;
        setDisplaySettings();
		populateOUData = true;    
    }

   	public void setDisplaySettings(){
		isMulticlassificationAllowed = false;
   		manageTheme = 'Spirits';
   		if(folderRecord.classification__c != null && folderRecord.classification__c != ''){
    		list<string> thms = folderRecord.classification__c.split(';');
			for(String t : thms){
				if(t!='' && t!=null){
					manageTheme = t;
					break;
				}
			}	    		
   		}
		if(!populateOUData){
       		folderRecord.Distributor_Names__c = null;
       		folderRecord.OrgUnits__c = null;
       		folderRecord.Distributors__c = null;
       		folderRecord.OrgUnitsNames__c = null;
		    Distributors = new List<SelectOption>();
    		DistributorsSelected = new List<SelectOption>();
    		SelectedDistributorIds = '';
    		SelectedDivisions = '';
		    OrganizationUnits = new List<SelectOption>();
    		OrganizationUnitsSelected = new List<SelectOption>();
    		SelectedOrganizationUnitsIds = '';
    		SelectedOrganizationUnits = ''; 
			selectedOus = '';
		}
    	if(folderRecord.Page_Section__c == null){
	        showAllowFileUpload = false;
			showAllowAddComment = false;
			showOnlyForInternal = false;
			showFilterByBrand = false;
			showFilterByTime = false;
			showLayoutType = false;
	        showDistributors = false;
	        showOrganizationUnits = false;
	        showOrder = false;
	        showParentFolder = false; 
	        showFolderName = false;
    	}else{    	
	    	//default settings
	        showAllowFileUpload = true;
			showAllowAddComment = true;
			showOnlyForInternal = true;
			showFilterByBrand = true;
			showFilterByTime = true;
			showLayoutType = true;
			showOrder = true;
			showFolderName = true;
	        showParentFolder = true; 
	        showDistributors = false;
	        showOrganizationUnits = false;
       
	    	if(Constant.PLANNING.equals(folderRecord.Page_Section__c)){
				isMulticlassificationAllowed = true;
	    		showAllowFileUpload = false;
	    		showAllowAddComment = false;
	    		showOnlyForInternal = false;
	    		folderRecord.Allow_File_Upload__c = false;
	    		folderRecord.Allow_Add_Comment__c = false;
	    		folderRecord.Distributors__c = null;
	    		if(!Constant.PLANNING_STANDARD.equals(folderRecord.Layout_Type__c)){
	    			showFilterByBrand = false;
					showFilterByTime = false;
					folderRecord.Filter_By_Brand__c = false;
	    			folderRecord.Filter_By_Time__c = false;
	    		}
	    		showHeaderChckbx = true;
	    	} else if(Constant.PERFORMANCE_MANAGMENT.equals(folderRecord.Page_Section__c)){
	    		showAllowFileUpload = false;
	    		showAllowAddComment = false;
	    		showFilterByBrand = false;
				showFilterByTime = false;
				showLayoutType = false;
				showDistributors = true;
				showOrganizationUnits = true;
				
				setDistributors();
				setOrganizationUnits();
				
				folderRecord.Distributors__c = null;					    		
	    		folderRecord.Allow_File_Upload__c = false;
	    		folderRecord.Allow_Add_Comment__c = false;
	    		folderRecord.Filter_By_Brand__c = false;
	    		folderRecord.Filter_By_Time__c = false;
	    		folderRecord.Layout_Type__c = 'Standard';
	    	} else if(Constant.COLLABORATION.equals(folderRecord.Page_Section__c)){
	    		showFilterByBrand = false;
				showFilterByTime = false;
				showLayoutType = false;
				showDistributors = true;
				showOrganizationUnits = true;
				
				setDistributors();
				setOrganizationUnits();
				
				folderRecord.Filter_By_Brand__c = false;
	    		folderRecord.Filter_By_Time__c = false;
	    		folderRecord.Layout_Type__c = 'Standard';
	
	    		showHeaderChckbx = true;
	    	}
    	}
    }
    
    private void getRefDistribOrgUnits(List<Organizational_Unit__c> childrenOrgUnit, String prevname, Map<Id, List<Organizational_Unit__c>> childrenOrgUnitMap){		
		childrenOrgUnit.sort();
		for(Organizational_Unit__c tmpOu : childrenOrgUnit){
			String prevnameNew;
			if(prevname == null || prevname == ''){
				prevnameNew = + tmpOu.Name;				
			}else{
				prevnameNew = prevname  + ' - ' + tmpOu.Name;
			}
			distributorsMap.put(tmpOu.Id, prevnameNew);			
			List<Organizational_Unit__c> childrenOrgUnitNew = childrenOrgUnitMap.get(tmpOu.Id);
			if(childrenOrgUnitMap.get(tmpOu.Id) != null && childrenOrgUnitNew.size() > 0 ){
				getRefDistribOrgUnits(childrenOrgUnitNew, prevnameNew, childrenOrgUnitMap);	
			}
		}				
	}
	
	public void  setDistributors(){
        Distributors = new List<SelectOption>();
        DistributorsSelected = new List<SelectOption>();     
		if((selectedOus != null && selectedOus != '')||(folderRecord.OrgUnits__c != null && folderRecord.OrgUnits__c != '')){
	        List<String> divisions = (selectedOus != null && selectedOus != '') ? selectedOus.split(';') : folderRecord.OrgUnits__c.split(';');
	        if(divisions.size() != 0){
	            Distributors = new List<SelectOption>();
	            distributorsMap = new Map<Id, String>();
	            List<Organizational_Unit__c> masterOrgUnit = [SELECT Id, Name, Label__c, Parent__r.Id FROM Organizational_Unit__c where type__c = :manageTheme];
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
		        	
		        Map<Id, List<Id>> mapTmp2 = new Map<Id, List<Id>>();
		        	
		        /* generate whole ou map */	        		        	
		        for(Organizational_Unit__c orgU : masterOrgUnit){
		        	if (mapTmp2.containsKey(orgU.Parent__r.Id)){
		        		List<Id> tmp2 = mapTmp2.get(orgU.Parent__r.Id);
		        		tmp2.add(orgU.Id);
		        		mapTmp2.put(orgU.Parent__r.Id, tmp2);
		        	} else {
		        		List<Id> tmp2 = new List<Id>();
		        		tmp2.add(orgU.Id);
		        		mapTmp2.put(orgU.Parent__r.Id, tmp2);
		        	} 	        					        		
		        }
		        	
		        List<Organizational_Unit__c> masterOrgUnitDivi = [select Id, Name from Organizational_Unit__c where Parent__c = null and type__c = :manageTheme];	 	
	        	getRefDistribOrgUnits(masterOrgUnitDivi, '', mapTmp);
	        		
	        	distributorsNewList = new List<Id>();
	        		
	        	List<Id> divisions2 = new List<Id>();
			    for(String diviTmp : divisions){
			    	divisions2.add(id.valueof(diviTmp));	
			    }	        		
	        		
	        	getRefDistribOrgUnits2(divisions2, mapTmp2);
	        		
	        	// helpers
				String accountRecordTypeIdsString = '';
	    		String glueHelper = '';
				for (String value : Service_API.getAccountRecordTypeIds()) {         
					accountRecordTypeIdsString += glueHelper + '\''+value+'\' ';
					glueHelper = ',';
				}
	        		
				String distributorsNewListIdsString = '';
	    		glueHelper = '';
				for (String value : distributorsNewList) {         
					distributorsNewListIdsString += glueHelper + '\''+value+'\' ';
					glueHelper = ',';
				}
				// helpers end
				
				Account[] accounts = new list<Account>();
				if(distributorsNewListIdsString != '' && accountRecordTypeIdsString != ''){
					accounts = database.query(' ' +
	        							  + ' SELECT Id, Name, '+manageTheme+'_Hierarchy__r.Id, '+manageTheme+'_Hierarchy__r.Label__c, '+manageTheme+'_Hierarchy__r.Name, '+manageTheme+'_Hierarchy__r.Type__c ' + 
	        							  + ' FROM Account ' +
	        							  + ' WHERE '+manageTheme+'_Hierarchy__r.Id In ('+distributorsNewListIdsString+') and Account.RecordTypeId in ('+accountRecordTypeIdsString+') ' +
	        							  + ' ORDER BY '+manageTheme+'_Hierarchy__r.Name, Name '
	        		);	
				}
	        		  
	            String distribLabel = '';  
	              	        
				for(Account acc: accounts) {
					sObject accSobject = (sObject) acc;
					if(accSobject.get(manageTheme+'_Hierarchy__c') != null){
						Id assignedToOrgUnitWithId = Id.valueof(String.valueof(accSobject.get(manageTheme+'_Hierarchy__c')));
			            distribLabel = '';
			            distribLabel = distributorsMap.get(assignedToOrgUnitWithId);
			                 
			            if(distribLabel != null & distribLabel != ''){
			                distribLabel += ' - '+acc.Name;
						} else {
			            	distribLabel = acc.Name;
			            }
			                  
			            if( ( folderRecord.Distributors__c == null || !folderRecord.Distributors__c.contains(acc.Id) ) || !populateOUData){
			                Distributors.add(new Selectoption(acc.Id,distribLabel)); 
						} else {
			            	DistributorsSelected.add(new Selectoption(acc.Id,distribLabel));
			        	}
					}
				}		                  
	        } else {
	            Distributors = new List<SelectOption>();
	        	DistributorsSelected = new List<SelectOption>();      
	        }
		}
    }
    
    private void getRefDistribOrgUnits2(List<Id> divisions2, Map<Id, List<Id>> childrenOrgUnitMap){		
		divisions2.sort();
		for(Id tmpOu : divisions2){			
			distributorsNewList.add(tmpOu);			
			List<Id> childrenOrgUnitNew = childrenOrgUnitMap.get(tmpOu);
			if(childrenOrgUnitMap.get(tmpOu) != null && childrenOrgUnitNew.size() > 0 ){
				getRefDistribOrgUnits2(childrenOrgUnitNew, childrenOrgUnitMap);	
			}
		}				
	}
    
    
    public void  updateDistributors(){
    	Distributors = new List<SelectOption>();
        DistributorsSelected = new List<SelectOption>();
      	String newSelection = '';           
		if(SelectedDivisions != null && SelectedDivisions != ''){
		    List<String> divisions = SelectedDivisions.split(';');
		      			      	
			if(divisions.size() != 0){
		        	
		        distributorsMap = new Map<Id, String>();
	            List<Organizational_Unit__c> masterOrgUnit = [SELECT Id, Name, Label__c, Parent__r.Id FROM Organizational_Unit__c where type__c = :manageTheme];
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
		        
		        Map<Id, List<Id>> mapTmp2 = new Map<Id, List<Id>>();
		        
		        /* generate whole ou map */	        		        	
		        for(Organizational_Unit__c orgU : masterOrgUnit){
		        	if (mapTmp2.containsKey(orgU.Parent__r.Id)){
		        		List<Id> tmp2 = mapTmp2.get(orgU.Parent__r.Id);
		        		tmp2.add(orgU.Id);
		        		mapTmp2.put(orgU.Parent__r.Id, tmp2);
		        	} else {
		        		List<Id> tmp2 = new List<Id>();
		        		tmp2.add(orgU.Id);
		        		mapTmp2.put(orgU.Parent__r.Id, tmp2);
		        	} 	        					        		
		        }
		        	
		        List<Organizational_Unit__c> masterOrgUnitDivi = [select Id, Name from Organizational_Unit__c where Parent__c = null and type__c = :manageTheme];	        	
	        	getRefDistribOrgUnits(masterOrgUnitDivi, '', mapTmp);
	        		
	        	distributorsNewList = new List<Id>();
	        		
	        	List<Id> divisions2 = new List<Id>();
				for(String diviTmp : divisions){
			    	divisions2.add(id.valueof(diviTmp));	
				}	        		
	        	
	        	getRefDistribOrgUnits2(divisions2, mapTmp2);
	        		
	        	// helpers
				String accountRecordTypeIdsString = '';
	    		String glueHelper = '';
				for (String value : Service_API.getAccountRecordTypeIds()) {         
					accountRecordTypeIdsString += glueHelper + '\''+value+'\' ';
					glueHelper = ',';
				}
	        		
				String distributorsNewListIdsString = '';
	    		glueHelper = '';
				for (String value : distributorsNewList) {         
					distributorsNewListIdsString += glueHelper + '\''+value+'\' ';
					glueHelper = ',';
				}
				// end helpers
					
				Account[] accounts = new list<Account>(); 
				if(distributorsNewListIdsString != '' && accountRecordTypeIdsString != ''){
					accounts = database.query(' ' +
	        							  + ' SELECT Id, Name, '+manageTheme+'_Hierarchy__c, '+manageTheme+'_Hierarchy__r.Label__c, '+manageTheme+'_Hierarchy__r.Name, '+manageTheme+'_Hierarchy__r.Type__c ' + 
	        							  + ' FROM Account ' +
	        							  + ' WHERE '+manageTheme+'_Hierarchy__r.Id In ('+distributorsNewListIdsString+') and Account.RecordTypeId in ('+accountRecordTypeIdsString+') ' +
	        							  + ' ORDER BY '+manageTheme+'_Hierarchy__r.Name, Name '
	        		);	
				}
							        	
		        String glue = '';
		        String distribLabel = '';
				for(Account acc: accounts) {
					sObject accSobject = (sObject) acc;
					if(accSobject.get(manageTheme+'_Hierarchy__c') != null){
						Id assignedToOrgUnitWithId = Id.valueof(String.valueof(accSobject.get(manageTheme+'_Hierarchy__c')));
		                distribLabel = '';
		               	distribLabel = distributorsMap.get(assignedToOrgUnitWithId);	
			            if(distribLabel != null & distribLabel != ''){
			                distribLabel += ' - '+acc.Name;
			            } else {
			                distribLabel = acc.Name;
			            }
			            if(SelectedDistributorIds != null && SelectedDistributorIds != '' && SelectedDistributorIds.contains(acc.Id) && populateOUData){
							DistributorsSelected.add(new Selectoption(acc.Id,distribLabel));
							newSelection += glue + acc.Id;
			                glue = ';';
			            } else {
			            	Distributors.add(new Selectoption(acc.Id,distribLabel));  
			        	}
					}
		    	}
			}
		}
	    SelectedDistributorIds = newSelection;
		folderRecord.Distributors__c = newSelection;  
    }   
	
	private void getRefOrgUnits(List<Organizational_Unit__c> childrenOrgUnit, String prevname, Map<Id, List<Organizational_Unit__c>> childrenOrgUnitMap){		
		childrenOrgUnit.sort();
		for(Organizational_Unit__c tmpOu : childrenOrgUnit){
			if(tmpOu.Label__c == 'Division' || tmpOu.Label__c == 'Region'){			
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
	}
	    
	public void  setOrganizationUnits(){
       		OrganizationUnits = new List<SelectOption>();
       		OrganizationUnitsSelected = new List<SelectOption>();       		      			    	
			
			List<Organizational_Unit__c> divis = Service_Api.getOrgUnitByParentForAdmin(null, manageTheme);
			List<String> orgDivisions = new List<String>();
			
			for(Organizational_Unit__c tmp : divis){
				orgDivisions.add(tmp.Name);	
			}
	       
			if(orgDivisions.size() != 0){
	        	OrganizationUnits = new List<SelectOption>(); 	        		    		
	        	ouDistributorsMap = new  Map<Id, String>();	        	
	        	
	        	List<Organizational_Unit__c> masterOrgUnit = [SELECT Id, Name, Label__c, Parent__r.Id FROM Organizational_Unit__c where type__c = :manageTheme];
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
	        	
	        	List<Organizational_Unit__c> masterOrgUnitDivi = [SELECT Id, Name, Label__c FROM Organizational_Unit__c WHERE Label__c = 'Division' AND Name In :orgDivisions and type__c = :manageTheme];	        	
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
					if( (folderRecord.OrgUnits__c == null || !folderRecord.OrgUnits__c.contains(idk)) || !populateOUData){
		            	OrganizationUnits.add(new Selectoption(idk,ouDistributorsMap.get(idk))); 
		            } else {
		            	OrganizationUnitsSelected.add(new Selectoption(idk,ouDistributorsMap.get(idk)));
		           	}	           						
				}        	
		            
		        OrganizationUnits.sort();
		            
			} else {
	        	OrganizationUnits = new List<SelectOption>();
	        	OrganizationUnitsSelected = new List<SelectOption>();			
			}			
    }
    
    public void  updateOrganizationUnits(){
       	OrganizationUnits = new List<SelectOption>();
       	OrganizationUnitsSelected = new List<SelectOption>();
		String newUnitSelection = '';       		
		
		List<Organizational_Unit__c> divis = Service_Api.getOrgUnitByParentForAdmin(null, manageTheme);
		List<String> orgDivisions = new List<String>();
			
		for(Organizational_Unit__c tmp : divis){
			orgDivisions.add(tmp.Name);	
		}
		
		if(SelectedOrganizationUnits != null && SelectedOrganizationUnits != ''){
	        List<String> splitedOrgs = SelectedOrganizationUnits.split(';');
			
			if(splitedOrgs.size() != 0){
	        	OrganizationUnits = new List<SelectOption>(); 	        		    		
			    ouDistributorsMap = new  Map<Id, String>();	        	
			        	
			    List<Organizational_Unit__c> masterOrgUnit = [SELECT Id, Name, Label__c, Parent__r.Id FROM Organizational_Unit__c where type__c = :manageTheme];
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
	        	List<Organizational_Unit__c> masterOrgUnitDivi = [SELECT Id, Name, Label__c FROM Organizational_Unit__c WHERE Label__c = 'Division' AND Name In :orgDivisions and type__c = :manageTheme];
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
	        		
				String glue = '';
				for(Id idk : ouDistributorsMapSorted.keySet()){							
					if(SelectedOrganizationUnitsIds != null && SelectedOrganizationUnitsIds != '' && SelectedOrganizationUnitsIds.contains(idk) && populateOUData){	
						OrganizationUnitsSelected.add(new Selectoption(idk,ouDistributorsMap.get(idk))); 
						newUnitSelection += glue + idk;
					} else {
			        	OrganizationUnits.add(new Selectoption(idk,ouDistributorsMap.get(idk)));
			        }	
				} 
	        }
		}
		SelectedOrganizationUnitsIds = newUnitSelection;
		folderRecord.OrgUnits__c = newUnitSelection;	
    }
         
    public pageReference save() {
    	try{
	    	List<String> distributorIds = new list<String>();
	    	if(folderRecord.Distributors__c != null && folderRecord.Distributors__c != ''){
	        	distributorIds = folderRecord.Distributors__c.split(';');
	    	}
	    	
	    	List<String> orgUnitsIds = new list<String>();
	    	if(folderRecord.OrgUnits__c != null && folderRecord.OrgUnits__c != ''){
	        	orgUnitsIds = folderRecord.OrgUnits__c.split(';');
	    	}

			List<Id> distribIdsValid = new list<Id>();
			for(String dId : distributorIds){
				if(dId != null && dId != ''){
					distribIdsValid.add(Id.valueOf(dId));
				}
			}
			
			List<Id> orgUnitsIdsValid = new list<Id>();
			for(String dId : orgUnitsIds){
				if(dId != null && dId != ''){
					orgUnitsIdsValid.add(Id.valueOf(dId));
				}
			}
			
	        Account[] accounts = [SELECT Id, Name FROM Account WHERE Id in :distribIdsValid];
	       	String glue = '';
	       	String names = '';
	       	for(Account a: accounts){
	       		names += glue + a.Name;
	       		glue = '; ';
	       	}
	       	folderRecord.Distributor_Names__c = names;
	       	
	       	List<Organizational_Unit__c> unitsList = [SELECT Id, Name FROM Organizational_Unit__c WHERE Id in:orgUnitsIdsValid];
	       	String glueU = '';
	       	String namesU = '';
	       	String idU = '';
	       	for(Organizational_Unit__c o: unitsList){
	       		namesU += glueU + o.Name;
       			idU += glueU + o.id;
	       		glueU = '; ';
	       	}
	       	folderRecord.OrgUnits__c = idU;
	       	folderRecord.OrgUnitsNames__c = namesU;
	       
	       	//update folderRecord;
	       	if(folderRecord.Page_Section__c == 'Planning'){
	       		folderRecord.Distributor_Names__c = null;
	       		folderRecord.OrgUnits__c = null;
	       		folderRecord.Distributors__c = null;
	       		folderRecord.OrgUnitsNames__c = null;
	       	}

	       	return con.save();
    	} catch(Exception ex){
    		Apexpages.addmessage(new apexpages.message(apexpages.severity.error, 'Error while saving a folder: '+ex.getmessage()));
    		return null;
    	}
    }
    
}