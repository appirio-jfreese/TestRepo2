trigger AccountBrandSetName on AccountBrand__c (before insert, before update) {

	Id[] BrandIds = new Id[]{};
	Id[] AccountIds = new Id[]{};
	for(AccountBrand__c a : trigger.new){
		BrandIds.add(a.Brand__c);
		AccountIds.add(a.Account__c);
	}
	
	Map <Id,Brand__c> brands = new Map<Id,Brand__c>([select id, name from Brand__c where  id in :BrandIds]);
	Map <Id,Account> accounts = new Map<Id,Account>([select id, name from Account where  id in :AccountIds]);
	
	for(AccountBrand__c a : trigger.new){
		String name = accounts.get(a.Account__c).Name+'_'+brands.get(a.Brand__c).Name;
		if(name.length() > 80){
			name = name.substring(0, 79);
		}
		a.Name = name;
	}
	
}