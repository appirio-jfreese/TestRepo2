/**
 * Class name: Controller_RepDailyActivities.page
 * PageName: RepDailyActivies.page
 */
@isTest
private class Test_Controller_RepDailyWorksheet {

    static void init(){
    //create accounts
        Map<String, Id> accRTIdsByName = new Map<String, Id>();
        for(RecordType accRT : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account']){
          accRTIdsByName.put(accRT.name, accRT.Id);
        }
        
        Objective__c objectiveRecord= new Objective__c(Name='Objective',Due_date__c=System.today());
        insert objectiveRecord;
        
        Goal__c goalRecord= new Goal__c(Name='Goal Record');
        insert goalRecord;
        
        Account acc=new Account(name='Account Name');
        insert acc;
        
        List<Action__c> accs = new List<Action__c>();
        
        for(Integer i = 0; i < 10; i++){
          accs.add(new Action__c(objective__c=objectiveRecord.id,account__c=acc.id));
        }
        //insert accs;
        
        Event e= new Event(Whatid=acc.id,EndDateTime=system.today(), DurationInMinutes=0, ActivityDateTime=system.today());
        insert e;  
       }
    
    static testMethod void myUnitTest() {
        
       // PageReference pageRef=null;
        PageReference pageRef = Page.RepDailyActivitiesWorksheet;
        
        Test.setCurrentPage(pageRef);
        DateTime d = Date.Today() ;
        String dateStr =  d.format('MM/dd/yyyy');
        System.currentPagereference().getParameters().put('date',dateStr);
       
        Controller_RepDailyActiviesWorksheet thecontroller=new Controller_RepDailyActiviesWorksheet();
        init();
       
        theController.getFooterLeftContent();
        theController.getOwnerName();
    }
}