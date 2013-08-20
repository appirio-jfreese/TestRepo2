public with sharing class Controller_MonthlyExecutionPlan extends Controller_Base {
    public list<map<String, String>> months {get; protected set;}
    public list<String> salesDriversToShow {get; protected set;}
    public Integer salesDriversToShowCount {get; protected set;}
    public map<String, list<map<String, String>>> programMap {get; protected set;}

    public String detailPagePath {public get; protected set;}
    public String pdfPath {public get; protected set;}
	public String currentPageUrl {public get; protected set;}
	
    public Integer timePeriod {
        get; 
        set{
            timePeriod = value;
            if (timePeriod>1) {
                span = 3;
            } else {
                span = 1;
            }
            calendar.initDateRange(timePeriod, calendar.startDate);
        }
    }    
    public Integer span {get; protected set;}
    public map<String, map<String, list<map<String, String>>>> calendarData {get; protected set;}
    
    public String salesDriver {get;set;}
    
    private Service_Calendar calendar;
    public String startFromDate {get; set;} 
    public String startDate {get; set;} 
    public String endDate {get; set;} 
        
    public Controller_MonthlyExecutionPlan() {
    	// Start: Changes for responsive site - Randy Wandell (Appirio) 7/10/13
		//pageUrl = Page.MonthlyExecutionPlan.getUrl();
		pageUrl = ApexPages.currentPage().getUrl();
		setResponsiveState();
		if(isResponsive){
        	detailPagePath = Page.R_MEPDetails.getUrl();
		}else{
			detailPagePath = Page.MEPDetails.getUrl();
		}
		// End:
        
        salesDriversToShow = new list<String>();
        programMap = new map<String, list<map<String, String>>>();
        months       = new list<map<String, String>>();
        calendarData = new map<String, map<String, list<map<String, String>>>>();
        
        calendar = new Service_Calendar();

        try{
			if(ApexPages.currentPage().getParameters().get('time') != null){
	        	timePeriod = Integer.valueOf(ApexPages.currentPage().getParameters().get('time'));
			} else {
				timePeriod = 1;
			}
            if(ApexPages.currentPage().getParameters().get('date') != null){
                try{
                    startFromDate = ApexPages.currentPage().getParameters().get('date');
                    calendar.initDateRange(timePeriod, date.valueOf(startFromDate));
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
		
        refreshContent();
    }
    
	private void prepareBreadcrumbs(){
		cleanBreadcrumbs();
		// Start: Changes for responsive site - Randy Wandell (Appirio) 7/10/13
//       	currentPageUrl = Page.MonthlyExecutionPlan.getUrl();
		currentPageUrl = ApexPages.currentPage().getUrl();
		// End:
        if(currentPageUrl.toLowerCase().indexOf('r_monthlyexecutionplan') > -1){
        	detailPagePath = Page.R_MEPDetails.getUrl();
		}else{
			detailPagePath = Page.MEPDetails.getUrl();
		}
        if(timePeriod != null){
			detailPagePath += '?time='+timePeriod;
			if(salesDriver != null && salesDriver != ''){
				detailPagePath += '&driver='+salesDriver;		
			}
			if(calendar != null){
				detailPagePath += '&date='+calendar.startDate.year()+'-'+calendar.startDate.month()+'-'+calendar.startDate.day()+'';
			}
        }
		detailPagePath += '&'+parseSelectedThemesToUrl();        
        
        addBreadcrumbItem(currentPageUrl, Constant.MONTHLY_EXECUTION_PLAN);
	}    
    
    public void nextMonth() {
    	calendar.incrementDates(timePeriod);
        refreshContent();      
    }   
     
    public void previousMonth() {
    	calendar.incrementDates(-timePeriod);
        refreshContent();      
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
        return Service_UserInput.getSalesDrivers(selectedThemes(), CONSTANT.MONTHLY_EXECUTION_PLAN);
    }

    public void selectSalesDriver() {
        refreshContent();
    }
    
    public void setStartDateValue() {
    	if (startFromDate != null) {
            calendar.initDateRange(timePeriod, Date.valueOf(startFromDate));
            refreshContent();
    	}
    }
    
    public void refreshContent() {
    	system.debug('-----refreshContent-----'+timePeriod);
        salesDriversToShow.clear();
        programMap.clear();
        //display all or only selected sales driver
        for (SelectOption o : Service_UserInput.getSalesDrivers(selectedThemes(), CONSTANT.MONTHLY_EXECUTION_PLAN)){
            if ((salesDriver == 'All' && o.getLabel() != 'All') || (salesDriver != 'All' && o.getLabel()==salesDriver)){
                salesDriversToShow.add(o.getLabel());
                programMap.put(o.getLabel(), new list<map<String, String>>{new map<String, String>{'className' => 'empty', 'label' => ''}});
            }
        }
        salesDriversToShowCount = salesDriversToShow.size();
        setMonths();

        pdfPath = Page.MonthlyExecutionPlanPdf.getUrl()+'?export=true&time='+timePeriod+'&driver='+salesDriver+'&date='+calendar.startDate.year()+'-'+calendar.startDate.month()+'-'+calendar.startDate.day()+'&'+parseSelectedThemesToUrl();
		prepareBreadcrumbs();      
		startFromDate = calendar.startDate.year() + '-' + calendar.startDate.month() + '-01';
		startDate = calendar.startDate.format();
		endDate = calendar.endDate.format();
    }
    
    private void setMonths() {
    	months.clear();
        populateData();
        for (Integer i=0; i<timePeriod; i++) {
            Date tmpDate = calendar.startDate.addMonths(i);
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
        List<Calendar__c> cRecords = Service_API.getMEPs(calendar.startDate, calendar.endDate, salesDriver, selectedThemes());
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
            Date tmpDate = calendar.startDate.addMonths(i);
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
                            	//if(ApexPages.currentPage().getUrl().indexOf('R_MonthlyExecutionPlan') > -1){
                            		//styleBackgroundImage = '/sfc/servlet.shepherd/version/download/' + cd[0].LatestPublishedVersionId;                           	
                            	//}else{
                                	styleBackgroundImage = 'background-image: url(/sfc/servlet.shepherd/version/download/' + cd[0].LatestPublishedVersionId + ');';
                            	//}
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
    
	// Start: Changes for Responsive Site - Randy Wandell (Appirio) 7/10/13    
    public void setResponsiveState() {
		if(pageUrl.toLowerCase().indexOf('r_monthlyexecutionplan') > -1) {
			isResponsive = true;
			preapareSiteNavigationMenu();
		} else {
			isResponsive = false;
			preapareSiteNavigationMenu();
		}    	
    }
    // End:     
}