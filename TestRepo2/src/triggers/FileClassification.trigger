trigger FileClassification on File__c (before insert, before update) {
/*
	set<string> folderIds = new set<string>();
	
	for(File__c f : trigger.new){
		if(f.Folders__c != null && f.Folders__c != ''){
			List<String> fileFolders = f.Folders__c.split(';');
			for(string folderId : fileFolders){
				if(folderId != null && folderId != '' && !folderIds.contains(folderId)) {
					folderIds.add(folderId);
				}
			}
		}
	}

	Map<Id,folder__c>  folderInformation = new Map <Id,folder__c>([select id, classification__c from folder__c where id = :folderIds and classification__c != null]);

	for(File__c f : trigger.new){
		if(f.Folders__c != null && f.Folders__c != ''){
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
	
*/	
}