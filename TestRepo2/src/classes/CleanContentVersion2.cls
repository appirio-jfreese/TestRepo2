global class CleanContentVersion2 implements Database.Batchable<sObject>{
    
    global final String FileQuery;
    
    global CleanContentVersion2(){
        FileQuery = 'SELECT id, Content_ID__c, Content_Version_Id__c FROM FILE__c';
    } 
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(FileQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<File__c> fileDeleteList = new List<File__c>();

        set<string> fileIDs = new Set<String>();
        for(sObject file : scope){
            fileIDs.add(String.valueOf(file.get('Content_Version_Id__c')));
        }

        List<ContentDocument> contentDocuments = [SELECT LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId = :fileIDs];                       
        set<string> documentIDs = new Set<String>();
        for(ContentDocument doc : contentDocuments){
            documentIDs.add(String.valueOf(doc.LatestPublishedVersionId));
        }
          
        for(sObject file : scope){
            
            file__c cfile = (file__c)file;
            
            if(cfile.Content_Version_Id__c == null){
                fileDeleteList.add(cfile);
            } else {
                if (!documentIDs.contains(cfile.Content_Version_Id__c)) {
                    fileDeleteList.add(cfile);
                }
            } 
        }
        
        if (fileDeleteList.size()>0) {          	         
            delete fileDeleteList;
        }       
    }
       
    global void finish(Database.BatchableContext BC){
		try{
   		   
   		   ScheduledContentVersion2 n = new ScheduledContentVersion2();
   			
		   DateTime curr = System.now();
		   curr = curr.addMinutes(15);
		   String name = 'File Delete';
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