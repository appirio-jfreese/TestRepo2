public with sharing class ActionBrandEditController {
	
	private Action_Product_Link__c apl	{get;set;}

	public ActionBrandEditController(ApexPages.StandardController stc){
		apl = [SELECT Id, Action__c FROM Action_Product_Link__c WHERE Id = :stc.getId()];
	}
	
	public PageReference forwardPage(){
		return new PageReference('/' + apl.Id + '/e?nooverride=1&saveURL=%2f' + apl.Action__c);///{!Case.Id}/e?saveURL=%2FsomeOtherObject);
	}

}