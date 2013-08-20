public with sharing class Service_Messages {

	// send email (share)
	public String sRecipientName {public get; public set; }
	public String sRecipientEmail {public get; public set; }
	public String sRecipientMsg {public get; public set; }
	public String cShareLink {public get; public set;}
	public String cShareLinkLow {public get; public set;}
	public User sender {protected get; protected set; }
	public Boolean isSend {public get; public set; }
	// for single share
	public String cvid {public get; public set;}

	// for multiple share
	public String cvids {public get; public set;}

	public list<Share_cache__c> cache {public get; public set;}

	public Service_Messages() {
		sender = [select Email, Name from User where Id = :Service_API.getUID()];
		sRecipientName = null;
		sRecipientEmail = null;
		sRecipientMsg = null;
		isSend = false;	
		cache = new	list<Share_cache__c>();	
	}

    public void sendEmailMsg(){
		isSend = false;	
		String sendMsg = sRecipientMsg;
		try{
	    	string fileName = cShareLink; 
	    	string fileDescription = '';
	        if (cvid != null) {
	            ContentVersion cv = [SELECT Title, Description FROM ContentVersion WHERE Id=:cvid];
	            if (cv != null) {
	                filename = cv.Title;
	                fileDescription = cv.Description;
	            }
	        }
	        
	    	Messaging.reserveSingleEmailCapacity(1);
			set<String> recipients = new set<String>();
			if (sRecipientEmail!=null && sRecipientEmail.indexOf(',')!=-1) {
				list<string> tmpRecipients = sRecipientEmail.split(',');
				for(string r : tmpRecipients){
					// check email regex?
					if(r!=null && r!='' && r.length() > 3) {
						if(!recipients.contains(r)){
							recipients.add(r);
						}
					}
				}
	        
				if (recipients.size()>99) {
	                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Too many recipients.' ));
	                return;
				}
			
			} else {
				recipients = new set<String>{sRecipientEmail};
			}
			
		
			list<Messaging.SingleEmailMessage> msgReadyToSend = new list<Messaging.SingleEmailMessage>();
			
			// cache
	        prepareCacheItem(cvid, fileDescription, sRecipientEmail);

			for(String email : recipients){
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setToAddresses(new list<String>{email});
		    	mail.setReplyTo(sender.Email);
		    	mail.setSubject(sender.Name + ' sent you file from Diageo Direct');
				mail.setSenderDisplayName(sender.Name);
				mail.setBccSender(false);
				mail.setUseSignature(false);
				String plainBody = sRecipientMsg;
				
				//add share link to the message if missing
				if (cShareLink != null) {
					if(sRecipientMsg == null || sRecipientMsg == '') {
						sRecipientMsg = '\n\n'+sender.Name+' shared with You:';
						sRecipientMsg += '\n\n<a href="'+ cShareLink + '">'+fileName+'</a>';
						if(cShareLinkLow != null){
							sRecipientMsg += '\n\n<a href="'+ cShareLinkLow + '">'+fileName+'</a>';
						}
						plainBody = '\n\n'+sender.Name+' shared with You:';
						plainBody += '\n\n' + cShareLink;					
						if(cShareLinkLow != null){
							plainBody += '\n\n' + cShareLinkLow;
						}	
					} else if (sRecipientMsg.indexOf(cShareLink, 0) == -1) {
						sRecipientMsg += '\n\n'+sender.Name+' shared with You:';
		                sRecipientMsg += '\n\n<a href="'+ cShareLink + '">'+fileName+'</a>';
		                
		                if(cShareLinkLow != null){
		                	sRecipientMsg += '\n\n<a href="'+ cShareLinkLow + '">'+fileName+'</a>';
		                }
						plainBody += '\n\n'+sender.Name+' shared with You:';
		                plainBody += '\n\n' + cShareLink;
		                if(cShareLinkLow != null){
							plainBody += '\n\n' + cShareLinkLow;
						}
					}
		        }
		        
		        mail.setPlainTextBody(plainBody);
		        if (sRecipientMsg != null) {
		        	sRecipientMsg = sRecipientMsg.replaceAll('\n','<br/>');
		        }
				mail.setHtmlBody(sRecipientMsg);
				msgReadyToSend.add(mail);
			}
			Messaging.sendEmail(msgReadyToSend);
			saveCache();
			isSend = true;
			sRecipientName = null;
			sRecipientEmail = null;
			sRecipientMsg = null;
			
		}
		catch (Exception e) {
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to send message.'));
			sRecipientMsg = sendMsg;
			isSend = false;	
			
		}
    }   

    public void closeEmailMsg(){
    	isSend = false;
    	cvids = null;
		sRecipientName = null;
		sRecipientEmail = null;
		sRecipientMsg = null;
		cache = new	list<Share_cache__c>();
    }
    
    public void sendEmailMsgMultiple(){
		isSend = false;
		String sendMsg = sRecipientMsg;
		list<String> cvidList = cvids.split(',');
        if(cvidList.size()>0) {
            if(cvidList.get(0)==null || cvidList.get(0)=='') {
                cvidList.remove(0);
            } else if(cvidList.get(cvidList.size()-1)==null || cvidList.get(cvidList.size()-1)=='') {
                cvidList.remove(cvidList.size()-1);
            }
        }       
     	list<File__c> contentFiles = new list<File__c>();
    	list<Content_Description__c> contentDescriptions = new list<Content_Description__c>();
    	list<Content_Description__c> contentDescriptionsLow = new list<Content_Description__c>();
    	
    	   	
		if(cvidList.size() != 0){
			//3.20.2013-Case4269-LSLEVIN-START//
			//Map<String,String> descrShareMap = new Map<String,String>();			
			//Map of Reserved Key Value Pairs so the links can be sorted
			Map<String,String> linkShareMap = new Map<String,String>();
			//Map of Lower Case Content Titles for Sorting
			Map<String,String> lowerConMap = new Map<String,String>();
			
			try{
				contentDescriptions = [select Description__c, Title__c, share_link__c, Content_Version_Id__c, Content_Version_Id_Low__c
									   from Content_Description__c
									   where Content_Version_Id__c in :cvidList];			           
    		} catch (Exception e) {
    			contentDescriptions = new list<Content_Description__c>();
    		}

			try{
				contentDescriptionsLow = [select Description__c, Title__c, share_link_low__c, Content_Version_Id__c, Content_Version_Id_Low__c
									   from Content_Description__c
									   where Content_Version_Id_Low__c in :cvidList];        
    		} catch (Exception e) {
    			contentDescriptionsLow = new list<Content_Description__c>();
    		}

			try{
				contentFiles = [select Description__c, Title__c, share_link__c, Content_Version_Id__c
	                            from File__c
			  					where Content_Version_Id__c in :cvidList] ;        
    		} catch (Exception e) {
    			contentFiles = new list<File__c>();
    		}
    		
			try{	        
		    	Messaging.reserveSingleEmailCapacity(1);
				set<String> recipients = new set<String>();
				if (sRecipientEmail!=null && sRecipientEmail.indexOf(',')!=-1) {
					list<string> tmpRecipients = sRecipientEmail.split(',');
					for(string r : tmpRecipients){
						// check email regex?
						if(r!=null && r!='' && r.length() > 3) {
							if(!recipients.contains(r)){
								recipients.add(r);
							}
						}
					}
			        
					if (recipients.size()>99) {
		                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Too many recipients.' ));
		                return;
					}
				} else {
					recipients = new set<String>{sRecipientEmail};
				}
				
				system.debug(recipients);
				
				list<Messaging.SingleEmailMessage> msgReadyToSend = new list<Messaging.SingleEmailMessage>();
				
					String plainBody = sRecipientMsg; 
					//add share link to the message if missing
					if (contentDescriptions.size() != 0 || contentDescriptionsLow.size() != 0 || contentFiles.size() != 0) {
						sRecipientMsg += '\n\n'+sender.Name+' shared with You:';
						plainBody += '\n\n'+sender.Name+' shared with You:';	
									
						for(File__c content :  contentFiles){
							if(content.share_link__c != null && content.share_link__c != ''){
			                	sRecipientMsg += '\n\n<a href="'+ content.share_link__c + '">'+content.Title__c+'</a>';
			                	plainBody += '\n\n' + content.share_link__c;
			                	
			                	// add to cache
			                	prepareCacheItem(content.Content_Version_Id__c, content.Description__c, sRecipientEmail);
							}
						}
	
	
						for(Content_Description__c content :  contentDescriptions){
							if(content.share_link__c != null && content.share_link__c != ''){
								//descrShareMap.put(content.share_link__c, content.Title__c);							
								//added by LSLEVIN
								linkShareMap.put(content.Title__c, content.share_link__c);
								lowerConMap.put(content.Title__c.toLowerCase(),content.Title__c);
			                	// add to cache
			                	prepareCacheItem(content.Content_Version_Id__c, content.Description__c, sRecipientEmail);
							}
						}
						
						for(Content_Description__c content :  contentDescriptionsLow){
							if(content.share_link_low__c != null && content.share_link_low__c != ''){
								//descrShareMap.put(content.share_link_low__c, content.Title__c+' (low res.)');							
								//added by LSLEVIN
								linkShareMap.put(content.Title__c+' (low res.)', content.share_link_low__c);
								lowerConMap.put(content.Title__c.toLowerCase()+' (low res.)',content.Title__c+' (low res.)');
			                	// add to cache
			                	prepareCacheItem(content.Content_Version_Id_Low__c, content.Description__c, sRecipientEmail);
							}
						}			
						
						//List of Content Titles
    					list<String> sortedConValues = new list<String>();
    					//List of LowerCase Content Titles
    					list<String> sortedLowCon = new list<String>();		
    					sortedLowCon.addAll(lowerConMap.keySet());
    					sortedLowCon.sort();
    					
    					for(String content : sortedLowCon){
    						sortedConValues.add(lowerConMap.get(content));
    					}
    					
   						for(integer i = 0; i < sortedConValues.size(); i++){
   							if(sortedConValues.get(i) != null && sortedConValues.get(i) != ''){
   								sRecipientMsg += '\n\n<a href="'+ linkShareMap.get(sortedConValues.get(i)) + '">'+ sortedConValues.get(i)+'</a>';
			                	plainBody += '\n\n' + linkShareMap.get(sortedConValues.get(i));
   							}
   						}

					
			/*	 	// add to mail
						for(String shLink : descrShareMap.keySet()){
							if(shLink != null && shLink != ''){
			                	sRecipientMsg += '\n\n<a href="'+ shLink + '">'+ descrShareMap.get(shLink)+'</a>';
			                	plainBody += '\n\n' + shLink;
							}
						}*/
					//END-Case4269
					
			        }

				for(String email : recipients){
					Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	                mail.setToAddresses(new list<String>{email});
			    	mail.setReplyTo(sender.Email);
			    	mail.setSubject(sender.Name + ' sent you file from Diageo Direct');
					mail.setSenderDisplayName(sender.Name);
					mail.setBccSender(false);
					mail.setUseSignature(false);
					
			        // send mail
			        mail.setPlainTextBody(plainBody);
			        if (sRecipientMsg != null) {
			        	sRecipientMsg = sRecipientMsg.replaceAll('\n','<br/>');
			        }
					mail.setHtmlBody(sRecipientMsg);
					msgReadyToSend.add(mail);
				}

				Messaging.sendEmail(msgReadyToSend);
				saveCache();
				isSend = true;
				sRecipientName = null;
				sRecipientEmail = null;
				sRecipientMsg = null;
			}
			catch (Exception e) {
				ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to send message.' ));
				sRecipientMsg = sendMsg;
				isSend = false;			
			}
		} else {
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to send message.' ));
			sRecipientMsg = sendMsg;
			isSend = false;			
		}
    }       
    
    
    public void prepareCacheItem(String cv, String cn, String cr){
    	if(cv != null && cv != '' && cr != null && cr != '' ){
	    	Share_cache__c cacheItem = new Share_cache__c();
	    	cacheItem.Content_Version_Id__c = cv;
	    	cacheItem.Content_Name__c = cn;
	    	cacheItem.Recipients__c = cr;
	    	cache.add(cacheItem);
    	}
    } 
    
    public void saveCache(){
    	try{
    		if(cache != null && cache.size() != 0){
    			insert cache;
    		}
    	} catch (Exception e) {
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to cache action.' ));
		}
    } 
   
    
}