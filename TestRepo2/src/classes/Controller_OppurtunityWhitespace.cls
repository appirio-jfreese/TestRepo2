public without sharing class Controller_OppurtunityWhitespace {
	public list<NABCA_Opportunity__c > NABCAOpportunitylist{get;set;}
	Account accountRecord;
	Public Boolean ShowList{get;set;}
	public String monthYear{get;set;}
	private final Map<integer,String> monthMap = new Map<integer,String>{1 => 'Jan',2 => 'Feb',3 => 'Mar',4 => 'Apr',5 => 'May',6 => 'Jun',7 => 'July',8 => 'Aug',9 => 'Sept',10 => 'Oct',11 => 'Nov',12 => 'Dec'};

 

	public Controller_OppurtunityWhitespace(ApexPages.StandardController controller) {
    	accountRecord=(Account)Controller.getRecord();
    	NABCAOpportunitylist = new list<NABCA_Opportunity__c>();
		NABCAOpportunitylist = [select id, account__c, brand__c, brand__r.Common_Code__c, brand__r.Common_Description__c,
										brand__r.nabca_size_description__c, Roll12_9L_Volume__c, Percent_Change_Last_Year__c,
										State_Distribution_Percent__c, Month_End_Date__c
										from NABCA_Opportunity__c
										where account__c =: accountRecord.Id
										order by Roll12_9L_Volume__c desc limit 10];
		if(NABCAOpportunitylist.size() > 0){
			ShowList = true;
			Date endDate = NABCAOpportunitylist[0].Month_End_Date__c;
			monthYear =  monthmap.get(endDate.month()) + ' ' + endDate.year().format().replace(',','');
		}
		
	}
        
}