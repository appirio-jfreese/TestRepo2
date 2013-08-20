/**
* @author Denise Bacher
* @date 19/08/2011
* @description Create and update Content_Proxy__c when changes are made to the associated ContentVersion/ContentDocument.
*           Using ContentDocumentID on the Content_Proxy__c so it keeps the link to the document when new versions are uploaded.
*/
trigger contentTrigger on ContentVersion (before insert, before update, after update) {
    if (Trigger.isUpdate) {
        TriggerContentDescription.disabled = true;
        TriggerFile.disabled = true;
        //we need call action "on before update" to create a contentDescription object if it doesn't exists and populate a value for a contentDecription field
        if (Trigger.isBefore) {
            TriggerContentVersion.updateContentDescriptionAndFileOnBeforeUpdate(Trigger.newMap);
        } else {
            TriggerContentVersion.updateContentDescriptionAndFileOnAfterUpdate(Trigger.newMap);
        }
        TriggerFile.disabled = false;
        TriggerContentDescription.disabled = false;
    }
    
    /**
    Modified by : Jai Gupta [Appirio Jaipur]
    Modified Date : 30th Oct, 2012
    Related to : Case #00003058 (Do not need validation rule to be worked on Drink Image workspace)
    **/
    if(Trigger.isInsert || Trigger.isUpdate) {
        if(Trigger.isBefore){
            // Custom setting that holds ids of Diageo direct workspace (update custom setting reocrds with workspace Ids)
            set<string> workspaceIds = new set<string>();
            set<string> contentTypes = new set<string>();
            
            for(DiageoDirectLibraries__c ddl : DiageoDirectLibraries__c.getAll().values()) {
                if(ddl.Name == 'ContentTypes') {
                	for(String id : ddl.Id__c.split(',')) {
                		contentTypes.add(id);
                	}
                } else if(ddl.Name == 'ContentWorkspace') {
					for(String id : ddl.Id__c.split(',')) {
                		workspaceIds.add(id);
                	}
                }
            }
            system.debug('===========contentTypes=========='+contentTypes);
            system.debug('===========workspaceIds=========='+workspaceIds);
            for(ContentVersion con : trigger.new) {
                system.debug('=========con.FirstPublishLocationId======'+con.FirstPublishLocationId);
                system.debug('=========con.RecordTypeId======'+con.RecordTypeId);
            	if(con.Description == '' || con.Description == null) {
            		if((con.FirstPublishLocationId != null && workspaceIds.contains(con.FirstPublishLocationId)
            			|| (con.RecordTypeId != null && contentTypes.contains(con.RecordTypeId)))) {
            			con.addError('Description is a required field');
            		}
            	}
            }
        }
    }
}