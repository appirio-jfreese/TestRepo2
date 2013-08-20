public with sharing class TriggerFile {
    public static boolean disabled = false;
    public static void onBeforeUpdate(map<id, File__c> newFileMap, map<id, File__c> oldFileMap) {
        if (TriggerFile.disabled) {
            return;
        }
              
       	
        List<String> contentList = new List<String>();
        Map<id, File__c> copyMap = new Map<id, File__c>();
        list<ContentVersion> cvs = new list<ContentVersion>();

        
	    for(String key : newFileMap.keySet()) {
	        File__c cd = newFileMap.get(key);
	        contentList.add(cd.Content_Id__c);	    
	        copyMap.put(cd.Content_Id__c, cd);
            boolean changed = false;
            ContentVersion cv = new ContentVersion(Id=cd.Content_Version_Id__c);
            if( cd.Title__c != oldFileMap.get(key).Title__c) {
                cv.Title = cd.Title__c;
                changed = true;
            }
            if( cd.Description__c != oldFileMap.get(key).Description__c) {
                cv.Description = cd.Description__c;
                changed = true;
            }
            if( cd.Classification__c != oldFileMap.get(key).Classification__c) {
                cv.Classification__c = cd.Classification__c;
                changed = true;
            }
            if (changed) {
                cvs.add(cv);
            }
	        
	    }
	    
       
        Set<Id> keySet = new Set<Id>(); 
        keySet = newFileMap.keySet();
        List<File__c> files = [Select f.share_link__c, f.filetype__c, f.filesize__c, f.Video_Id__c, f.Title__c, f.Tags__c, f.SystemModstamp, f.Start_Date__c, f.RTS__c, f.Preview_Id__c, f.Preview_Available__c, f.Portfolio__c, f.Page_Section__c, f.OwnerId, f.Only_For_Internal_User__c, f.Name, f.LastModifiedDate, f.LastModifiedById, f.Is_Video__c, f.IsDeleted, f.Image_Resolution__c, f.Id, f.Folders__c, f.Folder_Names__c, f.End_Date__c, f.OrgUnits__c, f.Division_Access__c, f.Distributors__c, f.Distributor_Names__c, f.Description__c, f.CreatedDate, f.CreatedById, f.Content_Version_Id__c, f.Content_ID__c, f.Calendar__c, f.Brands__c, f.Brand_Names__c, f.Available_Until__c From File__c f
        					   Where(
        					   			f.Content_ID__c IN :contentList
        					   			AND f.Id NOT IN :keySet
        					   		)
        					  ];       
       	           	
       	for(File__c file : files) {	       
	       File__c f = copyMap.get(file.Content_Id__c);	       
	       
	       file.share_link__c = f.share_link__c; 	 
	       file.filetype__c = f.filetype__c;
	       file.filesize__c = f.filesize__c;
	       file.Video_Id__c = f.Video_Id__c;
	       file.Title__c = f.Title__c;
	       file.Tags__c = f.Tags__c;	    
	       file.Start_Date__c = f.Start_Date__c;
	       file.RTS__c = f.RTS__c;
	       file.Preview_Id__c = f.Preview_Id__c;
	       file.Preview_Available__c = f.Preview_Available__c;
	       file.Portfolio__c = f.Portfolio__c;
	       file.Page_Section__c = f.Page_Section__c;
	       file.OwnerId = f.OwnerId;
	       file.Only_For_Internal_User__c = f.Only_For_Internal_User__c;
	       file.Is_Video__c = f.Is_Video__c;
	       file.Image_Resolution__c = f.Image_Resolution__c;
	       file.Folders__c = f.Folders__c;
	       file.Folder_Names__c = f.Folder_Names__c;
	       file.End_Date__c = f.End_Date__c;
	       file.OrgUnits__c = f.OrgUnits__c;
	       file.Division_Access__c = f.Division_Access__c;
	       file.Distributors__c = f.Distributors__c;
	       file.Distributor_Names__c = f.Distributor_Names__c;
	       file.Description__c = f.Description__c;
	       file.Content_Version_Id__c = f.Content_Version_Id__c;
	       file.Content_ID__c = f.Content_ID__c;
	       file.Brands__c = f.Brands__c;
	       file.Brand_Names__c = f.Brand_Names__c;
	       file.Available_Until__c = f.Available_Until__c;
	    }
	    
	    TriggerFile.disabled = true;
	    update(files);
	    if (cvs.size()>0) {
            TriggerContentVersion.disabled = true;
            update cvs;
            TriggerContentVersion.disabled = false;
	    }
	    TriggerFile.disabled = false;
    }
    
    public static void setClassification(list<File__c> files) {
        if (TriggerFile.disabled) {
            return;
        }
	    
	    set<string> folderIds = new set<string>();
	    
	    for(File__c f : files){
	        if(f.Folders__c != null && f.Folders__c != '' && f.Page_Section__c == 'Planning'){
	            List<String> fileFolders = f.Folders__c.split(';');
	            for(string folderId : fileFolders){
	                if(folderId != null && folderId != '' && !folderIds.contains(folderId)) {
	                    folderIds.add(folderId);
	                }
	            }
	        }
	    }
	
	    Map<Id,folder__c>  folderInformation = new Map <Id,folder__c>([select id, classification__c from folder__c where id = :folderIds and classification__c != null]);
	
	    for(File__c f : files){
	        if(f.Folders__c != null && f.Folders__c != '' && f.Page_Section__c == 'Planning'){
	            List<String> fileFolders = f.Folders__c.split(';');
	            for(string folderId : fileFolders){
	                if(folderId != null && folderId != '' && folderInformation.containsKey(folderId)) {
	                    List<String> folderClasifications = folderInformation.get(folderId).classification__c.split(';');
	                    for(String clsf : folderClasifications){
	                        if(clsf == '' || clsf == null){
	                            continue;
	                        }
	                        if(f.classification__c != null && f.classification__c.contains(clsf.trim())){
	                            continue;
	                        }
	                        if( f.classification__c == null){
	                            f.classification__c = clsf;
	                        } else {
	                            f.classification__c = f.classification__c+' ;'+clsf;
	                        }
	                    }
	                }
	            }
	        }
	    }    	
    }
}