/*******************************************************************************
Name        : Controller_Basket.cls

 Updated By  : Basant Verma (Appirio Offshore)   
 Date        : 6/12/13
 Story/Task  : US79/DE569
*******************************************************************************/
public with sharing class Service_Notification {
	
    public static void addFollow(list<ID> contentvIds){
    	// Start : Changes for US79/DE569 by Basant Verma
			Service_Follow.addFollow(contentvIds);
			// End : Changes for US79/DE569 by Basant Verma
    	/*
    	try{
    		list<File__c> files1 = [select Id from File__c where Content_Version_Id__c in :contentvIds];
    		list<Content_Description__c> files2 = [select Id from Content_Description__c where Content_Version_Id__c in :contentvIds or Content_Version_Id_Low__c in :contentvIds];
	    	List<FollowContent__c> ess = new List<FollowContent__c>();
	    	for(File__c cid : files1){
	    		ess.add(new FollowContent__c(User__c = Service_API.getUID(), File__c = cid.id));
	    	}
	    	for(Content_Description__c cid : files2){
	    		ess.add(new FollowContent__c(User__c = Service_API.getUID(), Content_Description__c = cid.id));
	    	}
	    	insert ess;
    	}catch(Exception ex){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Could not subscribe to content.'));
    	}
    	*/
    }

    
    public static Set<Id> getFollowIds(){
    	// Start : Changes for US79/DE569 by Basant Verma
			return Service_Follow.getFollowIds();
			// End : Changes for US79/DE569 by Basant Verma
    	/*
    	try{
			Id userId = Service_API.getUID();
			List<FollowContent__c> ess = [select Content_Description__c, File__c from FollowContent__c where User__c = :userId];
			List<Id> files = new List<Id>();
			List<Id> descr = new List<Id>();
			for(FollowContent__c fc : ess){
				if(fc.File__c != null)
					files.add(fc.File__c);
				else if(fc.Content_Description__c != null)
					descr.add(fc.Content_Description__c);
			}
			List<File__c> filesObj = [select Content_Version_Id__c from File__c where Id in :files];
			List<Content_Description__c> descrObj = [select Content_Version_Id_Low__c, Content_Version_Id__c from Content_Description__c where id in :descr];
			for(File__c file : filesObj){
				contentIds.add(file.Content_Version_Id__c);
			}
			for(Content_Description__c cd : descrObj){
				if(cd.Content_Version_Id__c != null)
					contentIds.add(cd.Content_Version_Id__c);
				if(cd.Content_Version_Id_Low__c != null)
					contentIds.add(cd.Content_Version_Id_Low__c);
			}
		}catch(Exception ex){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Could not load subscriptions.'));
    	}
    	return contentIds;
    	*/
    }
       
    
    public static void removeFollow(list<ID> contentvIds){
    	// Start : Changes for US79/DE569 by Basant Verma
			Service_Follow.removeFollow(contentvIds);
			// End : Changes for US79/DE569 by Basant Verma
    	/*
    	try{
    		list<ID> contentIds = new list<Id>();
    		list<File__c> files1 = [select id from File__c where Content_Version_Id__c in :contentvIds];
    		list<Content_Description__c> files2 = [select Id from Content_Description__c where Content_Version_Id__c in :contentvIds or Content_Version_Id_Low__c in :contentvIds];
    		for(File__c f : files1){
    			contentIds.add(f.id);
    		}
    		for(Content_Description__c f : files2){
    			contentIds.add(f.id);
    		}
			Id userId = Service_API.getUID();
			List<FollowContent__c> ess = [select id from FollowContent__c where User__c = :userId and (File__c in :contentIds or Content_Description__c in :contentIds)];
			delete ess;
    	}catch(Exception ex){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Could not unsubscribe.'));
    	}
    	*/
    }
    
}