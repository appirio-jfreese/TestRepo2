public global class TriggerContentVersion {
    public static boolean disabled = false;
	public static void updateContentDescriptionAndFileOnBeforeUpdate(map<id, ContentVersion> ContentVersionMap) {
		if (disabled) {
			return;
		}
        List<Content_Description__c> contentDescriptionAddList    = new List<Content_Description__c>();
        List<Content_Description__c> contentDescriptionUpdateList = new List<Content_Description__c>();        
     
        Set<Id> contentDescriptionAddSet = new Set<Id>();
        List<file__c> fileAddList    = new List<file__c>();
        List<file__c> fileUpdateList = new List<file__c>();
        map<String, ContentVersion> helper = new map<String, ContentVersion>(); 
        recordtype[] rts = [SELECT id, DeveloperName FROM recordtype where DeveloperName in :new list<string>{'Low_Resolution', 'Performance_Management', 'Collaboration', 'Planning', 'Multicultural'} AND SobjectType = 'ContentVersion'];
        Id lowResolutionRecordTypeId,performanceManagementRecordTypeId,collaborationRecordTypeId,planningRecordTypeId,multiculturalRecordTypeId;
        for(recordtype rt : rts) {
        	if (rt.DeveloperName == 'Low_Resolution') {
                lowResolutionRecordTypeId = rt.Id;
            } else if (rt.DeveloperName =='Performance_Management') {
                performanceManagementRecordTypeId = rt.Id;
            } else if (rt.DeveloperName =='Collaboration') {
                collaborationRecordTypeId = rt.Id;
            } else if (rt.DeveloperName =='Planning') {
                planningRecordTypeId = rt.Id;
            } else if (rt.DeveloperName =='Multicultural') {
                multiculturalRecordTypeId = rt.Id;
            }
        }
        for(ContentVersion c : contentVersionMap.values()){
            helper.put(c.ContentDocumentId, c);
            if (c.RecordTypeId == lowResolutionRecordTypeId) {
                Content_Description__c cd = new Content_Description__c(
                    Id                        = c.High_Resolution__c,
                    Content_Version_Id_Low__c = c.Id,
                    Content_ID_Low__c         = c.ContentDocumentId
                );
                
                if((!contentDescriptionAddSet.contains(cd.Id)) && cd.Id != null){
                	contentDescriptionUpdateList.add(cd);
                	contentDescriptionAddSet.add(cd.Id);
                }
            	
            } else if (c.RecordTypeId == performanceManagementRecordTypeId || c.RecordTypeId == collaborationRecordTypeId || c.RecordTypeId == planningRecordTypeId) {
                if (c.file__c == null) {
                    string pageSection = '';
                    String fileClassification = '';
                    if (c.RecordTypeId == performanceManagementRecordTypeId) {
                        pageSection = 'Performance Management';
                        
                        // only one classification is allowed, get first selected
						if(c.classification__c != null && c.classification__c != ''){
    						list<string> thms = c.classification__c.split(';');
							for(String t : thms){
								if(t!='' && t!=null){
									fileClassification = t;
									break;
								}
							}
						}	 
                    } else if (c.RecordTypeId == collaborationRecordTypeId) {
                        pageSection = 'Collaboration';
                        // only one classification is allowed, get first selected
						if(c.classification__c != null && c.classification__c != ''){
    						list<string> thms = c.classification__c.split(';');
							for(String t : thms){
								if(t!='' && t!=null){
									fileClassification = t;
									break;
								}
							}
						}	    		
                    } else if (c.RecordTypeId == planningRecordTypeId) {
                        pageSection = 'Planning';
                        fileClassification = c.Classification__c;
                    }
                    file__c f = new file__c(
                        Title__c              = c.Title,
                        Description__c        = c.Description,
                        Content_Version_Id__c = c.Id,
                        Content_ID__c         = c.ContentDocumentId,
                        filetype__c           = c.filetype,
                        Page_Section__c       = pageSection,
                        Image_Resolution__c   = c.Image_Resolution__c,
                        Tags__c				  = c.TagCsv,
						Portfolio__c          = c.Portfolio__c,
                        RTS__c				  = c.RTS__c,
                        Uploaded_date__c	  = c.LastModifiedDate,
						Classification__c	  = fileClassification
                    );
                    fileAddList.add(f);
                } else {
                    file__c f = new file__c(
                        Id                    = c.file__c,
                        Title__c              = c.Title,
                        Description__c        = c.Description,
                        Content_Version_Id__c = c.Id,
                        Content_ID__c         = c.ContentDocumentId,
                        filetype__c           = c.filetype,
                        Image_Resolution__c   = c.Image_Resolution__c,
                        Tags__c				  = c.TagCsv,
						Portfolio__c          = c.Portfolio__c,
                        RTS__c				  = c.RTS__c,
                        Uploaded_date__c	  = c.LastModifiedDate,
						Classification__c	  = c.Classification__c
                    );
                    fileUpdateList.add(f);
                }
            } else {
                string name = c.title;
                if(name.length()>80) {
                    name = name.substring(0, 79);
                }

                if (c.Content_Description__c == null) {
                    Content_Description__c cd = new Content_Description__c(
                        Name                  = name,
                        Title__c              = c.Title,
                        Description__c        = c.Description,
                        Content_Version_Id__c = c.Id,
                        Content_ID__c         = c.ContentDocumentId,
                        filetype__c           = c.filetype,
                        Image_Resolution__c   = c.Image_Resolution__c,
                        Portfolio__c          = c.Portfolio__c,
                        TBA__c                = c.TBA__c,
                        Tags__c				  = c.TagCsv,
                        RTS__c				  = c.RTS__c,
                        Matrix_type__c		  = c.Matrix_type__c,
                        Uploaded_date__c	  = c.LastModifiedDate,
						Classification__c	  = c.Classification__c
                    );
                     
                  	contentDescriptionAddList.add(cd); 
                  	
                } else {
                    Content_Description__c cd = new Content_Description__c(
                        Id                    = c.Content_Description__c,
                        Name                  = name,
                        Title__c              = c.Title,
                        Description__c        = c.Description,
                        Content_Version_Id__c = c.Id,
                        Content_ID__c         = c.ContentDocumentId,
                        filetype__c           = c.filetype,
                        Image_Resolution__c   = c.Image_Resolution__c,
                        Portfolio__c          = c.Portfolio__c,
                        TBA__c                = c.TBA__c,
                        Tags__c				  = c.TagCsv,
                        RTS__c				  = c.RTS__c,
                        Matrix_type__c		  = c.Matrix_type__c,
                        Uploaded_date__c	  = c.LastModifiedDate,
						Classification__c	  = c.Classification__c
                    );
                    if((!contentDescriptionAddSet.contains(cd.Id)) && cd.Id != null){                    	
                   		contentDescriptionUpdateList.add(cd);                   		
                   		contentDescriptionAddSet.add(cd.Id);
                    }
                } 
            }
        }
        if (contentDescriptionAddList.size()>0) {
            try {
            	insert contentDescriptionAddList;
            } catch (System.Dmlexception dmlex) {
        		for(ContentVersion c : contentVersionMap.values()){
                    String[] messages = dmlex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION,');                     
                    c.addError(messages.size()>1?messages[1]:messages[0]);
                }
            }
            contentDescriptionAddList = [SELECT Id, Content_ID__c FROM Content_Description__c WHERE Id in: contentDescriptionAddList];

            for(Content_Description__c cd : contentDescriptionAddList) {
                helper.get(cd.Content_ID__c).Content_Description__c = cd.Id;
            }
        }
        if (contentDescriptionUpdateList.size()>0) {        
        	update contentDescriptionUpdateList;
        }
        if (fileAddList.size()>0) { 
            insert fileAddList;
            fileAddList = [SELECT Id, Content_ID__c FROM file__c WHERE Id in: fileAddList];

            for(file__c f : fileAddList) {
                helper.get(f.Content_ID__c).file__c = f.Id;
            }
        }
        if (fileUpdateList.size()>0) {
            update fileUpdateList;
        }
    }
    
    public static void updateContentDescriptionAndFileOnAfterUpdate(map<id, ContentVersion> ContentVersionMap) {
        if (disabled) {
            return;
        }
        List<Content_Description__c> contentDescriptionUpdateList = new List<Content_Description__c>();
        Set<Id> contentDescriptionAddSet = new Set<Id>();
        List<file__c> fileUpdateList = new List<file__c>();
        recordtype[] rts = [SELECT id, DeveloperName FROM recordtype where DeveloperName in :new list<string>{'Low_Resolution', 'Performance_Management', 'Collaboration', 'Planning', 'Multicultural'} AND SobjectType = 'ContentVersion'];
        Id lowResolutionRecordTypeId,performanceManagementRecordTypeId,collaborationRecordTypeId,planningRecordTypeId,multiculturalRecordTypeId;
        for(recordtype rt : rts) {
            if (rt.DeveloperName == 'Low_Resolution') {
                lowResolutionRecordTypeId = rt.Id;
            } else if (rt.DeveloperName =='Performance_Management') {
                performanceManagementRecordTypeId = rt.Id;
            } else if (rt.DeveloperName =='Collaboration') {
                collaborationRecordTypeId = rt.Id;
            } else if (rt.DeveloperName =='Planning') {
                planningRecordTypeId = rt.Id;
            } else if (rt.DeveloperName =='Multicultural') {
                multiculturalRecordTypeId = rt.Id;
            }
        }
        
        ContentVersion[] cvs = new list<ContentVersion>(); 
        for (Id key : ContentVersionMap.keySet()) {
        	if(ContentVersionMap.get(key).ContentSize != null) {
        		cvs.add(ContentVersionMap.get(key));
        	}
        }
        if (cvs.size()==0) {
            cvs = [SELECT Id, RecordTypeId, ContentSize, High_Resolution__c, Content_Description__c, file__c FROM ContentVersion WHERE Id in: ContentVersionMap.keySet()];
        }
        
        for(ContentVersion c : cvs){
            if (c.RecordTypeId == lowResolutionRecordTypeId) {
                Content_Description__c cd = new Content_Description__c(
                    Id              = c.High_Resolution__c,
                    filesize_Low__c = TriggerContentVersion.convertFileSize(c.contentSize)
                );
                if((!contentDescriptionAddSet.contains(cd.Id)) && cd.Id != null){ 
               		contentDescriptionUpdateList.add(cd);
               		contentDescriptionAddSet.add(cd.Id);
                }
                
            } else if (c.RecordTypeId == performanceManagementRecordTypeId || c.RecordTypeId == collaborationRecordTypeId || c.RecordTypeId == planningRecordTypeId) {
                file__c f = new file__c(
                    Id          = c.file__c,
                    filesize__c = TriggerContentVersion.convertFileSize(c.contentSize)
                );
                fileUpdateList.add(f);
                
            } else {
                Content_Description__c cd = new Content_Description__c(
                    Id          = c.Content_Description__c,
                    filesize__c = TriggerContentVersion.convertFileSize(c.contentSize)
                );
                if((!contentDescriptionAddSet.contains(cd.Id)) && cd.Id != null){ 
              		contentDescriptionUpdateList.add(cd);
               		contentDescriptionAddSet.add(cd.Id);
                }
                
            }
        }
        
        if (contentDescriptionUpdateList.size()>0) {
            update contentDescriptionUpdateList;
        }
        if (fileUpdateList.size()>0) {
            update fileUpdateList;
        }
    }
    
    public static string convertFileSize(integer bytes) {
        if (bytes==null) {
        	bytes = 0;
        } else {
            bytes /= 1024;
        }
        String result = bytes + 'kB';
        if (bytes > 1024) {
            bytes /= 1024;
            result = bytes + 'MB';
        }
        return result;
    }
}