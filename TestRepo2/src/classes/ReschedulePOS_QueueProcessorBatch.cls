/****
Created By : Jai Gupta [Appirio Jaipur]
Created Date : July 09 ,2013
Related to : Image upload Failure -- This class reschedules POS_QueueProcessorBatch job if it is not running for last 30 mins.
*****/

global class ReschedulePOS_QueueProcessorBatch implements Schedulable {
    global void execute(SchedulableContext SC) { 
        try {
            final Integer MAX_HOURS_TO_WAIT = 1;
            final Integer MAX_MINUTES_TO_WAIT = 30 ;
            DateTime dt = System.now();
            AsyncApexJob asyncJob = null;            
            boolean scheduleNow = false ;
            List<AsyncApexJob> asyncJobList = new List<AsyncApexJob>([SELECT Id, ApexClass.Name,CompletedDate from AsyncApexJOb where ApexClass.Name = 'POS_QueueProcessorBatch' order by completedDate DESC Limit 1]);
            
            if(asyncJobList.size() == 0) {
                scheduleNow = true ;
            } else {
                Long currentTime = System.now().getTime();
                Long LastCompleteTime = asyncJobList.get(0).CompletedDate.getTime();
                
                Long minutesFromLastSchedule = (currentTime - LastCompleteTime)/1000/60 ;
                
                system.debug('=======minutesvalue======='+minutesFromLastSchedule );
                
                if(minutesFromLastSchedule > MAX_MINUTES_TO_WAIT) {
                    scheduleNow = true ;
                }
            }
            
            if(scheduleNow) {
                POS_QueueProcessorBatch btch = new POS_QueueProcessorBatch() ;
                Database.executeBatch(btch, 9);
            }
                    
          } catch(Exception ex) {
              system.debug('=========Error during the process======='+ex.getMessage());
       }
    }
}