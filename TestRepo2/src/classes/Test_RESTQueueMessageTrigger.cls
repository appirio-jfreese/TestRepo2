/* Created by Jai gupta [Appirio Jaipur]
   created date June 26, 2013
   Test class for : RESTQueueMessageTrigger

 **/
@isTest
public class Test_RESTQueueMessageTrigger  {

    public static testmethod void testTrigger(){
        REST_Queue_Message__c msg = new REST_Queue_Message__c(Name='postMagentoCallDocumentsObjId', ObjectId__c='sObjId', ObjectName__c='sObjTypeName', FieldName__c='sObjFieldName',
                Request_apiPath__c='apiPath', Request_apiArguments__c='optionalArguments');
        insert msg ;
                
        msg.Status__c = 'Failed-3-Attempts';
        update msg;
    }
}