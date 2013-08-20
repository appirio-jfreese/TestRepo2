trigger ContentMatrixContentDescription on Content_Description__c (after insert, after update) {
    
	if((trigger.isInsert || trigger.isUpdate )){
			
			list<Content_Property__c> contentPropertyToInsert = new list<Content_Property__c>();
		    for(Content_Description__c c : Trigger.new){
	            if(c.Matrix_type__c != null && c.Matrix_type__c != ''){
	            	if(Trigger.isUpdate && trigger.oldmap.get(c.Id).Matrix_type__c == c.Matrix_type__c) {
	            		continue;
	            	}
	            	
	            	list<Content_Matrix__c> matrix = [Select Id, Category__c, Sub_Category__c, Sub_Sub_Category__c, Sub_Sub_Sub_Category__c FROM Content_Matrix__c WHERE Matrix_Type__c = :c.Matrix_type__c];
	            	list<Content_Property__c> currentProperty = [select Id, Category__c, Sub_Category__c, Sub_Sub_Category__c, Sub_Sub_Sub_Category__c FROM Content_Property__c where Content_Description__c = :c.id];
					if(matrix.size() != 0){
						for(Content_Matrix__c matrixItem : matrix) {
							Boolean needToCreate = true;
							for(Content_Property__c property : currentProperty) {
								if(
									property.Category__c == matrixItem.Category__c &&
									property.Sub_Category__c == matrixItem.Sub_Category__c &&
									property.Sub_Sub_Category__c == matrixItem.Sub_Sub_Category__c &&
									property.Sub_Sub_Sub_Category__c == matrixItem.Sub_Sub_Sub_Category__c 
								){
									needToCreate = false;
									break;
								}
							}
							if(needToCreate){
								Content_Property__c newCp = new Content_Property__c();
								newCp.Content_Description__c = c.id;
								newCp.Category__c = matrixItem.Category__c;
								newCp.Sub_Category__c = matrixItem.Sub_Category__c;
								newCp.Sub_Sub_Category__c = matrixItem.Sub_Sub_Category__c;
								newCp.Sub_Sub_Sub_Category__c = matrixItem.Sub_Sub_Sub_Category__c;
								newCp.Start_Date__c = date.today();
								newCp.End_Date__c = date.today();
								contentPropertyToInsert.add(newCp);
							}
						}				
					}            
	            }
		    }
		    
		    if(contentPropertyToInsert.size() != 0){
		    	insert contentPropertyToInsert;
		    }

	}
}