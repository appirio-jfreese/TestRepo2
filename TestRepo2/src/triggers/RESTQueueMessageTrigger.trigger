/* Created by Jai gupta [Appirio Jaipur]
       created date June 25, 2013
       Related to Case #00043236 : As per Carlos request, sending emails only when a Rest Queue messages completed failed to be processed.
 **/
trigger RESTQueueMessageTrigger on REST_Queue_Message__c (before update) {
    
    if(Trigger.isBefore) {
        if(Trigger.isUpdate) {
            
            final string FAILED_3_ATTEMPTS = 'Failed-3-Attempts' ;
            List<REST_Queue_Message__c> failedMessages = new list<REST_Queue_Message__c>();
            for(REST_Queue_Message__c mes : Trigger.new) {
                if(mes.Status__C == FAILED_3_ATTEMPTS && mes.status__C != Trigger.oldMap.get(mes.Id).Status__c ) {
                    failedMessages.add(mes);
                }
            }
            
            if(failedMessages.size() > 0) {
                SendNotifications.SendRestQueueMessageFailedNotifications(failedMessages);
            }
        }
    }

}