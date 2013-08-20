public without sharing class Controller_PerformanceManagment extends Controller_Base {

	private list<Account> distributors;
	private list<Organizational_Unit__c> organizationalUnits;
	private Map<Id, OrganizationalUnit> ouMap;
	private Map<Id, list<Account>> distributorMap;
	private set<id> parentsOUids;
	
	public list<id> totalUserOrganizationalsUnits {get; protected set;}
	
    public BreadcrumbsHolder organizationalUnitBreadcrumbs{get;set;}    
    public Boolean isAutomaticLand {get; set;}

    public Integer selectedIterator {get; set;}

	public Id currentOrganizationalUnit{get;set;}
	
    public String currentDivision {get; set;}
    public String currentDistributor {get; set;}
    public String currentDistributorId {get; set;}

    public Folder directoryTree {get; set;}
    public String downloadFromFolderId {get; set;}
    public String currentPageUrl {get; set;}
    public List<AggregateResult> content {get; set;}
    public Map<Id, list<File>> fileMap {get; protected set;}
    public String emptySring {get{return '';}}

    public Controller_PerformanceManagment() {
    	try{
			pageUrl = Page.PerformanceManagment.getUrl();
	        shareFromContentDescription = false;
	
		    directoryTree = new Folder('PARENT','PARENT');
		    content = new List<AggregateResult>();
		    Map<Id, list<File>> fileMap = new Map<Id, list<File>>();
			isAutomaticLand = false;
			selectedIterator = 1;
		    currentDivision = '';		
		    currentDistributor = '';
		    currentDistributorId = '';
			downloadFromFolderId = '';
			currentOrganizationalUnit = null;  
			organizationalUnitBreadcrumbs = new BreadcrumbsHolder();	
			totalUserOrganizationalsUnits = new list<id>();
			// start vars
			list<Integer> levels = new List<Integer>();
			Map<Integer, String> startLevels = new Map<Integer, String>();
			//		
		
			String tmpcurrentDistributor;
			String tmpcurrentDistributorId;

	        List<Account> accounts = Service_API.getUserAccounts();
			Id defaultAccountId = Id.valueOf(Service_API.getAID());
	        for(Account a : accounts){            	
	           	if(a.Id == defaultAccountId){
					tmpcurrentDistributor = a.Name;
					tmpcurrentDistributorId = a.Id;
					Integer itLevel = 2; 
					set<id> defaultAccountIdSet = new set<id>();
					defaultAccountIdSet.add(defaultAccountId);
					for(String orgUnitStage : Service_API.searchOrganizationalUnitIds(defaultAccountIdSet)){
						isAutomaticLand = true;
						levels.add(itLevel);
						startLevels.put(itLevel, orgUnitStage);
						itLevel++;
					}
	           	} 
	        }
	        totalUserOrganizationalsUnits = Service_API.searchOrganizationalUnitIds(Service_API.getAIDs());

			if(!isAutomaticLand){ // access only to one dis, don't get params from url, user always land in one place
				map<String,String> urlPrm = ApexPages.currentPage().getParameters();
				for(String prm : urlPrm.keySet()){
					String cIter = prm.replaceAll('orgunit', '');
					if(prm.length() != cIter.length()){ // this param contains information about org unit
						levels.add(Integer.valueOf(cIter));
						startLevels.put(Integer.valueOf(cIter), urlPrm.get(prm));
					}
				}
				if(ApexPages.currentPage().getParameters().get('distributorname') != null && ApexPages.currentPage().getParameters().get('distributorname') != '' && ApexPages.currentPage().getParameters().get('distributorid') != null && ApexPages.currentPage().getParameters().get('distributorid') != ''){
					currentDistributor =  EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('distributorname'), 'UTF-8');
					currentDistributorId = ApexPages.currentPage().getParameters().get('distributorid');
				}
				if(ApexPages.currentPage().getParameters().get('sitetheme') != null && ApexPages.currentPage().getParameters().get('sitetheme') != ''){
					String requestedTheme =  EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('sitetheme'), 'UTF-8');
					if(requestedTheme != siteTheme){
						ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Theme should be changed to: '+requestedTheme));
						return;
					}
				}
			} else {
				currentDistributor 		= tmpcurrentDistributor;
				currentDistributorid 	= tmpcurrentDistributorid;
			}
			
			// starting params exists
			if(levels.size() !=0){
				levels.sort(); // sort! required!
				for(Integer lvl : levels){
					selectedIterator++;
					currentOrganizationalUnit = startLevels.get(lvl);
					prepareBreadcrumbs();
				}
			} else {
				prepareBreadcrumbs();
			}
			if(currentDistributor != null && currentDistributor !='' && currentDistributorId != '' && currentDistributorId != null){
				showContent();
			}			
        } catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable load data. '));
			return;        
        }	
    }

	private OrganizationalUnit setupOrganizationalUnit(Id startFromOuId){
		try{
			if(Service_API.getSectionTheme() == null || Service_API.getSectionTheme() == ''){
				return new OrganizationalUnit(CONSTANT.PERFORMANCE_MANAGMENT, CONSTANT.PERFORMANCE_MANAGMENT);
			}
			// get data to processing
			if(organizationalUnits == null){
				if(isInternalUser){
				    organizationalUnits = [ SELECT id, Name, Parent__r.Id, Parent__r.Name FROM Organizational_Unit__c where type__c = :Service_API.getSectionTheme()];
				    organizationalUnitBreadcrumbs.setupOrganizationalUnitsMap(organizationalUnits);
				} else {
					set<id> ouAccess = new set<id>(totalUserOrganizationalsUnits);
					organizationalUnits = [ SELECT id, Name, Parent__r.Id, Parent__r.Name FROM Organizational_Unit__c where type__c = :Service_API.getSectionTheme() and id in :ouAccess];
					organizationalUnitBreadcrumbs.setupOrganizationalUnitsMap(organizationalUnits);  
				}
			}
			if(parentsOUids == null){
				parentsOUids = new set<id>();
				for(Organizational_Unit__c op :organizationalUnits){
					if(op.Parent__r.Id != null){
						parentsOUids.add(op.Parent__r.Id);
					}
				}
			}
			if(distributors == null){		
			    if(isInternalUser){
		        	distributors = database.query('SELECT Id, Name, '+Service_API.getSectionTheme()+'_Hierarchy__c FROM Account WHERE Account.RecordTypeId in ('+IdListToString(Service_API.getAccountRecordTypeIds())+')');
			    } else {
		        	distributors = database.query('SELECT Id, Name, '+Service_API.getSectionTheme()+'_Hierarchy__c FROM Account WHERE id in ('+IdListToString(Service_API.getAIDs())+') and Account.RecordTypeId in ('+IdListToString(Service_API.getAccountRecordTypeIds())+')');	    
			    }
			}
			// start processing
			OrganizationalUnit tmpOuTree;
			if(startFromOuId == null){
				tmpOuTree = new OrganizationalUnit(CONSTANT.PERFORMANCE_MANAGMENT, CONSTANT.PERFORMANCE_MANAGMENT);
			} else {
				tmpOuTree = new OrganizationalUnit(startFromOuId, organizationalUnitBreadcrumbs.organizationalUnitsMap.get(startFromOuId).Name);
			}
	
		    // processing distributors
		    if(distributorMap == null){
				distributorMap = new Map<Id, list<Account>>();
				for(Account d : distributors){
					list<Account> distributorContainer;
					sObject dSobject = (sObject) d;
					if(dSobject.get(Service_API.getSectionTheme()+'_Hierarchy__c') != null){
						Id assignedToOrgUnitWithId = Id.valueof(String.valueof(dSobject.get(Service_API.getSectionTheme()+'_Hierarchy__c')));
						if(assignedToOrgUnitWithId != null){
							if(distributorMap.containsKey(assignedToOrgUnitWithId)){
								distributorContainer = distributorMap.get(assignedToOrgUnitWithId);
							} else {
								distributorContainer = new list<Account>();
							}
							distributorContainer.add(d);
							distributorMap.put(assignedToOrgUnitWithId, distributorContainer);
						}
					}
				}
			}
			// processing organizational units
			if(ouMap == null){
		    	ouMap = new Map<Id, OrganizationalUnit>();
				for(Organizational_Unit__c o : organizationalUnits){
					OrganizationalUnit ou = new OrganizationalUnit(o.Id, o.Name);
					OrganizationalUnit parentOu;
					if(ouMap.containsKey(o.Parent__c)){
						parentOu = ouMap.get(o.Parent__c);
					} else {
						parentOu = new OrganizationalUnit(o.Parent__c, o.Parent__r.Name);
					}
					parentOu.addOrganizationalUnit(ou);
					ouMap.put(o.Parent__c, parentOu);
				}
			}
			
			// generate final tree
			for(Organizational_Unit__c o : organizationalUnits){
				if(o.Parent__c == startFromOuId ){
					OrganizationalUnit ouParent = new OrganizationalUnit(o.Id, o.Name);
					if(distributorMap.containsKey(o.Parent__c)){
						tmpOuTree.assignDistributors( distributorMap.get(o.Parent__c) );
					}
					tmpOuTree.addOrganizationalUnit( prepareOrganizationalUnitTree(ouMap, distributorMap, ouParent) );
				} else if(o.Id == startFromOuId ) {
					if(!parentsOUids.contains(o.Id)){
						if(distributorMap.containsKey(o.Id)){
							tmpOuTree.assignDistributors( distributorMap.get(o.Id) );
						}
					}			
				}
			}
			return tmpOuTree;
        } catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to prepare organizational unit tree. '));
			return null;       
        }	
	}
	//generate tree
	private OrganizationalUnit prepareOrganizationalUnitTree(Map<Id, OrganizationalUnit> ouMap, Map<Id,list<Account>> distributorMap, OrganizationalUnit ou){
		try{
			OrganizationalUnit ouSubTree = new OrganizationalUnit(ou.organizationalUnitId, ou.organizationalUnitName);
			if(distributorMap.containsKey(ou.organizationalUnitId)){
				ouSubTree.assignDistributors( distributorMap.get(ou.organizationalUnitId) );
			}	
			if(ouMap.containsKey(ou.organizationalUnitId)) {
				for(OrganizationalUnit o: ouMap.get(ou.organizationalUnitId).organizationalUnits){
					ouSubTree.addOrganizationalUnit( prepareOrganizationalUnitTree(ouMap, distributorMap, o) );
				}
			}
			return ouSubTree;
        } catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to prepare organizational unit tree (recursion). '));
			return null;       
        }	
	}

	private void prepareBreadcrumbs(){
		try {
			map<string,string> urlParams = new map<string,string>();
			organizationalUnitBreadcrumbs.clear();		
			OrganizationalUnit currentOrgUnitIns = setupOrganizationalUnit(null);
			
			organizationalUnitBreadcrumbs.addOrganizationalUnit(currentOrgUnitIns);
			if(currentOrganizationalUnit != null){
				List<id> orgUnitSteps = new List<id>();
				Service_API.searchOrganizationalUnitIdsRecursion(currentOrganizationalUnit, orgUnitSteps);
				Integer oulvl = 1;
				for(Id ouid : orgUnitSteps){
					if(!urlParams.containsKey('orgunit'+String.valueof(oulvl))){
						urlParams.put('orgunit'+String.valueof(oulvl), ouid);
					}
					currentOrgUnitIns = setupOrganizationalUnit(ouid);
					organizationalUnitBreadcrumbs.addOrganizationalUnit(currentOrgUnitIns);
					oulvl++;
				}
			}
	        
	       	currentPageUrl = Page.PerformanceManagment.getUrl();
			
			if(currentDistributorId != null && currentDistributorId != '' && currentDistributor != '' && currentDistributor != null){
				urlParams.put('distributorid', currentDistributorId);
				urlParams.put('distributorname', EncodingUtil.urlEncode(currentDistributor, 'UTF-8'));
			}

			if(siteTheme != null && siteTheme != '' && siteTheme != '' && siteTheme != null){
				urlParams.put('sitetheme', EncodingUtil.urlEncode(siteTheme, 'UTF-8'));
			}	
			
			if(currentOrgUnitIns.distributors.size() == 0 && currentOrgUnitIns.organizationalUnits.size() == 1){
				currentOrganizationalUnit = currentOrgUnitIns.organizationalUnits.get(0).organizationalUnitId;
				selectedIterator++;
				prepareBreadcrumbs();
			} else if(currentOrgUnitIns.distributors.size() == 1 && currentOrgUnitIns.organizationalUnits.size() == 0){
				currentDistributor = currentOrgUnitIns.distributors.get(0).Name;
				currentDistributorid = currentOrgUnitIns.distributors.get(0).Id;
			}
	
	       	// generate url 
	       	if(!urlParams.isEmpty()){
	       		currentPageUrl += '?';
	       		String glue = '';
	       		for(String param : urlParams.keySet()){
	       			if(!currentPageUrl.contains(param)){
	       				currentPageUrl += glue+param+'='+urlParams.get(param);
	       				glue = '&';
	       			}
	       		} 
	       	}
        } catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to prepare organizational unit breadcrumbs tree. '));
        }	
	}

	public void nextOrganizationalUnit(){
		prepareBreadcrumbs();
		showContent();
	}
	
	public void distributorsContent(){	
		prepareBreadcrumbs();
		showContent();
	}

	public void downloadFromFolder(){
		if(downloadFromFolderId != '' && downloadFromFolderId != null && currentDistributorId != null && currentDistributorId != '' && currentDivision != null && currentDivision != '' ){
			try{
				
				List<AccountBrand__c> ab = [select Brand__c from AccountBrand__c where Brand__r.diageo_direct_visible__c = true and id in :Service_API.getAIDs()];
				List<Id> ids = new List<Id>();
				for(AccountBrand__c a : ab){
					ids.add(a.Brand__c);
				}
				
	    		content = new List<AggregateResult>();
  				String query = 'select Content_Version_Id__c cvid, Description__c description, filesize__c filesize, filetype__c filetype, Title__c  title, is_video__c is_video, video_id__c video_id, Image_Resolution__c imageRes' + 
	  			  	   ' from File__c ' +
  					   ' where Brands__c includes (\''+IdListToString(ids)+'\') AND Page_Section__c = \''+CONSTANT.PERFORMANCE_MANAGMENT+'\' and Folders__c includes (\''+downloadFromFolderId+'\') and (( Distributors__c includes (\''+currentDistributorId+'\') or Division_Access__c = \''+currentDivision+'\' ) ';
				if(isInternalUser){
					query += ' or ( Distributors__c = null or Division_Access__c = null ) ';
				}   
				query += ' ) GROUP BY Content_Version_Id__c, Image_Resolution__c, Description__c, filesize__c, filetype__c, Title__c, is_video__c, video_id__c ' +
					   + ' ORDER BY Description__c ASC';		
    			content = database.query(query);

			} catch(Exception e){
				ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to download multiple files. Processing error. '));
            	return;
			}
		} else {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to download multiple files. Missing params. '));
            return;
		}
	}

	public void showContent(){
	    directoryTree = new Folder('PARENT','PARENT');
		try{
			
			if(currentDistributorId != null && currentDistributorId != ''){
				currentDivision = Service_API.searchDivisionByDistributorId(currentDistributorId);
				List<Folder__c> folders = Service_API.getDocumentFolders(Constant.PERFORMANCE_MANAGMENT, currentOrganizationalUnit, isInternalUser);
				List<File__c> files = Service_API.getFolderFiles(Constant.PERFORMANCE_MANAGMENT, currentDistributorId, currentDivision, isInternalUser);
		    	fileMap = new Map<Id, list<File>>();
				for(File__c file : files){
					File fileObject = new File(file.Content_Version_Id__c, file.Description__c, file.filesize__c, file.filetype__c, file.video_id__c);
					list<Id> assignedToFolders = file.Folders__c!=null?file.Folders__c.split(';'):new list<Id>();
					for(Id parentFolderId : assignedToFolders){
			    		if(parentFolderId != null){
							list<File> fileContainer;
							if(fileMap.containsKey(parentFolderId)){
								fileContainer = fileMap.get(parentFolderId);
							} else {
								fileContainer = new list<File>();
							}
							fileContainer.add(fileObject);
							fileMap.put(parentFolderId, fileContainer);
			    		}
					}
				}
	
		    	Map<Id, Folder> folderMap = new Map<Id, Folder>();
				for(Folder__c folder : folders){
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
				for(Folder__c folder : folders){
					if(folder.Parent_Folder__c == null ){
						Folder folderObject = new Folder(folder.Id, folder.Name);			
						directoryTree.addToFolder( prepareTree(folderMap, fileMap, folderObject) );
					}
				}
				
				currentBasketIds = Service_Basket.getBasketIds();
				currentFollowIds = Service_Notification.getFollowIds();
			}			
		} catch(Exception e){
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to prepare directory tree. '));
           	return;
		}
	}

	private Folder prepareTree(Map<Id,Folder> folderMap, Map<Id,list<File>> fileMap, Folder folder){
		Folder directoryTree = new Folder(folder.folderId, folder.folderName);
		if(folderMap.containsKey(folder.folderId)) {
			for(Folder f: folderMap.get(folder.folderId).dirs){
				directoryTree.addToFolder( prepareTree(folderMap, fileMap, f) );
			}
		}
		if(fileMap.containsKey(folder.folderId)){
			directoryTree.addToFolder( fileMap.get(folder.folderId) );
		}					
		return directoryTree;	
	}
	
	public String IdListToString(List<ID> valueList){
    	String result = '';
    	String glue = '';
		for (String value : valueList) {         
			result += glue + '\''+value+'\' ';
			glue = ',';
		}    	
    	return result;
    }
    
	public String IdListToString(Set<ID> valueList){
    	String result = '';
    	String glue = '';
		for (String value : valueList) {         
			result += glue + '\''+value+'\' ';
			glue = ',';
		}    	
    	return result;
    }
}