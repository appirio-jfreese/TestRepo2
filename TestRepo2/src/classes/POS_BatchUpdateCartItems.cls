/**
Batch that periodically updates any missing or invalid WBS numbers

*/
global class POS_BatchUpdateCartItems implements Database.Batchable<sObject> {


    String query = 'select Id, Ship_To__c, Item__c, Ship_To__r.Account__c, WBS__c, Company_Code__c '+
     ' from Cart_Item__c where Ship_To__c != null and '+
     ' '+
     ' Item__r.Program__r.Order_Window__r.Status__c not in (\'Archived\',\'In Review\',\'Budgeting\') ';
    // (WBS__c=null or WBS__c like \'%?%\') and
    
    List<String> orderWindowId= new List<String>();
    Boolean isFull=false;

    /*public POS_BatchUpdateCartItems (String orderWindowId) {
        this.orderWindowId=orderWindowId;
    }*/
    
    /*
       since the trigger needs to be bulkified we will make order window id as list
    */
    public POS_BatchUpdateCartItems (Boolean isFull,List<String> orderWindowId) {
            
            this.orderWindowId=orderWindowId;
            this.isFull=isFull;
    }
    
    global database.queryLocator start(Database.BatchableContext BC) 
    {
        if(!isFull){
            query = query +' and (WBS__c=null or WBS__c like \'%?%\') AND Is_Manual_WBS__c=false';
        }
        
        if(isFull){
            query = query +' and Is_Manual_WBS__c=false';
        }
        
        if (orderWindowId!=null && orderWindowId.size()>0) {
            //query = query +' and Item__r.Program__r.Order_Window__c = \''+orderWindowId+'\'';
            query = query +' and Item__r.Program__r.Order_Window__c IN: orderWindowId';
        }
        
        if (Test.isRunningTest()) {
            query=query+' LIMIT 100';
        }
        return database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Cart_Item__c> cartItems){
        
        System.debug('Cart Items: '+cartItems);
        POS_WBSUtil util = new POS_WBSUtil(cartItems);
        cartItems = util.populateWBSData(); 
        System.debug('Cart Items with WBS: '+cartItems);
        update cartItems;
        
        
            
    }

    global void finish(Database.BatchableContext BC) {
        
    }
    
    @isTest 
    public static void testUpdateCartItems () {
        
        Test.startTest();
        POS_BatchUpdateCartItems batch = new POS_BatchUpdateCartItems(false,null);
        Database.executeBatch(batch);
        Test.stopTest();
        
    }
    
    @isTest
    public static void testWBSBatch () {
        
        //Get the current time
        Datetime now = System.now();
        
        Profile p = [select id from profile where name='System Administrator'];
         
        User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id,
        timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
        
        
        System.runAs(u) {
            POS_TestDataUtil.initializeTestData();
        
            //Create Agency
            Account agency = POS_TestDataUtil.createProductionAgency();
            Account account = POS_TestDataUtil.createAccount();
            Account_Member__c member = POS_TestDataUtil.createAccountMember(account,u);

            Planning_Account__c pa = new Planning_Account__c();
            pa.Name='PAC';
            pa.District_Code__c='DIST';
            pa.Sub_Channel_Code__c = 'H';
            insert pa;

            Organizational_Unit__c org = new Organizational_Unit__c();
            org.District_Code__c = 'DIST'; 
            org.Responsible_Code__c = 'RC';
            insert org;
            
            account.Spirits_Hierarchy__c = org.Id;
            update account;
            
            Brand__c brand = POS_TestDataUtil.createBrand();
            brand.WBS_Level_3__c = 'PH3';
            brand.WBS_Level_5__c = 'PH5';
            brand.Classification__c = 'Spirits';
            update brand;
            
            Order_Window__c ow = POS_TestDataUtil.createOrderWindow();
            
            Program__c program = POS_TestDataUtil.createProgram(brand.Id,ow.Id);
            program.Program_Code__c='PRG';
            update program;
            
            Item__c item = POS_TestDataUtil.populateItem(program, agency);
            item.Channel__c = 'On-Premise';
            
            insert item;
            
            
            Cart__c crt = POS_TestDataUtil.createCart(u, ow);
            
            Cart_Item__c ci = POS_TestDataUtil.populateCartItem(item, crt);
            Ship_To__c shipTo = POS_TestDataUtil.createShipTo(account);
            ci.Ship_To__c = shipTo.Id;
            
            insert ci;
             
            System.debug('Cart Item ID: '+ci);
            List<Cart_Item__c> cartItems = new List<Cart_Item__c>();
            cartItems.add(ci);
            POS_WBSUtil util = new POS_WBSUtil(cartItems);
            cartItems = util.populateWBSData(); 
            System.assert(ci.WBS__c == '2RCPH3PH5AHDISTPACPRG1PP');
            System.assert(ci.Company_Code__c=='2290');
        
            
            Test.startTest();
            POS_BatchUpdateCartItems batch = new POS_BatchUpdateCartItems(false,null);
            Database.executeBatch(batch);
            Test.stopTest();
            
            ci = [select Id,WBS__c,Company_Code__c from Cart_Item__c where Id=:ci.Id];
            System.debug('WBS: '+ci.WBS__c);
            System.assert(ci.WBS__c == '2RCPH3PH5AHDISTPACPRG1PP');
            System.assert(ci.Company_Code__c=='2290');
             
        }
    }
}