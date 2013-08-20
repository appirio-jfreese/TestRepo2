global public without sharing virtual class Controller_BaseRemote {
   
    
    public Controller_BaseRemote() {
                
    }
    
    public Controller_BaseRemote(Controller_Base controller ) {
            
    }
    
    @RemoteAction 
    global static String downloadVideoFromBC(String videoId) { 
        String url = '';
        if(videoId != null && videoId != ''){
            // get video url
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            String token = Service_API.getSetting('brightcovetoken');
            if(token != '' && token != null){               
                req.setEndpoint('http://api.brightcove.com/services/library?command=find_video_by_id&video_id='+videoId+'&video_fields=FLVURL&media_delivery=http&token='+token);
                req.setMethod('GET');
                HttpResponse res = h.send(req);         
                String responseString = res.getBody();
                if(responseString != null && responseString != ''){
                    JSONParser parser = JSON.createParser(responseString);
                    parser.nextToken();
                    parser.nextValue();
                    url = parser.getText();
                }
            }
        }
        return url;      
    }    
     
    @RemoteAction  
    global static void cacheDownload(String cvids) { 
    	try{
	        list<Download_cache__c> cache = new list<Download_cache__c>();
	        
	        
	        // get data about content
	        list<String> cvidList = cvids.split(',');
	        
	        if(cvidList.size()>0) {
	            if(cvidList.get(0)==null || cvidList.get(0)=='') {
	                cvidList.remove(0);
	            } else if(cvidList.get(cvidList.size()-1)==null || cvidList.get(cvidList.size()-1)=='') {
	                cvidList.remove(cvidList.size()-1);
	            }
	        }       
	
	        list<File__c> contentFiles = new list<File__c>();
	        list<Content_Description__c> contentDescriptions = new list<Content_Description__c>();
	        list<Content_Description__c> contentDescriptionsLow = new list<Content_Description__c>();
	            
	        if(cvidList.size() != 0){
	            Map<String,String> descrShareMap = new Map<String,String>();
	            
	            try{
	                contentDescriptions = [select Title__c, Content_Version_Id__c, Content_Version_Id_Low__c
	                                       from Content_Description__c
	                                       where Content_Version_Id__c in :cvidList];        
	            } catch (Exception e) {
	                contentDescriptions = new list<Content_Description__c>();
	            }
	
	            try{
	                contentDescriptionsLow = [select Title__c, Content_Version_Id__c, Content_Version_Id_Low__c
	                                       from Content_Description__c
	                                       where Content_Version_Id_Low__c in :cvidList];        
	            } catch (Exception e) {
	                contentDescriptionsLow = new list<Content_Description__c>();
	            }
	
	            try{
	                contentFiles = [select Title__c, Content_Version_Id__c
	                                from File__c
	                                where Content_Version_Id__c in :cvidList];        
	            } catch (Exception e) {
	                contentFiles = new list<File__c>();
	            }
	            
	            for(File__c content :  contentFiles){
	                if(content.Title__c != null && content.Title__c != '' && content.Content_Version_Id__c != null && content.Content_Version_Id__c != '' ){
	                    Download_cache__c cacheItem = new Download_cache__c();
	                    cacheItem.Content_Version_Id__c = content.Content_Version_Id__c;
	                    cacheItem.Content_Name__c = content.Title__c;
	                    cache.add(cacheItem);
	                }
	            }
	    
	            for(Content_Description__c content :  contentDescriptions){
	                if(content.Title__c != null && content.Title__c != '' && content.Content_Version_Id__c != null && content.Content_Version_Id__c != '' ){
	                    Download_cache__c cacheItem = new Download_cache__c();
	                    cacheItem.Content_Version_Id__c = content.Content_Version_Id__c;
	                    cacheItem.Content_Name__c = content.Title__c;
	                    cache.add(cacheItem);
	                }
	            }
	                        
	            for(Content_Description__c content :  contentDescriptionsLow){
	                if(content.Title__c != null && content.Title__c != '' && content.Content_Version_Id_Low__c != null && content.Content_Version_Id_Low__c != '' ){
	                    Download_cache__c cacheItem = new Download_cache__c();
	                    cacheItem.Content_Version_Id__c = content.Content_Version_Id_Low__c;
	                    cacheItem.Content_Name__c = content.Title__c;
	                    cache.add(cacheItem);
	                }
	            }           
	        }
	        
	        if(cache != null && cache.size() != 0){
	            insert cache;
	        }       
    	}catch(Exception ex){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Could not perform operation.'));
    	}
    } 
    
    @RemoteAction 
    global static set<User> getPossibleShareUsers(String searchFor, String selectedEmails) {
        set<User> result = new set<User>();
        
        // check is internal user
        Boolean isInternalUsrRemote = false;
        Profile[] profiles = [select Id from Profile where Name =: Constant.PROFILE_NAME_INTERNAL];
        if(profiles.size() > 0){
            isInternalUsrRemote = String.valueOf(UserInfo.getProfileId()).equals(profiles[0].Id);
        } 

        
        set<String> possibleUsersEmails = new set<String>();
        searchFor = '%'+searchFor+'%';
        
        //preapre list of already selected emails
        list<string> selectedEmailsList = selectedEmails.split(',');
        //trim emails
        list<string> selectedEmailsListTrim = new list<string>();
        for(String currentEmail : selectedEmailsList){
            if(currentEmail != null && currentEmail != '' && currentEmail.trim() != ''){
                selectedEmailsListTrim.add(currentEmail.trim());
            }
        }

        // get possible users
        list<User> possibleUsers = new list<User>();
        
        if(isInternalUsrRemote){
            //diageo user
            if(selectedEmailsList.size() != 0){
                // already selected
                possibleUsers = [select Contact.Email, FirstName, LastName from User where (Contact.Email like :searchFor or FirstName like :searchFor or LastName like :searchFor) and Contact.Email not in :selectedEmailsListTrim];          
            } else {
                //empty select -> first
                possibleUsers = [select Contact.Email, FirstName, LastName from User where (Contact.Email like :searchFor or FirstName like :searchFor or LastName like :searchFor) ];
            }
        } else {
            if(selectedEmailsList.size() != 0){
                // already selected
                possibleUsers = [select Contact.Email, FirstName, LastName from User where (Contact.Account.Id in :Service_API.getAIDs()) and (Contact.Email like :searchFor or FirstName like :searchFor or LastName like :searchFor) and Contact.Email not in :selectedEmailsListTrim];            
            } else {
                //empty select -> first
                possibleUsers = [select Contact.Email, FirstName, LastName from User where (Contact.Account.Id in :Service_API.getAIDs())  and (Contact.Email like :searchFor or FirstName like :searchFor or LastName like :searchFor) ];
            }
        }

        for(User usr : possibleUsers){
            if(!possibleUsersEmails.contains(usr.Contact.Email)){
                possibleUsersEmails.add(usr.Contact.Email);
                User pUser = new User();
                pUser.FirstName = usr.FirstName;
                pUser.LastName = usr.LastName;
                pUser.Email = usr.Contact.Email;
                if(pUser.Email != null && pUser.Email != ''){
                	result.add(pUser);
                }  
            }
        }
        
        // get users from user address book
        list<User_Address_Book__c> userAddressBook = [SELECT Email__c, First_Name__c, Last_Name__c FROM User_Address_Book__c where OwnerId = :Service_API.getUID() and (Email__c like :searchFor or First_Name__c like :searchFor or Last_Name__c like :searchFor) and Email__c not in :selectedEmailsListTrim and Email__c not in :possibleUsersEmails ];
        for(User_Address_Book__c addressBookItem : userAddressBook){
            if(!possibleUsersEmails.contains(addressBookItem.Email__c)){
                possibleUsersEmails.add(addressBookItem.Email__c);
                User pUser = new User();
                pUser.FirstName = addressBookItem.First_Name__c;
                pUser.LastName = addressBookItem.Last_Name__c;
                pUser.Email = addressBookItem.Email__c;
                if(pUser.Email != null && pUser.Email != ''){
                	result.add(pUser);
                }                 
            }
        }
        
        return result;
    }
    
   	global private class searchPILResponse {
    	public list<Brand__c> brands {get;set;}
    	public string bottlehtml {get;set;} 
    	public  Map<Id, String> brandValidNames {get;set;}
   	}
   	
    @RemoteAction 
    global static searchPILResponse searchPILBrand(String brandName) { 
    	searchPILResponse finalResponse = new searchPILResponse();
		Map<Id, String> brandValidNames = new Map<Id, String>();
		    	
        if(brandName != null && brandName != ''){
			finalResponse.brands = Service_API.getPILBrandsNewSearch(brandName);
			
			Integer bc = 0;
			String html = '';
        	Map<Id, String> bottleImgMap = new Map<Id, String>();
        	
			for(Brand__c brand : finalResponse.brands){
	            brandValidNames.put(brand.Id, brand.Name.replaceAll('[^a-zA-Z0-9]','_'));

	            if(brand.Core_Trademarks__c == true){
	                if(!bottleImgMap.containsKey(brand.id) && brand.Core_Trademarks_Logo__r.Content_Version_Id__c != '' && brand.Core_Trademarks_Logo__r.Content_Version_Id__c != null){
	                    bottleImgMap.put(brand.id, brand.Core_Trademarks_Logo__r.Content_Version_Id__c);
	                }
	            }
	            if(brand.reserve_brand__c == true){
	                if(!bottleImgMap.containsKey(brand.id) && brand.Reserve_Brand_Logo__r.Content_Version_Id__c != '' && brand.Reserve_Brand_Logo__r.Content_Version_Id__c != null){
	                    bottleImgMap.put(brand.id, brand.Reserve_Brand_Logo__r.Content_Version_Id__c);
	                }
	            }
	            if(brand.reserve_brand__c != true && brand.Core_Trademarks__c != true){
	                if(!bottleImgMap.containsKey(brand.id) && brand.Core_Trademarks_Logo__r.Content_Version_Id__c != '' && brand.Core_Trademarks_Logo__r.Content_Version_Id__c != null){
	                    bottleImgMap.put(brand.id, brand.Core_Trademarks_Logo__r.Content_Version_Id__c);
	                }
	                if(!bottleImgMap.containsKey(brand.id) && brand.Reserve_Brand_Logo__r.Content_Version_Id__c != '' && brand.Reserve_Brand_Logo__r.Content_Version_Id__c != null){
	                    bottleImgMap.put(brand.id, brand.Reserve_Brand_Logo__r.Content_Version_Id__c);
	                }
	            }


				if(bc == 0){
					html += '<div class="clear-float"></div>';
					html += '<div class="float-left alignBox" style="width: 10px;">&nbsp;</div>';											
				}
				html += '<div class="brand-box extra-bottle-margin" name="'+brandValidNames.get(brand.Id)+'" onclick="showContent(\''+brand.id+'\',null);showDialog(\'brandPageContent\', true);centerDialog();">';
            		if(!bottleImgMap.containsKey(brand.id)){
						html += '<img src="" class="brand-box-bottle dummyBottle"/><br/>';
            		} else {
            			html += '<img src="/sfc/servlet.shepherd/version/download/'+bottleImgMap.get(brand.Id)+'" class="brand-box-bottle"/><br/>';
            		}   
					html += '<div class="bottleShadow"></div>';
					html += '<div class="brand-box-description">'+brand.Name+'</div>';
				html += '</div>';
				bc = Math.mod(bc+1,10);
			}
			
			finalResponse.bottlehtml =  EncodingUtil.urlEncode(html, 'UTF-8');
			finalResponse.brandValidNames = brandValidNames;
        }
        
        return finalResponse;      
    }
    /*
    	Changes done by Jai Gupta [Appirio Jaipur]
    	Modified Date : Dec 11,2012
    	Related Case : #00003466 [Java script error when click on Upload file button]
    */
    /************* UPLOAD **********************************/
   global class HierarchicalOptionRemote {
        public String value {get;set;}
        public String label {get;set;}
        public String optionId {get;set;}
        public List<HierarchicalOptionRemote> children {get;set;}
        public HierarchicalOptionRemote(String optionId, String label){
            this.value = optionId;
            this.optionId = optionId;
            this.label = label;
            children = new List<HierarchicalOptionRemote>();
        }
        public void addKid(HierarchicalOptionRemote option){
            children.add(option);
        }
    }
    
    @RemoteAction
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
    
    @RemoteAction
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
    
    @RemoteAction
    global static List<HierarchicalOptionRemote> getFoldersOptions(String orgUnitId, String distributorId, Boolean isInternal){
        List<HierarchicalOptionRemote> foldersOptions = new List<HierarchicalOptionRemote>();
        try{
            List<Folder__c> folders = Service_API.getDocumentFolders(Constant.COLLABORATION, orgUnitId, isInternal, distributorId);
            Map<Id, List<Folder__c>> children = new Map<Id, List<Folder__c>>();
            Map<Id, HierarchicalOptionRemote> foldersMap = new Map<Id, HierarchicalOptionRemote>();
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
            return new List<HierarchicalOptionRemote>();
        }
        return foldersOptions;
    }
    
    global static void folderTreeConstruct(Id folderid, Id parentId, Map<Id, Folder__c> foldersIdsMap, Map<Id, HierarchicalOptionRemote> folderMap, Map<Id, List<Folder__c>> children){
        HierarchicalOptionRemote ckeckbox = new HierarchicalOptionRemote(folderid, foldersIdsMap.get(folderid).Name);
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
	/* End for case #00003466*/
}