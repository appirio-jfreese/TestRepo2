public with sharing class GoalCreation2Controller {
	
	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'quick dave test, please ignore: ' + dummyOnGoal));
	
	public final static string ANYSTRING					= '-- Any --';
	
	public Map<String, String> params						{get;set;}
	
	public Boolean isLoading								{get;set;}
	
	public String prevSaveMode								{get;set;} //'none', 'create', 'cascade'
	public String goalMode									{get;set;} //'createSAM', 'createLocal', 'cascade'
	
	public String userMode									{get;set;} //'sam', 'dir', 'mgr'
	public String userModeQuestion							{get;set;}
	public Boolean showRoleConfirmPanel						{get;set;}
	public String profName									{get;set;}
	
	public Boolean enforcePriority							{get;set;}
	
	public List<Goal__c> existingGoals						{get;set;}
	
	public Goal__c dummyGoal								{get;set;}
	public Goal__c dummyOnGoal								{get;set;}
	public Goal__c dummyOffGoal								{get;set;}
	public Id dummyOnGoalId									{get;set;}
	public Id dummyOffGoalId								{get;set;}
	public String dummyOnGoalLongName						{get;set;}
	public String dummyOffGoalLongName						{get;set;}

	public Boolean allowTopFieldEdit						{get;set;}
	public Boolean allowOnPrem								{get;set;}
	public Boolean allowOffPrem								{get;set;}
	public Boolean allowManualName							{get;set;}
	public Boolean allowProgram								{get;set;}
	public Boolean franchiseProgramException				{get;set;}
	
	public List<ProductLine> pls							{get;set;}
	public Integer currentPLIndex							{get;set;}
	public List<String> spiritsList							{get;set;}
	public List<String> winesList							{get;set;}
	public Map<String, String> genericBrandsMap				{get;set;}
	public Map<String, String> plClassesByBrand				{get;set;}
	public Map<String, String> plGroupsByBrand				{get;set;}
	public Map<String, Set<String>> subBrandsByParent		{get;set;}
	public Map<String, Set<String>> idvBrandsByParent		{get;set;}
	public Map<String, Set<String>> sizesByBrand			{get;set;}
	public Map<String, Set<String>> sizesBySubBrand			{get;set;}
	public Map<String, Set<String>> sizesByIdvBrand			{get;set;}
	
	public String programName								{get;set;}
	public String programDesc								{get;set;}
	public String premiseValue								{get;set;}
	public String premiseDispValue							{get;set;}
	
	private Map<String, Id> goalRecTypeIdsByDevName			{get;set;}
	private Map<String, String> goalRecTypeNamesByDevName	{get;set;}
	public List<SelectOption> onPremGoalRecTypes			{get;set;}
	public List<SelectOption> offPremGoalRecTypes			{get;set;}
	public String onPremRecTypeId							{get;set;}
	public String offPremRecTypeId							{get;set;}
	public String onPremRecTypeSel							{get;set;}
	public String offPremRecTypeSel							{get;set;}
	public String onPremRecTypeSelDisplay					{get;set;}
	public String offPremRecTypeSelDisplay					{get;set;}
	
	public Boolean showAdditionalFields						{get;set;}
	public Boolean showCases								{get;set;}
	
	public Boolean showContentLink							{get;set;}
	public Boolean showTypeOfAd								{get;set;}
	public Boolean showSizeOfAd								{get;set;}
	public Boolean showFeatureType							{get;set;}
	public Boolean showSuggestedPrice						{get;set;}
	public Boolean showAccomplishment						{get;set;}
	public Boolean showProductSamples						{get;set;}
	public Boolean showTrainer								{get;set;}
	public Boolean showTrainingAud							{get;set;}
	public Boolean showTrainingLength						{get;set;}
	public Boolean showNumAttendees							{get;set;}
	public Boolean showTastedProduct						{get;set;}
	public Boolean showShelfSetCriteria						{get;set;}
	
	public static String errorMessage						{get;set;}
	
	public List<Object> onSPLs								{get;set;}
	public List<Object> offSPLs								{get;set;}
	public Boolean withSubmit								{get;set;}
	
	public String onIdsString								{get;set;}
	public String offIdsString								{get;set;}
	public String onGoalsString								{get;set;}
	public String offGoalsString							{get;set;}
	public String onCasesString								{get;set;}
	public String offCasesString							{get;set;}
	public String onCommentsString							{get;set;}
	public String offCommentsString							{get;set;}
	
	public class ProductLine {
		public String sfdcId								{get;set;}
		public Integer index								{get;set;}
		
		public String plClass								{get;set;}
		public String plGroup								{get;set;}
		
		public List<SelectOption> prodList1					{get;set;}
		public List<SelectOption> prodList2					{get;set;}
		public List<SelectOption> prodList3					{get;set;}
		public List<SelectOption> sizeList					{get;set;}
		
		public String prodSel1								{get;set;}
		public String prodSel2								{get;set;}
		public String prodSel3								{get;set;}
		public String sizeSel								{get;set;}
		
		public String lowestName							{get;set;}
		
		public ProductLine(Integer index){
			this.index = index;
			
			prodList1 = new List<SelectOption>();
			prodList1.add(new SelectOption(ANYSTRING, '-- Select one --'));
			prodList2 = new List<SelectOption>();
			prodList2.add(new SelectOption(ANYSTRING, ANYSTRING));
			prodList3 = new List<SelectOption>();
			prodList3.add(new SelectOption(ANYSTRING, ANYSTRING));
			sizeList = new List<SelectOption>();
			sizeList.add(new SelectOption(ANYSTRING, ANYSTRING));
			
			prodSel1 = ANYSTRING;
			prodSel2 = ANYSTRING;
			prodSel3 = ANYSTRING;
			sizeSel = ANYSTRING;
			
			calculateLowestName();
		}
		
		public void calculateLowestName(){
			lowestName = null;
			if(prodSel3 != ANYSTRING){
				lowestName = prodSel3;
			} else if(prodSel2 != ANYSTRING){
				lowestName = prodSel2;
			} else if(prodSel1 != ANYSTRING){
				lowestName = prodSel1;
			}
		}
		
		public void addExistingData(Goal_Product_Link__c gpl){
			sfdcId = gpl.Id;
			plClass = gpl.Product_Classification__c;
			plGroup = gpl.Product_Group__c;
			prodSel1 = GoalCreation2Controller.removeAposIndex(gpl.Generic_Brand__c);
			prodSel2 = GoalCreation2Controller.removeAposIndex(gpl.Sub_Brand__c);
			prodSel3 = GoalCreation2Controller.removeAposIndex(gpl.Individual_Brand__c);
			sizeSel = gpl.Size__c;
			if(prodSel1 == null){
				prodSel1 = ANYSTRING;
			}
			if(prodSel2 == null){
				prodSel2 = ANYSTRING;
			}
			if(prodSel3 == null){
				prodSel3 = ANYSTRING;
			}
			if(sizeSel == null){
				sizeSel = ANYSTRING;
			}
			calculateLowestName();
		}
		
		public void addExistingData(ProductLine pl){
			sfdcId = pl.sfdcId;
			plClass = pl.plClass;
			plGroup = pl.plGroup;
			prodSel1 = pl.prodSel1;
			prodSel2 = pl.prodSel2;
			prodSel3 = pl.prodSel3;
			sizeSel = pl.sizeSel;
		}
	}
	
	public class SubPremLine {
		public String existingId							{get;set;}
		
		public String userId								{get;set;}
		public String userName								{get;set;}
		public String premise								{get;set;}
		public String state									{get;set;}
		
		public Integer accsAvail							{get;set;}
		public Integer goal									{get;set;}
		public Integer cases								{get;set;}
		public String comments								{get;set;}
		
		public SubPremLine(String userId, String userName, String premise, Territory__c terr){
			this.userId = userId;
			this.userName = userName;
			this.premise = premise;
			state = terr.State__c;
			
			accsAvail = 0;
			goal = 0;
			cases = 0;
			comments = '';
		}
	}
	

	public GoalCreation2Controller(){
		isLoading = true;
		determineModes();
	}
	
	public void determineModes(){
		franchiseProgramException = false;
		
		params = ApexPages.currentPage().getParameters();
		if(params.get('idArray') == ''){
			params.put('idArray', null);
		}
		
		prevSaveMode = 'none';
		if((params.get('parentOnId') != null || params.get('parentOffId') != null) && params.get('idArray') != null){
			prevSaveMode = 'cascade';
		} else if(params.get('idArray') != null){
			prevSaveMode = 'create';
		}
		
		userMode = null;
		userModeQuestion = null;
		
		Id userId = UserInfo.getUserId();
		
		List<Territory__c> terrs = [
			SELECT Id,
				   SAM__c,
				   Director__c,
				   Manager__c,
				   OwnerId,
				   State__c
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
		} else if(!isSam && !isDirector && isManager){
			userMode = 'mgr';
		} else if(!isSam && isDirector && isManager){
			userModeQuestion = 'dir|mgr';
		}
		
		if(userModeQuestion == 'dir|mgr' && (params.get('parentOnId') != null || params.get('parentOffId') != null)){
			/*String parentGoalId = params.get('parentOnId');
			if(parentGoalId == null){
				parentGoalId = params.get('parentOffId');
			}
			Goal__c parentGoal = [SELECT Id, Goal_Level__c FROM Goal__c WHERE Id = :parentGoalId];
			if(parentGoal.Goal_Level__c == 'Director'){*/
				userModeQuestion = null;
				userMode = 'dir';
			//}
		}
		
		if(userMode == 'mgr' && (terrs[0].State__c == 'NJ' || terrs[0].State__c == 'CT')){
			franchiseProgramException = true;
		}
		
		if(userMode == 'sam'){
			goalMode = 'createSAM';
		} else if((prevSaveMode != 'cascade' && prevSaveMode != 'none') || params.get('local') == 'true' || userMode == 'mgr'){
			goalMode = 'createLocal';
		} else if(params.get('parentOnId') != null || params.get('parentOffId') != null){
			goalMode = 'cascade';
		}
		
		if(userMode != null){
			initValues();
		} else {
			showRoleConfirmPanel = true;
		}
	}
	
	public void confirmDirector(){
		userMode = 'dir';
		initValues();
	}
	
	public void confirmManager(){
		userMode = 'mgr';
		initValues();
	}
	
	private void initValues(){
		showRoleConfirmPanel = false;
		showAdditionalFields = false;
		
		allowTopFieldEdit = false;
		allowProgram = false;
		allowOnPrem = true;
		allowOffPrem = true;
    	allowManualName = false;
		pls = new List<ProductLine>();
		
		profName = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
		
		if(goalMode == 'createSAM' && prevSaveMode == 'none'){
			//SAM is creating a new goal from scratch
			allowTopFieldEdit = true;
			allowProgram = true;
			populateRTSelects();
			setDefaultRTs();
			resetDummyGoals();
			populatePLSelects();
			addPL();
			premiseValue = 'On-Premise - Control';
		} else if(goalMode == 'createSAM' && prevSaveMode == 'create'){
			//SAM is editing a previously saved goal they created from scratch
			allowTopFieldEdit = true;
			allowProgram = true;
			populateRTSelects();
			populatePLSelects();
			createDummyGoalsFromIdArray();
			setDefaultRTs();
			fillPLSelectsWithSaved(true);
			if(dummyGoal != null && dummyGoal.Program__c != null){
				programSelected(false);
			}
			if(dummyOnGoal.Name != ''){
				dummyOnGoal.Name = dummyOnGoal.Name.split(' - ')[1];
				premiseValue = 'On-Premise - Control';
			} else if(dummyOffGoal.Name != ''){
				dummyOffGoal.Name = dummyOffGoal.Name.split(' - ')[1];
				premiseValue = 'Off-Premise - Control';
			}
			prioritySelected();
		} else if(goalMode == 'createLocal' && prevSaveMode == 'none'){
			//Director or Manager is creating a new local goal
			allowTopFieldEdit = true;
			if(franchiseProgramException == false){
				allowProgram = false;
			} else {
				allowProgram = true;
			}
			populateRTSelects();
			setDefaultRTs();
			resetDummyGoals();
			populatePLSelects();
			addPL();
			premiseValue = 'On-Premise - Control';
		} else if(goalMode == 'createLocal' && prevSaveMode == 'create'){
			//Director or Manager is editing a previously saved local goal they created
			allowTopFieldEdit = true;
			allowProgram = false;
			populateRTSelects();
			populatePLSelects();
			createDummyGoalsFromIdArray();
			setDefaultRTs();
			fillPLSelectsWithSaved(true);
			if(pls.size() == 0){
				addPL();
			}
			if(dummyGoal != null && dummyGoal.Program__c != null){
				programSelected(false);
			}
			if(dummyOnGoal.Name != ''){
				dummyOnGoal.Name = dummyOnGoal.Name.split(' - ')[1];
				premiseValue = 'On-Premise - Control';
			}
			if(dummyOffGoal.Name != ''){
				dummyOffGoal.Name = dummyOffGoal.Name.split(' - ')[1];
				premiseValue = 'Off-Premise - Control';
			}
			prioritySelected();
			if(dummyGoal.Priority__c == 'Local'){
				localNameChanged();
			}
		} else if(goalMode == 'cascade' && prevSaveMode == 'none'){
			//Director is cascading a goal they just received from the SAM
			populateRTSelects();
			setDefaultRTs();
			createDummyGoalsFromParentIds(false);
			fillPLSelectsWithSaved(false);
			if(params.get('parentOnId') == null){
				allowOnPrem = false;
			}
			if(params.get('parentOffId') == null){
				allowOffPrem = false;
			}
		} else if(goalMode == 'cascade' && prevSaveMode == 'cascade'){
			//Director is resuming cascading a goal they originally received from the SAM, then saved
			populateRTSelects();
			createDummyGoalsFromIdArray();
			createDummyGoalsFromParentIds(true);
			setDefaultRTs();
			fillPLSelectsWithSaved(false);
			if(dummyGoal.Program__c != null){
				programSelected();
			}
			if(params.get('parentOnId') == null){
				allowOnPrem = false;
			}
			if(params.get('parentOffId') == null){
				allowOffPrem = false;
			}
			prioritySelected();
		}
		setDefaultPriority();
		isLoading = false;
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'quick dave test, please ignore: ' + allowOnPrem +', ' + allowOffPrem));
	}
	
	private void resetDummyGoals(){
		dummyGoal = new Goal__c();
		dummyOnGoal = new Goal__c();
		dummyOnGoal.Start_Date__c = Date.today().toStartOfMonth().addMonths(1);
		dummyOnGoal.Due_Date__c = Date.today().toStartOfMonth().addMonths(2).addDays(-1);
		dummyOffGoal = new Goal__c();
		dummyOffGoal.Start_Date__c = dummyOnGoal.Start_Date__c;
		dummyOffGoal.Due_Date__c = dummyOnGoal.Due_Date__c;
	}
	
	private void createDummyGoalsFromIdArray(){		
		String prevString = params.get('idArray');
		List<String> prevIds = prevString.split('_');
		existingGoals = getExistingGoals(prevIds, false);
		
		for(Goal__c goal : existingGoals){
			dummyGoal = goal;
			if(goal.Goal_Type__c == 'On-Premise - Control'){
				dummyOnGoal = goal;
				onPremRecTypeSel = goal.RecordType.DeveloperName;
			} else {
				dummyOffGoal = goal;
				offPremRecTypeSel = goal.RecordType.DeveloperName;
			}
		}
		if(dummyOnGoal == null){
			dummyOnGoal = new Goal__c();
			dummyOnGoal.Name = '';
			onPremRecTypeSel = 'Feature';
			onPremRecTypeSelDisplay = goalRecTypeNamesByDevName.get('Feature');
			onPremRecTypeId = goalRecTypeIdsByDevName.get('Feature');
			dummyOnGoal.Start_Date__c = Date.today().toStartOfMonth().addMonths(1);
			dummyOnGoal.Due_Date__c = Date.today().toStartOfMonth().addMonths(2).addDays(-1);
		}
		if(dummyOffGoal == null){
			dummyOffGoal = new Goal__c();
			dummyOffGoal.Name = '';
			offPremRecTypeSel = 'Display_Goals';
			offPremRecTypeSelDisplay = goalRecTypeNamesByDevName.get('Display_Goals');
			offPremRecTypeId = goalRecTypeIdsByDevName.get('Display_Goals');
			dummyOffGoal.Start_Date__c = Date.today().toStartOfMonth().addMonths(1);
			dummyOffGoal.Due_Date__c = Date.today().toStartOfMonth().addMonths(2).addDays(-1);
		}
	}
	
	private void createDummyGoalsFromParentIds(Boolean onlyReplaceSomeFields){
		List<String> parentIds = new List<String>();
		if(params.get('parentOnId') != null){
			parentIds.add(params.get('parentOnId'));
		}
		if(params.get('parentOffId') != null){
			parentIds.add(params.get('parentOffId'));
		}
		List<Goal__c> parentGoals = getExistingGoals(parentIds, onlyReplaceSomeFields);
		
		for(Goal__c goal : parentGoals){
			dummyGoal = goal;
			if(goal.Goal_Type__c == 'On-Premise - Control'){
				dummyOnGoalId = goal.Id;
				if(onlyReplaceSomeFields == true){
					dummyOnGoal.Minimum_of_Accounts__c = goal.Minimum_of_Accounts__c;
					dummyOnGoal.Cases_Displayed__c = goal.Cases_Displayed__c;
				} else {
					dummyOnGoal = goal;
					dummyOnGoalLongName = dummyOnGoal.Long_Name__c;
				}
			} else {
				dummyOffGoalId = goal.Id;
				if(onlyReplaceSomeFields == true){
					dummyOffGoal.Minimum_of_Accounts__c = goal.Minimum_of_Accounts__c;
					dummyOffGoal.Cases_Displayed__c = goal.Cases_Displayed__c;
				} else {
					dummyOffGoal = goal;
					dummyOffGoalLongName = dummyOffGoal.Long_Name__c;
				}
			}
		}
	}
	
	private void fillPLSelectsWithSaved(Boolean editEnabled){
		pls = new List<ProductLine>();
		currentPLIndex = 0;
		for(Goal_Product_Link__c gpl : dummyGoal.Goal_Product_Links__r){
			addPLExisting(gpl);
			if(editEnabled){
				prodSel1Changed();
			}
			currentPLIndex++;
		}
	}
	
	private void populateRTSelects(){
		goalRecTypeIdsByDevName = new Map<String, Id>();
		goalRecTypeNamesByDevName = new Map<String, String>();
		onPremGoalRecTypes = new List<SelectOption>();
		offPremGoalRecTypes = new List<SelectOption>();
		for (RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Goal__c' AND DeveloperName != 'Ease_of_Shop' ORDER BY Name]){
			goalRecTypeIdsByDevName.put(rt.DeveloperName, rt.Id);
			goalRecTypeNamesByDevName.put(rt.DeveloperName, rt.Name);
			if(rt.DeveloperName != 'Display_Goals'
				&& rt.DeveloperName != 'Cold_Box_Goals'
				&& rt.DeveloperName != 'Ad_Execution'
				//&& rt.DeveloperName != 'Ease_of_Shop'
				&& rt.DeveloperName != 'Shelf_Set_Goals'
				&& rt.DeveloperName != 'Volume_Goals'
				&& rt.DeveloperName != 'Window_Display_Goals'
			){
				onPremGoalRecTypes.add(new SelectOption(rt.DeveloperName, rt.Name));
			}
			if(rt.DeveloperName != 'Feature'
				&& rt.DeveloperName != 'Bar_Promotion_Goals'
				&& rt.DeveloperName != 'Menu'){
				offPremGoalRecTypes.add(new SelectOption(rt.DeveloperName, rt.Name));
			}
		}
	}
	
	private void setDefaultRTs(){
		String onDevName = 'Feature';
		String offDevName = 'Display_Goals';
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'quick dave test, please ignore: ' + onPremRecTypeSel));
		if(onPremRecTypeSel != null){
			onDevName = onPremRecTypeSel;
		}
		if(offPremRecTypeSel != null){
			offDevName = offPremRecTypeSel;
		}
		onPremRecTypeSel = onDevName;
		onPremRecTypeSelDisplay = goalRecTypeNamesByDevName.get(onDevName);
		onPremRecTypeId = goalRecTypeIdsByDevName.get(onDevName);
		offPremRecTypeSel = offDevName;
		offPremRecTypeSelDisplay = goalRecTypeNamesByDevName.get(offDevName);
		offPremRecTypeId = goalRecTypeIdsByDevName.get(offDevName);
	}
	
	private void setDefaultPriority(){
		enforcePriority = false;
		if(profName == 'Diageo - Sales Manager'){
			if(dummyGoal.Id == null){
				dummyGoal.Priority__c = 'Local';
			}
		} else if(goalMode == 'createLocal' && franchiseProgramException == false){
			enforcePriority = true;
			dummyGoal.Priority__c = 'Local';
		} else if(allowTopFieldEdit == false){
			enforcePriority = true;
		}
	}
	
	private List<Goal__c> getExistingGoals(List<String> idList, Boolean skipStringSection){
		List<Goal__c> goals = 
				[SELECT Id,
						Goal_For__c,
						Goal_Type__c,
						State__c,
						Minimum_of_Accounts__c,
						Cases_Displayed__c,
						Comments__c,
						Program__c,
						Program__r.Name,
						Priority__c,
						RecordTypeId,
						RecordType.Name,
						RecordType.DeveloperName,
						Owner.Name,
						Long_Name__c,
						Name,
						SFA_POS_Items__c,
						Account_Grade__c,
						Location_Grade__c,
						Start_Date__c,
						Due_Date__c,
						Content_Link__c,
						Feature_Type__c,
						Length_of_Training__c,
						Number_of_Attendees__c,
						Product_Sample_s__c,
						Shelf_Set_Criteria__c,
						Size_of_Ad__c,
						Suggested_Price__c,
						Tasted_Product__c,
						Trainer__c,
						Training_Audience__c,
						Type_of_Ad__c,
						(SELECT Id,
								Product_Classification__c,
								Product_Group__c,
								Report_Brand__c,
								Generic_Brand__c,
								Sub_Brand__c,
								Individual_Brand__c,
								Size__c
						   FROM Goal_Product_Links__r
						)
				   FROM Goal__c
				  WHERE Id IN :idList
				];
				
		if(skipStringSection == false){
			onIdsString = '';
			offIdsString = '';
			onGoalsString = '';
			offGoalsString = '';
			onCasesString = '';
			offCasesString = '';
			onCommentsString = '';
			offCommentsString = '';
			
			for(Goal__c goal : goals){
				if(goal.Comments__c == null){
					goal.Comments__c = '';
				}
				if(goal.Goal_For__c == UserInfo.getUserId() && params.get('idArray') == null){
					if(goal.Goal_Type__c == 'On-Premise - Control'){
						onIdsString += UserInfo.getUserId() + '|' + goal.Id + '||';
						onGoalsString += UserInfo.getUserId() + '|' + 0 + '||';
						onCasesString += UserInfo.getUserId() + '|' + 0 + '||';
						onCommentsString += UserInfo.getUserId() + '|' + String.escapeSingleQuotes(goal.Comments__c) + '||';
					} else {
						offIdsString += UserInfo.getUserId() + '|' + goal.Id + '||';
						offGoalsString += UserInfo.getUserId() + '|' + 0 + '||';
						offCasesString += UserInfo.getUserId() + '|' + 0 + '||';
						offCommentsString += UserInfo.getUserId() + '|' + String.escapeSingleQuotes(goal.Comments__c) + '||';
					}
				} else {
					if(goal.Goal_Type__c == 'On-Premise - Control'){
						onIdsString += goal.Goal_For__c + '|' + goal.Id + '||';
						onGoalsString += goal.Goal_For__c + '|' + goal.Minimum_of_Accounts__c + '||';
						onCasesString += goal.Goal_For__c + '|' + goal.Cases_Displayed__c + '||';
						onCommentsString += goal.Goal_For__c + '|' + String.escapeSingleQuotes(goal.Comments__c) + '||';
					} else {
						offIdsString += goal.Goal_For__c + '|' + goal.Id + '||';
						offGoalsString += goal.Goal_For__c + '|' + goal.Minimum_of_Accounts__c + '||';
						offCasesString += goal.Goal_For__c + '|' + goal.Cases_Displayed__c + '||';
						offCommentsString += goal.Goal_For__c + '|' + String.escapeSingleQuotes(goal.Comments__c) + '||';
					}
				}
			}
		}
		
		return goals;
	}
	
	public void populatePLSelects(){
		spiritsList = new List<String>();
		winesList = new List<String>();
		genericBrandsMap = new Map<String, String>();
		plClassesByBrand = new Map<String, String>();
		plGroupsByBrand = new Map<String, String>();
		subBrandsByParent = new Map<String, Set<String>>();
		idvBrandsByParent = new Map<String, Set<String>>();
		sizesByBrand = new Map<String, Set<String>>();
		sizesBySubBrand = new Map<String, Set<String>>();
		sizesByIdvBrand = new Map<String, Set<String>>();
		
		for(Product__c prod : [SELECT Id,
									  Product_Classification__c,
									  Product_Group__c,
									  Report_Brand__c,
									  Generic_Brand__c,
									  Sub_Brand__c,
									  Individual_Brand__c,
									  Size__c
								 FROM Product__c
							 ORDER BY Generic_Brand__c,
							 		  Sub_Brand__c,
							 		  Individual_Brand__c]){
			
			prod.Generic_Brand__c = indexApostrophe(prod.Generic_Brand__c);
			prod.Sub_Brand__c = indexApostrophe(prod.Sub_Brand__c);
			prod.Individual_Brand__c = indexApostrophe(prod.Individual_Brand__c);
							 		  	
			if(genericBrandsMap.get(prod.Generic_Brand__c) == null){
				genericBrandsMap.put(prod.Generic_Brand__c, prod.Generic_Brand__c);
				if(prod.Product_Classification__c == 'Spirit'){
					spiritsList.add(prod.Generic_Brand__c);
				} else if(prod.Product_Classification__c == 'Wine'){
					winesList.add(prod.Generic_Brand__c);
				}
				plClassesByBrand.put(prod.Generic_Brand__c, prod.Product_Classification__c);
				plGroupsByBrand.put(prod.Generic_Brand__c, prod.Product_Group__c);
			}
			
			if(subBrandsByParent.get(prod.Generic_Brand__c) == null){
				subBrandsByParent.put(prod.Generic_Brand__c, new Set<String>());
			}
			subBrandsByParent.get(prod.Generic_Brand__c).add(prod.Sub_Brand__c);
			
			if(idvBrandsByParent.get(prod.Sub_Brand__c) == null){
				idvBrandsByParent.put(prod.Sub_Brand__c, new Set<String>());
			}
			idvBrandsByParent.get(prod.Sub_Brand__c).add(prod.Individual_Brand__c);
			
			if(sizesByBrand.get(prod.Generic_Brand__c) == null){
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'quick dave test, please ignore: ' + prod.Generic_Brand__c));
				sizesByBrand.put(prod.Generic_Brand__c, new Set<String>());
			}
			sizesByBrand.get(prod.Generic_Brand__c).add(prod.Size__c);
			
			if(sizesBySubBrand.get(prod.Sub_Brand__c) == null){
				sizesBySubBrand.put(prod.Sub_Brand__c, new Set<String>());
			}
			sizesBySubBrand.get(prod.Sub_Brand__c).add(prod.Size__c);
			
			if(sizesByIdvBrand.get(prod.Individual_Brand__c) == null){
				sizesByIdvBrand.put(prod.Individual_Brand__c, new Set<String>());
			}
			sizesByIdvBrand.get(prod.Individual_Brand__c).add(prod.Size__c);
			
		}
	}
	
	public static String indexApostrophe(String s){
		if(s != null){
			Integer index = s.indexOf('\'');
			if(index != -1){
				s = s + '_' + index;
				s = s.replace('\'', '');
			}
		}
		return s;
	}
	
	public static String removeAposIndex(String s){
		if(s != null && s.contains('_')){
			String[] spl = s.split('_');
			Integer index = Integer.valueOf(spl[1]);
			s = spl[0];
			s = s.substring(0, index) + '\'' + s.substring(index, s.length());
		}
		return s;
	}
	
	@RemoteAction
    public static List<List<SubPremLine>> readSPLs(String userMode) {
        List<List<SubPremLine>> splListArray = new List<List<SubPremLine>>();
        splListArray.add(new List<SubPremLine>());
        splListArray.add(new List<SubPremLine>());
		Map<Id, SubPremLine> onSPLsByUserId = new Map<Id, SubPremLine>();
		Map<Id, SubPremLine> offSPLsByUserId = new Map<Id, SubPremLine>();
		
		List<Territory__c> terrs;
		if(userMode == 'sam'){
			terrs = [
				SELECT Id,
					   Director__c,
					   Director__r.Name,
					   OwnerId,
					   State__c
				  FROM Territory__c
				 WHERE SAM__c = :UserInfo.getUserId()
				 ORDER BY State__c, Director__r.Name
			];
		} else if(userMode == 'dir'){
			terrs = [
				SELECT Id,
					   Manager__c,
					   Manager__r.Name,
					   OwnerId,
					   State__c
				  FROM Territory__c
				 WHERE Director__c = :UserInfo.getUserId()
				 ORDER BY State__c, Manager__r.Name
			];
		} else if(userMode == 'mgr'){
			terrs = [
				SELECT Id,
					   OwnerId,
					   Owner.Name,
					   State__c
				  FROM Territory__c
				 WHERE Manager__c = :UserInfo.getUserId()
				 ORDER BY State__c, Owner.Name
			];
		}
		
		Map<String, Integer> onAccCountsByTerritoryId = new Map<String, Integer>();
		Map<String, Integer> offAccCountsByTerritoryId = new Map<String, Integer>();
		
		for(Account acc : [SELECT Id,
								  Territory__c,
								  RecordType.Name
							 FROM Account
							WHERE Territory__c IN :terrs
							  AND Called_On__c = true
							  AND (RecordType.Name = 'On-Premise - Control' OR RecordType.Name = 'Off-Premise - Control'
							    OR RecordType.Name = 'On Premise' OR RecordType.Name = 'Off Premise')
						  ]){
			Integer currentCount = 0;
			
			if(acc.RecordType.Name == 'On-Premise - Control' || acc.RecordType.Name == 'On Premise'){
				System.debug('*** here ' + acc.Id);
				if(onAccCountsByTerritoryId.get(acc.Territory__c) != null){
					currentCount = onAccCountsByTerritoryId.get(acc.Territory__c);
				}
				currentCount++;
				onAccCountsByTerritoryId.put(acc.Territory__c, currentCount);
			}
			if(acc.RecordType.Name == 'Off-Premise - Control' || acc.RecordType.Name == 'Off Premise'){
				if(offAccCountsByTerritoryId.get(acc.Territory__c) != null){
					currentCount = offAccCountsByTerritoryId.get(acc.Territory__c);
				}
				currentCount++;
				offAccCountsByTerritoryId.put(acc.Territory__c, currentCount);
			}
		}
		
		for(Territory__c terr : terrs){
			Integer onAccCount = onAccCountsByTerritoryId.get(terr.Id);
			Integer offAccCount = offAccCountsByTerritoryId.get(terr.Id);
			
			if(onAccCount != null || offAccCount != null){
				String splUserId;
				String splUserName;
				if(userMode == 'sam'){
					splUserId = terr.Director__c;
					splUserName = terr.Director__r.Name;
				} else if(userMode == 'dir'){
					splUserId = terr.Manager__c;
					splUserName = terr.Manager__r.Name;
				} else if(userMode == 'mgr'){
					splUserId = terr.OwnerId;
					splUserName = terr.Owner.Name;
				}
				
				if(onAccCount != null){
					SubPremLine spl = onSPLsByUserId.get(splUserId);
					if(spl == null){
						spl = new SubPremLine(splUserId, splUserName, 'On-Premise - Control', terr);
						onSPLsByUserId.put(splUserId, spl);
						splListArray[0].add(spl);
					}
					spl.accsAvail += onAccCount;
				}
				if(offAccCount != null){
					SubPremLine spl = offSPLsByUserId.get(splUserId);
					if(spl == null){
						spl = new SubPremLine(splUserId, splUserName, 'Off-Premise - Control', terr);
						offSPLsByUserId.put(splUserId, spl);
						splListArray[1].add(spl);
					}
					spl.accsAvail += offAccCount;
				}
			}
		}
		
		return splListArray;
    }
    
    public void programSelected(){
    	programSelected(true);
    }
    public void programSelected(Boolean copyAllFields){
    	if(dummyGoal.Program__c != null){
	    	Calendar__c program = [SELECT Id, Name, Description__c, Start_Date__c, End_Date__c, Sales_Channel__c
	    						   FROM Calendar__c WHERE Id = :dummyGoal.Program__c];
	    	programName = program.Name.replace('"', '');
	    	programDesc = program.Description__c;
	    	
	    	if(copyAllFields){
		    	dummyOnGoal.Start_Date__c = program.Start_Date__c;
		    	dummyOffGoal.Start_Date__c = program.Start_Date__c;
		    	dummyOnGoal.Due_Date__c = program.End_Date__c;
		    	dummyOffGoal.Due_Date__c = program.End_Date__c;
		    	
				String onDevName = 'Feature';
				String offDevName = 'Display_Goals';
		    	if(program.Sales_Channel__c == 'Distribution' || 
		    		program.Sales_Channel__c == 'Innovation' || 
		    		program.Sales_Channel__c == 'Sustainovation'){
		    		onDevName = 'Distribution_Accts_Sold_Goals';
		    		offDevName = 'Distribution_Accts_Sold_Goals';
				}
				onPremRecTypeSel = onDevName;
				onPremRecTypeSelDisplay = goalRecTypeNamesByDevName.get(onDevName);
				onPremRecTypeId = goalRecTypeIdsByDevName.get(onDevName);
				offPremRecTypeSel = offDevName;
				offPremRecTypeSelDisplay = goalRecTypeNamesByDevName.get(offDevName);
				offPremRecTypeId = goalRecTypeIdsByDevName.get(offDevName);
		    	
		    	toggleAdditionalFieldBooleans();
		    	calculateName();
	    	}
    	} else {
    		programName = null;
    		programDesc = null;
    	}
    }
    
    public void prioritySelected(){
    	if(dummyGoal.Priority__c == 'National' && goalMode != 'cascade'){
    		allowProgram = true;
    	} else {
    		allowProgram = false;
    		//dummyGoal.Program__c = null;
    	}
    	calculateName();
    }
	
	public void calculateName(){
		onPremRecTypeSelDisplay = goalRecTypeNamesByDevName.get(onPremRecTypeSel);
		offPremRecTypeSelDisplay = goalRecTypeNamesByDevName.get(offPremRecTypeSel);
		
		if(dummyGoal.Priority__c == 'Local'){
			Boolean hasBrand = false;
			for(ProductLine pl : pls){
				if(pl.lowestName != null){
					hasBrand = true;
				}
			}
			if(hasBrand == false && allowManualName == false){
				allowManualName = true;
				dummyGoal.Long_Name__c = '';
			} else if(hasBrand == true){
				constructName();
			}
		} else if(dummyGoal.Priority__c == 'National'){
			constructName();
		}
	}
	
	public void constructName(){
		allowManualName = false;
		
		//Create apostrophed name
		Set<String> brandNameSet = new Set<String>();
		List<String> brandNames = new List<String>();
		
		for(ProductLine pl : pls){
			if(pl.lowestName != null && brandNameSet.contains(pl.lowestName) == false){
				brandNameSet.add(pl.lowestName);
				brandNames.add(pl.lowestName);
			}
		}
		String midString = '';
		if(brandNames.size() > 0){
			midString = String.join(brandNames, ', ') + ' - ';
		} else if(dummyGoal.Program__c != null){
			midString = programName + ' - ';
		}
		
		if(dummyOnGoal != null){
			dummyOnGoal.Long_Name__c = onPremRecTypeSelDisplay + ' - ' + midString + 'On';
		}
		if(dummyOffGoal != null){
			dummyOffGoal.Long_Name__c = offPremRecTypeSelDisplay + ' - ' + midString + 'Off';
		}
		
		//Create non-apostrophed name
		brandNameSet = new Set<String>();
		brandNames = new List<String>();
		
		for(ProductLine pl : pls){
			String name = removeAposIndex(pl.lowestName);
			if(name != null && brandNameSet.contains(name) == false){
				brandNameSet.add(name);
				brandNames.add(name);
			}
		}
		midString = '';
		if(brandNames.size() > 0){
			midString = String.join(brandNames, ', ') + ' - ';
		} else if(dummyGoal.Program__c != null){
			midString = programName + ' - ';
		}
		
		if(dummyOnGoal != null){
			dummyOnGoalLongName = onPremRecTypeSelDisplay + ' - ' + midString + 'On';
		}
		if(dummyOffGoal != null){
			dummyOffGoalLongName = offPremRecTypeSelDisplay + ' - ' + midString + 'Off';
		}
	}
	
	public void addPL(){
		ProductLine pl = new ProductLine(pls.size());
		populatePL(pl);
		pls.add(pl);
	}
	
	public void addPLExisting(Goal_Product_Link__c gpl){
		ProductLine pl = new ProductLine(pls.size());
		populatePL(pl);
		gpl.Generic_Brand__c = indexApostrophe(gpl.Generic_Brand__c);
		gpl.Sub_Brand__c = indexApostrophe(gpl.Sub_Brand__c);
		gpl.Individual_Brand__c = indexApostrophe(gpl.Individual_Brand__c);
		pl.addExistingData(gpl);
		pls.add(pl);
	}
	
	public void populatePL(ProductLine pl){
		if(spiritsList != null){
			for(String name : spiritsList){
				pl.prodList1.add(new SelectOption(name, removeAposIndex(name)));
			}
			for(String name : winesList){
				pl.prodList1.add(new SelectOption(name, removeAposIndex(name)));
			}
		}
	}
	
	public void removePL(){
		for(Integer i = currentPLIndex; i < pls.size() - 1; i++){
			pls[i + 1].index = i;
			pls[i] = pls[i + 1];
		}
		pls.remove(pls.size() - 1);
		calculateName();
	}
	
	public void copyPL(){
		ProductLine pl = new ProductLine(pls.size());
		populatePL(pl);
		pl.addExistingData(pls[currentPLIndex]);
		pls.add(pl);
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'wha ' + pl));
		currentPLIndex = pls.size() - 1;
		isLoading = true;
		prodSel1Changed();
		isLoading = false;
	}
	
	public void prodSel1Changed(){
		ProductLine pl = pls[currentPLIndex];
		pl.prodList2 = new List<SelectOption>();
		List<String> vals = new List<String>(subBrandsByParent.get(pl.prodSel1));
		if(vals.size() != 1){
			pl.prodList2.add(new SelectOption(ANYSTRING, ANYSTRING));
			vals.sort();
		}
		for(String name : vals){
			pl.prodList2.add(new SelectOption(name, removeAposIndex(name)));
		}
		if(pl.prodList2.size() == 1){
			pl.prodSel2 = pl.prodList2[0].getValue();
		} else if(isLoading == false){
			pl.prodSel2 = ANYSTRING;
		}
		
		pl.plClass = plClassesByBrand.get(pl.prodSel1);
		pl.plGroup = plGroupsByBrand.get(pl.prodSel1);
		
		prodSel2Changed();
	}
	
	public void prodSel2Changed(){
		ProductLine pl = pls[currentPLIndex];
		pl.prodList3 = new List<SelectOption>();
		List<String> vals = new List<String>(idvBrandsByParent.get(pl.prodSel2));
		if(vals.size() != 1){
			pl.prodList3.add(new SelectOption(ANYSTRING, ANYSTRING));
			vals.sort();
		}
		for(String name : vals){
			pl.prodList3.add(new SelectOption(name, removeAposIndex(name)));
		}
		if(pl.prodList3.size() == 1){
			pl.prodSel3 = pl.prodList3[0].getValue();
		} else if(isLoading == false){
			pl.prodSel3 = ANYSTRING;
		}
		prodSel3Changed();
	}
	
	public void prodSel3Changed(){
		ProductLine pl = pls[currentPLIndex];
		
		pl.sizeList = new List<SelectOption>();
		Set<String> allVals = new Set<String>();
		
		if(pl.prodSel3 != ANYSTRING){
			allVals.addAll(sizesByIdvBrand.get(indexApostrophe(pl.prodSel3)));
		} else if(pl.prodSel2 != ANYSTRING){
			allVals.addAll(sizesBySubBrand.get(indexApostrophe(pl.prodSel2)));
		} else if(pl.prodSel1 != ANYSTRING){
			allVals.addAll(sizesByBrand.get(indexApostrophe(pl.prodSel1)));
		}
		
		List<String> vals = new List<String>(allVals);
		if(vals.size() != 1){
			pl.sizeList.add(new SelectOption(ANYSTRING, ANYSTRING));
			vals.sort();
		}
		String oldVal = pl.sizeSel;
		Boolean oldValAvail = false;
		for(String name : vals){
			pl.sizeList.add(new SelectOption(name, removeAposIndex(name)));
			if(name == oldVal){
				oldValAvail = true;
			}
		}
		if(oldValAvail == true){
			pl.sizeSel = oldVal;
		} else if(pl.sizeList.size() == 1){
			pl.sizeSel = pl.sizeList[0].getValue();
		} else if(isLoading == false){
			pl.sizeSel = ANYSTRING;
		}
		pl.calculateLowestName();
		calculateName();
	}
	
	public void suggestPremiseValue(){
		if(dummyOnGoal == null || allowOnPrem == false){
			premiseValue = 'Off-Premise - Control';
		} else if(dummyOffGoal == null || allowOffPrem == false){
			premiseValue = 'On-Premise - Control';
		}
		premiseSelected();
	}
	
	public void premiseSelected(){
		if(premiseValue == 'On-Premise - Control'){
			premiseDispValue = 'On-Premise';
		} else {
			premiseDispValue = 'Off-Premise';
		}
		if(goalMode == 'createSAM' || goalMode == 'createLocal'){
			recTypeSelected();
		} else if(goalMode == 'cascade'){
			if(dummyOnGoal != null){
				onPremRecTypeSel = dummyOnGoal.RecordType.DeveloperName;
			}
			if(dummyOffGoal != null){
				offPremRecTypeSel = dummyOffGoal.RecordType.DeveloperName;
			}
			toggleAdditionalFieldBooleans();
		}
	}
	
	public void recTypeSelected(){
		onPremRecTypeId = goalRecTypeIdsByDevName.get(onPremRecTypeSel);
		offPremRecTypeId = goalRecTypeIdsByDevName.get(offPremRecTypeSel);
		toggleAdditionalFieldBooleans();
		calculateName();
	}
	
	public void localNameChanged(){
		dummyOnGoal.Long_Name__c = onPremRecTypeSelDisplay + ' - ' + dummyOnGoal.Name + ' - On';
		dummyOffGoal.Long_Name__c = offPremRecTypeSelDisplay + ' - ' + dummyOffGoal.Name + ' - Off';
	}
	
	public void toggleAdditionalFields(){
		showAdditionalFields = !showAdditionalFields;
		toggleAdditionalFieldBooleans();
	}
	
	public void toggleAdditionalFieldBooleans(){
		showCases			= false;
		showContentLink		= false;
		showTypeOfAd		= false;
		showSizeOfAd		= false;
		showFeatureType		= false;
		showSuggestedPrice	= false;
		showAccomplishment	= false;
		showProductSamples	= false;
		showTrainer			= false;
		showTrainingAud		= false;
		showTrainingLength	= false;
		showNumAttendees	= false;
		showTastedProduct	= false;
		showShelfSetCriteria = false;
		
		String localType;
		if(premiseValue == 'On-Premise - Control'){
			localType = onPremRecTypeSel;
		} else {
			localType = offPremRecTypeSel;
		}
		
		if(localType == 'Ad_Execution'){
			showFeatureType			= true;
			showSizeOfAd			= true;
			showSuggestedPrice		= true;
			showTypeOfAd			= true;
		} else if(localType == 'Bar_Promotion_Goals'){
		} else if(localType == 'Cold_Box_Goals'){
			showSuggestedPrice		= true;
		} else if(localType == 'Display_Goals'){
			showCases				= true;
			showSuggestedPrice		= true;
		} else if(localType == 'Distribution_Accts_Sold_Goals'){
			showContentLink			= true;
			showSuggestedPrice		= true;
		} else if(localType == 'Distribution_POD_Goals'){
			showContentLink			= true;
			showSuggestedPrice		= true;
		} else if(localType == 'Feature'){
			showFeatureType			= true;
			showSuggestedPrice		= true;
		} else if(localType == 'General_Goals'){
		} else if(localType == 'Menu'){
			showFeatureType			= true;
		} else if(localType == 'Shelf_Set_Goals'){
			showShelfSetCriteria 	= true;
			showSuggestedPrice		= true;
		} else if(localType == 'Staff_Training_Goals'){
			showNumAttendees		= true;
			showTastedProduct		= true;
			showTrainer				= true;
			showTrainingAud			= true;
			showTrainingLength		= true;
		} else if(localType == 'Tasting_Goals'){
			showProductSamples		= true;
		} else if(localType == 'Volume_Goals'){
			showCases				= true;
			showSuggestedPrice		= true;
		} else if(localType == 'Window_Display_Goals'){
		}
	}
	
	public void doNothing(){}
	
	public void checkSaveErrors(){
		/*errorMessage = '';
		if(allowManualName == true && (dummyOnGoal.Name == null || dummyOnGoal.Name == '')){
			errorMessage = 'Please enter a name for your On-Premise goals.';
			return;
		}
		if(allowManualName == true && (dummyOffGoal.Name == null || dummyOffGoal.Name == '')){
			errorMessage = 'Please enter a name for your Off-Premise goals.';
			return;
		}*/
	}
	
	public void checkSubmitErrors(){
		checkSaveErrors();

		if(dummyGoal.Priority__c == null){
			errorMessage = 'Please select a value for Priority.';
			return;
		}
		if(dummyGoal.Priority__c == 'National' && dummyGoal.Program__c == null){
			Boolean hasBrand = false;
			for(ProductLine pl : pls){
				if(pl.lowestName != null){
					hasBrand = true;
				}
			}
			if(hasBrand == false){
				errorMessage = 'National goals must either be related to a Program, or to one or more brands.';
				return;
			}
		}
		if(dummyOnGoal != null && dummyOnGoal.Start_Date__c == null){
			errorMessage = 'Please select a Start Date for On-Premise goals.';
			return;
		}
		if(dummyOnGoal != null && dummyOnGoal.Due_Date__c == null){
			errorMessage = 'Please select an End Date for On-Premise goals.';
			return;
		}
		if(dummyOffGoal != null && dummyOffGoal.Start_Date__c == null){
			errorMessage = 'Please select a Start Date for Off-Premise goals.';
			return;
		}
		if(dummyOffGoal != null && dummyOffGoal.Due_Date__c == null){
			errorMessage = 'Please select an End Date for Off-Premise goals.';
			return;
		}
		if(allowOnPrem && allowOffPrem){
			errorMessage = 'CHECK_FOR_BOTH_PREMISES';
		}
	}
	
	@RemoteAction
    public static String doSave(Boolean withSubmit, List<String[]> dummyGoalStringArrays,
    							List<SubPremLine> onSPLs, List<SubPremLine> offSPLs,
    							String dummyOnGoalId, String dummyOffGoalId, List<String> goalIdsToDelete,
    							List<String[]> plStringArrays, String goalLevel, Boolean isManagerCreatingLocal) {
    								
		List<Goal__c> goalsToInsert = new List<Goal__c>();
		
		for(SubPremLine spl : onSPLs){
			if(spl.goal > 0){
				Goal__c goal = buildGoal(spl, dummyGoalStringArrays[0], withSubmit, goalLevel, isManagerCreatingLocal);
				if(goal.Name == null || goal.Name == ''){
					return 'onNameEmpty';
				}
				if(dummyOnGoalId != ''){
					goal.Parent_Goal__c = dummyOnGoalId;
				}
				goalsToInsert.add(goal);
			}
		}
		for(SubPremLine spl : offSPLs){
			if(spl.goal > 0){
				Goal__c goal = buildGoal(spl, dummyGoalStringArrays[1], withSubmit, goalLevel, isManagerCreatingLocal);
				if(goal.Name == null || goal.Name == ''){
					return 'offNameEmpty';
				}
				if(dummyOffGoalId != ''){
					goal.Parent_Goal__c = dummyOffGoalId;
				}
				goalsToInsert.add(goal);
			}
		}
		
		upsert goalsToInsert;
		
		List<Goal__c> goalsToUpdate = new List<Goal__c>();
		
		if(withSubmit){
			if(dummyOnGoalId != ''){
				Goal__c parentGoal = [SELECT Id FROM Goal__c WHERE Id =:dummyOnGoalId];
				parentGoal.Completed__c = true;
				goalsToUpdate.add(parentGoal);
			}
			if(dummyOffGoalId != ''){
				Goal__c parentGoal = [SELECT Id FROM Goal__c WHERE Id =:dummyOffGoalId];
				parentGoal.Completed__c = true;
				goalsToUpdate.add(parentGoal);
			}
		}
		
		if(goalsToUpdate.size() > 0){
			update goalsToUpdate;
		}
		
		if(goalIdsToDelete.size() > 0){
			List<Goal__c> goalsToDelete = [SELECT Id FROM Goal__c WHERE Id IN :goalIdsToDelete];
			delete goalsToDelete;
		}
		
		goalsToInsert = [SELECT Id, (SELECT Id FROM Goal_Product_Links__r) FROM Goal__c WHERE Id IN :goalsToInsert];
		Set<Id> gplIdsToDelete = new Set<Id>();
		for(Goal__c goal : goalsToInsert){
			if(goal.Goal_Product_Links__r != null){
				for(Goal_Product_Link__c gpl : goal.Goal_Product_Links__r){
					gplIdsToDelete.add(gpl.Id);
				}
			}
		}
		if(gplIdsToDelete.size() > 0){
			delete [SELECT Id FROM Goal_Product_Link__c WHERE Id IN :gplIdsToDelete];
		}
		
		List<Goal_Product_Link__c> gplsToInsert = new List<Goal_Product_Link__c>();
		
		for(Goal__c goal : goalsToInsert){
			for(String[] plVals : plStringArrays){
				Goal_Product_Link__c gpl = buildGPL(goal, plVals);
				if(gpl.Generic_Brand__c != null){
					gplsToInsert.add(gpl);
				}
			}
		}
		
		if(gplsToInsert.size() > 0){
			insert gplsToInsert;
		}
		
		if(withSubmit){
			return 'submitted';
		}
		return 'saved';
	}
	
	private static Goal__c buildGoal(SubPremLine spl, List<String> dummyGoalVals, Boolean withSubmit, String goalLevel, Boolean isManagerCreatingLocal){
		Goal__c goal;
		if(spl.existingId == null){
			goal = new Goal__c();
		} else {
			goal = [SELECT Id FROM Goal__c WHERE Id=:spl.existingId];
		}
		
		goal.Goal_For__c 					= spl.userId;
		goal.Goal_Type__c 					= spl.premise;
		goal.State__c 						= spl.state;
		goal.Minimum_of_Accounts__c 		= spl.goal;
		goal.Cases_Displayed__c 			= spl.cases;
		goal.Comments__c 					= spl.comments;
		
		goal.Program__c 					= convertToId(dummyGoalVals[0]);
		goal.Priority__c 					= dummyGoalVals[1];
		goal.RecordTypeId 					= dummyGoalVals[2];
		goal.Long_Name__c 					= dummyGoalVals[3];
		goal.Name 							= dummyGoalVals[4];
		
		goal.SFA_POS_Items__c 				= dummyGoalVals[5];
		goal.Account_Grade__c 				= dummyGoalVals[6];
		goal.Location_Grade__c 				= dummyGoalVals[7];
		goal.Start_Date__c 					= Date.parse(dummyGoalVals[8]);
		goal.Due_Date__c 					= Date.parse(dummyGoalVals[9]);
		
		goal.Content_Link__c 				= dummyGoalVals[10];
		goal.Feature_Type__c 				= dummyGoalVals[11];
		goal.Length_of_Training__c 			= convertToDecimal(dummyGoalVals[12]);
		goal.Number_of_Attendees__c 		= convertToDecimal(dummyGoalVals[13]);
		goal.Product_Sample_s__c 			= Boolean.valueOf(dummyGoalVals[14]);
		goal.Shelf_Set_Criteria__c 			= dummyGoalVals[15];
		goal.Size_of_Ad__c 					= dummyGoalVals[16];
		goal.Suggested_Price__c 			= convertToDecimal(dummyGoalVals[17]);
		goal.Tasted_Product__c 				= Boolean.valueOf(dummyGoalVals[18]);
		goal.Trainer__c 					= dummyGoalVals[19];
		goal.Training_Audience__c 			= dummyGoalVals[20];
		goal.Type_of_Ad__c 					= dummyGoalVals[21];
		
		if(isManagerCreatingLocal){
			goal.Assignment_Mode__c = 'count';
			goal.Assignment_Mode_Detail__c = String.valueOf(goal.Minimum_of_Accounts__c);
		}
		
		if(withSubmit){
			goal.OwnerId = goal.Goal_For__c;
		} else {
			goal.OwnerId = UserInfo.getUserId();
		}
		
		goal.Goal_Level__c = goalLevel;
		
		return goal;
	}
	
	private static Goal_Product_Link__c buildGPL(Goal__c goal, String[] plVals){
		Goal_Product_Link__c gpl = new Goal_Product_Link__c();
		gpl.Goal__c = goal.Id;
		gpl.Product_Classification__c	= convertPossibleAny(plVals[0]);
		gpl.Product_Group__c			= convertPossibleAny(plVals[1]);
		//gpl.Report_Brand__c 			= convertPossibleAny(plVals[2]);
		gpl.Generic_Brand__c 			= convertPossibleAny(plVals[2]);
		gpl.Sub_Brand__c 				= convertPossibleAny(plVals[3]);
		gpl.Individual_Brand__c 		= convertPossibleAny(plVals[4]);
		gpl.Size__c 					= convertPossibleAny(plVals[5]);
		return gpl;
	}
	
	private static Decimal convertToDecimal(String s){
		if(s == '' || s == null){
			return 0;
		} else {
			return Decimal.valueOf(s);
		}
	}
	
	private static String convertToId(String s){
		if(s == ''){
			s = null;
		}
		return s;
	}
	
	private static String convertPossibleAny(String s){
		if(s == ANYSTRING){
			return null;
		} else {
			return s;
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}