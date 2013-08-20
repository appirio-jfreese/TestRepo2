public with sharing class Controller_FAQ extends Controller_Base {

    public list<FAQ__c> faqs {get; set;}
    
    public Controller_FAQ() {
        addBreadcrumbItem(Apexpages.currentPage().getUrl(), Constant.FAQ);
		pageUrl = Page.FAQ.getUrl();
        faqs = Service_API.getFAQs();
    }
}