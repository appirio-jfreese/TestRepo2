/*******************************************************************************
Name 				: Controller_Collaboration.cls

*******************************************************************************/
public without sharing class Controller_Collaboration extends Controller_Base {
    public class CollaborationException extends Exception {}

	public String currentConversationFileId {get;set;}
    
	private list<Account> distributors;
	private list<Organizational_Unit__c> organizationalUnits;
    private Map<Id, OrganizationalUnit> ouMap;
	private Map<Id, list<Account>> distributorMap;
	private set<id> parentsOUids;
	
	public list<id> totalUserOrganizationalsUnits {get; protected set;}
	public Id currentOrganizationalUnit{get;set;}
	public Integer selectedIterator{get;set;}
	public String currentDivision {get; set;}
	public String currentDistributor {get; set;}
    public String currentDistributorId {get; set;}
   	public Id organizationalHierarchy{
   		get { return currentOrganizationalUnit;} set;
   	}
   	public String organizationalHierarchyName{
		get {
			if(organizationalUnitBreadcrumbs.organizationalUnitsMap.containsKey(currentOrganizationalUnit)){ 				
				return organizationalUnitBreadcrumbs.organizationalUnitsMap.get(currentOrganizationalUnit).Name;
			} else {
				return '';
			}
		} set;
   	}
    
    public BreadcrumbsHolder organizationalUnitBreadcrumbs{get;set;}  
      
    private String mainFoldername = '';
    public Map<String, List<AggregateResult>> contentMap {get; protected set;}
    public Map<String, String> contentComments {get; protected set;}
    public MAP<string, List<AggregateResultHolder>> contentHolderMap {
    	get {
    		MAP<string, List<AggregateResultHolder>> contentHolder1 = new MAP<string, List<AggregateResultHolder>>();
    		if(contentMap!=null){
    			for(string key : contentMap.keySet()){
		    		List<AggregateResultHolder> tmpList = new List<AggregateResultHolder>();
		    		for(AggregateResult ar : contentMap.get(key)){
		    			AggregateResultHolder tmp = new AggregateResultHolder();
		    			tmp.result = ar;
		    			tmp.contentId = String.valueOf(ar.get('id'));
		    			tmpList.add(tmp);
		    		}
		    		contentHolder1.put(key,tmpList);
    			}
    		}
    		return contentHolder1;
    	}
    	set;
    }
    
    public String emptySring {get{return '';}}
    private List<String> headersTmp = new List<String>();
    public List<String> headers {set;
    	get{
    		List<String> tmp = new List<String>();
    		for(String s : headersTmp){
    			if(contentMap.keySet().contains(s))
    				tmp.add(s);
    		}
    		return tmp;
    	}
    } 
    public String emptyString = '';
    public Integer contentSize {
    	get {
    		Integer i = 0;
    		if(!contentMap.isEmpty()){
    			for(List<AggregateResult> l : contentMap.values()){
    				if(l != null){
    					i+=l.size();
    				}
    			}
    		}
    		return i;
    	}
    }
    public List<AggregateResult> contentList {
    	get {
    		List<AggregateResult> res = new List<AggregateResult>();
    		if(!contentMap.isEmpty()){
	    		for(List<AggregateResult> it : contentMap.values()){
	    			res.addAll(it);
	    		}
    		}
    		return res;
    	}
    }
    public Boolean isAutomaticLand {get; set;}
	public list<Folder_Comment__c> comments {get; protected set;}
    public Folder sectionFolders {get; protected set;}
    public Folder subSectionFolders {get; protected set;}
    public String currentSection {get; set;}
    public String currentSubSection {get; set;}
	public String currentPageUrl {get; set;}
	public String currentPageUrlSections {get; set;}
    public String requestedFolder {
     	get{
			if(currentSubSection != '' && currentSubSection != null){
				return currentSubSection;
			} else {
				return currentSection;
			}
       	}
	    private set;
	} 
    public String requestedFolderName {
     	get{
     		String fName = 'Not found';
	        if(currentSection != null && currentSection != ''){
	        	for(Folder folder : sectionFolders.dirs){
	        		if(folder.folderId == currentSection){
	        			fName = folder.folderName.replaceAll('<br/>',' ');
	        			break;
	        		}
	        	}
	        }
	        if(currentSubSection != null && currentSubSection != ''){
	        	for(Folder folder : subSectionFolders.dirs){
	        		if(folder.folderId == currentSubSection){
	        			fName = folder.folderName.replaceAll('<br/>',' ');
	        			break;
	        		}
	        	}
	        }
			return fName; 
       	}
	   	set;
	}     
    
	// display as list (true) or box (false)
    public Boolean displayAsList {get; set;}	
    public Boolean isAddCommentAllowed {get; protected set;}	
    public Boolean isUploadFileAllowed {get; protected set;}
		public Boolean isUserAllowedToUploadFile {get; protected set;}
		// Start : TA993 : Parul Gupta (Appirio Offshore)
    public Boolean allowFileEdit {get; protected set;}
    // End : TA993 : Parul Gupta (Appirio Offshore)
    public Controller_Collaboration() {
		try {
			pageUrl = Page.Collaboration.getUrl();
			
	        shareFromContentDescription = false;
	    	currentPageUrlSections = '';
	    	currentPageUrl = Page.Collaboration.getUrl();
		    contentMap = new Map<String, List<AggregateResult>>();
		    headersTmp = new List<String>();
		    comments = new List<Folder_Comment__c>();
			sectionFolders = new Folder('PARENT','PARENT');
			subSectionFolders = new Folder('CHILD','CHILD');		
			isAutomaticLand = false;
			selectedIterator = 1;
			
			// start vars
			list<Integer> levels = new List<Integer>();
			Map<Integer, String> startLevels = new Map<Integer, String>();
			//
	
			isAddCommentAllowed = false;
			isUploadFileAllowed = false;
			isUserAllowedToUploadFile = [select Collaboration_Upload_Allowed__c from user where id = :Service_API.getUID()].Collaboration_Upload_Allowed__c;
			
			// Start : TA993 : Parul Gupta (Appirio Offshore)
	    	// Added new attribute allowFileEdit to allow Diageo Employees
	    	// to delete, rename, and replace existing files if they have access to upload section.
	    	if(isUserAllowedToUploadFile){
	    		allowFileEdit = true;
	    	}else{
	    		allowFileEdit = false;
	    	}
	    	// END : TA993 : Parul Gupta (Appirio Offshore)
	    	
	      	currentDivision = '';
		    currentDistributor = '';
		    currentDistributorId = '';
			// sub sections
			currentSection = '';
			currentSubSection = '';		
	
			displayAsList = false;
			
			currentOrganizationalUnit = null;  
	
			organizationalUnitBreadcrumbs = new BreadcrumbsHolder();	
			totalUserOrganizationalsUnits = new list<id>();
			
			String tmpcurrentDistributor;
			String tmpcurrentDistributorId;

			if(ApexPages.currentPage().getParameters().get('afterupload') != null && ApexPages.currentPage().getParameters().get('afterupload') != ''){
				isAutomaticLand = false; 
			} else {
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
			}
	        
	        totalUserOrganizationalsUnits = Service_API.searchOrganizationalUnitIds(Service_API.getAIDs());
	        
			if(ApexPages.currentPage().getParameters().get('displayas') != null && ApexPages.currentPage().getParameters().get('displayas') != ''){
				if(ApexPages.currentPage().getParameters().get('displayas') == 'box'){
					displayAsList = false;
				} else {
					displayAsList = true;
				}
			}
			if(ApexPages.currentPage().getParameters().get('section') != null && ApexPages.currentPage().getParameters().get('section') != '' ){
				currentSection = ApexPages.currentPage().getParameters().get('section');
			}

			if(ApexPages.currentPage().getParameters().get('subection') != null && ApexPages.currentPage().getParameters().get('subection') != '' ){
				currentSubSection = ApexPages.currentPage().getParameters().get('subection');
			}

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
						isAddCommentAllowed = false;
						isUploadFileAllowed = false;
				        currentDivision = '';
					    currentDistributor = '';
					    currentDistributorId = '';
						currentSection = '';
						currentSubSection = '';	
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
					selectedIterator = lvl;
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
           	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load data.'));
           	return;			
		}		        
      
    }

	public void showContent(){
		try{
			
			sectionFolders = new Folder('PARENT','PARENT');				
			subSectionFolders = new Folder('CHILD','CHILD');
			isAddCommentAllowed = false;
			isUploadFileAllowed = false;
			
			if(currentDistributorId != null && currentDistributorId !=''){
				List<Folder__c> folders = Service_API.getDocumentFolders(Constant.COLLABORATION, currentOrganizationalUnit, this.isInternalUser, currentDistributorId);
				for(Folder__c folder : folders){
					if(folder.Parent_Folder__c == null && folder.is_header__c != true){
						Folder folderObject = new Folder(folder.Id, folder.Name.replaceAll(' ','<br/>'), folder.Allow_File_Upload__c, folder.Allow_Add_Comment__c);
						sectionFolders.addToFolder(folderObject);
						if(currentSection == '' || currentSection == null){
							currentSection = folder.Id;
						}
						if(currentSection != null && currentSection != '' && Id.valueOf(currentSection) == folder.Id){
							isAddCommentAllowed = folder.Allow_Add_Comment__c;
							isUploadFileAllowed = folder.Allow_File_Upload__c;
						}
					}
				}		
					
				if (currentSection == null || currentSection == '') {
					throw new CollaborationException('There is no content');
				}	
				for(Folder__c folder : folders){
					if(folder.Parent_Folder__c != null){
						if(folder.Parent_Folder__c == Id.valueOf(currentSection)){
							Folder folderObject = new Folder(folder.Id, folder.Name, folder.Allow_File_Upload__c, folder.Allow_Add_Comment__c);
							subSectionFolders.addToFolder(folderObject);
	
							if(currentSubSection != null && currentSubSection != '' && Id.valueOf(currentSubSection) == folder.Id){
								isAddCommentAllowed = folder.Allow_Add_Comment__c;
								isUploadFileAllowed = folder.Allow_File_Upload__c;
							}						
						}
					}
				}
			}
			initPager();
			refreshPageContent();

			currentPageUrlSections = '';
			if(currentSection != null && currentSection != ''){
				currentPageUrlSections += '&section='+currentSection;
			}
			if(currentSubSection != null && currentSubSection != ''){
				currentPageUrlSections += '&subsection='+currentSubSection;
			}
		
		} catch(CollaborationException e) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, e.getMessage()));
			initPager();
			refreshPageContent();
            return;
		} catch(Exception e){
			initPager();
			refreshPageContent();
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load sections.'));
			return;
		}
	}

	public void userAddComment(){
		refreshPageContent();
	}
	
    public List<SelectOption> getFileOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Select File'));
        for(String key : contentMap.keySet()){
	        List<AggregateResult> content = contentMap.get(key);
	        if(content.size() > 0){
				for(AggregateResult file : content){
					options.add(new SelectOption(String.valueOf(file.get('id')),String.valueOf(file.get('description'))));
				}
			}
        }
        return options;
    }
    
	private OrganizationalUnit setupOrganizationalUnit(Id startFromOuId){
		try{
			if(Service_API.getSectionTheme() == null || Service_API.getSectionTheme() == ''){
				return new OrganizationalUnit(CONSTANT.COLLABORATION, CONSTANT.COLLABORATION);
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
		        	distributors = database.query('SELECT Id, Name, '+Service_API.getSectionTheme()+'_Hierarchy__c FROM Account WHERE Account.RecordTypeId in ('+IdSetToString(Service_API.getAccountRecordTypeIds())+')');
			    } else {
		        	distributors = database.query('SELECT Id, Name, '+Service_API.getSectionTheme()+'_Hierarchy__c FROM Account WHERE id in ('+IdSetToString(Service_API.getAIDs())+') and Account.RecordTypeId in ('+IdSetToString(Service_API.getAccountRecordTypeIds())+')');	    
			    }
			}
			// start processing
			OrganizationalUnit tmpOuTree;
			if(startFromOuId == null){
				tmpOuTree = new OrganizationalUnit(CONSTANT.COLLABORATION, CONSTANT.COLLABORATION);
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
					if(o.Parent__c != null && distributorMap.containsKey(o.Parent__c)){
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
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to prepare organizational unit tree (recursion). '));
			return null;       
        }	
	}
	//generate tree
	private OrganizationalUnit prepareOrganizationalUnitTree(Map<Id, OrganizationalUnit> ouMap, Map<Id,list<Account>> distributorMap, OrganizationalUnit ou){
		try{
			OrganizationalUnit ouSubTree = new OrganizationalUnit(ou.organizationalUnitId, ou.organizationalUnitName);
			if(ouMap.containsKey(ou.organizationalUnitId)) {
				for(OrganizationalUnit o: ouMap.get(ou.organizationalUnitId).organizationalUnits){
					ouSubTree.addOrganizationalUnit( prepareOrganizationalUnitTree(ouMap, distributorMap, o) );
				}
			}
			if(distributorMap.containsKey(ou.organizationalUnitId)){
				ouSubTree.assignDistributors( distributorMap.get(ou.organizationalUnitId) );
			}					
			return ouSubTree;
        } catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to prepare organizational unit tree. '));
			return null;       
        }	
	}
    
	private void prepareBreadcrumbs(){
		try{
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
	       	currentPageUrl = Page.Collaboration.getUrl();
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

    // switch section
    public void switchSection() {
    	currentSubSection = '';
		showContent(); 	
    }    

    // switch subSection
    public void switchSubSection() {
    	showContent();	
    } 

    public void renderAsList() {
    	displayAsList = true; // other action if needed

    }   

    public void renderAsBox() {
    	displayAsList = false; // other action if needed    	
    } 

    public override void refreshPageContent() {
		try{
			
			contentMap = new Map<String, List<AggregateResult>>();
			contentComments = new Map<String, String>();
			headersTmp = new List<String>();
			
			comments = new List<Folder_Comment__c>();
			List<AggregateResult> content = new List<AggregateResult>();			

			if( ((currentSection != '' && currentSection != null) || (currentSubSection != '' && currentSubSection != null)) && (currentDistributorId != '' && currentDistributorId != null) && (requestedFolder != '' && requestedFolder != null)){ 
				currentDivision = Service_API.searchDivisionByDistributorId(currentDistributorId);
							
				numberOfItems = 0;
				mainFoldername = [select Name from Folder__c where Id = :requestedFolder].Name;
				
				List<Folder__c> folders = [select Id, Name from Folder__c where (Id = :requestedFolder) or  (Parent_Folder__c = :requestedFolder and Page_Section__c = :CONSTANT.COLLABORATION and is_header__c = true and Classification__c includes (:Service_API.getSectionTheme())) order by Order__c asc];
				String queryString = 'select OwnerID, Description__c folderName, id, Content_Version_Id__c cvid, Description__c description, filesize__c filesize, filetype__c filetype, Title__c  title, is_video__c is_video, video_id__c video_id, Preview_Available__c previewAvailable, Preview_Id__c previewId, max(Uploaded_date__c) createdDate, Image_Resolution__c imageRes '+
							'from File__c '+ 
	  					   	'where Classification__c includes (\''+Service_API.getSectionTheme()+'\') and (Available_Until__c >= TODAY or Available_Until__c = null) and (Page_Section__c = \''+CONSTANT.COLLABORATION+'\') and ( Distributors__c includes (\''+currentDistributorId+'\') or Division_Access__c = \''+currentDivision+'\' ) ';
	  			queryString += (!this.isInternalUser) ? ' and (Only_For_Internal_User__c = false) ' : '';
	  			queryString += ' and (';
	  			queryString += 'Folders__c includes (\''+requestedFolder+'\')';
		  		for(Folder__c folder : folders){
			       	queryString += ' or Folders__c includes (\''+folder.id+'\')';
		  		}
		  		queryString += ')';
	  			queryString += 'GROUP BY id, Content_Version_Id__c, Description__c, filesize__c, filetype__c, Title__c, is_video__c, video_id__c, Preview_Available__c, Preview_Id__c, Image_Resolution__c, OwnerID ORDER BY Description__c';
	  			content = database.query(queryString);
				List<Id> fids = new List<Id>();
	            for(AggregateResult ar : content){
	              	fids.add((Id)ar.get('id'));
	            }
	            List<File__c> filesWithFolders = [select id, Folders__c from File__c where id in :fids];
	            Map<id, list<id>> fileToFolders = new Map<id, list<id>>();
	            for(File__c file : filesWithFolders){
	              	if(file.Folders__c == null || file.Folders__c == '')
	               		continue;
	               	list<id> tmp = new list<id>();
	               	if(file.Folders__c != null){
		               	for(String s : file.Folders__c.split(';')){
		               		tmp.add((id)s);
		               	}
	               	}
	               	fileToFolders.put(file.id, tmp);
	            }
	            Map<id, String> folderIdToName = new Map<id, String>();
	            for(Folder__c folder : folders){
	            	folderIdToName.put(folder.id, folder.Name);
	            }
	            for(AggregateResult ar : content){
	               	List<Id> tmpl = fileToFolders.get((Id)ar.get('id'));
	               	if(tmpl == null)
	               		continue;
	               	for(Id fid : tmpl){
	               		String fname = folderIdToName.get(fid);
	               		if(fname == null)
	               			continue;
	               		List<AggregateResult> tmp = contentMap.get(fname);
	               		tmp = (tmp == null) ? (new List<AggregateResult>()) : tmp;
	               		tmp.add(ar);
	               		contentMap.put(fname, tmp);
	               		numberOfItems++;
	               		if(fid == requestedFolder)
	               			mainFoldername = fname;
	               	}
	            }
	            for(Folder__c folder : folders){
	              	if(contentMap.keySet().contains(folder.Name))
	            		headersTmp.add(folder.Name);
	            }
	            if(!contentMap.isEmpty()){
	              	contentMap = getRequestedPageForMap(contentMap, headers);
	            } else {
					numberOfItems = 0; 
	            }
				currentBasketIds = Service_Basket.getBasketIds();
				currentFollowIds = Service_Notification.getFollowIds();
				
				comments = Service_API.getFolderComments(currentDistributorId, requestedFolder);
				// get number of comments for each item
				set<string> fileIdsOnCurrentPage = new set<string>();
				for(List<AggregateResult> underHeader : contentMap.values()){
					for(AggregateResult ch : underHeader){
						String fileIdOnPage = String.valueOf(ch.get('id'));
						fileIdsOnCurrentPage.add(fileIdOnPage);
						contentComments.put(fileIdOnPage, '0');
					}
				}
				if(!fileIdsOnCurrentPage.isEmpty()){
					list<AggregateResult> numberOfComments = [
						select 
							file__r.id fileId, count(id) numberOfComments 
						from 
							folder_comment__c 
						where 
							file__c in :fileIdsOnCurrentPage 
							and Distributor_Access__c = :currentDistributorId 
                    		and Folder__c = :requestedFolder
                    		and Classification__c = :Service_API.getSectionTheme() 
                    	group by 
                    		file__r.id
					];
					for(AggregateResult num : numberOfComments){
						String fileIdOnPage = String.valueOf(num.get('fileId'));
						contentComments.put(fileIdOnPage, String.valueOf(num.get('numberOfComments')));
					}
				}
			} else {
				numberOfItems = 0;			
			}
       	} catch( Exception err ){
        	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load content.'));
           	return;
       	}
      
    }	

    private String IdSetToString(Set<ID> valueList){
    	String result = '';
    	String glue = '';
		for (String value : valueList) {         
			result += glue + '\''+value+'\' ';
			glue = ',';
		}    	
    	return result;
    }
}