trigger ContentPropertySetName on Content_Property__c (before insert, before update) {
	
	Id[] ContentIds = new Id[]{};
	for(Content_Property__c c : trigger.new){
		ContentIds.add(c.Content_Description__c);
	}
	
	Map <Id,Content_Description__c> contents = new Map<Id,Content_Description__c>([select id, name from Content_Description__c where  id in :ContentIds]);
	
	for(Content_Property__c c : trigger.new){
		if(contents.containsKey(c.Content_Description__c)) {
			String name = contents.get(c.Content_Description__c).Name+'_'+c.Category__c;
			if(name.length() > 80){
				name = name.substring(0, 79);
			}
			c.Name = name;
		}
	}
}