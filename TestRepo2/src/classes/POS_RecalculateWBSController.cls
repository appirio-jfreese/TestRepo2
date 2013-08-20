public class POS_RecalculateWBSController{
        
        /*
              ID:US868

            Name:POS Admin: Button and API call to trigger WBS recalculation.
             
            Description:
            As a POS CM Admin or POS Agency, I need the ability to recalculate the WBS codes for an order window at will.
             
            Today WBS are a 24 character string that lives on the cart item object.  
            These WBS string gets populated by a trigger after update on the cart_item object.  
            This trigger invokes POS_WBSUtil to recalculate wbs string based on multiple attributes of the 
            cart item and its associations.
       */        
        
        String full_missing;
        public POS_RecalculateWBSController(){
            
             full_missing = ApexPages.currentPage().getParameters().get('calculate');               
        }
        
        public void recalculate(){
            Boolean isFull = full_missing=='full'?true:false;
            
            //schedule the batch apex
            POS_BatchUpdateCartItems batch = new POS_BatchUpdateCartItems(isFull ,null); 
            Database.executeBatch(batch);
  
        }
        
    
}