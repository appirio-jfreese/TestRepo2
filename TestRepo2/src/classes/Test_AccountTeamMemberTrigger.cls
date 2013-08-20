@isTest
public class Test_AccountTeamMemberTrigger {

	public static testmethod void testTrigger(){
		Test.starttest();
			Id uid = Userinfo.getUserId();
			Account account = new Account(Name = 'a');
			insert account;
			User user = new User(Id = uid); 
			Account_Member__c member = new Account_Member__c(Account__c = account.id, User__c = user.Id);
			insert member;
			
			Account_Member__c member1a = new Account_Member__c(User__c = uid, Account__c=account.id, Default__c = true);
			Account_Member__c member1 = new Account_Member__c(User__c = uid, Account__c=account.id, Default__c = true);
			Account_Member__c member2 = new Account_Member__c(User__c = uid, Account__c=account.id, Default__c = true);
			insert member1a;
			List<Account_Member__c> members = new List<Account_Member__c>();
			members.add(member1);
			members.add(member2);
			try{
				insert members;
				system.assert(false);
			} catch(Exception ex){
				//ok
			}
			delete member;
			try{
				delete member1a;
				system.assert(false);
			} catch(Exception ex){
				//ok
			}
		Test.stoptest(); 
	}

}