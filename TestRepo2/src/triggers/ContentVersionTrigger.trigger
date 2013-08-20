/*******************************************************************************
Name        : ContentVersionTrigger.trigger

Updated By  : Basant Verma (Appirio Offshore)   
Date        : 6/5/13
Story/Task  : US79/TA1001
Description : Trigger on ContentVersion to "subscribe" users to receive email 
                            notifications whenever a new ContentVersion record is created
*******************************************************************************/
trigger ContentVersionTrigger on ContentVersion (after insert, after update) {
    if(Trigger.isAfter && Trigger.isInsert){
        ContentVersionTriggerHandler.onAfterInsert(Trigger.newMap);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        ContentVersionTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}