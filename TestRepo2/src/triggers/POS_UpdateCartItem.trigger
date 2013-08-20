trigger POS_UpdateCartItem on Cart_Item__c (before insert, before update) {

	//Commented out because this is being moved to a batch.  Left 
	//here in case it needs to be resurrected for some reason
	
	/*Cart_Item__c firstItem = trigger.new.get(0);
	if (firstItem.Item__c==null) {
		return; //Shouldn't happen but don't want to break from bad data
	}
	
	Id program = [select Program__c from Item__c where ID=:firstItem.Item__c].get(0).Program__c;
	System.debug('Program ID: '+program);
	Order_Window__c ow = [select Id, Order_Window__r.Id, Order_Window__r.Name, Order_Window__r.Fiscal_Year__c from Program__c where Id=:program].get(0).Order_Window__r;
	
	POS_WBSUtil util = new POS_WBSUtil(trigger.new,ow);
	util.populateWBSData();*/
	
	
	
	
}