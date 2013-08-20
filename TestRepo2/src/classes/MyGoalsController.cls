public without sharing class MyGoalsController {

	public String userMode							{get;set;} //'sam', 'dir', 'mgr', 'rep'
	public String profName							{get;set;}

	public String viewSel							{get;set;}
	public List<SelectOption> viewChoices			{get;set;}
	
	public List<GoalLine> gls						{get;set;}
	public Map<String, GoalLine> glsByGroupKey		{get;set;}
	
	public String glKeyClicked						{get;set;}
	
	public String sortDirection						{get;set;}
	public String sortExp							{get;set;}
	public String sortExpression {
		get {
        	return sortExp;
		}
		set {
			if (value == sortExp){
				if(sortDirection == 'ASC'){
					sortDirection = 'DESC';
				} else {
					sortDirection = 'ASC';
				}
			} else {
				sortDirection = 'ASC';
				sortExp = value;
			}
		}
   }
	
	public class GoalLine {
		public String key							{get;set;}
		public List<String> idArray					{get;set;}
		
		public Boolean hasOnGoal					{get;set;}
		public Boolean hasOffGoal					{get;set;}
		public String onRecTypeName					{get;set;}
		public String offRecTypeName				{get;set;}
		public String parentOnId					{get;set;}
		public String parentOffId					{get;set;}
		
		public String resumeOrCascadeLabel			{get;set;}
		
		public String name							{get;set;}
		public String premString					{get;set;}
		public String recTypeName					{get;set;}
		public Integer goalNum						{get;set;}
		public String goalNumString					{get;set;}
		public Date startDate						{get;set;}
		public Date dueDate							{get;set;}
		public String startDateString				{get;set;}
		public String dueDateString					{get;set;}
		public String priority						{get;set;}
		public String progName						{get;set;}
		public String goalLevel						{get;set;}
		public String goalFor						{get;set;}
		public Set<String> goalForSet				{get;set;}
		
		public DateTime lastModDT					{get;set;}
		
		public GoalLine(Goal__c goal, String key, String viewSel, String userMode){
			this.key = key;
			goalNum = 0;
			idArray = new List<String>();
			hasOnGoal = false;
			hasOffGoal = false;
			
			lastModDT = goal.LastModifiedDate;
			
			addGoal(goal, viewSel, userMode);
		}
		
		public void addGoal(Goal__c goal, String viewSel, String userMode){
			idArray.add(goal.Id);
			
			if(goal.Goal_Type__c == 'On-Premise - Control'){
				hasOnGoal = true;
				onRecTypeName = goal.RecordType.Name;
			} else {
				hasOffGoal = true;
				offRecTypeName = goal.RecordType.Name;
			}
			
			if(hasOnGoal && !hasOffGoal){
				premString = 'On';
			} else if(!hasOnGoal && hasOffGoal){
				premString = 'Off';
			} else {
				premString = 'On / Off';
			}
			
			if(goal.Goal_For__c == UserInfo.getUserId() && goal.Goal_Type__c == 'On-Premise - Control'){
				parentOnId = goal.Id;
			} else if(goal.Goal_For__c == UserInfo.getUserId() && goal.Goal_Type__c == 'Off-Premise - Control'){
				parentOffId = goal.Id;
			} else if(viewSel == 'saved' && goal.Parent_Goal__c != null && goal.Parent_Goal__r.Goal_Type__c == 'On-Premise - Control'){
				parentOnId = goal.Parent_Goal__c;
			} else if(viewSel == 'saved' && goal.Parent_Goal__c != null && goal.Parent_Goal__r.Goal_Type__c == 'Off-Premise - Control'){
				parentOffId = goal.Parent_Goal__c;
			}
			
			name = goal.Name;
			if(goal.Long_Name__c != null){
				String[] nameSplit = goal.Long_Name__c.split(' - ');
				if(nameSplit.size() > 0){
					name = nameSplit[1];
				}
			}
			
			if(goal.Minimum_of_Accounts__c != null){
				goalNum += Integer.valueOf(goal.Minimum_of_Accounts__c);
			}
			startDate = goal.Start_Date__c;
			dueDate = goal.Due_Date__c;
			if(goal.Start_Date__c != null){
				startDateString = goal.Start_Date__c.format();
			}
			if(goal.Due_Date__c != null){
				dueDateString = goal.Due_Date__c.format();
			}
			priority = goal.Priority__c;
			progName = goal.Program__r.Name;
			goalLevel = goal.Goal_Level__c;
			
			if(goalForSet == null){
				goalForSet = new Set<String>();
			}
			goalForSet.add(goal.Goal_For__r.Name);
			List<String> goalForList = new List<String>(goalForSet);
			goalForList.sort();
			goalFor = '';
			for(String s : goalForList){
				goalFor += s + ', ';
			}
			if(goalFor != ''){
				goalFor = goalFor.substring(0, goalFor.length() - 2);
			}
			
			if(hasOnGoal && hasOffGoal){
				recTypeName = onRecTypeName + ' / ' + offRecTypeName;
			} else if(hasOnGoal){
				recTypeName = onRecTypeName;
			} else if(hasOffGoal){
				recTypeName = offRecTypeName;
			}
			
			resumeOrCascadeLabel = '';
			if(viewSel == 'saved'){
				resumeOrCascadeLabel = 'Resume';
			} else if(viewSel == 'allMine' && (userMode == 'dir' || (userMode == 'dir/mgr' && goal.Goal_Level__c == 'Director'))){
				resumeOrCascadeLabel = 'Cascade';
			}
		}
		
		public Object getSortableValue(String field){
			if(field == 'name'){
				return name;
			} else if(field == 'premString'){
				return premString;
			} else if(field == 'recTypeName'){
				return recTypeName;
			} else if(field == 'goalNum'){
				return goalNum;
			} else if(field == 'startDateString'){
				return startDate;
			} else if(field == 'priority'){
				return priority;
			} else if(field == 'progName'){
				return progName;
			} else if(field == 'goalLevel'){
				return goalLevel;
			} else if(field == 'goalFor'){
				return goalFor;
			}
			return null;
		}
	}
	
	public MyGoalsController(){
		determineUserMode();
		initValues();
	}
	
	public void determineUserMode(){
		userMode = null;
		
		Id userId = UserInfo.getUserId();
		profName = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
		
		List<Territory__c> terrs = [
			SELECT Id,
				   SAM__c,
				   Director__c,
				   Manager__c,
				   OwnerId
			  FROM Territory__c
			 WHERE SAM__c = :userId
			 	OR Director__c = :userId
			 	OR Manager__c = :userId
			 	OR OwnerId = :userId
		];
		
		Boolean isSam = false;
		Boolean isDirector = false;
		Boolean isManager = false;
		
		for(Territory__c terr : terrs){
			if(isSam == false && terr.SAM__c == userId){
				isSam = true;
			}
			if(isDirector == false && terr.Director__c == userId){
				isDirector = true;
			}
			if(isManager == false && terr.Manager__c == userId){
				isManager = true;
			}
		}
		if(isSam && !isDirector && !isManager){
			userMode = 'sam';
		} else if(!isSam && isDirector && !isManager){
			userMode = 'dir';
		} else if(!isSam && isDirector && isManager){
			userMode = 'dir/mgr';
		} else if(!isSam && !isDirector && isManager){
			userMode = 'mgr';
		} else {
			userMode = 'rep';
		}
	}
	
	private void initValues(){
		viewChoices = new List<SelectOption>();
		
		if(userMode == 'sam'){
			viewSel = 'saved';
			viewChoices.add(new SelectOption('saved', 'Goals I\'ve saved but not submitted'));
			viewChoices.add(new SelectOption('subs', 'Current goals I\'ve cascaded to others'));
			viewChoices.add(new SelectOption('all', 'All goals I\'ve cascaded to others'));
			viewChoices.add(new SelectOption('remain', 'All open goals I\'ve cascaded to others'));
		} else if(userMode == 'dir'){
			viewSel = 'allMine';
			viewChoices.add(new SelectOption('allMine', 'New goals cascaded to me'));
			viewChoices.add(new SelectOption('saved', 'Goals I\'ve saved but not submitted'));
			viewChoices.add(new SelectOption('subs', 'Current goals I\'ve cascaded to others'));
			viewChoices.add(new SelectOption('all', 'All goals I\'ve cascaded to others'));
			viewChoices.add(new SelectOption('remain', 'All open goals I\'ve cascaded to others'));
		} else if(userMode == 'dir/mgr'){
			viewSel = 'allMine';
			viewChoices.add(new SelectOption('allMine', 'New goals cascaded to me'));
			viewChoices.add(new SelectOption('saved', 'Goals I\'ve saved but not submitted'));
			viewChoices.add(new SelectOption('subs', 'Current goals I\'ve cascaded to others'));
			viewChoices.add(new SelectOption('all', 'All goals I\'ve cascaded to others'));
			viewChoices.add(new SelectOption('remain', 'All open goals I\'ve cascaded to others'));
		} else if(userMode == 'mgr'){
			if(profName == 'Diageo - Sales Manager'){
				viewSel = 'saved';
			} else {
				viewSel = 'allMine';
				viewChoices.add(new SelectOption('allMine', 'New goals cascaded to me'));
				viewChoices.add(new SelectOption('currentMine', 'Current goals cascaded to me'));
				viewChoices.add(new SelectOption('futureMine', 'Future goals cascaded to me'));
			}
			viewChoices.add(new SelectOption('saved', 'Goals I\'ve saved but not submitted'));
			viewChoices.add(new SelectOption('subs', 'Current goals I\'ve cascaded to others'));
			viewChoices.add(new SelectOption('all', 'All goals I\'ve cascaded to others'));
			viewChoices.add(new SelectOption('remain', 'All goals I\'ve cascaded to others, not yet accepted'));
		} else if(userMode == 'rep'){
			viewSel = 'allMine';
			viewChoices.add(new SelectOption('allMine', 'All goals cascaded to me'));
			viewChoices.add(new SelectOption('currentMine', 'Current goals cascaded to me'));
			viewChoices.add(new SelectOption('futureMine', 'Future goals cascaded to me'));
			viewChoices.add(new SelectOption('mineRep', 'Goals I\'ve recently accepted'));
		}
		
		sortDirection = 'ASC';
		sortExp = 'name';
		
		queryGoals();
		sortData();
	}
	
	public void queryGoals(){
		List<Goal__c> goals = new List<Goal__c>();
		
		if(viewSel == 'allMine'){
			goals = [SELECT Id,
							Name,
							Long_Name__c,
							Goal_Type__c,
							Minimum_of_Accounts__c,
							Start_Date__c,
							Due_Date__c,
							Priority__c,
							Program__r.Name,
							Goal_Level__c,
							RecordType.Name,
							Goal_For__r.Name,
							CreatedById,
							Parent_Goal__c,
							Parent_Goal__r.Goal_Type__c,
							LastModifiedDate,
							(SELECT Id FROM Child_Goals__r)
					   FROM Goal__c
					  WHERE OwnerId = :UserInfo.getUserId()
					    AND Goal_For__c = :UserInfo.getUserId()
					    AND Completed__c = false
					    AND (Parent_Goal__c = null OR Parent_Goal__r.Completed__c = true)
					    AND Start_Date__c >= :Date.today().addDays(-30)
					    AND Priority__c != null
					];
		} else if(viewSel == 'currentMine'){
			goals = [SELECT Id,
							Name,
							Long_Name__c,
							Goal_Type__c,
							Minimum_of_Accounts__c,
							Start_Date__c,
							Due_Date__c,
							Priority__c,
							Program__r.Name,
							Goal_Level__c,
							RecordType.Name,
							Goal_For__r.Name,
							CreatedById,
							Parent_Goal__c,
							Parent_Goal__r.Goal_Type__c,
							LastModifiedDate,
							(SELECT Id FROM Child_Goals__r)
					   FROM Goal__c
					  WHERE OwnerId = :UserInfo.getUserId()
					    AND Goal_For__c = :UserInfo.getUserId()
					    AND Completed__c = false
					    AND (Parent_Goal__c = null OR Parent_Goal__r.Completed__c = true)
					    AND Start_Date__c <= :Date.today().addDays(5)
					    AND Due_Date__c >= :Date.today()
					    AND Priority__c != null
					];
		} else if(viewSel == 'futureMine'){
			goals = [SELECT Id,
							Name,
							Long_Name__c,
							Goal_Type__c,
							Minimum_of_Accounts__c,
							Start_Date__c,
							Due_Date__c,
							Priority__c,
							Program__r.Name,
							Goal_Level__c,
							RecordType.Name,
							Goal_For__r.Name,
							CreatedById,
							Parent_Goal__c,
							Parent_Goal__r.Goal_Type__c,
							LastModifiedDate,
							(SELECT Id FROM Child_Goals__r)
					   FROM Goal__c
					  WHERE OwnerId = :UserInfo.getUserId()
					    AND Goal_For__c = :UserInfo.getUserId()
					    AND Completed__c = false
					    AND (Parent_Goal__c = null OR Parent_Goal__r.Completed__c = true)
					    AND Start_Date__c > :Date.today().addDays(5)
					    AND Priority__c != null
					];
		} else if(viewSel == 'subs'){
			goals = [SELECT Id,
							Name,
							Long_Name__c,
							Goal_Type__c,
							Minimum_of_Accounts__c,
							Start_Date__c,
							Due_Date__c,
							Priority__c,
							Program__r.Name,
							Goal_Level__c,
							RecordType.Name,
							Goal_For__r.Name,
							CreatedById,
							Parent_Goal__c,
							Parent_Goal__r.Goal_Type__c,
							LastModifiedDate,
							(SELECT Id FROM Child_Goals__r)
					   FROM Goal__c
					  WHERE CreatedById = :UserInfo.getUserId()
					    AND OwnerId != :UserInfo.getUserId()
					    AND Due_Date__c >= :Date.today()
					    AND Priority__c != null
					];
		} else if(viewSel == 'saved'){
			goals = [SELECT Id,
							Name,
							Long_Name__c,
							Goal_Type__c,
							Minimum_of_Accounts__c,
							Start_Date__c,
							Due_Date__c,
							Priority__c,
							Program__r.Name,
							Goal_Level__c,
							RecordType.Name,
							Goal_For__r.Name,
							CreatedById,
							Parent_Goal__c,
							Parent_Goal__r.Goal_Type__c,
							LastModifiedDate,
							(SELECT Id FROM Child_Goals__r)
					   FROM Goal__c
					  WHERE CreatedById = :UserInfo.getUserId()
					    AND OwnerId = :UserInfo.getUserId()
					    AND Goal_For__c != :UserInfo.getUserId()
					    AND Completed__c = false
					    AND Priority__c != null
					];
		} else if(viewSel == 'all'){
			goals = [SELECT Id,
							Name,
							Long_Name__c,
							Goal_Type__c,
							Minimum_of_Accounts__c,
							Start_Date__c,
							Due_Date__c,
							Priority__c,
							Program__r.Name,
							Goal_Level__c,
							RecordType.Name,
							Goal_For__r.Name,
							CreatedById,
							Parent_Goal__c,
							Parent_Goal__r.Goal_Type__c,
							LastModifiedDate,
							(SELECT Id FROM Child_Goals__r)
					   FROM Goal__c
					  WHERE CreatedById = :UserInfo.getUserId()
					    AND OwnerId != :UserInfo.getUserId()
					    AND Priority__c != null
					  ORDER BY CreatedDate DESC
					  LIMIT 1000
					];
		} else if(viewSel == 'remain'){
			goals = [SELECT Id,
							Name,
							Long_Name__c,
							Goal_Type__c,
							Minimum_of_Accounts__c,
							Start_Date__c,
							Due_Date__c,
							Priority__c,
							Program__r.Name,
							Goal_Level__c,
							RecordType.Name,
							Goal_For__r.Name,
							CreatedById,
							Parent_Goal__c,
							Parent_Goal__r.Goal_Type__c,
							LastModifiedDate,
							(SELECT Id FROM Child_Goals__r)
					   FROM Goal__c
					  WHERE CreatedById = :UserInfo.getUserId()
					    AND OwnerId != :UserInfo.getUserId()
					    AND Priority__c != null
					    AND Completed__c = false
					];
		} else if(viewSel == 'mineRep'){
			goals = [SELECT Id,
							Name,
							Long_Name__c,
							Goal_Type__c,
							Minimum_of_Accounts__c,
							Start_Date__c,
							Due_Date__c,
							Priority__c,
							Program__r.Name,
							Goal_Level__c,
							RecordType.Name,
							Goal_For__r.Name,
							CreatedById,
							Parent_Goal__c,
							Parent_Goal__r.Goal_Type__c,
							LastModifiedDate,
							(SELECT Id FROM Child_Goals__r)
					   FROM Goal__c
					  WHERE OwnerId = :UserInfo.getUserId()
					    AND Goal_For__c = :UserInfo.getUserId()
					    AND Completed__c = true
					    AND Due_Date__c >= :Date.today()
					    AND Priority__c != null
					];
		}
		
		gls = new List<GoalLine>();
		glsByGroupKey = new Map<String, GoalLine>();
		
		if(goals.size() > 0){
			for(Goal__c goal : goals){
				if(goal.Long_Name__c != null){
					if((viewSel == 'allMine' || viewSel == 'currentMine' || viewSel == 'futureMine') && goal.Child_Goals__r.size() > 0){
						//do not show
					} else {
						String key = '';
						key += goal.Long_Name__c.split(' - ')[1];
						key += '|' + goal.Goal_Level__c;
						key += '|' + goal.CreatedById;
						key += '|' + goal.Priority__c;
						key += '|' + goal.Program__c;
						key += '|' + goal.LastModifiedDate;
						key = key.replace(',', '');
						
						if(glsByGroupKey.get(key) != null){
							glsByGroupKey.get(key).addGoal(goal, viewSel, userMode);
						} else {
							GoalLine gl = new GoalLine(goal, key, viewSel, userMode);
							glsByGroupKey.put(key, gl);
						}
					}
				}
			}
			gls = glsByGroupKey.values();
		}
	}
	
	public void sortData(){
		Map<Object, List<GoalLine>> glsBySortVal = new Map<Object, List<GoalLine>>();
		for(GoalLine gl : gls){
			Object val = gl.getSortableValue(sortExp);
			
			if(glsBySortVal.get(val) == null){
				glsBySortVal.put(val, new List<GoalLine>());
			}
			glsBySortVal.get(val).add(gl);
		}
		
		List<Object> sortVals = new List<Object>(glsBySortVal.keyset());
		sortVals.sort();
		if(sortDirection == 'DESC'){
			List<Object> newSortVals = new List<Object>();
			for(Integer i = sortVals.size() - 1; i >= 0; i--){
				newSortVals.add(sortVals[i]);
			}
			sortVals = newSortVals;
		}
		
		gls = new List<GoalLine>();
		for(Integer i = 0; i < sortVals.size(); i++){
			for(GoalLine gl : glsBySortVal.get(sortVals[i])){
				gls.add(gl);
			}
		}
	}
	
	public PageReference cascadeClicked(){
		GoalLine gl = glsByGroupKey.get(glKeyClicked);
		
		String paramString = '?idArray=';
		if(viewSel == 'saved'){
			for(Integer i = 0; i < gl.idArray.size(); i++){
				paramString += gl.idArray[i];
				if(i < gl.idArray.size() - 1){
					paramString += '_';
				}
			}
		}
		if(gl.parentOnId != null){
			paramString += '&parentOnId=' + gl.parentOnId;
		}
		if(gl.parentOffId != null){
			paramString += '&parentOffId=' + gl.parentOffId;
		}
		return new PageReference('/apex/GoalCreation2Page' + paramString);
	}
	
	public void doNothing(){}
	
	public void deleteConfirmed(){
		GoalLine gl = glsByGroupKey.get(glKeyClicked);
		
		delete [SELECT Id FROM Goal__c WHERE Id IN :gl.idArray];
		
		queryGoals();
	}
		
	public PageReference createLocalGoal(){
		return new PageReference('/apex/GoalCreation2Page?local=true');
	}
	
	public PageReference gotoActionAssignment(){
		return new PageReference('/apex/ActionAssignmentPage');
	}

}