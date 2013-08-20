@IsTest
public class POS_RecalculateWBSTest{
    
    @isTest
    public static void testRecalculateWBSController () {
        
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
               POS_RecalculateWBSController ctrl= new POS_RecalculateWBSController();
                ctrl.recalculate();
            Test.stopTest();
            
            ci = [select Id,WBS__c,Company_Code__c from Cart_Item__c where Id=:ci.Id];
            System.debug('WBS: '+ci.WBS__c);
            System.assert(ci.WBS__c == '2RCPH3PH5AHDISTPACPRG1PP');
            System.assert(ci.Company_Code__c=='2290');
             
        }
    }
    
   
    public static testmethod void testPOS_WBSCalculationTrigger() {
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
               ow  = [Select Id,Status__c from Order_window__c where Id=:ow.Id];
               ow.status__c= 'Closed';
               update ow;
            Test.stopTest();
            
            ci = [select Id,WBS__c,Company_Code__c from Cart_Item__c where Id=:ci.Id];
            System.debug('WBS: '+ci.WBS__c);
            System.assert(ci.WBS__c == '2RCPH3PH5AHDISTPACPRG1PP');
            System.assert(ci.Company_Code__c=='2290');
             
        }
    }

}