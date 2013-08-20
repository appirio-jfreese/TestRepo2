public with sharing class Controller_FileDelete {
	
	private ApexPages.StandardController con;
	public File__c fileRecord{get;set;}	
	
	public Controller_FileDelete(ApexPages.StandardController controller) {    	
        con = controller;                
        fileRecord = (File__c)controller.getRecord();                        		     
    }
    
    public PageReference deleteAndRedirect()
    {
    	File__c file = [Select Id, Content_ID__c From File__c  Where Id=:fileRecord.Id];
    	List<File__c> fs =[Select Content_ID__c From File__c Where Content_ID__c = :file.Content_ID__c];
		delete(fs);	        		
		        			   		
		List<ContentDocument> cd = [Select Id From ContentDocument Where Id = :file.Content_ID__c];
		delete(cd);	
		
		String url = File__c.SObjectType.getDescribe().getKeyPrefix();
		return new PageReference('/'+url);

    }

}