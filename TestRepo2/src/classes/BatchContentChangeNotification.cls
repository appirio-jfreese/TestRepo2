/*****************************************************************************
 * Name           : BatchContentChangeNotification
 * Created On     : June 6, 2013
 * Created By     : Parul Gupta(Appirio Offshore)
 * Task Number    : TA1000
 * Implementation : Batch job to send unsent Content Change Notifications.
******************************************************************************/
global class BatchContentChangeNotification implements Database.Batchable<sObject>, Schedulable{ 
    
    // Holds the query string.
    public String queryStr;
    
    // Holds the boolean value to acknowledge user that batch job is completed
    public boolean sendAckEmail = false;
    public static Map<Id,ContentVersion> contentVersionObjMap;
    
    // Initializes the query with QueryLocator.
    global Database.QueryLocator start(Database.BatchableContext BC){       
        System.debug('BatchContentChangeNotification :: Batch Process start()');
        Date dt = Date.today();
        queryStr = 'Select id, email, Content_Notification_Frequency__c,'
                    + ' (Select id, User__c, Retry_Count__c, '
                    + ' Content__c,'
                    + ' Content_Version__c, '
                    + ' Content_Subscription__c, Change_Description__c, Send_Date__c,'
                    + ' Status__c, Error_Message__c'
                    + ' from Content_Change_Notifications__r'
                    + ' where Status__c != \'Sent\''
                    + ' and Send_Date__c <= : dt order by createddate desc limit 50)' 
                    + ' from user'
                    + ' where Content_Notification_Frequency__c = \'Daily\''
                    + ' or Content_Notification_Frequency__c = \'Weekly\'';
                        
        system.debug('Query Str :: ' + queryStr);       
        return Database.getQueryLocator(queryStr);
    }
    
    // Processes the list of objects.
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('BatchContentChangeNotification :: Batch Process execute()'); 
        System.debug('Batch size ::::::::::::::::::: ' + scope.size());
        processNotifications(scope);
    }
    
    // Method sends print requests for posting on server and updates status field
    global void processNotifications(List<sObject> scope){
        System.debug('processUnsentNotifications :::::::::::::::::::'+scope);
        
        // Get notification custom setting
        Content_Notification__c notificationSetting = Content_Notification__c.getOrgDefaults();
        
        // Process unsent notifications
        processUnsentNotifications(scope, notificationSetting);
       
        // Delete sent notifications
        deleteSentNotifications(notificationSetting);      
    }
                 
    // Completes the batch process.
    global void finish(Database.BatchableContext BC) {
       
        // Add logging information
        System.debug('Process Completed');
         // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, 
                          TotalJobItems, CreatedBy.Email 
                          from AsyncApexJob 
                          where Id = :BC.getJobId()];
        
        if(sendAckEmail) {
            // Send an email to the Apex job's submitter notifying of job completion.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('BatchContentChangeNotification status :: ' + a.Status);
            mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '
            + a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
        System.debug('Batch :: BatchContentChangeNotification status :: ' + a.Status);
        System.debug('The batch Apex job processed ' + a.TotalJobItems + ' batches with '
                        + a.NumberOfErrors + ' failures.');
    }
    
    /*********************************************************************
    // Method processes pending/unsent notifications
    *********************************************************************/
    public static void processUnsentNotifications(List<sObject> scope, 
                            Content_Notification__c notificationSetting){
        
         // List of email messages 
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        
        // DE606 : Decides how share_link will be populated
        Id collaborationDefaultRecordTypeId;
        Id distributorPortalDefaultRecordTypeId;
        for(ContentWorkspace CW : [SELECT Id, Name, DefaultRecordTypeId FROM ContentWorkspace 
                                    WHERE Name =: Constant.COLLABORATION_LIBRARY
                                    or Name = : Constant.DISTRIBUTOR_PORTAL_LIBRARY]){
            if(CW.Name == Constant.COLLABORATION_LIBRARY){
                collaborationDefaultRecordTypeId = CW.DefaultRecordTypeId;
            }else{
                distributorPortalDefaultRecordTypeId = CW.DefaultRecordTypeId;
            }                       
        }
                
        // List of content change notifications
        List<Content_Change_Notification__c> changeNotifications 
                        = new List<Content_Change_Notification__c>();
                            
        // Get latest content versions
        Map<id, List<String>> contentVersionMap = getContentVersions(scope, 
                                collaborationDefaultRecordTypeId, 
                                distributorPortalDefaultRecordTypeId);
        /*Added by Rahul Chitkara on 1 August Case 00006164 */                        
        if(contentVersionMap.keySet().size() > 0){                        
            contentVersionObjMap = new Map<Id,ContentVersion>([select Id, File__r.share_link__c from ContentVersion where Id in : contentVersionMap.keySet()]);
        }                        
        // End Case 00006164                        
                                
        
        Integer allowedRetryCount = 0;
        if(notificationSetting != null 
        && notificationSetting.Content_Notification_Retries__c != null){
            allowedRetryCount = Integer.valueOf(notificationSetting.Content_Notification_Retries__c);
        }
        
        // Get unsent email messages
        emailMessages = getEmailMessages(scope, changeNotifications, contentVersionMap,
                        allowedRetryCount);  
        
        if(emailMessages.size() > 0){
            try{
                system.debug('========emailMessages================'+emailMessages);
                // Send email messages
                Messaging.sendEmail(emailMessages); 
                
                // If successfully sent, update status = 'Sent'
                for(Content_Change_Notification__c changeNotification : changeNotifications){
                    changeNotification.status__c = 'Sent';
                }           
            }
            catch (Exception e) {
                system.debug('BatchContentChangeNotification :: Failed to send emails ' + e);
                
                // If exception occurs, update status = 'Error'
                for(Content_Change_Notification__c changeNotification : changeNotifications){
                    changeNotification.status__c = 'Error';                 
                    if(allowedRetryCount > 0 && changeNotification.Retry_Count__c > 0){
                        changeNotification.Retry_Count__c--;
                    }
                    changeNotification.Error_Message__c = e.getMessage();
                }
            }
            system.debug('========changeNotifications================'+changeNotifications);
            
            // Update notifications
            update changeNotifications;                     
        } 
    }
    
    /*********************************************************************
    // Method returns content version map with key as content version Id
    // and value as List of String contains 1.) Title 2.) Share_Link
    *********************************************************************/
    private static Map<Id, List<String>> getContentVersions(List<sObject> scope,
                                        Id collaborationDefaultRecordTypeId,
                                        Id distributorPortalDefaultRecordTypeId){
        Set<Id> fileContentIds = new Set<Id>();
        Set<Id> desContentIds = new Set<Id>(); 
        Set<Id> contentVersionIds = new Set<Id>();
        Map<Id, List<String>> contentVersionMap = new Map<Id, List<String>>();
        List<String> titleShareList;
        User user;
        for(sObject obj : scope){
            user = (User)obj;
            for(Content_Change_Notification__c changeNotification : user.Content_Change_Notifications__r){
                if(changeNotification.Content_Version__c != null){
                    contentVersionIds.add(changeNotification.Content_Version__c);
                }                       
            }
        }
        system.debug('=======contentVersionIds============='+contentVersionIds); 
        
        // Fetch title for respective versions       
        if(contentVersionIds.size() > 0){
            for(ContentVersion cVersion : [Select id, title, RecordTypeId, contentDocumentId
                                            from ContentVersion
                                            where id in : contentVersionIds]){
                if(cVersion.RecordTypeId == collaborationDefaultRecordTypeId){
                    fileContentIds.add(cVersion.contentDocumentId);
                }else if(cVersion.RecordTypeId == distributorPortalDefaultRecordTypeId){
                    desContentIds.add(cVersion.contentDocumentId);
                }
                titleShareList = new List<String>();
                titleShareList.add(cVersion.title);
                contentVersionMap.put(cVersion.id, titleShareList); 
            }   
        }
        system.debug('=======fileContentVersionIds============='+fileContentIds);
        system.debug('=======desContentVersionIds============='+desContentIds);
        
        // Fetch share links for contents
        if(desContentIds.size() > 0){
            for(Content_Description__c contentDesc : [select share_link__c, Content_Version_Id__c
                                                      from Content_Description__c
                                                      where Content_ID__c in :desContentIds]){                  
                if(contentDesc.share_link__c != null 
                && contentVersionMap.get(contentDesc.Content_Version_Id__c) != null){
                    contentVersionMap.get(contentDesc.Content_Version_Id__c).add(contentDesc.share_link__c);
                }                                           
            }
        }
        
        if(fileContentIds.size() > 0){
            for(File__c file : [select share_link__c, Content_Version_Id__c
                                from File__c
                                where Content_ID__c in :fileContentIds]){               
                if(file.share_link__c != null
                && contentVersionMap.get(file.Content_Version_Id__c) != null){
                    contentVersionMap.get(file.Content_Version_Id__c).add(file.share_link__c);
                }
                                            
            }
        }
        system.debug('========contentVersionMap================'+contentVersionMap);
        return contentVersionMap;
    }
    
    
    /*********************************************************************
    // Method returns unsent email messages list
    *********************************************************************/
    private static List<Messaging.SingleEmailMessage> getEmailMessages(List<sObject> scope, 
                        List<Content_Change_Notification__c> changeNotificaitons,
                        Map<Id, List<String>> contentVersionMap,
                        Integer allowedRetries){
        List<Messaging.SingleEmailMessage> unsentEmailMessages = new List<Messaging.SingleEmailMessage>();
        User user;
        String notificationStr;
        String notificationHtmlStr;   
        Messaging.SingleEmailMessage mail;        
        DateTime todayDT = (DateTime)Date.today();
        String dayOfWeek = todayDT.format('E');
        String sharelink;
        String documentName;
        String reasonForChange;
        system.debug('===dayOfWeek========='+dayOfWeek);
        
        // Get sender email 
        OrgWideEmailAddress sender;
        for(OrgWideEmailAddress owea : [select Id from OrgWideEmailAddress 
                                        where Address = 'diageodirect@diageo.com']){
            sender = owea;
        }
       
        // Iterage through each user and create email message for each user containing
        // list of change notifications
        for(sObject obj : scope){
            user = (User)obj; 
            if((user.Content_Notification_Frequency__c == 'Daily'
            || (user.Content_Notification_Frequency__c == 'Weekly' 
                && dayOfWeek == 'Sun')
            || user.Content_Notification_Frequency__c == 'Real Time')
            && user.Content_Change_Notifications__r.size() > 0) {               
                mail = new Messaging.SingleEmailMessage();              
                notificationStr = '';   
                notificationHtmlStr = '';
                shareLink = ''; 
                documentName = '';
                reasonForChange = '';   
                for(Content_Change_Notification__c changeNotification : user.Content_Change_Notifications__r){
                    if((changeNotification.status__c == 'Pending'
                    || (changeNotification.status__c == 'Error' 
                        && changeNotification.Retry_Count__c > 0 
                        && changeNotification.Retry_Count__c < allowedRetries)) 
                    && changeNotification.content_Version__c != null 
                    && contentVersionMap.get(changeNotification.content_Version__c) != null){                       
                        
                        documentName = contentVersionMap.get(changeNotification.content_Version__c).get(0);                     
                         // Commented out by Rahul Chitkara on 30th July for 00006164
                    /* if(contentVersionMap.get(changeNotification.content_Version__c).size() > 1){
                            shareLink = contentVersionMap.get(changeNotification.content_Version__c).get(1);
                        } */
                        // Added by Rahul Chitkara for 00006164. Change the value of Sharelink
                        if(changeNotification.content_Version__c!=null || changeNotification.content_Version__c!=''){
                            if(contentVersionObjMap.keySet().size() > 0 && contentVersionObjMap.ContainsKey(changeNotification.content_Version__c)){
                                shareLink = contentVersionObjMap.get(changeNotification.content_Version__c).File__r.share_link__c;
                            }
                             
                        }
                            // end changes 00006164 
                        reasonForChange = changeNotification.Change_Description__c;                 
                        system.debug('====sharelink========'+shareLink);
                        system.debug('====title========'+documentName);
                        system.debug('====reasonForChange========'+reasonForChange);
                        if(notificationStr == ''){
                            notificationStr += '\n';
                            notificationHtmlStr += '\n';
                        }
                        notificationStr += '\n' + documentName +  ' - ' + reasonForChange;
                        if(shareLink != null && shareLink != ''){
                            notificationStr += ' - ' + shareLink;                           
                        }   
                        notificationHtmlStr += '\n' + '<a href="' + shareLink + '">' 
                                                    + documentName + '</a>' + ' - ' + reasonForChange;                                              
                        changeNotificaitons.add(changeNotification);
                        
                    }
                } 
                if(notificationStr != '' && notificationHtmlStr != ''){
                    populateEmailParameters(mail, user, sender, notificationStr, 
                                notificationHtmlStr, documentName);             
                    unsentEmailMessages.add(mail); 
                }       
            }                       
        }
        return unsentEmailMessages;
    }
    
    /*********************************************************************
    // Method populates email parameters
    *********************************************************************/
    private static void populateEmailParameters(Messaging.SingleEmailMessage mail,
                                                User receiver, OrgWideEmailAddress sender,                                               
                                                String notificationStr,
                                                String notificationHtmlStr,
                                                String documentName){
        // Email Subject and pre plain body
        String subject = '';
        String prePlainBody = '';
        if(receiver.Content_Notification_Frequency__c == 'Real Time'){
            subject += 'Diageo Direct Content Update: ' + documentName;
            prePlainBody += 'The following items have been updated: \n' 
                            + documentName + '. Click on the link to open the item. \n';
        }else{
            subject = 'Diageo Direct Content ' + receiver.Content_Notification_Frequency__c +  ' Status Update';
            prePlainBody += 'The following items have been updated.'
                            + ' Click on the link to open the item. \n';
        }
        
        system.debug('===email========'+receiver.email);                            
        mail.setToAddresses(new List<String>{receiver.email});                      
        mail.setSubject(subject);
        mail.setTargetObjectId(receiver.id);
        mail.setOrgWideEmailAddressId(sender.id);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody(prePlainBody + notificationStr);
        notificationHtmlStr = notificationHtmlStr.replaceAll('\n','<br/>');
        mail.setHtmlBody(prePlainBody + notificationHtmlStr);
    }
    
    /*********************************************************************
    // Method deletes sent notifications which are created before 
    // the period of time specified in custom setting.
    *********************************************************************/
    private static void deleteSentNotifications(Content_Notification__c notificationSetting){   
        if(notificationSetting != null 
        && notificationSetting.Delete_Sent_Notification_Threshhold__c != null){
            Date dateToCompare 
            = system.today().addMonths(-Integer.valueOf(notificationSetting.Delete_Sent_Notification_Threshhold__c));
            
            // Get all sent notifications before threshold date
            List<Content_Change_Notification__c> sentNotifications 
                        = [Select id from Content_Change_Notification__c
                            where status__c = 'Sent' 
                            and createdDate < : dateToCompare];
                            
            // Delete sent notifications
            if(sentNotifications.size() > 0){
                delete sentNotifications;
            }
        }
        
    }
    
    // Execute method for schedulable context.
    global void execute(SchedulableContext SC) {
      
        System.debug('In SchedulableContext :::::::: ');
        
        ID batchprocessid = Database.executeBatch(this);        
        
        System.debug('batchprocessid ::::: ' + batchprocessid);
        
        ID scheduledJobId = SC.getTriggerID();
        
        System.debug('scheduledJobId ::::: ' + scheduledJobId);
   }
}