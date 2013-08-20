public class ContentNotificationController {
    
    private final List<Content_Subscription__c> contentSubs;
    private Set<Id> contentDocIds;
    private Map<Id, ContentDocument> contentDocMap;
    
    public ContentNotificationController() {
        contentSubs = [SELECT Id, User__c, Content__c 
                       FROM Content_Subscription__c];
                
        if(contentSubs != null && contentSubs.size() > 0) {
            contentDocIds = new Set<Id>();
            for(Content_Subscription__c conSub : contentSubs) {
                contentDocIds.add(conSub.Content__c);
            }
        }
        
        contentDocMap = new Map<Id, ContentDocument>([SELECT Id
                                                      FROM ContentDocument
                                                      WHERE Id IN : contentDocIds
                                                            AND LastModifiedDate <=: system.now()]);

        //@TODO - Loop through the Map of Content that has been recently changed for which there are Subscriptions
    }

    public List<Content_Subscription__c> getContentSubs() {
        return contentSubs;
    }
    
    public class ContentNotification {
        public Content_Subscription__c contentSub;
        public String contentName;
        public String contentURL;
    
        public ContentNotification(){}
    }
}