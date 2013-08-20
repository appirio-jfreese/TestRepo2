trigger AccountTrigger on Account (before insert, before update, after insert, after update, after delete) {
	
	if(trigger.isBefore){
		
		if(trigger.isInsert){
			AccountActions.updateRecordTypes(trigger.new);
			AccountActions.checkNabcaTerritory(trigger.new);
			AccountActions.checkToPopulateStateField(trigger.new);
		} else if(trigger.isUpdate){
			AccountActions.updateRecordTypes(trigger.new, trigger.oldMap);
			AccountActions.checkNabcaTerritory(trigger.new);
			AccountActions.checkToPopulateStateField(trigger.new);
		}
		
	} else if(trigger.isAfter){
		
		if(trigger.isInsert){
			AccountActions.updateSURIs(trigger.new, true);
		} else if(trigger.isUpdate){
			AccountActions.checkToUpdateSURIs(trigger.oldMap, trigger.new);
			AccountActions.checkChangedFieldsForGARI(trigger.oldMap, trigger.new);
		} else if(trigger.isDelete){
			AccountActions.updateSURIs(trigger.old, false);
		}
		
	}

}