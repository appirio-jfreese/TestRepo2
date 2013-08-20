public with sharing class ActionCompleteDashboardController {
	/*
	public String mode {get;
		set {
			Boolean firstSet = (mode == null);
			mode = value;
			if(firstSet){
				init();
			}
		}
	}
	public String chart {get;
		set {
			Boolean firstSet = (chart == null);
			chart = value;
			if(firstSet){
				init();
			}
		}
	}
	
	public Boolean showDueDate {get;set;}
	public Boolean showGoalName {get;set;}
	public Boolean showGoalType {get;set;}
	public Boolean showGoalFor {get;set;}
	public Boolean showChannel {get;set;}
	public Boolean showRecType {get;set;}
	
	public List<Goal__c> allGoals {get;set;}
	public List<Goal__c> dispGoals {get;set;}
	public Integer resultSize {get;set;}
	public Integer chartHeight {get;set;}
	
	public List<SelectOption> dateSelections {get;set;}
	public List<SelectOption> nameSelections {get;set;}
	public List<SelectOption> typeSelections {get;set;}
	public List<SelectOption> forSelections {get;set;}
	public List<SelectOption> chanSelections {get;set;}
	public List<SelectOption> rtSelections {get;set;}
	
	public Date startDate {get;set;}
	public Date endDate {get;set;}
	public String progStartString {get;set;}
	public String progEndString {get;set;}
	public String dueStartString {get;set;}
	public String dueEndString {get;set;}
	
	public String dateStartSel {get;set;}
	public String dateEndSel {get;set;}
	public String nameSel {get;set;}
	public String typeSel {get;set;}
	public String forSel {get;set;}
	public String forLabel {get;set;}
	public String chanSel {get;set;}
	public String rtSel {get;set;}
	
	public String chartTitle {get;set;}
	public String leftAxisLabel {get;set;}
	
	public List<Data> byStateData {get;set;}
	public List<Data> westData {get;set;}
	public List<Data> eastData {get;set;}
	public List<Data> progData {get;set;}
	public List<Data> goalForData {get;set;}
	public List<Data> dataToUse {get;set;}
	
	public static Set<String> WEST_STATES = new Set<String>{
		'Idaho',
		'Iowa',
		'Michigan',
		'Montana',
		'Ohio',
		'Oregon',
		'Utah',
		'Wyoming'
		};
	public static Set<String> EAST_STATES = new Set<String>{
		'Alabama',
		'Maine',
		'Mississippi',
		'New Hampshire',
		'North Carolina',
		'Pennsylvania',
		'Vermont',
		'Virginia',
		'West Virginia'
		};
	
	public ActionCompleteDashboardController(){
	}
	
	public void init(){
		if(mode != null && chart != null){
			determineVisibility();
			populateDateDropdown();
			dateChanged();
		}
	}
	
	private void determineVisibility(){
		showDueDate = true;
		showGoalName = true;
		showGoalType = true;
		showChannel = true;
		showRecType = true;
		if(mode == 'exec' || mode == 'rep' || chart == 'goalFor'){
			showGoalFor = false;
		} else {
			showGoalFor = true;
			if(mode == 'dir'){
				forLabel = 'Manager Name';
			} else {
				forLabel = 'Rep Name';
			}
		}
	}
	
	private void populateDateDropdown(){
		dateSelections = new List<SelectOption>();
		Date startD = Date.newInstance(2012, 10, 1);
		Date endD = Date.today().toStartOfMonth().addYears(2);
		Date tempStart = startD;
		
		while(tempStart != endD){
			Date tempEnd = tempStart.addMonths(1).addDays(-1);
			String encode = encodeDateSelection(tempStart, tempEnd);
			dateSelections.add(new SelectOption(encode, monthString(tempStart)));
			tempStart = tempStart.addMonths(1);
		}
		
		setInitialValues(encodeDateSelection(Date.today().toStartOfMonth(), Date.today().toStartOfMonth().addMonths(1).addDays(-1)));
	}
	
	private String encodeDateSelection(Date startD, Date endD){
		String startS = DateTime.newInstance(startD.year(),startD.month(),startD.day()).format('yyyy-MM-dd');
		String endS = DateTime.newInstance(endD.year(),endD.month(),endD.day()).format('yyyy-MM-dd');
		return startS + '|' + endS;
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
	
	private void setInitialValues(String dateEncode){
		dateStartSel = dateEncode;
		dateEndSel = dateEncode;
		nameSel = 'all';
		typeSel = 'all';
		forSel = 'all';
		chanSel = 'all';
		rtSel = 'all';
	}
	
	public void dateChanged(){
		progStartString = dateStartSel.substring(0, 10);
		progEndString = dateStartSel.substring(11);
		dueStartString = dateEndSel.substring(0, 10);
		dueEndString = dateEndSel.substring(11);
		
		refreshGoalDropdowns();
	}
	
	private void refreshGoalDropdowns(){
		String q = 'SELECT Id';
		q += ', Program__c';
		q += ', Program__r.Name';
		q += ', Goal_Type__c';
		q += ', Goal_For__c';
		q += ', Goal_For__r.Name';
		q += ', Sales_Channel__c';
		q += ', RecordTypeId';
		q += ', RecordType.Name';
		q += getModeParams();
		
		System.debug('*** ' + q);
		allGoals = Database.query(q);
		
		Map<String, Id> progIdsByName = new Map<String, Id>();
		Set<String> goalTypes = new Set<String>();
		Map<String, Id> forIdsByName = new Map<String, Id>();
		Set<String> chanTypes = new Set<String>();
		Map<String, Id> rtIdsByName = new Map<String, Id>();
		
		Boolean nameNoLongerAvailable = true;
		Boolean typeNoLongerAvailable = true;
		Boolean forNoLongerAvailable = true;
		Boolean chanNoLongerAvailable = true;
		Boolean rtNoLongerAvailable = true;
		for(Goal__c goal : allGoals){
			progIdsByName.put(goal.Program__r.Name, goal.Program__c);
			if(nameSel != 'all' && goal.Program__c == nameSel){
				nameNoLongerAvailable = false;
			}
			
			goalTypes.add(goal.Goal_Type__c);
			if(typeSel != 'all' && goal.Goal_Type__c == typeSel){
				typeNoLongerAvailable = false;
			}
			
			forIdsByName.put(goal.Goal_For__r.Name, goal.Goal_For__c);
			if(forSel != 'all' && goal.Goal_For__c == forSel){
				forNoLongerAvailable = false;
			}
			
			chanTypes.add(goal.Sales_Channel__c);
			if(chanSel != 'all' && goal.Sales_Channel__c == chanSel){
				chanNoLongerAvailable = false;
			}
			
			rtIdsByName.put(goal.RecordType.Name, goal.RecordTypeId);
			if(rtSel != 'all' && goal.RecordTypeId == rtSel){
				rtNoLongerAvailable = false;
			}
		}
		
		nameSelections = new List<SelectOption>();
		nameSelections.add(new SelectOption('all', '--- All ---'));
		
		List<String> sortedKeys = new List<String>(progIdsByName.keySet());
		sortedKeys.sort();
		for(String name : sortedKeys){
			if(progIdsByName.get(name) != null){
				nameSelections.add(new SelectOption(progIdsByName.get(name), name));
			}
		}

		typeSelections = new List<SelectOption>();
		typeSelections.add(new SelectOption('all', '--- All ---'));
		List<String> sortedGoalTypes = new List<String>(goalTypes);
		sortedGoalTypes.sort();
		for(String typee : sortedGoalTypes){
			typeSelections.add(new SelectOption(typee, typee));
		}
		
		forSelections = new List<SelectOption>();
		forSelections.add(new SelectOption('all', '--- All ---'));
		
		sortedKeys = new List<String>(forIdsByName.keySet());
		sortedKeys.sort();
		for(String name : sortedKeys){
			if(forIdsByName.get(name) != null){
				forSelections.add(new SelectOption(forIdsByName.get(name), name));
			}
		}
		
		chanSelections = new List<SelectOption>();
		chanSelections.add(new SelectOption('all', '--- All ---'));
		List<String> sortedChanTypes = new List<String>(chanTypes);
		sortedChanTypes.sort();
		for(String chan : sortedChanTypes){
			chanSelections.add(new SelectOption(chan, chan));
		}
		
		rtSelections = new List<SelectOption>();
		rtSelections.add(new SelectOption('all', '--- All ---'));
		
		sortedKeys = new List<String>(rtIdsByName.keySet());
		sortedKeys.sort();
		for(String name : sortedKeys){
			if(rtIdsByName.get(name) != null){
				rtSelections.add(new SelectOption(rtIdsByName.get(name), name));
			}
		}
		
		//check to see if previous selections are still in the list
		if(nameNoLongerAvailable){
			nameSel = 'all';
		}
		if(typeNoLongerAvailable){
			typeSel = 'all';
		}
		if(forNoLongerAvailable){
			forSel = 'all';
		}
		if(chanNoLongerAvailable){
			chanSel = 'all';
		}
		if(rtNoLongerAvailable){
			rtSel = 'all';
		}
		refreshCharts();
	}
	
	public void nameChanged(){
		refreshCharts();
	}
	
	public void typeChanged(){
		refreshCharts();
	}
	
	public void forChanged(){
		refreshCharts();
	}
	
	public void chanChanged(){
		refreshCharts();
	}
	
	public void rtChanged(){
		refreshCharts();
	}

	public void refreshCharts(){
		byStateData = new List<Data>();
		westData = new List<Data>();
		eastData = new List<Data>();
		progData = new List<Data>();
		goalForData = new List<Data>();
		dataToUse = new List<Data>();
		
		String q = 'SELECT Id';
		q += ', Minimum_of_Accounts__c';
		q += ', State__c';
		q += ', Program__c';
		q += ', Program__r.Name';
		q += ', Action_Complete__c';
		q += ', Goal_For__r.Name';
		q += getModeParams();
		
		if(nameSel != 'all'){
			q += ' AND Program__c = \'' + nameSel + '\'';
		}
		if(typeSel != 'all'){
			q += ' AND Goal_Type__c = \'' + typeSel + '\'';
		}
		if(forSel != 'all'){
			q += ' AND Goal_For__c = \'' + forSel + '\'';
		}
		if(chanSel != 'all'){
			q += ' AND Sales_Channel__c = \'' + chanSel + '\'';
		}
		if(rtSel != 'all'){
			q += ' AND RecordTypeId = \'' + rtSel + '\'';
		}
		
		dispGoals = Database.query(q);
		resultSize = dispGoals.size();
		
		if(dispGoals.size() > 0){
			Map<String, Decimal> minsByStateName = new Map<String, Decimal>();
			Map<String, Decimal> compsByStateName = new Map<String, Decimal>();
			Map<String, Decimal> minsByProgNameWest = new Map<String, Decimal>();
			Map<String, Decimal> compsByProgNameWest = new Map<String, Decimal>();
			Map<String, Decimal> minsByProgNameEast = new Map<String, Decimal>();
			Map<String, Decimal> compsByProgNameEast = new Map<String, Decimal>();
			Map<String, Decimal> minsByProgNameProg = new Map<String, Decimal>();
			Map<String, Decimal> compsByProgNameProg = new Map<String, Decimal>();
			Map<String, Decimal> minsByGoalFor = new Map<String, Decimal>();
			Map<String, Decimal> compsByGoalFor = new Map<String, Decimal>();
			
			for(Goal__c goal : dispGoals){
				String stateString = goal.State__c;
				stateString = stateString.split(', ')[0];
				
				Decimal existingMin = minsByStateName.get(stateString);
				Decimal existingComp = compsByStateName.get(stateString);
				if(existingMin == null){
					existingMin = 0;
					existingComp = 0;
				}
				existingMin += goal.Minimum_of_Accounts__c;
				existingComp += goal.Action_Complete__c;
				minsByStateName.put(stateString, existingMin);
				compsByStateName.put(stateString, existingComp);
				
				if(WEST_STATES.contains(stateString)){
					existingMin = minsByProgNameWest.get(goal.Program__r.Name);
					existingComp = compsByProgNameWest.get(goal.Program__r.Name);
					if(existingMin == null){
						existingMin = 0;
						existingComp = 0;
					}
					existingMin += goal.Minimum_of_Accounts__c;
					existingComp += goal.Action_Complete__c;
					minsByProgNameWest.put(goal.Program__r.Name, existingMin);
					compsByProgNameWest.put(goal.Program__r.Name, existingComp);
					
				} else if(EAST_STATES.contains(stateString)){
					existingMin = minsByProgNameEast.get(goal.Program__r.Name);
					existingComp = compsByProgNameEast.get(goal.Program__r.Name);
					if(existingMin == null){
						existingMin = 0;
						existingComp = 0;
					}
					existingMin += goal.Minimum_of_Accounts__c;
					existingComp += goal.Action_Complete__c;
					minsByProgNameEast.put(goal.Program__r.Name, existingMin);
					compsByProgNameEast.put(goal.Program__r.Name, existingComp);
				}
				
				//PROG, not by state breakout
				existingMin = minsByProgNameProg.get(goal.Program__r.Name);
				existingComp = compsByProgNameProg.get(goal.Program__r.Name);
				if(existingMin == null){
					existingMin = 0;
					existingComp = 0;
				}
				existingMin += goal.Minimum_of_Accounts__c;
				existingComp += goal.Action_Complete__c;
				minsByProgNameProg.put(goal.Program__r.Name, existingMin);
				compsByProgNameProg.put(goal.Program__r.Name, existingComp);
				
				existingMin = minsByGoalFor.get(goal.Goal_For__r.Name);
				existingComp = compsByGoalFor.get(goal.Goal_For__r.Name);
				if(existingMin == null){
					existingMin = 0;
					existingComp = 0;
				}
				existingMin += goal.Minimum_of_Accounts__c;
				existingComp += goal.Action_Complete__c;
				minsByGoalFor.put(goal.Goal_For__r.Name, existingMin);
				compsByGoalFor.put(goal.Goal_For__r.Name, existingComp);
			}
			
			if(chart == 'state'){
				Map<String, Decimal> percsByName = new Map<String, Decimal>();
				Map<Decimal, String> namesByPerc = new Map<Decimal, String>();
				for(String name : minsByStateName.keySet()){
					Decimal min = minsByStateName.get(name);
					Decimal comp = compsByStateName.get(name);
					Decimal perc = 0;
					if(min != 0){
						perc = Math.floor(comp / min * 100);
					}
					percsByName.put(name, perc);
					while(namesByPerc.get(perc) != null){
						perc += 0.0001;
					}
					namesByPerc.put(perc, name);
				}
				List<Decimal> allPercs = new List<Decimal>(namesByPerc.keySet());
				allPercs.sort();
				for(Decimal perc : allPercs){
					String name = namesByPerc.get(perc);
					byStateData.add(new Data(truncateProgName(name), perc, name));
				}
				dataToUse = byStateData;
				chartTitle = 'By State';
				leftAxisLabel = 'State';
			}
			
			if(chart == 'west'){
				Map<String, Decimal> percsByName = new Map<String, Decimal>();
				Map<Decimal, String> namesByPerc = new Map<Decimal, String>();
				for(String name : minsByProgNameWest.keySet()){
					Decimal min = minsByProgNameWest.get(name);
					Decimal comp = compsByProgNameWest.get(name);
					Decimal perc = 0;
					if(min != 0){
						perc = Math.floor(comp / min * 100);
					}
					percsByName.put(name, perc);
					while(namesByPerc.get(perc) != null){
						perc += 0.0001;
					}
					namesByPerc.put(perc, name);
				}
				List<Decimal> allPercs = new List<Decimal>(namesByPerc.keySet());
				allPercs.sort();
				for(Decimal perc : allPercs){
					String name = namesByPerc.get(perc);
					westData.add(new Data(truncateProgName(name), perc, name));
				}
				dataToUse = westData;
				chartTitle = 'By Program';
				leftAxisLabel = 'Program';
			}
			
			if(chart == 'east'){
				Map<String, Decimal> percsByName = new Map<String, Decimal>();
				Map<Decimal, String> namesByPerc = new Map<Decimal, String>();
				for(String name : minsByProgNameEast.keySet()){
					Decimal min = minsByProgNameEast.get(name);
					Decimal comp = compsByProgNameEast.get(name);
					Decimal perc = 0;
					if(min != 0){
						perc = Math.floor(comp / min * 100);
					}
					percsByName.put(name, perc);
					while(namesByPerc.get(perc) != null){
						perc += 0.0001;
					}
					namesByPerc.put(perc, name);
				}
				List<Decimal> allPercs = new List<Decimal>(namesByPerc.keySet());
				allPercs.sort();
				for(Decimal perc : allPercs){
					String name = namesByPerc.get(perc);
					eastData.add(new Data(truncateProgName(name), perc, name));
				}
				dataToUse = eastData;
				chartTitle = 'By Program';
				leftAxisLabel = 'Program';
			}
			
			if(chart == 'prog'){
				Map<String, Decimal> percsByName = new Map<String, Decimal>();
				Map<Decimal, String> namesByPerc = new Map<Decimal, String>();
				for(String name : minsByProgNameProg.keySet()){
					Decimal min = minsByProgNameProg.get(name);
					Decimal comp = compsByProgNameProg.get(name);
					Decimal perc = 0;
					if(min != 0){
						perc = Math.floor(comp / min * 100);
					}
					percsByName.put(name, perc);
					while(namesByPerc.get(perc) != null){
						perc += 0.0001;
					}
					namesByPerc.put(perc, name);
				}
				List<Decimal> allPercs = new List<Decimal>(namesByPerc.keySet());
				allPercs.sort();
				for(Decimal perc : allPercs){
					String name = namesByPerc.get(perc);
					progData.add(new Data(truncateProgName(name), perc, name));
				}
				dataToUse = progData;
				chartTitle = 'All Programs';
				leftAxisLabel = 'Program';
			}
			
			if(chart == 'goalFor'){
				Map<String, Decimal> percsByName = new Map<String, Decimal>();
				Map<Decimal, String> namesByPerc = new Map<Decimal, String>();
				for(String name : minsByGoalFor.keySet()){
					Decimal min = minsByGoalFor.get(name);
					Decimal comp = compsByGoalFor.get(name);
					Decimal perc = 0;
					if(min != 0){
						perc = Math.floor(comp / min * 100);
					}
					percsByName.put(name, perc);
					while(namesByPerc.get(perc) != null){
						perc += 0.0001;
					}
					namesByPerc.put(perc, name);
				}
				List<Decimal> allPercs = new List<Decimal>(namesByPerc.keySet());
				allPercs.sort();
				for(Decimal perc : allPercs){
					String name = namesByPerc.get(perc);
					goalForData.add(new Data(truncateProgName(name), perc, name));
				}
				dataToUse = goalForData;
				chartTitle = '% Complete by User';
				leftAxisLabel = 'User';
			}
		}
		
		if(dataToUse != null){
			chartHeight = dataToUse.size() * 12 + 120;
		}
	}
	
	public String truncateProgName(String progName){
		if(progName.length() > 18){
			return progName.substring(0, 18);
		}
		return progName;
	}
	
	public String getModeParams(){
		String q = '';
		
		q += ' FROM Goal__c';
		q += ' WHERE Program_Start_Date__c >= ' + progStartString + ' AND Program_End_Date__c <= ' + progEndString;
		q += ' AND Due_Date__c >= ' + dueStartString + ' AND Due_Date__c <= ' + dueEndString;
		
		q+= ' AND Sales_Channel__c != \'Local\'';
		q+= ' AND Goal_Type__c LIKE \'% - Control\'';
		q+= ' AND Minimum_of_Accounts__c != 0';
		q+= ' AND Minimum_of_Accounts__c != null';
		q+= ' AND Action_Complete__c != null';
		q+= ' AND Program__c != null';
		q+= ' AND State__c != null';
		if(mode == 'exec'){
			q+= ' AND Goal_Level__c = \'Director\'';
		} else if(mode == 'dir'){
			q+= ' AND Goal_Level__c = \'Manager\'';
		} else if(mode == 'mgr'){
			q+= ' AND Goal_Level__c = \'Rep\'';
		} else if(mode == 'rep'){
			q+= ' AND Goal_Level__c = \'Rep\'';
		}
		return q;
	}
	
	public class Data {
		String name {get;set;}
		Decimal dispValue {get;set;}
		Decimal actualValue {get;set;}
		String fullName {get;set;}
		String tipValue {get;set;}
		
		public Data(String name, Decimal actualValue, String fullName){
			this.name = name;
			this.actualValue = actualValue;
			this.dispValue = actualValue;
			if(this.dispValue > 100){
				this.dispValue = 100;
			}
			this.fullName = fullName;
			this.tipValue = String.valueOf(Math.floor(actualValue)) + '%';
		}
	}
	*/
}