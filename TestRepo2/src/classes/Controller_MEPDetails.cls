/*******************************************************************************
Name        : Controller_MEPDetails.cls

Updated By 	: Basant Kumar Verma (Appirio OffShore)
Date 				: 7/1/2013
Story/Task	: US585/TA1082
*******************************************************************************/
public with sharing class Controller_MEPDetails extends Controller_Base {
	// display as list (true) or box (false)
    public Boolean displayAsList {get; set;}
    
    public Id detailId {public get; protected set;}
    public Calendar__c mepItem {public get; protected set;}
    public String dateDescription {public get; protected set;}
    public String salesDriverDescription {public get; protected set;}
	public String description {public get; protected set;}
	public String styleBackgroundLogoImage {public get; protected set;}
    public String contentDocumentId {public get;public set;}
        
	// show section
    public MAP<string, List<AggregateResult>> detailsMap {public get; protected set;}
    public MAP<string, List<AggregateResultHolder>> contentHolderMap {
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
    public List<String> detailsMapOrder {public get; protected set;}
    
	public String backToMonthlyExecutionPlanUrl {get; private set;}	

	public String goalsFolderId {
		get {
			return Service_API.getGoalsFolderId();
		}
		set;
	}
	
    public Controller_MEPDetails() {
    	// Start: Changes for responsive site - Randy Wandell (Appirio) 7/10/13
    	setResponsiveState();
    	if(isResponsive) {
    		backToMonthlyExecutionPlanUrl = Page.R_MonthlyExecutionPlan.getUrl();
    	} else {
    		backToMonthlyExecutionPlanUrl = Page.MonthlyExecutionPlan.getUrl();
    	}
    	pageUrl = ApexPages.currentPage().getUrl();
//		pageUrl = Page.MEPDetails.getUrl();
		// End:

        displayAsList = true;
		
        try{
			if(ApexPages.currentPage().getParameters().get('date') != null){	
				backToMonthlyExecutionPlanUrl += '?date='+ApexPages.currentPage().getParameters().get('date');
				if(ApexPages.currentPage().getParameters().get('time') != null){
		        	backToMonthlyExecutionPlanUrl += '&time='+Integer.valueOf(ApexPages.currentPage().getParameters().get('time'));
				}
				if(ApexPages.currentPage().getParameters().get('driver') != null){
		        	backToMonthlyExecutionPlanUrl += '&driver='+ApexPages.currentPage().getParameters().get('driver');
				}
			}
			// Start: Existing bug when building url - Randy Wandell (Appirio) 7/10/13
//			backToInnovationAndVAPUrl += '&'+parseSelectedThemesToUrl();
			if(backToMonthlyExecutionPlanUrl.indexOf('?') >-1) {
				backToMonthlyExecutionPlanUrl += '&';
			} else {
				backToMonthlyExecutionPlanUrl += '?';
			}
			backToMonthlyExecutionPlanUrl += parseSelectedThemesToUrl();
			// End;
        } catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load data from url. '));
	    	// Start: Changes for responsive site - Randy Wandell (Appirio) 7/10/13
	    	//backToMonthlyExecutionPlanUrl = Page.MonthlyExecutionPlan.getUrl(); 
	    	if(isResponsive) {
	    		backToMonthlyExecutionPlanUrl = Page.R_MonthlyExecutionPlan.getUrl();
	    	} else {
	    		backToMonthlyExecutionPlanUrl = Page.MonthlyExecutionPlan.getUrl();
	    	}            
 			// End:    
        }
        
        // Start: Changes for responsive site - Randy Wandell (Appirio) 7/10/13	
//        addBreadcrumbItem(Page.MonthlyExecutionPlan.getUrl(), Constant.MONTHLY_EXECUTION_PLAN);
        addBreadcrumbItem(backToMonthlyExecutionPlanUrl, Constant.MONTHLY_EXECUTION_PLAN);
        // End:
        
        if(ApexPages.currentPage().getParameters().get('id') != null){
            try {
                detailId = Id.valueOf(ApexPages.currentPage().getParameters().get('id'));
                mepItem = Service_API.getMEP(detailId, selectedThemes());
                dateDescription = ''+mepItem.Start_Date__c.format()+' - '+mepItem.End_Date__c.format();
                salesDriverDescription = ''+mepItem.Sales_Channel__c;
                description = mepItem.Description__c==null?mepItem.Description__c:mepItem.Description__c.replaceAll('\n','<br/>');
                addBreadcrumbItem(Apexpages.currentPage().getUrl(), mepItem.name);                
                if(mepItem.Logo_Image_Large__r.content_id__c != null) {
                    ContentDocument[] cd = [SELECT LatestPublishedVersionId FROM ContentDocument WHERE Id=: mepItem.Logo_Image_Large__r.content_id__c];
                    if (cd != null && cd.size()>0) {
                    		// Start - Changes for US585/TA1082 - Basant Verma
                    		if(currentUserPage().equalsIgnoreCase('/apex/R_MEPDetails'))
                        	styleBackgroundLogoImage = '/sfc/servlet.shepherd/version/download/' + cd[0].LatestPublishedVersionId;
                        else
                        	styleBackgroundLogoImage = 'background-image: url(/sfc/servlet.shepherd/version/download/' + cd[0].LatestPublishedVersionId + ');';
                        // End - Changes for US585/TA1082 - Basant Verma
                    }
                }

            } catch( Exception err ){
            	detailId = null;
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load details.'));
                return;
            }
        }
        
        refreshPageContent();        
    }
    
    public PageReference initTheme(){
    	// Start : Changes for DE700 Parul Gupta : Added Parameter condition
        if(ApexPages.currentPage().getParameters().get('toggled') == null
        && ApexPages.currentPage().getParameters().get('toggled') == ''){
			if(mepItem != null && Service_API.getSectionTheme() != mepItem.classification__c && mepItem.classification__c != 'Mixed'){
				Service_API.setUserSiteTheme(mepItem.classification__c, false);
	    		PageReference pr = ApexPages.currentPage();
	    		pr.setRedirect(true);
	    		return pr;
			}
        }
        // End : Changes for DE700 Parul Gupta
		return null;
    }
    
    public override void refreshPageContent() {
        detailsMap = new MAP<string, List<AggregateResult>>();
        detailsMapParser = new MAP<string,string>();
        detailsMapSize = new MAP<String,Integer>();
        detailsMapOrder = new list<String>();
        
		Set<ID> brandIdsSet = Service_API.getAllContentBrandIDs(Constant.MONTHLY_EXECUTION_PLAN);
		String glue = '';
		String brandIdsString = '';
		for (String id : brandIdsSet) {         
			brandIdsString += glue + '\''+id+'\' ';
			glue = ',';
		}
		
		List<String> subCategoriesList = new List<String>();
    	list<Sections__c> sectionTabs = Service_API.getSectionTabs(CONSTANT.MONTHLY_EXECUTION_PLAN);
    	for(Sections__c s : sectionTabs ){
    		if((s.Parent_Tab__c == null || s.Parent_Tab__c == '') && s.Sales_Driver__c == mepItem.Sales_Channel__c && s.Tab__c!=null && s.Tab__c!=''){
    			subCategoriesList.add(s.Tab__c);
                detailsMapOrder.add(s.Tab__c);
                detailsMap.put(s.Tab__c, new List<AggregateResult>() );
                detailsMapParser.put(s.Tab__c,s.Tab__c.replaceAll('[^a-zA-Z0-9]', ''));
                detailsMapSize.put(s.Tab__c, 0);    			
    		}
    	}    	
    	
    	String subCategoriesString = '';
    	glue = '';
		for (String categoryName : subCategoriesList) {         
			subCategoriesString += glue + '\''+categoryName+'\' ';
			glue = ',';
		}

        isNewContent = false;									  	
		if(subCategoriesList.size() != 0 && brandIdsSet.size() != 0){    	
			AggregateResult[] tmpList = database.query('SELECT Sub_Category__c, Sub_Sub_Category__c, content_description__r.is_video__c is_video, content_description__r.video_id__c video_id, content_description__r.Title__c title, content_description__r.Description__c description, content_description__r.Content_Version_Id__c cvid, content_description__r.filetype__c filetype, content_description__r.Preview_Available__c previewAvailable, content_description__r.Preview_Id__c previewId, content_description__r.filesize__c filesize, content_description__r.filesize_low__c filesize_low, content_description__r.Content_Version_Id_Low__c cvidlow, max(content_description__r.Uploaded_date__c) createdDate, content_description__r.image_resolution__c imageRes  FROM content_property__c ' +
		        +' WHERE content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') and category__c=\''+Constant.MONTHLY_EXECUTION_PLAN+'\' and Sub_Category__c in ('+subCategoriesString+') AND content_description__r.Content_Id__c in ('+brandIdsString+') AND Calendar__c=\''+detailId+'\' '
		        +' GROUP BY Sub_Category__c, Sub_Sub_Category__c, content_description__r.is_video__c, content_description__r.video_id__c, content_description__r.Title__c, content_description__r.Description__c, content_description__r.Content_Version_Id__c, content_description__r.filetype__c, content_description__r.Preview_Available__c, content_description__r.Preview_Id__c, content_description__r.filesize__c, content_description__r.filesize_low__c, content_description__r.Content_Version_Id_Low__c, content_description__r.image_resolution__c  '+ 
		        +' ORDER BY Sub_Sub_Category__c, content_description__r.Description__c ASC');

        	if (tmpList!= null) {
        		for(AggregateResult ar: tmpList) {
        			string subCategoryName = (string)ar.get('Sub_Category__c');
	                String dateString = String.valueOf(ar.get('createdDate'));
	                DateTime itemTime = datetime.valueOf(dateString);
	                if(lastLoginDate < itemTime){
	                    isNewContent = true;
	                }                     
                    if(detailsMap.containsKey(subCategoryName)){
	                    List<AggregateResult> tempList = detailsMap.get(subCategoryName);
                        tempList.add(ar);
                        detailsMap.put(subCategoryName, tempList);
                       	detailsMapSize.put(subCategoryName, tempList.size());
                    }
        		}
        	}                	
		}
		currentBasketIds = Service_Basket.getBasketIds();
		currentFollowIds = Service_Notification.getFollowIds();
    }
    
    public void renderAsListSlider() {
    	displayAsList = true; // other action if needed
    }   

    public void renderAsBoxSlider() {
    	displayAsList = false; // other action if needed    	
    }
    
	// Start: Changes for Responsive Site - Randy Wandell (Appirio) 7/10/13    
    public void setResponsiveState() {
		pageUrl = ApexPages.currentPage().getUrl();
		if(pageUrl.toLowerCase().indexOf('r_mepdetails') > -1) {
			isResponsive = true;
			preapareSiteNavigationMenu();
		} else {
			isResponsive = false;
			preapareSiteNavigationMenu();
		}    	
    }
    // End:    
}