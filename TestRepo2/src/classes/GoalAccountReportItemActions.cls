public with sharing class GoalAccountReportItemActions {

	public static void copyFieldsFromAccount(List<Goal_Account_Report_Item__c> garis){
		Set<Id> accIds = new Set<Id>();
		for(Goal_Account_Report_Item__c gari : garis){
			if(gari.Account__c != null){
				accIds.add(gari.Account__c);
			}
		}
		Map<Id, Account> accsById = new Map<Id, Account>([SELECT Id, OwnerId, Owner.FirstName, Owner.LastName, Primary_Demographic__c FROM Account WHERE Id IN :accIds]);
		
		for(Goal_Account_Report_Item__c gari : garis){
			if(gari.Account__c != null){
				Account acc = accsById.get(gari.Account__c);
				if(acc != null){
					gari.Primary_Demographic__c = acc.Primary_Demographic__c;
					if(acc.OwnerId != null){
						gari.User__c = acc.Owner.FirstName + ' ' + acc.Owner.LastName;
					}
				}
			}
		}
	}

}