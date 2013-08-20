public with sharing class PerformanceController {
	
	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'DAVE TEST, PLEASE IGNORE: ' + q));
	
	public String userMode {get;set;}
	
	public Boolean showDueDate {get;set;}
	public Boolean showLevel {get;set;}
	public Boolean showGoalName {get;set;}
	public Boolean showBFieldFilter {get;set;}
	/*public Boolean showPClass {get;set;}
	public Boolean showPGroup {get;set;}
	public Boolean showGBrand {get;set;}
	public Boolean showSBrand {get;set;}
	public Boolean showIBrand {get;set;}
	public Boolean showSize {get;set;}*/
	public Boolean showGoalType {get;set;}
	public Boolean showGoalFor {get;set;}
	public Boolean showPriority {get;set;}
	public Boolean showRecType {get;set;}
	public Boolean showState {get;set;}
	public Boolean showGroupBy {get;set;}
	public Boolean showSortBy {get;set;}
	
	public Integer resultSize {get;set;}
	public Integer chartHeight {get;set;}
	
	public List<SelectOption> dateSelections {get;set;}
	public List<SelectOption> levelSelections {get;set;}
	public List<SelectOption> nameSelections {get;set;}
	public List<SelectOption> bFieldTypeSelections {get;set;}
	public List<SelectOption> bFieldValueSelections {get;set;}
	/*public List<SelectOption> pClassSelections {get;set;}
	public List<SelectOption> pGroupSelections {get;set;}
	public List<SelectOption> gBrandSelections {get;set;}
	public List<SelectOption> sBrandSelections {get;set;}
	public List<SelectOption> iBrandSelections {get;set;}
	public List<SelectOption> sizeSelections {get;set;}*/
	public List<SelectOption> typeSelections {get;set;}
	public List<SelectOption> forSelections {get;set;}
	public List<SelectOption> priorSelections {get;set;}
	public List<SelectOption> rtSelections {get;set;}
	public List<SelectOption> stateSelections {get;set;}
	public List<SelectOption> groupBySelections {get;set;}
	public List<SelectOption> sortBySelections {get;set;}
	
	private Set<String> bFieldValueLabels {get;set;}
	private Set<String> pClassLabels {get;set;}
	private Set<String> pGroupLabels {get;set;}
	private Set<String> rBrandLabels {get;set;}
	private Set<String> gBrandLabels {get;set;}
	private Set<String> sBrandLabels {get;set;}
	private Set<String> iBrandLabels {get;set;}
	private Set<String> sizeLabels {get;set;}
	private Set<String> indBrandSizeLabels {get;set;}
	
	Map<Id, List<Goal_Brand_Report_Item__c>> gbriListsByGoalId	{get;set;}
	
	public String dateSel {get;set;}
	public String levelSel {get;set;}
	public String nameSel {get;set;}
	public String bFieldTypeSel {get;set;}
	public String bFieldValueSel {get;set;}
	/*public String pClassSel {get;set;}
	public String pGroupSel {get;set;}
	public String gBrandSel {get;set;}
	public String sBrandSel {get;set;}
	public String iBrandSel {get;set;}
	public String sizeSel {get;set;}*/
	public String typeSel {get;set;}
	public String forSel {get;set;}
	public String forLabel {get;set;}
	public String priorSel {get;set;}
	public String rtSel {get;set;}
	public String stateSel {get;set;}
	public String groupBySel {get;set;}
	public String sortBySel {get;set;}
	
	public String chartTitle {get;set;}
	public String leftAxisLabel {get;set;}
	
	public List<Data> byStateData {get;set;}
	public List<Data> dataToUse {get;set;}
	
	public static Set<String> WEST_STATES = new Set<String>{
		'ID',
		'IA',
		'MI',
		'MT',
		'OH',
		'OR',
		'UT',
		'WY'
		};
	public static Set<String> EAST_STATES = new Set<String>{
		'AL',
		'ME',
		'MS',
		'NH',
		'NC',
		'PA',
		'VT',
		'VA',
		'WV'
		};
		
	public class Data {
		String name {get;set;}
		Decimal dispValue {get;set;}
		Decimal actualValue {get;set;}
		String fullName {get;set;}
		String tipValue {get;set;}
		
		public Data(String fullName, Decimal actualValue){
			this.fullName = fullName;
			if(fullName.length() > 40){
				this.name = fullName.substring(0, 40);
			} else {
				this.name = fullName;
			}
			this.actualValue = actualValue;
			this.dispValue = actualValue;
			if(this.dispValue > 100){
				this.dispValue = 100;
			}
			this.tipValue = String.valueOf(Math.floor(actualValue)) + '%';
		}
	}

	public PerformanceController(){
		determineUserMode();
		determineVisibility();
		populateDateDropdowns();
		dateChanged();
	}
	
	private void determineUserMode(){
		String profileName = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
		if(profileName == 'System Administrator' || profileName == 'Control - SAM'){
			userMode = 'sam';
			return;
		}

		Id userId = UserInfo.getUserId();
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
		} else if(!isSam && !isDirector && isManager){
			userMode = 'mgr';
		} else if(!isSam && isDirector && isManager){
			userMode = 'dir';
			showLevel = true;
		} else {
			userMode = 'rep';
		}
	}
	
	private void determineVisibility(){
		if(showLevel != true){
			showLevel = false;
		}
		showDueDate = true;
		showGoalName = true;
		showBFieldFilter = true;
		/*showPClass = true;
		showPGroup = true;
		showGBrand = true;
		showSBrand = true;
		showIBrand = true;
		showSize = true;*/
		showGoalType = true;
		showPriority = true;
		showRecType = true;
		showState = true;
		showGroupBy = true;
		showSortBy = true;
		
		showGoalFor = true;
		if(userMode == 'sam'){
			forLabel = 'Director';
		} else if(userMode == 'dir'){
			forLabel = 'Manager';
		} else if(userMode == 'mgr'){
			forLabel = 'Rep';
		} else if(userMode == 'rep'){
			forLabel = 'Rep';
		}
	}
	
	private void populateDateDropdowns(){
		dateSelections = new List<SelectOption>();
		dateSelections.add(new SelectOption('last', 'Last Month'));
		dateSelections.add(new SelectOption('this', 'This Month'));
		dateSelections.add(new SelectOption('next', 'Next Month'));
		
		if(showLevel){
			levelSelections = new List<SelectOption>();
			levelSelections.add(new SelectOption('dir', 'Director'));
			levelSelections.add(new SelectOption('mgr', 'Manager'));
		}
		
		setInitialValues();
	}
	
	private void setInitialValues(){
		dateSel = 'this';
		levelSel = 'dir';
		nameSel = 'all';
		bFieldTypeSel = 'Generic Brand';
		bFieldValueSel = 'all';
		/*pGroupSel = 'all';
		pClassSel = 'all';
		gBrandSel = 'all';
		sBrandSel = 'all';
		iBrandSel = 'all';
		sizeSel = 'all';*/
		typeSel = 'all';
		forSel = 'all';
		priorSel = 'all';
		rtSel = 'all';
		groupBySel = 'Generic Brand';
		sortBySel = 'perc';
	}
	
	private String encodeDate(Date d){
		String s = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
		return s;
	}
	
	public void dateChanged(){
		refreshGoalDropdowns();
	}
	
	public void levelChanged(){
		userMode = levelSel;
		determineVisibility();
		refreshGoalDropdowns();
	}
	
	private void refreshGoalDropdowns(){
		String q = 'SELECT Id';
		q += ', Name';
		q += ', Long_Name__c';
		q += ', Goal_Type__c';
		q += ', Goal_For__c';
		q += ', Goal_For__r.Name';
		q += ', Priority__c';
		q += ', RecordTypeId';
		q += ', RecordType.Name';
		q += ', State__c';
		q += ', Minimum_of_Accounts__c';
		q += ', Action_Complete__c';
		
		q += ', (SELECT Id';
		q += '		  , Level__c';
		q += '		  , Label__c';
		q += '     FROM Goal_Brand_Report_Items__r';
		q += '    WHERE Label__c != \'(Undefined)\')';
		
		q += ' FROM Goal__c';
		q += ' WHERE Minimum_of_Accounts__c != null';
		q += ' AND Action_Complete__c != null';
		//q += ' AND Name LIKE \'%-%\'';
		q += ' AND Goal_Type__c LIKE \'% - Control\'';
		q += ' AND Goal_For__c != null';
		q += ' AND State__c != null';
		q += ' AND Priority__c != null';
		
		if(dateSel == 'last'){
			String startString = encodeDate(Date.today().toStartOfMonth().addMonths(-1));
			String endString = encodeDate(Date.today().toStartOfMonth().addDays(-1));
			q += ' AND Due_Date__c >= ' + startString;
			q += ' AND Due_Date__c <= ' + endString;
		} else if(dateSel == 'this'){
			String startString = encodeDate(Date.today().toStartOfMonth());
			String endString = encodeDate(Date.today().toStartOfMonth().addMonths(1).addDays(-1));
			q += ' AND Due_Date__c >= ' + startString;
			q += ' AND Due_Date__c <= ' + endString;
		} else if(dateSel == 'next'){
			String startString = encodeDate(Date.today().toStartOfMonth().addMonths(1));
			String endString = encodeDate(Date.today().toStartOfMonth().addMonths(2).addDays(-1));
			q += ' AND Due_Date__c >= ' + startString;
			q += ' AND Due_Date__c <= ' + endString;
		}
		
		if(userMode == 'sam'){
			q += ' AND Goal_Level__c = \'Director\'';
		} else if(userMode == 'dir'){
			q += ' AND Goal_Level__c = \'Manager\'';
		} else if(userMode == 'mgr'){
			q += ' AND Goal_Level__c = \'Rep\'';
		} else if(userMode == 'rep'){
			q += ' AND Goal_Level__c = \'Rep\'';
		}
		
		//q+= ' LIMIT 1000';
		
		
		Set<String> shortNames = new Set<String>();
		pClassLabels = new Set<String>();
		pGroupLabels = new Set<String>();
		rBrandLabels = new Set<String>();
		gBrandLabels = new Set<String>();
		sBrandLabels = new Set<String>();
		iBrandLabels = new Set<String>();
		sizeLabels = new Set<String>();
		indBrandSizeLabels = new Set<String>();
		Set<String> goalTypes = new Set<String>();
		Set<String> forNames = new Set<String>();
		Set<String> priorTypes = new Set<String>();
		Set<String> rtNames = new Set<String>();
		Set<String> stateNames = new Set<String>();
		
		gbriListsByGoalId = new Map<Id, List<Goal_Brand_Report_Item__c>>();
		
		for(Goal__c goal : Database.query(q)){
			String shortName;
			if(goal.Long_Name__c == null){
				shortName = goal.Name.split(' - ')[0];
			} else {
				shortName = goal.Long_Name__c.split(' - ')[1];
			}
			shortNames.add(shortName);
			
			gbriListsByGoalId.put(goal.Id, goal.Goal_Brand_Report_Items__r);
			for(Goal_Brand_Report_Item__c gbri : goal.Goal_Brand_Report_Items__r){
				if(gbri.Level__c == 'Product Classification'){
					pClassLabels.add(gbri.Label__c);
				}
				if(gbri.Level__c == 'Product Group'){
					pGroupLabels.add(gbri.Label__c);
				}
				if(gbri.Level__c == 'Report Brand'){
					rBrandLabels.add(gbri.Label__c);
				}
				if(gbri.Level__c == 'Generic Brand'){
					gBrandLabels.add(gbri.Label__c);
				}
				if(gbri.Level__c == 'Sub Brand'){
					sBrandLabels.add(gbri.Label__c);
				}
				if(gbri.Level__c == 'Individual Brand'){
					iBrandLabels.add(gbri.Label__c);
				}
				if(gbri.Level__c == 'Size'){
					sizeLabels.add(gbri.Label__c);
				}
				if(gbri.Level__c == 'Report Brand'){
					rBrandLabels.add(gbri.Label__c);
				}
				if(gbri.Level__c == 'Ind. Brand / Size'){
					indBrandSizeLabels.add(gbri.Label__c);
				}
			}
			
			goalTypes.add(goal.Goal_Type__c);
			forNames.add(goal.Goal_For__r.Name);
			priorTypes.add(goal.Priority__c);
			rtNames.add(goal.RecordType.Name);
			stateNames.add(goal.State__c);
		}
		
		nameSelections = new List<SelectOption>();
		nameSelections.add(new SelectOption('all', '--- All ---'));
		List<String> sortedKeys = new List<String>(shortNames);
		sortedKeys.sort();
		for(String name : sortedKeys){
			String truncName = name;
			if(name.length() > 50){
				truncName = name.substring(0, 50);
			}
			nameSelections.add(new SelectOption(truncName, truncName));
		}
		
		bFieldTypeSelections = new List<SelectOption>();
		bFieldTypeSelections.add(new SelectOption('Product Classification', 'Product Classification'));
		bFieldTypeSelections.add(new SelectOption('Product Group', 'Product Group'));
		bFieldTypeSelections.add(new SelectOption('Report Brand', 'Report Brand'));
		bFieldTypeSelections.add(new SelectOption('Generic Brand', 'Generic Brand'));
		bFieldTypeSelections.add(new SelectOption('Sub Brand', 'Sub Brand'));
		bFieldTypeSelections.add(new SelectOption('Individual Brand', 'Individual Brand'));
		bFieldTypeSelections.add(new SelectOption('Size', 'Size'));
		bFieldTypeSelections.add(new SelectOption('Ind. Brand / Size', 'Ind. Brand / Size'));
		
		refreshBFieldValueSelections();
		
		/*
		pClassSelections = new List<SelectOption>();
		pClassSelections.add(new SelectOption('all', '--- All ---'));
		sortedKeys = new List<String>(pClassLabels);
		sortedKeys.sort();
		for(String name : sortedKeys){
			pClassSelections.add(new SelectOption(name, name));
		}
		
		pGroupSelections = new List<SelectOption>();
		pGroupSelections.add(new SelectOption('all', '--- All ---'));
		sortedKeys = new List<String>(pGroupLabels);
		sortedKeys.sort();
		for(String name : sortedKeys){
			pGroupSelections.add(new SelectOption(name, name));
		}
		
		gBrandSelections = new List<SelectOption>();
		gBrandSelections.add(new SelectOption('all', '--- All ---'));
		sortedKeys = new List<String>(gBrandLabels);
		sortedKeys.sort();
		for(String name : sortedKeys){
			gBrandSelections.add(new SelectOption(name, name));
		}
		
		sBrandSelections = new List<SelectOption>();
		sBrandSelections.add(new SelectOption('all', '--- All ---'));
		sortedKeys = new List<String>(sBrandLabels);
		sortedKeys.sort();
		for(String name : sortedKeys){
			sBrandSelections.add(new SelectOption(name, name));
		}
		
		iBrandSelections = new List<SelectOption>();
		iBrandSelections.add(new SelectOption('all', '--- All ---'));
		sortedKeys = new List<String>(iBrandLabels);
		sortedKeys.sort();
		for(String name : sortedKeys){
			iBrandSelections.add(new SelectOption(name, name));
		}
		
		sizeSelections = new List<SelectOption>();
		sizeSelections.add(new SelectOption('all', '--- All ---'));
		sortedKeys = new List<String>(sizeLabels);
		sortedKeys.sort();
		for(String name : sortedKeys){
			sizeSelections.add(new SelectOption(name, name));
		}
		*/
		
		typeSelections = new List<SelectOption>();
		typeSelections.add(new SelectOption('all', '--- All ---'));
		List<String> sortedGoalTypes = new List<String>(goalTypes);
		sortedGoalTypes.sort();
		for(String typee : sortedGoalTypes){
			typeSelections.add(new SelectOption(typee, typee));
		}
		
		forSelections = new List<SelectOption>();
		forSelections.add(new SelectOption('all', '--- All ---'));
		sortedKeys = new List<String>(forNames);
		sortedKeys.sort();
		for(String name : sortedKeys){
			forSelections.add(new SelectOption(name, name));
		}
		
		priorSelections = new List<SelectOption>();
		priorSelections.add(new SelectOption('all', '--- All ---'));
		List<String> sortedPriorTypes = new List<String>(priorTypes);
		sortedPriorTypes.sort();
		for(String prior : sortedPriorTypes){
			priorSelections.add(new SelectOption(prior, prior));
		}
		
		rtSelections = new List<SelectOption>();
		rtSelections.add(new SelectOption('all', '--- All ---'));
		sortedKeys = new List<String>(rtNames);
		sortedKeys.sort();
		for(String name : sortedKeys){
			rtSelections.add(new SelectOption(name, name));
		}
		
		stateSelections = new List<SelectOption>();
		stateSelections.add(new SelectOption('all', '--- All ---'));
		if(userMode == 'sam'){
			stateSelections.add(new SelectOption('east', '--- All East ---'));
			stateSelections.add(new SelectOption('west', '--- All West ---'));
		}
		sortedKeys = new List<String>(stateNames);
		sortedKeys.sort();
		for(String name : sortedKeys){
			stateSelections.add(new SelectOption(name, name));
		}
		
		refreshGroupBySelections();
		
		sortBySelections = new List<SelectOption>();
		sortBySelections.add(new SelectOption('perc', 'Percentage'));
		sortBySelections.add(new SelectOption('name', 'Name'));
		
		//check to see if previous selections are still in the list
		if(shortNames.contains(nameSel) == false){
			nameSel = 'all';
		}
		
		if(bFieldValueLabels.contains(bFieldValueSel) == false){
			bFieldValueSel = 'all';
		}
		
		/*if(pClassLabels.contains(pClassSel) == false){
			pClassSel = 'all';
		}
		if(pGroupLabels.contains(pGroupSel) == false){
			pGroupSel = 'all';
		}
		if(gBrandLabels.contains(gBrandSel) == false){
			gBrandSel = 'all';
		}
		if(sBrandLabels.contains(sBrandSel) == false){
			sBrandSel = 'all';
		}
		if(iBrandLabels.contains(iBrandSel) == false){
			iBrandSel = 'all';
		}
		if(sizeLabels.contains(sizeSel) == false){
			sizeSel = 'all';
		}*/
		
		if(goalTypes.contains(typeSel) == false){
			typeSel = 'all';
		}
		if(forNames.contains(forSel) == false){
			forSel = 'all';
		}
		if(priorTypes.contains(priorSel) == false){
			priorSel = 'all';
		}
		if(rtNames.contains(rtSel) == false){
			rtSel = 'all';
		}
		if(stateNames.contains(stateSel) == false){
			stateSel = 'all';
		}
		
		refreshCharts();
	}
	
	private void refreshBFieldValueSelections(){
		bFieldValueSelections = new List<SelectOption>();
		bFieldValueSelections.add(new SelectOption('all', '--- All ---'));
		
		if(bFieldTypeSel == 'Product Classification'){
			bFieldValueLabels = pClassLabels;
		}
		if(bFieldTypeSel == 'Product Group'){
			bFieldValueLabels = pGroupLabels;
		}
		if(bFieldTypeSel == 'Report Brand'){
			bFieldValueLabels = rBrandLabels;
		}
		if(bFieldTypeSel == 'Generic Brand'){
			bFieldValueLabels = gBrandLabels;
		}
		if(bFieldTypeSel == 'Sub Brand'){
			bFieldValueLabels = sBrandLabels;
		}
		if(bFieldTypeSel == 'Individual Brand'){
			bFieldValueLabels = iBrandLabels;
		}
		if(bFieldTypeSel == 'Size'){
			bFieldValueLabels = sizeLabels;
		}
		if(bFieldTypeSel == 'Ind. Brand / Size'){
			bFieldValueLabels = indBrandSizeLabels;
		}
		
		List<String> sortList = new List<String>(bFieldValueLabels);
		sortList.sort();
		for(String label : sortList){
			bFieldValueSelections.add(new SelectOption(label, label));
		}
	}
	
	private void refreshGroupBySelections(){
		groupBySelections = new List<SelectOption>();
		groupBySelections.add(new SelectOption(bFieldTypeSel, bFieldTypeSel));
		groupBySelections.add(new SelectOption('Name', 'Name'));
		groupBySelections.add(new SelectOption('Subdivision', 'Subdivision'));
		groupBySelections.add(new SelectOption('State', 'State'));
		groupBySelections.add(new SelectOption(forLabel, forLabel));
		
		if(groupBySel != 'Name' &&
		   groupBySel != 'Subdivision' &&
		   groupBySel != 'State' &&
		   groupBySel != forLabel){
			groupBySel = bFieldTypeSel;   	
		}
	}
	
	public void nameChanged(){
		refreshCharts();
	}
	
	public void bFieldTypeChanged(){
		refreshBFieldValueSelections();
		bFieldValueSel = 'all';
		refreshGroupBySelections();
		refreshCharts();
	}
	
	public void bFieldValueChanged(){
		refreshCharts();
	}
	
	/*
	public void pClassChanged(){
		refreshCharts();
	}
	
	public void pGroupChanged(){
		refreshCharts();
	}
	
	public void gBrandChanged(){
		refreshCharts();
	}
	
	public void sBrandChanged(){
		refreshCharts();
	}
	
	public void iBrandChanged(){
		refreshCharts();
	}
	
	public void sizeChanged(){
		refreshCharts();
	}
	*/
	
	public void typeChanged(){
		refreshCharts();
	}
	
	public void forChanged(){
		refreshCharts();
	}
	
	public void priorChanged(){
		refreshCharts();
	}
	
	public void rtChanged(){
		refreshCharts();
	}
	
	public void stateChanged(){
		refreshCharts();
	}
	
	public void groupByChanged(){
		refreshCharts();
	}
	
	public void sortByChanged(){
		refreshCharts();
	}
	
	public void refreshCharts(){
		dataToUse = new List<Data>();
		resultSize = 0;
		
		Map<String, Decimal> minsByGroupName = new Map<String, Decimal>();
		Map<String, Decimal> compsByGroupName = new Map<String, Decimal>();
		
		Boolean groupingByBrandField = false;
		if(groupBySel == 'Product Classification' ||
			groupBySel == 'Product Group' ||
			groupBySel == 'Report Brand' ||
			groupBySel == 'Generic Brand' ||
			groupBySel == 'Sub Brand' ||
			groupBySel == 'Individual Brand' ||
			groupBySel == 'Size' ||
			groupBySel == 'Ind. Brand / Size'){
				groupingByBrandField = true;
		}
		
		/*Map<String, String> brandFieldFilters = new Map<String, String>();
		if(pClassSel != 'all'){
			brandFieldFilters.put('Product_Classification__c', pClassSel);
		}
		if(pGroupSel != 'all'){
			brandFieldFilters.put('Product_Group__c', pGroupSel);
		}
		if(gBrandSel != 'all'){
			brandFieldFilters.put('Generic_Brand__c', gBrandSel);
		}
		if(sBrandSel != 'all'){
			brandFieldFilters.put('Sub_Brand__c', sBrandSel);
		}
		if(iBrandSel != 'all'){
			brandFieldFilters.put('Individual_Brand__c', iBrandSel);
		}
		if(sizeSel != 'all'){
			brandFieldFilters.put('Size__c', sizeSel);
		}*/
		
		String q = 'SELECT Id';
		q += ', Name';
		q += ', Minimum_of_Accounts__c';
		q += ', State__c';
		q += ', Goal_For__r.Name';
		q += ', Action_Complete__c';
		
		q += ', (SELECT Id';
		q += '		  , Level__c';
		q += '		  , Label__c';
		q += '		  , Completed_Actions__c';
		q += '     FROM Goal_Brand_Report_Items__r';
		q += '     WHERE Label__c != \'(Undefined)\'';
		if(groupingByBrandField){
			q += '	 AND Level__c = \'' + groupBySel + '\'';
		}
		if(bFieldValueSel != 'all'){
			q += '	 AND Label__c = \'' + bFieldValueSel + '\'';
		}
		/*if(brandFieldFilters.size() > 0){
			q += '   AND (';
			List<String> keys = new List<String>(brandFieldFilters.keySet());
			for(Integer i = 0; i < keys.size(); i++){
				q += keys[i] + ' = \'' + brandFieldFilters.get(keys[i]) + '\'';
				if(i < keys.size() - 1){
					q += ' OR ';
				}
			}
			q += '   )';
		}*/
		q += '  )';
		
		q += ' FROM Goal__c';
		q += ' WHERE Minimum_of_Accounts__c != null';
		//q += ' AND Name LIKE \'%-%\'';
		q += ' AND Goal_Type__c LIKE \'% - Control\'';
		q += ' AND Goal_For__c != null';
		q += ' AND State__c != null';
		q += ' AND Priority__c != null';
		
		if(dateSel == 'last'){
			String startString = encodeDate(Date.today().toStartOfMonth().addMonths(-1));
			String endString = encodeDate(Date.today().toStartOfMonth().addDays(-1));
			q += ' AND Due_Date__c >= ' + startString;
			q += ' AND Due_Date__c <= ' + endString;
		} else if(dateSel == 'this'){
			String startString = encodeDate(Date.today().toStartOfMonth());
			String endString = encodeDate(Date.today().toStartOfMonth().addMonths(1).addDays(-1));
			q += ' AND Due_Date__c >= ' + startString;
			q += ' AND Due_Date__c <= ' + endString;
		} else if(dateSel == 'next'){
			String startString = encodeDate(Date.today().toStartOfMonth().addMonths(1));
			String endString = encodeDate(Date.today().toStartOfMonth().addMonths(2).addDays(-1));
			q += ' AND Due_Date__c >= ' + startString;
			q += ' AND Due_Date__c <= ' + endString;
		}
		
		if(userMode == 'sam'){
			q += ' AND Goal_Level__c = \'Director\'';
		} else if(userMode == 'dir'){
			q += ' AND Goal_Level__c = \'Manager\'';
		} else if(userMode == 'mgr'){
			q += ' AND Goal_Level__c = \'Rep\'';
		} else if(userMode == 'rep'){
			q += ' AND Goal_Level__c = \'Rep\'';
		}
		
		if(typeSel != 'all'){
			q += ' AND Goal_Type__c = \'' + typeSel + '\''; 
		}
		if(forSel != 'all'){
			q += ' AND Goal_For__r.Name = \'' + forSel + '\''; 
		}
		if(priorSel != 'all'){
			q += ' AND Priority__c = \'' + priorSel + '\''; 
		}
		if(rtSel != 'all'){
			q += ' AND RecordType.Name = \'' + rtSel + '\''; 
		}
		if(stateSel == 'east'){
			q += ' AND State__c IN :EAST_STATES';
		} else if(stateSel == 'west'){
			q += ' AND State__c IN :WEST_STATES';	
		} else if(stateSel != 'all'){
			q += ' AND State__c = \'' + stateSel + '\''; 
		}
		if(nameSel != 'all'){
			if(nameSel.length() == 50){
				q += ' AND Name LIKE \'%' + nameSel + '%\'';
			} else {
				q += ' AND Name LIKE \'%' + nameSel + ' - %\'';
			}
		}
		
		String groupName;
		Integer goalCount;
		Integer actCount;
		Decimal existingMin;
		Decimal existingComp;
		
		for(Goal__c goal : database.query(q)){
			if(groupBySel == 'Name'){
				String shortName;
				String[] splitName = goal.Name.split(' - ');
				if(splitName.size() <= 1){
					shortName = splitName[0];
				} else if(splitName[1].contains('Premise')){
					shortName = splitName[0];
				} else {
					shortName = splitName[1];
				}
				groupName = shortName;
			} else if(groupBySel == 'Subdivision'){
				if(WEST_STATES.contains(goal.State__c)){
					groupName = 'West';
				} else if(EAST_STATES.contains(goal.State__c)){
					groupName = 'East';
				} else {
					groupName = 'Other';
				}
			} else if(groupBySel == 'State'){
				groupName = goal.State__c;
			} else if(groupBySel == forLabel){
				groupName = goal.Goal_For__r.Name;
			} else {
				//groupingByBrandField = true;
			}
			
			goalCount = Integer.valueOf(goal.Minimum_of_Accounts__c);
			
			if(!groupingByBrandField){
				//ensure that it meets current filter before adding
				if(goal.Goal_Brand_Report_Items__r.size() > 0){
					actCount = Integer.valueOf(goal.Action_Complete__c);
					
					existingMin = minsByGroupName.get(groupName);
					if(existingMin == null){
						existingMin = 0;
						existingComp = 0;
					} else {
						existingComp = compsByGroupName.get(groupName);
					}
					existingMin += goalCount;
					existingComp += actCount;
					minsByGroupName.put(groupName, existingMin);
					compsByGroupName.put(groupName, existingComp);
				}
			} else {
				actCount = 0;
				
				for(Goal_Brand_Report_Item__c gbri : goal.Goal_Brand_Report_Items__r){
					groupName = gbri.Label__c;
					actCount = Integer.valueOf(gbri.Completed_Actions__c);
					
					existingMin = minsByGroupName.get(groupName);
					if(existingMin == null){
						existingMin = 0;
						existingComp = 0;
					} else {
						existingComp = compsByGroupName.get(groupName);
					}
					existingMin += goalCount;
					existingComp += actCount;
					minsByGroupName.put(groupName, existingMin);
					compsByGroupName.put(groupName, existingComp);
				}
			}
		}
		
		Map<String, Decimal> percsByName = new Map<String, Decimal>();
		Map<Decimal, String> namesByPerc = new Map<Decimal, String>();
		for(String groupName2 : minsByGroupName.keySet()){
			groupName = groupName2;
			Decimal min = minsByGroupName.get(groupName);
			Decimal comp = compsByGroupName.get(groupName);
			Decimal perc = 0;
			if(min != 0){
				perc = Math.floor(comp / min * 100);
			}
			percsByName.put(groupName, perc);
			while(namesByPerc.get(perc) != null){
				perc += 0.00001;
			}
			namesByPerc.put(perc, groupName);
		}
		if(sortBySel == 'perc'){
			List<Decimal> allPercs = new List<Decimal>(namesByPerc.keySet());
			allPercs.sort();
			for(Decimal perc : allPercs){
				groupName = namesByPerc.get(perc);
				dataToUse.add(new Data(groupName, perc));
			}
		} else if(sortBySel == 'name'){
			List<String> allNames = new List<String>(percsByName.keySet());
			allNames.sort();
			for(Integer i = allNames.size() - 1; i >= 0; i--){
				String name = allNames[i];
				Decimal groupPerc = percsByName.get(name);
				dataToUse.add(new Data(name, groupPerc));
			}
		}
		
		chartTitle = 'By ' + groupBySel;
		leftAxisLabel = groupBySel;
		
		if(dataToUse != null){
			chartHeight = dataToUse.size() * 15 + 120;
		}
	}
}