global without sharing class Service_UploadFile {

    /*************WRAPPERPS**********************************/
    public class FileWrapper{
        public ContentVersion file {get;set;}
        public FileWrapper(Boolean first){
            file = new ContentVersion(Description = first ? '' : ' ');
        }
    }
    
   global class HierarchicalOption {
        public String value {get;set;}
        public String label {get;set;}
        public String optionId {get;set;}
        public List<HierarchicalOption> children {get;set;}
        public HierarchicalOption(String optionId, String label){
            this.value = optionId;
            this.optionId = optionId;
            this.label = label;
            children = new List<HierarchicalOption>();
        }
        public void addKid(HierarchicalOption option){
            children.add(option);
        }
    }
    
    global class Destination{
        public String orgUnitId {get;set;}
        public String orgUnitName {get;set;}
        public String distributorId {get;set;}
        public String distributorName {get;set;}
        public String foldersIds {get;set;}
        public String foldersNames {get;set;}
        public Destination(){
            this.orgUnitId = '';
            this.orgUnitName = '';
            this.distributorId = '';
            this.distributorName = '';
            this.foldersIds = '';
            this.foldersNames = '';
        }
        public Destination(Id orgUnitId, String orgUnitName, Id distributorId, String distributorName, Id folderId, String folderName){
            this.orgUnitId = orgUnitId;
            this.orgUnitName = orgUnitName;
            this.distributorId = distributorId;
            this.distributorName = distributorName;
            this.foldersIds = folderId+',';
            this.foldersNames = folderName+',';
        }
        public set<String> foldersIdsUnique(){
        	set<String> uniqueResult = new set<String>();
        	if(foldersIds == null | foldersIds == ''){
        		return uniqueResult;
        	}
        	List<String> ids = foldersIds.split(',');
        	for(String id : ids){
        		if(id != null && id.trim() !=''){
        			uniqueResult.add(id);
        		}
        	}
        	return uniqueResult;
        }
        public set<String> foldersNamesUnique(){
        	set<String> uniqueResult = new set<String>();
        	if(foldersNames == null | foldersNames == ''){
        		return uniqueResult;
        	}
        	List<String> ids = foldersNames.split(',');
        	for(String id : ids){
        		if(id != null && id.trim() != ''){
					uniqueResult.add(id);
        		}
        	}
        	return uniqueResult;
        }
    }
    /*************FIELDS**********************************/
    
    public List<Organizational_Unit__c> orgUnits {get;set;}
    public Id organizationalHierarchyIdSelected {get;set;}
    public String distributorIdSelected {get; set;}
    
    // cache
    private id folderIdTmp;
    private id distributorIdTmp;
    private id organizationalHierarchyIdTmp;
    //
    
    public Id folderId {get;set{folderId = value; initService();}}
    public Id distributorId {get;set{ distributorId = value; initService(); }}
    public String distributorName {get;set{distributorName = value; initService();}}
    public Id organizationalHierarchyId {get;set{organizationalHierarchyId = value; initService();}}
    public String organizationalHierarchyName {get; set{organizationalHierarchyName = value; initService();}}
    public String afterUploadRedirectTo {get; set;}
    public String fileIndexes {get;set;}
    public String destinationIndexes {get;set;}
    public Boolean isInternal {get;set;}
    public String comment{get;set;}
    public Date availableUntil {get;set;}
    public String availableUntilText {get;set;}
    
    public Boolean isError {get;set;}
    
    public List<Destination> destinations {get;set;}
    
    public ContentVersion file0 {get;set;}
    public ContentVersion file1 {get;set;}
    public ContentVersion file2 {get;set;}
    public ContentVersion file3 {get;set;}
    public ContentVersion file4 {get;set;}
    public ContentVersion file5 {get;set;}
    public ContentVersion file6 {get;set;}
    public ContentVersion file7 {get;set;}
    public ContentVersion file8 {get;set;}
    public ContentVersion file9 {get;set;}
    
    public List<SelectOption> orgUnitsOptions {get; private set;}
    
    // workaround to solve deployment issue
    public List<FileWrapper> files {get;set;}
    // workaround to solve deployment issue
        
    private Boolean alreadeyInitiated = false; 

    /*************CONSTRUTOR**********************************/
    public Service_UploadFile() {
        //initService();
        alreadeyInitiated = false;
        distributorName = '';
        availableUntilText = '';
        isError = false;
    }
   
    /*************METHODS**********************************/
    private void initService(){
    	if(
    		(folderId != null && distributorId != null && distributorName != null && organizationalHierarchyId != null && organizationalHierarchyName != null && !alreadeyInitiated)
    	){
    		folderIdTmp = folderId;
    		distributorIdTmp = distributorId;
    		organizationalHierarchyIdTmp = organizationalHierarchyId;
	    	initOrgUnitsList();
	    	initDestinations();
	    	initFilesList();
	    	organizationalHierarchyIdSelected = organizationalHierarchyId;
	    	distributorIdSelected = distributorId;
	    	if(availableUntil != null){
	    		availableUntilText = availableUntil.format();
	    	} else {
	    		availableUntilText = 'mm/dd/yyyy';
	    	}
	    	alreadeyInitiated = true;
    	}
    }
    
    private void initFilesList(){
        files = new List<FileWrapper>();
        file0 = new ContentVersion();
        file1 = new ContentVersion();
        file2 = new ContentVersion();
        file3 = new ContentVersion();
        file4 = new ContentVersion();
        file5 = new ContentVersion();
        file6 = new ContentVersion();
        file7 = new ContentVersion();
        file8 = new ContentVersion();
        file9 = new ContentVersion();
        fileIndexes = '0,';
    }
    
    private void initDestinations(){
        if(!alreadeyInitiated){
	        destinations = new List<Destination>();
	        String fname = '';
	        try{
	        	fname = [select Name from Folder__c where id = :folderId].Name;
	        } catch(Exception ex){}
	        destinations.add(new Destination(organizationalHierarchyId, organizationalHierarchyName, DistributorId, distributorName, folderId, fname));
	        for(Integer i = 0; i<9; i++){
	            destinations.add(new Destination());
	        }
	        destinationIndexes = '0,';
        }
    }
    
    private void initOrgUnitsList(){
        List<id> ouIds = Service_Api.searchOrganizationalUnitIds(Service_API.getAIDs());
        orgUnitsOptions = new List<SelectOption>();
        if(orgUnits == null){
        	orgUnits = [select Id, Name, Parent__c from Organizational_Unit__c where id in :ouIds and type__c = :Service_API.getSectionTheme()];
        }
        //construct upper-most ous
        Set<Id> ids = new Set<Id>();
        Set<id> uppermost = new Set<Id>();
        for(Organizational_Unit__c ou : orgUnits){
            ids.add(ou.id);
            uppermost.add(ou.id);
        }
        Map<Id, List<Organizational_Unit__c>> orgUnitHierarchy = new Map<Id, List<Organizational_Unit__c>>();
        for(Organizational_Unit__c ou : orgUnits){
            if(ou.Parent__c != null && ids.contains(ou.Parent__c)){
                uppermost.remove(ou.id);
                List<Organizational_Unit__c> children = orgUnitHierarchy.get(ou.Parent__c);
                children = (children == null) ? (new List<Organizational_Unit__c>()) : (children);
                children.add(ou);
                orgUnitHierarchy.put(ou.Parent__c, children);
            }
        }
        //reccursion towards leaves
        for(Organizational_Unit__c ou : orgUnits){
            if(uppermost.contains(ou.id)){
                orgUnitsOptions.add(new SelectOption(ou.id, ou.Name));
                orgUnitsOptions.addAll(findOUsChildren(ou, orgUnitHierarchy, ou.Name));
            }
        }
    }
    
    private List<SelectOption> findOUsChildren(Organizational_Unit__c parent, Map<Id, List<Organizational_Unit__c>> orgUnitHierarchy, String currName){
        List<SelectOption> options = new List<SelectOption>();
        if(orgUnitHierarchy.get(parent.id)!=null){
            for(Organizational_Unit__c ou : orgUnitHierarchy.get(parent.id)){
                String name = currName+' - '+ou.Name;
                options.add(new SelectOption(ou.id, name));
                options.addAll(findOUsChildren(ou, orgUnitHierarchy, name));
            }
        }
        return options;
    }
    
    public List<SelectOption> getDistributorsForOrgUnit(){
    	if(organizationalHierarchyId != null){
    		List<SelectOption> distributors = new List<SelectOption>();
    	    List<Account> accounts = getDistributorsForOrgUnit(organizationalHierarchyId);
    	    for(Account account : accounts){
            	distributors.add(new SelectOption(account.id, account.name));
        	}
    		return distributors;
    
    	} else { 
    		return new List<SelectOption>();
    	}
    }
    
    global static List<Account> getDistributorsForOrgUnit(Id orgId){
        List<Account> distributors = new List<Account>();
        
        String currentTheme = Service_API.getSectionTheme();
        
        String ids = ''; String glue = '';
        for(Id id : Service_API.getAIDs()){
            ids += glue + '\''+id+'\'';
            glue = ',';
        }
        
        String query = 'select id, Name from Account where Id in ('+ids+') and '+currentTheme+'_Hierarchy__c = \''+orgId+'\'';
        List<Account> accounts = database.query(query);
        for(Account account : accounts){
            distributors.add(account);
        }
        return distributors;
    }
    
    public List<HierarchicalOption> getFoldersOptions(){
        return getFoldersOptions(organizationalHierarchyId, DistributorId,isInternal);
    }

    global static String getFoldersMergedLocations(String folderIdsToMarge){
        String resultString = '';
        try{
	        List<String> fList = (folderIdsToMarge!=null&&folderIdsToMarge!='') ? folderIdsToMarge.split(',') : new List<String>();
	        Set<String> fSet = new Set<String>(fList);
	        if(fSet.size() != 0){
	        	Set<String> fSetValid = new Set<String>(fList);
		        for(String fIdToMarge : fSet){
		            if(fIdToMarge != null && fIdToMarge !=''){
						fSetValid.add(fIdToMarge);
		            }
		        }
		        if(fSetValid.size() != 0){
		        	List<Folder__c> fs = [select id, name from Folder__c where id in :fSetValid order by name];
		        	String gluef = '';
		        	for(Folder__c f : fs){
		        		resultString += gluef + f.name;
		        		gluef = ',';
		        	}
		        }
	        }
        } catch(Exception ex) {
            return '';
        }
        return resultString;
    }
    
    global static List<HierarchicalOption> getFoldersOptions(String orgUnitId, String distributorId, Boolean isInternal){
        List<HierarchicalOption> foldersOptions = new List<HierarchicalOption>();
        try{
            List<Folder__c> folders = Service_API.getDocumentFolders(Constant.COLLABORATION, orgUnitId, isInternal, distributorId);
            Map<Id, List<Folder__c>> children = new Map<Id, List<Folder__c>>();
            Map<Id, HierarchicalOption> foldersMap = new Map<Id, HierarchicalOption>();
            Map<Id, Folder__c> foldersIdsMap = new Map<Id, Folder__c>();
            Set<Id> mainFolders = new Set<Id>();
            Set<Id> allIds = new Set<Id>();
            for(Folder__c folder : folders){
                if(!folder.Allow_File_Upload__c)
                    continue;
                allIds.add(folder.id);
                foldersIdsMap.put(folder.id, folder);
            }
            for(Folder__c folder : folders){
                if(!folder.Allow_File_Upload__c)
                    continue;
                Id parId;
                if(allIds.contains(folder.Parent_Folder__c)){
                    parId = folder.Parent_Folder__c;
                } else {
                    parId = null;
                    mainFolders.add(folder.id);
                }
                List<Folder__c> childrenList = children.get(folder.Parent_Folder__c);
                childrenList = (childrenList == null) ? (new List<Folder__c>()) : childrenList;
                childrenList.add(folder);
                children.put(folder.Parent_Folder__c, childrenList);
            }
            
            for(Id folderid : mainFolders){
                folderTreeConstruct(folderId, null, foldersIdsMap, foldersMap, children);
            }
            foldersOptions = foldersMap.values();
        } catch(Exception ex) {
            return new List<HierarchicalOption>();
        }
        return foldersOptions;
    }
    
    global static void folderTreeConstruct(Id folderid, Id parentId, Map<Id, Folder__c> foldersIdsMap, Map<Id, HierarchicalOption> folderMap, Map<Id, List<Folder__c>> children){
        HierarchicalOption ckeckbox = new HierarchicalOption(folderid, foldersIdsMap.get(folderid).Name);
        if(parentId != null && folderMap.get(parentId)!=null){
            folderMap.get(parentId).addKid(ckeckbox);
        } else {
            folderMap.put(folderid, ckeckbox);
        }
        if(folderid!=null && children.get(folderid)!=null){
            for(Folder__c f : children.get(folderid)){
                folderTreeConstruct(f.id, folderid, foldersIdsMap, folderMap, children);
            }
        }
    }
    
    private List<Destination> selectedDestinations(){
        List<String> indsls = (destinationIndexes!=null&&destinationIndexes!='') ? destinationIndexes.split(',') : new List<String>();
        Set<String> inds = new Set<String>(indsls);
        List<Destination> toReturn = new List<Destination>();
        Integer i = 0;
        for(Destination destination : destinations){
            if(inds.contains(String.valueof(i))){
				destination.foldersIds = destination.foldersIds.replace(',,', ',');
				destination.foldersNames = destination.foldersNames.replace(',,', ',');
                toReturn.add(destination);
            }
            i++;
        }
        return toReturn;
    }

    public PageReference upload() {
        Savepoint sp = database.setSavepoint();

	    try{
	    	if( availableUntilText != null && availableUntilText != '' && availableUntilText != 'mm/dd/yyyy'){
	    		availableUntil = date.parse(availableUntilText);
	    	} else {
	    		availableUntil = null;
	    	}
	    } catch (Exception ex) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Invalid date format.'));
            isError = true;
            database.rollback(sp);
            initFilesList();
            return null;
        }
        try{
            ContentWorkspace CW = [SELECT DefaultRecordTypeId, Id FROM ContentWorkspace WHERE Name='Collaboration'];
            map<String, File__c> fileObjects = new map<String, File__c>();
                        
            List<Destination> selectedDestinations = selectedDestinations();
            if(selectedDestinations.size()==0){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Select at least one folder.'));
                isError = true;
				initFilesList();
                return null;
            }
            String currentSiteTheme = Service_API.getSectionTheme();
            set<string> foldersNamesUniqueSet = new set<String>();
           	set<string> foldersIdsUniqueSet = new set<String>();
            set<string> orgUnitIdUniqueSet = new set<String>();
            set<string> orgUnitNameUniqueSet = new set<String>();
            set<string> distributorIdUniqueSet = new set<String>();
            set<string> distributorNameUniqueSet = new set<String>();

            string foldersNamesUniqueString = '';
           	string foldersIdsUniqueString = '';
            string orgUnitIdUniqueString = '';
            string orgUnitNameUniqueString = '';
            string distributorIdUniqueString = '';
            string distributorNameUniqueString = '';
            
            for(Destination destination : selectedDestinations){
            	if(destination.distributorId == null || destination.distributorId == '' || destination.foldersIds == null  || destination.foldersIds == ''){
	              	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Missing destination.'));
	                isError = true;
					initFilesList();
                    return null;
                }
                foldersIdsUniqueSet.addAll(destination.foldersIdsUnique());
				foldersNamesUniqueSet.addAll(destination.foldersNamesUnique());
                orgUnitIdUniqueSet.add(destination.orgUnitId);
                orgUnitNameUniqueSet.add(destination.orgUnitName);
                distributorIdUniqueSet.add(destination.distributorId);
                distributorNameUniqueSet.add(destination.distributorName);
            }

			foldersIdsUniqueString       = SetToString(foldersIdsUniqueSet);
            foldersNamesUniqueString	 = SetToString(foldersNamesUniqueSet);
            orgUnitIdUniqueString        = SetToString(orgUnitIdUniqueSet);
            orgUnitNameUniqueString      = SetToString(orgUnitNameUniqueSet);
            distributorIdUniqueString    = SetToString(distributorIdUniqueSet);
            distributorNameUniqueString  = SetToString(distributorNameUniqueSet);
 
            // process file data
        	List<String> fileIndexesList = (fileIndexes!=null&&fileIndexes!='') ? fileIndexes.split(',') : new List<String>();
        	Set<String> fileIndexesSet = new Set<String>(fileIndexesList);
        	            
            if(fileIndexesSet.size()==0){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Select at least one file.'));
                isError = true;
				initFilesList();
                return null;
            }
   
   			if(fileIndexesSet.contains('0')){
                if(file0.PathOnClient == null){
                	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Missing file.'));
                    isError = true;
            		initFilesList();
                    return null;
                }
                
                file0.RecordTypeId = CW.DefaultRecordTypeId;
                file0.title = file0.PathOnClient;
                file0.FirstPublishLocationId = CW.Id;
                file0.Classification__c = currentSiteTheme;

                File__c fileObject = new File__c(
                        Content_ID__c         = 'dummy value',
                        Content_Version_ID__c = 'dummy value',
                        folders__c            = foldersIdsUniqueString,
                        folder_names__c		  = foldersNamesUniqueString,
                        OrgUnits__c           = orgUnitIdUniqueString,
                        OrgUnitsNames__c      = orgUnitNameUniqueString,
                        Distributors__c       = distributorIdUniqueString,
                        Distributor_Names__c  = distributorNameUniqueString,
                        Available_Until__c    = availableUntil
                );
                fileObjects.put('0',fileObject);
            }
                
   			if(fileIndexesSet.contains('1')){
                if(file1.PathOnClient == null){
                	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Missing file.'));
                    isError = true;
            		initFilesList();
                    return null;
                }
                
                file1.RecordTypeId = CW.DefaultRecordTypeId;
                file1.title = file1.PathOnClient;
                file1.FirstPublishLocationId = CW.Id;
                file1.Classification__c = currentSiteTheme;

                File__c fileObject = new File__c(
                        Content_ID__c         = 'dummy value',
                        Content_Version_ID__c = 'dummy value',
                        folders__c            = foldersIdsUniqueString,
                        folder_names__c		  = foldersNamesUniqueString,
                        OrgUnits__c           = orgUnitIdUniqueString,
                        OrgUnitsNames__c      = orgUnitNameUniqueString,
                        Distributors__c       = distributorIdUniqueString,
                        Distributor_Names__c  = distributorNameUniqueString,
                        Available_Until__c    = availableUntil
                );
                fileObjects.put('1',fileObject);
            }
            
   			if(fileIndexesSet.contains('2')){
                if(file2.PathOnClient == null){
                	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Missing file.'));
                    isError = true;
            		initFilesList();
                    return null;
                }
                
                file2.RecordTypeId = CW.DefaultRecordTypeId;
                file2.title = file2.PathOnClient;
                file2.FirstPublishLocationId = CW.Id;
                file2.Classification__c = currentSiteTheme;

                File__c fileObject = new File__c(
                        Content_ID__c         = 'dummy value',
                        Content_Version_ID__c = 'dummy value',
                        folders__c            = foldersIdsUniqueString,
                        folder_names__c		  = foldersNamesUniqueString,
                        OrgUnits__c           = orgUnitIdUniqueString,
                        OrgUnitsNames__c      = orgUnitNameUniqueString,
                        Distributors__c       = distributorIdUniqueString,
                        Distributor_Names__c  = distributorNameUniqueString,
                        Available_Until__c    = availableUntil
                );
                fileObjects.put('2',fileObject);
            }
            
   			if(fileIndexesSet.contains('3')){
                if(file3.PathOnClient == null){
                	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Missing file.'));
                    isError = true;
            		initFilesList();
                    return null;
                }
                
                file3.RecordTypeId = CW.DefaultRecordTypeId;
                file3.title = file3.PathOnClient;
                file3.FirstPublishLocationId = CW.Id;
                file3.Classification__c = currentSiteTheme;

                File__c fileObject = new File__c(
                        Content_ID__c         = 'dummy value',
                        Content_Version_ID__c = 'dummy value',
                        folders__c            = foldersIdsUniqueString,
                        folder_names__c		  = foldersNamesUniqueString,
                        OrgUnits__c           = orgUnitIdUniqueString,
                        OrgUnitsNames__c      = orgUnitNameUniqueString,
                        Distributors__c       = distributorIdUniqueString,
                        Distributor_Names__c  = distributorNameUniqueString,
                        Available_Until__c    = availableUntil
                );
                fileObjects.put('3',fileObject);
            }
            
   			if(fileIndexesSet.contains('4')){
                if(file4.PathOnClient == null){
                	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Missing file.'));
                    isError = true;
            		initFilesList();
                    return null;
                }
                
                file4.RecordTypeId = CW.DefaultRecordTypeId;
                file4.title = file4.PathOnClient;
                file4.FirstPublishLocationId = CW.Id;
                file4.Classification__c = currentSiteTheme;

                File__c fileObject = new File__c(
                        Content_ID__c         = 'dummy value',
                        Content_Version_ID__c = 'dummy value',
                        folders__c            = foldersIdsUniqueString,
                        folder_names__c		  = foldersNamesUniqueString,
                        OrgUnits__c           = orgUnitIdUniqueString,
                        OrgUnitsNames__c      = orgUnitNameUniqueString,
                        Distributors__c       = distributorIdUniqueString,
                        Distributor_Names__c  = distributorNameUniqueString,
                        Available_Until__c    = availableUntil
                );
                fileObjects.put('4',fileObject);
            }
            
   			if(fileIndexesSet.contains('5')){
                if(file5.PathOnClient == null){
                	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Missing file.'));
                    isError = true;
            		initFilesList();
                    return null;
                }
                
                file5.RecordTypeId = CW.DefaultRecordTypeId;
                file5.title = file5.PathOnClient;
                file5.FirstPublishLocationId = CW.Id;
                file5.Classification__c = currentSiteTheme;

                File__c fileObject = new File__c(
                        Content_ID__c         = 'dummy value',
                        Content_Version_ID__c = 'dummy value',
                        folders__c            = foldersIdsUniqueString,
                        folder_names__c		  = foldersNamesUniqueString,
                        OrgUnits__c           = orgUnitIdUniqueString,
                        OrgUnitsNames__c      = orgUnitNameUniqueString,
                        Distributors__c       = distributorIdUniqueString,
                        Distributor_Names__c  = distributorNameUniqueString,
                        Available_Until__c    = availableUntil
                );
                fileObjects.put('5',fileObject);
            }
            
   			if(fileIndexesSet.contains('6')){
                if(file6.PathOnClient == null){
                	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Missing file.'));
                    isError = true;
            		initFilesList();
                    return null;
                }
                
                file6.RecordTypeId = CW.DefaultRecordTypeId;
                file6.title = file6.PathOnClient;
                file6.FirstPublishLocationId = CW.Id;
                file6.Classification__c = currentSiteTheme;

                File__c fileObject = new File__c(
                        Content_ID__c         = 'dummy value',
                        Content_Version_ID__c = 'dummy value',
                        folders__c            = foldersIdsUniqueString,
                        folder_names__c		  = foldersNamesUniqueString,
                        OrgUnits__c           = orgUnitIdUniqueString,
                        OrgUnitsNames__c      = orgUnitNameUniqueString,
                        Distributors__c       = distributorIdUniqueString,
                        Distributor_Names__c  = distributorNameUniqueString,
                        Available_Until__c    = availableUntil
                );
                fileObjects.put('6',fileObject);
            }
            
   			if(fileIndexesSet.contains('7')){
                if(file7.PathOnClient == null){
                	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Missing file.'));
                    isError = true;
            		initFilesList();
                    return null;
                }
                
                file7.RecordTypeId = CW.DefaultRecordTypeId;
                file7.title = file7.PathOnClient;
                file7.FirstPublishLocationId = CW.Id;
                file7.Classification__c = currentSiteTheme;

                File__c fileObject = new File__c(
                        Content_ID__c         = 'dummy value',
                        Content_Version_ID__c = 'dummy value',
                        folders__c            = foldersIdsUniqueString,
                        folder_names__c		  = foldersNamesUniqueString,
                        OrgUnits__c           = orgUnitIdUniqueString,
                        OrgUnitsNames__c      = orgUnitNameUniqueString,
                        Distributors__c       = distributorIdUniqueString,
                        Distributor_Names__c  = distributorNameUniqueString,
                        Available_Until__c    = availableUntil
                );
                fileObjects.put('7',fileObject);
            }
            
   			if(fileIndexesSet.contains('8')){
                if(file8.PathOnClient == null){
                	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Missing file.'));
                    isError = true;
            		initFilesList();
                    return null;
                }
                
                file8.RecordTypeId = CW.DefaultRecordTypeId;
                file8.title = file8.PathOnClient;
                file8.FirstPublishLocationId = CW.Id;
                file8.Classification__c = currentSiteTheme;

                File__c fileObject = new File__c(
                        Content_ID__c         = 'dummy value',
                        Content_Version_ID__c = 'dummy value',
                        folders__c            = foldersIdsUniqueString,
                        folder_names__c		  = foldersNamesUniqueString,
                        OrgUnits__c           = orgUnitIdUniqueString,
                        OrgUnitsNames__c      = orgUnitNameUniqueString,
                        Distributors__c       = distributorIdUniqueString,
                        Distributor_Names__c  = distributorNameUniqueString,
                        Available_Until__c    = availableUntil
                );
                fileObjects.put('8',fileObject);
            }
            
   			if(fileIndexesSet.contains('9')){
                if(file9.PathOnClient == null){
                	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Missing file.'));
                    isError = true;
            		initFilesList();
                    return null;
                }
                
                file9.RecordTypeId = CW.DefaultRecordTypeId;
                file9.title = file9.PathOnClient;
                file9.FirstPublishLocationId = CW.Id;
                file9.Classification__c = currentSiteTheme;

                File__c fileObject = new File__c(
                        Content_ID__c         = 'dummy value',
                        Content_Version_ID__c = 'dummy value',
                        folders__c            = foldersIdsUniqueString,
                        folder_names__c		  = foldersNamesUniqueString,
                        OrgUnits__c           = orgUnitIdUniqueString,
                        OrgUnitsNames__c      = orgUnitNameUniqueString,
                        Distributors__c       = distributorIdUniqueString,
                        Distributor_Names__c  = distributorNameUniqueString,
                        Available_Until__c    = availableUntil
                );
                fileObjects.put('9',fileObject);
            }

			if(fileObjects.values().size() == 0){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Missing file.'));
                isError = true;
            	initFilesList();
                return null;
			}

            TriggerFile.disabled = true;
            insert fileObjects.values();
            TriggerFile.disabled = false;
        
        	if(fileIndexesSet.contains('0')){
				File__c fileObject = fileObjects.get('0');
                file0.File__c = fileObject.Id;
        		insert file0;
        	}
        	if(fileIndexesSet.contains('1')){
				File__c fileObject = fileObjects.get('1');
                file1.File__c = fileObject.Id;
        		insert file1;
        	}        
        	if(fileIndexesSet.contains('2')){
				File__c fileObject = fileObjects.get('2');
                file2.File__c = fileObject.Id;
        		insert file2;
        	}        
        	if(fileIndexesSet.contains('3')){
				File__c fileObject = fileObjects.get('3');
                file3.File__c = fileObject.Id;
        		insert file3;
        	}        
        	if(fileIndexesSet.contains('4')){
				File__c fileObject = fileObjects.get('4');
                file4.File__c = fileObject.Id;
        		insert file4;
        	}        
        	if(fileIndexesSet.contains('5')){
				File__c fileObject = fileObjects.get('5');
                file5.File__c = fileObject.Id;
        		insert file5;
        	}        
        	if(fileIndexesSet.contains('6')){
				File__c fileObject = fileObjects.get('6');
                file6.File__c = fileObject.Id;
        		insert file6;
        	}        
        	if(fileIndexesSet.contains('7')){
				File__c fileObject = fileObjects.get('7');
                file7.File__c = fileObject.Id;
        		insert file7;
        	}        
        	if(fileIndexesSet.contains('8')){
				File__c fileObject = fileObjects.get('8');
                file8.File__c = fileObject.Id;
        		insert file8;
        	}        
        	if(fileIndexesSet.contains('9')){
				File__c fileObject = fileObjects.get('9');
                file9.File__c = fileObject.Id;
        		insert file9;
        	}        
	        
	        //refresh & align
            Set<Id> fids = new Set<Id>();
            
            if(fileIndexesSet.contains('0')){
            	fids.add(file0.id);
            }
            if(fileIndexesSet.contains('1')){
            	fids.add(file1.id);
            }
            if(fileIndexesSet.contains('2')){
            	fids.add(file2.id);
            }
            if(fileIndexesSet.contains('3')){
            	fids.add(file3.id);
            }
            if(fileIndexesSet.contains('4')){
            	fids.add(file4.id);
            }
            if(fileIndexesSet.contains('5')){
            	fids.add(file5.id);
            }
            if(fileIndexesSet.contains('6')){
            	fids.add(file6.id);
            }
            if(fileIndexesSet.contains('7')){
            	fids.add(file7.id);
            }
            if(fileIndexesSet.contains('8')){
            	fids.add(file8.id);
            }
            if(fileIndexesSet.contains('9')){
            	fids.add(file9.id);
            }

			initFilesList();
            
            // normal processing
            List<ContentVersion> filesRefreshed = [SELECT Id, ContentDocumentId, Title, Description, filetype, contentSize, RecordTypeId, File__c FROM ContentVersion WHERE Id in :fids];
            List<File__c> refreshFiles = new List<File__c>();
            List<Folder_Comment__c> comments = new List<Folder_Comment__c>();
            for(ContentVersion cv : filesRefreshed){
                refreshFiles.add( new File__c(
                	id = cv.File__c,
	                Content_ID__c         = cv.ContentDocumentId,
	                Content_Version_ID__c = cv.Id,
	                title__c              = cv.Title,
	                Description__c        = cv.Description,
	                filetype__c           = cv.filetype,
	                filesize__c           = TriggerContentVersion.convertFileSize(cv.contentSize),
	                Page_Section__c       = 'Collaboration',
	                Classification__c     = currentSiteTheme
                ));
                if((comment != null || comment != '') && (comment.length() < 999 && comment.length() > 0)){
                	for(String distributorId : distributorIdUniqueSet){
	                	for(String folderId : foldersIdsUniqueSet){
		                    Folder_Comment__c fcomment = new Folder_Comment__c();
		                    fcomment.Comment_Body__c = comment;
		                    fcomment.Distributor_Name__c = Service_API.getAID();
		                    fcomment.Distributor_Access__c = distributorId;
		                    fcomment.folder__c = folderId;
		                    fcomment.file__c = cv.File__c;
		                    fcomment.Classification__c = currentSiteTheme;
		                    comments.add(fcomment);
	                	}                		
                	}
                }
            }
            
            TriggerFile.disabled = true;
            update refreshFiles;
            TriggerFile.disabled = false;
            if(comments!=null && !comments.isEmpty()){
            	insert comments;
            }
            alreadeyInitiated = false;
            initService();
            PageReference pr =  new PageReference(afterUploadRedirectTo+'&afterupload=true');
            pr.setRedirect(true);
            return pr;
        }
        catch (Exception ex) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to upload files. Please re-select Your files again.'));
            isError = true;
            database.rollback(sp);
			initFilesList();
            return null;
        }
    }
    
	public String SetToString(Set<String> valueList){
    	String result = '';
    	String glue = '';
		for (String value : valueList) {         
			result += glue + value;
			glue = ';';
		}    	
    	return result;
    }
}