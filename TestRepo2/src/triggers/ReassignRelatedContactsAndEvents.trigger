trigger ReassignRelatedContactsAndEvents on Account (before update, after update) {
   try {
      Set<Id> accountIds = new Set<Id>(); 
      Map<Id, String> oldOwnerIds = new Map<Id, String>(); 
      Map<Id, String> newOwnerIds = new Map<Id, String>(); 
      Contact[] contactUpdates = new Contact[0]; 
      Event[] eventUpdates = new Event[0];
      Action__c[] actionUpdates = new Action__c[0];
      system.debug('----Line 8----');
      
      for (Account a : Trigger.new) { 
         if (a.OwnerId != Trigger.oldMap.get(a.Id).OwnerId) {
            oldOwnerIds.put(a.Id, Trigger.oldMap.get(a.Id).OwnerId); 
            newOwnerIds.put(a.Id, a.OwnerId); 
            accountIds.add(a.Id); 
            system.Debug('----Line 15 accountId----' + accountIds);
         }
      }
          
        if ( accountIds != null) {
         for (Account act : [SELECT Id, (SELECT Id, OwnerId FROM Contacts), (SELECT Id, OwnerId FROM Events), (Select Id, OwnerId FROM Actions__r) FROM Account WHERE Id in :accountIds]) { 
            String newOwnerId = newOwnerIds.get(act.Id); 
            String oldOwnerId = oldOwnerIds.get(act.Id);
            
     
            system.Debug('----Line 25 oldOwnerIds----' + oldOwnerIds);
            system.Debug('----Line 26 act.Contacts----' + act.Contacts);
            for (Contact c : act.Contacts) {
             system.Debug('----Line 28 act.Contacts----'+ act.Contacts);
               if (c.OwnerId == oldOwnerId) {
                system.Debug('----Line 30 oldOwnerID----'+ oldOwnerId);
                  Contact updatedContact = new Contact (Id = c.Id, OwnerId = newOwnerId);
                   system.Debug('----Line 29 updatedContact----'+ updatedContact);
                  contactUpdates.add(updatedContact); 
               }
            }
            for (Event e : act.Events) { 
              system.Debug('----Line 34 OwnerId----'+ e.OwnerId);
               if (e.OwnerId == oldOwnerId) { 
                  system.Debug('----Line 36 oldOwnerID----'+ oldOwnerId);
                  Event updatedEvent = new Event (Id = e.Id, OwnerId = newOwnerId); 
                  system.Debug('----Line 38 newOwnerID----' + updatedEvent);
                  EventUpdates.add(updatedEvent); 
               }
            }
           for (Action__c ac : act.Actions__r) { 
              if(ac.OwnerId == oldOwnerId) { 
                 Action__c updatedAction = new Action__c (Id = ac.Id, OwnerId = newOwnerId); 
                 actionUpdates.add(updatedAction); 
           	  }
           }                
        }
         
         update actionUpdates;
         update contactUpdates;
         update EventUpdates; 
      }
   }  catch(Exception e) { 
      System.Debug('reassignRelatedContactsAndOpportunities failure: '+e.getMessage()); 
   }
}