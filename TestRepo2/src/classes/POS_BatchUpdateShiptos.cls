/*
This class updates the various shipto records when a specific shipto is edited or removed
*/
global class POS_BatchUpdateShiptos implements Database.Batchable<sObject> {
    private integer operation;
    private Ship_To__c originalShipTo;
    private Ship_To__c replacementShipTo;
    
    
    public static String query = 'select Id, Ship_To__c, Item__c from Cart_Item__c ';
    
    public POS_BatchUpdateShiptos (Ship_To__c originalShipTo, Ship_To__c replacementShipTo) {
        this.originalShipTo=originalShipTo;
        this.replacementShipTo = replacementShipTo;
    }
    
    global database.queryLocator start(Database.BatchableContext BC) 
    {
        String filteredQuery = query+' where Ship_To__c=\''+originalShipTo.Id+'\'';
        
        System.debug('QUERY: '+query);
        return database.getQueryLocator(filteredQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<Cart_Item__c> cartItems){
        System.debug('Updating: '+cartItems);
        for (Cart_Item__c cartItem:cartItems) {
            cartItem.Ship_To__c = replacementShipTo.Id;
        }
        
        update cartItems;
    }

    global void finish(Database.BatchableContext BC) {
        
    }
    
    @isTest 
    public static void testReplaceShipToId () {
        Order_Window__c ow = POS_TestDataUtil.createOrderWindow();
        Program__c program = POS_TestDataUtil.createProgram(ow.Id);
        Item__c item = POS_TestDataUtil.createItem(program);
        User shopper = [Select Id,Name FROM User WHERE Id =:UserInfo.getUserId()];//POS_TestDataUtil.createStdUser();
        Cart__c cart = POS_TestDataUtil.createCart(shopper, ow);
        
        Ship_To__c shipTo = POS_TestDataUtil.createShipTo();
        
        Cart_Item__c cartItem = new Cart_Item__c();
        cartItem.Item__c=item.Id;
        cartItem.Cart__c=cart.Id;
        cartItem.Quantity__c=item.Packout_Quantity__c;
        cartItem.Ship_To__c=shipTo.Id;
        insert cartItem;
        
        Ship_To__c shipTo2 = POS_TestDataUtil.createShipTo();
        
        Test.startTest();
        POS_BatchUpdateShiptos batch = new POS_BatchUpdateShiptos(shipTo,shipTo2);
        Database.executeBatch(batch);
        Test.stopTest();
        
        Cart_Item__c cartItemLoaded = [select Ship_To__c from Cart_Item__c where Id=:cartItem.Id];
        System.debug('LOADED: '+cartItemLoaded);
        System.assert(cartItemLoaded.Ship_To__c==shipTo2.Id);
        
        
    }
}