/* Created by Jai gupta [Appirio Jaipur]
       created date June 25, 2013
       Related to Case #00043236 : As per Carlos request, sending emails only when a Rest Queue messages completed failed to be processed.
 **/
public class SendNotifications {

    public static void SendRestQueueMessageFailedNotifications(List<REST_Queue_Message__c> failedMessages) {
        
        List<Messaging.SingleEmailMessage> notifications = new list<Messaging.SingleEmailMessage>();
        try {
            for (REST_Queue_Message__c mes : failedMessages){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new list<String>{'pos-order-confirmation@diageo.com','diageo.support@appirio.com'});
                mail.setReplyTo('pos-order-confirmation@diageo.com');
                mail.setSubject('HTTP Request failed to be processed');
                mail.setSenderDisplayName('Diageo POS Processing');
                mail.setBccSender(false);
                mail.setUseSignature(false);
                
                String body = 'There was an error received while processing Rest Queue Message records \n\n';
                
                String server = System.URL.getSalesforceBaseURL().getHost();
                
                if (server.indexOf('na7.salesforce.com')>-1) {
                   // body=body+'This error was experienced in the live PRODUCTION environment\n';
                }
                else {
                    body=body+'This error was received in the SANDBOX environment and is a result of testing/development there.Please forward '+
                        'this message to the development/qa team';
                    body=body+'\n\n';
                    body=body+'Error occurred on server: '+server;
                    body=body+'\n';
                }
                
                body += '\nRest Queue message Name : '+mes.Name;
                body += '\n\nAPI Arguments : \n'+mes.Request_apiArguments__c ;
                body += '\n\nLast Processed time : '+mes.LastProcessedTime__c ;
                body += '\n\nRelated to : '+mes.ObjectId__c;
                
                mail.setPlainTextBody(body);
                notifications.add(mail);
            }
            if (notifications.size() > 0) {
                Messaging.sendEmail(notifications);
            }
        }
        catch (Exception ex) {
            System.debug('FAILURE TO SEND EMAIL: '+ex.getMessage());
        }
    
    }

}