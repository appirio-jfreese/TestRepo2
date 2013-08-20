global class ScheduledContentVersion implements Schedulable{

	/*
    global void execute(SchedulableContext SC) {
		CleanContentVersion jobToDo = new CleanContentVersion();
		Database.executeBatch(jobToDo);
    }
    */ 
    
    
    global void execute(SchedulableContext sc){
    	CleanContentVersion jobToDo = new CleanContentVersion();
		try{
	   		Database.executeBatch(jobToDo);
	   		String jobid = sc.getTriggerId();
	   		system.abortjob(jobid);
	  	} catch(Exception ex){
	  		String jobid = sc.getTriggerId();
	   		system.abortjob(jobid);
	 	}
	}
	
	
	
    
}