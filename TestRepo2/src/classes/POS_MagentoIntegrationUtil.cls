/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        05/01/2012
 * @description Utility class that contains common methods supporting the Meganto Integration over REST Service.
 */

public with sharing class POS_MagentoIntegrationUtil { 
     

    //build magento endpoint url
    public static String getMagentoEndPoint() {
        try{
            POS_Magento_Configuration__c settings = POS_Magento_Configuration__c.getOrgDefaults();
            
            return settings.Magento_Endpoint__c;
        }
        catch(Exception e){ return ''; }
    }
    
    //retrieve magento session id
    public static String getMagentoSessionId() {
        
        POS_Magento_Configuration__c settings = POS_Magento_Configuration__c.getOrgDefaults();
        
        String METHOD_NAME = 'method=login';
        String USERNAME = '&username=' + settings.Magento_WS_Username__c;
        String API_KEY = '&apiKey=' + settings.Magento_API_Key__c;
        
        String endPoint = getMagentoEndPoint() ;
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setBody(METHOD_NAME + USERNAME + API_KEY);
        
        Http http = new Http();
        Dom.Document doc = new Dom.Document();
        
        if (!Test.isRunningTest()){
                HttpResponse res = http.send(req);
                doc = res.getBodyDocument();
        } else {
                String xmlString = '<?xml version="1.0" encoding="UTF-8"?> <Mage_Api_Model_Server_Handler generator="zend" version="1.0"><login><response>66a152c4973e75ce5a8a029964aa7468</response><status>success</status></login></Mage_Api_Model_Server_Handler>';
                doc.load(xmlString);
        }
        
        Dom.XMLNode root = doc.getRootElement();
        Dom.XMLNode login = root.getChildElements()[0];
        Dom.XMLNode response = login.getChildElements()[0];
        
        return response.getText();
        
    }

    // to be used for synchronous service callout from Controller
    public static Dom.Document getMagentoCallDocument(String apiPath, String optionalArguments) {
        String msessionId = getMagentoSessionId();
        return getMagentoCallDocument(msessionId, apiPath, optionalArguments, false);
    } 
    
    // to be used for synchronous service callout from Batch by passing session ID
    public static Dom.Document getMagentoCallDocument(String msessionId, String apiPath, String optionalArguments) {
        return getMagentoCallDocument(msessionId, apiPath, optionalArguments, false);
    }      
    
    // to be used for asynchronous service callout that have bulk data updates
    public static Dom.Document saveMagentoCallToQueue(String apiPath, String optionalArguments, String sObjId, String sObjTypeName) {
        
            String sObjFieldName = 'Magento_Id__c'; // it's the same for all Objects mapped to Magento 
            
            REST_Queue_Message__c msg = new REST_Queue_Message__c(Name='postMagentoCallDocument'+sObjId, ObjectId__c=sObjId, ObjectName__c=sObjTypeName, FieldName__c=sObjFieldName,
                Request_apiPath__c=apiPath, Request_apiArguments__c=optionalArguments);
            insert msg;
            
            return null;
    }  
    
    public static REST_Queue_Message__c createAsyncMagentoCall (String apiPath, String optionalArguments, String sObjId, String sObjTypeName,String sObjFieldName) {
        REST_Queue_Message__c msg = new REST_Queue_Message__c(Name='postMagentoCallDocument'+sObjId, ObjectId__c=sObjId, ObjectName__c=sObjTypeName, FieldName__c=sObjFieldName,
          Request_apiPath__c=apiPath, Request_apiArguments__c=optionalArguments);
        return msg;
    }
        
        
    public static void bulkSaveMagentoCallToQueue (List<Rest_Queue_Message__c> messages) {
        insert messages;
    }
    
    // to be used for asynchronous service callouts    
    public static Dom.Document postMagentoCallDocument(String apiPath, String optionalArguments, String sObjId, String sObjTypeName) {
        
        try {
            String msessionId = getMagentoSessionId();
            Dom.Document resp = getMagentoCallDocument(msessionId, apiPath, optionalArguments, true);

            if(resp != null && sObjTypeName != null && sObjTypeName!='') {
                updateRecordWithMagentoId(msessionId, resp, sObjId, sObjTypeName);
            }
            
            return resp;
        
        } catch(POS_MagentoIntegrationException me) {           
            System.debug('POS_MagentoIntegrationException while postMagentoCallDocument -' + me.getStackTraceString());
            saveMagentoCallToQueue(apiPath, optionalArguments, sObjId, sObjTypeName);
            return null;
            
        } catch(Exception e) {          
            System.debug('Exception while postMagentoCallDocument -' + e.getStackTraceString());
            return null;
        }
        
    }

    //perform magento api call and return dom document    
    private static Dom.Document getMagentoCallDocument(String magentoSessionId, String apiPath, String optionalArguments, boolean aSync) {
        // Changes done by Jai Gupta for case 00043236 to get the additional details for HTTPRequest and HTTPResponse on May 17,2013
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        // End for case 00043236
        try {        
            String METHOD_NAME = 'method=call';
            String SESSION_ID = '&sessionId=' + magentoSessionId;
            String API_PATH = '&apiPath=' + apiPath;
            String API_ARGUMENTS = (optionalArguments == null) ? '' : optionalArguments;
            
            String endPoint = getMagentoEndPoint();
            
            // Commented out by Jai Gupta for case 00043236 to get the additional details for HTTPRequest and HTTPResponse on May 17,2013
            //HttpRequest req = new HttpRequest();
            //End for case 00043236
            req.setEndpoint(endPoint);
            req.setMethod('POST');
            req.setTimeout(60000); // 60 secs max allowed, default is 10 sec
            req.setBody(METHOD_NAME + SESSION_ID + API_PATH + API_ARGUMENTS);
            
            System.debug('req -' + req.getBody());
            
            Http http = new Http();
            Dom.Document doc = new Dom.Document();
            
            if (!Test.isRunningTest()){
                // Changes done by Jai Gupta for case 00043236 to get the additional details for HTTPRequest and HTTPResponse on May 17,2013
                    res = http.send(req);
                // End for case 00043236
                    doc = res.getBodyDocument();
            } else {
                    String xmlString = '<?xml version="1.0" encoding="UTF-8"?><Mage_Api_Model_Server_Handler generator="zend" version="1.0"><call><status>success</status></call></Mage_Api_Model_Server_Handler>';
                    doc.load(xmlString);
            }
            
            System.debug('resp-doc -' + doc.toXmlString());
        

            String status = getMagentoResponseElement(doc, 'status');
            
            if(aSync && status != 'success') { 
                throw new POS_MagentoIntegrationException('FAILED_MAGENTO_RESPONSE_STATUS');
            }
            return doc;
            
        } catch(Exception e) { // cathc any exception that may occur during REST callout and save the request in Queue for batch processing
            System.debug('Exception while createMagentoCategory -' + e);
            // Changes done for case 00043236 By Jai Gupta [Appirio Jaipur] on Mar 29,2013
            // Sending main cause for excpetion "FAILED_MAGENTO_SERVIVE_CALL"
            // Changes done by Jai Gupta for case 00043236 to get the additional details for HTTPRequest and HTTPResponse on May 17,2013
            // Commented below code for case 00043236 as per Carlos request to send email only when the request completely fails to process June 25,13
            /*String otherDetails = '';
            otherDetails += '\nHTTPRequest :\n'+req.getBody();
            otherDetails += '\n\nHTTPResponse :\n'+res ;
            otherDetails += '\n';
            POS_QueueProcessorBatch.sendError(e,'Error origin for FAILED_MAGENTO_SERVIVE_CALL exception','POS_MagentoIntegrationUtil',otherDetails);*/
            // End forcase 00043236
            throw new POS_MagentoIntegrationException('FAILED_MAGENTO_SERVIVE_CALL');
        }        
        
    }
    
    public static void updateRecordWithMagentoId(String msessionId, Dom.Document resp, String sObjId, String sObjTypeName) {
        
        Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjTypeName);
        System.debug('sObjTypeName -' + sObjTypeName + ' Type -' + t);
        sObject newObj = (sObject)t.newSObject();
        
        String responseId = getMagentoResponseElement(resp, 'response');
        System.debug('responseId -' + responseId);
        
        if(newObj instanceof Item__c) {
            if(responseId != null && responseId != '1') { // updates should not be passing sObjTypeName, but this is double check
                Item__c o = new Item__c(id=sObjId, Magento_Id__c = responseId);
                update o;
                System.debug('Item MagentoId after update - ' + o.Magento_ID__c);
            }
            
        } else if(newObj instanceof Item_Customization__c) { // IMP: Special Handling for this as product_custom_option.add always returns 1 as magentoId.
            String option_id = getCustomOptionId(resp, sObjId);
            Item_Customization__c o = new Item_Customization__c(id=sObjId, Magento_Id__c = option_id);
            update o;
            
        } else if(newObj instanceof Item_Category__c) { // IMP: Special Handling as to update Magento_Option_Id for rollup child
            String option_id = getOptionFromRollupSelection(resp, sObjId); // sObjId is passed as chlItem.Id+'-'+chlItem.Name
            String itmId = sObjId.substring(0, sObjId.indexOf('-'));
            
            System.debug('itmId - ' + itmId + '  option_id - ' + option_id);
            Item__c o = new Item__c(id=itmId, Magento_Option_Id__c = option_id);
            update o;
            
        } else if(newObj instanceof Brand__c) {
            Brand__c o = new Brand__c(id=sObjId, Magento_Id__c = responseId);
            update o;
            
        } else if(newObj instanceof Order_Window__c) {
            Order_Window__c o = new Order_Window__c(id=sObjId, Magento_Id__c = responseId);
            update o;
            
        } else if(newObj instanceof Program__c) {
            Program__c o = new Program__c(id=sObjId, Magento_Id__c = responseId);
            update o;
            
        }
    } 
    
    private static String getOptionFromRollupSelection(Dom.Document doc, String sObjId) {

        if (doc == null)   {
            System.debug('parameter doc is null');
            return '';
        }
        System.debug('getOptionFromRollupSelection doc = ' + doc.toXmlString());
        System.debug( '*** sObjId-' + sObjId);
        
        Integer dividerPos = sObjId.indexOf('-');
        System.debug('***** dividerPos-' + dividerPos);
        
        String itmId = sObjId.substring(0, dividerPos);
        String itmName = sObjId.substring(itmId.length()+1);   
    
        System.debug('doc.toXmlString() - ' + doc.toXmlString());
        Dom.XMLNode root = doc.getRootElement();
        Dom.XMLNode call = root.getChildElements()[0];
        
        System.debug('call.getChildElements().size() - ' + call.getChildElements().size());
        for(Dom.XMLNode keyNode : call.getChildElements()) {
            
            Dom.XMLNode labelNode = keyNode.getChildElement('label', null); 
            System.debug('labelNode - ' + labelNode);
            
            if(labelNode != null) {
                System.debug('labelNode.getText().trim() -' + labelNode.getText().trim() + '-');
                System.debug('itmName.trim() -' + itmName.trim() + '-');
            }
            
            if(labelNode != null && labelNode.getText().trim() == itmName.trim()) {
                Dom.XMLNode valueNode = keyNode.getChildElement('value', null); 
                System.debug('valueNode - ' + valueNode);
                if(valueNode != null && valueNode.getText() != '') {
                    return valueNode.getText().trim();
                }
            }
        }
        
         return '';
    }     
    
    
    private static String getCustomOptionId(Dom.Document doc, String iCustId) {
        Item_Customization__c iCust = [SELECT id, Name, Item__c from Item_Customization__c where id=:iCustId];
    
        System.debug('getCustomOptionId doc = ' + doc);
        if (doc == null)   {
            System.debug('parameter doc is null');
            return '';
        }
        
        Dom.XMLNode root = doc.getRootElement();
        Dom.XMLNode call = root.getChildElements()[0];
        
        String option_id = '';
        for(Dom.XMLNode key : call.getChildElements()) {
            
            Boolean ttlMatch = false;
            for(Dom.XMLNode node : key.getChildElements()) {
                if(node.getName() == 'option_id') {
                    option_id = node.getText();
                }
                if(node.getName() == 'title' && node.getText() == iCust.Name) {
                    ttlMatch = true;
                }
            }
            
            if(ttlMatch) {  //key_n node corresponding to Option Name title 
                return option_id;
            }
        }       
        
        
        return '';  
    } 
    
    //parse magento response and return value corresponding to the requested child element    
    public static String getMagentoResponseElement(Dom.Document doc, String element) { 
        if (doc == null)   {
            System.debug('parameter doc is null');
            return '';
        }
        
        Dom.XMLNode root = doc.getRootElement();
        Dom.XMLNode call = root.getChildElements()[0];
        
        String responseId = '';
        for(Dom.XMLNode node : call.getChildElements()) {
            if(element == node.getName()) {
                responseId = node.getText();
            }
        }  
        
        return responseId;
    }  
    
    //Get the user ID of a magento user based on SFDC ID
    public static String getMagentoCustomerId (String sfdcUserId) {
        //String MAGENTO_SESSION_ID = POS_MagentoIntegrationUtil.getMagentoSessionId();
        
        //Need to cut ID down to the 15 character version as that's what's passed in SSO 
        sfdcUserId=sfdcUserId.substring(0,15);
        
        System.debug('Sending SFDC ID: '+sfdcUserId);
        String API_ARGUMENTS = '&arg2[customer][diageo_id]='+ sfdcUserId;
        
        Dom.Document doc = POS_MagentoIntegrationUtil.getMagentoCallDocument('customer.list', API_ARGUMENTS);
        
        System.debug('Returned XML: '+doc.toXmlString());
        String customerId;
        String status = getMagentoResponseElement(doc, 'status');
        System.debug('Status of magento response: '+status);
        
        if (status=='success') {
            //A result was found so parse the DOM tree to get it
            System.debug('Parsing dom tree...');
            try {
                Dom.XmlNode path = doc.getRootElement().getChildElement('call',null).getChildElement('key_0',null);
                Dom.XmlNode customerIdNode = path.getChildElement('customer_id', null);
                System.debug('Customer ID node: '+customerIdNode);
                customerId = customerIdNode.getText();
            }
            catch (Exception e) {
                System.debug('No matching salesforce Id.  Improperly setup user');
            }
        }
        System.debug('Magento customer Id: '+customerId);
        return customerId;
    }
    
}