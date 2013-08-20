/*************************************************************************
Name : Test_CaseStatusUpdate
Author : Rahul Chitkara, (Appirio Offshore)
Date : February 2013
Usage : This class covers the code for the Trigger "CaseStatusUpdate "
 
Created for Case 00039908
**************************************************************************/

@isTest
private class Test_CaseStatusUpdate{
    
    static testMethod void testCaseStatusUpdateTrigger(){
        Case testCase = new Case();
        testCase.First_Name__c = 'FirstName';
        testCase.Last_Name__c = 'LastName';
        testCase.Status = 'New';
        testCase.BusinessHoursId = null;
        insert testCase;
        testCase.Status = 'Waiting on Customer Acceptance';
        update testCase;
        testCase = [select id,Resolution_Timestamp__c from Case where  id=:testCase.id];
        /* 
        Modified By - Rahul chitkara(Appirio Jaipur)
        Modified Date- 28th March        
        */
        Datetime systemNow = Test_CaseStatusUpdate.getDateTimeObj(System.now()) ;
        Datetime resolutionTimeStamp =  Test_CaseStatusUpdate.getDateTimeObj(testCase.Resolution_Timestamp__c);
        system.assertEquals(systemNow, resolutionTimeStamp);                           
    }
     private static Datetime getDateTimeObj(Datetime dt){
        Integer year = dt.year();
        Integer month= dt.month();
        Integer day = dt.day();
        Integer hour= dt.hour();  
        Integer minute = dt.minute();  
        return datetime.newInstance(year, month, day, hour, minute, 0);
    }
    


}