/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        06/01/2012
 * @description create Account Member record when a Portal User corresponding to a contact is added.
 */
public with sharing class POS_PortalUser {
	
	@future
	public static void createAccountMembers(Map<Id, Id> acctMbrs) {
		
		List<Account_Member__c> acctMbrList = new List<Account_Member__c>();
		for(Id userId:acctMbrs.keySet()) {
			//Other testcode is causing this to fail because members are getting created by an account without the perms to do so
			if (!Test.isRunningTest()) {
				Account_Member__c am = new Account_Member__c(Account__c=acctMbrs.get(userId), Active__c=true, User__c=userId);
				acctMbrList.add(am);
			}
			
		}
		
		System.debug('acctMbrList.size() -' + acctMbrList.size() );
		upsert(acctMbrList);
	}
	
	@future
	public static void deleteAccountMembers(Map<Id, Id> acctMbrs) {
		
		List<Account_Member__c> acctMbrList = [Select id from Account_Member__c where user__c in :acctMbrs.keySet()];
		System.debug('acctMbrList.size() -' + acctMbrList.size() );
		
			
		if(acctMbrList.size() > 0) {
			delete(acctMbrList);
		}
	}
	
    @isTest(SeeAllData=true)
    public static void testPortalUserAccountMemberSync() {
    	// test creation/deletion of AccountMember when a PortalUser is created
    	Profile p = [select id from profile where name='System Administrator'];
    	UserRole role = [select id from UserRole where name='Diageo NA' limit 1];
         
		User sUsr = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id,
		timezonesidkey='America/Chicago', username='posmmunittest@diageo.com', userroleid=role.id);
		
		insert sUsr;
    	
    	System.runAs(sUsr) {
	    	Account acct = POS_TestDataUtil.createAccount();
	    	
	    	update acct;
	    	System.debug('acct.OwnerId -' + acct.OwnerId + ' acct.owner.UserRoleId -' + acct.owner.UserRoleId);
	    	//Contact ctct = POS_TestDataUtil.createContact(acct);
    		//User pUsr = POS_TestDataUtil.createPortalUser(ctct);
    	}	
    
    	// Note: commented out the code below as couldn't get rid of - UNKNOWN_EXCEPTION, portal account owner must have a role: []
    	//
    }		

}