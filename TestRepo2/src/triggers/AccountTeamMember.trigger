trigger AccountTeamMember on Account_Member__c (after delete, before insert, before update) {
    if(Trigger.isUpdate || Trigger.isInsert){
        TriggerAccountTeamMemberHandler.beforeUpdateOrInsert(Trigger.new, Trigger.old);
    }
    if(Trigger.isDelete){
        TriggerAccountTeamMemberHandler.afterDelete(Trigger.new, Trigger.old);
    } else if(Trigger.isInsert){
        TriggerAccountTeamMemberHandler.beforeInsert(Trigger.new, Trigger.old);
    }
}