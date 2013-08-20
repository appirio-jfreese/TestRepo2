trigger CalendarBrandsSetName on CalendarBrand__c (before insert, before update) {
	Id[] BrandIds = new Id[]{};
	Id[] CalendarIds = new Id[]{};
	for(CalendarBrand__c calBr : trigger.new){
		BrandIds.add(calBr.Brand__c);
		CalendarIds.add(calBr.Calendar__c);
	}
	
	Map <Id,Brand__c> brands = new Map<Id,Brand__c>([select id, name from Brand__c where  id in :BrandIds]);
	Map <Id,Calendar__c> calendars = new Map<Id,Calendar__c>([select id, name from Calendar__c where  id in :CalendarIds]);
	
	for(CalendarBrand__c calBr : trigger.new){
		String name = calendars.get(calBr.Calendar__c).Name+'_'+brands.get(calBr.Brand__c).Name;
		if(name.length() > 80){
			name = name.substring(0, 79);
		}
		calBr.Name = name;
	}
}