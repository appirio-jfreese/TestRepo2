trigger ShareCacheHistory on Share_cache__c (after insert) {

	// get already existing emails;
	set<String> existingEmails = new set<string>();
	
	list<User_Address_Book__c> existingAddressBookItems = [SELECT Email__c, First_Name__c, Last_Name__c FROM User_Address_Book__c where OwnerId = :Service_API.getUID()];
	for(User_Address_Book__c bookItem : existingAddressBookItems){
		if(!existingEmails.contains(bookItem.Email__c)){
			existingEmails.add(bookItem.Email__c);
		}
	}

	list<User_Address_Book__c> newAddressBookItemToInsert = new list<User_Address_Book__c>();

	for(Share_cache__c historyItem : trigger.new){
		if(historyItem.Recipients__c != null && historyItem.Recipients__c != '') {
			list<String> contentRecipients = historyItem.Recipients__c.split(',');
			for(String recEmail : contentRecipients){
				if(recEmail != null && recEmail != '' && !existingEmails.contains(recEmail) ){
					User_Address_Book__c tmp = new User_Address_Book__c();
					tmp.Email__c = recEmail;
					newAddressBookItemToInsert.add(tmp);
				}			
			}
		}
	}
	
	if(newAddressBookItemToInsert.size() != 0){
		insert newAddressBookItemToInsert;
	}
}