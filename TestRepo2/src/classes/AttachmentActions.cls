public with sharing class AttachmentActions {
	
	public static void updateParentActions(List<Attachment> attList){
		//get Action ID prefix
		Schema.DescribeSObjectResult actionDescribe = Schema.SObjectType.Action__c;
		String actionPrefix = actionDescribe.getKeyPrefix();
		
		//Create set of action IDs
		Set<Id> actionIds = new Set<Id>();
			
		//Get action IDs from attachments whose parents are indeed actions
		for(Attachment att : attList){
			if(String.valueOf(att.ParentId).startsWith(actionPrefix)){
				actionIds.add(att.ParentId);
			}
		}
		
		//Update those parent actions
		if(actionIds.size() > 0){
			List<Action__c> actionsToUpdate =
				[SELECT Id,
						(SELECT Id
						   FROM Attachments
						  LIMIT 1
						)
				   FROM Action__c
				  WHERE Id IN :actionIds
				];
				
				
			for(Action__c action : actionsToUpdate){
				action.Has_Attachment__c = action.Attachments.size() > 0;
			}
			
			update actionsToUpdate;
		}
	}
	
	public static void updateParentAccounts(List<Attachment> attList){
		//get Account ID prefix
		Schema.DescribeSObjectResult actionDescribe = Schema.SObjectType.Account;
		String accountPrefix = actionDescribe.getKeyPrefix();
		
		//Create set of account IDs
		Set<Id> accountIds = new Set<Id>();
			
		//Get action IDs from attachments whose parents are indeed accounts
		for(Attachment att : attList){
			if(String.valueOf(att.ParentId).startsWith(accountPrefix)){
				accountIds.add(att.ParentId);
			}
		}
		
		//Update those parent accounts
		if(accountIds.size() > 0){
			List<Account> accountsToUpdate =
				[SELECT Id,
						(SELECT Id
						   FROM Attachments
						  LIMIT 1
						)
				   FROM Account
				  WHERE Id IN :accountIds
				];
				
				
			for(Account acc : accountsToUpdate){
				acc.Has_Attachment__c = acc.Attachments.size() > 0;
			}
			update accountsToUpdate;
		}
	}

}