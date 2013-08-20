public with sharing class Controller_PrivacyPolicy extends Controller_Base {

	public Page_Content__c[] contentItems {get; set;}
	public list<Attachment> attachments {get; set;}
	
	
	public Controller_PrivacyPolicy() {
        addBreadcrumbItem(Apexpages.currentPage().getUrl(), Constant.PRIVACY_POLICY);
		pageUrl = Page.PrivacyPolicy.getUrl();
        contentItems = [select Page_Content_Value__c from Page_Content__c where Page_Name__c = : Constant.PRIVACY_POLICY ORDER BY Order__c];
        
        Set<id> contentItemsIds = new set<id>();
		
		for(Page_Content__c c : contentItems){
			contentItemsIds.add(c.id);
		}
		
    	this.attachments = [select Id, Name from Attachment where ParentId IN :contentItemsIds and isDeleted = false];
    	
	}
}