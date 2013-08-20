trigger POS_WBSCalculation on Order_Window__c (after insert,after update) {
     
     /*  ID:US868

        Name:POS Admin: Button and API call to trigger WBS recalculation.
         
        Description:
        As a POS CM Admin or POS Agency, I need the ability to recalculate the WBS codes for an order window at will.
         
        Today WBS are a 24 character string that lives on the cart item object.  
        These WBS string gets populated by a trigger after update on the cart_item object.  
        This trigger invokes POS_WBSUtil to recalculate wbs string based on multiple attributes of the cart 
        item and its associations.
        
        Trigger should execute a full WBS recalculation when the order window status is updated to 'Closed'
     */
     
     List<String> orderWindowId = new List<String>();
     for(Order_Window__c n : trigger.new) {
         if(n.Status__c=='Closed'){
             orderWindowId.add(n.Id);
         }
     }
     
     if(orderWindowId.size()>0){
         //start the batch - limit is 5 bacthes the system will not have batch updates hence it is ok :)
         POS_BatchUpdateCartItems batch = new POS_BatchUpdateCartItems(true,orderWindowId); 
         Database.executeBatch(batch);
     }
}