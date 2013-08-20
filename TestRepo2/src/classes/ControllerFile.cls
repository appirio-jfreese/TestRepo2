public with sharing class ControllerFile {
	private ApexPages.StandardController con;
	private File__c fileRecord;
    private Map<Id, Folder> folderMap = new Map<Id, Folder>();
    public Map<String, Integer> folderDeepth {get;set;}  
    public Map<String, Boolean> folderChecked {get;set;}  
    public List<SelectOption> Folders {get;set;}
    public List<SelectOption> FoldersSelected {get;set;}
    public String SelectedFolderIds {get;set;}
    public List<SelectOption> Distributors {get;set;}
    public List<SelectOption> DistributorsSelected {get;set;}
    public String SelectedDistributorIds {get;set;}
    public List<SelectOption> Brands {get;set;}
    public List<SelectOption> BrandsSelected {get;set;}
    public String SelectedBrandIds {get;set;}
    public Boolean isDistributorsSelectionVisible {get;set;}
    public Boolean isBrandSelectionVisible {get;set;}
    public Boolean isOnlyForInternalVisible {get;set;}
    public Boolean areDatesVisible {get;set;}
    public Boolean isCalendarVisible {get;set;}
    public Boolean showOrganizationUnits {get; set;}	
    
    public Map<Id, String> ouDistributorsMap{get;set;}
	public map<Id, String> distributorsMap{get;set;}
    public List<SelectOption> OrganizationUnits {get;set;}
    public List<SelectOption> OrganizationUnitsSelected {get;set;}	
    public String SelectedOrganizationUnitsIds {get;set;}
    public String SelectedOrganizationUnits {get;set;}
    public List<Id> distributorsNewList {set;get;}

	public String selectedOus {get;set;}
    
	public String manageTheme {get;set;}
	public Boolean isMulticlassificationAllowed {get;set;}
	public Boolean populateOUData {get;set;}
    
    public ControllerFile(ApexPages.StandardController controller) {
        con = controller;
        folderDeepth = new Map<String, Integer>();
        folderChecked = new Map<String, Boolean>();
        fileRecord = (File__c)controller.getRecord();
        
        populateOUData = true;
        refreshFolderList();
    }
    
    public List<SelectOption> getThemes() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = File__c.Classification__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {	
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }   
        return options;
    } 
    
    public void changeTheme(){
        populateOUData = false;
        refreshFolderList();
  		populateOUData = true;
    }
    
    public void setFieldsVisibility(){
		isMulticlassificationAllowed = false;
   		manageTheme = 'Spirits';
   		File__c f = [select classification__c from File__c where id = :fileRecord.id limit 1];
   		if(f.classification__c != null && f.classification__c != ''){
    		list<string> thms = f.classification__c.split(';');
			for(String t : thms){
				if(t!='' && t!=null){
					manageTheme = t;
					break;
				}
			}	    		
   		}
		if(!populateOUData){
       		fileRecord.Distributors__c = null;
       		fileRecord.Distributor_Names__c = null;
       		fileRecord.OrgUnits__c = null;
	       	fileRecord.OrgUnitsNames__c = null;
	       	fileRecord.Division_Access__c = null;
	        fileRecord.Brand_Names__c = null;
	        fileRecord.Brands__c = null;
	        fileRecord.Folder_Names__c = null;
	        fileRecord.Folders__c = null;
			Folders = new List<SelectOption>();
			FoldersSelected = new List<SelectOption>();
			SelectedFolderIds = '';
			
    		Brands = new List<SelectOption>();
    		BrandsSelected = new List<SelectOption>();
    		SelectedBrandIds = '';	
    				
		    Distributors = new List<SelectOption>();
    		DistributorsSelected = new List<SelectOption>();
    		SelectedDistributorIds = '';
		    OrganizationUnits = new List<SelectOption>();
    		OrganizationUnitsSelected = new List<SelectOption>();
    		
    		SelectedOrganizationUnitsIds = '';
    		SelectedOrganizationUnits = ''; 
    		
			selectedOus = '';
		}
    	if(fileRecord.Page_Section__c == Constant.PLANNING){
    		isMulticlassificationAllowed = true;
    		isOnlyForInternalVisible =  false;
	        fileRecord.Only_For_Internal_User__c = true;
	        isBrandSelectionVisible = true;
	        areDatesVisible = true;
	        isCalendarVisible = true;
	        showOrganizationUnits = false;
    	} else {
            isOnlyForInternalVisible = true;
            fileRecord.Only_For_Internal_User__c = false;
            isBrandSelectionVisible = false;
            areDatesVisible = false;
            isCalendarVisible = false;
            showOrganizationUnits = true;
            setOrganizationUnits();
    	}
    	isDistributorsSelectionVisible = fileRecord.Only_For_Internal_User__c ? false : true;
    	fileRecord.Classification__c = fileRecord.Classification__c;
    }
    
    private void getRefDistribOrgUnits(List<Organizational_Unit__c> childrenOrgUnit, String prevname, Map<Id, List<Organizational_Unit__c>> childrenOrgUnitMap){		
		childrenOrgUnit.sort();
		for(Organizational_Unit__c tmpOu : childrenOrgUnit){
			String prevnameNew;
			if(prevname == null || prevname == ''){
				prevnameNew = + tmpOu.Name;				
			} else {
				prevnameNew = prevname  + ' - ' + tmpOu.Name;
			}
			distributorsMap.put(tmpOu.id, prevnameNew);			
			List<Organizational_Unit__c> childrenOrgUnitNew = childrenOrgUnitMap.get(tmpOu.Id);
			if(childrenOrgUnitMap.get(tmpOu.Id) != null && childrenOrgUnitNew.size() > 0 ){
				getRefDistribOrgUnits(childrenOrgUnitNew, prevnameNew, childrenOrgUnitMap);	
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
	
    
    public void refreshFolderList() {
        folders = new List<SelectOption>();
        foldersSelected = new List<SelectOption>();
        Distributors = new List<SelectOption>();
        DistributorsSelected = new List<SelectOption>();
        Brands = new List<SelectOption>();
        BrandsSelected = new List<SelectOption>();
        distributorsMap = new map<Id, String>();

        setFieldsVisibility();

        if((selectedOus != null && selectedOus != '')||(fileRecord.OrgUnits__c != null && fileRecord.OrgUnits__c != '')||(fileRecord.Page_Section__c == Constant.PLANNING)){
	    	List<String> divisions;
	    	if(fileRecord.Page_Section__c != Constant.PLANNING)
	    		divisions = (selectedOus != null && selectedOus != '') ? selectedOus.split(';') : fileRecord.OrgUnits__c.split(';');
	    	else
	    		divisions = new List<String>();
	    		
	    	if(divisions.size() != 0 || (fileRecord.Page_Section__c == Constant.PLANNING)){
			    Distributors = new List<SelectOption>();
	            DistributorsSelected = new List<SelectOption>();   
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
	        	getRefDistribOrgUnits(masterOrgUnitDivi,'',mapTmp);

		        if (fileRecord.Page_Section__c != null) {
		        	List<Folder__c> tmpFolders;
		        	if(fileRecord.Page_Section__c == Constant.PLANNING){
		        		tmpFolders = Service_API.getPlanningFoldersForAdmin();
		        	} else {
		        		if (fileRecord.OrgUnits__c != null) {
		        		    tmpFolders = Service_API.getDocumentFoldersForAdmin(fileRecord.Page_Section__c, divisions, true);
		        		} else {
		        			tmpFolders = new Folder__c[]{};
		        		}
		        	}
		            folderMap = new Map<Id, Folder>();
		            
		            for(Folder__c folder : tmpFolders){
		                Folder folderObject = new Folder(folder.Id, folder.Name);
		                Folder parentFolder;
		                if(folderMap.containsKey(folder.Parent_Folder__c)){
		                    parentFolder = folderMap.get(folder.Parent_Folder__c);
		                } else {
		                    parentFolder = new Folder(folder.Parent_Folder__c, folder.Parent_Folder__r.Name);
		                }
		                parentFolder.addToFolder(folderObject);
		                folderMap.put(folder.Parent_Folder__c, parentFolder);
		            }
		            for(Folder__c folder : tmpFolders){
		                if(folder.Parent_Folder__c == null ){
		                    Folder folderObject = new Folder(folder.Id, folder.Name);     
		                   	prepareTree(folderMap, folderObject, 0);
		                }
		            }
		        }
		        if (!masterOrgUnit.isEmpty()) {
		        	
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

		            String glue = '';
		            String distribLabel = '';
		            String newSelection = '';  
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
			                if( (fileRecord.Distributors__c == null || !fileRecord.Distributors__c.contains(acc.Id)) || !populateOUData){
				            	Distributors.add(new Selectoption(acc.Id, distribLabel));
				            } else {
				            	DistributorsSelected.add(new Selectoption(acc.Id, distribLabel));
								newSelection += glue + acc.Id;
					            glue = ';';
				            }  
						}
		             }
		             SelectedDistributorIds = newSelection;
		             fileRecord.Distributors__c = newSelection;
		        } else {
	              Distributors = new List<SelectOption>();
	              DistributorsSelected = new List<SelectOption>();     
	              SelectedDistributorIds = '';
	              fileRecord.Distributors__c = ''; 
		        }
        	} else {
	              Distributors = new List<SelectOption>();
	              DistributorsSelected = new List<SelectOption>();     
	              SelectedDistributorIds = '';
	              fileRecord.Distributors__c = ''; 
	        }
        } else {
			Distributors = new List<SelectOption>();
            DistributorsSelected = new List<SelectOption>();     
	        SelectedDistributorIds = '';
			fileRecord.Distributors__c = '';   
        }
        
        if(isBrandSelectionVisible == true){
        	Brand__c[] brandsList = [SELECT Id, Name FROM Brand__c where diageo_direct_visible__c = true ORDER BY Name];
            for(Brand__c b: brandsList) {
            	if( (fileRecord.Brands__c == null || !fileRecord.Brands__c.contains(b.Id)) || !populateOUData){
            		Brands.add(new Selectoption(b.Id, b.Name));
            	} else {
            		BrandsSelected.add(new Selectoption(b.Id, b.Name));
            	}
            }
        }
    }
    
    public void setOnlyForInternalUser(){
    	if(fileRecord.Only_For_Internal_User__c == true){
    		isDistributorsSelectionVisible = false;
    		fileRecord.Distributors__c = '';
    	} else {
    		isDistributorsSelectionVisible = true;
    	}
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
	        	
	        List<Organizational_Unit__c> masterOrgUnit = [SELECT Id, Name, Label__c, Parent__r.Id FROM Organizational_Unit__c WHERE type__c = :manageTheme];
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
				if( (fileRecord.OrgUnits__c == null || !fileRecord.OrgUnits__c.contains(idk) ) || !populateOUData){
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
			        	
			    List<Organizational_Unit__c> masterOrgUnit = [SELECT Id, Name, Label__c, Parent__r.Id FROM Organizational_Unit__c WHERE type__c = :manageTheme];
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
			    	
			    List<Organizational_Unit__c> masterOrgUnitDivi = [SELECT Id, Name, Label__c FROM Organizational_Unit__c WHERE Label__c = 'Division' AND Name In :orgDivisions AND type__c = :manageTheme];
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
		fileRecord.OrgUnits__c = newUnitSelection;	
    }
    
    private List<SelectOption> prepareTree(Map<Id, Folder> folderMap, Folder folder, Integer level) {
        String name =  folder.folderName;
        if(fileRecord.Folders__c == null || !fileRecord.Folders__c.contains(folder.folderId)){
        	folderChecked.put(folder.folderId, false);
        } else {
        	folderChecked.put(folder.folderId, true);
        }     
        folders.add(new Selectoption(folder.folderId, name));
        folderDeepth.put(folder.folderId, level);
      
        if(folderMap.containsKey(folder.folderId)) {
            for(Folder f: folderMap.get(folder.folderId).dirs){
                prepareTree(folderMap, f, level+1);
            }
        }
        return folders;   
    }
    
    public pageReference save() {
    	try{
    		if(fileRecord.Page_Section__c != Constant.PLANNING){
    			if(fileRecord.OrgUnits__c == null || fileRecord.OrgUnits__c == ''){
		    		Apexpages.addmessage(new apexpages.message(apexpages.severity.error, 'Select at least one organization unit.'));
		    		return null;
    			}
    		}
    		
			// setup distributors
	        List<String> distributorIds = fileRecord.Distributors__c.split(';');
	        Account[] accounts = [SELECT Id, Name FROM Account WHERE Id in :distributorIds and Account.RecordTypeId in :Service_API.getAccountRecordTypeIds()];
        	String glueD = '';
        	String namesD = '';
			String idD = '';
        	for(Account a: accounts){
        		namesD += glueD + a.Name;
				idD += glueD + a.Id;
        		glueD = '; ';
        	}
        	fileRecord.Distributor_Names__c = namesD;
        	fileRecord.Distributors__c = idD;

			// setup brands        	        	
            if (fileRecord.Brands__c != null) {
	        	List<String> brandIds = fileRecord.Brands__c.split(';');
	        	Brand__c[] brandsList = [SELECT Id, Name FROM Brand__c WHERE Id in :brandIds];
	        	String glueB = '';
	        	String namesB = '';
	        	String idB= '';
	        	for(Brand__c b: brandsList){
	        		namesB += glueB + b.Name;
	        		idB += glueB + b.Id;
	        		glueB = '; ';
	        	}
        		fileRecord.Brand_Names__c = namesB;
        		fileRecord.Brands__c = idB;
            } else {
        		fileRecord.Brand_Names__c = null;
        		fileRecord.Brands__c = null;
            }

	       	//setup folders
	        List<String> folderIds = fileRecord.Folders__c.split(';');	
	        Folder__c[] folders = [SELECT Id, Name FROM Folder__c WHERE Id in :folderIds];
        	String glueF = '';
        	String namesF = '';
        	String idF = '';
        	for(Folder__c f: folders){
        		namesF += glueF + f.Name;
        		idF += glueF + f.Id;
        		glueF = '; ';
        	}
        	fileRecord.Folder_Names__c = namesF;
			fileRecord.Folders__c = idF;

			//setup organizational units
        	List<String> orgUnitsIds = new list<String>();
	    	if(fileRecord.OrgUnits__c != null && fileRecord.OrgUnits__c != ''){
	        	orgUnitsIds = fileRecord.OrgUnits__c.split(';');
	    	}

        	List<Id> orgUnitsIdsValid = new list<Id>();
			for(String dId : orgUnitsIds){
				if(dId != null && dId != ''){
					orgUnitsIdsValid.add(Id.valueOf(dId));
				}
			}
        	List<Organizational_Unit__c> unitsList = [SELECT Id, Name FROM Organizational_Unit__c WHERE Id in:orgUnitsIdsValid];
	       	String glueU = '';
	       	String namesU = '';
	       	String idU = '';
	       	for(Organizational_Unit__c o: unitsList){
	       		namesU += glueU + o.Name;
       			idU += glueU + o.id;
	       		glueU = '; ';
	       	}
	       	fileRecord.OrgUnitsNames__c = namesU;
	       	fileRecord.OrgUnits__c = idU;

    		// setup division access
	        if ((fileRecord.OrgUnits__c != null && fileRecord.OrgUnits__c != '')&&(fileRecord.Distributors__c=='' || fileRecord.Distributors__c==null)) {
	        	List<Organizational_Unit__c> divs = [select Name from Organizational_Unit__c where Label__c = 'Division' and id in :fileRecord.OrgUnits__c.split(';') and type__c = :manageTheme];
	        	fileRecord.Division_Access__c = '';
	        	String glueDA = '';
	        	for(Organizational_Unit__c ou : divs){
	        		fileRecord.Division_Access__c += glueDA + ou.Name;
	        		glueDA = ';'; 
	        	}
	        } else {
	        	fileRecord.Division_Access__c = null;
	        }
        	
        	
        	// setup null values for planning
	        if(fileRecord.Page_Section__c == 'Planning'){
	       		fileRecord.Distributor_Names__c = null;
	       		fileRecord.OrgUnits__c = null;
	       		fileRecord.Distributors__c = null;
	       		fileRecord.OrgUnitsNames__c = null;
	       		fileRecord.Division_Access__c = null;
	       	} else {
	        	fileRecord.Brand_Names__c = null;
	        	fileRecord.Brands__c = null;
	       	}
	       	
        	return con.save();
        	
    	} catch(Exception ex){
    		Apexpages.addmessage(new apexpages.message(apexpages.severity.error, 'Error while saving a file: '+ex.getmessage()));
    		return null;
    	}
    }
    
}