public with sharing class Controller_CloneCalendar {

	private ApexPages.StandardController con;
	private Calendar__c calendarRecord;
	public List<selectOption> salesChanells {public get; public set;}
	
	public String selectedChanell {public get; public set;}
	public String calendarName{public get; public set;}
	public List<selectOption> recordTypes {public get; public set;}
	public String selectedRecordType{public get; public set;}
	public List<CalendarBrand__c> calendarBrands;
	private Calendar__c calendar;
	private Map<String, String> recordTypeToConstant;

    public Controller_CloneCalendar(ApexPages.StandardController controller) {
    	
        con = controller;                
        calendarRecord = (Calendar__c)controller.getRecord();        
        
        calendar = [Select c.show_tooltip_details__c, c.background_color__c, c.Type__c, c.Theme__c, c.Text_Color__c, c.SystemModstamp, c.Start_Date__c, c.Specification_Text__c, c.Specification_Content_Description__c, c.Situation_Text__c, c.Situation_Content_Description__c, c.Ship_Date__c, c.Segment__c, c.Sales_Channel__c, c.RecordTypeId, c.RecordType.name, c.Programs__c, c.Priority__c, c.Name, c.Logo_Image_Small__c, c.Logo_Image_Large__c, c.Launch_Date__c, c.LastModifiedDate, c.LastModifiedById, c.LastActivityDate, c.IsDeleted, c.Idea_Text__c, c.Idea_Content_Description__c, c.Id, c.How_it_Works_Text__c, c.How_it_Works_Content_Description__c, c.Folder__c, c.End_Date__c, c.Description__c, c.Description_Content_Description__c, c.CreatedDate, c.CreatedById, c.Consumer_Target_Text__c, c.Consumer_Target_Content_Description__c, c.Background_Color2__c, c.Archive__c From Calendar__c c where c.id = :calendarRecord.id];
        
        recordTypeToConstant = new Map<String, String>();
        if(calendar.RecordType.name != 'Planning'){
        	recordTypeToConstant.put('Multicultural', Constant.MULTICULTURAL);
	        recordTypeToConstant.put('Innovation, Sustainovation & VAP', Constant.INNOVATION_AND_SUSTAINOVATION);
	        recordTypeToConstant.put('Monthly Execution Plan', Constant.MONTHLY_EXECUTION_PLAN);
        } else {
        	recordTypeToConstant.put('Planning', Constant.PLANNING);
        }
        
        recordTypes = getRecordTypes();
        	
      	selectedChanell = calendar.Sales_Channel__c;
      	selectedRecordType = calendar.RecordType.name;
      	salesToRecordType();      	
      
    }
    
    public List<selectOption> getRecordTypes()
    {
    	List<SelectOption> options = new List<SelectOption>();          
        for(String rt: recordTypeToConstant.keySet()){
            options.add(new SelectOption(rt, rt));
        }
        return options;
    }
    
    public void salesToRecordType()
    {    	      
       List<SelectOption> options = new List<SelectOption>(); 
       
       options = Service_UserInput.getSalesDrivers(recordTypeToConstant.get(selectedRecordType));
  	  
  	   options.remove(0);
       salesChanells = options;       
    }
    
    public PageReference saveCloneCalendar()
    {
    	Calendar__c cal = calendar.clone(false, true);
    	cal.name = calendarName;
    	cal.Sales_Channel__c = selectedChanell;
    	
    	cal.RecordTypeId = [Select r.Id, r.name From RecordType r WHERE r.Name= :selectedRecordType AND r.SobjectType = 'Calendar__c' LIMIT 1].id;

    	insert cal;
    	
    	if(selectedRecordType != 'Planning'){
        	List<CalendarBrand__c> calendarBrands = [Select Calendar__c, Brand__c From CalendarBrand__c WHERE Calendar__c = :calendarRecord.id];
      		List<Content_Property__c> contentProperty = [Select c.SystemModstamp, c.Sub_Sub_Sub_Category__c, c.Sub_Sub_Category__c, c.Sub_Category__c, c.Start_Date__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.End_Date__c, c.CreatedDate, c.CreatedById, c.Content_Description__c, c.Selling_Materials_Classification_Row_1__c, c.Selling_Materials_Classification_Row_2__c, c.Category__c, c.Calendar__c From Content_Property__c c WHERE Calendar__c = :calendarRecord.id];
      	
      		List<Content_Property__c> contentPropertyClones = new List<Content_Property__c>();
      		
      		for(Content_Property__c c: contentProperty){
           		Content_Property__c cl = c.clone(false, true);
           		cl.Calendar__c = cal.id;
           		contentPropertyClones.add(cl);
           		
        	}        		        	
        	insert contentPropertyClones;
        	
        	List<CalendarBrand__c> calendarBrandsClones = new List<CalendarBrand__c>();
      		
      		for(CalendarBrand__c c: calendarBrands){
           		CalendarBrand__c cb = c.clone(false, true);
           		cb.Calendar__c = cal.id;
           		calendarBrandsClones.add(cb);
           		
        	}        		        	
        	insert calendarBrandsClones;
        	
      		
      	}else{
      		List<File__c> files = [Select f.share_link__c, f.filetype__c, f.filesize__c, f.Video_Id__c, f.Title__c, f.Tags__c, f.SystemModstamp, f.Start_Date__c, f.RTS__c, f.Preview_Id__c, f.Preview_Available__c, f.Portfolio__c, f.Page_Section__c, f.Only_For_Internal_User__c, f.Name, f.LastModifiedDate, f.LastModifiedById, f.Is_Video__c, f.IsDeleted, f.Image_Resolution__c, f.Id, f.Folders__c, f.Folder_Names__c, f.End_Date__c, f.OrgUnits__c, f.Division_Access__c, f.Distributors__c, f.Distributor_Names__c, f.Description__c, f.CreatedDate, f.CreatedById, f.Content_Version_Id__c, f.Content_ID__c, f.Calendar__c, f.Brands__c, f.Brand_Names__c, f.Available_Until__c From File__c f WHERE Calendar__c = :calendarRecord.id];
      		
      		List<File__c> filesClones = new List<File__c>();
      		
      		for(File__c f: files){
           		File__c fi = f.clone(false, true);
           		fi.Calendar__c = cal.id;
           		filesClones.add(fi);
           		
        	}        		        	
        	insert filesClones;
      	}
      	
      	return new PageReference('/'+cal.id);
      	
    	
    }
    
    
  


}