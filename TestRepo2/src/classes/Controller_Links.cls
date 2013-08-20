public with sharing class Controller_Links extends Controller_Base {
    
    public List<Hyperlink__c> brandLinks {public get; protected set;}
    public List<Hyperlink__c> facebookLinks {public get; protected set;}
    public List<Hyperlink__c> industryLinks {public get; protected set;}
    
    public Controller_Links() {
        addBreadcrumbItem(Apexpages.currentPage().getUrl(), Constant.LINKS);
		pageUrl = Page.Links.getUrl();
		
		brandLinks = Service_API.getBrandLinks();
        facebookLinks = Service_API.getFacebookLinks();
        industryLinks = Service_API.getIndustryLinks();
        
    }
}