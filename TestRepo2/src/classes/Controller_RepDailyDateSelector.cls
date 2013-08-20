public with sharing class Controller_RepDailyDateSelector {
    public event eventRecord;
    
    public Controller_RepDailyDateSelector(ApexPages.StandardController controller) {
        eventRecord=(event)controller.getRecord();
    }
    
    public pageReference GeneratePDF(){
        string month=string.valueof(eventRecord.ActivityDate.month());
        string day=string.valueof(eventRecord.ActivityDate.day());
        String year=string.valueof(eventRecord.ActivityDate.year());
        
        pageReference pg= new pageReference('/apex/RepDailyActivitiesWorksheet?date='+month+'/'+day+'/'+year);        
        return pg;
    }

}