public with sharing class SurveyLayoutChildRecordActions 
{
	
	
	public static void validateParentSurveyIsNotClosedOnInsert(List<SurveyLayout_Brand_Items__c> newLayoutItems) 
	{
		Set<String> layoutIds = new Set<String>();
		for(SurveyLayout_Brand_Items__c item : newLayoutItems) {
			if(item.Survey_Layout__c != null)
				layoutIds.add(item.Survey_Layout__c);
		}
		
		if(!layoutIds.isEmpty()) {
			
			Map<Id,Survey_Layout__c> layoutMap = new Map<Id,Survey_Layout__c>( [select id, Activate_Survey__c 
																					from survey_layout__c
																					where id in :layoutIds] );
			
			for(SurveyLayout_Brand_Items__c newLayoutItem : newLayoutItems)
			{
				if(newLayoutItem.Survey_Layout__c != null) {
					Survey_Layout__c layout = layoutMap.get(newLayoutItem.Survey_Layout__c);
					if(layout != null && layout.Activate_Survey__c == true) {
						newLayoutItem.addError('You cannot add layout items to activated surveys.');
					}
				}
				
			}
			
		}
		
	}
	
	
	
	
	public static void validateParentSurveyIsNotClosedOnInsert(List<Survey_Layout_Brand_Bottle_Item__c> newLayoutItems) 
	{
		Set<String> layoutIds = new Set<String>();
		for(Survey_Layout_Brand_Bottle_Item__c item : newLayoutItems) {
			if(item.Survey_Layout__c != null)
				layoutIds.add(item.Survey_Layout__c);
		}
		
		if(!layoutIds.isEmpty()) {
			
			Map<Id,Survey_Layout__c> layoutMap = new Map<Id,Survey_Layout__c>( [select id, Activate_Survey__c 
																					from survey_layout__c
																					where id in :layoutIds] );
			
			for(Survey_Layout_Brand_Bottle_Item__c newLayoutItem : newLayoutItems)
			{
				if(newLayoutItem.Survey_Layout__c != null) {
					Survey_Layout__c layout = layoutMap.get(newLayoutItem.Survey_Layout__c);
					if(layout != null && layout.Activate_Survey__c == true) {
						newLayoutItem.addError('You cannot add layout items to activated surveys.');
					}
				}
				
			}
			
		}
	}
	
}