public with sharing class Controller_Compliance extends Controller_Base {

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
	
	public Controller_Compliance() {
        addBreadcrumbItem(Apexpages.currentPage().getUrl(), Constant.COMPLIANCE);
		pageUrl = Page.Compliance.getUrl();
        refreshPageContent();
	}
	
	public override void refreshPageContent() {
        content = [SELECT Sub_Category__c, Sub_Sub_Category__c, Sub_Sub_Sub_Category__c, content_description__r.is_video__c is_video, content_description__r.video_id__c video_id, content_description__r.Title__c title, content_description__r.Description__c description, content_description__r.Content_Version_Id__c cvid, content_description__r.filetype__c filetype, content_description__r.Preview_Available__c previewAvailable, content_description__r.Preview_Id__c previewId, content_description__r.filesize__c filesize, content_description__r.filesize_low__c filesize_low, content_description__r.Content_Version_Id_Low__c cvidlow,  max(LastModifiedDate) createdDate 
			        FROM content_property__c 
			        WHERE Category__c =: Constant.COMPLIANCE
			         GROUP BY Sub_Category__c, Sub_Sub_Category__c, Sub_Sub_Sub_Category__c, content_description__r.is_video__c, content_description__r.video_id__c, content_description__r.Title__c, content_description__r.Description__c, content_description__r.Content_Version_Id__c, content_description__r.filetype__c, content_description__r.Preview_Available__c, content_description__r.Preview_Id__c, content_description__r.filesize__c, content_description__r.filesize_low__c, content_description__r.Content_Version_Id_Low__c 
			         ORDER BY Sub_Sub_Sub_Category__c, content_description__r.Description__c ASC
			      ];
			      
		numberOfItems = Integer.valueOf(content.size());
		content = getRequestedPage(content);	
		currentBasketIds = Service_Basket.getBasketIds();		
	}
}