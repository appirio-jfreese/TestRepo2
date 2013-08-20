/*************************************************************************
Name : Test_Task_After_Insert
Author : Nimit Walia, (Appirio Offshore)
Date : February 2013
Usage : This class covers the code for the Trigger "Task_After_Insert"
 
Created for Case 00039908
**************************************************************************/

@isTest
private class Test_Task_After_Insert{
    
    static testMethod void testTaskInsertTrigger(){
    
        Case testCase = new Case();
        testCase.First_Name__c = 'FirstName';
        testCase.Last_Name__c = 'LastName';
        insert testCase;
        
        Task testTask = new Task();
        testTask.whatId = testCase.id;
        testTask.subject = 'Test Subject';
        testTask.Status = 'Completed';
        insert testTask;
        
        testCase = [select id, Initial_Response_Timestamp__c from Case where id=:testCase.id];
        /* Modified by - Rahul Chitkara(Appirio Offshore)
        Date - 28th Feb
        */
        Datetime systemNow = Test_Task_After_Insert.getDateTimeObj(System.now()) ;
        Datetime initialResponseTime =  Test_Task_After_Insert.getDateTimeObj(testCase.Initial_Response_Timestamp__c);    
        system.assertEquals(systemNow,initialResponseTime);
        System.debug('-----System Value'+systemNow+'-----InitialResponseTime'+initialResponseTime);
    
    }
    private static Datetime getDateTimeObj(Datetime dt){
        Integer year = dt.year();
        Integer month= dt.month();
        Integer day = dt.day();
        Integer hour= dt.hour();  
        Integer minute = dt.minute();  
        return datetime.newInstance(year, month, day, hour, minute, 0);
    }
    
    //End Changes

}