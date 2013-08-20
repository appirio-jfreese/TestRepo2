public with sharing class TriggerHomeVideo {
    public static boolean disabled = false;
    
    public static void onAfterInsertAndUpdate(list<HomeVideo__c> newItems) {
        if (TriggerFile.disabled) {
            return;
        }
              
	   	Id current = null;
	    String currentClassification = null;
	    list<String> currentClassificationList = null;
	    
	    for (HomeVideo__c hv: newItems) {
	    	if (hv.current__c == true) {
	    		current = hv.Id;
	    		currentClassification = hv.Classification__c;
	    		break;
	    	}
	    }
	    
	    if(currentClassification != null && currentClassification != ''){
	    	currentClassificationList = currentClassification.split(';');
	    }
	     
	    if (current != null && currentClassification != null && currentClassification != '') {
	    	set<String> currentClassificationSet = new set<string>(currentClassificationList);
	    	String result = '';
	    	String glue = '';
			for (String value : currentClassificationSet) {         
				result += glue + '\''+value.trim()+'\' ';
				glue = ',';
			}    	
	
	        HomeVideo__c[] currentVideos = database.query('SELECT Id, Classification__c FROM HomeVideo__c WHERE current__c = true AND Id != \''+String.valueOf(current)+'\' AND Classification__c includes  ('+result+') ');
	        list<HomeVideo__c> toUpdates = new list<HomeVideo__c>();
	        
	        if (currentVideos.size()>0) {
			    for (HomeVideo__c hvu: currentVideos) {
			    	String newClassification = hvu.Classification__c;
			    	for(String cl : currentClassificationSet){
			    		newClassification = newClassification.replaceAll(cl.trim(),'');
			    	}
			    	Boolean newCurrent = true;
			    	if(newClassification == null || newClassification.trim() == ''){
			    		newCurrent = false;
			    	}
			        toUpdates.add(new HomeVideo__c(id=hvu.id, Classification__c=newClassification, current__c=newCurrent));
			    }
	        }
	        if (toUpdates.size()>0) {
	        	TriggerFile.disabled = true;
	        	update toUpdates;
	        	TriggerFile.disabled = false;
	        }
	    }
       
    }
}