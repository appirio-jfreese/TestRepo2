/********************************************************************************************************************
Name        : APPIRIO_RecipeAssetLinkingController
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 19th Nov, 2012
Purpose     : Controller of APPIRIO_RecipeAssetLinking.page
Ref         : T-96368
			  Create a Visualforce page per the specs in the attached file.
			  This page allows the user to search for Recipe__c objects, and then link them to an asset via 
			  the Published_Recipe__c junction object. 
			  It contains all the search functionality and we should be able to add onto it to perform the junction object save operations.
********************************************************************************************************************/
public with sharing class APPIRIO_RecipeAssetLinkingController extends MM_RecipeBase {
	
	/*variable declaration*/
	public integer PAGE_SIZE = 9; //sets the page size or number of rows
   	private List<String> recipeIds;
	public Id selectedAssetId{get;set;}
	public String selectedAssetName{get;set;}
	public Id selectedRecipeId{get;set;}
	
	public Map<Id,User> authorMap {get;set;}
	//private List<Diageo_Brand__c> recipeBrands {get; set; }
	private Map<String,String> buttonColorMap {get; set;}
	//private String rQuery { get; set; }
	private String whereClause {get; set;}
	private String constructorWhere {get; set;}
	private List<Id> exportList {get;set;}
	private boolean filtered{get;set;}
	public String searchTerm {get; set;}
	public string isNavigatingFromDetail{get;set;}
	public boolean isDetail{get;set;}
	public Set<String> brandFilter {get; set;}
	public Set<String> brandFilterValues {get; set;}
	public Set<String> colorFilter {get; set; }
	public Set<String> colorFilterValues {get; set;}
	public Set<String> occasionFilter {get; set; }
	public Set<String> flavorFilter {get; set; }
	public Set<String> flavorFilterValues {get; set;}
	public Set<String> typeFilter {get; set; }
	public Set<String> typeFilterValues {get; set;}
	public Set<String> statusFilter {get; set;}
	public Set<String> numberFilter {get; set;}	
	private string sortType {get;set;}
	public string sortTypeTop{get;set;}
	private integer colorCount {get;set;}
	private integer statusCount{get;set;}
	private Integer numberCount{get;set;}
	private integer brandCount{get;set;}
	private integer flavorCount{get;set;}
	private Integer typeCount{get;set;}
	private list<string> colorOptions = new list<string>();
	map<string,id> attributeMap = new map<string,id>();
	map<string,id> brandMap = new map<string,id>();
	private list<string> flavorOptions = new list<string>();
	private list<string> typeOptions = new list<string>();
	private list<string> brandOptions;
	private string NONE_STRING = ' - None - ';
	
	
	String commaSet(Set<String> l) {
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
	public String brandLast {get;set;}
	
	public String colorLast {get;set;}
	
	public String flavorLast {get;set;}
	
	public String typeLast {get;set;}
		
	public String statusLast {get{
		return commaSet(statusFilter);
		}
		set;}
	public String numberLast {get{
		return commaSet(numberFilter);
		}
		set;}	
			
	public integer colorCounter { get{
		return genericCounter(colorFilter);
	}
	set;
	}
	
	public integer brandCounter { get{
		return genericCounter(brandFilter);
	}
	set;
	}
	
	public integer flavorCounter { get{
		return genericCounter(flavorFilter);
	}
	set;
	}
	
	public integer statusCounter { get{
		return genericCounter(statusFilter);
	}
	set;
	}
	
	public integer numberCounter { get{
		return genericCounter(numberFilter);
	}
	set;
	}
	
	public integer typeCounter { get{
		return genericCounter(typeFilter);
	}
	set;
	}
	
	public integer genericCounter(set<string> cs){
		return(cs.size());
	} 
	
	/*Locale Filter*/
    private integer localeCount{get;set;}
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
	
	Set<Id> publishedRecipeIds;
	Set<Id> suppressedRecipeIds;
	/*
    //Constructor of calss APPIRIO_RecipeAssetLinkingController
	*/
	public APPIRIO_RecipeAssetLinkingController() {
		localeFilter = new Set<String>();
		isDetail = true;
		String key;
		string childDiageoName;
		authorMap = new Map<Id,User>([SELECT Id, Name From User]);
		
		//Getting all the Attribute Values for each type to display on to the screen for filtering
		for(Attribute__c attr : [select id,Attribute_Value__c,Attribute_Type__c,Attribute_Value_Image__c from Attribute__c]){
	   		if(attr.Attribute_Type__c =='Color'){
	   			colorOptions.add((string)attr.Attribute_Value__c);
	   			attributeMap.put(attr.Attribute_Value__c,attr.Id);
	   		}
	   		else if(attr.Attribute_Type__c =='Flavor'){
	   			flavorOptions.add((string)attr.Attribute_Value__c);
	   			attributeMap.put(attr.Attribute_Value__c,attr.Id);
	   		}
	   		else if(attr.Attribute_Type__c =='Drink Type'){
	   			typeOptions.add((string)attr.Attribute_Value__c);
	   			attributeMap.put(attr.Attribute_Value__c,attr.Id);
	   		}
   		}	
		
	 	brandOptions = new List<String>(); //new list for holding all of the picklist options
      	for (Diageo_Brand__c db : [SELECT Id,Name FROM Diageo_Brand__c order by Name]) { //for all values in the picklist list
         	brandOptions.add(db.Name); //add the value and label to our final list
         	attributeMap.put(db.Name,db.id);
      	}		
		
		buttonColorMap = new Map<String,String>{'Archive'=>'greyButton', 'Draft'=>'blueButton', 'Approved'=>'greenButton', 'Rejected'=>'redButton', 'Pending Approval'=> 'offGreenButton', 'Pending Review'=> 'offGreenButton'};
		
		//TO hold the Search Criteria that is applied.Used when Navigating back to the Search page from other page
		selectedAssetId = Apexpages.currentPage().getParameters().get('aId');
		selectedAssetName = Apexpages.currentPage().getParameters().get('aName');
		isNavigatingFromDetail = ApexPages.currentPage().getParameters().get('isNavigatingFromDetail');
		sortType = Apexpages.currentPage().getParameters().get('sortType');	
		searchTerm = ApexPages.currentPage().getParameters().get('searchTerm');
		currentBrand = ApexPages.currentPage().getParameters().get('currentBrand');	
		currentColor = ApexPages.currentPage().getParameters().get('currentColor');
		currentFlavor = ApexPages.currentPage().getParameters().get('currentFlavor');
		currentType = ApexPages.currentPage().getParameters().get('currentType');
		currentStatus = ApexPages.currentPage().getParameters().get('currentStatus');
		currentIngredientNumber = ApexPages.currentPage().getParameters().get('currentIngredientNumber');
		
		isNavigatingFromDetail = 'false';	
		
		if(sortType == null) {
			sortTypeTop  = 'DFT';
			sortType = 'DFT';
		}
		filterResults();
	}	
	
	//Method that takes the current Filter Criteria that is returned from Recipe View Page and Formats them into a set 
	public void splitString(string attrString,set<string> strSet,set<string> valuesSet,string flag){
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
	
	//Getting all the Brand values User selected from the UI and adds them to a set.
   	public String currentBrand {
  		get;
  		set {
  			
  			brandCount = 0;
			if (value != null) {
				this.currentBrand = value;
				value = value.replace('[','').replace(']',''); 
				value = value.trim();
			}

	    	if (brandFilter == null)
	        	brandFilter = new Set<String>();
	        
	        if(brandFilterValues == null)
	        		brandFilterValues = new set<string>();
	
	    	//If it has commas then it's multi valued
	    	if (value == null || brandFilter.Contains(attributeMap.get(value)))
	    	{
	    		brandFilter.remove(attributeMap.get(value));
	    		if(value != null) {
	    			brandFilterValues.remove(EncodingUtil.urlEncode(value,'UTF-8'));
	    			brandCount++;
	    			filterResults();
	    		}	
	    	}	
	    	else if(value != null && value!='') {
	    			if(isNavigatingFromDetail == 'true') {
	    				if(currentBrand != null && currentBrand.trim() != '') {
		    				currentBrand = currentBrand.replace('[','').replace(']','');		
						    splitString(currentBrand,brandFilter,brandFilterValues,'true');
	    				}
		    		}
		    		else{
			    		brandFilter.add(attributeMap.get(value));	
			    		brandFilterValues.add(EncodingUtil.urlEncode(value,'UTF-8'));
			    		brandCount++;
		    		}
	    			
		    		brandLast = currentBrand;
	    			filterResults();
	    	}		
		    		    		
  		}
    }
    
	//Getting all the Status values User selected from the UI and adds them to a set.
	public String currentStatus {
		get;
  		set {
  			
  			statusCount = 0;
			if (value != null) {
				this.currentStatus = value;
				value = value.replace('[','').replace(']',''); 
				value = value.trim();
			}

	    	if (statusFilter == null)
	        	statusFilter = new Set<String>();
	        
	        //If it has commas then it's multi valued
	    	if (value == null || statusFilter.Contains(value)) {
	    		
	    		statusFilter.remove(value);
	    		if(value != null) {
	    			statusCount++;
	    			filterResults();
	    		}	
	    	}else if(value != null && value!='') {
	    			if(isNavigatingFromDetail == 'true') {
	    				if(currentStatus != null && currentStatus.trim() != '') {
		    				currentStatus = currentStatus.replace('[','').replace(']','');		
						    statusFilter.add(value);
	    				}
		    		}
		    		else{
			    		statusFilter.add(value);	
			    		statusCount++;
		    		}
	    			
		    		statusLast = currentStatus;
	    			filterResults();
	    	}		
  		}	
	}
	
	//Getting all the IngredientNumber values User selected from the UI and adds them to a set.
	public String currentIngredientNumber {
		get;
		set {
			numberCount = 0;
			if (value != null) {
				this.currentIngredientNumber = value;
				value = value.replace('[','').replace(']','');
				value = value.trim();
			}
	    	if (numberFilter == null)
	        	numberFilter = new Set<String>();
		    	
	    	//If it has commas then it's multi valued
	    	if (value == null)
		    	{
		    		numberFilter.remove(value);
		    		if(value != null) {
		    			numberCount++;
		    			filterResults();
		    		}	
		    	}	
		    	
		   else if(value.trim() != '') {
		    	if(value != null && numberFilter.Contains(value.substring(0,1))) {
		    		numberFilter.remove(value.substring(0,1));
		    		numberCount++;
		    	    filterResults();
		       }
		       else if(value != null && value != '4+') {
		       		if(isNavigatingFromDetail == 'true') {
						splitString(currentIngredientNumber,numberFilter,null,'false');
		    		}
		    		else{
			    		numberFilter.add(value);
			    		numberCount++;
		    		}
		    		filterResults();
		       }
		       else if(value != null && value == '4+')	{
		       		if(isNavigatingFromDetail == 'true') {
						splitString(currentIngredientNumber,numberFilter,null,'false');
		    		}
		    		else{
			    		numberFilter.add(value.substring(0,1));
			    		numberCount++;
		    		}
		    		filterResults();
		       }	
		 	}
	  	}	
	}	
	
	//Getting all the Color values User selected from the UI and adds them to a set.
    public String currentColor {
    	get;
    	set {
			colorCount = 0;
			boolean flag = false;
			if (value != null) {
				this.currentColor = value;
				value = value.replace('[','').replace(']','');
				value = value.trim();
			}	
	    	if (colorFilter == null)
	        		colorFilter = new Set<String>();
	        	
	        if(colorFilterValues == null)
	        		colorFilterValues = new set<string>();
	
	    	if (value == null || colorFilter.Contains(attributeMap.get(value)))
		    	{
		    		colorFilter.remove(attributeMap.get(value));
		    		if(value != null) {
		    			colorFilterValues.remove(value);
		    			colorCount++;
		    			filterResults(); 
		    		}	 		
		    }	
		    else if(value != null && value!='') {
	
		    		if(isNavigatingFromDetail == 'true') {
		    			if(currentColor != null && currentColor.trim() != '')
		    				currentColor = currentColor.replace('[','').replace(']','');	
							splitString(currentColor,colorFilter,colorFilterValues,'ASCII');
		    		}
		    		else{		
			    		colorFilter.add(attributeMap.get(value));
			    		colorFilterValues.add(value);
			    		colorCount++;
		    		}
		    		colorLast = currentColor;
					filterResults(); 
		    	}			  		    		
    	}
    }
       
    //Getting all the Type values User selected from the UI and adds them to a set.
   	public String currentType {
    	get;
    	set {
    		typeCount = 0;
	    	if (value != null) {
	    		this.currentType = value;
	    		value = value.replace('[','').replace(']','');
	    		value = value.trim();
	    	}
	        
	        if (typeFilter == null)
	           typeFilter = new Set<String>();
			
			if(typeFilterValues == null)
	        		typeFilterValues = new set<string>();
			
			
			if(value == null || typeFilter.Contains(attributeMap.get(value)))
			{
	     		typeFilter.remove(attributeMap.get(value));
	     		if(value != null) {
	     			typeFilterValues.remove(value);
	     			typeCount++;	
	     			filterResults();
	     		}
	     		 
	    	}	
			else if(value != null && value!='') {
					if(isNavigatingFromDetail == 'true') {
						if(currentType != null && currentType.trim() != '')
		    				currentType = currentType.replace('[','').replace(']','');
							splitString(currentType,typeFilter,typeFilterValues,'ASCII');
		    		}
		    		else{
						typeFilter.add(attributeMap.get(value));
						typeFilterValues.add(value);
						typeCount++;
		    		}		
		    		typeLast = currentType;		
		    		filterResults();
		  	}	 	     		
    	}
    }    
    
    //Getting all the Flavor values User selected from the UI and adds them to a set.
   	public String currentFlavor {
    	get;
    	set {
    		flavorCount = 0;
	    	if (value != null) {
	    		this.currentFlavor = value;
	    		value = value.replace('[','').replace(']','');
	    		value = value.trim();
	    	}
	        
	        if (flavorFilter == null)
	           flavorFilter = new Set<String>(); 
	           
	        if(flavorFilterValues == null)
	        		flavorFilterValues = new set<string>();
	        
	        if (value == null || flavorFilter.Contains(attributeMap.get(value)))
			{
	     		flavorFilter.remove(attributeMap.get(value));
	     		
	     		if(value != null) {
	     			flavorCount++;
	     			flavorFilterValues.remove(value);
	     			filterResults();
	     		}
	    	} else if(value != null && value.trim()!='') {
				if(isNavigatingFromDetail == 'true') {
					if(currentFlavor != null && currentFlavor.trim() != '') {
	    				currentFlavor = currentFlavor.replace('[','').replace(']','');		
					    splitString(currentFlavor,flavorFilter,flavorFilterValues,'ASCII');
					}    
	    		}
	    		else{		
					flavorFilter.add(attributeMap.get(value)); 	
					flavorFilterValues.add(value);
					flavorCount++;   	
	    		}
	    			flavorLast = currentFlavor;
	    			filterResults();
    		}
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
	

	//The main Search method that appends the applied filter criteria and performs the Search.
	public PageReference filterResults() {
		filtered = true;
		recipeIds = new List<String>();
		List<Recipe__c> tempRecipes = new List<Recipe__c>();
		for(Recipe__c recipe :setWrapperRecipes(Database.query(createQuery(true,null)))) {
			recipeIds.add(recipe.Id);
			tempRecipes.add(recipe);
		}
		con = new ApexPages.StandardSetController(tempRecipes);
		con.setPageSize(PAGE_SIZE);		
		whereClause = null;
		return null;
    }
    
    private String createQuery(Boolean countRecipe, Set<String> recIds) {
    	if(sortTypeTop != null) {
			sortType = sortTypeTop;
		} else {
			sortType = 'DFT';
		}	
    	
    	String rQuery;
    	if(countRecipe) {
    		rQuery =  'SELECT Id, '; 
			rQuery += '(Select Id, Status__c From Published_Recipes__r where Digital_Published_Asset__c=\''+selectedAssetId+'\') ';
			rQuery += 'From Recipe__c ';
    	} else {
    		rQuery =  'SELECT CreatedById, CreatedDate, Recipe_Title__c, LastModifiedDate, Status__c, Locale__c, Main_Drink_Image__c, '; 
			rQuery += 'Main_Drink_Image__r.Content_id__c, Mobile_Drink_Image__r.Content_id__c, Mobile_Selected_Image__r.Content_id__c, ';
			rQuery += 'Mobile_Unselected_Image__r.Content_id__c, Background_Image__r.Content_id__c, Brand_Recipe_Image__r.Content_id__c, ';
			rQuery += 'Search_Recipe_Image__r.Content_id__c, Additional_Image_1__r.Content_id__c, Additional_Image_2__r.Content_id__c, ';  
			rQuery += '(Select Id, Status__c From Published_Recipes__r where Digital_Published_Asset__c=\''+selectedAssetId+'\') ';
			rQuery += 'From Recipe__c ';	
    	}
    		
    	whereClause = ' Where recordSaved__c = true and Recipe_Title__c <> null and Status__c = \'Approved\' ';
      //whereClause = ' Where recordSaved__c = true and Recipe_Title__c <> null - Modified on July 18 per Diageo case 00006064
    	
    	
    	if(!countRecipe) {
			if(recIds.isEmpty()) {
				whereClause += ' And (Id IN (\'\')';
				whereClause += ')';
			} else {
				whereClause += ' And (Id IN ';
				whereClause += parseListForQuery(recIds)+')';
			}
			
		} else {
			//Search if the search box has been populated, filter if not
			if (searchTerm == null || searchTerm.length() == 0 ) {
					searchFunctionality();
					
			} else {
				string brandSearchTerm = searchTerm.replace(' ','%');
			    //if(isNavigatingFromdetail!='true') - Modified on July 30 per Diageo case 00006102
			    if(isNavigatingFromdetail=='true')
			    searchTerm = String.escapeSingleQuotes(searchTerm);
			    searchTerm = searchTerm.replace('*','\\*');
			    set<string> childBrandNames = new set<string>();
			    list<Diageo_Ingredient__c> tempDIng = new list<Diageo_Ingredient__c>();
			    string sa ='%'+brandSearchTerm+'%';
			    string st = '%'+searchTerm+'%';
			  	
			    set<string> recipeIdset = new set<string>();
			    set<Recipe__c> wholeRecipeList = new set<Recipe__c>();
			    
			    wholeRecipeList.addAll([select id from Recipe__c where id IN (select Recipe__c from Recipe_Attribute__c where Attribute__r.Attribute_Value__c like:st)]);
			    wholeRecipeList.addAll([select id from Recipe__c where id IN (select Recipe__c from Recipe_Occasion__c where Occasion__r.Name_Of_The_Occasion__c like:st or Occasion__r.Occasion_Type__c like:st)]);
			    wholeRecipeList.addAll([select id from Recipe__c where id IN (Select Recipe__c from Preparation_Step__c where Description__c like :st)]);
			    wholeRecipeList.addAll([select id from Recipe__c where Recipe_Title__c like :st or Status__c like :st or Recipe_Tag__c like :st]);
			    wholeRecipeList.addAll([select id from Recipe__c where id IN (select Recipe__c FROM Diageo_Ingredient__c Where Recipe_Diageo_Product__r.Name like :sa or Recipe_Non_Diageo_Product__r.Name like :sa or Recipe_Diageo_Product__r.Short_Description__c like :sa or Recipe_Brand__r.Short_Description__c like :sa)]);
			    
			   	for(Recipe__c r :wholeRecipeList) {
			   		recipeIdset.add(r.Id);
			   	}
				if(wholeRecipeList.isEmpty()) {
					whereClause += ' And (Id IN (\'\')';
					whereClause += ')';
				}
				else{
					whereClause += ' And (Id IN ';
					whereClause += parseListForQuery(recipeIdset)+')';
				}
							
				if ((brandFilter != null && brandFilter.size() > 0) || (colorFilter != null && colorFilter.size() > 0) ||  (flavorFilter != null && flavorFilter.size() > 0) ||(typeFilter != null && typeFilter.size() > 0) || (statusFilter != null && statusFilter.size() > 0) || (numberFilter != null && numberFilter.size() > 0)  || (localeFilter != null && localeFilter.size() > 0)) {				
					searchFunctionality();
				}
			}
    	}
		
		if (whereClause != null)
				rQuery = rQuery + whereClause;
				
		//Only Admins can see Archived Recipes			
		if (!getIsSuperAdmin()) {
			rQuery = rQuery + ' AND Status__c <> \'Archive\'';
		}
		
		//Add order by
		if(sortType != null && sortType.equals('DESC')) {
			rQuery += ' Order By Recipe_Title__c DESC';	
		} else {
			rQuery += ' Order By Recipe_Title__c ASC';
		}
		return rQuery;
    }
    
    //Method that is being called when Filters are being Selected/Applied.
    public void searchFunctionality() {
    	if (brandFilter != null && brandFilter.size() > 0) {
			if (whereClause == null)
				whereClause = ' WHERE ';
			else
				whereClause += ' AND ';	
					
			whereClause += 'Id IN (select Recipe__c from Diageo_Ingredient__c where Recipe_Diageo_Product__r.Diageo_Brand_Id__c In';
			if(brandFilter != null && brandFilter.isEmpty())
				whereClause += '(\'\')';
			else
			whereClause += parseListForQuery(brandFilter)+')';
		}		
	
		if ((colorFilter != null && colorFilter.size() > 0) || (flavorFilter != null && flavorFilter.size() > 0) ||(typeFilter != null && typeFilter.size() > 0)) {		
			set<string> attrFilter = new set<string>();
			integer havingInt = 0;
			if(colorFilter != null && colorFilter.size() > 0) {
				attrFilter.addAll(colorFilter);
				havingInt++;
			}	
			if(flavorFilter != null && flavorFilter.size() > 0) {
				attrFilter.addAll(flavorFilter);
				havingInt++;
			}	
			if(typeFilter != null && typeFilter.size() > 0) {
				attrFilter.addAll(typeFilter);
				havingInt++;
			}
			
			if (whereClause == null)
				whereClause = 'WHERE ';
			else
				whereClause += 'AND ';
					
			set<string> RecipeIdSet = new set<String>();	
			AggregateResult[] recipeFilterList = [select Recipe__c from Recipe_Attribute__c where Attribute__r.Id in:attrFilter group by Recipe__c having COUNT_DISTINCT(Attribute__r.Attribute_Type__c) =:havingInt];
			
			
			if(recipeFilterList.size()>0 && recipeFilterList != null) {
				for(AggregateResult ar :recipeFilterList) {	
					RecipeIdSet.add((string)ar.get('Recipe__c'));
				}
			}
			
			if (RecipeIdSet.isEmpty())
				whereClause += 'Id IN (\'\')';
			else{
				whereClause += ' Id IN ';
				whereClause += parseListForQuery(RecipeIdSet);
			}	
		}
		
		if (localeFilter != null && localeFilter.size() > 0) {
			if (whereClause == null)
				whereClause = ' WHERE ';
			else
				whereClause += ' AND ';
			
			whereClause += 'locale__c  In ';	
			whereClause += parseListForQuery(localeFilter);	
		}
		
		if (numberFilter != null && numberFilter.size() > 0) {
			//filter by ingredient number	
			Set<String> constructedNumberFilter = new Set<String>();
			map<string, integer> recipeCountMap = new map<string,Integer>();
			Map<string,set<string>> integerRecipeMap = new Map<string,set<string>>();
			
			AggregateResult[] diageoIngredientResults	= [Select Recipe__c, count(Id) 
															 From Diageo_Ingredient__c
															GROUP BY  Recipe__c];
																											
			integer totalCount = 0;
			for (AggregateResult ard : diageoIngredientResults) {
					
				if((Integer)ard.get('expr0') == 1) {
					set<string> oneList = integerRecipeMap.get('1');
					if (oneList == null) {
						oneList = new set<string>();
					}
					oneList.add((String)ard.get('Recipe__c'));
					integerRecipeMap.put('1',oneList);
				} else if((Integer)ard.get('expr0') == 2) {
					set<string> twoList = integerRecipeMap.get('2');
					if (twoList == null) {
						twoList = new set<string>();
					}
					twoList.add((String)ard.get('Recipe__c'));
					integerRecipeMap.put('2',twoList);
				} else if((Integer)ard.get('expr0') == 3) {
					set<string> threeList = integerRecipeMap.get('3');
					if (threeList == null) {
						threeList = new set<string>();
					}
					threeList.add((String)ard.get('Recipe__c'));
					integerRecipeMap.put('3',threeList);
				}
				
				if((Integer)ard.get('expr0') >= 4) {
					set<string> fourList = integerRecipeMap.get('4');
					if (fourList == null) {
						fourList = new set<string>();
					}
					fourList.add((String)ard.get('Recipe__c'));
					integerRecipeMap.put('4',fourList);
				}
			}
				
			for(string s: numberFilter) {
				if(integerRecipeMap.get(s) != null)
					constructedNumberFilter.addAll(integerRecipeMap.get(s));
			}
				
			if (whereClause == null)
				whereClause = ' WHERE ';
			else
				whereClause += ' AND ';
					
				
			if (constructedNumberFilter.size()<1)
				whereClause += 'Id IN (\'\')';
			else {	
				whereClause += 'Id In ';
				whereClause += parseListForQuery(constructedNumberFilter);
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
					localeFilter.add(value);
	    		} else {	
		    		localeFilter.add(value);
		    		localeCount++;	
	    		}
	    		filterResults();
	    	}
		}	
	}
    
    //Clears all the Selected or applied Filter Criteria.
    public PageReference clearFilters() {
    	colorLast = '';
    	flavorLast = '';
    	typeLast = '';
    	brandLast = '';
    	currentStatus = null;
    	currentLocale = null;
    	
    	if (flavorFilter != null)
    		flavorFilter.clear();
    	if (colorFilter != null)	
    		colorFilter.clear();
    	if (typeFilter != null)
    		typeFilter.clear();
    	if (brandFilter != null)
    		brandFilter.clear();
    	if (statusFilter != null)
    		statusFilter.clear();
    	if (numberFilter != null)
    		numberFilter.clear();
    	if(searchTerm != null)
    		searchTerm = '';	
        if (localeFilter != null)
    		localeFilter.clear();
    	if (flavorFilterValues != null)
    		flavorFilterValues.clear();
    	if (colorFilterValues != null)	
    		colorFilterValues.clear();
    	if (typeFilterValues != null)
    		typeFilterValues.clear();
    	if (brandFilterValues != null)
    		brandFilterValues.clear();
    	if (isNavigatingFromDetail == 'true')
    		isNavigatingFromDetail = '';
    	return filterResults();
    }
    
    public PageReference refreshPanel() {
    	return null;
    }
    
	public List<Diageo_Brand__c> getRecipeBrands() {
		return [SELECT Id, Name FROM Diageo_Brand__c];
	}
	
	//Diageo Brands
	public List<String> getBrands() {	
		return brandOptions;
   	}	
	
	public List<String> getRecipeFlavors() {
    	return flavorOptions;
   	}
	
	public List<String> getRecipeColors() {
    	return colorOptions;
   	}
   	
   	public List<String> getTypes() {
    	return typeOptions;
   	}
   	
   	public List<String> getStatus() {
    	return getPickValues2(new Published_Recipe__c(), 'Status__c');
   	}
   	
   	public List<String> getLocales() {
        return getPickValues2(new Recipe__c(), 'Locale__c');
    }
   	
   	public List<String> getIngredientNumbers() {
    	List<String> ingNum = new List<String>();
    	ingNum.add('1');
    	ingNum.add('2');
    	ingNum.add('3');
    	ingNum.add('4+');
    	return ingNum;
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
        options.add(new SelectOption('RPF','Ready to Publish First'));
        return options;
   }
   
   
   /* Paging Section */
   
   	public list<recipeWrapper> recipes {get;set;}
 
	// instantiate the StandardSetController from a query locator
	public ApexPages.StandardSetController con {
		get {
			if(con == null) {
				con = new ApexPages.StandardSetController(setWrapperRecipes(Database.query(createQuery(true,null))));
				//sets the number of records in each page set
				con.setPageSize(PAGE_SIZE);
			}
			return con;
		}
		set;
	}
	
	//returns a list of arranged recipes in the current page set
	public List<Recipe__c> setWrapperRecipes(List<Recipe__c> sRecipes) {
		
		List<Recipe__c> tempRecipes = new List<Recipe__c>();
		publishedRecipeIds = new Set<Id>();
		suppressedRecipeIds = new Set<Id>();
      	
      	List<Recipe__c> lstRecipes = new List<Recipe__c>();
      	
		Map<String,List<Recipe__c>> mapPublishedStatusRecipes = new Map<String,List<Recipe__c>>();
		for(Recipe__c recipe : sRecipes) {
      		if(recipe.Published_Recipes__r.size() > 0 && recipe.Published_Recipes__r[0].Status__c != null) {
				if(recipe.Published_Recipes__r[0].Status__c.equals('Published')) {
					publishedRecipeIds.add(recipe.Id);
				} else {
					suppressedRecipeIds.add(recipe.Id);
				}
				
				if(!mapPublishedStatusRecipes.containsKey(recipe.Published_Recipes__r[0].Status__c)) {
	      			mapPublishedStatusRecipes.put(recipe.Published_Recipes__r[0].Status__c, new List<Recipe__c>());
	      		}
	      		mapPublishedStatusRecipes.get(recipe.Published_Recipes__r[0].Status__c).add(recipe);
      		} else {
      			if(!mapPublishedStatusRecipes.containsKey('Ready to Publish')) {
	      			mapPublishedStatusRecipes.put('Ready to Publish', new List<Recipe__c>());
	      		}
	      		mapPublishedStatusRecipes.get('Ready to Publish').add(recipe);
      		}
      		lstRecipes.add(recipe);
      	}
      	
      	if(statusFilter == null) statusFilter = new Set<String>();
      	
      	if(statusFilter.size() == 0 && (sortType.equals('ASC') || sortType.equals('DESC')) ) {
      		for(Recipe__c rw :lstRecipes) {
	      		tempRecipes.add(rw);
      		}
      	} 
      	
      	if(statusFilter.size() > 0) {
	      	if(statusFilter.contains('Published') && mapPublishedStatusRecipes.get('Published') != null) {
	      		for(Recipe__c rw :mapPublishedStatusRecipes.get('Published')) {
	      			tempRecipes.add(rw);
	      		} 
	      	} 
	      	
	      	if(statusFilter.contains('Suppressed') && mapPublishedStatusRecipes.get('Suppressed') != null) {
	      		for(Recipe__c rw :mapPublishedStatusRecipes.get('Suppressed')) {
	      			tempRecipes.add(rw);
	      		} 
	      	}
      	}
      	
      	if(statusFilter.size() == 0 && (sortType.equals('DFT') || sortType.equals('RPF'))) {
      		for(Recipe__c rw :sortRecords(mapPublishedStatusRecipes)) {
      			tempRecipes.add(rw);
      		}
      	}
      	
      	return tempRecipes;
   	}
   	
 	//returns a list of wrapper objects for the sObjects in the current page set
	public List<recipeWrapper> getWrapperRecipes() {
		Integer counter = ((pageNumber-1)*PAGE_SIZE);
		Set<String> ids = new Set<String>();
      	for(Integer cnt=0; cnt<PAGE_SIZE; cnt++) {
      		if(recipeIds.size() > counter+cnt)
      			ids.add(recipeIds[counter+cnt]);
      	}
      	
      	recipes = new List<RecipeWrapper>();
      	for(Recipe__c recipe : setWrapperRecipes(Database.query(createQuery(false,ids)))) {
      		if(recipe.Published_Recipes__r.size() > 0 && recipe.Published_Recipes__r[0].Status__c != null) 
      	    	recipes.add(new RecipeWrapper(recipe,recipe.Published_Recipes__r[0].Status__c));
      		else
      			recipes.add(new RecipeWrapper(recipe,'Ready to Publish'));
      	}
		whereClause = null;
		return recipes;
   	}
   	
   	private List<Recipe__c> sortRecords(Map<String,List<Recipe__c>> mapPublishedStatusRecipes) {
   		List<Recipe__c> tempRecipes = new List<Recipe__c>();
   		if(sortType.equals('DFT')) {
   			if(mapPublishedStatusRecipes.get('Published') != null) {
	      		for(Recipe__c recipe :mapPublishedStatusRecipes.get('Published')) {
	      			tempRecipes.add(recipe);
	      		} 
   			}
   			if(mapPublishedStatusRecipes.get('Suppressed') != null) {
	      		for(Recipe__c recipe :mapPublishedStatusRecipes.get('Suppressed')) {
	      			tempRecipes.add(recipe);
	      		} 
   			}
   			if(mapPublishedStatusRecipes.get('Ready to Publish') != null) {
	      		for(Recipe__c recipe :mapPublishedStatusRecipes.get('Ready to Publish')) {
	      			tempRecipes.add(recipe);
	      		} 
   			}
   		}
   		if(sortType.equals('RPF')) {
   			if(mapPublishedStatusRecipes.get('Ready to Publish') != null) {
	      		for(Recipe__c recipe :mapPublishedStatusRecipes.get('Ready to Publish')) {
	      			tempRecipes.add(recipe);
	      		} 
   			}
   			if(mapPublishedStatusRecipes.get('Suppressed') != null) {
	      		for(Recipe__c recipe :mapPublishedStatusRecipes.get('Suppressed')) {
	      			tempRecipes.add(recipe);
	      		} 
   			}
   			if(mapPublishedStatusRecipes.get('Published') != null) {
	      		for(Recipe__c recipe :mapPublishedStatusRecipes.get('Published')) {
	      			tempRecipes.add(recipe);
	      		} 
   			}
   		}
   		return tempRecipes;
   	}
   	
   	public PageReference publishAll() {
   		selectedRecipeId = null;
   		for(recipeWrapper rw: recipes) {
   			rw.checked = true;
   		}
   		return savePublishRecipes();
   	}
   	
   	public PageReference suppressedAll() {
   		selectedRecipeId = null;
   		for(recipeWrapper rw: recipes) {
   			if(rw.checked)
   				rw.checked = false;
   		}
   		return savePublishRecipes();
   	}
   	
   	public PageReference publishRecipe() {
   		return savePublishRecipes();
   	}
   	
	public PageReference savePublishRecipes() {
		List<Published_Recipe__c> lstInsertedPublishedRecipe = new List<Published_Recipe__c>();
		List<Published_Recipe__c> lstUpdatedPublishedRecipe = new List<Published_Recipe__c>(); 
		for(recipeWrapper rw: recipes) {
			if(selectedRecipeId != null && selectedRecipeId == rw.rec.Id) {
				rw.checked = !rw.checked;
			}
			if(rw.checked && !publishedRecipeIds.contains(rw.rec.Id) && !suppressedRecipeIds.contains(rw.rec.Id)) {
				lstInsertedPublishedRecipe.add(
							new Published_Recipe__c(
								Status__c = 'Published',
								Recipe__c = rw.rec.Id,
								Digital_Published_Asset__c = selectedAssetId));
			} else if(rw.checked && suppressedRecipeIds.contains(rw.rec.Id)) {
				lstUpdatedPublishedRecipe.add(
							new Published_Recipe__c(
								Id = rw.rec.Published_Recipes__r[0].Id,
								Status__c = 'Published',
								Recipe__c = rw.rec.Id,
								Digital_Published_Asset__c = selectedAssetId));
			}  else if(!rw.checked && publishedRecipeIds.contains(rw.rec.Id)) {
				lstUpdatedPublishedRecipe.add(
							new Published_Recipe__c(
								Id = rw.rec.Published_Recipes__r[0].Id,
								Status__c = 'Suppressed',
								Recipe__c = rw.rec.Id,
								Digital_Published_Asset__c = selectedAssetId));
			} 
		}
		
		if(lstInsertedPublishedRecipe.size() > 0)
			insert lstInsertedPublishedRecipe;
		
		if(lstUpdatedPublishedRecipe.size() > 0)
			update lstUpdatedPublishedRecipe;
		
		return filterResults();
	}
	
	//indicates whether there are more records after the current page set.
	public Boolean hasNext {
		get {
			return con.getHasNext();
		}
		set;
	}
	
	//used to show user the total size of the list
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