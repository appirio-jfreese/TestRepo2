global class POS_ScheduleWBSBatch implements Schedulable {

    global void execute(SchedulableContext SC) { 
        
         POS_BatchUpdateCartItems btch = new POS_BatchUpdateCartItems(true,null) ;
         Database.executeBatch(btch);
    
    }

}