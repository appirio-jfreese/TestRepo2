/********************************************************************************************************************
Name        : APPIRIO_OccasionsAssetLinkingController
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 19th Nov, 2012
Purpose     : Controller of APPIRIO_OccasionsAssetLinking.page
Ref         : T-96368
              Create a Visualforce page per the specs in the attached file.
              This page allows the user to search for Occasion__c objects, and then link them to an asset via 
              the Published_Occasion__c junction object. 
              It contains all the search functionality and we should be able to add onto it to perform the junction object save operations.
********************************************************************************************************************/
public with sharing class APPIRIO_OccasionsAssetLinkingController {
	public Id selectedAssetId{get;set;}
	private List<String> occasionIds;
    public String selectedAssetName{get;set;}
    public Id selectedOccasionId{get;set;}
    Map<string,id> attributeMap = new Map<string,id>();
    
    /***************************/
    public Map<Id,User> authorMap {get;set;}
    //public String rQuery { get; set; }
    public String whereClause {get; set;}
    public String constructorWhere {get; set;}
    public List<Id> exportList {get;set;}
    public list<Attribute__c> attrTypes = new list<Attribute__c>();
    public boolean filtered{get;set;}
    public String searchTerm {get; set;}
    public string isNavigatingFromDetail{get;set;}
    public boolean isDetail{get;set;}
    public Set<String> occasionFilter {get; set; }
    public Set<String> searchFilter {get; set;}
    public string styleName{get;set;}
    
    public string sortType {get;set;}
    public string sortTypeTop{get;set;}
    
    public list<string> typeOptions = new list<string>();
    private string NONE_STRING = ' - None - ';
    public integer PAGE_SIZE = 9;
    
    /*Type Filter*/
    public integer typeCount{get;set;}
    public Set<String> typeFilter {get; set;}
    public Set<String> typeFilterValues {get; set;}
    public integer typeCounter { get{
		return genericCounter(typeFilter);
	}
	set;
	}
    public String typeLast {
    	get	{
			return commaSet(typeFilter);
		}
		set;
	}
	/*********/
	
	/*Month Filter*/
    public integer monthCount{get;set;}
    public Set<String> monthFilter {get; set;}
    public Set<String> monthFilterValues {get; set;}
    public integer monthCounter { get{
		return genericCounter(monthFilter);
	}
	set;
	}
    public String monthLast {
    	get	{
			return commaSet(monthFilter);
		}
		set;
	}
	/*********/
	
	/*Day Filter*/
    public integer dayCount{get;set;}
    public Set<String> dayFilter {get; set;}
    public Set<String> dayFilterValues {get; set;}
    public integer dayCounter { get{
		return genericCounter(dayFilter);
	}
	set;
	}
    public String dayLast {
    	get	{
			return commaSet(dayFilter);
		}
		set;
	}
	/*********/
	
	/*Locale Filter*/
    public integer localeCount{get;set;}
    public Set<String> localeFilter {get; set;}
    public Set<String> localeFilterValues {get; set;}
    public integer localeCounter { get{
		return genericCounter(localeFilter);
	}
	set;
	}
    public String localeLast {
    	get	{
			return commaSet(localeFilter);
		}
		set;
	}
	/*********/
		
    public String commaSet(Set<String> l)
    {
        List<String> temp = new List<String>();
        String t;
        for(String s:l){
            temp.add(s);
        }
        temp.sort(); 
        
        for(Integer i=0;i<temp.size();i++)
        { 
            if(i==0)
            t=temp[i];
            else
            t=t+temp[i];
            if(i<temp.size()-1)
              t+=',';
        }
        return t;
    }
    
    public integer genericCounter(set<string> cs){
        return(cs.size());
    } 
    
    Set<Id> publishedOccasionIds;
    Set<Id> suppressedOccasionIds;
    
    public APPIRIO_OccasionsAssetLinkingController(){
        selectedAssetId = Apexpages.currentPage().getParameters().get('aId');
        selectedAssetName = Apexpages.currentPage().getParameters().get('aName');
        
        typeFilter = new Set<String>();
        monthFilter = new Set<String>();
        dayFilter = new Set<String>();
        localeFilter = new Set<String>();
        
        isDetail = true;
        String key;
        authorMap = new Map<Id,User>([SELECT Id, Name From User]);
        
        //TO hold the Search Criteria that is applied.Used when Navigating back to the Search page from other page
        isNavigatingFromDetail = ApexPages.currentPage().getParameters().get('isNavigatingFromDetail');
        sortType = Apexpages.currentPage().getParameters().get('sortType'); 
        
        isNavigatingFromDetail = 'false';   
        
        if(sortType == null) {
            sortTypeTop  = 'DFT';
            sortType = 'DFT';
        }
        filterResults();
    }   
    
    //The main Search method that appends the applied filter criteria and performs the Search.
    public PageReference filterResults() {
        filtered = true;
		occasionIds = new List<String>();
		List<Occasion__c> tempOccasions = new List<Occasion__c>();
		for(Occasion__c occasion :setWrapperOccasions(Database.query(createQuery(true,null)))) {
			occasionIds.add(occasion.Id);
			tempOccasions.add(occasion);
		}
		con = new ApexPages.StandardSetController(tempOccasions);
		con.setPageSize(PAGE_SIZE);		
		whereClause = null;
		return null;
    }
    
    private String createQuery(Boolean countOccasion, Set<String> occIds) {
    	if(sortTypeTop != null) {
			sortType = sortTypeTop;
		} else {
			sortType = 'DFT';
		}	
    	
    	String rQuery;
    	if(countOccasion) {
    		rQuery =  'SELECT Id, '; 
			rQuery += '(Select Digital_Published_Asset__c, Occasion__c, Status__c From Published_Occasions__r) ';
			rQuery += 'FROM Occasion__c';	
    	} else {
    		rQuery =  'SELECT Start_Month__c, Start_Date__c, Recipe_Occasion_Image__r.Content_id__c, Recipe_Occasion_Image__c, Occasion_Type__c, '; 
			rQuery += 'Name_Of_The_Occasion__c, Locale__c, Id, (Select Digital_Published_Asset__c, Occasion__c, Status__c From Published_Occasions__r) ';
			rQuery += 'FROM Occasion__c';	
    	}
    		
    	whereClause = ' Where Name_Of_The_Occasion__c <> null ';
    	
    	if(!countOccasion) {
			if(occIds.isEmpty()) {
				whereClause += ' And (Id IN (\'\')';
				whereClause += ')';
			} else {
				whereClause += ' And (Id IN ';
				whereClause += parseListForQuery(occIds)+')';
			}
		} else {
			//Search if the search box has been populated, filter if not
			if (searchTerm == null || searchTerm.length() == 0 ){
					searchFunctionality();
			} else {
	        	if(isNavigatingFromdetail!='true')
			    searchTerm = String.escapeSingleQuotes(searchTerm);
			    searchTerm = searchTerm.replace('*','\\*');
		        string st = '%'+searchTerm+'%';
		        
		        Set<String> occasionIds = new Set<String>();
			    for(Occasion__c o :[select Id from Occasion__c where Name  like :st 
			    											   or Name_Of_The_Occasion__c like :st 
			    											   or Occasion_Type__c like :st 
			    											   or Occasion_Tag__c like :st 
			    											   or Occasion_External_Id__c like :st]) {
			   		occasionIds.add(o.Id);
			   	}
				if(occasionIds.isEmpty()) {
					whereClause += ' And (Id IN (\'\')';
					whereClause += ')';
				}
				else{
					whereClause += ' And (Id IN ';
					whereClause += parseListForQuery(occasionIds)+')';
				}
				
				if ( (typeFilter != null && typeFilter.size() > 0) || (monthFilter != null && monthFilter.size() > 0) || (dayFilter != null && dayFilter.size() > 0) || (localeFilter != null && localeFilter.size() > 0) ){				
					searchFunctionality();
				}
	        }
    	}
    	
    	if (whereClause != null)
			rQuery = rQuery + whereClause;
		
		//Add order by
		if(sortType != null && sortType.equals('DESC')) {
			rQuery += ' Order By Name_Of_The_Occasion__c DESC';	
		} else {
			rQuery += ' Order By Name_Of_The_Occasion__c ASC';
		}
		return rQuery;
    }
    
    //Method that is being called when Filters are being Selected/Applied.
    public void searchFunctionality(){
			
		if (typeFilter != null && typeFilter.size() > 0){
			if (whereClause == null)
				whereClause = ' WHERE ';
			else
				whereClause += ' AND ';
			
			whereClause += 'Occasion_Type__c  In ';	
			whereClause += parseListForQuery(typeFilter);	
		}
		
		if (monthFilter != null && monthFilter.size() > 0){
			if (whereClause == null)
				whereClause = ' WHERE ';
			else
				whereClause += ' AND ';
			
			whereClause += 'Start_Month__c  In ';	
			whereClause += parseListForQuery(monthFilter);	
		}
		
		if (dayFilter != null && dayFilter.size() > 0){
			if (whereClause == null)
				whereClause = ' WHERE ';
			else
				whereClause += ' AND ';
			
			whereClause += 'Day_Of_The_Week__c  In ';	
			whereClause += parseListForQuery(dayFilter);	
		}
		
		if (localeFilter != null && localeFilter.size() > 0) {
			if (whereClause == null)
				whereClause = ' WHERE ';
			else
				whereClause += ' AND ';
			
			whereClause += 'locale__c  In ';	
			whereClause += parseListForQuery(localeFilter);	
		}	
    }
    
    //Takes the set of selected Values for each attribute and formats them to comply with SOQL standards
	public String parseListForQuery(Set<String> s) {
		String returnString;	
		Integer listSize = s.size();
		Integer counter = 0;	
		returnString = '(';

		for (String element : s) {
			if (element == null) {
				counter++;
				continue;	
			}	
			if ((counter + 1) < listSize)
				returnString += '\'' + element + '\',';
			else
				returnString += '\'' + element + '\'';
				
			counter++;
		}			
		returnString += ')';			
		return returnString;	
	}
	
	//Getting all the Type values User selected from the UI and adds them to a set.
	public String currentType {
		get;
		set {
			typeCount = 0;
			if (value != null){
				this.currentType = value;
				value = value.replace('[','').replace(']','');
				value = value.trim();
			}

	    	if (typeFilter == null)
	        	typeFilter = new Set<String>();
		    	
	    	//If it has commas then it's multi valued
	    	if (value == null || typeFilter.Contains(value)) {
	    		typeFilter.remove(value);
	    		if( value != null) {
	    			typeCount++;
	    			filterResults();
	    		}			
	    	} else if(value != null && value!='') {
	    		if(isNavigatingFromDetail == 'true') {
					splitString(currenttype,typeFilter,null,'false');
	    		} else {	
		    		typeFilter.add(value);
		    		typeCount++;	
	    		}
	    			
	    		filterResults();
	    	}
		}	
	}
	
	//Getting all the Month values User selected from the UI and adds them to a set.
	public String currentMonth {
		get;
		set {
			monthCount = 0;
			if (value != null) {
				this.currentmonth = value;
				value = value.replace('[','').replace(']','');
				value = value.trim();
			}

	    	if (monthFilter == null)
	        	monthFilter = new Set<String>();
		    	
	    	//If it has commas then it's multi valued
	    	if (value == null || monthFilter.Contains(value)) {
	    		monthFilter.remove(value);
	    		if( value != null){
	    			monthCount++;
	    			filterResults();
	    		}			
	    	} else if(value != null && value!='') {
	    		if(isNavigatingFromDetail == 'true'){
					splitString(currentmonth,monthFilter,null,'false');
	    		} else {	
		    		monthFilter.add(value);
		    		monthCount++;	
	    		}
	    			
	    		filterResults();
	    	}
		    	
		}	
	}
	
	//Getting all the Day values User selected from the UI and adds them to a set.
	public String currentDay {
		get;
		set {
			dayCount = 0;
			if (value != null) {
				this.currentday = value;
				value = value.replace('[','').replace(']','');
				value = value.trim();
			}

	    	if (dayFilter == null)
	        	dayFilter = new Set<String>();
		    	
	    	//If it has commas then it's multi valued
	    	if (value == null || dayFilter.Contains(value)) {
	    		dayFilter.remove(value);
	    		if( value != null){
	    			dayCount++;
	    			filterResults();
	    		}			
	    	} else if(value != null && value!='') {
	    		if(isNavigatingFromDetail == 'true') {
					splitString(currentday,dayFilter,null,'false');
	    		} else {	
		    		dayFilter.add(value);
		    		dayCount++;	
	    		}
	    			
	    		filterResults();
	    	}
		    	
		}	
	}
    
    //Getting all the Locale values User selected from the UI and adds them to a set.
	public String currentLocale {
		get;
		set {
			localeCount = 0;
			if (value != null){
				this.currentlocale = value;
				value = value.replace('[','').replace(']','');
				value = value.trim();
			}

	    	if (localeFilter == null)
	        	localeFilter = new Set<String>();
		    	
	    	//If it has commas then it's multi valued
	    	if (value == null || localeFilter.Contains(value)) {
	    		localeFilter.remove(value);
	    		if( value != null){
	    			localeCount++;
	    			filterResults();
	    		}			
	    	} else if(value != null && value!='') {
	    		if(isNavigatingFromDetail == 'true') {
					splitString(currentlocale,localeFilter,null,'false');
	    		} else {	
		    		localeFilter.add(value);
		    		localeCount++;	
	    		}
	    			
	    		filterResults();
	    	}
		}	
	}
    
    //Method that takes the current Filter Criteria that is returned from Recipe View Page and Formats them into a set 
	public void splitString(string attrString,set<string> strSet,set<string> valuesSet,string flag) {
		strSet.clear();
		if(valuesSet != null)
			valuesSet.clear();
			
		attrString = attrString.replace('[','').replace(']','');
		if(attrString != null && attrString.trim()!= '') {		
			string[] strarr = attrString.split(',');
			for(string s : strarr) {	
				s = s.trim();
				if(flag == 'true' || flag == 'ASCII'){
					if(!strSet.contains(attributeMap.get(s)))	
						strSet.add(attributeMap.get(s));
					if(flag == 'true')
						valuesSet.add(EncodingUtil.URLENCODE(s,'UTF-8'));
					else if(flag == 'ASCII')
						valuesSet.add(s);
				} else {
					if(!strSet.contains(s)){
						strSet.add(s);
					}
				}
			}
		}
	}
    
    //Clears all the Selected or applied Filter Criteria.
    public PageReference clearFilters() {
        system.debug('===================clearFilters=============');
        
        currentType = null;
        if (typeFilter != null)
    		typeFilter.clear();
    	
    	currentMonth = null;
        if (monthFilter != null)
    		monthFilter.clear();
    		
    	currentDay = null;
        if (dayFilter != null)
    		dayFilter.clear();
    		
        currentLocale = null;
        if (localeFilter != null)
    		localeFilter.clear();
        
        if(searchTerm != null)
    		searchTerm = '';
        if (isNavigatingFromDetail == 'true')
            isNavigatingFromDetail = '';
        
        return filterResults();
    }
    
    public PageReference refreshPanel() {
        return null;
    }
    
   	public List<String> getTypes() {
        return getPickValues2(new Occasion__c(), 'Occasion_Type__c');
    }
    
    public List<String> getMonths() {
        return getPickValues2(new Occasion__c(), 'Start_Month__c');
    }
    
    public List<String> getDays() {
        return getPickValues2(new Occasion__c(), 'Day_Of_The_Week__c');
    }
    
    public List<String> getLocales() {
        return getPickValues2(new Occasion__c(), 'Locale__c');
    }
    
    public List<String> getPickValues2(Sobject object_name, String field_name) {
    
        List<String> options = new List<String>(); //new list for holding all of the picklist options
      
        
        Schema.sObjectType sobject_type = object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            options.add((String)a.getLabel()); //add the value and label to our final list
        }
        
        return options; //return the List
   }    

   
   public list<SelectOption> getSortOrderTypes() {
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('DFT','Default'));
        options.add(new SelectOption('ASC','Alphabetically(A-Z)'));
        options.add(new selectOption('DESC','Alphabetically(Z-A)'));
        options.add(new SelectOption('AVL','Available First'));
        return options;
   }
   
   
   /* Paging Section */
   
    public list<OccasionWrapper> occasions {get;set;}
 
    // instantiate the StandardSetController from a query locator
	public ApexPages.StandardSetController con {
		get {
			if(con == null) {
				con = new ApexPages.StandardSetController(setWrapperOccasions(Database.query(createQuery(true,null))));
				//sets the number of records in each page set
				con.setPageSize(PAGE_SIZE);
			}
			return con;
		}
		set;
	}
    
    //returns a list of arranged recipes in the current page set
	public List<Occasion__c> setWrapperOccasions(List<Occasion__c> sOccasions) {
		
		List<Occasion__c> tempOccasions = new List<Occasion__c>();
		publishedOccasionIds = new Set<Id>();
		suppressedOccasionIds = new Set<Id>();
      	
      	List<Occasion__c> lstOccasions = new List<Occasion__c>();
      	
		Map<String,List<Occasion__c>> mapPublishedStatusOccasions = new Map<String,List<Occasion__c>>();
		for(Occasion__c Occasion : sOccasions) {
      		if(occasion.Published_Occasions__r.size() > 0 && occasion.Published_Occasions__r[0].Status__c != null) {
				if(occasion.Published_Occasions__r[0].Status__c.equals('Published')) {
					publishedOccasionIds.add(occasion.Id);
				} else {
					suppressedOccasionIds.add(occasion.Id);
				}
				
				if(!mapPublishedStatusOccasions.containsKey(occasion.Published_Occasions__r[0].Status__c)) {
	      			mapPublishedStatusOccasions.put(occasion.Published_Occasions__r[0].Status__c, new List<Occasion__c>());
	      		}
	      		mapPublishedStatusOccasions.get(occasion.Published_Occasions__r[0].Status__c).add(occasion);
      		} else {
      			if(!mapPublishedStatusOccasions.containsKey('Available')) {
	      			mapPublishedStatusOccasions.put('Available', new List<Occasion__c>());
	      		}
	      		mapPublishedStatusOccasions.get('Available').add(occasion);
      		}
      		lstOccasions.add(occasion);
      	}
      	if(sortType.equals('ASC') || sortType.equals('DESC')) {
      		for(Occasion__c occasion :lstOccasions) {
	      		tempOccasions.add(occasion);
      		}
      	} 
      	
      	if(sortType.equals('DFT') || sortType.equals('AVL')) {
      		for(Occasion__c occasion :sortRecords(mapPublishedStatusOccasions)) {
      			tempOccasions.add(occasion);
      		}
      	}
      	return tempOccasions;
   	}
   	/*
    public List<Occasion__c> setWrapperOccasions(List<Occasion__c> sOccasions) {
		system.debug('===================setWrapperOccasions=============');
		
		system.debug('===================sOccasions=============: '+sOccasions.size());
		
		List<Occasion__c> tempOccasions = new List<Occasion__c>();
		
		publishedOccasionIds = new Set<Id>();
        suppressedOccasionIds = new Set<Id>();
        
        List<OccasionWrapper> tempOccasionWrapper = new List<OccasionWrapper>();
        
        Map<String,List<OccasionWrapper>> mapPublishedStatusOccasions = new Map<String,List<OccasionWrapper>>();
        for(Occasion__c occasion : sOccasions) {
            OccasionWrapper newOccasionWrapper;
            if(mapPublishedOccasionIdStatus.containsKey(occasion.Id)) {
                newOccasionWrapper = new OccasionWrapper(occasion,mapPublishedOccasionIdStatus.get(occasion.Id));  
                if(newOccasionWrapper.publishStatus.equals('Published')) {
                    publishedOccasionIds.add(occasion.Id);
                } else {
                    suppressedOccasionIds.add(occasion.Id);
                }
            } else {
                newOccasionWrapper = new OccasionWrapper(occasion,'Available');
            }
            
            if(!mapPublishedStatusOccasions.containsKey(newOccasionWrapper.publishStatus)) {
                mapPublishedStatusOccasions.put(newOccasionWrapper.publishStatus, new List<OccasionWrapper>());
            }
            mapPublishedStatusOccasions.get(newOccasionWrapper.publishStatus).add(newOccasionWrapper);
            tempOccasionWrapper.add(newOccasionWrapper);
        }
        
        if(sortType.equals('ASC') || sortType.equals('DESC') ) {
        	system.debug('===================ASC/DESC=============: '+sOccasions.size());
            for(OccasionWrapper ow :tempOccasionWrapper) {
                tempOccasions.add(ow.occ);
            }
        } 
        if(sortType.equals('DFT') || sortType.equals('AVL')) {
        	system.debug('===================DFT/AVL=============: '+sOccasions.size());
            for(OccasionWrapper ow :sortRecords(mapPublishedStatusOccasions)) {
      			tempOccasions.add(ow.occ);
      		}
        }
		
      	return tempOccasions;
   	}
    */
    
    // returns a list of wrapper objects for the sObjects in the current page set
    public List<OccasionWrapper> getWrapperOccasions() {
		Integer counter = ((pageNumber-1)*PAGE_SIZE);
		Set<String> ids = new Set<String>();
      	for(Integer cnt=0; cnt<PAGE_SIZE; cnt++) {
      		if(occasionIds.size() > counter+cnt)
      			ids.add(occasionIds[counter+cnt]);
      	}
      	
      	occasions = new List<OccasionWrapper>();
      	for(Occasion__c occasion : setWrapperOccasions(Database.query(createQuery(false,ids)))) {
      		if(occasion.Published_Occasions__r.size() > 0 && occasion.Published_Occasions__r[0].Status__c != null) 
      			occasions.add(new OccasionWrapper(occasion,occasion.Published_Occasions__r[0].Status__c));
      		else
      			occasions.add(new OccasionWrapper(occasion,'Available'));
      	}
		whereClause = null;
		return occasions;
   	}
   	/*
    // returns a list of wrapper objects for the sObjects in the current page set
    public List<OccasionWrapper> getWrapperOccasions() {
        system.debug('===================getWrapperoccasions=============');
        
        occasions = new List<OccasionWrapper>();
        publishedOccasionIds = new Set<Id>();
        suppressedOccasionIds = new Set<Id>();
        List<Occasion__c> tempList = (List<Occasion__c>)con.getRecords();
        List<OccasionWrapper> tempOccasionWrapper = new List<OccasionWrapper>();
        
        Map<String,List<OccasionWrapper>> mapPublishedStatusOccasions = new Map<String,List<OccasionWrapper>>();
        for(Occasion__c occasion : tempList) {
            OccasionWrapper newOccasionWrapper;
            if(mapPublishedOccasionIdStatus.containsKey(occasion.Id)) {
                newOccasionWrapper = new OccasionWrapper(occasion,mapPublishedOccasionIdStatus.get(occasion.Id));  
                if(newOccasionWrapper.publishStatus.equals('Published')) {
                    publishedOccasionIds.add(occasion.Id);
                } else {
                    suppressedOccasionIds.add(occasion.Id);
                }
            } else {
                newOccasionWrapper = new OccasionWrapper(occasion,'Available');
            }
            if(!mapPublishedStatusOccasions.containsKey(newOccasionWrapper.publishStatus)) {
                mapPublishedStatusOccasions.put(newOccasionWrapper.publishStatus, new List<OccasionWrapper>());
            }
            mapPublishedStatusOccasions.get(newOccasionWrapper.publishStatus).add(newOccasionWrapper);
            tempOccasionWrapper.add(newOccasionWrapper);
        }
        
        if(sortType.equals('ASC') || sortType.equals('DESC') ) {
            for(OccasionWrapper ow :tempOccasionWrapper) {
                occasions.add(ow);
            }
        } 
        if(sortType.equals('DFT') || sortType.equals('AVL')) {
            sortRecords(mapPublishedStatusOccasions);
        }
        
        return occasions;
    }*/
    
    private List<Occasion__c> sortRecords(Map<String,List<Occasion__c>> mapPublishedStatusOccasions) {
        List<Occasion__c> tempOccasions = new List<Occasion__c>();
        if(sortType.equals('DFT')) {
            if(mapPublishedStatusOccasions.get('Published') != null) {
                for(Occasion__c ow :mapPublishedStatusOccasions.get('Published')) {
                    tempOccasions.add(ow);
                } 
            }
            if(mapPublishedStatusOccasions.get('Suppressed') != null) {
                for(Occasion__c ow :mapPublishedStatusOccasions.get('Suppressed')) {
                    tempOccasions.add(ow);
                } 
            }
            if(mapPublishedStatusOccasions.get('Available') != null) {
                for(Occasion__c ow :mapPublishedStatusOccasions.get('Available')) {
                    tempOccasions.add(ow);
                } 
            }
        }
        if(sortType.equals('AVL')) {
            if(mapPublishedStatusOccasions.get('Available') != null) {
                for(Occasion__c ow :mapPublishedStatusOccasions.get('Available')) {
                    tempOccasions.add(ow);
                } 
            }
            if(mapPublishedStatusOccasions.get('Suppressed') != null) {
                for(Occasion__c ow :mapPublishedStatusOccasions.get('Suppressed')) {
                    tempOccasions.add(ow);
                } 
            }
            if(mapPublishedStatusOccasions.get('Published') != null) {
                for(Occasion__c ow :mapPublishedStatusOccasions.get('Published')) {
                    tempOccasions.add(ow);
                } 
            }
        }
        return tempOccasions;
    }
    
    public PageReference publishAll() {
        selectedOccasionId = null;
        for(OccasionWrapper ow: occasions) {
            ow.checked = true;
        }
        return savePublishOccasions();
    }
    
    public PageReference suppressedAll() {
        selectedOccasionId = null;
        for(OccasionWrapper ow: occasions) {
            if(ow.checked)
                ow.checked = false;
        }
        return savePublishOccasions();
    }
    
    public PageReference publishOccasion() {
        system.debug('===================selectedOccasionId: '+selectedOccasionId);
        return savePublishOccasions();
    }
    
    public PageReference savePublishOccasions() {
        List<Published_Occasion__c> lstInsertedPublishedOccasion = new List<Published_Occasion__c>();
        List<Published_Occasion__c> lstUpdatedPublishedOccasion = new List<Published_Occasion__c>(); 
        for(OccasionWrapper ow: occasions) {
            if(selectedOccasionId != null && selectedOccasionId == ow.occ.Id) {
                ow.checked = !ow.checked;
            }
            if(ow.checked && !publishedOccasionIds.contains(ow.occ.Id) && !suppressedOccasionIds.contains(ow.occ.Id)) {
                lstInsertedPublishedOccasion.add(
                            new Published_Occasion__c(
                                Status__c = 'Published',
                                Occasion__c = ow.occ.Id,
                                Digital_Published_Asset__c = selectedAssetId));
            } else if(ow.checked && suppressedOccasionIds.contains(ow.occ.Id)) {
                lstUpdatedPublishedOccasion.add(
                            new Published_Occasion__c(
                                Id = ow.occ.Published_Occasions__r[0].Id,
                                Status__c = 'Published',
                                Occasion__c = ow.occ.Id,
                                Digital_Published_Asset__c = selectedAssetId));
            }  else if(!ow.checked && publishedOccasionIds.contains(ow.occ.Id)) {
                lstUpdatedPublishedOccasion.add(
                            new Published_Occasion__c(
                                Id = ow.occ.Published_Occasions__r[0].Id,
                                Status__c = 'Suppressed',
                                Occasion__c = ow.occ.Id,
                                Digital_Published_Asset__c = selectedAssetId));
            } 
        }
        
        if(lstInsertedPublishedOccasion.size() > 0)
            insert lstInsertedPublishedOccasion;
        
        if(lstUpdatedPublishedOccasion.size() > 0)
            update lstUpdatedPublishedOccasion;
        
        return filterResults();
    }
    
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }
    
    public Integer totalRecords {
        get {
            return con.getResultSize();
        }
        set;
    }
    
    public Integer currentStartRecord {
        get {
            return (pageNumber*PAGE_SIZE)-8;
        }
        set;
    }
    
    public Integer currentEndRecord {
        get {
            if (hasNext)
                return currentStartRecord+(PAGE_SIZE-1);
            else{
                Integer tmp = Math.mod(totalRecords,PAGE_SIZE);
                if (tmp == 0)
                    return (PAGE_SIZE-1)+currentStartRecord;
                else
                    return (tmp-1)+currentStartRecord;
                    
            }
        }
        set;
    }   
   
    //Returns the Page Numbers to display on to the screen.
    public list<pageNumberWrapper> pageNumbers {
        get {
            Integer lastRow = Integer.valueOf(Math.ceil(totalRecords/PAGE_SIZE));
            if( Math.mod(totalRecords,PAGE_SIZE)!= 0)
                lastRow+=1;
            
            List<pageNumberWrapper> pNo = new List<pageNumberWrapper>();
            Integer j=1;
            for(Integer i=pageNumber;i<=lastRow && j<6;i++) {
                pNo.add(new pageNumberWrapper(i,j,con,pageNumber));
                j++;
            }
            return pNo;
        }
        set;
   }
   
    public class pageNumberWrapper {
        public Integer num{get;set;}
        public Integer cnt{get;set;}
        public String col{get; set;}
        ApexPages.StandardSetController con;
        public pageNumberWrapper(Integer n,Integer c,ApexPages.StandardSetController con, Integer pno)
        {
            this.num=n;
            this.cnt=c;
            this.con=con;
            if(this.num == pno)
            this.col='red';
            else
            this.col='black';
        }
    
        public void pageItems() {
            Integer n = Integer.valueOf(Apexpages.currentPage().getParameters().get('cnt')); 
            for(Integer i=1;i<n;i++)
            this.con.next();
        }
 
    }
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }
 
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }
 
    // returns the first page of records
    public void first() {
        con.first();
    }
 
    // returns the last page of records
    public void last() {
        con.last();
    }
 
    // returns the previous page of records
    public void previous() {
        con.previous();
    }
 
    // returns the next page of records
    public void next() {
        con.next();
        
    }
 
    // returns the PageReference of the original page, if known, or the home page.
    public void cancel() {
        con.cancel();
    }
    
    //returns the current logged in Browser name to associate respective CSS.
    public String getUserAgent() { 
        return ApexPages.currentPage().getHeaders().get('User-Agent');
    }
}