global class ScheduledContentVersion2 implements Schedulable{

	/*
    global void execute(SchedulableContext SC) {
        CleanContentVersion2 jobToDo = new CleanContentVersion2();
        Database.executeBatch(jobToDo);
    }
    */
    
    global void execute(SchedulableContext sc){
    	CleanContentVersion2 jobToDo = new CleanContentVersion2();
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