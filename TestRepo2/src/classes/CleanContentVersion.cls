global class CleanContentVersion implements Database.Batchable<sObject>{
	
	global final String ContentDescriptionQuery;
	
	global CleanContentVersion(){
		ContentDescriptionQuery = 'SELECT id, Content_ID__c, Content_Version_Id__c, Content_ID_Low__c, Content_Version_Id_Low__c FROM Content_Description__c';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(ContentDescriptionQuery);
	}
     
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Content_Description__c> contentDescriptionUpdateList = new List<Content_Description__c>();
        List<Content_Description__c> contentDescriptionDeleteList = new List<Content_Description__c>();

		set<string> descriptionIDs = new Set<String>();
		for(sObject descr : scope){
			descriptionIDs.add(String.valueOf(descr.get('Content_Version_Id__c')));
			descriptionIDs.add(String.valueOf(descr.get('Content_Version_Id_Low__c')));			
		}

		List<ContentDocument> contentDocuments = [SELECT LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId = :descriptionIDs];                    	
		set<string> documentIDs = new Set<String>();
		for(ContentDocument doc : contentDocuments){
			documentIDs.add(String.valueOf(doc.LatestPublishedVersionId));
		}
		 
		for(sObject descr : scope){
			
			Content_Description__c cDescription = (Content_Description__c)descr;
			
			if(cDescription.Content_Version_Id__c == null && cDescription.Content_Version_Id_Low__c == null){
				contentDescriptionDeleteList.add(cDescription);
			} else if(cDescription.Content_Version_Id__c != null && cDescription.Content_Version_Id_Low__c == null){
				if(!documentIDs.contains(cDescription.Content_Version_Id__c)){
					contentDescriptionDeleteList.add(cDescription);
				}
			} else if(cDescription.Content_Version_Id__c == null && cDescription.Content_Version_Id_Low__c != null){				
					contentDescriptionDeleteList.add(cDescription);				
			} else if(cDescription.Content_Version_Id__c != null && cDescription.Content_Version_Id_Low__c != null){
				if(!documentIDs.contains(cDescription.Content_Version_Id__c)){
					cDescription.Content_ID__c = null;
					cDescription.Content_Version_Id__c = null;
				}
				if(!documentIDs.contains(cDescription.Content_Version_Id_Low__c)){
					cDescription.Content_ID_Low__c = null;
					cDescription.Content_Version_Id_Low__c = null;
				}
				
				if(cDescription.Content_Version_Id__c != null){
					contentDescriptionUpdateList.add(cDescription);				
				} else {
					contentDescriptionDeleteList.add(cDescription);
				}			
			}
		} 
		
		if (contentDescriptionUpdateList.size()>0) {
			update contentDescriptionUpdateList;
		}
		if (contentDescriptionDeleteList.size()>0) {
			
			Set<Id> toDeleteIdSet = new set<Id>();

			for(Content_Description__c s : contentDescriptionDeleteList){
				toDeleteIdSet.add(s.Id);
			}			

			List<Content_Property__c> cp = [Select Content_Description__c From Content_Property__c Where Content_Description__c = :toDeleteIdSet];
	        delete(cp);
	        List<ContentBrand__c> cb = [Select Content_Description__c From ContentBrand__c Where Content_Description__c = :toDeleteIdSet];
	        delete(cb); 		       
			
			delete contentDescriptionDeleteList;
		}		
    }
    
	global void finish(Database.BatchableContext BC){
		try{
   		   
   		   ScheduledContentVersion n = new ScheduledContentVersion();
   			
		   DateTime curr = System.now();
		   curr = curr.addMinutes(15);
		   String name = 'Content_Desc Delete';
		   String nextTime = '';
		   nextTime+=curr.second()+' ';
		   nextTime+=curr.minute()+' ';
		   nextTime+=curr.hour()+' ';
		   nextTime+=curr.day()+' ';
		   nextTime+=curr.month()+' ? ';
		   nextTime+=curr.year();
   		   
   		   system.schedule(name,nextTime,n);
   		   
  		} catch(Exception ex){

  		}
	}
}