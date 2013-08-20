public without sharing class BlitzAdminController {
	
	public Integer activeCount {get;set;}
	public List<Blitz__c> blitzes {get;set;}
	public Map<Id, String> inactiveUserNamesById {get;set;}

	public BlitzAdminController(){
		init();
	}
	
	public void init(){
		blitzes =
			[SELECT Id,
					Account__c,
					Amount__c,
					Blitz_Brand__c,
					Blitz_Details__c, 
					Blitz_Program__c, 
					Comments__c, 
					Date_Finished__c, 
					OwnerId,
					Owner.isActive,
					Owner.Name,
					PDF_Link__c
			   FROM Blitz__c
			   ORDER BY Owner.Name
			];
		activeCount = blitzes.size();
		
		inactiveUserNamesById = new Map<Id, String>();
		for(Blitz__c blitz : blitzes){
			if(blitz.Owner.isActive == false && blitz.OwnerId != UserInfo.getUserId()){
				inactiveUserNamesById.put(blitz.OwnerId, blitz.Owner.Name);
			}
		}
		if(inactiveUserNamesById.size() > 0){
			String message = 'The following Blitz record owners are currently inactive: ';
			for(Integer i = 0; i < inactiveUserNamesById.size(); i++){
				message += inactiveUserNamesById.values()[i];
				if(i < inactiveUserNamesById.size() - 1){
					message += ', ';
				}
			}
			message += '. They must be activated before continuing.';
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, message));
		}
	}
	
	public void doMassArchival(){
		/*
		List<User> users = [SELECT Id FROM User WHERE Id IN :inactiveUserNamesById.keyset()];
		if(users.size() > 0){
			//activate users
			for(User user : users){
				user.isActive = true;
			}
			update users;
		}*/
		
		List<Blitz_History__c> hists = new List<Blitz_History__c>();
		for(Blitz__c blitz : blitzes){
			Blitz_History__c hist = new Blitz_History__c();
			hist.Account__c = blitz.Account__c;
			hist.Amount__c = blitz.Amount__c;
			hist.Blitz_Brand__c = blitz.Blitz_Brand__c;
			hist.Blitz_Details__c = blitz.Blitz_Details__c;
			hist.Blitz_Program__c = blitz.Blitz_Program__c;
			hist.Comments__c = blitz.Comments__c;
			hist.Date_Finished__c = blitz.Date_Finished__c;
			hist.OwnerId = blitz.OwnerId;
			hist.PDF_Link__c = blitz.PDF_Link__c;
			hists.add(hist);
		}
		
		insert hists;
		delete blitzes;
		
		/*
		if(users.size() > 0){
			//deactivate users
			deactivateUsers(inactiveUserNamesById.keyset());
		}*/
		
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, activeCount + ' Blitz records have been converted to Blitz History records.'));
		init();
	}
	
	/*
	@future
	private static void deactivateUsers(Set<Id> userIds){
		List<User> users = [SELECT Id FROM User WHERE Id IN :userIds];
		for(User user : users){
			user.isActive = false;
		}
		update users;
	}*/

}