trigger FileTrigger on File__c (before insert, before update) {
    TriggerFile.setClassification(Trigger.new);
    if (Trigger.isUpdate) {
        TriggerFile.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
    
}