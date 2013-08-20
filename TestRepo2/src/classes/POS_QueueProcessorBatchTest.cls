/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        12/01/2011
 * @description Contains unit tests for the POS_QueueProcessorBatch class
 
 * Modified By : Jai Gupta [Appirio Jaipur]
 * Modified Date : Jan 31,2013
 * Related to Case : 00003851 (Test class was failing due to some changes in POS_QueueProcessorBatch class)
 **/

@isTest 
private class POS_QueueProcessorBatchTest {
    
    static User u = new user();
    static {
    	POS_Magento_Configuration__c settings = new POS_Magento_Configuration__c();
    	settings.Magento_WS_Username__c = 'xyz@abc.com';
        settings.Magento_API_Key__c = '12312';
        settings.Name = 'Test123';
        settings.BRAND_CATEGORY__c= 'wine';
        settings.Magento_Endpoint__c='http://google.com';
        settings.ORDERWINDOW_CATEGORY__c = 'test';
        settings.PROGRAM_CATEGORY__c='test prg';
        settings.TYPE_BRAND__c='testing';
        settings.TYPE_ORDER_WINDOW__c='test OW';
        settings.TYPE_PROGRAM__c = 'testing';
        insert settings ;
    	
        Profile p = [select id from profile where name='POS - API User Agency'];
         
        u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id,
        timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
    }
    
    static testMethod void testCreate() {
        System.runAs(u) {       
            Brand__c brd1=POS_TestDataUtil.createBrand();
            REST_Queue_Message__c msg1 = new REST_Queue_Message__c(name='postMagentoCallDocumenta-test1', 
                                            Request_apiPath__c='category.create', Request_apiArguments__c='&arg2[parentId]=95&arg2[category][name]=UB+Light&arg2[category][is_active]=1&arg2[category][include_in_menu]=1&arg2[category][available_sort_by]=name&arg2[category][default_sort_by]=name',
                                            status__c='Ready-to-Process', ObjectName__c='Brand__c', ObjectId__c=brd1.id, FieldName__c='Magento_id__c');
            insert msg1; 
            
            System.debug('**** brd1.id -'+ brd1.id);
            Test.startTest();
            Database.executeBatch(new POS_QueueProcessorBatch());
            Test.stopTest();
            
            // always place the Assert check after the Test.stopTest() as executeBatch runs asynchronously
            REST_Queue_Message__c m1 = [select Id, LastProcessedTime__c, Status__c from REST_Queue_Message__c where ObjectId__c =: brd1.id];
            System.debug('****m1 LastProcessedTime__c -'+ m1.LastProcessedTime__c + ' Status__c -'+ m1.Status__c);
            
            system.assertEquals('Processed-Successfully', m1.Status__c);
              
        }      
        
    }
    
    static testMethod void testUpdate() {
        
        System.runAs(u) {       
            
            Brand__c brd2=POS_TestDataUtil.createBrand();
            REST_Queue_Message__c msg2 = new REST_Queue_Message__c(name='postMagentoCallDocumenta-test2', 
                                            Request_apiPath__c='category.update', Request_apiArguments__c='&arg2[categoryId]=7&arg2[category][name]=UB+Royal&arg2[category][is_active]=1&arg2[category][include_in_menu]=1&arg2[category][available_sort_by]=name&arg2[category][default_sort_by]=name',
                                            status__c='Ready-to-Process', ObjectName__c='Brand__c', ObjectId__c=brd2.id, FieldName__c='Magento_id__c');
            insert msg2;                                            
            
            System.debug('**** brd2.id -'+ brd2.id);
            Test.startTest();
            Database.executeBatch(new POS_QueueProcessorBatch());
            Test.stopTest();
            
            // always place the Assert check after the Test.stopTest() as executeBatch runs asynchronously
            REST_Queue_Message__c m2 = [select Id, LastProcessedTime__c, Status__c from REST_Queue_Message__c where ObjectId__c =: brd2.id];
            System.debug('****m2 LastProcessedTime__c -'+ m2.LastProcessedTime__c + ' Status__c -'+ m2.Status__c);        
    
            system.assertEquals('Processed-Successfully', m2.Status__c); 
              
        }      
        
    }
}