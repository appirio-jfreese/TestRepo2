trigger CaseStatusUpdate on Case (before update) {

//
// (c) Appirio
// When Case Status is updated to "Waiting on Customer Acceptance", then update "Resolution Timestamp"
// to the current date/time
// 

 
  // this trigger should only run on individual Case update, not bulk loads.
  if (Trigger.new.size() == 1) {
    Case c = Trigger.new[0];

    if ((c.Status == 'Waiting on Customer Acceptance') && (Trigger.oldMap.get(c.Id).Status != 'Waiting on Customer Acceptance')) {
        c.Resolution_Timestamp__c = System.now();
        
        // Calculate the Business Hours elapsed from case creation until now.
        Id businessHoursId = c.BusinessHoursId;
        if (businessHoursId == null) {
          BusinessHours bh  = [SELECT Id 
                               FROM   BusinessHours 
                               WHERE  IsDefault = true];
          businessHoursId = bh.id;
        }
        
        system.debug('Business Hours Id = ' + businessHoursId);

        //The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
        c.Resolution_Time_Hours__c = BusinessHours.diff(businessHoursId, c.CreatedDate, System.now())/3600000.0;
        
        
      }
    }
    
}