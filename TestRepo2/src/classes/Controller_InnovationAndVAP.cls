public with sharing class Controller_InnovationAndVAP extends Controller_Base {
    public list<map<String, String>> months {get; protected set;}
    public list<String> salesDriversToShow {get; protected set;}
    public Integer salesDriversToShowCount {get; protected set;}
    public list<String> salesDriversToProcess {get; protected set;}
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
    public String startFromDate {get; public set;} 
    public String startDate {get; set;} 
    public String endDate {get; set;} 
    
    public String currentSectionConstant {get; private set;}
    public Boolean currentSectionBool {get; private set;}

    // general update content
    public List<AggregateResult> performanceUpdates {get; set;}
    public List<AggregateResult> planningCalendars {get; set;}
        
    public Controller_InnovationAndVAP() {
        currentSectionConstant = (siteTheme == 'Spirits') ? (Constant.INNOVATION_AND_SUSTAINOVATION) : (Constant.INNOVATION_SUSTAINOVATION_AND_VINTAGE);
        currentSectionBool = (siteTheme == 'Spirits');
        
        // Start: Changes for responsive site - Randy Wandell (Appirio) 7/10/13
        pageUrl = ApexPages.currentPage().getUrl();
        setResponsiveState();
        if(isResponsive) {
            detailPagePath = Page.R_IVAPDetails.getUrl();
        } else {
            detailPagePath = Page.IVAPDetails.getUrl();
        }
//      pageUrl = Page.InnovationAndVAP.getUrl();
        //End:
        
        salesDriversToShow = new list<String>();
        salesDriversToProcess = new list<String>();
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
                    calendar.initDateRange(timePeriod, Date.valueOf(startFromDate));
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
        refreshGeneralUpdates();
    }
    
    private void prepareBreadcrumbs(){
        cleanBreadcrumbs();
        
        // Start: Changes for responsive site - Randy Wandell (Appirio) 7/10/13
//          currentPageUrl = Page.InnovationAndVAP.getUrl();
        currentPageUrl = ApexPages.currentPage().getUrl();
        if(isResponsive) {
            detailPagePath = Page.R_IVAPDetails.getUrl();
        } else {
            detailPagePath = Page.IVAPDetails.getUrl();
        }
        //End:
        
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
        
        addBreadcrumbItem(currentPageUrl, currentSectionConstant);
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
        return Service_UserInput.getSalesDrivers(selectedThemes(), CONSTANT.INNOVATION_AND_SUSTAINOVATION);
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
        salesDriversToShow.clear();
        salesDriversToProcess.clear();
        programMap.clear();
        //display all or only selected sales driver
        String notShownDriver = (siteTheme == 'Wine') ? 'New Sizes, Pack/Label Changes' : 'Pack/Label Changes';
        for (SelectOption o : getSalesDrivers()){
            if ((salesDriver == 'All' && o.getLabel() != 'All') || (salesDriver != 'All' && o.getLabel()==salesDriver)){
                salesDriversToProcess.add(o.getLabel());
                if(o.getLabel() != notShownDriver){
                    salesDriversToShow.add(o.getLabel());
                    programMap.put(o.getLabel(), new list<map<String, String>>{new map<String, String>{'className' => 'empty', 'label' => ''}});
                }
            }
        }
        salesDriversToShowCount = salesDriversToShow.size();
        setMonths();
        
        // Start: Changes for responsive site - Randy Wandell (Appirio) 7/10/13
        if(isResponsive) {
            pdfPath = Page.R_InnovationAndVAPPdf.getUrl()+'?export=true&time='+timePeriod+'&driver='+salesDriver+'&date='+calendar.startDate.year()+'-'+calendar.startDate.month()+'-'+calendar.startDate.day()+'&'+parseSelectedThemesToUrl();
        } else {
            pdfPath = Page.InnovationAndVAPPdf.getUrl()+'?export=true&time='+timePeriod+'&driver='+salesDriver+'&date='+calendar.startDate.year()+'-'+calendar.startDate.month()+'-'+calendar.startDate.day()+'&'+parseSelectedThemesToUrl();
        }
        //End: 
        
        prepareBreadcrumbs();
        startFromDate = calendar.startDate.year() + '-' + calendar.startDate.month() + '-01';
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
        List<Calendar__c> cRecords = Service_API.getIVAPs(calendar.startDate, calendar.endDate, salesDriver, selectedThemes());
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
            for (String p: salesDriversToProcess) {
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
                            'id'                   => c.id,
                            'shipDate'             => c.Ship_Date__c!=null ? c.Ship_Date__c.format() : null,
                            'launchDate'           => c.Launch_Date__c != null ? c.Launch_Date__c.format() : null,
                            'startDate'            => c.Start_Date__c.format(),
                            'endDate'              => c.End_Date__c.format(),
                            'showTooltip'          => (c.Show_tooltip_details__c == true && c.Show_tooltip_details__c != null) ? '' : 'disableTooltip'                        
                        });
                    }
                }
                p = (siteTheme == 'Spirits' && p == 'Pack/Label Changes') ? ('New Sizes, Pack/Label Changes') : ((siteTheme == 'Wine' && p == 'New Sizes, Pack/Label Changes') ? ('Pack/Label Changes') : (p));
                list<map<String, String>> dataNoReplace = tmpMonthData.get(p);
                dataNoReplace = (dataNoReplace == null) ? (new list<map<String, String>>()) : dataNoReplace;
                dataNoReplace.addAll(tmpProgramData);
                tmpMonthData.put(p, dataNoReplace);
            }
            calendarData.put(tmpDate.year() + '-'+tmpDate.month(), tmpMonthData);
        } 
        
        calendarData.put('empty', programMap);
    }
    
    private void refreshGeneralUpdates(){
        Set<ID> brandIdsSet = Service_API.getAllContentBrandIDs(currentSectionConstant);

        String brandIdsString = '';
        String glue = '';
                
        for (String id : brandIdsSet) {         
            brandIdsString += glue + '\''+id+'\' ';
            glue = ',';
        }

        performanceUpdates = new List<AggregateResult>();
        planningCalendars = new List<AggregateResult>();

        if(!brandIdsSet.isEmpty()){
            AggregateResult[] tmpList = database.query('SELECT content_description__r.Title__c title, content_description__r.Description__c description, content_description__r.Content_Version_Id__c cvid, content_description__r.filetype__c filetype, Sub_Category__c FROM content_property__c' + 
            +' WHERE category__c=\'' + currentSectionConstant + '\' and (Sub_Category__c=\'' + Constant.PERFORMANCE_UPDATES + '\' or Sub_Category__c=\'' + Constant.PLANNING_CALENDARS + '\')  AND ( content_description__r.Content_Id__c in ('+brandIdsString+') OR (content_description__r.Portfolio__c=true and content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') ) )' +
            +' GROUP BY content_description__r.Title__c, content_description__r.Description__c, content_description__r.Content_Version_Id__c, content_description__r.filetype__c, Sub_Category__c'+ 
            +' ORDER BY content_description__r.Title__c ASC limit 1000');
            
            if (tmpList!= null) {
                for(AggregateResult ar: tmpList) {
                    string subCategoryName = (string)ar.get('Sub_Category__c');
                    if (subCategoryName == Constant.PERFORMANCE_UPDATES) {
                        performanceUpdates.add(ar);
                    } else if (subCategoryName == Constant.PLANNING_CALENDARS) {
                        planningCalendars.add(ar);
                    }
                }
            }
        }    
        
        startDate = calendar.startDate.format();
        endDate = calendar.endDate.format();
    }

    // Start: Changes for Responsive Site - Randy Wandell (Appirio) 7/10/13    
    public void setResponsiveState() {
        if(pageUrl.toLowerCase().indexOf('r_innovationandvap') > -1) {
            isResponsive = true;
            preapareSiteNavigationMenu();
        } else {
            isResponsive = false;
            preapareSiteNavigationMenu();
        }       
    }
    // End:    
}