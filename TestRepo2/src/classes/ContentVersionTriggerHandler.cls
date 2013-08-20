/*******************************************************************************
Name        : ContentVersionTriggerHandler.cls

Updated By  : Basant Verma (Appirio Offshore)   
Date        : 6/5/13
Story/Task  : US79/TA1001
Description : Handler Class for ContentVersionTrigger.trigger
*******************************************************************************/
public with sharing class ContentVersionTriggerHandler {
    private static boolean disabled = false;
    
    // This method called from ContentVersionTrigger on After Insert
    public static void onAfterInsert(Map<ID, ContentVersion> newRecordsMap){
        // Create Content Notification Records
        createContentNotifications(newRecordsMap);
    }
    
    // This method called from ContentVersionTrigger on After Update
    public static void onAfterUpdate(Map<ID, ContentVersion> newRecordsMap,
                                    Map<ID, ContentVersion> oldRecordsMap){
        // Create Content Notification Records
        createContentNotifications(newRecordsMap);
    }
        
    // Method creates Content_Change_Notification__c for each new content version
    private static void createContentNotifications(Map<ID, ContentVersion> newRecordsMap){
        
        // Fetch All Parent Content Documnet's Id
        Map<String, String> versionContentMap = new Map<String, String>();
        for(String cvId : newRecordsMap.keySet()){
            if(newRecordsMap.get(cvId).ReasonForChange != null){
                versionContentMap.put(newRecordsMap.get(cvId).ContentDocumentId, cvId);
            }
        }
        system.debug('===versionContentMap========='+versionContentMap);
        if(versionContentMap.size() > 0){
            
            if(disabled){
                return;
            }
            // Set of user ids
            Set<String> userIds = new Set<String>();
                        
            // Created New Notification Records 
            List<Content_Change_Notification__c> notifications = new List<Content_Change_Notification__c>();
            
            // Retry count
            Integer retryCount = 0;
            
            // Get Retry_Count value
            Content_Notification__c notificationSetting = Content_Notification__c.getOrgDefaults();
            if(notificationSetting != null 
            && notificationSetting.Content_Notification_Retries__c != null){
                retryCount = Integer.valueOf(notificationSetting.Content_Notification_Retries__c);
            }
            
            // Iterate through each subscription
            for(Content_Subscription__c sub : getContentSubscriptions(versionContentMap.keySet())){
                Content_Change_Notification__c notific = new Content_Change_Notification__c();
                notific.User__c = sub.User__c;
                notific.Content__c = sub.Content__c;
                notific.Content_Version__c = versionContentMap.get(sub.Content__c);
                notific.Change_Description__c = newRecordsMap.get(versionContentMap.get(sub.Content__c)).ReasonForChange;
                notific.Content_Subscription__c = (ID)sub.Id;
                notific.Send_Date__c = Date.today();
                notific.Retry_Count__c = retryCount;
                notifications.add(notific);
                if(sub.User__r.Content_Notification_Frequency__c == 'Real Time'){
                    userIds.add(sub.User__c);
                }
            }
            
            // Insert Notification Records
            if(notifications.size() > 0){
                insert notifications;           
                
                // Send notifications if Content_Notification_Frequency__c == 'Real Time'
                if(userIds.size() > 0){
                    handleEveryUpdateNotification(userIds, notifications);
                    disabled = true;
                }
            }
        }
    }
    
    // TA1000 : Method handles case where User.Content_Notification_Frequency__c == 'Real Time'
    private static void handleEveryUpdateNotification(Set<String> userIds, 
                    List<Content_Change_Notification__c> notifications){
        Set<String> notificationIds = new Set<String>();
        for(Content_Change_Notification__c notification : notifications){
            notificationIds.add(notification.id);
        }
        
        system.debug('======Future method call==============='+notificationIds);
        // Call future method to send real time notifications
        sendRealTimeNotifications(userIds, notificationIds);
    }
    
    // Fetch All Content Subscriptions Records
    private static List<Content_Subscription__c> getContentSubscriptions(Set<String> contentDocumentIds){       
        List<Content_Subscription__c> subscrips = [SELECT Id, User__c, 
                                                       User__r.Content_Notification_Frequency__c,
                                                       Content__c 
                                                       FROM Content_Subscription__c 
                                                       WHERE Content__c IN :contentDocumentIds];    
        system.debug('===subscrips========='+subscrips);
        return subscrips;
    }
    
    /**************************************************************
     // TA1000 : @future interface to send real time notifications
    **************************************************************/
    @future
    public static void sendRealTimeNotifications(Set<String> userIds, Set<String> notificationIds){
        Date dt = Date.today();
        String queryStr = 'Select id, email, Content_Notification_Frequency__c,'
                    + ' (Select id, User__c,'
                    + ' Content__c,'
                    + ' Content_Version__c, '
                    + ' Content_Subscription__c, Change_Description__c, Send_Date__c,'
                    + ' Status__c, Error_Message__c'
                    + ' from Content_Change_Notifications__r'
                    + ' where Status__c = \'Pending\''
                    + ' and Send_Date__c <= : dt and id in : notificationIds)' 
                    + ' from user'
                    + ' where id in : userIds';
        List<sObject> scope = Database.query(queryStr);
        BatchContentChangeNotification.processUnsentNotifications(scope, null);
    }
    
}