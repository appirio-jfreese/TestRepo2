public with sharing class Controller_NationalAccounts  extends Controller_Base {

	// ******************
	// MAIN & FILTER VIEW
	// ******************

    public Map<String, List<AggregateResult>> contentMap {get; protected set;} // for box/list view
    public MAP<string, List<AggregateResultHolder>> contentHolderMap {
    	get {
    		MAP<string, List<AggregateResultHolder>> contentHolder1 = new MAP<string, List<AggregateResultHolder>>();
    		if(contentMap!=null){
    			for(string key : contentMap.keySet()){
		    		List<AggregateResultHolder> tmpList = new List<AggregateResultHolder>();
		    		for(AggregateResult ar : contentMap.get(key)){
		    			AggregateResultHolder tmp = new AggregateResultHolder();
		    			tmp.result = ar;
		    			tmpList.add(tmp);
		    		}
		    		contentHolder1.put(key,tmpList);
    			}
    		}
    		return contentHolder1;
    	}
    	set;
    }
    
    public Boolean displayAsList {get; set;} // display as list (true) or box (false)
        
    private String mainFoldername = '';
    private List<String> headersTmp = new List<String>();
    public List<String> headers {set;
    	get{
    		List<String> tmp = new List<String>();
    		for(String s : headersTmp){
    			if(contentMap.keySet().contains(s))
    				tmp.add(s);
    		}
    		return tmp;
    	}
    } 
    public Integer contentSize {
    	get {
    		Integer i = 0;
    		if(!contentMap.isEmpty()){
    			for(List<AggregateResult> l : contentMap.values()){
    				if(l != null){
    					i+=l.size();
    				}
    			}
    		}
    		return i;
    	}
    }
    public List<AggregateResult> contentList {
    	get {
    		List<AggregateResult> res = new List<AggregateResult>();
    		if(!contentMap.isEmpty()){
    			for(List<AggregateResult> it : contentMap.values()){
    				res.addAll(it);
    			}
    		}
    		return res;
    	}
    }
        
    public Folder sectionFolders {get; protected set;} // top section buttons
    public Folder subSectionFolders {get; protected set;} // top sub section buttons

    public String currentSection {get; set;}
    public String currentSubSection {get; set;}
    public String requestedFolder {
        get{
            if(currentSubSection != '' && currentSubSection != null){
                return currentSubSection;
            } else {
                return currentSection;
            }
        }
        private set;
    } 
    
	public String nationalAccountsFolderId {
		get {
			return Service_API.getSetting('nationalAccountsFolderId');
		}
		set;
	}
	    
    public String requestedFolderName {
     	get{
     		String fName = 'Not found';
	        if(currentSection != null && currentSection != ''){
	        	for(Folder folder : sectionFolders.dirs){
	        		if(folder.folderId == currentSection){
	        			fName = folder.folderName.replaceAll('<br/>',' ');
	        			break;
	        		}
	        	}
	        }
	        if(currentSubSection != null && currentSubSection != ''){
	        	for(Folder folder : subSectionFolders.dirs){
	        		if(folder.folderId == currentSubSection){
	        			fName = folder.folderName.replaceAll('<br/>',' ');
	        			break;
	        		}
	        	}
	        }
			return fName; 
       	}
	   	set;
	}  
    // brands
	public List<Brand__c> parentBrandList {get; set;}
	public List<Brand__c> additionalBrandList{get; set;}
	public List<Brand__c> childBrandList {get; set;}
	public String parentId {get; set;}
    public String selectedBrandIds {get; set;}
    public String selectedChildBrandIds {get; set;}    
	protected List<Id> selectedBrandIdsList {protected get; protected set;}
    public String brandNumberDescription {get; set;}
    public String selectedBrandName {get; set;}
    
    // portfolio
    public Boolean selectedPortfolio {get; set;} // false
	public Integer brandBoxToRender {get;set;}
	// rts
    public Boolean selectedRTS {get; set;}

    // time period
    public String dateRangeDescription {get; set;}
    protected Service_Calendar calendarMonthView;
    protected Service_Calendar calendarForFilter;
	public List<Map<String, String>> quarterViewsList {public get; public set;}
	public List<Map<String, String>> monthViewsList {public get; public set;}
    public String selectedTimePeriods {get; set;}
	protected List<Integer> selectedTimePeriodsList {protected get; protected set;}
    protected Integer quarterShift {protected get; protected set;}
    protected Integer currentQtr {protected get; protected set;}    
    protected Integer monthShift {protected get; protected set;}
    protected Integer currentMTH {protected get; protected set;}
    public Boolean monthOrQuarterRender {get; set;} // true = Quarter
    
    public Boolean selectAllBrands {public get; public set;}	
	public Boolean selectAllVariants {public get; public set;}  
	public Boolean isFilterSet {public get; protected set;}  
    public Boolean filterByBrand {get; private set;}
    public Boolean filterByTime {get; private set;}
  
	
	// *********
	// VIEW TYPE
	// *********
	
    public Boolean isCalendar {get; private set;}
    public Boolean isExtraCalendar {get; private set;}
 
    	
	// *************
	// CALENDAR VIEW
	// *************
    
    public Boolean isExport {get; private set;}	
    public list<map<String, String>> months {get; protected set;}
    public list<String> salesDriversToShow {get; protected set;}
    public Integer salesDriversToShowCount {get; protected set;}
    public map<String, list<map<String, String>>> programMap {get; protected set;}
    public Integer timePeriod {
        get; 
        set{
            timePeriod = value;
            if (timePeriod>1) {
                span = 3;
            } else {
                span = 1;
            }
            calendarForView.initDateRange(timePeriod, calendarForView.startDate);
        }
    }    
    public Integer span {get; protected set;}
    public map<String, map<String, list<map<String, String>>>> calendarData {get; protected set;}
    public String salesDriver {get;set;}
    private Service_Calendar calendarForView;
    public String startFromDate {get; set;} 
    public String startDate {get; set;} 
    public String endDate {get; set;} 
    public Integer totalSalesDrivers {get; protected set;}
    public String pdfPath {public get; protected set;}
    
    // *******
    // DETAILS 
    //********

    public String detailId {public get; public set;}
    public Calendar__c calendarItem {public get; protected set;}
    public String dateDescription {public get; protected set;}
    public String salesDriverDescription {public get; protected set;}
	public String description {public get; protected set;}
	public String styleBackgroundLogoImage {public get; protected set;}
    public String contentDocumentId {public get;public set;}
	public MAP<string, List<AggregateResult>> detailsMap {public get; protected set;}
	public MAP<string, List<AggregateResultHolder>> detailsHolderMap {
    	get {
    		MAP<string, List<AggregateResultHolder>> contentHolder1 = new MAP<string, List<AggregateResultHolder>>();
    		if(detailsMap!=null){
    			for(string key : detailsMap.keySet()){
		    		List<AggregateResultHolder> tmpList = new List<AggregateResultHolder>();
		    		for(AggregateResult ar : detailsMap.get(key)){
		    			AggregateResultHolder tmp = new AggregateResultHolder();
		    			tmp.result = ar;
		    			tmpList.add(tmp);
		    		}
		    		contentHolder1.put(key,tmpList);
    			}
    		}
    		return contentHolder1;
    	}
    	set;
    }
	
	public MAP<string, string> detailsMapParser {public get; protected set;}
	public MAP<string, Integer> detailsMapSize {public get; protected set;}
	public List<Id> detailsMapOrder {public get; protected set;}
	    
    // ***********
    // CONSTRUCTOR
    // ***********
    
    public Controller_NationalAccounts() {
        if(!isInternalUser){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'You don\'t have access rights to the requested page'));            
            return;
        }
		pageUrl = Page.NationalAccounts.getUrl();
        shareFromContentDescription = false;        
        isExport = false;
        expandFilter = false;
        displayAsList = true;
        subSectionFolders = new Folder('CHILD','CHILD');        
        // sub sections
        currentSection    = '';
        currentSubSection = '';
   		selectedPortfolio = false;
   		selectedRTS = false;

		// **************
		// GET URL PARAMS
		// **************
		try{
			// standard params
			if(ApexPages.currentPage().getParameters().get('section') != null && ApexPages.currentPage().getParameters().get('section') != ''){
				currentSection = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('section'), 'UTF-8');
				if(ApexPages.currentPage().getParameters().get('subsection') != null && ApexPages.currentPage().getParameters().get('subsection') != ''){
					currentSubSection = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('subsection'), 'UTF-8');
				}
			}

        } catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load data from url. '));
			return;        
        }	    
  
    	
	    showContent();
    }
	// ************
	// INIT METHODS
	// ************
	
	private void initStandardView(){
        shareFromContentDescription = false;
		displayAsList = true;
		isFilterSet = false;
        expandFilter = false;
		selectAllBrands = false;
		selectAllVariants = false;
   		selectedPortfolio = false;
   		selectedRTS = false;		
        contentMap = new Map<String, List<AggregateResult>>();
        headersTmp = new List<String>();
        // get brands
        if(siteTheme != 'Wine') {
        	brandBoxToRender = 21;
        } else {
        	brandBoxToRender = 23;
        }
		parentBrandList = Service_API.getBrandsForFilters(new list<String>());
		/**by maciek**/
		Set<Id> setOfBrands = new Set<Id>();
		Integer i = 0;
		for(Brand__c brand : parentBrandList)
		{
			setOfBrands.add(brand.id);
			i++;
			if(i == brandBoxToRender)
			{
				break;
			}
		}
		
		if(i > 0){
			additionalBrandList = Service_API.getAdditionalBrandsForFilters(setOfBrands, new list<String>());
		}
		  
		/*************/
		childBrandList = new list<Brand__c>();		
		brandNumberDescription = 'All';
		dateRangeDescription = 'All Time Periods';
    	selectedBrandIds = '';
    	parentId = '';
    	selectedChildBrandIds = '';
    	selectedTimePeriods = '';
		selectedBrandIdsList = new List<Id>();    		
		// get time periods
		monthOrQuarterRender = true;
        calendarForFilter = new Service_Calendar();
		calendarForFilter.initDateRange(3, null);	// quarter view
		calendarMonthView = new Service_Calendar();
		calendarMonthView.initDateRange(1, null);
		currentQtr = calendarForFilter.fiscalQuarter;
		currentMth = calendarMonthView.fiscalMonth;
		quarterShift = 0;
		monthShift = 0;
		detailId = null;
		initTimePeriods();
	}

	private void initCalendarView(){
        salesDriversToShow = new list<String>();
        programMap = new map<String, list<map<String, String>>>();
        months       = new list<map<String, String>>();
        calendarData = new map<String, map<String, list<map<String, String>>>>();
        calendarForView = new Service_Calendar();
        contentMap = new Map<String, List<AggregateResult>>();   
        headersTmp = new List<String>();     
        timePeriod = 1;
		salesDriver = 'All';
		startFromDate = null;
		totalSalesDrivers = 0;
		detailId = null;
        expandFilter = false;
		try{
			// calendar params			
			calendarForView = new Service_Calendar();
			if(ApexPages.currentPage().getParameters().get('time') != null){
	        	timePeriod = Integer.valueOf(ApexPages.currentPage().getParameters().get('time'));
			} else {
				timePeriod = 1;
			}
            if(ApexPages.currentPage().getParameters().get('date') != null){
                try{
                    startFromDate = ApexPages.currentPage().getParameters().get('date');
                    calendarForView.initDateRange(timePeriod, date.valueOf(startFromDate));
                } catch (Exception e){
                    startFromDate = null;
                }
            } else {
                startFromDate = null;
            }
			if(ApexPages.currentPage().getParameters().get('driver') != null){
	        	salesDriver = ApexPages.currentPage().getParameters().get('driver');
			} else {
				salesDriver = 'All';
			}
			if(ApexPages.currentPage().getParameters().get('export') != null){
				isExport = true;	
			} else {
				isExport = false;
			}			
        } catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load data from url. '));
			return;        
        }
	}
	
	public void showDetails(){
		detailsMap = new MAP<string, List<AggregateResult>>();
		detailsMapParser = new MAP<string,string>();
		detailsMapSize = new MAP<String,Integer>();
		detailsMapOrder = new list<Id>();
        expandFilter = false;

		try {
        	calendarItem = Service_API.getPlanningCalendarItem(detailId,selectedThemes());
        	if(Service_API.getSectionTheme() != calendarItem.classification__c && calendarItem.classification__c != 'Mixed'){
				Service_API.setUserSiteTheme(calendarItem.classification__c, false);
			}
            dateDescription = ''+calendarItem.Start_Date__c.format()+' - '+calendarItem.End_Date__c.format();
            salesDriverDescription = ''+calendarItem.Sales_Channel__c;
            description = calendarItem.Description__c==null?calendarItem.Description__c:calendarItem.Description__c.replaceAll('\n','<br/>');
            if(calendarItem.Logo_Image_Large__r.content_id__c != null) {
                ContentDocument[] cd = [SELECT LatestPublishedVersionId FROM ContentDocument WHERE Id=: calendarItem.Logo_Image_Large__r.content_id__c];
                if (cd != null && cd.size()>0) {
                    styleBackgroundLogoImage = 'background-image: url(/sfc/servlet.shepherd/version/download/' + cd[0].LatestPublishedVersionId + ');';
                }
            }
            List<Folder__c> sliderTabs = Service_API.getChildFolders(requestedFolder);
            List<ID> foldersIds = new List<ID>();
            for(Folder__c folder : sliderTabs){
            	//if(folder.is_header__c != true){
	            	detailsMapOrder.add(folder.Id);
					foldersIds.add(folder.Id);
					detailsMap.put(folder.Id, new List<AggregateResult>() );
					detailsMapParser.put(folder.Id,folder.Name);
					detailsMapSize.put(folder.Id, 0);
            	//}
            }
            if(!foldersIds.isEmpty()){
	            String foldersIdsString = IdListToString(foldersIds);

				List<File__c> contentCalendarItems = [SELECT Id, Name, Folders__c, Is_video__c, Video_id__c, Title__c, Description__c, Content_Version_Id__c, filetype__c, Preview_Available__c, Preview_Id__c, filesize__c, LastModifiedDate, Image_resolution__c 
	           			FROM File__c 
	                	WHERE page_section__c= :Constant.PLANNING AND Calendar__c = :detailId limit 1000 ];
	            MAP<string, string> folderAssignedMap = new MAP<string, string>();
				for(File__c ccItem : contentCalendarItems){
					folderAssignedMap.put(ccItem.Id, ccItem.Folders__c);
				}
		
				List<AggregateResult> tmpList = database.query('Select Id, Is_video__c is_video, Video_id__c video_id, Title__c title, Description__c description, Content_Version_Id__c cvid, filetype__c filetype, Preview_Available__c previewAvailable, Preview_Id__c previewId, filesize__c filesize, max(Uploaded_date__c) createdDate, Image_resolution__c imageRes ' +
					+' FROM File__c ' + 
        			+' WHERE Classification__c includes (\''+Service_API.getSectionTheme()+'\') and page_section__c=\'' + Constant.PLANNING + '\' and Calendar__c=\''+detailId+'\' AND Folders__c includes (' + foldersIdsString + ') ' +
        			+' GROUP BY Id, Is_video__c, Video_id__c, Title__c, Description__c, Content_Version_Id__c, filetype__c, Preview_Available__c, Preview_Id__c, filesize__c, Image_resolution__c'+ 
        			+' ORDER BY Description__c ASC limit 1000');

				isNewContent = false;
	            for(AggregateResult ar : tmpList){
        			string fileId = (string)ar.get('Id');
	                String dateString = String.valueOf(ar.get('createdDate'));
	                DateTime itemTime = datetime.valueOf(dateString);
	                if(lastLoginDate < itemTime){
	                    isNewContent = true;
	                }   
        			if(folderAssignedMap.containsKey(fileId)){
	        			string assignedToFolders = folderAssignedMap.get(fileId);
	        			List<string> assignedToFoldersList = assignedToFolders.split(';');
	        			for(String addToFolderWithId : assignedToFoldersList){
	        				if(detailsMap.containsKey(addToFolderWithId)){
				            	List<AggregateResult> tempList = detailsMap.get(addToFolderWithId);
								tempList.add(ar);
				            	detailsMap.put(addToFolderWithId, tempList);
				            	detailsMapSize.put(addToFolderWithId, tempList.size());
	        				}
	        			}
        			}
	            }
            }
            prepareBreadcrumbs();
		} catch( Exception err ){
          	detailId = null;
			detailsMap = new MAP<string, List<AggregateResult>>();
			detailsMapSize = new MAP<String,Integer>();
			detailsMapParser = new MAP<string,string>();
			detailsMapOrder = new list<Id>();
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load details.'));
            return;
        }
	}	
	public void clearDetailsCalendar(){
		detailId = null;
     	calendarItem = null;
        dateDescription = null;
        salesDriverDescription = null;
        description = null;
		detailsMap = new MAP<string, List<AggregateResult>>();
		detailsMapSize = new MAP<String,Integer>();
		detailsMapParser = new MAP<string,string>();
		detailsMapOrder = new list<Id>();
        prepareBreadcrumbs();
        expandFilter = false;
	}
	
    // **********************
    // MAIN & FILTERS METHODS
    // **********************
    
    public void showContent() {
        expandFilter = false;
        try{
        	if(Test.isRunningTest()){
	              initCalendarView();
	              setMonths();
	              getMonthName(2012,1);
	              populateData();
            }
        	
            List<Folder__c> folders = Service_API.getPlanningFolders();
            sectionFolders = new Folder('PARENT','PARENT');
            subSectionFolders = new Folder('CHILD','CHILD');
            filterByBrand = false;
            filterByTime = false;
            isCalendar = false;
			isExtraCalendar = false;
            for(Folder__c folder : folders){
                if(folder.Parent_Folder__c == nationalAccountsFolderId){
                    Folder folderObject = new Folder(folder.Id, folder.Name, folder.Allow_File_Upload__c, folder.Allow_Add_Comment__c, folder.Filter_By_Brand__c, folder.Filter_By_Time__c);
                    sectionFolders.addToFolder(folderObject);
                    if(currentSection == '' || currentSection == null){
                        system.debug('------missing section');
                        currentSection = folder.Id;
                    }
                    if(Id.valueOf(currentSection) == folder.Id){
                    	system.debug('------folder: '+folder);
                        filterByBrand = folder.Filter_By_Brand__c;
                        filterByTime = folder.Filter_By_Time__c;
                        if(folder.Layout_Type__c == CONSTANT.PLANNING_STANDARD || folder.Layout_Type__c == '' || folder.Layout_Type__c == null){
                        	isCalendar = false;
                        	isExtraCalendar = false;
							initStandardView();
                        } else {
							initCalendarView();
							isCalendar = true;
							if(folder.Layout_Type__c == CONSTANT.PLANNING_CALENDAR){
								isExtraCalendar = true;
							} else {
								isExtraCalendar = false;							
							}
            				filterByBrand = false;
            				filterByTime = false;
                        } 
                    }
                }
            }
            if(!isCalendar && currentSection != null && currentSection !=''){
	            for(Folder__c folder : folders){
					if(folder.Parent_Folder__c != null){
//	                if(folder.Parent_Folder__c != null && folder.is_header__c != true){                
	                    if(folder.Parent_Folder__c == Id.valueOf(currentSection)){
	                        Folder folderObject = new Folder(folder.Id, folder.Name, folder.Allow_File_Upload__c, folder.Allow_Add_Comment__c, folder.Filter_By_Brand__c, folder.Filter_By_Time__c);
	                        subSectionFolders.addToFolder(folderObject);
	                        if(currentSubSection == '' || currentSubSection == null){
	                            currentSubSection = folder.Id;
	                        }
	                        if(Id.valueOf(currentSubSection) == folder.Id){
		                        filterByBrand = folder.Filter_By_Brand__c;
		                        filterByTime = folder.Filter_By_Time__c;
		                        if(folder.Layout_Type__c == CONSTANT.PLANNING_STANDARD || folder.Layout_Type__c == '' || folder.Layout_Type__c == null){
		                        	isCalendar = false;
                        			isExtraCalendar = false;
									initStandardView();
		                        } else {
									initCalendarView();
		                        	isCalendar = true;
									if(folder.Layout_Type__c == CONSTANT.PLANNING_CALENDAR){
										isExtraCalendar = true;
									} else {
										isExtraCalendar = false;							
									}
	    	        				filterByBrand = false;
		            				filterByTime = false;
		                        } 
	                        }
	                    }
	                }
	            }
            }

            if(!filterByBrand){ // no brand filters
		    	selectedBrandIds = '';
		    	parentId = '';
		    	selectedChildBrandIds = '';    	
		    	selectAllBrands = false;
		    	selectAllVariants = false;
				selectedBrandIdsList = new List<Id>();
				brandNumberDescription = 'All';
				parentBrandList = Service_API.getBrandsForFilters(new list<String>());
				/**by maciek**/
				Set<Id> setOfBrands = new Set<Id>();
				Integer i = 0;
				for(Brand__c brand : parentBrandList)
				{
					setOfBrands.add(brand.id);
					i++;
					if(i == brandBoxToRender)
					{
						break;
					}
				}
				
				if(i > 0){
					additionalBrandList = Service_API.getAdditionalBrandsForFilters(setOfBrands, new list<String>());
				}
				  
				/*************/
				childBrandList = new list<Brand__c>();
            }
            if(!filterByTime){ // no time filter
		    	selectedTimePeriods = '';
				selectedTimePeriodsList = new List<Integer>();
				dateRangeDescription = 'All Time Periods';
            }
            if(!filterByBrand && !filterByBrand){ // no filters
				isFilterSet = false;
            }

            initPager();
            refreshPageContent();
            prepareBreadcrumbs();
        } catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load sections.'));
            return;
        }
    }

    // switch section
    public void switchSection() {
        currentSubSection = '';
        showContent();  
        initPager();
        prepareBreadcrumbs();
        refreshPageContent();   
        expandFilter = false;
		system.debug('sbfolder');        
        system.debug(subSectionFolders);
        system.debug(isCalendar);        
    }    

    // switch subSection
    public void switchSubSection() {
        showContent();
        initPager();
        prepareBreadcrumbs();
        refreshPageContent();       
        expandFilter = false;
    } 
    
    public void switchToMonthView(){
    	monthOrQuarterRender = false;
    	initTimePeriods();
    	selectedTimePeriods = '';
		selectedTimePeriodsList = new List<Integer>();
		dateRangeDescription = 'All Time Periods';
	    refreshPageContent();
    }
    
    public void switchToQuarterView(){
    	monthOrQuarterRender = true;
    	selectedTimePeriods = '';
		selectedTimePeriodsList = new List<Integer>();
		dateRangeDescription = 'All Time Periods';
	    initTimePeriods();
	    refreshPageContent();
    }
    
    public void renderAsList() {
        displayAsList = true; // other action if needed
        prepareBreadcrumbs();   
        expandFilter = false;
    }   

    public void renderAsBox() {
        displayAsList = false; // other action if needed        
        prepareBreadcrumbs();
        expandFilter = false;
    }

    public void renderAsListSlider() {
        displayAsList = true; // other action if needed
        prepareBreadcrumbs();   
        expandFilter = false;
    }  
    public void renderAsBoxSlider() {
        displayAsList = false; // other action if needed        
        prepareBreadcrumbs();
        expandFilter = false;
    }
    
	// init time periods for time filter
    private void initTimePeriods() {
    	try{
			quarterViewsList = Service_UserInput.getQuarterOptions(calendarForFilter.fiscalQuarter, calendarForFilter.fiscalYear, calendarForFilter.startDate);
   			monthViewsList = Service_UserInput.getMonthsOptions(calendarMonthView);
		} catch( Exception err ){
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to init time periods.'));
			return;
		}
    }

	// filter: next time periods    
    public void nextPeriod() {
    	try{
			if(monthOrQuarterRender){
				calendarForFilter.incrementQuarter(1);
				quarterShift++;
				selectedTimePeriods = '';
				validselectedTimePeriodsList();
		        initTimePeriods();
		        refreshPageContent();      
		        expandFilter = false;
			} else {//month
				calendarMonthView.incrementMonth(3);
				monthShift = monthShift + 3;
				selectedTimePeriods = '';
				validselectedTimePeriodsList();
		        initTimePeriods();
		        refreshPageContent();
				expandFilter = false;
			}
		} catch( Exception err ){
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to switch time period.'));
			return;
		}
    }   

	// filter: prev time periods
    public void previousPeriod() {
    	try{
			if(monthOrQuarterRender){
				calendarForFilter.incrementQuarter(-1);
				quarterShift--;
				selectedTimePeriods = '';
				validselectedTimePeriodsList();
		        initTimePeriods();
		        refreshPageContent();      
		        expandFilter = false;
			} else {
				calendarMonthView.incrementMonth(-3);
				monthShift = monthShift - 3;
				selectedTimePeriods = '';
				validselectedTimePeriodsList();
		        initTimePeriods();
		        refreshPageContent();
				expandFilter = false;
			}
		} catch( Exception err ){
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to switch time period.'));
			return;
		}			
    }

	// reset filters
	public void resetFilter(){
		isFilterSet = false;		
    	selectedBrandIds = '';
    	parentId = '';
    	selectedTimePeriods = '';
    	selectedPortfolio = false;
		selectedRTS = false;
    	selectedChildBrandIds = '';    	
    	selectAllBrands = false;
    	selectAllVariants = false;
		selectedBrandIdsList = new List<Id>();
		selectedTimePeriodsList = new List<Integer>();
		brandNumberDescription = 'All';
		dateRangeDescription = 'All Time Periods';
		parentBrandList = Service_API.getBrandsForFilters(new list<String>());
		/**by maciek**/
		Set<Id> setOfBrands = new Set<Id>();
		Integer i = 0;
		for(Brand__c brand : parentBrandList)
		{
			setOfBrands.add(brand.id);
			i++;
			if(i == brandBoxToRender)
			{
				break;
			}
		}
		
		if(i > 0){
			additionalBrandList = Service_API.getAdditionalBrandsForFilters(setOfBrands, new list<String>());
		}
		  
		/*************/
		childBrandList = new list<Brand__c>();
		initPager();
		refreshPageContent();
        expandFilter = true;
	}
    
    // update filter variant brands
    public void updateVariantBrands() {
    	if(parentId != null && parentId != ''){
			childBrandList = Service_API.getChildBrands(parentId);
    		selectedChildBrandIds = '';
			selectedBrandName = [select Name from Brand__c where id = :parentId].Name;    		
			selectAllVariants = false;		
    	} else {
			childBrandList = new list<Brand__c>();
    		selectedChildBrandIds = '';
			selectAllVariants = false;
			parentId = '';	
    	}
        expandFilter = false;
    }
    
    // clear selected variant brands
    public void clearVariantBrandsSelected() {
		selectedChildBrandIds = '';
		selectAllVariants = false;	
        expandFilter = false;
    }
    
    // clear variant brand filter list -> more then one parent brand selected
    public void clearVariantBrands() {
  		childBrandList = new list<Brand__c>();      	
		selectedChildBrandIds = '';
		parentId = '';
		selectAllVariants = false;		
        expandFilter = false;
    }
    
    // set filter
    public void changeFilter(){
		selectedBrandIdsList = new List<Id>();
		isFilterSet = true;
		List<Id> tempSelectedBrandIdsList = new List<Id>();
		List<Id> tempSelectedChildBrandIdsList = new List<Id>();
		
    	String glue = '';
    	Integer brandsNo = null;

		// validate parent brand ids
    	if(selectedBrandIds != null && selectedBrandIds != ''){
			List<String> brandIdsListTemp = new List<String>();
			brandIdsListTemp = selectedBrandIds.split(',');
	    	for(String selectedId : brandIdsListTemp){
	    		if(selectedId != null && selectedId != ''){
	    			tempSelectedBrandIdsList.add(Id.valueOf(selectedId));
	    		}
	    	}
	    	glue = '';
			selectedBrandIds = '';
			for (Id id : tempSelectedBrandIdsList) {         
				selectedBrandIds += glue + id;
				glue = ',';
			}    	
    	}

		// validate parent brand ids
    	if(selectedChildBrandIds != null && selectedChildBrandIds != ''){
			List<String> childBrandIdsListTemp = new List<String>();
			childBrandIdsListTemp = selectedChildBrandIds.split(',');
	    	for(String selectedId : childBrandIdsListTemp){
	    		if(selectedId != null && selectedId != ''){
	    			tempSelectedChildBrandIdsList.add(Id.valueOf(selectedId));
	    		}
	    	}
	    	glue = '';
	    	selectedChildBrandIds = '';
	    	for (Id id : tempSelectedChildBrandIdsList) {         
				selectedChildBrandIds += glue + id;
				glue = ',';
			}    	
    	}

		brandsNo = tempSelectedBrandIdsList.size();
		
		selectedBrandName = null;
		if(brandsNo == 1){
			selectedBrandName = [select Name from Brand__c where id =: tempSelectedBrandIdsList[0]].Name;
		}

    	if(tempSelectedBrandIdsList.size() == 1 && !tempSelectedChildBrandIdsList.isEmpty()){
    		selectedBrandIdsList.addAll(tempSelectedChildBrandIdsList);
    	} else if(tempSelectedBrandIdsList.size() == 1 && tempSelectedChildBrandIdsList.isEmpty()){
    		selectedBrandIdsList.addAll(tempSelectedBrandIdsList);    		
    	} else {
    		selectedBrandIdsList.addAll(tempSelectedBrandIdsList);
    	}
		system.debug('selectedBrandIdsList'+selectedBrandIdsList);
		if(selectedBrandIdsList.isEmpty()){
			brandNumberDescription = 'All';
		} else {
			brandNumberDescription = ''+brandsNo;
		}
		initPager();
    	refreshPageContent();
        expandFilter = false;
    }        

	// refresh box/list content
    public override void refreshPageContent() {
		String queryString = '';
		list<String> cl;
    	if(isCalendar){
	        try{    		
		        salesDriversToShow.clear();
		        programMap.clear();
		        //display all or only selected sales driver
		        totalSalesDrivers = 0;
		        list<SelectOption> planningDrivers = Service_UserInput.getSalesDrivers(selectedThemes(), CONSTANT.PLANNING);
		        for (SelectOption o : planningDrivers){
		            if ((salesDriver == 'All' && o.getLabel() != 'All') || (salesDriver != 'All' && o.getLabel()==salesDriver)){
		                salesDriversToShow.add(o.getLabel());
		                programMap.put(o.getLabel(), new list<map<String, String>>{new map<String, String>{'className' => 'empty', 'label' => ''}});
		            }
		        }
				totalSalesDrivers = planningDrivers.size();
		        salesDriversToShowCount = salesDriversToShow.size();
		        setMonths();
				startFromDate = calendarForView.startDate.year() + '-' + calendarForView.startDate.month() + '-01';
				startDate = calendarForView.startDate.format();
				endDate = calendarForView.endDate.format();
				pdfPath = Page.NationalAccountsPdf.getUrl()+'?section='+currentSection+'&export=true&time='+timePeriod+'&driver='+salesDriver+'&date='+calendarForView.startDate.year()+'-'+calendarForView.startDate.month()+'-'+calendarForView.startDate.day()+'&'+parseSelectedThemesToUrl();
	        } catch( Exception err ){
	            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load content.'));
	            return;
	        }
    	} else {
    		isExport = false;
	        try{
	        	List<AggregateResult> content = new List<AggregateResult>();
				contentMap = new Map<String, List<AggregateResult>>();
				headersTmp = new List<String>();
				Set<ID> brandIdsSet = new Set<Id>();
		
				String brands = null;
				if(!selectedBrandIdsList.isEmpty()) {
					brands = IdListToString(selectedBrandIdsList);
				}
		
				String quarterViewSelect = '';
				
				dateRangeDescription = 'All Time Periods';	
		
				validselectedTimePeriodsList();
		
				// no filers
				if(selectedTimePeriodsList.isEmpty() && !selectedPortfolio && !selectedRTS && selectedBrandIdsList.isEmpty()){
                    // setup default time period
                    String orGlue = '';
                    quarterViewSelect = ' and ( ';
                    String[] tmpQuarters = new String[]{};
                    Service_Calendar[] tmpData = new Service_Calendar[]{};
                    if(monthOrQuarterRender){
                        for(Integer qtr=0; qtr<4; qtr++){
                            Service_Calendar subCalendar = new Service_Calendar();
                            subCalendar.initDateRange(3, null); // quarter view
                            subCalendar.incrementQuarter(qtr);
                            quarterViewSelect += orGlue + ' ( ';
                            quarterViewSelect += ' Start_Date__c <= '+datetime.newInstance(subCalendar.endDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')+' and End_Date__c >= '+datetime.newInstance(subCalendar.StartDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')+' ';
                            quarterViewSelect += ' ) ';
                            orGlue = ' or ';
                        }
                    } else {
                        for(Integer qtr=0; qtr<12; qtr++){
                            Service_Calendar subCalendar = new Service_Calendar();
                            subCalendar.initDateRange(1, null); // month view
                            subCalendar.incrementMonth(qtr);
                            quarterViewSelect += orGlue + ' ( ';
                            quarterViewSelect += ' Start_Date__c <= '+datetime.newInstance(subCalendar.endDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')+' and End_Date__c >= '+datetime.newInstance(subCalendar.StartDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')+' ';
                            quarterViewSelect += ' ) ';
                            orGlue = ' or ';
                        }
                    }               
                    quarterViewSelect += ' ) ';
                }
		
				if(!selectedTimePeriodsList.isEmpty()){
					String orGlue = '';
					quarterViewSelect = ' and ( ';
					String[] tmpQuarters = new String[]{};
					Service_Calendar[] tmpData = new Service_Calendar[]{};
					if(monthOrQuarterRender){
						for(Integer qtr : selectedTimePeriodsList){
							Service_Calendar subCalendar = new Service_Calendar();
							subCalendar.initDateRange(3, null);	// quarter view
							subCalendar.incrementQuarter(qtr + quarterShift);
							quarterViewSelect += orGlue + ' ( ';
							quarterViewSelect += ' Start_Date__c <= '+datetime.newInstance(subCalendar.endDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')+' and End_Date__c >= '+datetime.newInstance(subCalendar.StartDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')+' ';
							quarterViewSelect += ' ) ';
							orGlue = ' or ';
							tmpQuarters.add(String.valueOf(subCalendar.fiscalQuarter));
							tmpData.add(subCalendar);
						}
					} else {
						for(Integer qtr : selectedTimePeriodsList){
							Service_Calendar subCalendar = new Service_Calendar();
							subCalendar.initDateRange(1, null);	// month view
							subCalendar.incrementMonth(qtr + monthShift);
							quarterViewSelect += orGlue + ' ( ';
							quarterViewSelect += ' Start_Date__c <= '+datetime.newInstance(subCalendar.endDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')+' and End_Date__c >= '+datetime.newInstance(subCalendar.StartDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')+' ';
							quarterViewSelect += ' ) ';
							orGlue = ' or ';
							tmpData.add(subCalendar);
						}
											
					}
					quarterViewSelect += ' ) ';
					dateRangeDescription = '';
					String glue = '';
					if(monthOrQuarterRender){
			            SelectValues__c[] svs = [SELECT SelectValue__c, SelectSubValue__c FROM SelectValues__c WHERE SelectSubValue__c in: tmpQuarters AND SelectName__c = 'QuarterView'];
		                map<String,String> names = new map<String,String>();
			            for (SelectValues__c sv:svs) {
			            	names.put(sv.SelectSubValue__c, sv.SelectValue__c.toUpperCase());
			            }
						for (Service_Calendar sc : tmpData) {
							dateRangeDescription += glue + names.get(String.valueOf(sc.fiscalQuarter)) + ' ' + sc.startDate.year() + ' (FY' + String.valueOf(sc.fiscalYear).substring(2,4)+')';
							glue = ', ';
						}
					} else {
						for (Service_Calendar sc : tmpData) {
							dateRangeDescription += glue + getMonthName(sc.startDate.year(), sc.startDate.month()) + ' (FY' + String.valueOf(sc.fiscalYear).substring(2,4)+')';
							glue = ', ';
						}
					}
				}

				if(requestedFolder != ''  && requestedFolder != null){
	                
	                numberOfItems = 0;
	                List<Folder__c> folders = [select Id, Name from Folder__c where (Id = :requestedFolder) or (Parent_Folder__c = :requestedFolder and Page_Section__c = :CONSTANT.PLANNING and is_header__c = true and Classification__c includes (:Service_API.getSectionTheme())) order by Order__c asc];
	                queryString = 'select id, Content_Version_Id__c cvid, Description__c description, filesize__c filesize, filetype__c filetype, Title__c  title, is_video__c is_video, video_id__c video_id, Preview_Available__c previewAvailable, Preview_Id__c previewId, max(Uploaded_date__c) createdDate, image_resolution__c imageRes ' + 
	                       ' from File__c ' +
	                       ' where Classification__c includes (\''+Service_API.getSectionTheme()+'\') and (Available_Until__c >= TODAY or Available_Until__c = null) and (Page_Section__c = \'' + CONSTANT.PLANNING + '\' and ( Folders__c includes (\''+requestedFolder+'\')';
		            for(Folder__c folder : folders){
		             	queryString += ' or Folders__c includes (\''+folder.id+'\')';
		            }
		            queryString += '))';
	                
	                cl = new list<String>();
					
			        if (!selectedPortfolio && !selectedRTS && selectedBrandIdsList.isEmpty()) {
			        	if(siteTheme != 'Wine'){
							cl.add(' ( Portfolio__c=true and Classification__c includes (\''+Service_API.getSectionTheme()+'\')  ) ');		
				           	String RTSBrands = '';
							List<Brand__c> rtsBrandList = Service_API.getRTSBrands();
							for(Brand__c rtsBrand : rtsBrandList){
								RTSBrands += (RTSBrands != '') ? ',' : '';
								RTSBrands += '\''+rtsBrand.id+'\'';
							}
							cl.add(' ( RTS__c=true ) ');							
							if(rtsBrandList.size() != 0){
								cl.add(' (Brands__c includes ('+RTSBrands+') )');//or
							}
			        	}
			        	
						String brandys = '';
			           	List<Brand__c> brandy = Service_API.getBrandsForFilters(new list<String>());
			           	for(Brand__c b : brandy){
							brandys += (brandys != '') ? ',' : '';
							brandys += '\''+b.id+'\'';
						}	            	

						if(brandy.size() != 0){
							cl.add(' (Brands__c includes ('+brandys+') OR Brands__c = null )');
						}							
					}						
						
					if(!selectedBrandIdsList.isEmpty()){
						cl.add(' ( Brands__c includes ('+brands+') ) ');
					}
			        if (selectedPortfolio && siteTheme != 'Wine') {
						cl.add(' ( Portfolio__c=true and Classification__c includes (\''+Service_API.getSectionTheme()+'\')  ) ');			            	
				    }
			        if (selectedRTS && siteTheme != 'Wine') {
			           	String RTSBrands = '';
						List<Brand__c> rtsBrandList = Service_API.getRTSBrands();
						for(Brand__c rtsBrand : rtsBrandList){
							RTSBrands += (RTSBrands != '') ? ',' : '';
							RTSBrands += '\''+rtsBrand.id+'\'';
						}
						cl.add(' ( RTS__c=true ) ');							
						if(rtsBrandList.size() != 0){
							cl.add(' (Brands__c includes ('+RTSBrands+') )');//or
						}							
					}					
					if(cl.size() > 0){
						String cGlue = '';
						queryString+=' AND (';
						for(String c : cl){
							queryString += cGlue + ' ' + c;
							cGlue = ' OR ';
						}
						queryString+=')';
					}
						 
					queryString += quarterViewSelect;                       
		            queryString += ' GROUP BY id, Content_Version_Id__c, Description__c, filesize__c, filetype__c, Title__c, is_video__c, video_id__c, Preview_Available__c, Preview_Id__c, image_resolution__c ORDER BY Description__c ASC';
	                content= database.query(queryString);
	                List<Id> fids = new List<Id>();
	                for(AggregateResult ar : content){
	                	fids.add((Id)ar.get('id'));
	                }
	                List<File__c> filesWithFolders = [select id, Folders__c from File__c where id in :fids];
	                Map<id, list<id>> fileToFolders = new Map<id, list<id>>();
	                for(File__c file : filesWithFolders){
	                	if(file.Folders__c == null || file.Folders__c == '')
	                		continue;
	                	list<id> tmp = new list<id>();
	                	if(file.Folders__c != null){
		                	for(String s : file.Folders__c.split(';')){
		                		tmp.add((id)s);
		                	}
	                	}
	                	fileToFolders.put(file.id, tmp);
	                }
	                Map<id, String> folderIdToName = new Map<id, String>();
	                for(Folder__c folder : folders){
	                	folderIdToName.put(folder.id, folder.Name);
	                }
	                for(AggregateResult ar : content){
	                	List<Id> tmpl = fileToFolders.get((Id)ar.get('id'));
	                	if(tmpl == null)
	                		continue;
	                	for(Id fid : tmpl){
	                		String fname = folderIdToName.get(fid);
	                		if(fname == null)
	                			continue;
	                		List<AggregateResult> tmp = contentMap.get(fname);
	                		tmp = (tmp == null) ? (new List<AggregateResult>()) : tmp;
	                		tmp.add(ar);
	                		contentMap.put(fname, tmp);
	                		numberOfItems++;
	                		if(fid == requestedFolder)
	                			mainFoldername = fname;
	                	}
	                }
	                for(Folder__c folder : folders){
	                	if(contentMap.keySet().contains(folder.Name))
	                		headersTmp.add(folder.Name);
	                }
	                
		            if(!contentMap.isEmpty()){
		              	contentMap = getRequestedPageForMap(contentMap, headers);
		            } else {
						numberOfItems = 0; 
		            }
	            } else {
	                numberOfItems = 0;          
	            }
         	
         	currentBasketIds = Service_Basket.getBasketIds();
			currentFollowIds = Service_Notification.getFollowIds();
         	
	        } catch( Exception err ){
	            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load content.'));
	            return;
	        }
        
    	}
    }
    
    // prepare breadcrumbs 
    private void prepareBreadcrumbs(){

        cleanBreadcrumbs();
        String currentPageUrl = Page.NationalAccounts.getUrl();
        addBreadcrumbItem(currentPageUrl, Constant.NATIONAL_ACCOUNTS);

        if(displayAsList){
            currentPageUrl += '?displayas=list';
        } else {
            currentPageUrl += '?displayas=box';
        }

        if (currentSection != null && currentSection != '') {
            for (Folder folder : sectionFolders.dirs) {
                if (folder.folderId == currentSection) {
                    currentPageUrl += '&section='+folder.folderId;
                    addBreadcrumbItem(currentPageUrl, folder.folderName);
                    break;
                }
            }
        }

        if (currentSection != null && currentSection != '' && currentSubSection != null && currentSubSection != '') {
            for (Folder folder : subSectionFolders.dirs) {
                if (folder.folderId == currentSubSection) {
                    currentPageUrl += '&subsection='+folder.folderId;
                    addBreadcrumbItem(currentPageUrl, folder.folderName);
                    break;
                }
            }
        }
     
        if(detailId != null && detailId != '' && calendarItem != null){
        	addBreadcrumbItem('#', calendarItem.name);
        }
    }

	// validation: quarter list
    private List<Integer> validselectedTimePeriodsList(){
		List<String> quarterListTemp = new List<String>();
		selectedTimePeriodsList = new List<Integer>();
		if(selectedTimePeriods == null || selectedTimePeriods == ''){
			selectedTimePeriods = '';
			return selectedTimePeriodsList;
		}
		quarterListTemp = selectedTimePeriods.split(',');
	    if(monthOrQuarterRender){
		    for(String selectedQtr : quarterListTemp){
		    	if(selectedQtr != null && selectedQtr != ''){
		    		Integer tempQtr = Integer.valueOf(selectedQtr);
		    		if(tempQtr >= 0 && tempQtr <= 3){
		    			selectedTimePeriodsList.add(tempQtr);
		    		}
		    	}
		    }
	    } else {
	    	for(String selectedQtr : quarterListTemp){
		    	if(selectedQtr != null && selectedQtr != ''){
		    		Integer tempQtr = Integer.valueOf(selectedQtr);
		    		if(tempQtr >= 0 && tempQtr <= 11){
		    			selectedTimePeriodsList.add(tempQtr);
		    		}
		    	}
		    }
	    }

    	String validselectedTimePeriodsString = '';
    	String glue = '';
		for (Integer qtr : selectedTimePeriodsList) {         
			validselectedTimePeriodsString += glue + qtr;
			glue = ',';
		}    	
	    
	    selectedTimePeriods =  ',' + validselectedTimePeriodsString + ',';
	    return selectedTimePeriodsList;
	}
    // *********************
    // CALENDAR VIEW METHODS
    // *********************
    
    public void nextMonth() {
    	try {
	        calendarForView.incrementDates(timePeriod);
	        refreshPageContent();      
	        expandFilter = false;
       	} catch( Exception err ){
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to change month.'));
			return;
		}	        
    }   
     
    public void previousMonth() {
    	try {    	
	        calendarForView.incrementDates(-timePeriod);
	        refreshPageContent();      
	        expandFilter = false;
       	} catch( Exception err ){
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to change month.'));
			return;
		}	
    }   

    public List<SelectOption> getTimePeriods() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1','Monthly View'));
        options.add(new SelectOption('3','Quarterly View'));
        options.add(new SelectOption('6','6 Month View'));
        options.add(new SelectOption('12','12 Month View'));
        return options;
    }

    public List<SelectOption> getSalesDrivers() {
        return Service_UserInput.getSalesDrivers(selectedThemes(), CONSTANT.PLANNING);
    }

    public void selectSalesDriver() {
        refreshPageContent();
        expandFilter = false;
    }
    
    public void setStartDateValue() {
    	if (startFromDate != null) {
            calendarForView.initDateRange(timePeriod, Date.valueOf(startFromDate));
            refreshPageContent();
    	}
        expandFilter = false;
    }    
    
    private void setMonths() {
        months.clear();
        populateData();
        for (Integer i=0; i<timePeriod; i++) {
            Date tmpDate = calendarForView.startDate.addMonths(i);
            map<String, String> tmpMap = new map<String, String>{
                'name'       => getMonthName(tmpDate.year(), tmpDate.month()),
                'showArrows' => i==0?'':'none',
                'data'       => calendarData.containsKey(tmpDate.year()+'-'+tmpDate.month())?tmpDate.year()+'-'+tmpDate.month():'empty'
            };
            months.add(tmpMap);
        }
    }
    
    private String getMonthName(Integer year, Integer month) {
        String result;
        if (month==1) {
            result = 'January';
        } else if (month==2) {
            result = 'February';
        } else if (month==3) {
            result = 'March';
        } else if (month==4) {
            result = 'April';
        } else if (month==5) {
            result = 'May';
        } else if (month==6) {
            result = 'June';
        } else if (month==7) {
            result = 'July';
        } else if (month==8) {
            result = 'August';
        } else if (month==9) {
            result = 'September';
        } else if (month==10) {
            result = 'October';
        } else if (month==11) {
            result = 'November';
        } else if (month==12) {
            result = 'December';
        }
        return result + ' ' + year;
    }
    
    private void populateData(){
        calendarData.clear();
        List<Calendar__c> cRecords = Service_API.getPlanningCalendarItems(calendarForView.startDate, calendarForView.endDate, salesDriver, requestedFolder, selectedThemes());
        List<Calendar__c> cRecordsOrderCurrent = new List<Calendar__c>();
        List<Calendar__c> cRecordsOrderMixed = new List<Calendar__c>();
        List<Calendar__c> cRecordsOrderOther = new List<Calendar__c>();
        for(Calendar__c c : cRecords){
        	if(c.classification__c == siteTheme){
        		cRecordsOrderCurrent.add(c);
        	} else if(c.classification__c == 'Mixed'){
        		cRecordsOrderMixed.add(c);
        	} else {
        		cRecordsOrderOther.add(c);
        	}
        } 
        cRecords.clear();
        cRecords.addAll(cRecordsOrderCurrent);
        cRecords.addAll(cRecordsOrderMixed);
        cRecords.addAll(cRecordsOrderOther);
        for (Integer i = 0; i < timePeriod; i++){
            Date tmpDate = calendarForView.startDate.addMonths(i);
            map<String,list<map<String, String>>> tmpMonthData = new map <String, list<map<String, String>>>();
            for (String p: salesDriversToShow) {
                list<map<String, String>> tmpProgramData = new list<map<String, String>>();
                for(Calendar__c c : cRecords){
                    if(c.sales_channel__c == p && (c.start_date__c.month() == tmpDate.month() || c.end_date__c.month() == tmpDate.month() ||
                    (c.start_date__c.month() < tmpDate.month() && c.end_date__c.month() >= tmpDate.month()))){
                        String styleBackgroundColor ='';
                        String styleBackgroundImage ='';
                        String styleTextColor       ='';
                        if (isExport){
                        	styleBackgroundColor = 'background-color: #' + c.background_color__c + ';';
                        } else {
	                        if (c.background_color__c != null && c.background_color2__c == null) {
	                            styleBackgroundColor = 'background-color: #' + c.background_color__c + ';';
	                        } else if (c.background_color__c != null && c.background_color2__c != null) {
	                        	styleBackgroundColor = 'background: #' + c.background_color__c + ';';
	                        	styleBackgroundColor += 'background: -moz-linear-gradient(top, #' + c.background_color__c + ' 0%, #' + c.background_color2__c + ' 100%);';
	                        	styleBackgroundColor += 'background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#' + c.background_color__c + '), color-stop(100%,#' + c.background_color2__c + '));';
	                        	styleBackgroundColor += 'background: -webkit-linear-gradient(top, #' + c.background_color__c + ' 0%,#' + c.background_color2__c + ' 100%);';
	                        	styleBackgroundColor += 'background: -o-linear-gradient(top, #' + c.background_color__c + ' 0%,#' + c.background_color2__c + ' 100%);';
	                        	styleBackgroundColor += 'background: -ms-linear-gradient(top, #' + c.background_color__c + ' 0%,#' + c.background_color2__c + ' 100%);';
	                        	styleBackgroundColor += 'filter: progid:DXImageTransform.Microsoft.gradient(startColorStr=\'#' + c.background_color__c + '\', EndColorStr=\'#' + c.background_color2__c + '\');';
	                        }
                        }
                        if (c.text_color__c != null) {
                            styleTextColor = 'color: #' + c.text_color__c + ';';
                        }
                        if ((span==1 || salesDriversToShowCount==1) && c.Logo_Image_Small__r.content_id__c != null) {
                            ContentDocument[] cd = [SELECT LatestPublishedVersionId from ContentDocument where Id=: c.Logo_Image_Small__r.content_id__c];
                            if (cd != null && cd.size()>0) {
                                styleBackgroundImage = 'background-image: url(/sfc/servlet.shepherd/version/download/' + cd[0].LatestPublishedVersionId + ');';
                            }
                        }
                        tmpProgramData.add(new map<String, String>{
                            'styleBackgroundColor' => styleBackgroundColor,
                            'styleBackgroundImage' => styleBackgroundImage,
                            'styleTextColor'       => styleTextColor,
                            'label'                => c.name,
                            'description'          => c.Description__c!=null?c.Description__c.replaceAll('\n','<br/>'):'',
                            'id'                   => c.id
                        });
                    }
                }
                tmpMonthData.put(p, tmpProgramData);
            }
            calendarData.put(tmpDate.year() + '-'+tmpDate.month(), tmpMonthData);
        } 
        calendarData.put('empty', programMap);
    }

	// helper
    private String IdSetToString(Set<ID> valueList){
    	String result = '';
    	String glue = '';
		for (String value : valueList) {         
			result += glue + '\''+value+'\' ';
			glue = ',';
		}    	
    	return result;
    }

	// helper
    private String IdListToString(List<ID> valueList){
    	String result = '';
    	String glue = '';
		for (String value : valueList) {         
			result += glue + '\''+value+'\' ';
			glue = ',';
		}    	
    	return result;
    }    
    
}