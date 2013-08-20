trigger ForgotUserName on Forgot_User_Name__c (after insert) {
	try{
	    set<String> mailsNofications = new set<String>();
	    
	    list<Forgot_User_Name__c> notifyMade = new list<Forgot_User_Name__c>();
	    for (Forgot_User_Name__c fu: Trigger.new) {
	    	if(fu.Notification_sent__c != true){
				mailsNofications.add(fu.User_mail__c);
				Forgot_User_Name__c tmp = new Forgot_User_Name__c(id = fu.id);
				tmp.Notification_sent__c = true;
				notifyMade.add(tmp);
	    	}
	    }
	    
	    update notifyMade;
	    
	    list<User> usersToNotify = [SELECT id, username, email from User where email IN :mailsNofications];
	    map<String,set<String>> usersNotification = new map<String,set<String>>();
	    for(User u : usersToNotify){
	    	Set<String> tmpSet = new Set<String>();
	    	if(usersNotification.containsKey(u.email)){
	    		tmpSet = usersNotification.get(u.email);
	    	}
	   		tmpSet.add(u.username);
	   		usersNotification.put(u.email, tmpSet);    	
	    }
	    list<Messaging.SingleEmailMessage> msgReadyToSend = new list<Messaging.SingleEmailMessage>();
		Messaging.reserveSingleEmailCapacity(1);
		for(String userEmail : usersNotification.keySet()){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			list<String> recipients = new list<String>{userEmail};
			mail.setToAddresses(recipients);
		   	mail.setSubject('Diageo Direct portal! Your user names.');
			mail.setBccSender(false);
			mail.setUseSignature(false);
			String answer = 'Your user names can be found below \n\n';
			String glue = '';
			set<String> mailSet = usersNotification.get(userEmail);
			for(String mailPart : mailSet){
				answer += glue + mailPart;
				glue = ', \n';
			}
			answer += '\n\nThank you, \n Diageo Direct Support';
			
		    mail.setPlainTextBody(answer);
	        if (answer != null) {
	        	answer = answer.replaceAll('\n','<br/>');
	        }	    
			mail.setHtmlBody(answer);
			msgReadyToSend.add(mail);
		}
		Messaging.sendEmail(msgReadyToSend);
	}
	catch (Exception e) {
		
	}
}