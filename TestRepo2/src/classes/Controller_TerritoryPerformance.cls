public with sharing class Controller_TerritoryPerformance 
{
	public List<ObjectiveData> objectiveDataList{get;set;}
	public List<SelectOption> objectiveSelectOptions{get;set;}
	
	public String selectedObjectiveId{get;set;}
	
	
	public Controller_TerritoryPerformance()
	{
		String objectiveId = ApexPages.currentPage().getParameters().get('objectiveId') ;
		initializeData(objectiveId);
	}
	
	public Controller_TerritoryPerformance(String objectiveId) {
		initializeData(objectiveId);
	}
	
	public void initializeData(String objectiveId)
	{
		selectedObjectiveId = objectiveId ;
		
		objectiveDataList = new List<ObjectiveData>();
		objectiveSelectOptions = new List<SelectOption>();
		for(Objective__c obj : [select id, Name from Objective__c])
		{
			objectiveSelectOptions.add( new SelectOption(obj.Id, obj.Name) );
		}
		
		Map<Id,ObjectiveData> mapOfObjectiveDataByAccountOwner = new Map<Id,ObjectiveData>();
		
		if(objectiveId == null || objectiveId == '') {
			for(Action__c action : [select Id, OwnerId, Account__r.OwnerId, Account__r.Owner.Name, Objective__c, Status__c 
									from Action__c
									where Account__c <> null
									and Objective__c <> null])
			{
				putActionDataIntoMap(action, mapOfObjectiveDataByAccountOwner);
			}
		}
		else
		{
			for(Action__c action2 : [select Id, OwnerId, Account__r.OwnerId, Account__r.Owner.Name, Objective__c, Status__c 
									from Action__c
									where Account__c <> null
									and Objective__c = :objectiveId])
			{
				putActionDataIntoMap(action2, mapOfObjectiveDataByAccountOwner);
			}
		}
		
		objectiveDataList = mapOfObjectiveDataByAccountOwner.values();
		
	}
	
	private void putActionDataIntoMap(Action__c action, Map<Id,ObjectiveData> mapOfObjectiveDataByAccountOwner)
	{
		ObjectiveData objDataObj = mapOfObjectiveDataByAccountOwner.get(action.Account__r.OwnerId);
		
		if(objDataObj == null)
			objDataObj = new ObjectiveData(action.Account__r.Owner.Name, action.Account__r.OwnerId) ;
		
		objDataObj.totalCount++;
		
		if(action.Status__c == 'Closed - Complete')
			objDataObj.closedCount++;
		
		mapOfObjectiveDataByAccountOwner.put(action.Account__r.OwnerId, objDataObj);
	}
	
	
	
	
	
	
	public class ObjectiveData 
	{
        public String userName {get; set;}
        public Id userId{get; set;}
        public Integer totalCount { get; set; }
        public Integer closedCount { get; set; }        
		
		public ObjectiveData(String userName, Id userId) 
		{
            this.userName = userName ;
            this.userId = userId;
            this.totalCount = 0;
            this.closedCount = 0;
        }
		
		public Double getClosedPercentage()
		{
			Double doubToReturn = 0;
			if(totalCount > 0 && closedCount > 0) {
				doubToReturn = (Double)((closedCount / totalCount) * 100 ) ;
			}
			
			//doubToReturn.setScale(2);
			return doubToReturn ;
		}
		
		public String getMainLabel()
		{
			String strToReturn = String.valueOf(this.getClosedPercentage()) ;
			strToReturn += '% (' + closedCount + ' of '  + totalCount +  ')' ;
			
			return strToReturn;
		}
		
          
    }
	
	
	
}