public with sharing class Controller_RepDailyActiviesWorksheet {
    public string footerValue{get;set;} //Text to render on bottom left footer
    public Date dateValue{get;set;}
    public string URLParam{get;set;}
    public list<Event> eventList{get;set;}
    list<Action__c> actionList {get;set;}
    public List<wrapperClass> wrapperList{get;set;}
    public string RequiredStatus='Open - Not Started;Open - In Progress';//add ';' separated values for additional status
    
    public class wrapperClass{
        public event eventRecord{get;set;}
        public list<Action__c> actionList{get;set;}
        public DateTime LocaleStartTime{get;set;}
        
        public boolean getShowBlock(){
            if(actionList==null || actionList.size()==0)
                return false;
              return true;
            }
    }
    
    public Controller_RepDailyActiviesWorksheet(){
        URLParam=System.currentPagereference().getParameters().get('date');
        dateValue=date.Parse(URLParam);
        footerValue=System.Label.Rep_Footer_Comment_Instructions+' '+System.Label.Rep_Footer_Legal_Disclaimer;
        eventList=new List<Event>([Select e.WhatId, e.ReminderDateTime,e.EndDateTime, e.StartDateTime,e.AccountId,e.account.name,e.account.billingstreet,e.account.billingcity,e.account.billingstate,e.account.billingcountry From Event e where e.Whatid!=null and DAY_ONLY(e.EndDateTime)=:dateValue and IsRecurrence = false and e.ownerid=:system.userinfo.getUserid()]);
        set<id> accountid= new Set<id>();
        
        for(Event e: eventList){
            accountId.add(e.whatid);
        } 
        
        Set<string> statusSet= new Set<String>(RequiredStatus.split(';'));
        ActionList= new List<Action__c>([Select a.Due_Date__c,a.name,goal__c, a.Account__c,a.goal__r.name, a.goal__r.recordType.name From Action__c a where account__c in:accountId and status__c in: statusSet ORDER BY Due_Date__c, Name]);
        Map<id, List<Action__c>> ActionEventMap= new Map<id,List<Action__c>>();
        
        for(Action__c a:ActionList){
            List<Action__c> actionList;
            if(ActionEventMap.get(a.account__c)==null){
                actionList= new List<Action__c>();
               }else{
                actionList=ActionEventMap.get(a.account__c);
            }
            actionList.add(a);
            ActionEventMap.put(a.account__c,actionList); 
        }
        wrapperList= new List<WrapperClass>();
        
        for(Event e: EventList){
            wrapperClass wrapper=new wrapperClass();
            wrapper.eventRecord=e;
           // wrapper.LocaleStartTime= DateTime.parse(String.ValueOf(e.StartDateTime));
            wrapper.ActionList=ActionEventMap.get(e.accountid);      
            wrapperList.add(wrapper);
        }   
    }
    
        public String getFooterLeftContent() {
            return footerValue;
    }
    
    public String getOwnerName(){
        return System.userinfo.getname();
    }


}