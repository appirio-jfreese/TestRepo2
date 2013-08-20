/*******************************************************************************
Name        : Controller_SearchResult.cls

Modified By	: Basant Kumar Verma
Date				: 7/15/2013
Story/Task	: US612/DE635

Modified By	: Basant Kumar Verma
Date				: 7/16/2013
Story/Task	: US612/DE636

Modified By	: Basant Kumar Verma
Date				: 7/17/2013
Story/Task	: US612/DE634

Modified By	: Basant Kumar Verma
Date				: 8/02/2013
Story/Task	: US612/DE716

Modified By	: Basant Kumar Verma
Date				: 8/02/2013
Story/Task	: US585/DE678
*******************************************************************************/
public with sharing class Controller_SearchResult extends Controller_Base {
		// START : Changed for US585/DE678 - Basant
		// display as list (true) or box (false)
    public Boolean displayAsList {get; set;}
    // END : Changed for US585/DE678 - Basant
    
		//START : changed for US612/DE636 - Basant
		private static final String RESPONSIVE = 'Responsive';	
		//END : changed for US612/DE636 - Basant	
    public Integer minNoOfChar {
        get {
            return Integer.valueOf(Service_API.getSetting('minSearchNoOfChars'));
        }
        protected set;
    }
    public Integer limitPerSection {
        get {
            return Integer.valueOf(Service_API.getSetting('searchResultLimit'));
        }
        protected set;
    }   
    public String searchValue {get; set;}
    public map<string, List<AggregateResult>> contentMap {get; protected set;}
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

    public List<AggregateResult> contentDownloadShare {
    	get{
    		List<AggregateResult> ret = new List<AggregateResult>();
    		if(isDetails){
				ret.addAll(sectionContent);
    		} else {
    			for(List<AggregateResult> ars : contentMap.values()){
    				ret.addAll(ars);
    			}
    		}
    		return ret;
    	} 
    }
    
    public List<AggregateResult> sectionContent {get; protected set;}
    public List<AggregateResultHolder> sectionContentHolder {
    	get {
    		List<AggregateResultHolder> contentHolder1 = new List<AggregateResultHolder>();
    		if(sectionContent!=null){
	    		for(AggregateResult ar : sectionContent){
	    			AggregateResultHolder tmp = new AggregateResultHolder();
	    			tmp.result = ar;
	    			contentHolder1.add(tmp);
	    		}
    		}
    		return contentHolder1;
    	}
    	set;
    }
    
	public List<String> sectionOrder {get; protected set;}
 	public map<string, integer> sectionItemNumber {get; protected set;}
 	public Integer totalItemNumber {get; protected set;}
    public String currentSection {get; set;}
    public Boolean isDetails {get; set;}
    public Boolean firstZeroResult {get; set;}
    public String R_OrdertByAlpha {get; set;}
    public String R_OrdertByDate {get; set;}
    public Boolean secondZeroResult {get; set;}    
    protected String brandIdsString {get; protected set;}
 	protected transient map<string, string> sectionQuery {protected get; protected set;}
 	public String innovationSectionName {
 		get{
 			return (siteTheme == 'Spirits') ? (Constant.INNOVATION_AND_SUSTAINOVATION) : (Constant.INNOVATION_SUSTAINOVATION_AND_VINTAGE);
		}
		private set;
	}
	 
    public Controller_SearchResult() {
    	// Start: Changes for responsive site - Randy Wandell (Appirio) 7/10/13
		//pageUrl = Page.MonthlyExecutionPlan.getUrl();
		// START : Changed for US585/DE678 - Basant
		displayAsList = true;
		// END : Changed for US585/DE678 - Basant
		pageUrl = ApexPages.currentPage().getUrl();
		setResponsiveState();
    	sectionQuery = new map<string, string>();
    	sectionItemNumber = new map<string, integer>();
    	sectionOrder = new List<String>();
    	sectionContent = new List<AggregateResult>();
    	contentMap = new map<string, List<AggregateResult>>();
    	currentSection = '';
    	searchValue = '';
    	isDetails = false;
    	totalItemNumber = 0;
		firstZeroResult = false;
		secondZeroResult = false;
		initQuery();
		initSections();				
		 
		try{
			if(ApexPages.currentPage().getParameters().get('query') != null && ApexPages.currentPage().getParameters().get('query') != ''){
				searchValue = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('query'), 'UTF-8');
				searchValue = searchValue.replaceAll('[^a-zA-Z0-9]',' '); // search for alphanumeric 
        		addBreadcrumbItem(Apexpages.currentPage().getUrl(), 'Search results for: ' + searchValue);				
			}
        } catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load data from url. '));
			return;        
        }
        if(searchValue.length() < minNoOfChar){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Minimum length of search value is '+minNoOfChar+' chars. '));
			return;        
        }
     	// START : Changed for US612/DE634 - Basant Verma
     	if(isResponsive){
     		switchSection();
     	}else{
    		refreshPageContent();
     	}
     	// END : Changed for US612/DE634 - Basant Verma
    }
    // START : Changed for US585/DE678 - Basant
    public void renderAsListSlider() {
    	displayAsList = true; // other action if needed
    }   

    public void renderAsBoxSlider() {
    	displayAsList = false; // other action if needed    	
    }
		// END : Changed for US585/DE678 - Basant
    // switch section
    public void switchSection() {
    	isDetails = true;
    	initPager();
    	refreshPageContent();
   }

    public void clearSection() {
    	isDetails = false;
    	sectionContent = new List<AggregateResult>();
    	refreshPageContent();
    	firstZeroResult = false;
    	secondZeroResult = false;
    }
    
    public PageReference userResearch(){
    	PageReference pr = ApexPages.currentPage();
    	String refine = '';
    	if(firstZeroResult || secondZeroResult){
    		refine = '&refine=true';
    	}
    	if(searchPhrase != null && searchPhrase.length() != 0){
    		pr = new PageReference( Page.SearchResult.getUrl() + '?query='+EncodingUtil.urlEncode(searchPhrase,'UTF-8')+ refine );
    		pr.setRedirect(true);
    	}
    	return pr;
    }
    
		public void R_usersearchOrdertBy(){
	    	refreshPageContent();
	  }
        
    public override void refreshPageContent() {
    	try{
   	
    	initQuery();
 		if(isDetails){
		    String sectionQueryString = sectionQuery.get(currentSection);
		    if(sectionQueryString != null && sectionQueryString != ''){
		    	// START : Changed for US612/DE634 - Basant Verma
		    	sectionContent = customSortByDate(database.query(sectionQueryString+' limit 1000 '));
					// END : Changed for US612/DE634 - Basant Verma
					numberOfItems = Integer.valueOf(sectionContent.size());
					sectionContent = getRequestedPage(sectionContent);
					if(isResponsive){
						Boolean isRefine = false;
						if(ApexPages.currentPage().getParameters().get('refine') != null && ApexPages.currentPage().getParameters().get('refine') != ''){
							isRefine = true;
						}
						if(numberOfItems == 0 && !isRefine){
							firstZeroResult = true;
						}
						if(numberOfItems == 0 && isRefine){
							secondZeroResult = true;
						}
					}
		    }
 		} else {   
			totalItemNumber = 0;
			
			Set<ID> brandIdsSet = new Set<Id>();
			List<ID> userBrands = new List<ID>(Service_API.getAccBrandIds());
			brandIdsSet = Service_API.getContentBrandIDs(userBrands);
			
			
			if(!brandIdsSet.isEmpty()){
				brandIdsString = IdSetToString(brandIdsSet);
				initQuery();
				List<AggregateResult> sectionResultList;
				String sectionQueryString = '';
		    	for(String sectionName : sectionOrder){
		    		sectionQueryString = sectionQuery.get(sectionName);
		    		// START : Changed for US612/DE634 - Basant Verma
		    		sectionResultList = database.query(sectionQueryString+' limit '+limitPerSection);
		    		// END : Changed for US612/DE634 - Basant Verma
			        if (isNewContent==false && sectionResultList!=null && sectionResultList.size()>0) {
				        for (AggregateResult currentItem : sectionResultList) {
				            String dateString = String.valueOf(currentItem.get('createdDate'));
				            DateTime itemTime = datetime.valueOf(dateString);
				            if(lastLoginDate < itemTime){
				                isNewContent = true;
				                break;
				            }   
				        }
			        }
					contentMap.put(sectionName, sectionResultList);
					totalItemNumber += sectionResultList.size();
		    		sectionItemNumber.put(sectionName, sectionResultList.size());
		    	}
			}
			Boolean isRefine = false;
			if(ApexPages.currentPage().getParameters().get('refine') != null && ApexPages.currentPage().getParameters().get('refine') != ''){
				isRefine = true;
			}
			if(totalItemNumber == 0 && !isRefine){
				firstZeroResult = true;
			}
			if(totalItemNumber == 0 && isRefine){
				secondZeroResult = true;
			}		
 		}
		
		currentBasketIds = Service_Basket.getBasketIds();
		currentFollowIds = Service_Notification.getFollowIds();
    	} catch(Exception ex){
    		Apexpages.addmessage(new apexpages.message(apexpages.severity.info, ex.getMessage()+' '+ex.getStackTraceString()));
    	}
    }
    
    // START : Changed for US612/DE716 - Basant Verma
    // This Method will remove those entries where we have multiple Content Properties record on a single ContentDescription 
    // ***** NOTE ***** : FOR RESPONSIVE SITE ONLY 
    /*private List<AggregateResult> UniqueContentOnly(List<AggregateResult> inList){
    	if(!isResponsive){
    		return inList;
    	}
    	List<AggregateResult> uniqueResList = new List<AggregateResult>();
    	Set<String> contentVIdSet = new Set<String>();
	    if(inList != null && inList.size() > 0){
	    	String tCvId = '';
		    for(AggregateResult arg : inList){
		    	tCvId = String.valueOf(arg.get('cvid'));
		    	tCvId = (tCvId == null || tCvId.trim().equals('')) ? String.valueOf(arg.get('cvidlow')) : tCvId;
		    	if(!contentVIdSet.contains(tCvId)){
		    		contentVIdSet.add(tCvId);
		    		uniqueResList.add(arg);
		    	}
		    }
	    }
	    return uniqueResList;
    }*/
    // END : Changed for US612/DE716 - Basant Verma
    
    // START : Changed for US612/DE634 - Basant Verma
    private List<AggregateResult> customSortByDate(List<AggregateResult> inList){
    	if(R_OrdertByDate == null || R_OrdertByDate.trim().equals('')){
    		return inList;
    	}
    	
    	List<AggregateResult> resultList = new List<AggregateResult>();
    	if(inList == null || inList.size() <= 1){
	        return inList;
			}
	    
	    List<AggregateResult> left = new List<AggregateResult>(), right = new List<AggregateResult>();
	    Integer middle = inList.size() / 2;
	    
	    for(integer iCount = 0; iCount < middle; iCount++){
	        left.add(inList.get(iCount));
	    }
	    for(integer iCount = middle; iCount < inList.size(); iCount++){
	        right.add(inList.get(iCount));
	    }
	    
	    left = customSortByDate(left);
	    right = customSortByDate(right);
	    
	    return applyCustomeSorting(left, right);
    }
    
    private List<AggregateResult> applyCustomeSorting(List<AggregateResult> list1, List<AggregateResult> list2){
 			List<AggregateResult> result = new List<AggregateResult>();
	    while(list1.size() > 0 || list2.size() > 0){
	        if( list1.size() > 0 && list2.size() > 0){
	            if( ((R_OrdertByDate == null || R_OrdertByDate.trim().equalsIgnoreCase('ASC')) && String.valueOf(list1.get(0).get('createdDate')).toUpperCase().compareTo(String.valueOf(list2.get(0).get('createdDate')).toUpperCase()) <= 0 )
	            		|| ((R_OrdertByDate != null && R_OrdertByDate.trim().equalsIgnoreCase('DESC')) && String.valueOf(list1.get(0).get('createdDate')).toUpperCase().compareTo(String.valueOf(list2.get(0).get('createdDate')).toUpperCase()) >= 0 ) ){
	                result.add(list1.get(0));
	                list1.remove(0);
	            }
	            else{
	                result.add(list2.get(0));
	                list2.remove(0);
	            }
	        }
	        else if( list1.size() > 0){
	            result.add(list1.get(0));
	            list1.remove(0);
	        }
	        else if( list2.size() > 0){
	            result.add(list2.get(0));
	            list2.remove(0);
	        }
 			}	
	    return result;
 		}
		// END : Changed for US612/DE634 - Basant Verma
		
    private String IdSetToString(Set<ID> valueList){
    	String result = '';
    	String glue = '';
		for (String value : valueList) {         
			result += glue + '\''+value+'\' ';
			glue = ',';
		}    	
    	return result;
    }

    private String IdSetToString(Set<String> valueList){
    	String result = '';
    	String glue = '';
		for (String value : valueList) {         
			result += glue + '\''+value+'\' ';
			glue = ',';
		}    	
    	return result;
    }

    private void initSections(){
    	sectionOrder = new List<string>();
    	//START : changed for US612/DE636 - Basant	
	    if(isResponsive){
	   		sectionOrder.add(RESPONSIVE);
	   		currentSection = RESPONSIVE;
	   		Set<ID> brandIdsSet = new Set<Id>();
				List<ID> userBrands = new List<ID>(Service_API.getAccBrandIds());
				brandIdsSet = Service_API.getContentBrandIDs(userBrands);
				if(!brandIdsSet.isEmpty()){
					brandIdsString = IdSetToString(brandIdsSet);
				}
	    }else{
		    sectionOrder.add(CONSTANT.MONTHLY_EXECUTION_PLAN);
				sectionOrder.add(innovationSectionName);
		    sectionOrder.add(CONSTANT.SELLING_MATERILAS);
				sectionOrder.add(CONSTANT.CATEGOTY_DEVELOPMENT);
		    sectionOrder.add(CONSTANT.BRAND_MARKETING_INFORMATION);
				sectionOrder.add(CONSTANT.PRODUCT_IMAGES_AND_LOGOS);
		    sectionOrder.add(CONSTANT.COLLABORATION);
				if(isInternalUser){
					sectionOrder.add(CONSTANT.PLANNING);
				}
		    sectionOrder.add(CONSTANT.MULTICULTURAL);		
	    }
			//END : changed for US612/DE636 - Basant
		
    	contentMap = new Map<string, List<AggregateResult>>();
		sectionItemNumber = new map<string, integer>();
    	for(String sectionName : sectionOrder){
    		contentMap.put(sectionName, new List<AggregateResult>());
    		sectionItemNumber.put(sectionName, 0);    		
    	}
    }

     
    
     private void initQuery(){
    	
    	sectionQuery = new map<string, string>();
    	
		Set<Id> currentDistributors = Service_API.getAIDs();
		Set<String> currentDivisions  = Service_API.getDivisions();
		String currentDistributorsString = IdSetToString(currentDistributors);
		String currentDivisionsString = IdSetToString(currentDivisions);
		
		String ids = ''; // SOSL extra ids
		String searchValDec = EncodingUtil.urlDecode(searchValue, 'ASCII');

		/*
		// CURRENTLY TURN OFF 
		if(searchValue.length()>1){
			//SOSL QUERY FOR IDS
			List<List<SObject>> similar = [FIND :searchValDec IN ALL FIELDS RETURNING ContentVersion(Id)];
			String glue = '';
			for (SObject value : similar.get(0)) {         
				ids += glue + '\''+value.id+'\' ';
				glue = ',';
			} 
		}
		*/
		/* Start: changes for R_SearchResult page Harish Khatri(Appirio Offshore) */ 
		searchValue = searchValDec;
		// BMI SEARCH			    	
		String queryBMI    	= ' SELECT Sub_Category__c, Sub_Sub_Category__c, Sub_Sub_Sub_Category__c, content_description__r.Tags__c tag, content_description__r.is_video__c is_video, content_description__r.video_id__c video_id, content_description__r.Title__c title, content_description__r.Description__c description, content_description__r.Content_Version_Id__c cvid, content_description__r.filetype__c filetype, content_description__r.Preview_Available__c previewAvailable, content_description__r.Preview_Id__c previewId, content_description__r.filesize__c filesize, content_description__r.filesize_low__c filesize_low, content_description__r.Content_Version_Id_Low__c cvidlow, max(content_description__r.Uploaded_date__c) createdDate, content_description__r.image_resolution__c imageRes  FROM content_property__c' 
	 	 		   		  	+ ' WHERE content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') and Category__c in (\''+CONSTANT.BRAND_MARKETING_INFORMATION+'\') '
   						   	+ ' AND (content_description__r.Content_Id__c in ('+brandIdsString+') OR ( content_description__r.Portfolio__c=true and content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') ) ) '
				   		   	+ ' AND (((content_description__r.Title__c like \'%'+searchValue+'%\' OR content_description__r.Description__c like \'%'+searchValue+'%\' OR content_description__r.Tags__c like \'%'+searchValue+'%\'))' + ((ids!='') ? ' OR (content_description__r.content_version_id__c in ('+ids+') OR content_description__r.content_version_id_low__c in ('+ids+'))) ' : ')') +
				           	+ ' GROUP BY Sub_Category__c, Sub_Sub_Category__c, content_description__r.Tags__c, Sub_Sub_Sub_Category__c, content_description__r.is_video__c, content_description__r.video_id__c, content_description__r.Title__c, content_description__r.Description__c, content_description__r.Content_Version_Id__c, content_description__r.filetype__c, content_description__r.Preview_Available__c, content_description__r.Preview_Id__c, content_description__r.filesize__c, content_description__r.filesize_low__c, content_description__r.Content_Version_Id_Low__c, content_description__r.image_resolution__c  '+ 
				           	//+ ' ORDER BY Sub_Sub_Sub_Category__c, content_description__r.Description__c ASC' ;
				           	+ ' ORDER BY Sub_Sub_Sub_Category__c, content_description__r.Description__c ' + (R_OrdertByAlpha != null && R_OrdertByAlpha.trim() != '' ? R_OrdertByAlpha+' ' : 'ASC ') ;
		sectionQuery.put(CONSTANT.BRAND_MARKETING_INFORMATION, queryBMI);
		
		// SM SEARCH
		String querySM     	= ' SELECT Sub_Category__c, Sub_Sub_Category__c, Sub_Sub_Sub_Category__c, content_description__r.Tags__c tag, content_description__r.is_video__c is_video, content_description__r.video_id__c video_id, content_description__r.Title__c title, content_description__r.Description__c description, content_description__r.Content_Version_Id__c cvid, content_description__r.filetype__c filetype, content_description__r.Preview_Available__c previewAvailable, content_description__r.Preview_Id__c previewId, content_description__r.filesize__c filesize, content_description__r.filesize_low__c filesize_low, content_description__r.Content_Version_Id_Low__c cvidlow, max(content_description__r.Uploaded_date__c) createdDate, content_description__r.image_resolution__c imageRes  FROM content_property__c' 
 		           		   	+ ' WHERE content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') and Category__c in (\''+CONSTANT.SELLING_MATERILAS+'\') '
			 	   		   	+ ' AND (content_description__r.Content_Id__c in ('+brandIdsString+') OR ( content_description__r.Portfolio__c=true and content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') ) ) '
       				 	   	+ ' AND (((content_description__r.Title__c like \'%'+searchValue+'%\' OR content_description__r.Description__c like \'%'+searchValue+'%\' OR content_description__r.Tags__c like \'%'+searchValue+'%\'))' + ((ids!='') ? ' OR (content_description__r.content_version_id__c in ('+ids+') OR content_description__r.content_version_id_low__c in ('+ids+'))) ' : ')') +
		        		   	+ ' GROUP BY Sub_Category__c, Sub_Sub_Category__c, content_description__r.Tags__c, Sub_Sub_Sub_Category__c, content_description__r.is_video__c, content_description__r.video_id__c, content_description__r.Title__c, content_description__r.Description__c, content_description__r.Content_Version_Id__c, content_description__r.filetype__c, content_description__r.Preview_Available__c, content_description__r.Preview_Id__c, content_description__r.filesize__c, content_description__r.filesize_low__c, content_description__r.Content_Version_Id_Low__c, content_description__r.image_resolution__c  '+ 
		        	       	//+ ' ORDER BY Sub_Sub_Sub_Category__c, content_description__r.Description__c ASC';
		        	       	+ ' ORDER BY Sub_Sub_Sub_Category__c, content_description__r.Description__c ' + (R_OrdertByAlpha != null && R_OrdertByAlpha.trim() != '' ? R_OrdertByAlpha+' ' : 'ASC ') ;
		sectionQuery.put(CONSTANT.SELLING_MATERILAS, querySM);

		// MEP SEARCH
		String queryMEP    	= ' SELECT content_description__r.is_video__c is_video, content_description__r.Tags__c tag, content_description__r.video_id__c video_id, content_description__r.Title__c title, content_description__r.Description__c description, content_description__r.Content_Version_Id__c cvid, content_description__r.filetype__c filetype, content_description__r.Preview_Available__c previewAvailable, content_description__r.Preview_Id__c previewId, content_description__r.Content_Version_Id_Low__c cvidlow, content_description__r.filesize__c filesize, content_description__r.filesize_low__c filesize_low, max(content_description__r.Uploaded_date__c) createdDate, content_description__r.image_resolution__c imageRes  FROM content_property__c' + 
		               		+ ' WHERE content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') and category__c=\''+Constant.MONTHLY_EXECUTION_PLAN+'\' AND content_description__r.Content_Id__c in ('+brandIdsString+') '
		               		+ ' AND (((content_description__r.Title__c like \'%'+searchValue+'%\' OR content_description__r.Description__c like \'%'+searchValue+'%\' OR content_description__r.Tags__c like \'%'+searchValue+'%\') )' + ((ids!='') ? ' OR (content_description__r.content_version_id__c in ('+ids+') OR content_description__r.content_version_id_low__c in ('+ids+'))) ' : ')') +
		               		+ ' GROUP BY content_description__r.is_video__c, content_description__r.Tags__c, content_description__r.video_id__c, content_description__r.Title__c, content_description__r.Description__c, content_description__r.Content_Version_Id__c, content_description__r.filetype__c, content_description__r.Preview_Available__c, content_description__r.Preview_Id__c, content_description__r.Content_Version_Id_Low__c, content_description__r.filesize__c, content_description__r.filesize_low__c, content_description__r.image_resolution__c  '+ 
		               		//+ ' ORDER BY content_description__r.Description__c ASC';
		               		+ ' ORDER BY content_description__r.Description__c ' + (R_OrdertByAlpha != null && R_OrdertByAlpha.trim() != '' ? R_OrdertByAlpha+' ' : 'ASC ');
		sectionQuery.put(CONSTANT.MONTHLY_EXECUTION_PLAN, queryMEP);
		
		// IVAP SEARCH
		String queryIVAP   	= ' SELECT content_description__r.is_video__c is_video, content_description__r.Tags__c tag, content_description__r.video_id__c video_id, content_description__r.Title__c title, content_description__r.Description__c description, content_description__r.Content_Version_Id__c cvid, content_description__r.filetype__c filetype, content_description__r.Preview_Available__c previewAvailable, content_description__r.Preview_Id__c previewId, content_description__r.Content_Version_Id_Low__c cvidlow, content_description__r.filesize__c filesize, content_description__r.filesize_low__c filesize_low, max(content_description__r.Uploaded_date__c) createdDate, content_description__r.image_resolution__c imageRes  FROM content_property__c' + 
		               		+ ' WHERE content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') and category__c=\''+innovationSectionName+'\' AND content_description__r.Content_Id__c in ('+brandIdsString+') '
		               		+ ' AND (((content_description__r.Title__c like \'%'+searchValue+'%\' OR content_description__r.Description__c like \'%'+searchValue+'%\' OR content_description__r.Tags__c like \'%'+searchValue+'%\'))' + ((ids!='') ? ' OR (content_description__r.content_version_id__c in ('+ids+') OR content_description__r.content_version_id_low__c in ('+ids+'))) ' : ')') +
		               		+ ' GROUP BY content_description__r.is_video__c, content_description__r.Tags__c, content_description__r.video_id__c, content_description__r.Title__c, content_description__r.Description__c, content_description__r.Content_Version_Id__c, content_description__r.filetype__c, content_description__r.Preview_Available__c, content_description__r.Preview_Id__c, content_description__r.Content_Version_Id_Low__c, content_description__r.filesize__c, content_description__r.filesize_low__c, content_description__r.image_resolution__c  '+ 
		               		//+ ' ORDER BY content_description__r.Description__c ASC';
		               		+ ' ORDER BY content_description__r.Description__c '+ (R_OrdertByAlpha != null && R_OrdertByAlpha.trim() != '' ? R_OrdertByAlpha+' ' : 'ASC ') ;
		sectionQuery.put(innovationSectionName, queryIVAP);
		
		// PIL SEARCH
  		String queryPIL    	= ' SELECT content_description__r.is_video__c is_video, content_description__r.Tags__c tag, content_description__r.video_id__c video_id, content_description__r.Title__c title, content_description__r.Description__c description, content_description__r.Content_Version_Id__c cvid, content_description__r.filetype__c filetype, content_description__r.Preview_Available__c previewAvailable, content_description__r.Preview_Id__c previewId, content_description__r.Content_Version_Id_Low__c cvidlow, content_description__r.filesize__c filesize, content_description__r.filesize_low__c filesize_low, max(content_description__r.Uploaded_date__c) createdDate, content_description__r.image_resolution__c imageRes  FROM content_property__c' + 
		               		+ ' WHERE content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') and category__c=\''+Constant.PRODUCT_IMAGES_AND_LOGOS+'\' AND content_description__r.Content_Id__c in ('+brandIdsString+') '
		               		+ ' AND (((content_description__r.Title__c like \'%'+searchValue+'%\' OR content_description__r.Description__c like \'%'+searchValue+'%\' OR content_description__r.Tags__c like \'%'+searchValue+'%\'))' + ((ids!='') ? ' OR (content_description__r.content_version_id__c in ('+ids+') OR content_description__r.content_version_id_low__c in ('+ids+'))) ' : ')') +
		               		+ ' GROUP BY content_description__r.is_video__c, content_description__r.Tags__c, content_description__r.video_id__c, content_description__r.Title__c, content_description__r.Description__c, content_description__r.Content_Version_Id__c, content_description__r.filetype__c, content_description__r.Preview_Available__c, content_description__r.Preview_Id__c, content_description__r.Content_Version_Id_Low__c, content_description__r.filesize__c, content_description__r.filesize_low__c, content_description__r.image_resolution__c  '+ 
		               		//+ ' ORDER BY content_description__r.Description__c ASC';
		               		+ ' ORDER BY content_description__r.Description__c  '+ (R_OrdertByAlpha != null && R_OrdertByAlpha.trim() != '' ? R_OrdertByAlpha+' ' : 'ASC ') ;
		sectionQuery.put(CONSTANT.PRODUCT_IMAGES_AND_LOGOS, queryPIL);

		// CD SEARCH
		String queryCD     	= ' SELECT Sub_Category__c, Sub_Sub_Category__c, Sub_Sub_Sub_Category__c, content_description__r.Tags__c tag, content_description__r.is_video__c is_video, content_description__r.video_id__c video_id, content_description__r.Title__c title, content_description__r.Description__c description, content_description__r.Content_Version_Id__c cvid, content_description__r.filetype__c filetype, content_description__r.Preview_Available__c previewAvailable, content_description__r.Preview_Id__c previewId, content_description__r.filesize__c filesize, content_description__r.filesize_low__c filesize_low, content_description__r.Content_Version_Id_Low__c cvidlow, max(content_description__r.Uploaded_date__c) createdDate, content_description__r.image_resolution__c imageRes  FROM content_property__c' 
 		           		   	+ ' WHERE content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') and Category__c in (\''+CONSTANT.CATEGOTY_DEVELOPMENT+'\') '
			 	   		   	+ ' AND (content_description__r.Content_Id__c in ('+brandIdsString+') OR ( content_description__r.Portfolio__c=true and content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') ) ) '
       				 	   	+ ' AND (((content_description__r.Title__c like \'%'+searchValue+'%\' OR content_description__r.Description__c like \'%'+searchValue+'%\' OR content_description__r.Tags__c like \'%'+searchValue+'%\'))' + ((ids!='') ? ' OR (content_description__r.content_version_id__c in ('+ids+') OR content_description__r.content_version_id_low__c in ('+ids+'))) ' : ')') +
		        		   	+ ' GROUP BY Sub_Category__c, Sub_Sub_Category__c, content_description__r.Tags__c, Sub_Sub_Sub_Category__c, content_description__r.is_video__c, content_description__r.video_id__c, content_description__r.Title__c, content_description__r.Description__c, content_description__r.Content_Version_Id__c, content_description__r.filetype__c, content_description__r.Preview_Available__c, content_description__r.Preview_Id__c, content_description__r.filesize__c, content_description__r.filesize_low__c, content_description__r.Content_Version_Id_Low__c, content_description__r.image_resolution__c  '+ 
		        	       //	+ ' ORDER BY Sub_Sub_Sub_Category__c, content_description__r.Description__c ASC';	
		        	       	+ ' ORDER BY Sub_Sub_Sub_Category__c, content_description__r.Description__c '+ (R_OrdertByAlpha != null && R_OrdertByAlpha.trim() != '' ? R_OrdertByAlpha+' ' : 'ASC ') ;					
		sectionQuery.put(CONSTANT.CATEGOTY_DEVELOPMENT, queryCD);
		
		// COLLABORATION SEARCH
		String queryCOL    	= ' SELECT Content_Version_Id__c cvid,  Tags__c, Description__c description, filesize__c filesize, filetype__c filetype, Title__c  title, is_video__c is_video, video_id__c video_id, max(Uploaded_date__c) createdDate, image_resolution__c imageRes, OwnerId ' 
		  			  	    + ' FROM File__c '
		  			  	// Start : Changes for DE635 - Basant Verma
						    + ' WHERE Classification__c includes (\''+Service_API.getSectionTheme()+'\') and Page_Section__c = \''+CONSTANT.COLLABORATION+'\' and (( Distributors__c includes ('+currentDistributorsString+') ' + ((currentDivisionsString != null && !currentDivisionsString.trim().equals('')) ? ' or Division_Access__c in ('+currentDivisionsString+')' : '') + ' ) ';
						    // END : Changes for DE635 - Basant Verma
							if(isInternalUser){
								queryCOL += ' or ( Distributors__c = null or Division_Access__c = null ) ';
							}   
			   queryCOL    += ' ) ' 
		               		+ ' AND (((Title__c like \'%'+searchValue+'%\' OR Description__c like \'%'+searchValue+'%\' OR Tags__c like \'%'+searchValue+'%\'))' + ((ids!='') ? 'OR (content_version_id__c in ('+ids+')))  '  : ')' )+			
							+ ' GROUP BY Content_Version_Id__c, Tags__c, video_id__c,  Description__c, image_resolution__c, filesize__c, filetype__c, Title__c, is_video__c, OwnerId' +
							//+ ' ORDER BY Description__c ASC';	
							+ ' ORDER BY Description__c  '+ (R_OrdertByAlpha != null && R_OrdertByAlpha.trim() != '' ? R_OrdertByAlpha+' ' : 'ASC ') ;
		sectionQuery.put(CONSTANT.COLLABORATION, queryCOL);
		system.debug('DNAMES x'+currentDivisionsString+'x');
		
		// PLANNING SEARCH
		String queryPLN    	= ' SELECT  Content_Version_Id__c cvid, Description__c description, Tags__c, filesize__c filesize, filetype__c filetype, Title__c  title, is_video__c is_video, video_id__c video_id, Preview_Available__c previewAvailable, Preview_Id__c previewId, max(Uploaded_date__c) createdDate, image_resolution__c imageRes ' + 
		               		+ ' FROM File__c ' +
		               		+ ' WHERE Classification__c includes (\''+Service_API.getSectionTheme()+'\') and ( Available_Until__c >= TODAY or Available_Until__c = null) and (Page_Section__c = \'' + CONSTANT.PLANNING + '\' ) ' +
							+ ' AND (((Title__c like \'%'+searchValue+'%\' OR Description__c like \'%'+searchValue+'%\' OR Tags__c like \'%'+searchValue+'%\'))' + ((ids!='') ? 'OR (content_version_id__c in ('+ids+')))  '  : ')' )+
		           	   		+ ' GROUP BY Tags__c, video_id__c, Content_Version_Id__c, Description__c, filesize__c, filetype__c, Title__c, is_video__c, Preview_Available__c, Preview_Id__c, image_resolution__c ' +
		           	   		//+ ' ORDER BY Description__c ASC';
		           	   		+ ' ORDER BY Description__c '+ (R_OrdertByAlpha != null && R_OrdertByAlpha.trim() != '' ? R_OrdertByAlpha+' ' : 'ASC ') ;
		sectionQuery.put(CONSTANT.PLANNING, queryPLN);
		
		String queryMUL    	= ' SELECT Sub_Category__c, Sub_Sub_Category__c, Sub_Sub_Sub_Category__c, content_description__r.Tags__c, content_description__r.is_video__c is_video, content_description__r.video_id__c video_id, content_description__r.Title__c title, content_description__r.Description__c description, content_description__r.Content_Version_Id__c cvid, content_description__r.filetype__c filetype, content_description__r.Preview_Available__c previewAvailable, content_description__r.Preview_Id__c previewId, content_description__r.filesize__c filesize, content_description__r.filesize_low__c filesize_low, content_description__r.Content_Version_Id_Low__c cvidlow, max(content_description__r.Uploaded_date__c) createdDate, content_description__r.image_resolution__c imageRes  FROM content_property__c' 
	 	 		   		  	+ ' WHERE content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') and Category__c in (\''+CONSTANT.MULTICULTURAL+'\') '
   						   	+ ' AND (content_description__r.Content_Id__c in ('+brandIdsString+') OR ( content_description__r.Portfolio__c=true and content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') ) ) '
				   		   	+ ' AND (((content_description__r.Title__c like \'%'+searchValue+'%\' OR content_description__r.Description__c like \'%'+searchValue+'%\' OR content_description__r.Tags__c like \'%'+searchValue+'%\'))' + ((ids!='') ? ' OR (content_description__r.content_version_id__c in ('+ids+') OR content_description__r.content_version_id_low__c in ('+ids+'))) ' : ')') +
				           	+ ' GROUP BY Sub_Category__c, content_description__r.Tags__c, Sub_Sub_Category__c, Sub_Sub_Sub_Category__c, content_description__r.is_video__c, content_description__r.video_id__c, content_description__r.Title__c, content_description__r.Description__c, content_description__r.Content_Version_Id__c, content_description__r.filetype__c, content_description__r.Preview_Available__c, content_description__r.Preview_Id__c, content_description__r.filesize__c, content_description__r.filesize_low__c, content_description__r.Content_Version_Id_Low__c, content_description__r.image_resolution__c  '+ 
				           	//+ ' ORDER BY content_description__r.Description__c ASC';
				           	+ ' ORDER BY content_description__r.Description__c '+ (R_OrdertByAlpha != null && R_OrdertByAlpha.trim() != '' ? R_OrdertByAlpha+' ' : 'ASC ') ;
		sectionQuery.put(CONSTANT.MULTICULTURAL, queryMUL);
		/* End: changes for R_SearchResult page Harish Khatri(Appirio Offshore) */
			//START : changed for US612/DE636 - Basant	
	     /*String queryResponsive    	= ' SELECT Sub_Category__c, Sub_Sub_Category__c, Sub_Sub_Sub_Category__c, content_description__r.Tags__c, content_description__r.is_video__c is_video, content_description__r.video_id__c video_id, content_description__r.Title__c title, content_description__r.Description__c description, content_description__r.Content_Version_Id__c cvid, content_description__r.filetype__c filetype, content_description__r.Preview_Available__c previewAvailable, content_description__r.Preview_Id__c previewId, content_description__r.filesize__c filesize, content_description__r.filesize_low__c filesize_low, content_description__r.Content_Version_Id_Low__c cvidlow, max(content_description__r.Uploaded_date__c) createdDate, content_description__r.image_resolution__c imageRes FROM content_property__c' 
	 	 		   		  	+ ' WHERE content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') and Category__c in ('+sectionsListsForResponsive()+') '
   						   	+ ' AND (content_description__r.Content_Id__c in ('+brandIdsString+') OR ( content_description__r.Portfolio__c=true and content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') ) ) '
				   		   	+ ' AND (((content_description__r.Title__c like \'%'+searchValue+'%\' OR content_description__r.Description__c like \'%'+searchValue+'%\' OR content_description__r.Tags__c like \'%'+searchValue+'%\'))' + ((ids!='') ? ' OR (content_description__r.content_version_id__c in ('+ids+') OR content_description__r.content_version_id_low__c in ('+ids+'))) ' : ')') +
				          + ' GROUP BY Sub_Category__c, content_description__r.Tags__c, Sub_Sub_Category__c, content_description__r.is_video__c, content_description__r.video_id__c, content_description__r.Title__c, content_description__r.Description__c, content_description__r.Content_Version_Id__c, content_description__r.filetype__c, content_description__r.Preview_Available__c, content_description__r.Preview_Id__c, content_description__r.filesize__c, content_description__r.filesize_low__c, content_description__r.Content_Version_Id_Low__c, content_description__r.image_resolution__c  '+ 
				          + ' ORDER BY content_description__r.Description__c '+ (R_OrdertByAlpha != null && R_OrdertByAlpha.trim() != '' ? R_OrdertByAlpha+' ' : 'ASC ') ; */
			String queryResponsive = ' SELECT Tags__c, is_video__c is_video, video_id__c video_id, Title__c title, Description__c description, Content_Version_Id__c cvid, filetype__c filetype, Preview_Available__c previewAvailable, Preview_Id__c previewId, filesize__c filesize, filesize_low__c filesize_low, Content_Version_Id_Low__c cvidlow, max(Uploaded_date__c) createdDate, image_resolution__c imageRes FROM content_description__c ' 
						+ ' WHERE Classification__c includes (\''+Service_API.getSectionTheme()+'\') '
						+ ' AND (Content_Id__c in ('+brandIdsString+') OR ( Portfolio__c=true and Classification__c includes (\''+Service_API.getSectionTheme()+'\') ) ) '
						+ ' AND (((Title__c like \'%'+searchValue+'%\' OR Description__c like \'%'+searchValue+'%\' OR Tags__c like \'%'+searchValue+'%\'))' + ((ids!='') ? ' OR (content_version_id__c in ('+ids+') OR content_version_id_low__c in ('+ids+'))) ' : ')') +
						+ ' GROUP BY Tags__c, is_video__c, video_id__c, Title__c, Description__c, Content_Version_Id__c, filetype__c, Preview_Available__c, Preview_Id__c, filesize__c, filesize_low__c, Content_Version_Id_Low__c, image_resolution__c  '+ 
						+ ' ORDER BY Description__c '+ (R_OrdertByAlpha != null && R_OrdertByAlpha.trim() != '' ? R_OrdertByAlpha+' ' : 'ASC ') ;
			sectionQuery.put(RESPONSIVE, queryResponsive);
	    //END : changed for US612/DE636 - Basant
    }
    
	//START : changed for US612/DE636 - Basant
	/*private String sectionsListsForResponsive() {
		String R_sections = '';
		R_sections = '\'' + CONSTANT.MONTHLY_EXECUTION_PLAN + '\'' +
			', \'' + innovationSectionName + '\'' +
	    ', \'' + CONSTANT.SELLING_MATERILAS + '\'' +
			', \'' + CONSTANT.CATEGOTY_DEVELOPMENT + '\'' +
	    ', \'' + CONSTANT.BRAND_MARKETING_INFORMATION + '\'' +
			', \'' + CONSTANT.PRODUCT_IMAGES_AND_LOGOS + '\'' +
	    ', \'' + CONSTANT.COLLABORATION + '\'';
			if(isInternalUser){
				R_sections += ', \'' + CONSTANT.PLANNING + '\'';
			}
	    R_sections += ', \'' + CONSTANT.MULTICULTURAL + '\'';	
		return R_sections;
	}*/
	//END : changed for US612/DE636 - Basant
    
	// Start: Changes for Responsive Site - Randy Wandell (Appirio) 7/10/13    
    public void setResponsiveState() {
		if(pageUrl.toLowerCase().indexOf('r_searchresult') > -1) {
			isResponsive = true;
			preapareSiteNavigationMenu();
		} else {
			isResponsive = false;
			preapareSiteNavigationMenu();
		}    	
    }
    // End:
        
}