/**
 * Class name: Controller_RepDailyActivities.page
 * PageName: RepDailyActivies.page
 */
@isTest
private class Test_Controller_RepDailyActivities {

    static void init(){
         //create programs
        Calendar__c dispProg = Test_RecordUtil.newCalendar('dispProg', 'Integrated National Program');
        dispProg.Start_Date__c = Date.today();
       insert dispProg;
        
        //create brand
        Test_RecordUtil.ensureBrandCanBeCreated();
        Brand__c brand = Test_RecordUtil.newBrand('Captain Morgan');
        insert brand;
        
        //create bottle sizes
        Bottle_Size__c bots1 = Test_RecordUtil.newBottleSize('1L');
        insert bots1;
        
        //create brand bottle sizes
        BrandBottle_Size__c bbs1 = Test_RecordUtil.newBrandBottleSize('Captain Morgan 1L', brand.Id, bots1.Id);
        insert bbs1;
    
        Account accountRecord= new Account(name='Some Account');
        insert accountRecord;
        
        List<Goal__c> ListGoal= new List<Goal__c>();
        
        List<RecordType> recordTypesid=[Select id from RecordType where SobjectType='Goal__C'];
        
        for(RecordType recordTyp:recordTypesid){
            Goal__c goalRecord=new Goal__c(name='Sid Test Record',recordTypeId=recordTyp.id,Suggested_Price__c=2,Due_Date__c=system.today()+7, 
            SFA_POS_Items__c='Something3', Location_Grade__c='Something2', Cases_Displayed__c=12,Minimum_of_Accounts__c=5, 
            Program__c=dispProg.id,Type_of_Ad__c='Something1', Size_of_Ad__c='Something12', Brand_Type__c=bbs1.id,Feature_Type__c='Something6',
            Brand_Category__c=brand.id, Accomplishment_Recap__c='Something4');
            ListGoal.add(goalRecord);
        }
        
        insert listGoal;
        
        list<Action__c> actionList= new List<Action__c>();
        for(Goal__c goalRecord:ListGoal){       
            Action__c actionObject=new Action__c(Account__c=accountRecord.id,goal__c=goalRecord.id);
            actionList.add(actionObject);
        }
        
        insert actionList;
   }
    
    static testMethod void myUnitTest() {
        
       // PageReference pageRef=null;
        PageReference pageRef = Page.RepDailyActivities;
        Test.setCurrentPage(pageRef);
    
        Controller_RepDailyActivities cont = new Controller_RepDailyActivities();
        
        test.startTest();
        
        init();
        cont.init();
        
        test.stopTest();
    }
}