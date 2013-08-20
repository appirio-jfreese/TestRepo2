public with sharing class Controller_GoalCreationPage {
	
	/* This class is no longer used -- kept for archival purposes
	
	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'wha '));
	
	public Boolean isProgramSelected									{get;set;}
	public Boolean directorMode											{get;set;}
	public Boolean readOnlyMode											{get;set;}
	
	public Goal__c dummyGoal											{get;set;}
	public Goal__c incomingGoal											{get;set;}
	private Map<String, Id> goalRecTypeIdsByName						{get;set;}
	public String goalRecType											{get;set;}
	public List<SelectOption> onPremGoalRecTypes						{get;set;}
	public List<SelectOption> offPremGoalRecTypes						{get;set;}
	public String onPremRecTypeSel										{get;set;}
	public String offPremRecTypeSel										{get;set;}
	public String onPremRecTypeName										{get;set;}
	public String offPremRecTypeName									{get;set;}
	
	public Calendar__c cal												{get;set;}
	public List<Territory__c> terrs										{get;set;}
	public List<Goal__c> samGoals										{get;set;}

	public String premiseValue											{get;set;}
	public String premiseDispValue										{get;set;}
	
	public Map<String, Map<Id, ManagerPremise>> mpsByMgrByPrem			{get;set;}
	public List<ManagerPremise> dispMPs									{get;set;}
	public String bbgMPMgrId											{get;set;}
	public String bbgMPPrem												{get;set;}
	public String bbgSelName											{get;set;}
	
	public Integer totalAccsSelected									{get;set;}
	public Integer totalAccsAvail										{get;set;}
	public Integer totalAccsReq											{get;set;}
	public Integer totalCasesSelected									{get;set;}
	public Integer totalCasesReq										{get;set;}
	
	public Boolean showConfirmation										{get;set;}
	
	public Boolean isCreatingLocalGoal									{get;set;}
	public String localType												{get;set;}
	public List<SelectOption> localTypeOptions							{get;set;}
	public String localPrem												{get;set;}
	
	public Boolean isCreatingAssocGoal									{get;set;}
	
	public Boolean showFeatures											{get;set;}
	public Boolean showCases											{get;set;}
	public Boolean showLocationGrade									{get;set;}
	public Boolean showSFAPOS											{get;set;}
	public Boolean showContentLink										{get;set;}
	public Boolean showTypeOfAd											{get;set;}
	public Boolean showSizeOfAd											{get;set;}
	public Boolean showFeatureType										{get;set;}
	public Boolean showSuggestedPrice									{get;set;}
	public Boolean showAccomplishment									{get;set;}
	public Boolean showProductSamples									{get;set;}
	public Boolean showTrainer											{get;set;}
	public Boolean showTrainingAud										{get;set;}
	public Boolean showTrainingLength									{get;set;}
	public Boolean showNumAttendees										{get;set;}
	public Boolean showTastedProduct									{get;set;}
	
	public Brand_Bottle_Goal__c dummyBBG								{get;set;}
	public List<String> selectedBBGs									{get;set;}
	public String bbgSelValue											{get;set;}
	public List<SelectOption> bbgOptions								{get;set;}


	public class ManagerPremise {
		public Id mgrId													{get;set;}
		public String mgrName											{get;set;}
		public Set<String> stateNames									{get;set;}
		public String mgrStateString									{get;set;}
		public String prem		 										{get;set;}
		public Goal__c goal 											{get;set;}
		public Goal__c parentGoalFromSAM 								{get;set;}
		public Integer accCount											{get;set;}
		public Brand_Bottle_Goal__c dummyBBG							{get;set;}
		public List<SelectOption> bbgOptions							{get;set;}
		public List<String> selectedBBGs								{get;set;}
		public Map<Id, Brand_Bottle_Goal__c> prevBBGsByBBSId			{get;set;}
		public Boolean readOnlyMode										{get;set;}
		
		public ManagerPremise(){}
	}
	

	public Controller_GoalCreationPage(ApexPages.StandardSetController controller) {
		List<Goal__c> incomingGoals = controller.getSelected();
		if(incomingGoals.size() > 0){
			incomingGoal = [SELECT Id, Name, Program__c, Sales_Channel__c FROM Goal__c WHERE Id IN :incomingGoals LIMIT 1];
		}
		init();
	}
	
	private void init() {
		//set up some initial vars
		dummyGoal = new Goal__c();
		dummyGoal.OwnerId = UserInfo.getUserId();
		readOnlyMode = false;
		directorMode = false;
		isCreatingAssocGoal = false;
		isCreatingLocalGoal = false;
		showConfirmation = false;
		totalAccsSelected = 0;
		totalAccsAvail = 0;
		totalAccsReq = 0;
		totalCasesSelected = 0;
		totalCasesReq = 0;
		
		//query for goal rec types
		goalRecTypeIdsByName = new Map<String, Id>();
		onPremGoalRecTypes = new List<SelectOption>();
		offPremGoalRecTypes = new List<SelectOption>();
		for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Goal__c' ORDER BY Name]){
			goalRecTypeIdsByName.put(rt.Name, rt.Id);
			if(rt.Name != 'Display Goals'
			&& rt.Name != 'Cold Box Goals'
			&& rt.Name != 'Ad Execution'
			&& rt.Name != 'Ease of Shop'
			&& rt.Name != 'Shelf Set Goals'
			&& rt.Name != 'Window Display Goals'
			){
				onPremGoalRecTypes.add(new SelectOption(rt.Id, rt.Name));
			}
			if(rt.Name != 'Feature Goals' && rt.Name != 'Bar Promotion Goals'){
				offPremGoalRecTypes.add(new SelectOption(rt.Id, rt.Name));
			}
		}
		
		localType = 'General';
		localTypeOptions = new List<SelectOption>();
		localTypeOptions.add(new SelectOption('General Goals', 'General'));
		localTypeOptions.add(new SelectOption('Display Goals', 'Display'));
		localTypeOptions.add(new SelectOption('Distribution Goals', 'Distribution'));
		localTypeOptions.add(new SelectOption('Ad Execution', 'Ad Execution'));
		localTypeOptions.add(new SelectOption('Bar Promotion Goals', 'Bar Promotion'));
		localTypeOptions.add(new SelectOption('Cold Box Goals', 'Cold Box'));
		localTypeOptions.add(new SelectOption('Feature Goals', 'Feature'));
		localTypeOptions.add(new SelectOption('Menu Goals', 'Menu'));
		localTypeOptions.add(new SelectOption('Shelf Set Goals', 'Shelf Set'));
		localTypeOptions.add(new SelectOption('Staff Training Goals', 'Staff Training'));
		localTypeOptions.add(new SelectOption('Tasting Goals', 'Tasting'));
		localTypeOptions.add(new SelectOption('Window Display Goals', 'Window Display'));
		
		//query for user's territories
		terrs =
			[SELECT Id,
					Name,
					Director__c,
					Director__r.Name,
					Director__r.UserRole.Name,
					Manager__c,
					State__c,
					OwnerId
			   FROM Territory__c
			  WHERE SAM__c = :UserInfo.getUserId()
		   ORDER BY State__c, Director__r.Name
			];
			
		if(terrs.isEmpty()){
			terrs =
			[SELECT Id,
					Name,
					Manager__c,
					Manager__r.Name,
					Manager__r.UserRole.Name,
					Director__c,
					State__c,
					OwnerId
			   FROM Territory__c
			  WHERE Director__c = :UserInfo.getUserId()
		   ORDER BY State__c, Manager__r.Name
			];
			
			if(terrs.isEmpty()){
				//add some message
			} else {
				directorMode = true;
			}
		}
		
		if(incomingGoal == null){
			//user clicked on goal creation tab
			isProgramSelected = false;
		} else if(incomingGoal.Sales_Channel__c == 'Local'){
			//user clicked goal creation button for a local goal
			dummyGoal = incomingGoal;
			programSelected();
		} else {
			//user clicked goal creation button for a standard goal
			dummyGoal = incomingGoal;
			programSelected();
		}
		
	}
	
	public PageReference beginAssocCreation(){
		isCreatingAssocGoal = true;
		
		Goal__c parentGoal = 
			[SELECT Id,
					Name,
					Sales_Channel__c,
					Due_Date__c,
					Goal_Type__c,
					Program__c,
					RecordTypeId,
					RecordType.Name
			   FROM Goal__c
			  WHERE Id = :dummyGoal.Associate_Parent__c
			];
		
		dummyGoal = new Goal__c();
		dummyGoal.Name = parentGoal.Name;
		dummyGoal.Parent_Goal__c = parentGoal.Id;
		dummyGoal.Sales_Channel__c = parentGoal.Sales_Channel__c;
		dummyGoal.Due_Date__c = parentGoal.Due_Date__c;
		dummyGoal.Goal_Type__c = parentGoal.Goal_Type__c;
		dummyGoal.Program__c = parentGoal.Program__c;
		dummyGoal.RecordTypeId = parentGoal.RecordTypeId;
		localPrem = dummyGoal.Goal_Type__c;
		localType = parentGoal.RecordType.Name;
		
		return finishLocalOrAssocSetup();
	}
	
	public PageReference beginGoalCreation(){
		if(localType == 'Display Goals' && localPrem == 'On-Premise - Control'){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Display goals cannot be created for On-Premise accounts.'));
			return null;
		}
		if(localType == 'Cold Box Goals' && localPrem == 'On-Premise - Control'){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Cold Box goals cannot be created for On-Premise accounts.'));
			return null;
		}
		if(localType == 'Feature Goals' && localPrem == 'Off-Premise - Control'){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Feature goals cannot be created for Off-Premise accounts.'));
			return null;
		}
		if(localType == 'Bar Promotion Goals' && localPrem == 'Off-Premise - Control'){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Bar Promotion goals cannot be created for Off-Premise accounts.'));
			return null;
		}
		
		isCreatingLocalGoal = true;
		
		if(incomingGoal == null){
			dummyGoal = new Goal__c();
			dummyGoal.Sales_Channel__c = 'Local';
			dummyGoal.Goal_Type__c = localPrem;
			dummyGoal.RecordTypeId = goalRecTypeIdsByName.get(localType);
		} else {
			dummyGoal =
				[SELECT Id,
						Name,
						Program__c,
						OwnerId,
						Due_Date__c,
						Comments__c,
						State__c,
						Percent_of_Universe__c,
						Brand_Category__c,
						Account_Grade__c,
						RecordTypeId,
						RecordType.Name,
						Sales_Channel__c,
						Goal_Type__c,
						Features_Displayed__c,
						Cases_Displayed__c,
						Content_Link__c,
						Location_Grade__c,
						Suggested_Price__c,
						Feature_Type__c,
						Size_of_Ad__c,
						Type_of_Ad__c,
						Length_of_Training__c,
						Accomplishment_Recap__c,
						Number_of_Attendees__c,
						Tasted_Product__c,
						Product_Sample_s__c,
						Trainer__c,
						Training_Audience__c,
						SFA_POS_Items__c,
						(SELECT Id,
								Goal__c,
								BrandBottle_Size__c,
								BrandBottle_Size__r.Name
						   FROM Brand_Bottle_Goals__r
						)
				   FROM Goal__c
				   WHERE Id = :incomingGoal.Id
				];
			localPrem = dummyGoal.Goal_Type__c;
			localType = dummyGoal.RecordType.Name;
			
			if(dummyGoal.OwnerId != UserInfo.getUserId()){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The local goal you selected has already been submitted, and is no longer available for editing.'));
				resetView();
				return null;
			}
		}
		
		return finishLocalOrAssocSetup();
	}
	
	private PageReference finishLocalOrAssocSetup(){
		
		if(dummyGoal.Due_Date__c == null){
			dummyGoal.Due_Date__c = Date.today();
		}
		
		if(dummyGoal.Sales_Channel__c == 'Distribution' ||
           		dummyGoal.Sales_Channel__c == 'Innovation' ||
           		dummyGoal.Sales_Channel__c == 'Sustainovation'){
        	goalRecType = 'Distribution';
        } else {
        	goalRecType = 'General';
        }
		
		showFeatures		= dummyGoal.Goal_Type__c == 'On-Premise - Control' && goalRecType != 'Distribution' && localType != 'Distribution Goals';
		showCases			= dummyGoal.Goal_Type__c == 'Off-Premise - Control' && goalRecType != 'Distribution' && localType != 'Distribution Goals';
		showLocationGrade	= false;
		showSFAPOS			= false;
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
		
		if(localType == 'Display Goals'){
			showLocationGrade	= true;
			showSFAPOS			= true;
		} else if(localType == 'Distribution Goals'){
			showContentLink		= true;
		} else if(localType == 'General Goals'
			   || localType == 'Cold Box Goals'
			   || localType == 'Tasting Goals'){
		} else if(localType == 'Ad Execution'){
			showTypeOfAd		= true;
			showSizeOfAd		= true;
			showFeatureType		= true;
			showSuggestedPrice	= true;
		} else if(localType == 'Feature Goals'){
			showFeatureType		= true;
			showSuggestedPrice	= true;
		} else if(localType == 'Menu Goals'){
			showSFAPOS			= true;
			showFeatureType		= true;
			showSuggestedPrice	= true;
		} else if(localType == 'Shelf Set Goals'
			   || localType == 'Bar Promotion Goals'){
			showSFAPOS			= true;
			showFeatureType		= true;
			showSuggestedPrice	= true;
		} else if(localType == 'Staff Training Goals'){
			showSFAPOS			= true;
			showSuggestedPrice	= true;
			showProductSamples	= true;
			showTrainer			= true;
			showTrainingAud		= true;
			showTrainingLength	= true;
			showNumAttendees	= true;
			showTastedProduct	= true;
		} else if(localType == 'Window Display Goals'){
			showSFAPOS			= true;
		}		
		
		//query to get account counts
		Set<Id> ownerIds = new Set<Id>();
		Map<String, Integer> accCountsByOwnerPremiseKey = new Map<String, Integer>();
		for(Territory__c terr : terrs){
			ownerIds.add(terr.OwnerId);
			accCountsByOwnerPremiseKey.put(terr.OwnerId + localPrem, 0);
		}
		List<AggregateResult> ars = [ SELECT Count(Id),
											 OwnerId,
											 RecordType.Name
										FROM Account
									   WHERE OwnerId IN :ownerIds
									     AND Territory__c IN :terrs
									     AND RecordType.Name = :localPrem
									     AND Called_On__c = true
									GROUP BY OwnerId, RecordType.Name
									];
									
		for(AggregateResult ar : ars){
			String ownerId = String.valueOf(ar.get('OwnerId'));
			String premise = String.valueOf(ar.get('Name'));
			Integer accCount = Integer.valueOf(ar.get('expr0'));
			if(accCount > 0){
				accCountsByOwnerPremiseKey.put(ownerId + '|' + premise, accCount);
			}
		}
		
		//create ManagerPremise data
		mpsByMgrByPrem = new Map<String, Map<Id, ManagerPremise>>();
		Map<Id, ManagerPremise> mpMap = new Map<Id, ManagerPremise>();
		if(directorMode == false){
			for(Territory__c terr : terrs){
				if(mpMap.get(terr.Director__c) == null){
					mpMap.put(terr.Director__c, createMgrPrem(terr, localPrem, null, null));
				} else {
					mpMap.get(terr.Director__c).stateNames.add(terr.State__c);
				}
				if(accCountsByOwnerPremiseKey.get(terr.OwnerId + '|' + localPrem) != null){
					mpMap.get(terr.Director__c).accCount += accCountsByOwnerPremiseKey.get(terr.OwnerId + '|' + localPrem);
				}
			}
		} else {
			for(Territory__c terr : terrs){
				Integer accCount = accCountsByOwnerPremiseKey.get(terr.OwnerId + '|' + localPrem);
				if(accCount != null && accCount > 0 && mpMap.get(terr.Manager__c) == null){
					mpMap.put(terr.Manager__c, createMgrPrem(terr, localPrem, null, dummyGoal));
					mpMap.get(terr.Manager__c).accCount += accCountsByOwnerPremiseKey.get(terr.OwnerId + '|' + localPrem);
				}
			}
		}
		mpsByMgrByPrem.put(localPrem, mpMap);
        premiseValue = localPrem;
		
		for(Map<Id, ManagerPremise> mpMap2 : mpsByMgrByPrem.values()){
			for(ManagerPremise mp : mpMap2.values()){
				mp.mgrStateString = '';
				if(mp.stateNames.size() > 0) {
					for(String stateName : mp.stateNames){
						mp.mgrStateString += stateName + ', ';
					}
					mp.mgrStateString = mp.mgrStateString.subString(0, mp.mgrStateString.length() - 2);
				}
				mp.goal.State__c = mp.mgrStateString;
				
				if(mp.goal.Due_Date__c == null){
					mp.goal.Due_Date__c = Date.today();
				}
			}
		}
		
		totalSelectedChanged();
        
        premiseSelected();
		
		return null;
	}
	
	public PageReference programSelected(){
		//set local boolean
        isProgramSelected = true;
        
        //load calendar record
        if(dummyGoal.Program__c != null){
	        cal =
	        	[SELECT	Id,
	        			Name,
	        			Sales_Channel__c,
	        			End_Date__c
	        	   FROM Calendar__c
	        	  WHERE Id = :dummyGoal.Program__c
	        	];
	       	
	       	//determine goal record type
	        if(cal.Sales_Channel__c == 'Integrated National Program' ||
	           cal.Sales_Channel__c == 'Display/Visibility'){
	        	onPremRecTypeSel = goalRecTypeIdsByName.get('Feature Goals');
	        	offPremRecTypeSel = goalRecTypeIdsByName.get('Display Goals');
	        	goalRecType = 'Display';
	        } else if(cal.Sales_Channel__c == 'Distribution' ||
	           		  cal.Sales_Channel__c == 'Innovation' ||
	           		  cal.Sales_Channel__c == 'Sustainovation'){
	           	onPremRecTypeSel = goalRecTypeIdsByName.get('Distribution Goals');
	        	offPremRecTypeSel = goalRecTypeIdsByName.get('Distribution Goals');
	        	goalRecType = 'Distribution';
	        }
	        dummyGoal.Name = cal.Name;
	        dummyGoal.Sales_Channel__c = cal.Sales_Channel__c;
        } else {
        	localType = [SELECT RecordType.Name FROM Goal__c WHERE Id = :dummyGoal.Id].RecordType.Name;
        }
		
		//query to get account counts
		Set<Id> ownerIds = new Set<Id>();
		Map<String, Integer> accCountsByOwnerPremiseKey = new Map<String, Integer>();
		for(Territory__c terr : terrs){
			ownerIds.add(terr.OwnerId);
			accCountsByOwnerPremiseKey.put(terr.OwnerId + 'On-Premise - Control', 0);
			accCountsByOwnerPremiseKey.put(terr.OwnerId + 'Off-Premise - Control', 0);
			//REMOVE COMBINED accCountsByOwnerPremiseKey.put(terr.OwnerId + 'Combined Premise - Control', 0);
		}
		List<AggregateResult> ars = [ SELECT Count(Id),
											 OwnerId,
											 RecordType.Name
										FROM Account
									   WHERE OwnerId IN :ownerIds
									     AND Territory__c IN :terrs
									     AND RecordType.Name LIKE '% - Control'
									     AND Called_On__c = true
									GROUP BY OwnerId, RecordType.Name
									];
		for(AggregateResult ar : ars){
			String ownerId = String.valueOf(ar.get('OwnerId'));
			String premise = String.valueOf(ar.get('Name'));
			Integer accCount = Integer.valueOf(ar.get('expr0'));
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ownerId + ', ' + premise + ', ' + accCount));
			if(accCount > 0){
				accCountsByOwnerPremiseKey.put(ownerId + '|' + premise, accCount);
			}
		}
		
		Map<String, Goal__c> goalsFromSAMByPrem = new Map<String, Goal__c>();
		if(directorMode){
			if(cal == null){
				samGoals = 
					[SELECT Id,
							Name,
							Program__c,
							Due_Date__c,
							OwnerId,
							Goal_For__c,
							Completed__c,
							Minimum_of_Accounts__c,
							Cases_Displayed__c,
							Account_Grade__c,
							Location_Grade__c,
							Comments__c,
							Content_Link__c,
							Goal_Type__c,
							Percent_of_Universe__c,
							Features_Displayed__c,
							Sales_Channel__c,
							SFA_POS_Items__c,
							RecordTypeId,
							RecordType.Name,
							(SELECT Id,
									Goal__c,
									BrandBottle_Size__c,
									BrandBottle_Size__r.Name
							   FROM Brand_Bottle_Goals__r
							)
					   FROM Goal__c
					  WHERE Id = :dummyGoal.Id
					];
			} else {
				samGoals = 
					[SELECT Id,
							Name,
							Program__c,
							Due_Date__c,
							OwnerId,
							Goal_For__c,
							Completed__c,
							Minimum_of_Accounts__c,
							Cases_Displayed__c,
							Account_Grade__c,
							Location_Grade__c,
							Comments__c,
							Content_Link__c,
							Goal_Type__c,
							Percent_of_Universe__c,
							Features_Displayed__c,
							Sales_Channel__c,
							SFA_POS_Items__c,
							RecordTypeId,
							RecordType.Name,
							(SELECT Id,
									Goal__c,
									BrandBottle_Size__c,
									BrandBottle_Size__r.Name
							   FROM Brand_Bottle_Goals__r
							)
					   FROM Goal__c
					  WHERE Program__c = :cal.Id
					    AND OwnerId = :UserInfo.getUserId()
					    AND CreatedById != :UserInfo.getUserId()
					    AND Sales_Channel__c != 'Local'
					];
				
			}
			for(Goal__c goal : samGoals){
				goalsFromSAMByPrem.put(goal.Goal_Type__c, goal);
				if(goal.Goal_Type__c == 'On-Premise - Control'){
					onPremRecTypeSel = goal.RecordTypeId;
					onPremRecTypeName = goal.RecordType.Name;
				} else if(goal.Goal_Type__c == 'Off-Premise - Control'){
					offPremRecTypeSel = goal.RecordTypeId;
					offPremRecTypeName = goal.RecordType.Name;
				}
			}
		}
		
		//query for previously saved goal records
		List<Goal__c> prevGoals;
		if(cal == null){ 
			prevGoals = [SELECT Id,
					OwnerId,
					Goal_For__c,
					Completed__c,
					Due_Date__c,
					Minimum_of_Accounts__c,
					Cases_Displayed__c,
					Account_Grade__c,
					Location_Grade__c,
					Comments__c,
					Content_Link__c,
					Goal_Type__c,
					Percent_of_Universe__c,
					Features_Displayed__c,
					Sales_Channel__c,
					SFA_POS_Items__c,
					(SELECT Id,
							Goal__c,
							BrandBottle_Size__c,
							BrandBottle_Size__r.Name
					   FROM Brand_Bottle_Goals__r
					)
			   FROM Goal__c
			  WHERE Parent_Goal__c = :dummyGoal.Id
			    AND CreatedById = :UserInfo.getUserId()
			];
		} else {
			prevGoals = [SELECT Id,
					OwnerId,
					Goal_For__c,
					Completed__c,
					Due_Date__c,
					Minimum_of_Accounts__c,
					Cases_Displayed__c,
					Account_Grade__c,
					Location_Grade__c,
					Comments__c,
					Content_Link__c,
					Goal_Type__c,
					Percent_of_Universe__c,
					Features_Displayed__c,
					Sales_Channel__c,
					SFA_POS_Items__c,
					RecordTypeId,
					(SELECT Id,
							Goal__c,
							BrandBottle_Size__c,
							BrandBottle_Size__r.Name
					   FROM Brand_Bottle_Goals__r
					)
			   FROM Goal__c
			  WHERE Program__c = :cal.Id
				AND CreatedById = :UserInfo.getUserId()
			];
			
		}
		Map<String, Goal__c> prevGoalsByKey = new Map<String, Goal__c>();
		if(prevGoals.size() > 0){
			dummyGoal.Due_Date__c = prevGoals[0].Due_Date__c;
			dummyGoal.Account_Grade__c = prevGoals[0].Account_Grade__c;
			dummyGoal.SFA_POS_Items__c = prevGoals[0].SFA_POS_Items__c;
			for(Goal__c prevGoal : prevGoals){
				if(prevGoal.Goal_Type__c == 'On-Premise - Control'){
					onPremRecTypeSel = prevGoal.RecordTypeId;
				} else if(prevGoal.Goal_Type__c == 'Off-Premise - Control'){
					offPremRecTypeSel = prevGoal.RecordTypeId;
				}
				prevGoalsByKey.put(prevGoal.Goal_For__c + '|' + prevGoal.Goal_Type__c, prevGoal);
			}
		} else {
			if(directorMode && samGoals.size() > 0){
				dummyGoal.Due_Date__c = samGoals[0].Due_Date__c;
			} else {
				dummyGoal.Due_Date__c = cal.End_Date__c;
			}
		}
		
		//create ManagerPremise data
		mpsByMgrByPrem = new Map<String, Map<Id, ManagerPremise>>();
		Map<Id, ManagerPremise> onPremMap = new Map<Id, ManagerPremise>();
		Map<Id, ManagerPremise> offPremMap = new Map<Id, ManagerPremise>();
		//REMOVE COMBINED Map<Id, ManagerPremise> combinedMap = new Map<Id, ManagerPremise>(); 
		if(directorMode == false){
			for(Territory__c terr : terrs){
				if(onPremMap.get(terr.Director__c) == null){
					onPremMap.put(terr.Director__c, createMgrPrem(terr, 'On-Premise - Control', prevGoalsByKey.get(terr.Director__c + '|On-Premise - Control'), null));
				} else {
					onPremMap.get(terr.Director__c).stateNames.add(terr.State__c);
				}
				if(offPremMap.get(terr.Director__c) == null){
					offPremMap.put(terr.Director__c, createMgrPrem(terr, 'Off-Premise - Control', prevGoalsByKey.get(terr.Director__c + '|Off-Premise - Control'), null));
				} else {
					offPremMap.get(terr.Director__c).stateNames.add(terr.State__c);
				}
				//REMOVE COMBINED if(combinedMap.get(terr.Director__c) == null){
				//REMOVE COMBINED 	combinedMap.put(terr.Director__c, createMgrPrem(terr, 'Combined Premise - Control', prevGoalsByKey.get(terr.Director__c + '|Combined Premise - Control'), null));
				//REMOVE COMBINED } else {
				//REMOVE COMBINED 	combinedMap.get(terr.Director__c).stateNames.add(terr.State__c);
				//REMOVE COMBINED }
				if(accCountsByOwnerPremiseKey.get(terr.OwnerId + '|On-Premise - Control') != null){
					onPremMap.get(terr.Director__c).accCount += accCountsByOwnerPremiseKey.get(terr.OwnerId + '|On-Premise - Control');
				}
				if(accCountsByOwnerPremiseKey.get(terr.OwnerId + '|Off-Premise - Control') != null){
					offPremMap.get(terr.Director__c).accCount += accCountsByOwnerPremiseKey.get(terr.OwnerId + '|Off-Premise - Control');
				}
				//REMOVE COMBINED if(accCountsByOwnerPremiseKey.get(terr.OwnerId + '|Combined Premise - Control') != null){
				//REMOVE COMBINED 	combinedMap.get(terr.Director__c).accCount += accCountsByOwnerPremiseKey.get(terr.OwnerId + '|Combined Premise - Control');
				//REMOVE COMBINED }
			}
		} else {
			for(Territory__c terr : terrs){
				if(onPremMap.get(terr.Manager__c) == null){
					onPremMap.put(terr.Manager__c, createMgrPrem(terr, 'On-Premise - Control', prevGoalsByKey.get(terr.Manager__c + '|On-Premise - Control'), goalsFromSAMByPrem.get('On-Premise - Control')));
				}
				if(offPremMap.get(terr.Manager__c) == null){
					offPremMap.put(terr.Manager__c, createMgrPrem(terr, 'Off-Premise - Control', prevGoalsByKey.get(terr.Manager__c + '|Off-Premise - Control'), goalsFromSAMByPrem.get('Off-Premise - Control')));
					
				}
				//REMOVE COMBINED if(combinedMap.get(terr.Manager__c) == null){
				//REMOVE COMBINED 	combinedMap.put(terr.Manager__c, createMgrPrem(terr, 'Combined Premise - Control', prevGoalsByKey.get(terr.Manager__c + '|Combined Premise - Control'), goalsFromSAMByPrem.get('Combined Premise - Control')));
				//REMOVE COMBINED }
				if(accCountsByOwnerPremiseKey.get(terr.OwnerId + '|On-Premise - Control') != null){
					onPremMap.get(terr.Manager__c).accCount += accCountsByOwnerPremiseKey.get(terr.OwnerId + '|On-Premise - Control');
					
					
				}
				if(accCountsByOwnerPremiseKey.get(terr.OwnerId + '|Off-Premise - Control') != null){
					offPremMap.get(terr.Manager__c).accCount += accCountsByOwnerPremiseKey.get(terr.OwnerId + '|Off-Premise - Control');
					
					
				}
				//REMOVE COMBINED if(accCountsByOwnerPremiseKey.get(terr.OwnerId + '|Combined Premise - Control') != null){
				//REMOVE COMBINED 	combinedMap.get(terr.Manager__c).accCount += accCountsByOwnerPremiseKey.get(terr.OwnerId + '|Combined Premise - Control');	
				//REMOVE COMBINED }
			}
		}
		mpsByMgrByPrem.put('On-Premise - Control', onPremMap);
		mpsByMgrByPrem.put('Off-Premise - Control', offPremMap);
		//REMOVE COMBINED mpsByMgrByPrem.put('Combined Premise - Control', combinedMap);
		premiseValue = 'On-Premise - Control';
		
		for(Map<Id, ManagerPremise> mpMap : mpsByMgrByPrem.values()){
			for(ManagerPremise mp : mpMap.values()){
				mp.mgrStateString = '';
				if(mp.stateNames.size() > 0){
					for(String stateName : mp.stateNames){
						mp.mgrStateString += stateName + ', ';
					}
					mp.mgrStateString = mp.mgrStateString.subString(0, mp.mgrStateString.length() - 2);
				}
				mp.goal.State__c = mp.mgrStateString;
			}
		}
		
		totalSelectedChanged();
			
		if(readOnlyMode){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You have already created goals for this program.'));
			for(Map<Id, ManagerPremise> mpMap : mpsByMgrByPrem.values()){
				for(ManagerPremise mp : mpMap.values()){
					Goal__c goal = mp.goal;
					if(goal.Minimum_of_Accounts__c == null){
						goal.Minimum_of_Accounts__c = 0;
					}
					if(goal.Cases_Displayed__c == null){
						goal.Cases_Displayed__c = 0;
					}
				}
			}
		}
        
        //default to On-Premise - Control
        premiseSelected();
        
        return null;
	}
	
	private ManagerPremise createMgrPrem(Territory__c terr, String prem, Goal__c prevGoal, Goal__c goalFromSAM){
		ManagerPremise mp = new ManagerPremise();
		mp.stateNames = new Set<String>();
		mp.readOnlyMode = false;
		
		if(directorMode){
			mp.mgrId = terr.Manager__c;
			mp.mgrName = terr.Manager__r.Name;
			mp.stateNames.add(terr.State__c);
		} else {
			mp.mgrId = terr.Director__c;
			mp.mgrName = terr.Director__r.Name;
			mp.stateNames.add(terr.State__c);
		}
		mp.prem = prem;
		mp.accCount = 0;
		mp.bbgOptions = new List<SelectOption>();
		mp.selectedBBGs = new List<String>();
		
		if(goalFromSAM == null && prevGoal == null){
			//new goal
			mp.goal = new Goal__c();
			//if(terr.Director__c == terr.Manager__c){
			//	mp.goal.Goal_Level__c = 'Manager';
			//} else {
				mp.goal.Goal_Level__c = 'Director';
				if(directorMode){
					mp.readOnlyMode = true;
				}
			//}
			if(cal != null){
				mp.goal.Name = cal.Name + ' - ' + prem;
				mp.goal.Program__c = cal.Id;
				mp.goal.Due_Date__c = cal.End_Date__c;
				mp.goal.Sales_Channel__c = cal.Sales_Channel__c;
			}
			mp.goal.OwnerId = UserInfo.getUserId();
			mp.goal.Goal_For__c = mp.mgrId;
			mp.goal.Goal_Type__c = mp.prem;
		} else if(goalFromSAM == null && prevGoal != null){
			//previously saved goal, not from SAM
			mp.goal = prevGoal;
			if(prevGoal.OwnerId == prevGoal.Goal_For__c){
				readOnlyMode = true;
			}
			mp.prevBBGsByBBSId = new Map<Id, Brand_Bottle_Goal__c>();
			for(Brand_Bottle_Goal__c bbg : prevGoal.Brand_Bottle_Goals__r){
				mp.prevBBGsByBBSId.put(bbg.BrandBottle_Size__c, bbg);
				mp.bbgOptions.add(new SelectOption(bbg.BrandBottle_Size__c, bbg.BrandBottle_Size__r.Name));
			}
		} else if(goalFromSAM != null && prevGoal == null){
			//parent goal from SAM, no previous save by director
			mp.parentGoalFromSAM = goalFromSAM;
			mp.goal = new Goal__c();
			mp.goal.Goal_Level__c = 'Manager';
			mp.goal.Parent_Goal__c = goalFromSAM.Id;
			mp.goal.Name = mp.parentGoalFromSAM.Name;
			mp.goal.RecordTypeId = mp.parentGoalFromSAM.RecordTypeId;
			mp.goal.Program__c = mp.parentGoalFromSAM.Program__c;
			mp.goal.Due_Date__c = mp.parentGoalFromSAM.Due_Date__c;
			mp.goal.Sales_Channel__c = mp.parentGoalFromSAM.Sales_Channel__c;
			mp.goal.Location_Grade__c = mp.parentGoalFromSAM.Location_Grade__c;
			mp.goal.Comments__c = mp.parentGoalFromSAM.Comments__c;
			mp.goal.Content_Link__c = mp.parentGoalFromSAM.Content_Link__c;
			mp.goal.Percent_of_Universe__c = mp.parentGoalFromSAM.Percent_of_Universe__c;
			mp.goal.Features_Displayed__c = mp.parentGoalFromSAM.Features_Displayed__c;
			
			dummyGoal.Account_Grade__c = mp.parentGoalFromSAM.Account_Grade__c;
			dummyGoal.SFA_POS_Items__c = mp.parentGoalFromSAM.SFA_POS_Items__c;
			
			mp.goal.OwnerId = UserInfo.getUserId();
			mp.goal.Goal_For__c = mp.mgrId;
			mp.goal.Goal_Type__c = mp.prem;
			for(Brand_Bottle_Goal__c bbg : mp.parentGoalFromSAM.Brand_Bottle_Goals__r){
				mp.bbgOptions.add(new SelectOption(bbg.BrandBottle_Size__c, bbg.BrandBottle_Size__r.Name));
			}
		} else if(goalFromSAM != null && prevGoal != null){
			//parent goal from SAM, plus previous save by director
			mp.goal = prevGoal;
			if(prevGoal.OwnerId == prevGoal.Goal_For__c && prevGoal.Goal_For__c != UserInfo.getUserId()){
			//if(prevGoal.Completed__c == true){
				readOnlyMode = true;
			}
			mp.prevBBGsByBBSId = new Map<Id, Brand_Bottle_Goal__c>();
			for(Brand_Bottle_Goal__c bbg : prevGoal.Brand_Bottle_Goals__r){
				mp.prevBBGsByBBSId.put(bbg.BrandBottle_Size__c, bbg);
				mp.bbgOptions.add(new SelectOption(bbg.BrandBottle_Size__c, bbg.BrandBottle_Size__r.Name));
			}
		}
		
		mp.dummyBBG = new Brand_Bottle_Goal__c();
			
		return mp;
	}
	
	public PageReference premiseSelected(){
		if(premiseValue == 'On-Premise - Control'){
			premiseDispValue = 'On Premise';
			if(isCreatingAssocGoal == false && isCreatingLocalGoal == false){
				showFeatures = goalRecType != 'Distribution' && localType != 'Distribution Goals';
				showCases = false;
			}
		} else if(premiseValue == 'Off-Premise - Control'){
			premiseDispValue = 'Off Premise';
			if(isCreatingAssocGoal == false && isCreatingLocalGoal == false){
				showFeatures = false;
				showCases = goalRecType != 'Distribution' && localType != 'Distribution Goals';
			}
		//REMOVE COMBINED } else if(premiseValue == 'Combined Premise - Control'){
		//REMOVE COMBINED 	premiseDispValue = 'Combined Premise';
		}
		
		//sort territories by state name
		List<String> stateStrings = new List<String>();
		for(ManagerPremise mp : mpsByMgrByPrem.get(premiseValue).values()){
			stateStrings.add(mp.mgrStateString);
		}
		stateStrings.sort();
		Map<String, Integer> indexesByString = new Map<String, Integer>();
		for(String state : stateStrings){
			indexesByString.put(state, indexesByString.size());
		}
		dispMPs = new ManagerPremise[stateStrings.size()];
		for(ManagerPremise mp : mpsByMgrByPrem.get(premiseValue).values()){
			dispMPs.add(indexesByString.get(mp.mgrStateString), mp);
		}
		//dispMPs = mpsByMgrByPrem.get(premiseValue).values();
		
		totalSelectedChanged();
        return null;
	}
	
	public void overallDueDateChanged(){
		for(Map<Id, ManagerPremise> mpMap : mpsByMgrByPrem.values()){
			for(ManagerPremise mp : mpMap.values()){
				if(mp != null){
					mp.goal.Due_Date__c = dummyGoal.Due_Date__c;
				}
			}
		}
	}
	
	public PageReference addBBG(){
		ManagerPremise mp = mpsByMgrByPrem.get(bbgMPPrem).get(bbgMPMgrId);
		if(mp.dummyBBG.BrandBottle_Size__c != null){
			SelectOption opt = new SelectOption(mp.dummyBBG.BrandBottle_Size__c, bbgSelName);
			mp.bbgOptions.add(opt);
		}
		return null;
	}

	public PageReference removeBBGs(){
		ManagerPremise mp = mpsByMgrByPrem.get(bbgMPPrem).get(bbgMPMgrId);
		List<SelectOption> optsToKeep = new List<SelectOption>();
		for(SelectOption opt : mp.bbgOptions){
			Boolean keep = true;
			for(String remId : mp.selectedBBGs){
				if(opt.getValue() == remId){
					keep = false;
				}
			}
			if(keep){
				optsToKeep.add(opt);
			}
		}
		mp.bbgOptions = optsToKeep;
		return null;
	}

	public PageReference copyBBGs(){
		ManagerPremise mp = mpsByMgrByPrem.get(bbgMPPrem).get(bbgMPMgrId);
		
		List<SelectOption> optsToAdd = new List<SelectOption>();
		for(String optId : mp.selectedBBGs){
			for(SelectOption opt : mp.bbgOptions){
				if(opt.getValue() == optId){
					optsToAdd.add(new SelectOption(opt.getValue(), opt.getLabel()));
				}
			}
		}
		
		for(ManagerPremise otherMP : mpsByMgrByPrem.get(bbgMPPrem).values()){
			if(otherMP != mp){
				otherMP.bbgOptions.addAll(optsToAdd);
			}
		}
		return null;
	}
	
	public PageReference totalSelectedChanged(){
		totalAccsSelected = 0;
		totalAccsAvail = 0;
		totalAccsReq = 0;
		totalCasesSelected = 0;
		totalCasesReq = 0;

		for(ManagerPremise mp : mpsByMgrByPrem.get(premiseValue).values()){
			if(mp.goal.Minimum_of_Accounts__c != null){
				totalAccsSelected += Integer.valueOf(mp.goal.Minimum_of_Accounts__c);
			}
			if(mp.goal.Cases_Displayed__c != null){
				totalCasesSelected += Integer.valueOf(mp.goal.Cases_Displayed__c);
			}
			totalAccsAvail += mp.accCount;
			if(directorMode && mp.parentGoalFromSAM != null && totalAccsReq == 0){
				totalAccsReq = Integer.valueOf(mp.parentGoalFromSAM.Minimum_of_Accounts__c);
			}
			if(directorMode && mp.parentGoalFromSAM != null && totalCasesReq == 0){
				totalCasesReq = Integer.valueOf(mp.parentGoalFromSAM.Cases_Displayed__c);
			}
		}
		return null;
	}
	
	public PageReference saveClicked(){
		return doSave(false, false);
	}
	
	public PageReference submitClicked(){
		return doSave(true, true);
	}
	
	public PageReference confirmationCancelClicked(){
		showConfirmation = false;
		return null;
	}
	
	public PageReference confirmationSubmitClicked(){
		return doSave(false, true);
	}
	
	public PageReference doSave(Boolean doErrorCheck, Boolean andSubmit){
		if(doErrorCheck && checkForErrors()){
			return null;
		}
		
		List<Goal__c> goalsToUpsert = new List<Goal__c>();
		List<Goal__c> goalsToDelete = new List<Goal__c>();
		List<ManagerPremise> bbgMPs = new List<ManagerPremise>();
		
		for(Map<Id, ManagerPremise> mpMap : mpsByMgrByPrem.values()){
			for(ManagerPremise mp : mpMap.values()){
				Goal__c goal = mp.goal;
				if(andSubmit){
					goal.OwnerId = goal.Goal_For__c;
				}
				if(isCreatingLocalGoal == true || isCreatingAssocGoal == true){
					goal.Name = dummyGoal.Name;
					goal.Program__c = dummyGoal.Program__c;
					goal.Brand_Category__c = dummyGoal.Brand_Category__c;
					goal.Account_Grade__c = dummyGoal.Account_Grade__c;
					goal.RecordTypeId = dummyGoal.RecordTypeId;
					goal.Sales_Channel__c = dummyGoal.Sales_Channel__c;
					goal.Goal_Type__c = dummyGoal.Goal_Type__c;
					goal.Parent_Goal__c = dummyGoal.Parent_Goal__c;
					//goal.State__c = dummyGoal.State__c;
					
					goal.Content_Link__c = dummyGoal.Content_Link__c;
					goal.Location_Grade__c = dummyGoal.Location_Grade__c;
					goal.Suggested_Price__c = dummyGoal.Suggested_Price__c;
					goal.Feature_Type__c = dummyGoal.Feature_Type__c;
					goal.Size_of_Ad__c = dummyGoal.Size_of_Ad__c;
					goal.Type_of_Ad__c = dummyGoal.Type_of_Ad__c;
					goal.Length_of_Training__c = dummyGoal.Length_of_Training__c;
					goal.Accomplishment_Recap__c = dummyGoal.Accomplishment_Recap__c;
					goal.Number_of_Attendees__c = dummyGoal.Number_of_Attendees__c;
					goal.Tasted_Product__c = dummyGoal.Tasted_Product__c;
					goal.Product_Sample_s__c = dummyGoal.Product_Sample_s__c;
					goal.Trainer__c = dummyGoal.Trainer__c;
					goal.Training_Audience__c = dummyGoal.Training_Audience__c;
					goal.SFA_POS_Items__c = dummyGoal.SFA_POS_Items__c;
					if(directorMode){
						goal.Goal_Level__c = 'Manager';
					} else {
						goal.Goal_Level__c = 'Director';
					}
				} else if(directorMode == false){
					if(goal.Goal_Type__c == 'On-Premise - Control'){
						goal.RecordTypeId = onPremRecTypeSel;
					} else if(goal.Goal_Type__c == 'Off-Premise - Control'){
						goal.RecordTypeId = offPremRecTypeSel;
					}
				}
				if(goal.Cases_Displayed__c == null){
					goal.Cases_Displayed__c = 0;
				}
				if(goal.Minimum_of_Accounts__c > 0){
					//goal.Due_Date__c = dummyGoal.Due_Date__c;
					goal.Account_Grade__c = dummyGoal.Account_Grade__c;
					goal.SFA_POS_Items__c = dummyGoal.SFA_POS_Items__c;
					goalsToUpsert.add(goal);
					bbgMPs.add(mp);
				} else if(goal.Id != null){
					goalsToDelete.add(goal);
				}
			}
		}
		
		if(goalsToDelete.size() > 0){
			upsert goalsToDelete;
		}
		
		if(goalsToUpsert.size() > 0){
			upsert goalsToUpsert;
			
			if(directorMode && andSubmit){
				if(samGoals != null){
					for(Goal__c samGoal : samGoals){
						samGoal.Completed__c = true;
					}
					update samGoals;
				} else if(incomingGoal != null){
					incomingGoal.Completed__c = true;
					update incomingGoal;
				}
			}
			
			List<Brand_Bottle_Goal__c> bbgsToInsert = new List<Brand_Bottle_Goal__c>();
			List<Brand_Bottle_Goal__c> bbgsToDelete = new List<Brand_Bottle_Goal__c>();
			for(ManagerPremise mp : bbgMPs){
				for(SelectOption opt : mp.bbgOptions){
					Brand_Bottle_Goal__c bbg;
					Boolean matchFound = false;
					if(mp.prevBBGsByBBSId != null){
						if(mp.prevBBGsByBBSId.get(opt.getValue()) != null){
							matchFound = true;
							mp.prevBBGsByBBSId.remove(opt.getValue());
						}
					}
					if(matchFound == false){
						bbg = new Brand_Bottle_Goal__c();
						bbg.BrandBottle_Size__c = opt.getValue();
						bbg.Goal__c = mp.goal.Id;
						bbgsToInsert.add(bbg);
					}
				}
				if(mp.prevBBGsByBBSId != null){
					bbgsToDelete.addAll(mp.prevBBGsByBBSId.values());
				}
			}
			
			if(bbgsToInsert.size() > 0){
				insert bbgsToInsert;
			}
			if(bbgsToDelete.size() > 0){
				delete bbgsToDelete;
			}
			
			String messageString = 'Your goals have been saved';
			if(andSubmit){
				if(directorMode){
					messageString += ' and assigned to the appropriate Managers.';
				} else {
					messageString += ' and assigned to the appropriate Directors / Managers.';
				}
			} else {
				messageString += ' for editing at a later time.';
			}
			//messageString += ' You may select another Program or create a local goal.';
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, messageString));
			resetView();
		} else {
			if(andSubmit == false){
				String messageString = 'Nothing to save. Please enter a non-zero value for "Goal" on the goals you\'d like to save.';
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, messageString));
			}
		}
		
		return null;
	}
	
	public Boolean checkForErrors(){
		Boolean overallError = false;
		String premToShow;
		
		if(isCreatingLocalGoal == true && dummyGoal.Name == null){
			dummyGoal.Name.addError('Please enter a Goal Name value.');
			return true;
		}
		
		//do hard validations
		for(String premKey : mpsByMgrByPrem.keySet()){
			Map<Id, ManagerPremise> mpMap = mpsByMgrByPrem.get(premKey);
			for(ManagerPremise mp : mpMap.values()){
				Boolean mpHasError = false;
				//if(mp.goal.Minimum_of_Accounts__c > mp.accCount){
					//mpHasError = true;
					//mp.goal.Minimum_of_Accounts__c.addError('Goal value is higher than actual number of available accounts (' + mp.accCount + ').');
				//}
				if(mpHasError == true){
					overallError = true;
					if(premToShow == null){
						premToShow = premKey;
					} else if(premKey == 'On-Premise - Control' && premToShow != 'On-Premise - Control'){
						premToShow = 'On-Premise - Control';
					} else if(premKey == 'Off-Premise - Control' && premToShow != 'On-Premise - Control'){
						premToShow = 'Off-Premise - Control';
					}
				}
			}
		}
		
		if(overallError){
			premiseValue = premToShow;
			premiseSelected();
			return true;
		}
		
		//do soft validations
		Integer incompleteMPs = 0;
		Integer totalMPs = 0;
		Integer totalAccounts = 0;
		Integer totalCases = 0;
		
		for(String premKey : mpsByMgrByPrem.keySet()){
			Map<Id, ManagerPremise> mpMap = mpsByMgrByPrem.get(premKey);
			for(ManagerPremise mp : mpMap.values()){
					totalMPs++;
				if(mp.readOnlyMode == false){
					Boolean nullOrZeroGoal = mp.goal.Minimum_of_Accounts__c == null || mp.goal.Minimum_of_Accounts__c == 0;
					Boolean nullOrZeroCases = mp.goal.Cases_Displayed__c == null || mp.goal.Cases_Displayed__c == 0;
					if(nullOrZeroGoal){
						incompleteMPs++;
					} else {
						totalAccounts += Integer.valueOf(mp.goal.Minimum_of_Accounts__c);
					}
					if(nullOrZeroCases == false){
						totalCases += Integer.valueOf(mp.goal.Cases_Displayed__c);
					}
				}
			}
		}
		
		if(incompleteMPs == totalMPs){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must enter a "Goal" value for at least 1 state/premise combination.'));
			return true;
		//} else if(totalAccounts < totalAccsReq){
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You have not goaled out enough Accounts.'));
			//return true;
		//} else if(totalCasesReq > 0 && totalCases < totalCasesReq){
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You have not goaled out enough Cases Displayed.'));
			//return true;
		} else if(incompleteMPs == 0){
			showConfirmation = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Submitting these goals will assign them to the appropriate users. You will not be able to make further changes. Continue?'));
			return true;
		} else if(incompleteMPs == 1){
			showConfirmation = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You have not entered a "Goal" value for 1 state/premise combination. A goal will not be created for that combination. Continue anyway?'));
			return true;
		} else if(incompleteMPs > 1){
			showConfirmation = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You have not entered a "Goal" value for ' + incompleteMPs + ' state/premise combinations. Goals will not be created for those combinations. Continue anyway?'));
			return true;
		}
		
		return false;
	}
	
	public void resetView(){
		incomingGoal = null;
		isCreatingLocalGoal = false;
		isCreatingAssocGoal = false;
		isProgramSelected = false;
		init();
	}
	 */
}