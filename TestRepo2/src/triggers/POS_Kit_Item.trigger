/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        06/12/2012
 * @description validate to make sure there are no duplicate Kit items added to the same Kit
 
  @Modofied By Rahul Chitkara(Appirio Jaipur) on 25th March 2013 
  Case no - 00004511
 */
 
trigger POS_Kit_Item on Kit_Item__c (before insert, before update, before delete) {
    
    Set<Id> kitIds = new Set<Id>();
    if (trigger.isDelete) {
        for(Kit_Item__c k : trigger.old) {
            kitIds.add(k.Kit__c);
        }   
        
       
        //cubasc 3-13-2013 - added a where condition to the query to filter out the kitmasters that are in approved and accepted status.  These records should be allowed to be deleted.
        Map<Id, Item__c> kitsWithExistingItems = new Map<Id, Item__c>([Select id, (select k.Id From Kit_Items__r k) from Item__c where id in :kitIds and status__c IN ('Accepted w/Final Price', 'Approved w/Est Price')]);        
        for(Kit_Item__c k : trigger.old) {   
        // Modified By Rahul Chitkara - Check for Map size Case  - 00004511, 25th March         
         if(kitsWithExistingItems.size() > 0){
             /*  List<Kit_Item__c> existingKitItems = kitsWithExistingItems.get(k.Kit__c).Kit_Items__r;        
                System.debug('----existingItems'+existingKitItems.size());
                if(existingKitItems.size() <= 2 ) {
    
                    k.addError('Kit must contain at least two different items while in status Approved or Accepted');
                }   */
                
             k.addError('Kit Item can not be deleted while Kit Master item in status Approved or Accepted') ;
                // End Changes 00004511
            }                 
        }           
        
    }  else {
    
        for(Kit_Item__c k : trigger.new) {
            kitIds.add(k.Kit__c);
        }
        
        Map<Id, Item__c> kitsWithExistingItems = new Map<Id, Item__c>([Select id, (select k.Id, k.Name, k.Kit__c, k.Item__c From Kit_Items__r k) from Item__c where id in :kitIds]);
        
        for(Kit_Item__c k : trigger.new) {
            Boolean duplicateExists = false;
            List<Kit_Item__c> existingKitItems = kitsWithExistingItems.get(k.Kit__c).Kit_Items__r;
            
            for(Kit_Item__c l : existingKitItems) {
                if(l.id != k.id && l.Item__c == k.Item__c) {
                    duplicateExists = true;
                    break;
                }
            }
            
            if(duplicateExists) {
                k.addError('This kit-item already exists on the Kit. Cannot add duplicate.');
            }
        }
    }
    
}