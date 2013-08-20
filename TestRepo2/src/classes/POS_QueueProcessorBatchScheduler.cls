/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        05/16/2012
 * @description Scheduler to call QueueProcessorBatch.
 **/
global class POS_QueueProcessorBatchScheduler implements Schedulable {
    global void execute(SchedulableContext SC) { 
      	try {
	         POS_QueueProcessorBatch btch = new POS_QueueProcessorBatch() ;
	         Database.executeBatch(btch, 9); // getSession callout + 9 service callouts - as max allowed per batch execution is 10
	         
	 		 String jobid = sc.getTriggerId();
		     system.abortjob(jobid);
	         
	      } catch(Exception ex) {
	        String jobid = sc.getTriggerId();
	         system.abortjob(jobid);
	     }
    }

}