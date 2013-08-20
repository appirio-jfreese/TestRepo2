public with sharing class GoalAdminController {
	
	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'quick dave test, please ignore: ' + dummyOnGoal));
	
	public Boolean shouldShowGridBlock						{get;set;}

	public String filterStateSelection						{get;set;}
	public List<SelectOption> filterStateChoices			{get;set;}
	
	public String filterTypeSelection						{get;set;}
	public List<SelectOption> filterTypeChoices				{get;set;}
	
	public String filterPrioritySelection					{get;set;}
	public List<SelectOption> filterPriorityChoices			{get;set;}
	
	public String filterDueDateSelection					{get;set;}
	public List<SelectOption> filterDueDateChoices			{get;set;}
	
	public String filterRecTypeSelection					{get;set;}
	public List<SelectOption> filterRecTypeChoices			{get;set;}
	
	public String filterNameValue							{get;set;}
	
	public Boolean showGoalDetail							{get;set;}
	public Boolean showGroupDetail							{get;set;}
	public String selectedGoalId							{get;set;}
	public String selectedGroupIds							{get;set;}
	public Goal__c selectedGoal								{get;set;}
	public List<Goal__c> selectedGroupGoals					{get;set;}
	public List<Goal__c> childGoals							{get;set;}
	public List<Action__c> childActions						{get;set;}

	public GoalAdminController(){
		shouldShowGridBlock = false;
		showGoalDetail = false;		
		showGroupDetail = false;		
		populateFilterDropdowns();
	}
	
	private void populateFilterDropdowns(){
		Schema.DescribeFieldResult result;
		
		filterStateChoices = new List<SelectOption>();
		filterStateChoices.add(new SelectOption('Any', 'Any'));
		result = Goal__c.State__c.getDescribe();
		for(Schema.PicklistEntry ple : result.getPicklistValues()){
			if(ple.isActive()){
				filterStateChoices.add(new SelectOption(ple.getValue(), ple.getLabel()));
			}
		}
		filterStateSelection = 'Any';
		
		filterTypeChoices = new List<SelectOption>();
		filterTypeChoices.add(new SelectOption('Any', 'Any'));
		result = Goal__c.Goal_Type__c.getDescribe();
		for(Schema.PicklistEntry ple : result.getPicklistValues()){
			if(ple.isActive()){
				filterTypeChoices.add(new SelectOption(ple.getValue(), ple.getLabel()));
			}
		}
		filterTypeSelection = 'Any';
		
		filterPriorityChoices = new List<SelectOption>();
		filterPriorityChoices.add(new SelectOption('Any', 'Any'));
		result = Goal__c.Priority__c.getDescribe();
		for(Schema.PicklistEntry ple : result.getPicklistValues()){
			if(ple.isActive()){
				filterPriorityChoices.add(new SelectOption(ple.getValue(), ple.getLabel()));
			}
		}
		filterPrioritySelection = 'Any';
		
		filterDueDateChoices = new List<SelectOption>();
		Date nineMonthsAhead = Date.today().toStartOfMonth().addMonths(9);
		Integer numMonths = 11;
		for(Integer i = numMonths; i >= 0; i--){
			Date d = nineMonthsAhead.addMonths(-1 * i);
			String value = String.valueOf(d) + '|' + String.valueOf(d.addMonths(1));
			String label = monthString(d);
			filterDueDateChoices.add(new SelectOption(value, label));
		}
		filterDueDateSelection = String.valueOf(Date.today().toStartOfMonth()) + '|' + String.valueOf(Date.today().toStartOfMonth().addMonths(1));
		
		filterRecTypeChoices = new List<SelectOption>();
		filterRecTypeChoices.add(new SelectOption('Any', 'Any'));
		Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Goal__c.getRecordTypeInfosByName();
		List<String> rtNames = new List<String>();
		rtNames.addAll(rtMap.keySet());
		rtNames.sort();
		for(String rtName : rtNames){
			if(rtName != 'Master'){
				filterRecTypeChoices.add(new SelectOption(rtMap.get(rtName).getRecordTypeId(), rtName));
			}
		}
		filterRecTypeSelection = 'Any';
	}
	
	private String monthString(Date d){
		if(d.month() == 1){
			return 'January ' + d.year();
		} else if(d.month() == 2){
			return 'February ' + d.year();
		} else if(d.month() == 3){
			return 'March ' + d.year();
		} else if(d.month() == 4){
			return 'April ' + d.year();
		} else if(d.month() == 5){
			return 'May ' + d.year();
		} else if(d.month() == 6){
			return 'June ' + d.year();
		} else if(d.month() == 7){
			return 'July ' + d.year();
		} else if(d.month() == 8){
			return 'August ' + d.year();
		} else if(d.month() == 9){
			return 'September ' + d.year();
		} else if(d.month() == 10){
			return 'October ' + d.year();
		} else if(d.month() == 11){
			return 'November ' + d.year();
		}
		return 'December ' + d.year();
	}
	
	public void hideGridBlock(){
		shouldShowGridBlock = false;
	}
	
	@RemoteAction
	public static List<Goal__c> performFilterQuery(String queryString){
		return Database.query(queryString);
	}
	
	public void showGridBlock(){
		shouldShowGridBlock = true;
	}
	
	public void doNothing(){}
	
	public void goalSelected(){
		showGoalDetail = false;
		showGroupDetail = false;
		if(selectedGoalId == null || selectedGoalId == ''){
			selectedGoal = null;
		} else {
			showGoalDetail = true;
			selectedGoal =
				[SELECT Id,
						Name,
						Long_Name__c,
						Minimum_of_Accounts__c,
						Cases_Displayed__c,
						Start_Date__c,
						Due_Date__c,
						RecordTypeId,
						RecordType.Name,
						Priority__c,
						Parent_Goal__c,
						Completed__c
				   FROM Goal__c
				  WHERE Id = :selectedGoalId
				];
			if(selectedGoal.Long_Name__c == null){
				selectedGoal.Long_Name__c = selectedGoal.Name;
			}
				
			childGoals = 
				[SELECT Id,
						(SELECT Id FROM Actions__r)
				   FROM Goal__c
				  WHERE Parent_Goal__c = :selectedGoalId
				     OR Parent_Goal__r.Parent_Goal__c = :selectedGoalId
				     OR Parent_Goal__r.Parent_Goal__r.Parent_Goal__c = :selectedGoalId
				];
			
			childActions = new List<Action__c>();
			for(Goal__c child : childGoals){
				childActions.addAll(child.Actions__r);
			}
		}
	}
	
	public void groupSelected(){
		showGoalDetail = false;
		showGroupDetail = false;
		if(selectedGroupIds == null || selectedGroupIds == ''){
			selectedGoal = null;
		} else {
			showGroupDetail = true;
			List<String> goalIds = selectedGroupIds.split(',');
			selectedGroupGoals =
				[SELECT Id,
						Name,
						Long_Name__c,
						Minimum_of_Accounts__c,
						Cases_Displayed__c,
						Start_Date__c,
						Due_Date__c,
						RecordTypeId,
						RecordType.Name,
						Priority__c,
						Parent_Goal__c,
						Completed__c
				   FROM Goal__c
				  WHERE Id IN :goalIds
				     OR Parent_Goal__c IN :goalIds
				     OR Parent_Goal__r.Parent_Goal__c IN :goalIds
				];
				
			selectedGoal = selectedGroupGoals[0];
			if(selectedGoal.Long_Name__c == null){
				selectedGoal.Long_Name__c = selectedGoal.Name;
			}
			
			childGoals = 
				[SELECT Id
				   FROM Goal__c
				  WHERE Parent_Goal__c IN :goalIds
				     OR Parent_Goal__r.Parent_Goal__c IN :goalIds
				     OR Parent_Goal__r.Parent_Goal__r.Parent_Goal__c IN :goalIds
				];
		}
	}
	
	public void deleteSelectedGoal(){
		delete selectedGoal;
		delete childGoals;
		delete childActions;
		
		showGoalDetail = false;
		selectedGoal = null;
	}
	
	public void hideDetail(){
		showGoalDetail = false;
		showGroupDetail = false;
	}
	
	public void cancelGoalSelect(){
		showGoalDetail = false;
	}
	
	public void cancelGroupSelect(){
		showGroupDetail = false;
	}
	
	public void saveChanges(){
		if(showGoalDetail){
			update selectedGoal;
			showGoalDetail = false;
			
		} else if(showGroupDetail){
			if(selectedGoal.Long_Name__c.length() >= 80){
				selectedGoal.Name = selectedGoal.Long_Name__c.substring(0, 80);
			} else {
				selectedGoal.Name = selectedGoal.Long_Name__c;
			}
			
			for(Goal__c goal : selectedGroupGoals){
				goal.Long_Name__c = selectedGoal.Long_Name__c;
				goal.Name = selectedGoal.Name;
				goal.Start_Date__c = selectedGoal.Start_Date__c;
				goal.Due_Date__c = selectedGoal.Due_Date__c;
				goal.Priority__c = selectedGoal.Priority__c;
			}
			
			update selectedGroupGoals;
			showGroupDetail = false;
		}
	}

}