public with sharing class Controller_CategoryDevelopment extends Controller_Base {

	// display as list (true) or box (false)
    public Boolean displayAsList {get; set;}

	// main sections 
    public String currentSection {get; set;}
    public List<string> sections {get; set;}
    
    // sub sections
    public String currentSubSection {get; set;}
    public List<string> subSections {get; set;}
    
    // portfolio
    public Boolean selectedPortfolio {get; set;}
    public Boolean selectedTBA {get; set;}
    // rts
    public Boolean selectedRTS {get; set;}
        
    // brands
	public List<Brand__c> parentBrandList {get; set;}
	public List<Brand__c> additionalBrandList{get; set;}
	public List<Brand__c> childBrandList {get; set;}
    public Integer brandBoxToRender {get;set;}
	public String parentId {get; set;}
    public String selectedBrandIds {get; set;}
    public String selectedChildBrandIds {get; set;} 
    public Integer selectedChildBrandNumber {get; set;}   
	protected List<Id> selectedBrandIdsList {protected get; protected set;}
    public String brandNumberDescription {get; set;}
    public String selectedBrandName {get; set;}
    public String selectedCategoryName {get; set;}
    public String categoryNumberDescription {get; set;}
    public List<String> classificationItemsBreadCrumb{get;set;}
    
    private Boolean refreshDisabled = false;
   
    public Boolean disableFilter {get; private set;}
    public Integer activeFilter {get; private set;}
        
    // time period
	// calendar
    public String dateRangeDescription {get; set;}
    protected Service_Calendar calendar;
    protected Service_Calendar calendarMonthView;
	public List<Map<String, String>> quarterViewsList {public get; public set;}
	public List<Map<String, String>> monthViewsList {public get; public set;}
    public String selectedTimePeriods {get; set;}
	protected List<Integer> selectedTimePeriodsList {protected get; protected set;}
    protected Integer quarterShift {protected get; protected set;}
    protected Integer currentQtr {protected get; protected set;}
    protected Integer monthShift {protected get; protected set;}
    protected Integer currentMTH {protected get; protected set;}
    public Boolean monthOrQuarterRender {get; set;} // true = Quarter
    
	// content
    public List<AggregateResult> content {get; set;}
    public List<AggregateResultHolder> contentHolder {
    	get {
    		List<AggregateResultHolder> contentHolder1 = new List<AggregateResultHolder>();
    		if(content!=null){
	    		for(AggregateResult ar : content){
	    			AggregateResultHolder tmp = new AggregateResultHolder();
	    			tmp.result = ar;
	    			contentHolder1.add(tmp);
	    		}
    		}
    		return contentHolder1;
    	}
    	set;
    }
    
    //brand categories
    public List <SelectOption> brandCategories {get;set;}
    public String selectedBrandCategories {get;set;}
    public String allCategoriesString {get;set;}

	// select all checkbox values
    public Boolean selectAllBrands {public get; public set;}	
    public Boolean selectAllBrandCategories {public get; public set;}	
	public Boolean selectAllVariants {public get; public set;}  

	public Boolean isFilterSet {public get; protected set;}  
	
    public Controller_CategoryDevelopment() {
		pageUrl = Page.CategoryDevelopment.getUrl();
    	refreshDisabled = true;
		// default display as list
		displayAsList = true;
		disableFilter = false;
		isFilterSet = false;
        selectedPortfolio = false;
        selectedTBA = false;
		selectedRTS = false;
		selectAllBrands = false;
		selectAllVariants = false;
		expandFilter = false;
        
        if(siteTheme != 'Wine') {
        	brandBoxToRender = 21;
        } else {
        	brandBoxToRender = 23;
        }
		
        // setup sections
		sectionInit();
		
		// sub section setup        
		subSectionInit();
        
        // get brands
		//initParentBrands();
		
		brandNumberDescription = 'All';
		categoryNumberDescription = 'All';
		dateRangeDescription = 'All Time Periods';
		
    	selectedBrandIds = '';
    	parentId = '';
    	selectedChildBrandIds = '';
    	selectedTimePeriods = '';
		selectedBrandIdsList = new List<Id>();    		

		// get time periods
		monthOrQuarterRender = true;
        calendar = new Service_Calendar();
		calendar.initDateRange(3, null);	// quarter view
		calendarMonthView = new Service_Calendar();
		calendarMonthView.initDateRange(1, null);
		currentQtr = calendar.fiscalQuarter;
		currentMth = calendarMonthView.fiscalMonth;
		quarterShift = 0;
		monthShift = 0;
		initTimePeriods();
		
		initBrandCategories();

		// get content
		content = new List<AggregateResult>();
		
		try {
			if(ApexPages.currentPage().getParameters().get('section') != null && ApexPages.currentPage().getParameters().get('section') != ''){
				currentSection = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('section'), 'UTF-8');
				switchSection();
				if(ApexPages.currentPage().getParameters().get('subsection') != null && ApexPages.currentPage().getParameters().get('subsection') != ''){
					currentSubSection = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('subsection'), 'UTF-8');
					switchSubSection();
				}
			}
			if(ApexPages.currentPage().getParameters().get('openfilter') != null && ApexPages.currentPage().getParameters().get('openfilter') != ''){
				expandFilter = true;
			}
		} catch(Exception e){
           	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load data from url.'));
           	refreshDisabled = false;
           	return;			
		}
		
		refreshDisabled = false;		
		refreshPageContent();
		refreshDisabled = true;
		prepareBreadcrumbs();	
		refreshDisabled = false;
    }

	private void prepareBreadcrumbs(){
		cleanBreadcrumbs();
        addBreadcrumbItem(Page.CDIntro.getUrl(), Constant.CATEGOTY_DEVELOPMENT);		
        if(currentSection != null && currentSection != ''){
			String currentPageUrl = '?';
			currentPageUrl += 'section='+EncodingUtil.urlEncode(currentSection,'UTF-8');
        	if(currentSubSection != null && currentSubSection != ''){
        		currentPageUrl += '&subsection='+EncodingUtil.urlEncode(currentSubSection,'UTF-8');
        	}
        	addBreadcrumbItem(currentPageUrl, currentSection);
        }
	}
	
    // switch section
    public void switchSection() {
        selectedTBA = false;
        selectedBrandCategories = null;
    	Set<string> sectionSet = new Set<string>(sections);
        if( !sectionSet.contains(currentSection) ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable switch section.' ));
   	        return;
    	}
		subSectionInit();
    	initPager();
		prepareBreadcrumbs();
		refreshPageContent();
		expandFilter = false;
    }
    
    
    // switch subSection
    public void switchSubSection() {
    	Set<string> subSectionSet = new Set<string>(subSections);
        if( !subSectionSet.contains(currentSubSection) ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable switch section.' ));
   	        return;
    	}
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
    
    public void nextPeriod() {
    	if(monthOrQuarterRender){//quarter
			calendar.incrementQuarter(1);
			quarterShift++;
			selectedTimePeriods = '';
			validSelectedTimePeriodsList();
	        initTimePeriods();
	        refreshPageContent();
			expandFilter = false;
		} else {//month
			calendarMonthView.incrementMonth(3);
			monthShift = monthShift + 3;
			selectedTimePeriods = '';
			validSelectedTimePeriodsList();
	        initTimePeriods();
	        refreshPageContent();
			expandFilter = false;
		}
    }   

    private void initTimePeriods() {
		quarterViewsList = Service_UserInput.getQuarterOptions(calendar.fiscalQuarter, calendar.fiscalYear, calendar.startDate);
   		monthViewsList = Service_UserInput.getMonthsOptions(calendarMonthView);
    }

    public void previousPeriod() {
		if(monthOrQuarterRender){
			calendar.incrementQuarter(-1);
			quarterShift--;
			selectedTimePeriods = '';
			validSelectedTimePeriodsList();
	        initTimePeriods();
	        refreshPageContent();
			expandFilter = false;
		} else {
			calendarMonthView.incrementMonth(-3);
			monthShift = monthShift - 3;
			selectedTimePeriods = '';
			validSelectedTimePeriodsList();
	        initTimePeriods();
	        refreshPageContent();
			expandFilter = false;
		}
    }
    
    public void renderAsList() {
    	displayAsList = true; // other action if needed    	
		expandFilter = false;
    }   

    public void renderAsBox() {
    	displayAsList = false; // other action if needed    	
		expandFilter = false;
    }   
 
	public void resetFilter(){
		selectedTBA = false;
        selectedPortfolio = false;
		selectedRTS = false;
		isFilterSet = false;		
    	selectedBrandIds = '';
    	parentId = '';
    	selectedTimePeriods = '';
    	selectedChildBrandIds = '';    	
    	selectAllBrands = false;
    	selectAllVariants = false;
		selectedBrandIdsList = new List<Id>();
		selectedTimePeriodsList = new List<Integer>();
		brandNumberDescription = 'All';
		categoryNumberDescription = 'All';
		dateRangeDescription = 'All Time Periods';
		childBrandList = new list<Brand__c>();
		selectedBrandCategories = '';
		initPager();
		//initParentBrands();
		refreshPageContent();
		expandFilter = true;
	}
    
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

    public void clearVariantBrandsSelected() {
		selectedChildBrandIds = '';
		selectAllVariants = false;	
		expandFilter = false;
    }
    
    public void clearVariantBrands() {
  		childBrandList = new list<Brand__c>();      	
		selectedChildBrandIds = '';
		parentId = '';
		selectAllVariants = false;		
		expandFilter = false;
    }
       
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
		if(selectedBrandIdsList.isEmpty()){
			brandNumberDescription = 'All';
		} else {
			brandNumberDescription = ''+brandsNo;
		}
		selectedCategoryName = null;
		if(selectedBrandCategories != null && selectedBrandCategories != ''){
			Integer size = selectedBrandCategories.split(',').size();
			if(size == 1){
				selectedCategoryName = selectedBrandCategories;
			} else {
				categoryNumberDescription = String.valueOf(size);
			}
		}
		
					
		selectedChildBrandNumber = tempSelectedChildBrandIdsList.size();
		initPager();
    	refreshPageContent();
		expandFilter = false;
    }
    
    public override void refreshPageContent() {
    	if(refreshDisabled)
    		return;
		try{			
			initParentBrands();			
			content = new List<AggregateResult>();
			Set<ID> brandIdsSet = new Set<Id>();
			classificationItemsBreadCrumb = new List<String>();
			
			Boolean isFiltering = false;
			// get content document ids		
			if(!selectedBrandIdsList.isEmpty()) {
				isFiltering = true;
				brandIdsSet = Service_API.getContentBrandIDs(selectedBrandIdsList,CONSTANT.CATEGOTY_DEVELOPMENT, true);
			} else if(selectedBrandCategories != null && selectedBrandCategories != ''){				
				isFiltering = true;
				String[] categoryList = selectedBrandCategories != null ? selectedBrandCategories.split(',') : null;				
				classificationItemsBreadCrumb = categoryList;			
				Brand__c[] tmpParentBrandList = Service_API.getBrandsByCategories(categoryList);
				List<Id> currentBrandIds = new List<ID>();
				for(Brand__c brand : tmpParentBrandList){
					currentBrandIds.add(brand.id);
				}
				brandIdsSet = Service_API.getContentBrandIDs(currentBrandIds,CONSTANT.CATEGOTY_DEVELOPMENT, true);								
			} else {
				isFiltering = false;
				List<Id> currentBrandIds = new List<ID>();
				for(Brand__c brand : parentBrandList){
					currentBrandIds.add(brand.id);
				}
				brandIdsSet = Service_API.getContentBrandIDs(currentBrandIds,CONSTANT.CATEGOTY_DEVELOPMENT, false);
			}
			
			if(selectedBrandCategories != null && selectedBrandCategories != ''){
				String[] categoryList = selectedBrandCategories != null ? selectedBrandCategories.split(',') : null;				
				classificationItemsBreadCrumb = categoryList;	
			}
			
			if (selectedTBA) {
				classificationItemsBreadCrumb.add('TBA');
			}
	
			String quarterViewSelect = '';
			String queryString = '';
			dateRangeDescription = 'All Time Periods';	
			
			validSelectedTimePeriodsList();
	
			// no filers
			if(selectedTimePeriodsList.isEmpty() && !selectedPortfolio && !selectedRTS && !selectedTBA && selectedBrandIdsList.isEmpty()){
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

			if(currentSection != '' && currentSection != null && !brandIdsSet.isEmpty()){ 
				String brandIdsString = IdSetToString(brandIdsSet);
	
				queryString = 'SELECT Id, Sub_Category__c, Sub_Sub_Category__c, Sub_Sub_Sub_Category__c, content_description__r.is_video__c is_video, content_description__r.video_id__c video_id, content_description__r.Title__c title, content_description__r.Description__c description, content_description__r.Content_Version_Id__c cvid, content_description__r.filetype__c filetype, content_description__r.Preview_Available__c previewAvailable, content_description__r.Preview_Id__c previewId, content_description__r.filesize__c filesize, content_description__r.filesize_low__c filesize_low, content_description__r.Content_Version_Id_Low__c cvidlow, max(content_description__r.Uploaded_date__c) createdDate, content_description__r.image_resolution__c imageRes FROM content_property__c ' +
	 		 		          'WHERE content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') and Category__c = \''+CONSTANT.CATEGOTY_DEVELOPMENT+'\' AND Sub_Category__c in (\''+currentSection+'\') ';
				if(currentSubSection != '' && currentSubSection != null){
					queryString += ' AND Sub_Sub_Category__c in (\''+currentSubSection+'\') ';
				}

				list<String> cl = new list<String>();				
				
					if(!selectedPortfolio && !selectedRTS && !selectedTBA && !brandIdsSet.isEmpty()){
						if(brandIdsString != null && brandIdsString != ''){
							cl.add(' ( content_description__r.Content_Id__c in ('+brandIdsString+') ) ');
						}

						if(siteTheme != 'Wine'){
							List<Brand__c> rtsBrandList = Service_API.getRTSBrands();
							List<ID> selectedRTSBrandIdsList = new List<ID>();
							for(Brand__c rtsBrand : rtsBrandList){
								selectedRTSBrandIdsList.add(rtsBrand.id);
							}
							set<Id> rtsBrandIdsSet = Service_API.getContentBrandIDs(selectedRTSBrandIdsList,CONSTANT.CATEGOTY_DEVELOPMENT, true);
							if(rtsBrandIdsSet.size() != 0){
								String rtsBrandIdsString = IdSetToString(rtsBrandIdsSet);
								cl.add(' (( content_description__r.Content_Id__c in ('+rtsBrandIdsString+') ) )');
							}
							cl.add(' ( content_description__r.RTS__c = true and content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') ) ');	
							cl.add(' ( content_description__r.Portfolio__c=true and content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\')  ) ');
						}
	                    cl.add(' ( content_description__r.TBA__c=true and content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') ) ');
					}

					
					if(brandIdsString != null && brandIdsString != ''){
						cl.add(' (( content_description__r.Content_Id__c in ('+brandIdsString+') ) )');
					}

		            if (selectedPortfolio && siteTheme != 'Wine') {
						cl.add(' ( content_description__r.Portfolio__c=true and content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') ) ');
		            }
					
					if (selectedRTS && siteTheme != 'Wine') {
						List<Brand__c> rtsBrandList = Service_API.getRTSBrands();
						List<ID> selectedRTSBrandIdsList = new List<ID>();
						for(Brand__c rtsBrand : rtsBrandList){
							selectedRTSBrandIdsList.add(rtsBrand.id);
						}
						set<Id> rtsBrandIdsSet = Service_API.getContentBrandIDs(selectedRTSBrandIdsList,CONSTANT.CATEGOTY_DEVELOPMENT, true);
						if(rtsBrandIdsSet.size() != 0){
							String rtsBrandIdsString = IdSetToString(rtsBrandIdsSet);
							cl.add(' (( content_description__r.Content_Id__c in ('+rtsBrandIdsString+') ) )');
						}
						cl.add(' ( content_description__r.RTS__c = true and content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\')) ');						
					}

	                if (selectedTBA) {
	                    cl.add(' ( content_description__r.TBA__c=true and content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\')) ');
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

				queryString += quarterViewSelect + 
			        		  +' GROUP BY Sub_Category__c, Sub_Sub_Category__c, Sub_Sub_Sub_Category__c, content_description__r.is_video__c, content_description__r.video_id__c, content_description__r.Title__c, content_description__r.Description__c, content_description__r.Content_Version_Id__c, content_description__r.filetype__c, content_description__r.Preview_Available__c, content_description__r.Preview_Id__c, content_description__r.filesize__c, content_description__r.filesize_low__c, content_description__r.Content_Version_Id_Low__c, content_description__r.image_resolution__c, Id '+ 
			        		  +' ORDER BY Sub_Sub_Sub_Category__c, content_description__r.Description__c ASC';
				if(queryString != null && queryString != ''){
				    content = database.query(queryString);
					numberOfItems = Integer.valueOf(content.size());
					content = getRequestedPage(content);	
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

	public void initParentBrands(){
		String[] categoryList = (selectedBrandCategories != null &&  selectedBrandCategories != '') ? selectedBrandCategories.split(',') : null;
		parentBrandList = Service_API.getBrandsForFilters(categoryList);
		
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
			additionalBrandList = Service_API.getAdditionalBrandsForFilters(setOfBrands, categoryList);
		}
		
		//childBrandList = new list<Brand__c>();		
	}
	
    private void sectionInit(){
		sections = new List<String>();
        currentSection = null;
        
    	list<Sections__c> sectionTabs = Service_API.getSectionTabs(CONSTANT.CATEGOTY_DEVELOPMENT);
    	for(Sections__c s : sectionTabs ){
    		if(s.Parent_Tab__c == null || s.Parent_Tab__c == ''){
    			sections.add(s.Tab__c);
    		}
    	}

        if(sections.size() > 0){
        	currentSection = sections.get(0);
        }    
    }
    
    private void subSectionInit(){
        // setup sub sections
		subSections = new List<String>();       
        currentSubSection = null;

    	list<Sections__c> sectionTabs = Service_API.getSectionTabs(CONSTANT.CATEGOTY_DEVELOPMENT);
    	for(Sections__c s : sectionTabs ){
    		if(currentSection != null && currentSection != '' && s.Parent_Tab__c == currentSection ){
    			subSections.add(s.Tab__c);
    		}
    	}
    
		if(subSections.size() > 0){
			currentSubSection = subSections.get(0);
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

    private String IdSetToString(Set<ID> valueList){
    	String result = '';
    	String glue = '';
		for (String value : valueList) {         
			result += glue + '\''+value+'\' ';
			glue = ',';
		}    	
    	return result;
    }

    private String IdListToString(List<ID> valueList){
    	String result = '';
    	String glue = '';
		for (String value : valueList) {         
			result += glue + '\''+value+'\' ';
			glue = ',';
		}    	
    	return result;
    }
    
    private List<Integer> validSelectedTimePeriodsList(){
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
    
    private void initBrandCategories(){
    	brandCategories = Service_UserInput.getBrandCategories(false);
    	
    	String glue ='';
    	allCategoriesString = '';
    	for(SelectOption bc : brandCategories){
    		allCategoriesString += glue + bc.getValue();
    		glue = ',';
    	}
    }
    
}