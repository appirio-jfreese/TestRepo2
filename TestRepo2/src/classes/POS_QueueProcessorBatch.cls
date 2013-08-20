/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        05/16/2012
 * @description Process Messages from the REST_Queue_Message queue and post callouts corresponding to the same.
 
  /* Modified by Jai gupta [Appirio Jaipur]
       Modified date Feb 13, 2013
       Re-Added : Mar 21,2013
       Related to Case #00003906 : Covering the code in try catch block and sending emails
                                    from the catch block in case of any error occurs.
                                    
  /* Modified by Jai gupta [Appirio Jaipur]
       Modified date Mar 29, 2013
       Related to Case #00043236 : Enhanced function and provided two arguments subject and Classname
       								Almost generic and is being called from POS_MagentoIntegrationUtil
       								class as well.
 **/
global class POS_QueueProcessorBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    /**
     * @description Kicks off the batch job with the batch query.
     * @param       Database.BatchableContext bc - the context of the batch.
     * @return      Database.QueryLocator - an object which holds records that will be passed to the execute methods in batch.
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        //Batch_Job_Settings__c bjSettings = Batch_Job_Settings__c.getValues('default_setting');
        string queryStr = 'Select r.Status__c, r.Request_apiPath__c, r.Request_apiArguments__c, r.ObjectName__c, r.ObjectId__c, r.Name, r.LastProcessedTime__c, r.Id, r.FieldName__c, r.FailedCount__c From REST_Queue_Message__c r where r.Status__c in (\'Ready-to-Process\', \'Processed-Failed\') order by LastModifiedDate ' ;
        if(Test.isRunningTest()){
            queryStr += ' LIMIT 1 ';
        }
        return Database.getQueryLocator(queryStr);
    }
    
    /**
     * @description Executes one batch (10 records), only 10 callouts are allowed per batch.
     * @param       Database.BatchableContext bc - the context of the batch.
     * @return      List<SObject> scope - the set of records in this batch.
     */
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        
        List<REST_Queue_Message__c> queueMsgsForUpdate = new List<REST_Queue_Message__c>();
        List<REST_Queue_Error__c> queueErrorForInsert = new List<REST_Queue_Error__c>();
        Map<String, Map<String, Dom.Document>> magentoIdMap = new Map<String, Map<String, Dom.Document>>();
        String msessionId = POS_MagentoIntegrationUtil.getMagentoSessionId();
        for(SObject sObj : scope) {         
            REST_Queue_Message__c msg = (REST_Queue_Message__c)sobj;
            System.debug('**** Name -'+ msg.Name + ' msg.Request_apiPath__c -'+ msg.Request_apiPath__c + ' msg.Status__c -' 
                    + msg.Status__c + ' msg.ObjectName__c' + msg.ObjectName__c );

                // synchronous callout to Magento
                Dom.Document resp = POS_MagentoIntegrationUtil.getMagentoCallDocument(msessionId, msg.Request_apiPath__c, msg.Request_apiArguments__c); 
                String status = POS_MagentoIntegrationUtil.getMagentoResponseElement(resp, 'status');
                
                msg.LastProcessedTime__c = DateTime.now();
                msg.Response_Body__c = resp.toXmlString();
                    
                if(status != 'success') { 
                    if(msg.Status__c == 'Ready-to-Process' || msg.FailedCount__c == null) {
                        msg.FailedCount__c = 0; // reset the failed count is the status was changed back to Ready
                    }
                    msg.FailedCount__c = msg.FailedCount__c + 1.0;
                    if (msg.FailedCount__c >=3) {
                        msg.Status__c = 'Failed-3-Attempts';
                    } else {
                        msg.Status__c = 'Processed-Failed';
                    }
                    
                    // insert a record into REST_Queue_Error__c
                    REST_Queue_Error__c err = new REST_Queue_Error__c(REST_Queue_Message__c=msg.id, name=msg.name+'-'+msg.FailedCount__c, ErrorBody__c=resp.toXmlString());
                    queueErrorForInsert.add(err);
                    
                } else { // respose status == success
                    msg.Status__c = 'Processed-Successfully';
                    if(resp != null && msg.ObjectName__c != null && msg.ObjectName__c!='') {
                        
                        // create Map of all successful calls to update the MagentoId back on to the record
                        Map<String, Dom.Document> m2 = new Map<String, Dom.Document>();
                        m2.put(msg.ObjectName__c, resp);
                        magentoIdMap.put(msg.ObjectId__c, m2);
                        
                    }
                }
                    
                queueMsgsForUpdate.add(msg);
             }
         
             // looping through the map to do all DML after the callouts to avoid - CalloutException: uncommitted work pending
             for (String sfdcId : magentoIdMap.keySet()){
                String idStr = (String)sfdcId;
                Map<String, Dom.Document> m2 = magentoIdMap.get(sfdcId);
                
                for (String objName : m2.keySet()){ // will contain only one entry in the Map
                    
                    System.debug('idStr ' + idStr + ' objName ' + objName);
                    try {
                        POS_MagentoIntegrationUtil.updateRecordWithMagentoId(msessionId, m2.get(objName), idStr, objName);
                    } catch(DMLException de) {
                        // do nothing to continue processing
                        // avoids aborting the Job due to Field validation errors
                         // Re-added by Jai gupta on Mar 21,2013 for case 00003906
                         // Error function enhancement for case 00043236 By Jai Gupta [Mar 29,2013]
                        //sendError(de,'Error occurred in POS_QueueProcessorBatch class','POS_QueueProcessorBatch',null);
                    }
                }
             }
        
         System.debug('**** queueMsgsForUpdate.size() -'+ queueMsgsForUpdate.size() + ' ** queueErrorForInsert.size() -'+ queueErrorForInsert.size());
        
         update(queueMsgsForUpdate);
         insert(queueErrorForInsert);
        // Re-added by Jai gupta on Mar 21,2013 for case 00003906
         
    } 
	
	// Re-Added by Jai Gupta on Mar 21,2013 to send email in case of any exception occurs for case 00003906.
	/* Error function enhancement for case 00043236 By Jai Gupta [Mar 29,2013], 
	// Added two more arguments subject and classname
	// Can be called from different classes and a generic message can be send to users.
	*/ 
	public static void sendError (Exception e, String subject, string className, string otherDetails) {
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new list<String>{'pos-order-confirmation@diageo.com','diageo.support@appirio.com'});
            //mail.setToAddresses(new list<String>{'sstearns@modelmetrics.com'});
            
            mail.setReplyTo('pos-order-confirmation@diageo.com');
            mail.setSubject(subject);
            mail.setSenderDisplayName('Diageo POS Processing');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            
            String body = 'There was an error received while processing '+className+' class: \n\n';
            
            String server = System.URL.getSalesforceBaseURL().getHost();
            
            if (server.indexOf('na7.salesforce.com')>-1) {
                body=body+'  This error was experienced in the live PRODUCTION environment\n';
            }
            else {
                body=body+'  This error was received in the SANDBOX environment and is a result of testing/development there.  Please forward '+
                    'this message to the development/qa team';
            }
            body=body+'\n\n';
            body=body+'Error occured on server: '+server;
            if(e != null){
                body=body+'\nError was: '+e.getMessage();
                body=body+'\nTrace was: \n';
                body=body+' '+e.getStackTraceString();
                body=body+'\n';
            }
            // Changes done by Jai Gupta for case 00043236 to get the additional details for HTTPRequest and HTTPResponse on May 17,2013
            if(otherDetails != '' && otherDetails != null) {
            	body += otherDetails ;
            }
            // End May 17 changes
            // Changes Done for case 00043236 Start
            if(className.equalsIgnoreCase('POS_QueueProcessorBatch')) {
            	body=body+'\nPlease check the schedule jobs and rescheduled this batch class if it is no more scheduled.';
            }
            // End for case 00043236
            mail.setPlainTextBody(body);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
        catch (Exception ex) {
            System.debug('FAILURE TO SEND EMAIL: '+ex.getMessage());
        }
    }
	
    /**
     * @description Executes when all records selected by the query have been processed.
     * @param       Database.BatchableContext bc - the context of the batch.
     */
    global void finish(Database.BatchableContext bc) {
        System.debug('Batch POS_QueueProcessorBatch Finished');
        //Build the system time of now + 10 minutes to schedule the batch apex.
        Datetime sysTime = System.now();
        sysTime = sysTime.addMinutes(5);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.debug(chron_exp);
        POS_QueueProcessorBatchScheduler queueBatchSched = new POS_QueueProcessorBatchScheduler();
        //Schedule the next job, and give it the system time so name is unique
        System.schedule('POS_QueueProcessor-Job' + sysTime.getTime(),chron_exp,queueBatchSched); 
        
        String jobid = bc.getJobId();
        system.abortjob(jobid);     
                
    }

}