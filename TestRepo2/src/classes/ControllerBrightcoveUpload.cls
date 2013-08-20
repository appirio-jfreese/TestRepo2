public with sharing class ControllerBrightcoveUpload {
	public ContentVersion contentVer {get;set;}
	public String videoId {get;set;}
	public String videoDesc{get;set;}
	public List<selectOption> libsOptions {get;set;}
	public Id selectedLibrary {get;set;}
	
	public ControllerBrightcoveUpload(){
		
		contentVer = new ContentVersion();
		contentVer.ContentUrl = 'a';
				
		
		libsOptions = getLibraries(); 
	}	
	
	public List<selectOption> getLibraries()
    {
    	List<SelectOption> options = new List<SelectOption>();          
		List<ContentWorkspace> libraries = [Select c.Name, c.Id From ContentWorkspace c];
        for(ContentWorkspace lib: libraries){
            options.add(new SelectOption(lib.Id, lib.Name));
        }
        return options;
    }
	
	
	public PageReference submit(){
		
		contentVer.Description = videoDesc;
		Id RecordTyId = [Select c.DefaultRecordTypeId From ContentWorkspace c Where c.Id = :selectedLibrary].DefaultRecordTypeId;		
		contentVer.RecordTypeId = RecordTyId;
		
		insert contentVer;		
		
		ContentWorkspaceDoc contentWorkDoc = new ContentWorkspaceDoc();
			contentWorkDoc.ContentWorkspaceId = selectedLibrary;
			contentWorkDoc.ContentDocumentId  = [Select c.ContentDocumentId, c.Title From ContentVersion c Where c.Id = :contentVer.id].ContentDocumentId;
		
		insert contentWorkDoc;
		
		contentVer = [Select c.File__c, c.Title, c.Content_Description__c From ContentVersion c Where c.Id = :contentVer.id];
		
		if(contentVer.File__c != NULL){
			File__c fileN = new File__c(id=contentVer.File__c);
			fileN.Is_Video__c  = true;
			fileN.Video_Id__c = videoId;
			fileN.FileType__c = 'Video';			 
			update(fileN);			
			
			PageReference pr = new PageReference('/'+ fileN.id);
    		pr.setRedirect(true);
    		return pr;
		}else if(contentVer.Content_Description__c != NULL){
			Content_Description__c conDe = new Content_Description__c(id=contentVer.Content_Description__c);
			conDe.Is_Video__c = true;
			conDe.Video_Id__c = videoId;
			conDe.FileType__c = 'Video';			
			update(conDe);
			
			PageReference pr = new PageReference('/'+ conDe.id);
    		pr.setRedirect(true);
    		return pr;			
		}
	
		
		ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to add video'));
        return null; 
	}
}