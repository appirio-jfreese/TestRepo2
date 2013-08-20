public with sharing class POS_CalendarDetail {
	public String destination {get;set;}
	public boolean noCalendar {get;set;}
	
	public POS_CalendarDetail () {
		String referer =  ApexPages.currentPage().getHeaders().get('Referer');
		String programId = ApexPages.currentPage().getParameters().get('program');
		noCalendar=false;
		
		List<Program__c> programs = [select Id, Calendar__c, Calendar__r.RecordType.Name from Program__c where Id=:programId or Magento_Id__c=:programId];
		
		Program__c program;
		if (programs!=null && programs.size()>0) {
			program=programs.get(0);
		}
		
		if (program.Calendar__c==null) {
			destination=referer;
			noCalendar=true;
		} 
		else {
			String detailPage; 
			System.debug('Record type: '+program.Calendar__r.RecordType.Name);
			if (program.Calendar__r.RecordType.Name == 'Innovation, Sustainovation & VAP') {
				detailPage='IVAPDetails';
			}
			else if (program.Calendar__r.RecordType.Name == 'Monthly Execution Plan') {
				detailPage='MEPDetails';
			}
			else if (program.Calendar__r.RecordType.Name == 'Multicultural') {
				//detailPage='Multicultural';
				destination = referer; //Unsupported record type right now
				noCalendar=true;
				return;
			}
			else {
				destination = referer; //Unsupported record type
				noCalendar=true;
				return;
			}
			
			destination='/apex/'+detailPage+'?id='+program.Calendar__c;
		}
		
		
       	
	}
	
	@isTest
    public static void testCalendarDetail () {
    	Program__c program = POS_TestDataUtil.createProgram();
    	
    	Calendar__c calendar = new Calendar__c();
    	calendar.RecordTypeId=([select Id,Name from RecordType where Name='Innovation, Sustainovation & VAP']).Id;
    	insert calendar;
    	
    	System.debug('Rec Type: '+calendar.RecordType.Name);
    	
    	program.Calendar__c=calendar.Id;
    	update program;
    	
    	ApexPages.currentPage().getHeaders().put('Referer','test');
		ApexPages.currentPage().getParameters().put('program',program.Id);
    	POS_CalendarDetail detail = new POS_CalendarDetail();
    	System.debug('Detail: '+detail);
    	System.assert(detail.destination.indexOf('IVAPDetails')>=0);
    	
    	calendar.RecordTypeId=([select Id,Name from RecordType where Name='Monthly Execution Plan']).Id;
    	update calendar;
    	
    	detail = new POS_CalendarDetail();
    	System.debug('Detail: '+detail);
    	System.assert(detail.destination.indexOf('MEPDetails')>=0);
    	
    	calendar.RecordTypeId=([select Id,Name from RecordType where Name='Multicultural']).Id;
    	update calendar;
    	detail = new POS_CalendarDetail();
    	//No assertion here because Multicultural isn't implemented yet
    	
    	program.Calendar__c = null;
    	update program;
    	
    	detail = new POS_CalendarDetail();
    	System.debug('Detail: '+detail);
    	System.assert(detail.destination=='test');
    	
    }
}