global class scheduledBatchableUpdateCartItems implements Schedulable{
   global void execute(SchedulableContext sc) {
      List<String> orderWindowId = new List<String>();
      POS_BatchUpdateCartItems batch = new POS_BatchUpdateCartItems(true, orderWindowId); 
      Database.executebatch(batch);
   }
}