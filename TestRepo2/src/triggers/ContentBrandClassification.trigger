trigger ContentBrandClassification on ContentBrand__c (after insert) {

	list<ContentBrand__c> cbs = [select id, Content_Description__r.classification__c, brand__r.Classification__c from ContentBrand__c where id in :trigger.new and brand__r.Classification__c != null];
	
	set<id> needToUpdateIds = new set<id>();
	for(ContentBrand__c cb: cbs){
		if(!needToUpdateIds.contains(cb.Content_Description__r.id)){
			needToUpdateIds.add(cb.Content_Description__r.id);
		}
	}

	Map<Id,Content_Description__c> mapUpdate = new Map <Id,Content_Description__c>([select id, classification__c from Content_Description__c where id = :needToUpdateIds]);

	for(ContentBrand__c cb : cbs){
		if(mapUpdate.containsKey(cb.Content_Description__r.id)){
			Content_Description__c cd = mapUpdate.get(cb.Content_Description__r.id);
			if(+cb.brand__r.Classification__c == '' || +cb.brand__r.Classification__c == null){
				continue;
			}
			if(cd.classification__c != null && cd.classification__c.contains(+cb.brand__r.Classification__c.trim())){
				continue;
			}
			if(cd.classification__c == null){
				cd.classification__c = cb.brand__r.Classification__c;
			} else {
				cd.classification__c = cd.classification__c+';'+cb.brand__r.Classification__c;
			}
			mapUpdate.put(cb.Content_Description__r.id,cd);
		}
	}
	
	if(mapUpdate.size()!=0){
		update mapUpdate.values();
	}
	
}