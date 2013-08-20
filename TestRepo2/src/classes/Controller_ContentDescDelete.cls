public with sharing class Controller_ContentDescDelete {
	
	private ApexPages.StandardController con;
	public Content_Description__c descRecord{get;set;}	
	
	public Controller_ContentDescDelete(ApexPages.StandardController controller) {    	
        con = controller;                
        descRecord = (Content_Description__c)controller.getRecord();                		     
    }
    
    public PageReference deleteAndRedirect()
    {
    	Content_Description__c descR = [Select Id, Content_ID__c From Content_Description__c  Where Id=:descRecord.Id];
    	List<Content_Property__c> cp = [Select Content_Description__c From Content_Property__c Where Content_Description__c = :descR.Id];
		delete(cp);
		 
		List<ContentBrand__c> cb = [Select Content_Description__c From ContentBrand__c Where Content_Description__c = :descR.Id];
		delete(cb);
		
		List<ContentDocument> cd = [Select Id From ContentDocument Where Id = :descR.Content_ID__c];
		delete(cd);
		        		
		delete(descR);

		String url = Content_Description__c.SObjectType.getDescribe().getKeyPrefix();
		return new PageReference('/'+url);
    }

}