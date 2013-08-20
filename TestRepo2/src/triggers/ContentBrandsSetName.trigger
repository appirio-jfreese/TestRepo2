trigger ContentBrandsSetName on ContentBrand__c (before insert, before update) {
	
	Id[] BrandIds = new Id[]{};
	Id[] ContentIds = new Id[]{};
	for(ContentBrand__c c : trigger.new){
		BrandIds.add(c.Brand__c);
		ContentIds.add(c.Content_Description__c);
	}
	
	Map <Id,Brand__c> brands = new Map<Id,Brand__c>([select id, name from Brand__c where  id in :BrandIds]);
	Map <Id,Content_Description__c> contents = new Map<Id,Content_Description__c>([select id, name from Content_Description__c where  id in :ContentIds]);
	
	for(ContentBrand__c c : trigger.new){
		String name = contents.get(c.Content_Description__c).Name+'_'+brands.get(c.Brand__c).Name;
		if(name.length() > 80){
			name = name.substring(0, 79);
		}
		c.Name = name;
	}
	
}