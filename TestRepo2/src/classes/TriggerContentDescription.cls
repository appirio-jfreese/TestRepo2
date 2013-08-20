public with sharing class TriggerContentDescription {
    public static boolean disabled = false;
    public static void onBeforeUpdate(boolean isUpdate, map<id, Content_Description__c> newContentDescriptionMap, map<id, Content_Description__c> oldContentDescriptionMap) {
        if (TriggerContentDescription.disabled) {
            return;
        }
        list<ContentVersion> cvs = new list<ContentVersion>();
        for(String key : newContentDescriptionMap.keySet()) {
            Content_Description__c cd = newContentDescriptionMap.get(key);
            string name = cd.title__c;
            if(name.length()>80) {
                name = name.substring(0, 79);
            }
            cd.name = name;
	        if (isUpdate) {
	        	boolean changed = false;
	        	ContentVersion cv = new ContentVersion(Id=cd.Content_Version_Id__c);
                if( cd.Title__c != oldContentDescriptionMap.get(key).Title__c) {
                    cv.Title = cd.Title__c;
                    changed = true;
                }
                if( cd.Classification__c != oldContentDescriptionMap.get(key).Classification__c) {
                    cv.Classification__c = cd.Classification__c;
                    changed = true;
                }
                if( cd.Portfolio__c != oldContentDescriptionMap.get(key).Portfolio__c) {
                    cv.Portfolio__c = cd.Portfolio__c;
                    changed = true;
                }
                if( cd.RTS__c != oldContentDescriptionMap.get(key).RTS__c) {
                    cv.RTS__c = cd.RTS__c;
                    changed = true;
                }
                if( cd.Description__c != oldContentDescriptionMap.get(key).Description__c) {
                    cv.Description = cd.Description__c;
                    changed = true;
                }
                if( cd.TBA__c != oldContentDescriptionMap.get(key).TBA__c) {
                    cv.TBA__c = cd.TBA__c;
                    changed = true;
                }
                if( cd.Image_Resolution__c != oldContentDescriptionMap.get(key).Image_Resolution__c) {
                    cv.Image_Resolution__c = cd.Image_Resolution__c;
                    changed = true;
                }
                if( cd.Matrix_type__c != oldContentDescriptionMap.get(key).Matrix_type__c) {
                    cv.Matrix_type__c = cd.Matrix_type__c;
                    changed = true;
                }
                if (changed) {
                    cvs.add(cv);
                }
	        }
	    }
	    if (cvs.size()>0) {
	        TriggerContentVersion.disabled = true;
	        update cvs;
	        TriggerContentVersion.disabled = false;
	    }
    }

}