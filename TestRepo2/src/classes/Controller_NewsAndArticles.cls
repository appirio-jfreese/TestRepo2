public with sharing class Controller_NewsAndArticles extends Controller_Base {

	// list of articles to display
	public list<NewsAndArticles__c> articles {get; set;}
	public list<Attachment> attachments {get; set;}
    public Id articleId {get; set;} 
    public String actionUrl {get; set;}
    public NewsAndArticles__c currentArticle {get; set;}

    public Controller_NewsAndArticles(){
		pageUrl = Page.NewsAndArticles.getUrl();
		actionUrl = Page.NewsAndArticles.getUrl();
		articles = Service_API.getNewsAndArticles();
		
        if(ApexPages.currentPage().getParameters().get('id') != null){
			try {
				articleId = Id.valueOf(ApexPages.currentPage().getParameters().get('id'));
				currentArticle = Service_API.getArticle(articleId);
				addBreadcrumbItem(Apexpages.currentPage().getUrl(), currentArticle.Title__c);
				this.getAttachments();
	        } catch( Exception err ){
	            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load article. Error occured during processing.' ));
    	        return;
        	}
        }
    }
    
    public void getAttachments(){
    	this.attachments = [select Id, Name from Attachment where ParentId =: this.articleId and isDeleted = false];
    	system.debug(this.attachments);
    }
}