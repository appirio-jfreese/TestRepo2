/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        06/01/2012
 * @description create Account Member record when a Portal User corresponding to a contact is added.
 *
 *
 * Modified By	: 	Basant Kumar Verma (Appirio OffShore)
 * Date					:		07/25/2013
 * Story/Task		:		It was unnecessarily calling future method which hit SFDC Governor Limits
 *
 */
trigger POS_PortalUser on User (after insert, after update) {
	
	Map<Id, Id> acctMbrMap = new Map<Id, Id>();
	
	if (trigger.isInsert) {	
		List<User> usersWithContact = [SELECT Id, AccountId, ContactId FROM User where ContactId != null and id in :trigger.new];
		
		for(User n : usersWithContact) {
			acctMbrMap.put(n.Id, n.AccountId);
			
		}	
		
		System.debug('acctMbrMap.keySet().size() -' + acctMbrMap.keySet().size() );
		// workaround done to avoid MIXED_DML_OPERATION error by calling @future method as to create seperate transaction context
		// START - Changed by Basant - It was unnecessarily calling future method which hit SFDC Governor Limits
		if(acctMbrMap != null && acctMbrMap.size() > 0){
			POS_PortalUser.createAccountMembers(acctMbrMap);
		}
		// END - Changed by Basant - It was unnecessarily calling future method which hit SFDC Governor Limits
	
	} else if (trigger.isUpdate) {
		   //List<Id> contactIds = new List<Id>();
		   for(User n : trigger.new) {
				
				User o = trigger.oldMap.get(n.id);
				System.debug('o.IsPortalEnabled -' + o.IsPortalEnabled + ' n.IsPortalEnabled -' + n.IsPortalEnabled + 
					' o.ContactId -' + o.ContactId + ' n.ContactId -' + n.ContactId );
					
				//add to the list for deleting AccountMembers only if the Contact field on the User was cleared and portal user was disabled
				if (o.IsPortalEnabled==true && n.IsPortalEnabled==false) {
					 // Account Id of the Contact previously associated with this Portal User
					 // Note: the ContactId is not cleared on the new record at this point, which is against the typically expected behaviour
					 acctMbrMap.put(n.id, o.AccountId);
				}
		   }
		  
		System.debug('acctMbrMap.keySet().size() Update -' + acctMbrMap.keySet().size() );
		// workaround done to avoid MIXED_DML_OPERATION error by calling @future method as to create seperate transaction context
		// START - Changed by Basant - It was unnecessarily calling future method which hit SFDC Governor Limits
		if(acctMbrMap != null && acctMbrMap.size() > 0){
			POS_PortalUser.deleteAccountMembers(acctMbrMap);
		}
		// END - Changed by Basant - It was unnecessarily calling future method which hit SFDC Governor Limits		   
	}

}