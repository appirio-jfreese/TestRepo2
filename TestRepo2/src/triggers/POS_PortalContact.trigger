/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        06/01/2012
 * @description Keeps Contact and Portal User on Account as Account Member in sync
 */
trigger POS_PortalContact on Contact (after delete) {

	// query all the user that were linked to the contact being deleted
	/*List<User> usersWithContact = [SELECT Id, AccountId, ContactId FROM User where ContactId in :trigger.old];
	
	List<Account_Member__c> acctMbrList = new List<Account_Member__c>();
	for(User n : usersWithContact) {
				
		Account_Member__c am = new Account_Member__c(Account__c=n.AccountId, Active__c=true, User__c=n.Id);
		acctMbrList.add(am);
	}	
	
	System.debug('acctMbrList.size() -' + acctMbrList.size() );	*/

}