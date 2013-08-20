trigger CalendarBrandClassification on CalendarBrand__c (after insert) {
	
	list<CalendarBrand__c> cbs = [select id, Calendar__r.classification__c, brand__r.Classification__c from CalendarBrand__c where id in :trigger.new and brand__r.Classification__c != null];
	
	set<id> needToUpdateIds = new set<id>();
	for(CalendarBrand__c cb: cbs){
		if(!needToUpdateIds.contains(cb.Calendar__r.id)){
			needToUpdateIds.add(cb.Calendar__r.id);
		}
	}

	Map<Id,Calendar__c> mapUpdate = new Map <Id,Calendar__c>([select id, classification__c from Calendar__c where id = :needToUpdateIds]);

	for(CalendarBrand__c cb : cbs){
		if(mapUpdate.containsKey(cb.Calendar__r.id)){
			Calendar__c cal = mapUpdate.get(cb.Calendar__r.id);
			if(cb.brand__r.Classification__c == '' || cb.brand__r.Classification__c == null){
				continue;
			}
			if(cal.Classification__c == 'Mixed'){
				continue;
			}
			if(cal.Classification__c == '' || cal.Classification__c == null){
				cal.Classification__c = cb.brand__r.Classification__c;
			} else if(cal.Classification__c != cb.brand__r.Classification__c){
				cal.Classification__c = 'Mixed';
			}
			mapUpdate.put(cb.Calendar__r.id,cal);
		}
	}
	
	if(mapUpdate.size()!=0){
		update mapUpdate.values();
	}
}