trigger SurveyLayoutTrigger on Survey_Layout__c (after insert, after update, before insert, before update, before delete, after delete) 
{
    
    if (trigger.isBefore) {
        if (trigger.isInsert) {
            
            for( Survey_Layout__c layoutItem : trigger.new ) {
                if(layoutItem.Activate_Survey__c == true){}
                    // Line below (10) commented by Diana Acker, Oct 17, 2012, Appirio Case 00034196, testing survey creation
                    // layoutItem.Activate_Survey__c = false ;
            }
            
            
        } 
        
        if (trigger.isUpdate) {
            
            for( Survey_Layout__c oldLayoutItem : trigger.old ) {
                if(oldLayoutItem.Activate_Survey__c == true) {
                    Survey_Layout__c newLayoutItem = trigger.newMap.get(oldLayoutItem.Id);
                    if(newLayoutItem.Clone_Survey_Layout__c == false) {
                        newLayoutItem.addError('You cannot edit a survey after activation.');
                    }
                }
            }
            
            SurveyLayoutTriggerActions.cloneSurveyLayoutRecordsIfApplicable(trigger.newMap) ;
        }
    }
    
    if (trigger.isAfter) {
        if (trigger.isInsert) {
            //Line below (34) was uncommented by Diana Acker, 10/16/2012, Appirio Case 00034196, testing survey layout creation
            SurveyLayoutTriggerActions.createAccountSurveyRecordsFromLayoutRecord(trigger.newMap, trigger.oldMap) ;
        }
        
        if (trigger.isUpdate) {
             //Line below (39) was uncommented by Diana Acker, 10/19/2012, Appirio Case 00034196, testing survey layout creation
            SurveyLayoutTriggerActions.createAccountSurveyRecordsFromLayoutRecord(trigger.newMap, trigger.oldMap) ;
        }
        
        
        if(trigger.isDelete) {
            SurveyLayoutTriggerActions.removeSurveyRecordsOnLayoutDelete(trigger.oldMap);
        }
    }
    
    
    
    
}