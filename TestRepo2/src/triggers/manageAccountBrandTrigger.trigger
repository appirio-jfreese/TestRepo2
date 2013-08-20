/**
* @author Denise Bacher
* @date 26/08/2011
* @description Insert a new AccountBrand join record for the Diageo account when inserting a new brand
*				Delete all AccountBrand records and all child/grandchild Brand records when a brand is deleted
*/
trigger manageAccountBrandTrigger on Brand__c (after insert, after delete) {
	List<AccountBrand__c> accBrands = new List<AccountBrand__c>();    
	if(trigger.isInsert){
		//Need to limit resultset to Diageo accounts that are marked as a Distributor
	    List<Account> accounts = [SELECT Id FROM Account WHERE Name LIKE 'Diageo' and RecordType.Name='Distributor'];
	    for (Account account:accounts) {
	    	
		    for(Brand__c b : Trigger.new){
	            accBrands.add(new AccountBrand__c(name='Diageo ' + b.name, Brand__c = b.id, Account__c = account.id));
		    }
	    }
	    insert accBrands;
	} else {
		Set<ID> brandIDs = new Set<ID>();
		for (Brand__c b : Trigger.old){
			brandIDs.add(b.ID);
		}
		List<Brand__c> childBrands = [SELECT Id FROM Brand__c WHERE Parent_Brand__c IN :brandIDs AND Id NOT IN :brandIDs];
		accBrands = [select id, name from AccountBrand__c where Brand__c in :brandIDs];
		delete accBrands;
		delete childBrands;
	}
}