/*****************************************************************************************************************
Name        : Service_EditFile.cls

Updated By  : Jonathan Freese (Appirio)   
Date        : 6/19/13
Story/Task  : US604/TA1000

Updated By  : Basant Verma (AppirioOffShore)   
Date        : 6/20/13
Story/Task  : (after the pop up window closes, 
							User should remain on the same page they were already on 
							when they started to edit)

*******************************************************************************************************************/

public without sharing class Service_EditFile {
	
	public ContentVersion file {get;set;}
	public String availableUntil {get;set;}
	public Id folderId {get;set;}
    public Id distributorId {get;set;}
    public String distributorName {get;set;}
    public Id organizationalHierarchyId {get;set;}
	public String organizationalHierarchyName {get; set;}
	public String afterUploadRedirectTo {get;set;}
	public String commentBody {get;set;}
	
	public String description {get;set{
			description = value;
			file.Description = value;
		}
	}
	public String pathOnClient {get;set;}
	public String folderName {get;set;} 
	private Boolean commentExists;
	private Folder_Comment__c fcomment;
	
	private Boolean fileIdSetted = false;
	public Boolean allowComments = true;
	
	
    public Service_EditFile() {
        distributorName = '';
    }

	public Id fileId{
		get;
		set{
			if(fileIdSetted)
				return;
			fileIdSetted = true;
			this.file = new ContentVersion(id = value);
			this.fileId = value;
			try{
				file = [select Title, Description, File__r.Available_Until__c, File__c, Id, Content_Description__c, ContentDocumentId from ContentVersion where id = :value limit 1];
				availableUntil = String.valueof(file.File__r.Available_Until__c);
				description = file.Description;
			} catch(Exception ex) {}
			if(value == null){
				fileIdSetted = false;
			}
		}
	}
	
	public PageReference saveFile(){
		try{
			file.description = description;
			update file;
			if(allowComments && commentBody != ''){
				fcomment = new Folder_Comment__c();
				fcomment.Comment_Body__c = commentBody;
				fcomment.Distributor_Name__c = Service_API.getAID();
				fcomment.Distributor_Access__c = DistributorId;
				fcomment.folder__c = folderId;
				fcomment.file__c = file.File__c;
				fcomment.Classification__c = Service_API.getSectionTheme();
				insert fcomment;
			} else if(!allowComments && commentBody != ''){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Cannot add comments on search page.'));
			}
		} catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Unable to save changes.'));
			clear();
			return null;
		}
		return clear();
	}
	
	
	public PageReference replaceFile(){
		try{
			if(file.PathOnClient == null) {
	        	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Too large file'));
	            return null;
	    	} else {
	    		ContentWorkspace CW = [SELECT DefaultRecordTypeId, Id FROM ContentWorkspace WHERE Name='Collaboration'];
	    		// Start : Changes for TA1000 - Jonathan Freese
	    		ContentVersion cv = new ContentVersion(File__c = file.File__c, RecordTypeId = CW.DefaultRecordTypeId, Title = file.PathOnClient, ReasonForChange = 'replace (' + description + ')', description = description, ContentDocumentID = file.ContentDocumentID, PathOnClient = file.PathOnClient, VersionData = file.VersionData);
	    		// End : Changes for TA1000 - Jonathan Freese
	    		insert cv;
	    		if(organizationalHierarchyId==null || DistributorId==null || folderId==null){
	    			File__c f = new File__c(id 					  			= file.File__c,
	                    					Content_Version_Id__c 			= cv.id,
	                    					Content_ID__c  		  			= cv.ContentDocumentId,
	                    					title__c 			 			= cv.Title,
	                    					filetype__c           			= cv.filetype,
	                    					filesize__c          			= TriggerContentVersion.convertFileSize(file.contentSize),
	                						Page_Section__c     		 	= 'Collaboration');
	    			update f;
	    		} else {
		    		File__c f = new File__c(folders__c            			= folderId,
							                OrgUnits__c           			= organizationalHierarchyId,
							                OrgUnitsNames__c      			= organizationalHierarchyName,
						                    Distributors__c       			= DistributorId,
	                						Distributor_Names__c 			= distributorName,
	                    					id 					  			= file.File__c,
	                    					Content_Version_Id__c 			= cv.id,
	                    					Content_ID__c  		  			= cv.ContentDocumentId,
	                    					title__c 			 			= cv.Title,
	                    					filetype__c           			= cv.filetype,
	                    					filesize__c          			= TriggerContentVersion.convertFileSize(file.contentSize),
	                						Page_Section__c      			= 'Collaboration');
		    		update f;
	    		}
	    		cv.description = description;
	    		update cv;
	    		if(allowComments && commentBody != ''){
					fcomment = new Folder_Comment__c();
					fcomment.Comment_Body__c = commentBody;
					fcomment.Distributor_Name__c = Service_API.getAID();
					fcomment.Distributor_Access__c = DistributorId;
					fcomment.folder__c = folderId;
					fcomment.file__c = cv.File__c;
					insert fcomment;
				} else if(!allowComments && commentBody != ''){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Cannot add comments on search page.'));
				}
			}
		} catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Unable to save changes.'));
			clear();
			return null;
		}
		return clear();
	}
	
	public PageReference clear(){
		fileIdSetted = false;
		// Start : Changes - Basant Verma (after the pop up window closes, User should remain on the same page they were already on when they started to edit)
		PageReference pr = ApexPages.currentPage();
		if(afterUploadRedirectTo != null && !afterUploadRedirectTo.trim().equals(''))
			pr = new Pagereference(afterUploadRedirectTo);
		// End : Changes - Basant Verma
		pr.setRedirect(true);
		return pr;
	}
	
	public PageReference deleteFile(){
		try{
			List<Folder_Comment__c> fc = [select Id from Folder_Comment__c where file__c = :file.File__c];
			delete fc;
			ContentDocument cd = [select Id from ContentDocument where Id = :file.ContentDocumentId];
			List<File__c> f = [select Id from File__c where Content_Version_Id__c = :file.id];
			delete cd;
			delete f;
		} catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Unable to delete file.'));
			clear();
			return null;
		}
		return clear();
	}
}