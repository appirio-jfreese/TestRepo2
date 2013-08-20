/**

Updated By 	: Basant Kumar Verma (Appirio OffShore)
Date				: 15/6/2013
Story/Task	: US79/DE594

* @author Denise Bacher
* @date 29/08/2011
* @description API Service class used to display valid user inputs.
*/
public class Service_UserInput {
    /**
    * @author Mateusz Malik
    * @date 08/01/2012
    * @description Get the option list of specified parent theme sales drivers from Custom Settings list for admin (no classifications)
    * @return List<SelectOption> List of the sales drivers
    */
    public static List<selectOption> getSalesDrivers(String parentTheme) {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));
        
        List<contentCategory__c> categories = [SELECT Description__c FROM contentCategory__c WHERE Parent_Theme__c = :parentTheme ORDER BY Sort_Order__c ASC];
        for(contentCategory__c cat: categories){
            options.add(new SelectOption(cat.Description__c, cat.Description__c));
        }
        
        return options;
    } 
    
    /**
    * @author Mateusz Malik
    * @date 08/01/2012
    * @description Get the option list of specified parent theme sales drivers from Custom Settings list for specified classifications
    * @return List<SelectOption> List of the sales drivers
    */
    public static List<selectOption> getSalesDrivers(Set<String> classifications, String parentTheme) {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));
        
        if(!classifications.isEmpty()){
	        String query = 'SELECT Description__c FROM contentCategory__c WHERE Parent_Theme__c = \''+parentTheme+'\' AND (';
	        String glue = '';
	        for(String classification : classifications){
	        	query += glue + 'Classification__c like \'%'+classification+'%\'';
	        	glue = ' or ';
	        }
	        query += ') order by Sort_Order__c ASC';
	        
	        List<contentCategory__c> categories = Database.query(query);
	        for(contentCategory__c cat: categories){
	            options.add(new SelectOption(cat.Description__c, cat.Description__c));
	        }
        }
        
        return options;
    }
   /**
    * @author Bartek Dudziak
    * @date 01/09/2011
    * @description Get the option list of Case Status
    * @return List<SelectOption> List of the case Status
    */
    public static List<SelectOption> getCaseStatusList() {
        List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', 'Select Case Status'));
        Schema.DescribeFieldResult fieldResult = Case.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        return options;
    }
    
   /**
    * @author Bartek Dudziak
    * @date 12/12/2011
    * @description Get the option list of Case Types
    * @return List<SelectOption> List of the case Types
    */
    public static List<SelectOption> getCaseTypeList() {
        List<SelectOption> options = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult = Case.Type.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        return options;
    }    

    /**
    * @author Bartek Dudziak
    * @date 07/09/2011
    * @description Get the option list for requested selectName
    * @return List<SelectOption> List of options
    */
    public static List<selectOption> getSelectOption(String SelectName, String allText){
        List<SelectOption> options = new List<SelectOption>();
        if(allText != null){
        	options.add(new SelectOption('All', allText));
        }
        
        List<SelectValues__c> optAll = SelectValues__c.getall().values();
        
        for(SelectValues__c currentOption: optAll){
            if(currentOption.SelectName__c == SelectName){
				options.add(new SelectOption(currentOption.SelectValue__c, currentOption.SelectValue__c));
            }
        }

        return options;
    }

	private static List<SelectValues__c> cacheQuarter;
    /**
	* @author Bartek Dudziak
	* @date 08/09/2011
	* @description Get Quarter Description
	*/
	public static List<SelectValues__c> getQuarterDescription(){
				
		if(cacheQuarter == null){
	        List<SelectValues__c> optAll = SelectValues__c.getall().values();
	        List<SelectValues__c> options = new list<SelectValues__c>();
	        
	        for(SelectValues__c currentOption: optAll){
	            if(currentOption.SelectName__c == 'QuarterView'){
					options.add(currentOption);
					
	            }
	        }
			cacheQuarter = options;	      
		}
		return cacheQuarter;
	}	
	
    /**
    * @author Bartek Dudziak
    * @date 27/09/2011
    * @description Get the option list of brand categories
    * @return List<SelectOption> List of the brand categories
    */
    public static List<selectOption> getBrandCategories(Boolean addSelectACategory){
        List<SelectOption> options = new List<SelectOption>();
        if(addSelectACategory == true){
        	options.add(new SelectOption('All', 'Select a Category'));
        }
        
    	// user brand types
		set<string> brandCategories = Service_API.getUserBrandCategories();
        
        Schema.Describefieldresult fieldResult = Brand__c.Category__c.getDescribe();
        List<Schema.Picklistentry> ple = fieldResult.getPicklistValues();
        for(Schema.Picklistentry f: ple){
        	String bCategory = f.getValue();
        	if(brandCategories.contains(bCategory)){
            	options.add(new SelectOption(f.getValue(), f.getLabel()));
        	}
        }
        
        return options;
    }
    
    
    private static List<Map<String, String>> cacheQuarterOptions;
    /**
    * @author Bartek Dudziak, Anna Ptak
    * @date 18/10/2011
    * @description Get the list of quarters (for filter)
    * @return List<SelectOption> List of options
    */
    public static List<Map<String, String>> getQuarterOptions(Integer currentQtr, Integer currentYear, Date startDate){
    	
    	if(cacheQuarterOptions == null){
	    	SelectValues__c[] quarterDescription = getQuarterDescription();
	        List<Map<String, String>> options = new List<Map<String, String>>();
	
			Integer orginalCurrentYear = currentYear;
			Integer numberOfExtraQuarters = 3;
			
			if(currentQtr < 1 || currentQtr > 4){
	        	return options;  
			}
	
			for(SelectValues__c dsc : quarterDescription){
				if(Integer.valueOf(dsc.SelectSubValue__c) == currentQtr){
	        		options.add(new Map<String, String>{'value' => '0', 'className' => dsc.SelectValue__c,'year' => string.valueOf(startDate.year()), 'fiscalYear' => String.valueOf(currentYear).substring(2,4) });
	        		break;
				}
			}
	
			// next quarters
			for (Integer i = currentQtr; i < currentQtr + numberOfExtraQuarters; i++) {
				if(math.mod(i,4) == 0){
					currentYear += 1;
				}
				startDate = startDate.addMonths(3);
				for(SelectValues__c dsc : quarterDescription){
					if(Integer.valueOf(dsc.SelectSubValue__c) == (math.mod(i,4)+1)){
		        		options.add(new Map<String, String>{'value' => ''+(i-currentQtr+1)+'', 'className' => dsc.SelectValue__c,'year' => string.valueOf(startDate.year()), 'fiscalYear' => String.valueOf(currentYear).substring(2,4) });
		        		break;
					}
				}
			}
			cacheQuarterOptions = options;	        
    	}  
    	  return cacheQuarterOptions;	
    }    
    
    /**
    * @author Mateusz Malik
    * @date 23/11/2011
    * @description Get the option list of Months.
    * @return List<SelectOption> List of the Months.
    */
    public static List<Map<String, String>> getMonthsOptions(Service_Calendar calendarArg) {
        Service_Calendar calendar = new Service_Calendar(calendarArg.dateRange, calendarArg.startDate);
        
        List<Map<String, String>> options = new List<Map<String, String>>();        
        
        for(Integer i = 0; i<12; i++){
        	Integer currYear = calendar.startDate.year();
        	Integer fiscalYear = calendar.fiscalYear;
        	String className = '';
        	String monthName = '';
        	if(calendar.startDate.month() == 1){
        		monthName = 'January';
        		className = 'jan';
        	} else if(calendar.startDate.month() == 2){
        		monthName = 'February';
        		className = 'feb';
        	} else if(calendar.startDate.month() == 3){
        		monthName = 'March';
        		className = 'mar';
        	} else if(calendar.startDate.month() == 4){
        		monthName = 'April';
        		className = 'apr';
        	} else if(calendar.startDate.month() == 5){
        		monthName = 'May';
        		className = 'may';
        	} else if(calendar.startDate.month() == 6){
        		monthName = 'June';
        		className = 'jun';
        	} else if(calendar.startDate.month() == 7){
        		monthName = 'July';
        		className = 'jul';
        	} else if(calendar.startDate.month() == 8){
        		monthName = 'August';
        		className = 'aug';
        	} else if(calendar.startDate.month() == 9){
        		monthName = 'September';
        		className = 'sep';
        	} else if(calendar.startDate.month() == 10){
        		monthName = 'October';
        		className = 'oct';
        	} else if(calendar.startDate.month() == 11){
        		monthName = 'November';
        		className = 'nov';
        	} else if(calendar.startDate.month() == 12){
        		monthName = 'December';
        		className = 'dec';
        	}
        	options.add(new Map<String, String>{'value' => ''+i+'', 'className' => className,'year' => string.valueOf(currYear), 'fiscalYear' => String.valueOf(fiscalYear), 'monthName' => monthName });
        	calendar.incrementMonth(1);
        }
        
        return options;
    }
    
   /**
    * @author Bartek Dudziak
    * @date 12/12/2011
    * @description Get the option list of number of result per page
    * @return List<SelectOption> List of number of result per page
    */
    public static List<SelectOption> getNumberOfItemsPerPageList() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = User.Number_of_items_per_page__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }     
        return options;
    }   
    
   /**
    * @author Bartek Dudziak
    * @date 12/12/2011
    * @description Get the option list of site themes
    * @return List<SelectOption> List of site themes
    */
    public static List<SelectOption> getSiteThemes() {
        List<SelectOption> options = new List<SelectOption>();

    	// user brand types
		set<string> brandTypes = Service_API.getUserBrandTypes();
		// user brand types
        Schema.DescribeFieldResult fieldResult = User.Diageo_Direct_Theme__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {	
        	String stheme = f.getValue();
        	if(brandTypes.contains(stheme)){
            	options.add(new SelectOption(f.getValue(), f.getLabel()));
        	}
        }
        
        return options;
    } 
    
   /**
    * @author Bartek Dudziak
    * @date 12/12/2011
    * @description Get the option list of time zones 
    * @return List<SelectOption> List of time zones 
    */
    public static List<SelectOption> getTimezones() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = User.TimeZoneSidKey.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {	
           	options.add(new SelectOption(f.getValue(),f.getLabel()));
        }     
        return options;
    } 
    
    
    
    /**
    * @author Appirio Jaipur
    * @date 30/08/2012
    * @description Get the option list of Case Application field
    * @return List<SelectOption> List of the case Application
    */
    public static List<SelectOption> getApplicationList(String userType,String pickListName) {
        /* Changes done for case 00003410 by Jai gupta on 28 Jan , 2013
        //List<SelectOption> options = new List<SelectOption>();
		/**
	    * @Added by Appirio Jaipur
	    * @date 09/01/2012
	    * @Fetching values from "ExcludeApplicationValues__c" custom setting case #00032303
	    *
	    * @ Modified by Appirio Jaipur
	    * @date 11/22/2012
	    * @ Changed the custom setting name to "DependentPicklistValues__c" which is now holding
	    	piclist name with values to be shown for case #00003104
	    **/
		/*Map<string,DependentPicklistValues__c> valuesWithPicklist = DependentPicklistValues__c.getAll();
		
        Schema.DescribeFieldResult fieldResult = Case.Application__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
        	for(DependentPicklistValues__c cs : valuesWithPicklist.values()) {
        		if(cs.App_Name__c.equalsIgnoreCase(userType) && cs.pickList_Name__c.equalsIgnoreCase(pickListName)){
        			//for(String str : valuesWithPicklist.get(userType).Picklist_values__c.split(',')) {
        			for(String str : cs.Picklist_values__c.split(',')) {
	        			if(str.equalsIgnoreCase(f.getLabel())) {
	        				options.add(new SelectOption(f.getLabel(), f.getValue()));
	        			}
	        		}
        		}
        	}
        	/*if(valuesWithPicklist.containsKey(userType)) {
        		for(String str : valuesWithPicklist.get(userType).Picklist_values__c.split(',')) {
        			if(str.equalsIgnoreCase(f.getLabel())) {
        				options.add(new SelectOption(f.getLabel(), f.getValue()));
        			}
        		}
        	}*/
       /* } */
       	 Schema.DescribeFieldResult fieldResult = Case.Application__c.getDescribe();
         return getDependentPicklistValues(userType,pickListName,fieldResult);  
        //return options;
    }
    
    
    /** Changes done for case 00003410 **/
    /**
    * @author Appirio Jaipur [Jai Gupta]
    * @date 28/01/2013
    * @description Get the option list for Dependent picklist custom setting (Generic method) 
    * @return List<SelectOption> List Dependent picklist custom setting (Generic method)
    */
    private static List<SelectOption> getDependentPicklistValues(String userType,String pickListName,Schema.DescribeFieldResult fieldResult) {
    	List<SelectOption> options = new List<SelectOption>();
    	Map<string,DependentPicklistValues__c> valuesWithPicklist = DependentPicklistValues__c.getAll();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
        	for(DependentPicklistValues__c cs : valuesWithPicklist.values()) {
        		if(cs.App_Name__c.equalsIgnoreCase(userType) && cs.pickList_Name__c.equalsIgnoreCase(pickListName)){
        			//for(String str : valuesWithPicklist.get(userType).Picklist_values__c.split(',')) {
        			for(String str : cs.Picklist_values__c.split(',')) {
	        			if(str.equalsIgnoreCase(f.getLabel())) {
	        				options.add(new SelectOption(f.getLabel(), f.getValue()));
	        			}
	        		}
        		}
        	}
        }
    	return options ;
    }
    
    /**
    * @author Appirio Jaipur [Jai Gupta]
    * @date 28/01/2013
    * @description Get the option list of Case  type field
    * @return List<SelectOption> List of the case  Type
    */
    public static List<SelectOption> getCaseTypeList(String userType,String pickListName) {
    	Schema.DescribeFieldResult fieldResult = Case.Type.getDescribe();
    	return getDependentPicklistValues(userType,pickListName,fieldResult);
    }
    
    /**
    * @author Appirio Jaipur [Jai Gupta]
    * @date 28/01/2013
    * @description Get the option list of Case Market type field
    * @return List<SelectOption> List of the case Market Type
    */
    public static List<SelectOption> getMarketTypeList() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Case.Market_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
			options.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        return options;
    }
    
    /**
    * @author Appirio Jaipur [Jai Gupta]
    * @date 28/01/2013
    * @description Get the option list of Case Role field
    * @return List<SelectOption> List of the case Role
    */
    public static List<SelectOption> getRoleList() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Case.Role__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
			options.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        return options;
    }
    /** End for case 00003410 **/    
    
    
    // Start : Changes for US79/DE594 - Basant Verma
    /**
    * @author Basant Verma
    * @date 6/15/2013
    * @description Get the option list of Notification Frequency
    * @return List<SelectOption> List of Notification Frequency
    */
    public static List<SelectOption> getNotificationFrequency() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = User.Content_Notification_Frequency__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {	
        	String stheme = f.getValue();
        	options.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        return options;
    }
    // End : Changes for US79/DE594 - Basant Verma
}