public with sharing class Controller_CodesPolicies extends Controller_Base {

	public Page_Content__c[] contentItems {get; set;}
	public list<Attachment> attachments {get; set;}
	
	public Controller_CodesPolicies() {
		pageUrl = Page.CodesPolicies.getUrl();
        addBreadcrumbItem(Apexpages.currentPage().getUrl(), Constant.CODES_POLICIES);
        contentItems = [select Page_Content_Value__c from Page_Content__c where Page_Name__c = : Constant.CODES_POLICIES ORDER BY Order__c];
        
        Set<id> contentItemsIds = new set<id>();
		
		for(Page_Content__c c : contentItems){
			contentItemsIds.add(c.id);
		}
		
    	this.attachments = [select Id, Name from Attachment where ParentId IN :contentItemsIds and isDeleted = false];
    	//system.debug(this.attachments); 
	}
}