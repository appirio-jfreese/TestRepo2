public with sharing class Controller_TermsAndConditions extends Controller_Base  {

	public Page_Content__c[] contentItems {get; set;}
	public list<Attachment> attachments {get; set;}
	
	
	public Controller_TermsAndConditions() {
		pageUrl = Page.TermsAndConditions.getUrl();
        addBreadcrumbItem(Apexpages.currentPage().getUrl(), Constant.TERMS_AND_CONDITIONS);
        contentItems = [select Id, Page_Content_Value__c from Page_Content__c where Page_Name__c = : Constant.TERMS_AND_CONDITIONS ORDER BY Order__c];
		
		Set<id> contentItemsIds = new set<id>();
		
		for(Page_Content__c c : contentItems){
			contentItemsIds.add(c.id);
		}
		
    	this.attachments = [select Id, Name from Attachment where ParentId IN :contentItemsIds and isDeleted = false];
    	//system.debug(this.attachments); 
    }
}