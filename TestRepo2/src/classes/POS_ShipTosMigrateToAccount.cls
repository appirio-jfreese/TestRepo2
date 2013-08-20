public class POS_ShipTosMigrateToAccount {
    public Set<String> shipToIds = new Set<String>();
    public List<sObject> shipTos = new List<sObject>();
    
    public Ship_To__c st {get;set;}
    
    public POS_ShipTosMigrateToAccount(){  
        if(ApexPages.currentPage().getParameters().get('shipToIds') <> null) {
            shipToIds.addAll(
                ApexPages.currentPage().getParameters().get('shipToIds').split(',',-1)
            );
        }
        
        st = new Ship_To__c(); 
    }
         
    public List<sObject> getShipTos() {
        return [Select Id, Name from Ship_To__c where Id in :shipToIds];
    }
    
    // transfer many ShipTos to an account
    // this method is called from VF page POS_ShiptosMigrateToAccount
    public void doTransfers(){
        if(st.Account__c != null) {
            try {
                for(String shipToId : shipToIds) {
                    doTransfer(shipToId, st.Account__c);
                }
                
                ApexPages.addMessage(
                    new ApexPages.message(ApexPages.severity.INFO, 'All Ship To(s) have been moved to this account!')
                );    
            } catch (Exception e) {
                ApexPages.addMessages(e);
            }
        } 
    }
             
     /*        
        ID:US879
        Name: POS Admin: Realign Ship to to a different account
        Description:
        As a POS Admin I'd like to have the ability to reassign a ship to from one account to another and have all the corresponding child  objects moved automatically.  Due to salesforce restriction on child relationships this will need to be achieved with a copy then delete of ship to.
         
        Acceptance Criteria:
         
        - Inputs are Ship to and Target account for the move.
        - Tool should create a new shipto on the target account with the right owner transferred.
        - Should move all user ship tos, to the new ship to
        - Should move all cart items to the new ship to.
        - Should mark the old ship to as removed.
     */
     
     
     public void doTransfer(Ship_To__c shipto,Account target){
         doTransfer(shipto.Id,target.Id);
     }
     
     public void doTransfer(String shipToId,String Id){
             
            //first we will fetch all the relevant ship to details - we dont rely on the record passed as it may not contains all details
            try{
                List<Ship_To__c> shipToList = [Select Name, Account__c,Address_Type__c,Attention__c,City__c,Contact_Email__c,Notes__c,Phone__c,Removed__c,State__c,Street__c,Street_2__c,Zip__c,Is_Deleted__c FROM Ship_To__c WHERE Id=:shiptoId LIMIT 1];
            
                if(shipToList .size()==0) return;
                Ship_To__c ship=shipToList [0];
                Ship_To__c newshipto= ship.clone(false,true);
                newshipto.Account__c=id;
                //newshipto.CreatedById = ship.CreatedById;
                
                insert newshipto;     
                
                //lets update the old ship as removed
                ship.Removed__c=true;
                update ship;
                
                //once we have the new shipto created start the batch processes:to move the cart items(existing)
                POS_BatchUpdateShiptos batch = new POS_BatchUpdateShiptos(ship , newshipto);
                Database.executeBatch(batch); 
                
                //move all the user shipto also :-  we will use future method
                transferUserShipTo(shipToId,newshipto.Id);  
                
            }catch(Exception e){
            
            }
             
     }
     @future
     public static void transferUserShipTo(String oldShipToId,String newShipToId){
             //get all the user ships
             List<User_Ship_To__c> ushipto =[Select Id,Ship_To__c,User__c,Magento_Ship_To_ID__c,Favorite__c FROM User_Ship_To__c WHERE Ship_To__c=:oldShipToId];
             if(ushipto .size()==0) return;
             List<User_Ship_To__c> toInsert = new List<User_Ship_To__c>();
             for (User_Ship_To__c shipto:ushipto ) {
                User_Ship_To__c newus = shipto.clone(false,true);
                newus.Ship_To__c=newShipToId;
                toInsert.add(newus);
             } 
             insert  toInsert ;            
             delete ushipto;
     }
      
     static testmethod void testMigration(){
         Account newAccount = new Account(Name='test1');    
         insert newAccount;
         
           Brand__c brd = new Brand__c(Name = 'Portfolio', Classification__c='Spirits', Diageo_Direct_Visible__c=true, Brand_Type__c='Individual');
          insert brd;
         
         //let us create a ship to
          Order_Window__c ow = POS_TestDataUtil.createOrderWindow();
          Program__c program = POS_TestDataUtil.createProgram(ow.Id);
          Item__c item = POS_TestDataUtil.createItem(program);
          User shopper = [Select Id,Name FROM User WHERE Id=:UserInfo.getUserId()];
          Cart__c cart = POS_TestDataUtil.createCart(shopper, ow);
          
        
          
          Ship_To__c shipTo = POS_TestDataUtil.createShipTo();
          
          Cart_Item__c cartItem = new Cart_Item__c();
          cartItem.Item__c=item.Id;
          cartItem.Cart__c=cart.Id;
          cartItem.Quantity__c=item.Packout_Quantity__c;
          cartItem.Ship_To__c=shipTo.Id;
          insert cartItem;
          
          //create user ship to
          User_Ship_To__c us = new User_Ship_To__c();
          us.User__c =shopper .Id;
          us.ship_to__c=shipTo.Id;
          insert us;
          
          
          Test.startTest();
             POS_ShipTosMigrateToAccount job= new POS_ShipTosMigrateToAccount();
             job.doTransfer(shipTo, newAccount);
          Test.StopTest();
          
     } 
}