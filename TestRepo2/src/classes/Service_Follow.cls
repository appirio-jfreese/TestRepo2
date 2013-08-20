/*******************************************************************************
Name        : Service_Follow.cls

Updated By  : Basant Verma (Appirio Offshore)   
Date        : 6/7/13
Story/Task  : US503/TA1009
*******************************************************************************/
public without sharing class Service_Follow {
    private static Set<Id> followIds;
    
    public static void addFollow(list<ID> contentvIds){
    		if(contentvIds != null && contentvIds.size() > 0){
            // If content is already following.
            getFollowIds();
            List<Id> cvIds = new List<Id>();
            for(Id cvId : contentvIds){
                if(!followIds.contains(cvId))
                    cvIds.add(cvId);
            }
            System.debug('---- content Id'+cvIds);
            if(cvIds.size() > 0){
                List<Content_Subscription__c> subsList = new List<Content_Subscription__c>(); 
                
                // Fetch All Documents for which we need to Create Contenet_Subscription__c
                Map<String, ContentVersion> docVersions = new Map<String, ContentVersion>();
                for(ContentVersion cv : [Select Id, ContentDocumentId, ReasonForChange From ContentVersion Where Id IN : cvIds]){
                    docVersions.put(cv.ContentDocumentId, cv);
                }
                
                // Create Contenet_Subscription__c
                for(String key : docVersions.keySet()){
                    Content_Subscription__c sub = new Content_Subscription__c();
                    sub.User__c = Service_API.getUID();
                    sub.Content__c = key;
                    subsList.add(sub);
                    followIds.add(docVersions.get(key).Id);
                }
                
								if(subsList.size() > 0){
                    insert subsList;
                }
            }
        }
        
    }

    
    public static Set<Id> getFollowIds(){
    		if(followIds == null ){
            followIds = new Set<Id>();
            List<Id> docIds = new List<Id>();
            for(Content_Subscription__c cd : [Select Id, User__c, Content__c FROM Content_Subscription__c
                WHERE User__c = :Service_API.getUID()]){
                if(cd.Content__c != null && !cd.Content__c.trim().equals(''))
                    docIds.add(cd.Content__c);
            }
            
            ContentVersion prevCv = null;
            for(ContentVersion cv : [SELECT Id, ContentDocumentId, VersionNumber 
                FROM ContentVersion // Added isLatest = true in the below query by Jai Gupta [Appirio Jaipur] on July 23,2013 for case #00006101
                WHERE ContentDocumentId IN :docIds AND isLatest = true ORDER BY ContentDocumentId, VersionNumber desc]){
                if(prevCv == null || (prevCv != null && prevCv.ContentDocumentId != cv.ContentDocumentId)){
									prevCv = cv;
                	followIds.add(prevCv.Id);
                }
            }
        } 
        return followIds;
    }
    
    public static List<Id> getFollowIdList(){
        List<Id> cvIdList = new List<Id>();
        for(Id cvId : getFollowIds()){
            cvIdList.add(cvId);
        }
        return cvIdList;
    }
       
    
    public static void removeFollow(list<ID> contentvIds){
        if(contentvIds != null && contentvIds.size() > 0){
            // If content is already following.
            getFollowIds();
            List<Id> cvIds = new List<Id>();
            for(Id cvId : contentvIds){
                if(followIds.contains(cvId))
                    cvIds.add(cvId);
            }
            
            if(cvIds.size() > 0){
                List<Content_Subscription__c> subList;
                List<Content_Change_Notification__c> ccnList;
                Set<Id> docIds = new Set<Id>();
                for(ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion 
                        WHERE Id IN :cvIds ]){
                    docIds.add(cv.ContentDocumentId);
                }
                    
                subList = new List<Content_Subscription__c>([SELECT Id FROM Content_Subscription__c 
                    WHERE User__c = :Service_API.getUID() AND Content__c IN :docIds]);
                
                ccnList = new List<Content_Change_Notification__c>([SELECT Id 
                	FROM Content_Change_Notification__c WHERE Content_Subscription__c IN :subList ]);
                
                if(ccnList.size() > 0)
                    delete ccnList;
                if(subList.size() > 0)
                    delete subList;
                followIds.removeAll(cvIds);
            }
        }
    }
    
    public static Integer getNumberOfItems(){
        Set<Id> contentIds = Service_Follow.getFollowIds();
        return contentIds.size();
    } 
    
}